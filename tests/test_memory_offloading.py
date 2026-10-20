"""Offline source/planner tests: no GPU, drivers, downloads, WSL or model imports."""
from contextlib import redirect_stdout
import importlib.util
import io
import json
import os
from pathlib import Path
import re
import shutil
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


with mock.patch.object(sys, "path", [str(ROOT / "scripts/tools/helpers"), *sys.path]):
    sources = load("offload_sources", "scripts/tools/helpers/offload_sources.py")
planner = load("offload_plan", "scripts/memory/offload_plan.py")


class MemoryPlanner(unittest.TestCase):
    def test_raw_weights_and_no_runtime_guarantee(self):
        result = planner.estimate(70, 4, 64, 16)
        self.assertAlmostEqual(result["raw_weights_gib"], 32.60, places=2)
        self.assertFalse(result["runtime_guaranteed"])
        self.assertEqual(result["assessment"], "offload_may_be_possible")

    def test_shared_pool_is_not_added_twice(self):
        result = planner.estimate(70, 4, 64, 64, mode="unified")
        self.assertEqual(result["weight_budget_gib"], 56)
        self.assertLess(result["weight_budget_gib"], 64)

    def test_gpu_fit_is_only_weight_estimate(self):
        result = planner.estimate(8, 4, 32, 16)
        self.assertEqual(result["assessment"], "weights_may_fit_gpu")
        self.assertFalse(result["runtime_guaranteed"])
        self.assertTrue(any("KV-Cache" in x for x in result["warnings"]))

    def test_insufficient_memory_not_recommended(self):
        self.assertEqual(planner.estimate(120, 4, 16, 16)["assessment"], "weights_exceed_budget")

    def test_cpu_only_default_vram_reserve_is_valid(self):
        self.assertEqual(planner.estimate(8, 4, 16, 0)["weight_budget_gib"], 8)

    def test_invalid_negative_nonfinite_and_overflow(self):
        for args in ((-1, 4, 64, 16), (70, 0, 64, 16), (70, 4, 4, 16),
                     (float("nan"), 4, 64, 16), (70, float("inf"), 64, 16),
                     (1e308, 32, 64, 16)):
            with self.assertRaises(ValueError):
                planner.estimate(*args)

    def test_reserve_and_quantization_overhead_are_explicit(self):
        lean = planner.estimate(32, 4, 64, 16, overhead_percent=0)
        conservative = planner.estimate(32, 4, 64, 16, overhead_percent=30)
        self.assertGreater(conservative["weights_with_assumed_overhead_gib"],
                           lean["weights_with_assumed_overhead_gib"])

    def test_cli_json_is_pure_offline_arithmetic(self):
        with redirect_stdout(io.StringIO()) as output:
            planner.main(["--parameters-b", "70", "--ram-gib", "64", "--vram-gib", "16"])
        self.assertFalse(json.loads(output.getvalue())["runtime_guaranteed"])


class OffloadSources(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        env = mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(Path(self.tmp.name) / "private"))
        env.start()
        self.addCleanup(env.stop)
        self.output = io.StringIO()
        redirect = redirect_stdout(self.output)
        redirect.__enter__()
        self.addCleanup(redirect.__exit__, None, None, None)

    def fixture(self, key):
        base, source, marker = sources.paths(key)
        spec = sources.TOOLS[key]
        for name in ("LICENSE", "setup.py", spec["module"]):
            path = source / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("fixture", encoding="utf-8")
        return base, source, marker, spec

    def install(self, key):
        base, source, marker, spec = self.fixture(key)
        git = lambda location, *args: spec["pin"] if args == ("rev-parse", "HEAD") else spec["url"] if args == ("remote", "get-url", "origin") else ""
        with mock.patch.object(sources, "git", side_effect=git), mock.patch.object(sources, "resources"):
            self.assertEqual(sources.main([key, "install"]), 0)
        return base, source, marker, spec

    def test_both_plans_are_read_only(self):
        for key in sources.TOOLS:
            self.assertEqual(sources.main([key, "--dry-run"]), 0)
            self.assertFalse(sources.paths(key)[0].exists())

    def test_real_marker_only_after_source_preparation(self):
        for key in sources.TOOLS:
            _, _, marker, spec = self.install(key)
            record = json.loads(marker.read_text())
            self.assertEqual(record["commit"], spec["pin"])
            self.assertFalse(record["runtime_ready"])

    def test_update_idempotent_no_runtime_installation(self):
        for key in sources.TOOLS:
            _, _, marker, _ = self.install(key)
            before = marker.read_bytes()
            with mock.patch.object(sources, "verify"), mock.patch.object(sources, "resources"):
                self.assertEqual(sources.main([key, "update"]), 0)
            self.assertEqual(before, marker.read_bytes())

    def test_low_disk_has_new_log_and_no_marker(self):
        key = "hf_accelerate"
        base, _, marker = sources.paths(key)
        with mock.patch.object(sources, "resources", side_effect=ValueError("Speicherplatzmangel")), mock.patch.object(sources, "fetch") as fetch:
            with self.assertRaises(ValueError):
                sources.main([key, "install"])
        fetch.assert_not_called()
        self.assertFalse(marker.exists())
        logs = list((base.parent.parent / "install_logs").glob("hf_accelerate_install_*.log"))
        self.assertEqual(len(logs), 1)
        self.assertIn("Speicherplatzmangel", logs[0].read_text(encoding="utf-8"))

    def test_foreign_source_is_not_reset(self):
        base, source, marker, _ = self.fixture("deepspeed")
        with mock.patch.object(sources, "git", return_value="foreign"), mock.patch.object(sources, "resources"):
            with self.assertRaises(ValueError):
                sources.main(["deepspeed", "install"])
        self.assertFalse(marker.exists())
        self.assertTrue((source / "setup.py").exists())

    def test_deactivation_preserves_sources_and_runtime(self):
        for key in sources.TOOLS:
            _, source, marker, _ = self.install(key)
            self.assertEqual(sources.main([key, "uninstall"]), 0)
            self.assertFalse(marker.exists())
            self.assertTrue(source.is_dir())

    def test_lock_blocks_operation(self):
        base, _, _ = sources.paths("deepspeed")
        base.mkdir(parents=True)
        (base / "operation.lock").mkdir()
        with self.assertRaises(FileExistsError), mock.patch.object(sources, "fetch") as fetch:
            sources.main(["deepspeed", "install"])
        fetch.assert_not_called()

    def test_failed_marker_write_does_not_register_installed(self):
        base, _, marker, spec = self.fixture("hf_accelerate")
        with mock.patch.object(sources, "resources"), mock.patch.object(sources, "verify"), mock.patch.object(sources.json, "dump", side_effect=OSError("disk full")):
            with self.assertRaises(OSError):
                sources.main(["hf_accelerate", "install"])
        self.assertFalse(marker.exists())
        self.assertFalse(list(base.glob("status-*")))

    def test_pins_and_no_source_execution(self):
        for key, spec in sources.TOOLS.items():
            base, source, _ = sources.paths(key)
            base.mkdir(parents=True)
            with mock.patch.object(sources, "verify"), mock.patch.object(sources, "git") as git:
                sources.fetch(base, source, spec)
            commands = [c.args[1:] for c in git.call_args_list]
            self.assertIn(("fetch", "--depth=1", "origin", spec["pin"]), commands)
            self.assertFalse(any("pip" in c or "setup.py" in c for c in commands))

    def test_registry_and_doc_links(self):
        tools = json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"]
        for key, spec in sources.TOOLS.items():
            row, = [t for t in tools if t["id"] == key]
            self.assertEqual(row["source_commit"], spec["pin"])
            self.assertFalse(row["auto_install"])
            self.assertEqual(row["ports"], [])
            for field in ("install_script", "uninstall_script", "update_script", "doctor_script", "doc"):
                self.assertTrue((ROOT / row[field]).is_file())
        doc = ROOT / "docs/memory/UNIFIED_MEMORY_AND_OFFLOADING.md"
        text = doc.read_text(encoding="utf-8")
        for target in re.findall(r"\]\(([^)]+)\)", text):
            if "://" not in target:
                self.assertTrue((doc.parent / target.split("#")[0]).is_file(), target)
        self.assertIn("runtime_ready=false", text)
        self.assertIn("nicht in echte UMA", text)
        self.assertIn("WSL2", text)
        self.assertEqual(text.count("```") % 2, 0)


if __name__ == "__main__":
    unittest.main()
