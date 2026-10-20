"""Synthetic HTTP/timing fixtures only: no model server, inference, downloads or WSL."""
from contextlib import redirect_stdout, redirect_stderr
import copy
import importlib.util
import io
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("ollama_benchmark", ROOT / "scripts/benchmarks/ollama_benchmark.py")
bench = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(bench)
REPLY = {"done": True, "response": "PRIVATE_RESPONSE_FIXTURE",
         "prompt_eval_count": 100, "prompt_eval_duration": 2_000_000_000,
         "eval_count": 20, "eval_duration": 500_000_000,
         "total_duration": 3_000_000_000, "load_duration": 250_000_000}


class Benchmarks(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name) / "private"
        env = mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(self.root))
        env.start()
        self.addCleanup(env.stop)
        output = redirect_stdout(io.StringIO())
        self.output = output.__enter__()
        self.addCleanup(output.__exit__, None, None, None)

    def api(self, base, path, payload=None, timeout=120):
        if path == "/api/tags":
            return {"models": [{"name": "fixture:local", "digest": "f" * 64}]}
        return copy.deepcopy(REPLY)

    def run_args(self, *extra):
        return ["ollama", "--model", "fixture:local", "--execute", "--confirm-local-model", *extra]

    def report(self):
        files = list((self.root / "benchmarks/ollama").glob("*.json"))
        self.assertEqual(len(files), 1)
        return json.loads(files[0].read_text(encoding="utf-8"))

    def test_ns_conversion_and_no_fake_ttft(self):
        result = bench.analyze(REPLY)
        self.assertEqual(result["prefill_tokens_per_second"], 50)
        self.assertEqual(result["decode_tokens_per_second"], 40)
        self.assertEqual(result["load_seconds"], 0.25)
        self.assertIsNone(result["ttft_seconds"])
        self.assertNotIn("response", result)

    def test_invalid_metrics_rejected(self):
        for key, value in (("eval_duration", 0), ("eval_count", True),
                           ("eval_count", 2.5), ("load_duration", -1),
                           ("total_duration", float("nan")), ("eval_count", 10**400)):
            data = copy.deepcopy(REPLY)
            data[key] = value
            with self.assertRaises(ValueError):
                bench.analyze(data)
        with self.assertRaises(ValueError):
            bench.analyze({"done": False})

    def test_zero_work_has_no_invented_throughput(self):
        data = copy.deepcopy(REPLY)
        data.update(eval_count=0, eval_duration=0)
        self.assertIsNone(bench.analyze(data)["decode_tokens_per_second"])

    def test_plan_has_no_network_or_writes(self):
        with mock.patch.object(bench, "api") as api:
            bench.main(["ollama", "--model", "fixture:local"])
        api.assert_not_called()
        self.assertFalse(self.root.exists())
        self.assertFalse(json.loads(self.output.getvalue())["network_used"])

    def test_explicit_local_confirmation_required(self):
        with mock.patch.object(bench, "api") as api:
            with self.assertRaises(ValueError):
                bench.main(["ollama", "--model", "fixture:local", "--execute"])
        api.assert_not_called()
        self.assertFalse(self.root.exists())

    def test_cloud_model_rejected_without_request(self):
        with mock.patch.object(bench, "api") as api:
            with self.assertRaises(ValueError):
                bench.model_record("http://127.0.0.1:11434", "fixture:cloud", 1)
        api.assert_not_called()

    def test_remote_urls_credentials_and_queries_rejected(self):
        for url in ("https://127.0.0.1", "http://localhost:11434",
                    "http://example.com", "http://0.0.0.0:11434",
                    "http://user:password@127.0.0.1", "http://127.0.0.1/other",
                    "http://127.0.0.1?key=fixture"):
            with self.assertRaises(ValueError):
                bench.base_url(url)
        self.assertEqual(bench.base_url("http://[::1]:11434/"), "http://[::1]:11434")

    def test_redirects_disabled(self):
        with self.assertRaises(ValueError):
            bench.NoRedirect().redirect_request(None, None, 302, "", {}, "http://example.com")

    def test_http_uses_no_environment_proxy(self):
        response = mock.MagicMock()
        response.__enter__.return_value.read.return_value = json.dumps(REPLY).encode()
        opener = mock.Mock()
        opener.open.return_value = response
        with mock.patch.object(bench.request, "build_opener", return_value=opener) as build:
            bench.api("http://127.0.0.1:11434", "/api/generate", {"model": "fixture"}, timeout=1)
        self.assertEqual(build.call_args.args[0].proxies, {})
        self.assertIsInstance(build.call_args.args[1], bench.NoRedirect)

    def test_run_is_bounded_and_logs_only_metrics(self):
        with mock.patch.object(bench, "api", side_effect=self.api) as api:
            bench.main(self.run_args("--runs", "2", "--warmups", "1"))
        self.assertEqual(api.call_count, 4)
        data = self.report()
        self.assertEqual(data["status"], "success")
        self.assertEqual(len(data["samples"]), 2)
        self.assertEqual(data["summary"]["decode_tokens_per_second"]["median"], 40)
        self.assertEqual(data["model_identity"]["digest"], "f" * 64)
        self.assertFalse(data["ttft_measured"])
        self.assertNotIn("PRIVATE_RESPONSE_FIXTURE", json.dumps(data))
        self.assertNotIn(bench.PROMPT, json.dumps(data))
        for call in api.call_args_list[1:]:
            self.assertEqual(call.args[1], "/api/generate")
            self.assertFalse(call.args[2]["stream"])
        self.assertFalse((self.root / "benchmarks/ollama/operation.lock").exists())

    def test_missing_model_stops_before_generation(self):
        with mock.patch.object(bench, "api", return_value={"models": []}) as api:
            with self.assertRaises(ValueError):
                bench.main(self.run_args())
        self.assertEqual(api.call_count, 1)
        self.assertEqual(self.report()["failure_stage"], "local-model-lookup")

    def test_timeout_no_retry_and_private_failure_report(self):
        def api(base, path, payload=None, timeout=120):
            if path == "/api/tags":
                return self.api(base, path)
            raise ValueError("fixture failure, do not persist arbitrary server text")
        with mock.patch.object(bench, "api", side_effect=api) as mocked:
            with self.assertRaises(ValueError):
                bench.main(self.run_args())
        self.assertEqual(mocked.call_count, 2)
        data = self.report()
        self.assertEqual(data["status"], "failed")
        self.assertEqual(data["samples"], [])
        self.assertNotIn("arbitrary", json.dumps(data))

    def test_low_disk_logged_without_network(self):
        with mock.patch.object(bench.shutil, "disk_usage", return_value=mock.Mock(free=1)), mock.patch.object(bench, "api") as api:
            with self.assertRaisesRegex(ValueError, "Speicherplatzmangel"):
                bench.main(self.run_args())
        api.assert_not_called()
        self.assertEqual(self.report()["failure_stage"], "report-disk-check")

    def test_lock_prevents_parallel_client(self):
        lock = self.root / "benchmarks/ollama/operation.lock"
        lock.mkdir(parents=True)
        with mock.patch.object(bench, "api") as api:
            with self.assertRaises(ValueError):
                bench.main(self.run_args())
        api.assert_not_called()
        self.assertTrue(lock.exists())

    def test_offline_analysis_does_not_call_api(self):
        path = Path(self.tmp.name) / "reply.json"
        path.write_text(json.dumps(REPLY), encoding="utf-8")
        with mock.patch.object(bench, "api") as api:
            bench.main(["analyze", str(path)])
        api.assert_not_called()
        self.assertNotIn("PRIVATE_RESPONSE_FIXTURE", self.output.getvalue())

    def test_limits_are_not_silent_infinite_loops(self):
        with redirect_stderr(io.StringIO()):
            with self.assertRaises(SystemExit):
                bench.main(self.run_args("--runs", "11"))

    def test_docs_links_and_registered_hyperfine(self):
        import re
        row, = [x for x in json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"] if x["id"] == "hyperfine"]
        self.assertFalse(row["auto_install"])
        self.assertEqual(row["ports"], [])
        for field in ("install_script", "uninstall_script", "update_script", "doctor_script", "doc"):
            self.assertTrue((ROOT / row[field]).is_file())
        for relative in ("docs/tools/local-ai-benchmarks.md", "docs/benchmarks/RESULT_TEMPLATE.md"):
            doc = ROOT / relative
            text = doc.read_text(encoding="utf-8")
            for target in re.findall(r"\]\(([^)]+)\)", text):
                if "://" not in target:
                    self.assertTrue((doc.parent / target.split("#")[0]).is_file(), target)
            self.assertEqual(text.count("```") % 2, 0)


if __name__ == "__main__":
    unittest.main()
