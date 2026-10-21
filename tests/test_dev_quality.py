"""Offline fixtures only: no Git, package installation, WSL or project execution."""
from contextlib import redirect_stdout
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
with mock.patch.object(sys, "path", [str(ROOT / "scripts/tools/helpers"), *sys.path]):
    spec = importlib.util.spec_from_file_location("dev_quality", ROOT / "scripts/tools/helpers/dev_quality.py")
    dev = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(dev)


class DevQuality(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.root = Path(tmp.name) / "private"
        self.output = io.StringIO()
        capture = redirect_stdout(self.output)
        capture.__enter__()
        self.addCleanup(capture.__exit__, None, None, None)
        patch = mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(self.root),
                                ANTHROPIC_API_KEY="DO_NOT_INHERIT", PYTHONPATH="DO_NOT_INHERIT",
                                PIP_EXTRA_INDEX_URL="https://user:DO_NOT_INHERIT@invalid.test")
        patch.start()
        self.addCleanup(patch.stop)
        self.commands = []

    def fetch(self, base, source, spec):
        for name in spec["files"]:
            path = source / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("fixture source", encoding="utf-8")

    def process(self, command, cwd, env, timeout=1800, capture=False):
        self.commands.append(command)
        for key in ("ANTHROPIC_API_KEY", "PYTHONPATH", "PIP_EXTRA_INDEX_URL"):
            self.assertNotIn(key, env)
        self.assertEqual(env["PIP_CONFIG_FILE"], os.devnull)
        self.assertEqual(env["MYPY_USE_MYPYC"], "0")
        if "venv" in command:
            python = dev.python_in(Path(command[-1]))
            python.parent.mkdir(parents=True, exist_ok=True)
            python.write_bytes(b"fake python; never executed")
        if "install" in command:
            self.assertIn("--only-binary=:all:", command)
            self.assertTrue(any(Path(command[-1], name).is_file() for name in ("LICENSE", "LICENSE.md")))
        return subprocess.CompletedProcess(command, 0, "")

    def invoke(self, tool="black", action="install", *args):
        with mock.patch.object(dev, "fetch", side_effect=self.fetch), mock.patch.object(dev, "verify"), \
                mock.patch.object(dev, "budget"), mock.patch.object(dev, "run", side_effect=self.process):
            return dev.main([tool, action, *args])

    def test_dry_run_is_write_free(self):
        for tool in dev.TOOLS:
            for action in ("install", "update", "repair", "uninstall"):
                self.assertEqual(self.invoke(tool, action, "--dry-run"), 0)
        self.assertEqual(self.commands, [])
        self.assertFalse(self.root.exists())

    def test_status_and_doctor_never_write_download_or_execute(self):
        for tool in dev.TOOLS:
            self.assertEqual(self.invoke(tool, "status"), 0)
            self.assertEqual(self.invoke(tool, "doctor"), 1)
        self.assertEqual(self.commands, [])
        self.assertFalse(self.root.exists())

    def test_install_both_pinned_packages_publishes_only_after_checks(self):
        for tool in dev.TOOLS:
            self.assertEqual(self.invoke(tool), 0)
            base, source, marker = dev.paths(tool)
            data = json.loads(marker.read_text())
            self.assertEqual(data["commit"], dev.TOOLS[tool]["pin"])
            self.assertFalse(data["project_tested"])
            self.assertTrue(dev.python_in(dev.record_ok(base, marker, dev.TOOLS[tool])).is_file())
            self.assertEqual((source / dev.TOOLS[tool]["files"][0]).read_text(), "fixture source")
            self.assertEqual(list(base.glob("build-source-*")), [])
            self.assertEqual(list(base.glob("marker-*")), [])
            self.assertFalse((base / "operation.lock").exists())
        self.assertTrue(any("check" in cmd for cmd in self.commands))
        self.assertTrue(any("freeze" in cmd for cmd in self.commands))
        self.assertNotIn("DO_NOT_INHERIT", self.output.getvalue())

    def test_update_is_idempotent_and_does_not_run_packages(self):
        self.invoke()
        base, _, marker = dev.paths("black")
        before = marker.read_bytes()
        self.commands.clear()
        self.assertEqual(self.invoke("black", "update"), 0)
        self.assertEqual(self.commands, [])
        self.assertEqual(marker.read_bytes(), before)
        self.assertEqual(len(list(base.glob("env-*"))), 1)

    def test_modified_environment_blocks_repair_and_uninstall(self):
        self.invoke()
        base, _, marker = dev.paths("black")
        env = dev.record_ok(base, marker, dev.TOOLS["black"])
        personal = env / "personal.txt"
        personal.write_text("preserve")
        for action in ("repair", "uninstall"):
            with self.assertRaisesRegex(ValueError, "veraendert"):
                self.invoke("black", action)
        self.assertEqual(personal.read_text(), "preserve")
        self.assertTrue(marker.exists())
        self.assertEqual(self.invoke("black", "doctor"), 1)

    def test_personal_empty_directory_blocks_uninstall_too(self):
        self.invoke()
        base, _, marker = dev.paths("black")
        environment = dev.record_ok(base, marker, dev.TOOLS["black"])
        (environment / "personal-directory").mkdir()
        with self.assertRaisesRegex(ValueError, "veraendert"):
            self.invoke("black", "uninstall")
        self.assertTrue(marker.exists())

    def test_shared_verifier_accepts_each_source_spec(self):
        for tool, spec in dev.TOOLS.items():
            base, source, _ = dev.paths(tool)
            self.fetch(base, source, spec)
            with mock.patch.dict(dev.verify.__globals__, git=mock.Mock(side_effect=[spec["pin"], spec["url"], ""])):
                dev.verify(source, spec)
            (source / spec["module"]).unlink()
            with mock.patch.dict(dev.verify.__globals__, git=mock.Mock(side_effect=[spec["pin"], spec["url"], ""])):
                with self.assertRaisesRegex(ValueError, "unvollstaendig"):
                    dev.verify(source, spec)

    def test_uninstall_removes_only_owned_environment_not_sources_or_foreign_files(self):
        self.invoke()
        base, source, marker = dev.paths("black")
        foreign = base / "my-own-data"
        foreign.write_text("preserve")
        self.commands.clear()
        self.assertEqual(self.invoke("black", "uninstall"), 0)
        self.assertEqual(self.commands, [])
        self.assertFalse(marker.exists())
        self.assertEqual(list(base.glob("env-*")), [])
        self.assertTrue(source.is_dir())
        self.assertEqual(foreign.read_text(), "preserve")

    def test_failed_new_build_rolls_back_and_logs_current_failure(self):
        original = self.process

        def failing(command, *args, **kwargs):
            if "install" in command:
                raise ValueError("synthetic build failure")
            return original(command, *args, **kwargs)

        self.process = failing
        with self.assertRaisesRegex(ValueError, "synthetic build failure"):
            self.invoke()
        base, source, marker = dev.paths("black")
        self.assertFalse(marker.exists())
        self.assertEqual(list(base.glob("env-*")), [])
        self.assertEqual(list(base.glob("build-source-*")), [])
        self.assertTrue(source.is_dir())
        log, = (self.root / "install_logs").glob("black_install_*.log")
        self.assertIn("synthetic build failure", log.read_text())
        self.assertIn("Rollback", log.read_text())

    def test_failed_marker_write_rolls_back_new_environment(self):
        with mock.patch.object(dev.os, "replace", side_effect=OSError("synthetic marker failure")), self.assertRaises(OSError):
            self.invoke()
        base, _, marker = dev.paths("black")
        self.assertFalse(marker.exists())
        self.assertEqual(list(base.glob("env-*")), [])
        self.assertEqual(list(base.glob("marker-*")), [])

    def test_missing_ensurepip_stops_before_fetch(self):
        with mock.patch.object(dev, "run", side_effect=ValueError("missing ensurepip")), \
                mock.patch.object(dev, "fetch") as fetch, mock.patch.object(dev, "budget"), self.assertRaises(ValueError):
            dev.main(["black"])
        fetch.assert_not_called()
        self.assertFalse(dev.paths("black")[2].exists())

    def test_disk_failure_stops_before_fetch(self):
        with mock.patch.object(dev, "resources"), mock.patch.object(dev.shutil, "disk_usage", return_value=mock.Mock(free=1)), \
                mock.patch.object(dev, "fetch") as fetch, self.assertRaisesRegex(ValueError, "Speicherplatzmangel"):
            dev.main(["mypy"])
        fetch.assert_not_called()

    def test_lock_prevents_new_build(self):
        base, _, _ = dev.paths("black")
        (base / "operation.lock").mkdir(parents=True)
        with self.assertRaises(FileExistsError):
            self.invoke()
        self.assertEqual(self.commands, [])
        self.assertTrue((base / "operation.lock").is_dir())

    def test_unowned_or_path_traversal_marker_is_refused(self):
        self.invoke()
        base, _, marker = dev.paths("black")
        data = json.loads(marker.read_text())
        data["environment"] = "../foreign"
        marker.write_text(json.dumps(data))
        with self.assertRaisesRegex(ValueError, "Besitznachweis"):
            self.invoke("black", "uninstall")
        self.assertTrue(marker.exists())
        self.assertEqual(len(list(base.glob("env-*"))), 1)

    def test_unknown_environment_without_marker_is_preserved(self):
        base, _, _ = dev.paths("black")
        (base / "env-foreign").mkdir(parents=True)
        self.invoke("black", "uninstall")
        self.assertTrue((base / "env-foreign").is_dir())

    def test_run_wrapper_never_leaks_raw_subprocess_exception(self):
        with mock.patch.object(dev.subprocess, "run", side_effect=OSError("secret")), self.assertRaises(ValueError) as caught:
            dev.run(["fake"], self.root, {}, capture=True)
        self.assertNotIn("secret", str(caught.exception))

    def test_invalid_arguments_and_workspace_are_rejected(self):
        with mock.patch.object(sys, "stderr", io.StringIO()), self.assertRaises(SystemExit):
            dev.main(["black", "update", "--uninstall"])
        with mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR="relative"), self.assertRaises(ValueError):
            dev.paths("black")

    def test_registry_menu_wrappers_and_documentation_agree(self):
        registry = json.loads((ROOT / "config/tools.yml").read_text())
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        native = (ROOT / "scripts/helpers/native_tool_status.sh").read_text()
        for tool, spec in dev.TOOLS.items():
            row, = [r for r in registry["tools"] if r["id"] == tool]
            self.assertEqual(row["source_commit"], spec["pin"])
            self.assertFalse(row["auto_install"])
            self.assertEqual(row["ports"], [])
            self.assertIn(f'TOOL_SCRIPT_NAMES["{spec["name"]}"]="{tool}"', menu)
            self.assertIn(f'{spec["name"]}) marker={tool}/build-ready.json', native)
            for action in ("install", "update", "uninstall", "doctor", "status"):
                path = ROOT / f"scripts/tools/{tool}_{action}.sh"
                self.assertIn(f'dev_quality.py" {tool} {action}', path.read_text())
        tutorial = (ROOT / "docs/tutorials/manus-development-workflow.md").read_text()
        for phrase in ("Automaton", "127.0.0.1", "Maximal drei", "kein unabhaengiger Nachweis", "PyPI"):
            self.assertIn(phrase, tutorial)


if __name__ == "__main__":
    unittest.main()
