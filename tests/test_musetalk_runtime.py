"""Offline MuseTalk lifecycle fixtures; never install packages or invoke a GPU."""
from contextlib import redirect_stdout
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
sys.path.insert(0, str(ROOT / "scripts/tools/helpers"))
import musetalk_runtime as tool


class MuseTalkTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.env = patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": self.temp.name})
        self.env.start()
        self.addCleanup(self.env.stop)
        self.base, self.checkout, self.source_marker, self.dependencies, self.marker = tool.locations()

    def seed_source(self):
        self.base.mkdir(parents=True, exist_ok=True)
        self.checkout.mkdir(exist_ok=True)
        (self.checkout / "README.md").write_text("source fixture")
        self.source_marker.write_text("source marker fixture")

    def fake_build(self, checkout, dependencies):
        (dependencies / ".venv/bin").mkdir(parents=True)
        (dependencies / ".venv/bin/python").write_text("fake executable")
        (dependencies / ".venv/pyvenv.cfg").write_text("fake config")
        (dependencies / "resolved-requirements.txt").write_text("fixture==1\n")
        (dependencies / "constraints.txt").write_text("fixture==1\n")

    def installed(self):
        self.seed_source()
        with patch.object(tool.source, "validate"), patch.object(tool.source, "install"), patch.object(tool, "preflight"), patch.object(tool.source, "reserve"), patch.object(tool, "build", side_effect=self.fake_build), redirect_stdout(io.StringIO()):
            tool.install(self.base, self.checkout, self.source_marker, self.dependencies, self.marker)

    def test_plan_never_creates_directories_or_runs_commands(self):
        with patch.object(tool.source, "run") as run, patch.object(tool, "preflight") as preflight, redirect_stdout(io.StringIO()) as out:
            self.assertEqual(tool.main(["install", "--dry-run"]), 0)
        run.assert_not_called()
        preflight.assert_not_called()
        self.assertEqual(list(Path(self.temp.name).iterdir()), [])
        self.assertIn('"reserve_mb": 20480', out.getvalue())
        self.assertIn('"blackwell_supported": false', out.getvalue())

    def test_source_marker_is_not_runtime_success(self):
        self.seed_source()
        with patch.object(tool.source, "validate"), redirect_stdout(io.StringIO()) as out:
            self.assertEqual(tool.main(["status"]), 0)
        result = json.loads(out.getvalue())
        self.assertTrue(result["sources_present"])
        self.assertFalse(result["installed"])
        self.assertFalse(result["runtime_tested"])

    def test_source_upgrade_and_idempotence(self):
        self.installed()
        with patch.object(tool.source, "validate"), patch.object(tool, "preflight") as preflight, patch.object(tool, "build") as build, redirect_stdout(io.StringIO()):
            tool.install(self.base, self.checkout, self.source_marker, self.dependencies, self.marker)
        preflight.assert_not_called()
        build.assert_not_called()
        self.assertEqual(self.source_marker.read_text(), "source marker fixture")
        record = json.loads(self.marker.read_text())
        self.assertEqual(record["scope"], "dependencies")
        self.assertFalse(record["runtime_tested"])
        self.assertFalse(record["models_downloaded"])

    def test_failed_build_preserves_existing_sources_and_models(self):
        self.seed_source()
        models = self.base / "models"
        models.mkdir()
        (models / "owned.bin").write_text("keep")
        def fail(*args):
            (self.dependencies / "partial").write_text("partial")
            raise OSError("No space left on device")
        with patch.object(tool.source, "validate"), patch.object(tool.source, "install"), patch.object(tool, "preflight"), patch.object(tool.source, "reserve"), patch.object(tool, "build", side_effect=fail), redirect_stdout(io.StringIO()):
            with self.assertRaises(OSError):
                tool.install(self.base, self.checkout, self.source_marker, self.dependencies, self.marker)
        self.assertFalse(self.dependencies.exists())
        self.assertFalse(self.marker.exists())
        self.assertTrue(self.source_marker.exists())
        self.assertEqual((models / "owned.bin").read_text(), "keep")

    def test_failed_first_install_removes_only_new_checkout(self):
        self.base.mkdir(parents=True)
        with patch.object(tool.source, "validate"), patch.object(tool.source, "install", side_effect=lambda *args: self.seed_source()), patch.object(tool, "preflight"), patch.object(tool.source, "reserve"), patch.object(tool, "build", side_effect=ValueError("failure")), redirect_stdout(io.StringIO()):
            with self.assertRaises(ValueError):
                tool.install(self.base, self.checkout, self.source_marker, self.dependencies, self.marker)
        self.assertFalse(self.checkout.exists())
        self.assertFalse(self.source_marker.exists())
        self.assertFalse(self.dependencies.exists())

    def test_unmanaged_dependencies_are_never_overwritten(self):
        self.dependencies.mkdir(parents=True)
        keep = self.dependencies / "keep"
        keep.write_text("keep")
        with self.assertRaisesRegex(ValueError, "ohne Runtime-Nachweis"):
            tool.install(self.base, self.checkout, self.source_marker, self.dependencies, self.marker)
        self.assertEqual(keep.read_text(), "keep")

    def test_marker_write_failure_never_publishes_success(self):
        self.seed_source()
        with patch.object(tool.source, "validate"), patch.object(tool.source, "install"), patch.object(tool, "preflight"), patch.object(tool.source, "reserve"), patch.object(tool, "build", side_effect=self.fake_build), patch.object(tool.os, "replace", side_effect=OSError("ENOSPC marker")), redirect_stdout(io.StringIO()):
            with self.assertRaises(OSError):
                tool.install(self.base, self.checkout, self.source_marker, self.dependencies, self.marker)
        self.assertFalse(self.marker.exists())
        self.assertFalse(self.dependencies.exists())
        self.assertEqual(list(self.base.glob("runtime-ready-pending-*")), [])

    def test_modified_environment_blocks_uninstall_before_source_removal(self):
        self.installed()
        (self.dependencies / "user.txt").write_text("keep")
        with patch.object(tool.source, "validate"), redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "veraendert"):
                tool.main(["uninstall"])
        self.assertTrue(self.source_marker.exists())
        self.assertTrue(self.dependencies.exists())

    def test_uninstall_preserves_models_outside_owned_environment(self):
        self.installed()
        keep = self.base / "my-model.bin"
        keep.write_text("keep")
        with patch.object(tool.source, "validate"), redirect_stdout(io.StringIO()):
            self.assertEqual(tool.main(["uninstall"]), 0)
            self.assertEqual(tool.main(["uninstall"]), 0)
        self.assertFalse(self.marker.exists())
        self.assertFalse(self.checkout.exists())
        self.assertEqual(keep.read_text(), "keep")

    def test_blackwell_preflight_rejects_without_download(self):
        self.base.mkdir(parents=True)
        with patch.object(tool.platform, "system", return_value="Linux"), patch.object(tool.platform, "machine", return_value="x86_64"), patch.object(tool.source, "reserve"), patch.object(tool.source, "executable", side_effect=lambda name: name), patch.object(tool.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, "12.0\n", "")), patch.object(tool.source, "run") as run:
            with self.assertRaisesRegex(ValueError, "Blackwell"):
                tool.preflight(self.base)
        run.assert_not_called()

    def test_low_disk_failure_is_logged_before_fetch_or_build(self):
        with patch.object(tool.platform, "system", return_value="Linux"), patch.object(tool.platform, "machine", return_value="x86_64"), patch.object(tool.source, "reserve", side_effect=ValueError("Windows-Host-Speicherplatzmangel fixture")), patch.object(tool.source, "install") as install, patch.object(tool, "build") as build, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Speicherplatzmangel"):
                tool.main(["install"])
        install.assert_not_called()
        build.assert_not_called()
        logs = list((Path(self.temp.name) / "install_logs").glob("*.log"))
        self.assertEqual(len(logs), 1)
        self.assertIn("Speicherplatzmangel fixture", logs[0].read_text())
        self.assertFalse(self.dependencies.exists())

    def test_missing_python_noninteractive_requires_approval(self):
        with patch.dict(os.environ, {"MUSETALK_PYTHON_BIN": "", "MUSETALK_INSTALL_PYTHON": "ask"}), patch.object(tool.shutil, "which", return_value=None), patch.object(tool.sys.stdin, "isatty", return_value=False), patch.object(tool.source, "run") as run, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "nicht freigegeben"):
                tool.python310(self.dependencies, {})
        run.assert_not_called()

    def test_build_installs_dependencies_without_models_or_entrypoint(self):
        self.seed_source()
        self.dependencies.mkdir()
        def capture(args, cwd, env):
            return "fixture==1" if "freeze" in args else ""
        with patch.object(tool, "python310", return_value="python3.10"), patch.object(tool.source, "executable", return_value="uv"), patch.object(tool.source, "run", side_effect=capture) as run:
            tool.build(self.checkout, self.dependencies)
        commands = [list(map(str, call.args[0])) for call in run.call_args_list]
        joined = "\n".join(" ".join(command) for command in commands)
        for expected in ("torch==2.0.1", "mmcv==2.0.1", "--only-binary mmcv", "pip check", "pip freeze"):
            self.assertIn(expected, joined)
        for forbidden in ("download_weights", "app.py", "scripts.inference", "huggingface-cli", "docker"):
            self.assertNotIn(forbidden, joined)
        self.assertEqual(run.call_args_list[-1].args[2]["HF_HUB_OFFLINE"], "1")
        self.assertNotIn("OPENAI_API_KEY", run.call_args_list[-1].args[2])

    def test_gap_entrypoint_dispatches_runtime_and_keeps_source_opt_in(self):
        with patch.object(tool, "main", return_value=0) as main:
            self.assertEqual(tool.source.main(["musetalk", "install", "--dry-run"]), 0)
        main.assert_called_once_with(["install", "--dry-run"])

    def test_source_only_uninstall_cannot_orphan_python_environment(self):
        self.installed()
        with self.assertRaisesRegex(ValueError, "verwaiste"):
            tool.source.main(["musetalk", "uninstall", "--source-only"])
        self.assertTrue(self.dependencies.exists())
        self.assertTrue(self.checkout.exists())


if __name__ == "__main__":
    unittest.main()
