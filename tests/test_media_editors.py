"""Offline media installer tests; no real download, package build, GUI or WSL."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
HELPERS = ROOT / "scripts/tools/helpers"
sys.path.insert(0, str(HELPERS))
try:
    spec = importlib.util.spec_from_file_location("media_editors", HELPERS / "media_editors.py")
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
finally:
    sys.path.pop(0)


def fake_fetch(stage, spec):
    (stage / spec["license_file"]).write_text("synthetic-license", encoding="utf-8")


def fake_build(args, cwd, timeout=1800):
    if "install" in args:
        return
    if "--check" not in args:
        key = "remotion" if "--filter=@remotion/cli..." in args else "hyperframes"
        for name in m.SPECS[key]["artifacts"]:
            file = cwd / name
            file.parent.mkdir(parents=True, exist_ok=True)
            file.write_text("synthetic-build", encoding="utf-8")


class MediaEditorsTests(unittest.TestCase):
    def test_all_plans_are_read_only_and_do_not_require_bun(self):
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": tmp}), \
                patch.object(m, "download", side_effect=AssertionError("download")), \
                patch.object(m, "fetch", side_effect=AssertionError("fetch")), \
                patch.object(m, "run", side_effect=AssertionError("execute")), \
                contextlib.redirect_stdout(io.StringIO()):
            for key in m.SPECS:
                self.assertEqual(m.main([key, "install", "--dry-run"]), 0)
            self.assertEqual(list(Path(tmp).iterdir()), [])

    def test_concat_release_not_executed_and_hash_download_contract(self):
        with tempfile.TemporaryDirectory() as tmp, contextlib.redirect_stdout(io.StringIO()), \
                patch.object(m, "reserve"), patch.object(m.platform, "system", return_value="Linux"), \
                patch.object(m.platform, "machine", return_value="x86_64"), \
                patch.object(m, "run", side_effect=AssertionError("GUI")):
            base = Path(tmp)
            def download(url, target, size, sha):
                self.assertIn("/v0.2.8/", url)
                self.assertEqual(size, 137947640)
                self.assertEqual(len(sha), 64)
                target.write_bytes(b"synthetic-appimage")
            with patch.object(m, "download", side_effect=download):
                m.install("concat", base, base / "runtime", base / "build-ready.json", m.SPECS["concat"])
            record = m.validate(base / "runtime", base / "build-ready.json", m.SPECS["concat"], full=True)
            self.assertTrue(record["build_ready"])
            self.assertFalse(record["runtime_ready"])

    def test_failed_download_leaves_no_marker_and_preserves_user_file(self):
        with tempfile.TemporaryDirectory() as tmp, contextlib.redirect_stdout(io.StringIO()), \
                patch.object(m, "reserve"), patch.object(m.platform, "system", return_value="Linux"), \
                patch.object(m.platform, "machine", return_value="x86_64"), \
                patch.object(m, "download", side_effect=ValueError("SHA256 mismatch")):
            base = Path(tmp)
            (base / "keep.txt").write_text("keep")
            with self.assertRaisesRegex(ValueError, "SHA256"):
                m.install("concat", base, base / "runtime", base / "build-ready.json", m.SPECS["concat"])
            self.assertEqual(list(base.iterdir()), [base / "keep.txt"])

    def test_two_source_builds_use_frozen_lock_and_expected_artifacts(self):
        for key in ("remotion", "hyperframes"):
            with self.subTest(key=key), tempfile.TemporaryDirectory() as tmp, \
                    contextlib.redirect_stdout(io.StringIO()), patch.object(m, "reserve"), \
                    patch.object(m.platform, "system", return_value="Linux"), \
                    patch.object(m, "runtimes", return_value=("node", "bun")), \
                    patch.object(m, "fetch", side_effect=fake_fetch), \
                    patch.object(m, "run", side_effect=fake_build) as run:
                base = Path(tmp)
                m.install(key, base, base / "runtime", base / "build-ready.json", m.SPECS[key], accepted=True)
                record = m.validate(base / "runtime", base / "build-ready.json", m.SPECS[key], full=True)
                self.assertFalse(record["runtime_ready"])
                commands = [call.args[0] for call in run.call_args_list]
                self.assertIn(["bun", "install", "--frozen-lockfile", "--ignore-scripts"], commands)
                self.assertTrue(any("--check" in cmd for cmd in commands))
                if key == "remotion":
                    self.assertTrue(any("--concurrency=1" in cmd for cmd in commands))
                else:
                    self.assertEqual(sum("--cwd" in cmd for cmd in commands), len(m.SPECS[key]["packages"]))

    def test_remotion_decline_prints_license_before_any_package_action(self):
        with tempfile.TemporaryDirectory() as tmp, contextlib.redirect_stdout(io.StringIO()) as out, \
                patch.object(m, "reserve"), patch.object(m.platform, "system", return_value="Linux"), \
                patch.object(m, "runtimes", return_value=("node", "bun")), \
                patch.object(m, "fetch", side_effect=fake_fetch), \
                patch.object(m.sys.stdin, "isatty", return_value=False), patch.object(m, "run") as run:
            base = Path(tmp)
            with self.assertRaisesRegex(ValueError, "nicht akzeptiert"):
                m.install("remotion", base, base / "runtime", base / "build-ready.json", m.SPECS["remotion"])
            run.assert_not_called()
            self.assertIn("synthetic-license", out.getvalue())
            self.assertEqual(list(base.iterdir()), [])

    def test_build_failure_rolls_back_without_hiding_current_log(self):
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": tmp}), \
                contextlib.redirect_stdout(io.StringIO()), patch.object(m, "reserve"), \
                patch.object(m.platform, "system", return_value="Linux"), \
                patch.object(m, "runtimes", return_value=("node", "bun")), \
                patch.object(m, "fetch", side_effect=fake_fetch), \
                patch.object(m, "run", side_effect=OSError("No space left on device")):
            with self.assertRaises(OSError):
                m.main(["hyperframes", "install"])
            base, runtime, marker = m.paths("hyperframes")
            self.assertFalse(runtime.exists())
            self.assertFalse(marker.exists())
            self.assertFalse((base.parent / "media-build.lock").exists())
            log = next((Path(tmp) / "install_logs").glob("hyperframes_install_*.log"))
            text = log.read_text(encoding="utf-8")
            self.assertIn("No space left", text)
            self.assertIn("Rollback", text)

    def test_reserve_failure_happens_before_download_and_is_logged(self):
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": tmp}), \
                contextlib.redirect_stdout(io.StringIO()), \
                patch.object(m.platform, "system", return_value="Linux"), \
                patch.object(m, "reserve", side_effect=ValueError("Speicherplatzmangel")), \
                patch.object(m, "download") as download:
            with self.assertRaisesRegex(ValueError, "Speicherplatzmangel"):
                m.main(["concat", "install"])
            download.assert_not_called()
            log = next((Path(tmp) / "install_logs").glob("concat_install_*.log"))
            self.assertIn("Speicherplatzmangel", log.read_text(encoding="utf-8"))

    def test_marker_alone_never_counts_as_installed(self):
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": tmp}), \
                contextlib.redirect_stdout(io.StringIO()) as out:
            base, runtime, marker = m.paths("concat")
            base.mkdir(parents=True)
            marker.write_text('{"build_ready":true}')
            self.assertEqual(m.main(["concat", "check"]), 1)
            self.assertFalse(json.loads(out.getvalue())["installed"])

    def test_unmanaged_runtime_is_never_overwritten(self):
        with tempfile.TemporaryDirectory() as tmp:
            base = Path(tmp)
            (base / "runtime").mkdir()
            with self.assertRaisesRegex(ValueError, "Besitznachweis"):
                m.install("concat", base, base / "runtime", base / "marker", m.SPECS["concat"])

    def test_edited_or_extra_files_block_deletion(self):
        with tempfile.TemporaryDirectory() as tmp, contextlib.redirect_stdout(io.StringIO()), \
                patch.object(m, "reserve"), patch.object(m.platform, "system", return_value="Linux"), \
                patch.object(m.platform, "machine", return_value="x86_64"), \
                patch.object(m, "download", side_effect=lambda url, p, size, sha: p.write_bytes(b"original")):
            base = Path(tmp)
            runtime, marker = base / "runtime", base / "build-ready.json"
            m.install("concat", base, runtime, marker, m.SPECS["concat"])
            (runtime / "my-video.mp4").write_text("preserve")
            with self.assertRaisesRegex(ValueError, "Zusatzdateien"):
                m.validate(runtime, marker, m.SPECS["concat"], full=True)
            self.assertTrue((runtime / "my-video.mp4").exists())

    def test_build_lock_rejects_parallel_invocation_and_is_not_removed(self):
        with tempfile.TemporaryDirectory() as tmp:
            base = Path(tmp) / "concat"
            base.mkdir()
            with m.build_lock(base):
                with self.assertRaisesRegex(ValueError, "bereits"):
                    with m.build_lock(base):
                        self.fail("parallel")
                self.assertTrue((base.parent / "media-build.lock").exists())
            self.assertFalse((base.parent / "media-build.lock").exists())

    def test_build_env_does_not_inherit_provider_credentials(self):
        with tempfile.TemporaryDirectory() as tmp, \
                patch.dict(os.environ, {"OPENAI_API_KEY": "synthetic-not-a-key", "AWS_SECRET_ACCESS_KEY": "fixture"}), \
                patch.object(m.subprocess, "run") as run, contextlib.redirect_stdout(io.StringIO()):
            m.run(["bun", "install"], Path(tmp))
            env = run.call_args.kwargs["env"]
            self.assertNotIn("OPENAI_API_KEY", env)
            self.assertNotIn("AWS_SECRET_ACCESS_KEY", env)
            self.assertEqual(env["HOME"], str(Path(tmp) / ".installer-home"))

    def test_unsafe_inventory_path_and_symlink_escape_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            runtime = Path(tmp) / "runtime"
            runtime.mkdir()
            for name in ("../outside", "/etc/passwd", "C:/outside", "bad\\path"):
                with self.assertRaises(ValueError):
                    m.safe_entry(runtime, name)

    def test_menu_registry_wrappers_and_documentation(self):
        import re
        registry = json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"]
        setup = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        native = (ROOT / "scripts/helpers/native_tool_status.sh").read_text(encoding="utf-8")
        for key, spec in m.SPECS.items():
            entries = [t for t in registry if t["id"] == key]
            self.assertEqual(len(entries), 1)
            self.assertEqual(entries[0]["version"], spec["version"])
            self.assertEqual(entries[0]["ports"], [])
            self.assertIn('TOOL_SCRIPT_NAMES["' + spec["name"] + '"]="' + key + '"', setup)
            self.assertIn(spec["name"] + ") marker=" + key + "/build-ready.json", native)
            for action in ("install", "update", "uninstall", "status", "check", "doctor"):
                wrapper = (ROOT / ("scripts/tools/" + key + "_" + action + ".sh")).read_text(encoding="utf-8")
                self.assertIn('media_editors.py" ' + key + " " + action, wrapper)
                if action == "install":
                    self.assertIn("github.com/" + spec["repo"], wrapper)
            doc = ROOT / entries[0]["doc"]
            text = doc.read_text(encoding="utf-8")
            self.assertIn("runtime_ready=false", text)
            for link in re.findall(r"\]\(([^)]+)\)", text):
                if not link.startswith(("https://", "http://", "#")):
                    self.assertTrue((doc.parent / link).is_file(), link)


if __name__ == "__main__":
    unittest.main()
