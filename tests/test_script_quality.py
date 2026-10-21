"""Offline lifecycle fixtures; no downloads, shell runtime or project execution."""
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
    spec = importlib.util.spec_from_file_location("script_quality", ROOT / "scripts/tools/helpers/script_quality.py")
    scripts = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(scripts)


class ScriptQualityTests(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name) / "private"
        self.output = io.StringIO()
        capture = redirect_stdout(self.output)
        capture.__enter__()
        self.addCleanup(capture.__exit__, None, None, None)
        patch = mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(self.root))
        patch.start()
        self.addCleanup(patch.stop)

    def fetch(self, base, source, spec):
        for name in spec["files"]:
            path = source / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("fixture", encoding="utf-8")

    def invoke(self, tool="bats_core", action="install", *args):
        with mock.patch.object(scripts, "fetch", side_effect=self.fetch), \
                mock.patch.object(scripts, "verify"), mock.patch.object(scripts, "resources"), \
                mock.patch.object(scripts, "runtime", return_value="fake-runtime"), \
                mock.patch.object(scripts, "syntax_check"):
            return scripts.main([tool, action, *args])

    def test_dry_run_is_write_free_and_does_not_resolve_runtime(self):
        with mock.patch.object(scripts, "fetch") as fetch, mock.patch.object(scripts, "runtime") as runtime:
            for tool in scripts.TOOLS:
                for action in ("install", "update", "repair", "uninstall"):
                    self.assertEqual(scripts.main([tool, action, "--dry-run"]), 0)
            fetch.assert_not_called()
            runtime.assert_not_called()
        self.assertFalse(self.root.exists())

    def test_missing_status_and_doctor_are_read_only(self):
        with mock.patch.object(scripts, "fetch") as fetch, mock.patch.object(scripts, "syntax_check") as probe:
            for tool in scripts.TOOLS:
                self.assertEqual(scripts.main([tool, "status"]), 0)
                self.assertEqual(scripts.main([tool, "doctor"]), 1)
            fetch.assert_not_called()
            probe.assert_not_called()
        self.assertFalse(self.root.exists())

    def test_install_update_check_and_uninstall_each_tool(self):
        for tool in scripts.TOOLS:
            self.assertEqual(self.invoke(tool), 0)
            base, source, marker = scripts.paths(tool)
            self.assertEqual(json.loads(marker.read_text()), scripts.record(scripts.TOOLS[tool]))
            with mock.patch.object(scripts, "fetch") as fetch, \
                    mock.patch.object(scripts, "verify"), mock.patch.object(scripts, "runtime"), \
                    mock.patch.object(scripts, "syntax_check") as probe:
                self.assertEqual(scripts.main([tool, "update"]), 0)
                self.assertEqual(scripts.main([tool, "check"]), 0)
                fetch.assert_not_called()
                probe.assert_not_called()
            self.assertFalse((base / "operation.lock").exists())
            self.assertEqual(self.invoke(tool, "uninstall"), 0)
            self.assertFalse(marker.exists())
            self.assertFalse(source.exists())
        self.assertTrue(list((self.root / "install_logs").glob("*.log")))

    def test_failed_new_install_rolls_back_source_and_keeps_current_log(self):
        with mock.patch.object(scripts, "fetch", side_effect=self.fetch), \
                mock.patch.object(scripts, "verify"), mock.patch.object(scripts, "resources"), \
                mock.patch.object(scripts, "runtime", return_value="fake"), \
                mock.patch.object(scripts, "syntax_check", side_effect=ValueError("syntax failure")):
            with self.assertRaisesRegex(ValueError, "syntax failure"):
                scripts.main(["bats_core", "install"])
        base, source, marker = scripts.paths("bats_core")
        self.assertFalse(source.exists())
        self.assertFalse(marker.exists())
        self.assertFalse((base / "operation.lock").exists())
        logs = list((self.root / "install_logs").glob("*.log"))
        self.assertEqual(len(logs), 1)
        self.assertIn("Rollback", logs[0].read_text())
        self.assertIn("Ergebnis: failed", logs[0].read_text())

    def test_existing_unregistered_source_is_not_removed_on_failure(self):
        base, source, marker = scripts.paths("bats_core")
        source.mkdir(parents=True)
        personal = source / "personal.txt"
        personal.write_text("keep")
        with mock.patch.object(scripts, "fetch", side_effect=ValueError("foreign source")), \
                mock.patch.object(scripts, "resources"), mock.patch.object(scripts, "runtime"):
            with self.assertRaisesRegex(ValueError, "foreign"):
                scripts.main(["bats_core"])
        self.assertEqual(personal.read_text(), "keep")
        self.assertFalse(marker.exists())

    def test_modified_source_refuses_uninstall_and_retains_marker(self):
        self.invoke()
        _, source, marker = scripts.paths("bats_core")
        with mock.patch.object(scripts, "verify", side_effect=ValueError("changed source")):
            with self.assertRaisesRegex(ValueError, "changed"):
                scripts.main(["bats_core", "uninstall"])
        self.assertTrue(source.exists())
        self.assertTrue(marker.exists())

    def test_missing_runtime_is_logged_before_download(self):
        with mock.patch.object(scripts, "runtime", side_effect=ValueError("bash fehlt")), \
                mock.patch.object(scripts, "fetch") as fetch:
            with self.assertRaisesRegex(ValueError, "bash fehlt"):
                scripts.main(["bats_core"])
            fetch.assert_not_called()
        log, = (self.root / "install_logs").glob("*.log")
        self.assertIn("bash fehlt", log.read_text())

    def test_low_disk_is_logged_without_fetch(self):
        usage = type("Usage", (), {"free": 128 * 1024**2})()
        with mock.patch.object(scripts, "runtime"), mock.patch.object(scripts, "resources"), \
                mock.patch.object(scripts.shutil, "disk_usage", return_value=usage), \
                mock.patch.object(scripts, "fetch") as fetch:
            with self.assertRaisesRegex(ValueError, "Speicherplatzmangel"):
                scripts.main(["invoke_build"])
            fetch.assert_not_called()
        log, = (self.root / "install_logs").glob("*.log")
        self.assertIn("Speicherplatzmangel", log.read_text())

    def test_source_delete_does_not_require_runtime(self):
        self.invoke()
        with mock.patch.object(scripts, "runtime", side_effect=AssertionError("must not execute")), \
                mock.patch.object(scripts, "verify"):
            self.assertEqual(scripts.main(["bats_core", "uninstall"]), 0)

    def test_syntax_checks_parse_only_and_do_not_inherit_api_keys(self):
        for tool, spec in scripts.TOOLS.items():
            _, source, _ = scripts.paths(tool)
            with mock.patch.object(scripts.subprocess, "run") as run, \
                    mock.patch.dict(os.environ, ANTHROPIC_API_KEY="secret", BASH_ENV="malicious"):
                scripts.syntax_check(source, spec, "fake-runtime")
                args, kwargs = run.call_args
                self.assertNotIn("ANTHROPIC_API_KEY", kwargs["env"])
                self.assertEqual(kwargs["timeout"], 60)
                if tool == "bats_core":
                    self.assertIn("-n", args[0])
                    self.assertEqual(kwargs["env"]["BASH_ENV"], os.devnull)
                else:
                    self.assertIn("::ParseFile", args[0][-1])
                    self.assertNotIn("Import-Module", args[0][-1])
            with mock.patch.object(scripts.subprocess, "run", side_effect=subprocess.TimeoutExpired("fake", 60)):
                with self.assertRaisesRegex(ValueError, "Syntaxpruefung"):
                    scripts.syntax_check(source, spec, "fake-runtime")

    def test_registry_menu_wrappers_and_markers_agree(self):
        registry = json.loads((ROOT / "config/tools.yml").read_text())
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        native = (ROOT / "scripts/helpers/native_tool_status.sh").read_text()
        for tool, spec in scripts.TOOLS.items():
            row, = [row for row in registry["tools"] if row["id"] == tool]
            self.assertEqual(row["source_commit"], spec["pin"])
            self.assertFalse(row["auto_install"])
            self.assertEqual(row["ports"], [])
            self.assertIn(f'TOOL_SCRIPT_NAMES["{spec["name"]}"]="{tool}"', menu)
            self.assertIn(f'{spec["name"]}) marker={tool}/scripts-ready.json', native)
            for action in ("install", "update", "uninstall", "check", "doctor", "status"):
                path = ROOT / f"scripts/tools/{tool}_{action}.sh"
                self.assertIn(f'script_quality.py" {tool} {action} "$@"', path.read_text())

    def test_workspace_rejects_repository_and_relative_paths(self):
        for root in ("relative", str(ROOT)):
            with mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=root), self.assertRaises(ValueError):
                scripts.paths("bats_core")

    def test_explicit_runtime_selection(self):
        with mock.patch.dict(os.environ, INVOKE_BUILD_PWSH_BIN="explicit-pwsh"), \
                mock.patch.object(scripts.shutil, "which", return_value="explicit-pwsh") as which:
            self.assertEqual(scripts.runtime(scripts.TOOLS["invoke_build"]), "explicit-pwsh")
            which.assert_called_once_with("explicit-pwsh")

    @unittest.skipUnless(os.name == "nt", "Windows WSL-launcher guard")
    def test_windows_wsl_launcher_is_rejected_without_execution(self):
        launcher = str(Path(os.environ["SystemRoot"]) / "System32/bash.exe")
        with mock.patch.object(scripts.shutil, "which", return_value=launcher), \
                mock.patch.object(scripts.subprocess, "run") as run:
            with self.assertRaisesRegex(ValueError, "WSL-Launcher"):
                scripts.runtime(scripts.TOOLS["bats_core"])
            run.assert_not_called()


if __name__ == "__main__":
    unittest.main()
