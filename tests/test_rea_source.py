"""REA fixture tests: no real checkout, npm build, MCP, agent or target analysis."""
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
from types import SimpleNamespace
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
with mock.patch.object(sys, "path", [str(ROOT / "scripts/tools/helpers"), *sys.path]):
    SPEC = importlib.util.spec_from_file_location("rea_source", ROOT / "scripts/tools/helpers/rea_source.py")
    rea = importlib.util.module_from_spec(SPEC)
    SPEC.loader.exec_module(rea)


class ReaSource(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name) / "home"
        self.home.mkdir()
        env = mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(Path(self.tmp.name) / "private"),
                              REA_BUILD="0", INSTALL_HEAVY_TOOLS="0")
        env.start()
        self.addCleanup(env.stop)
        self.base, self.source, self.marker = rea.paths()
        output = redirect_stdout(io.StringIO())
        self.output = output.__enter__()
        self.addCleanup(output.__exit__, None, None, None)
        git = mock.patch.object(rea, "git", side_effect=lambda source, *args:
                                rea.PIN if args == ("rev-parse", "HEAD") else
                                rea.URL if args == ("remote", "get-url", "origin") else "")
        self.git = git.start()
        self.addCleanup(git.stop)

    def fixture(self):
        for name in ("package.json", "package-lock.json", "LICENSE", "DISCLAIMER.md", "scripts/rea.mjs"):
            path = self.source / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text('{"name":"rea-agents","version":"6.7.0"}' if name == "package.json" else "fixture",
                            encoding="utf-8")

    def install(self):
        self.fixture()
        with mock.patch.object(rea, "resource_guard"):
            return rea.main(["install"])

    def test_plan_is_read_only_and_does_not_fetch(self):
        self.assertEqual(rea.main(["--dry-run"]), 0)
        self.assertFalse(self.base.exists())
        self.git.assert_not_called()

    def test_default_installs_source_only_not_runtime(self):
        with mock.patch.object(rea, "build_source") as build:
            self.assertEqual(self.install(), 0)
            build.assert_not_called()
        data = json.loads(self.marker.read_text())
        self.assertEqual(data["scope"], "github-source")
        self.assertEqual(data["commit"], rea.PIN)
        self.assertEqual(rea.main(["doctor"]), 0)
        self.assertFalse((self.home / ".claude").exists())

    def test_update_keeps_same_pin_without_build(self):
        self.install()
        before = self.marker.read_bytes()
        with mock.patch.object(rea, "resource_guard"), mock.patch.object(rea, "build_source") as build:
            self.assertEqual(rea.main(["update"]), 0)
        build.assert_not_called()
        self.assertEqual(before, self.marker.read_bytes())

    def test_invalid_source_does_not_create_marker(self):
        self.fixture()
        self.git.side_effect = lambda *args: "wrong"
        with mock.patch.object(rea, "resource_guard"):
            with self.assertRaisesRegex(ValueError, "Quelle"):
                rea.main(["install"])
        self.assertFalse(self.marker.exists())

    def test_build_requires_second_opt_in_before_fetch(self):
        with mock.patch.dict(os.environ, REA_BUILD="1"), mock.patch.object(rea, "resource_guard"), mock.patch.object(rea, "fetch") as fetch:
            with self.assertRaisesRegex(ValueError, "INSTALL_HEAVY_TOOLS"):
                rea.main(["install"])
        fetch.assert_not_called()
        self.assertFalse(self.marker.exists())

    def test_failed_build_clears_success_marker_and_logs_failure(self):
        self.install()
        with mock.patch.dict(os.environ, REA_BUILD="1", INSTALL_HEAVY_TOOLS="1"), mock.patch.object(rea, "resource_guard"), mock.patch.object(rea, "build_source", side_effect=OSError("disk full")):
            with self.assertRaises(OSError):
                rea.main(["--repair"])
        self.assertFalse(self.marker.exists())
        self.assertTrue(self.source.exists())
        logs = list((self.base.parent.parent / "install_logs").glob("rea_repair_*.log"))
        self.assertEqual(len(logs), 1)
        self.assertIn("disk full", logs[0].read_text(encoding="utf-8"))

    def test_build_commands_are_bounded_and_no_setup_is_run(self):
        self.fixture()
        for name in rea.ARTIFACTS:
            path = self.source / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("fixture", encoding="utf-8")
        def command(args, source, **kwargs):
            version = "v24.11.0" if args[0] == "/fixture/node" else "11.16.0"
            return SimpleNamespace(stdout=version)
        with mock.patch.dict(os.environ, REA_BUILD="1", INSTALL_HEAVY_TOOLS="1", OPENAI_API_KEY="fixture-not-a-key"), mock.patch.object(rea.sys, "platform", "linux"), mock.patch.object(rea.shutil, "which", side_effect=lambda x: "/fixture/" + x), mock.patch.object(rea, "resource_guard"), mock.patch.object(rea, "run_command", side_effect=command) as run:
            self.assertEqual(rea.main(["install"]), 0)
        calls = run.call_args_list
        self.assertIn("--ignore-scripts", calls[2].args[0])
        self.assertIn("--concurrency=1", calls[3].args[0])
        self.assertEqual(calls[3].kwargs["timeout"], 3600)
        self.assertNotIn("OPENAI_API_KEY", calls[3].kwargs["env"])
        self.assertFalse(any("setup" in c.args[0] or "mcp" in c.args[0] for c in calls))
        self.assertEqual(json.loads(self.marker.read_text())["scope"], "github-source-built")
        self.assertEqual(rea.main(["doctor"]), 0)
        (self.source / rea.ARTIFACTS[0]).write_text("changed", encoding="utf-8")
        self.assertEqual(rea.main(["check"]), 1)

    def test_uninstall_preserves_source_and_manual_configuration(self):
        self.install()
        config = self.home / ".qwen/settings.json"
        config.parent.mkdir(parents=True)
        config.write_text('{"mcpServers":{"rea":"manual-fixture"}}', encoding="utf-8")
        self.assertEqual(rea.main(["uninstall"]), 0)
        self.assertFalse(self.marker.exists())
        self.assertTrue((self.source / "scripts/rea.mjs").exists())
        self.assertIn("manual-fixture", config.read_text())
        self.assertEqual(rea.main(["status"]), 0)

    def test_low_disk_failure_logged_before_any_fetch(self):
        with mock.patch.object(rea, "resource_guard", side_effect=ValueError("Speicherplatzmangel")), mock.patch.object(rea, "fetch") as fetch:
            with self.assertRaises(ValueError):
                rea.main(["install"])
        fetch.assert_not_called()
        logs = list((self.base.parent.parent / "install_logs").glob("rea_install_*.log"))
        self.assertIn("Speicherplatzmangel", logs[0].read_text(encoding="utf-8"))
        self.assertFalse(self.marker.exists())

    def test_disk_guard(self):
        self.base.mkdir(parents=True)
        with mock.patch.object(rea, "resources"), mock.patch.object(rea.shutil, "disk_usage", return_value=shutil._ntuple_diskusage(100, 99, 1)):
            with self.assertRaisesRegex(ValueError, "1024 MiB"):
                rea.resource_guard(self.base)

    def test_lock_prevents_parallel_operations(self):
        self.base.mkdir(parents=True)
        (self.base / "operation.lock").mkdir()
        with self.assertRaises(FileExistsError), mock.patch.object(rea, "fetch") as fetch:
            rea.main(["install"])
        fetch.assert_not_called()

    def test_failed_marker_write_is_not_installed(self):
        self.fixture()
        with mock.patch.object(rea, "resource_guard"), mock.patch.object(rea.json, "dump", side_effect=OSError("write failed")):
            with self.assertRaises(OSError):
                rea.main(["install"])
        self.assertFalse(self.marker.exists())
        self.assertFalse(list(self.base.glob("status-*")))

    def test_foreign_marker_is_preserved(self):
        self.install()
        self.marker.write_text('{"commit":"foreign"}', encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "Fremder"):
            rea.main(["uninstall"])
        self.assertTrue(self.marker.exists())

    def test_repo_workspace_rejected(self):
        with mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(ROOT / "private")):
            with self.assertRaises(ValueError):
                rea.paths()

    def test_fetch_pin_and_staging_cleanup(self):
        self.base.mkdir(parents=True)
        with mock.patch.object(rea, "source_ok"):
            rea.fetch(self.base, self.source)
        commands = [c.args[1:] for c in self.git.call_args_list]
        self.assertIn(("fetch", "--depth=1", "origin", rea.PIN), commands)
        self.assertFalse(list(self.base.glob("rea-download-*")))

    def test_registry_menu_and_doc_links(self):
        tools = json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"]
        row, = [t for t in tools if t["id"] == "rea"]
        self.assertFalse(row["auto_install"])
        self.assertEqual(row["source_commit"], rea.PIN)
        self.assertEqual(row["ports"], [])
        for key in ("install_script", "uninstall_script", "update_script", "doctor_script", "doc"):
            self.assertTrue((ROOT / row[key]).is_file())
        self.assertIn('TOOL_SCRIPT_NAMES["REA"]="rea"', (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8"))
        for relative in ("docs/tools/rea.md", "docs/tutorials/own-app-with-rea.md"):
            doc = ROOT / relative
            text = doc.read_text(encoding="utf-8")
            self.assertEqual(text.count("```") % 2, 0)
            for target in re.findall(r"\]\(([^)]+)\)", text):
                if "://" not in target:
                    self.assertTrue((doc.parent / target.split("#")[0]).is_file(), target)
        tutorial = (ROOT / "docs/tutorials/own-app-with-rea.md").read_text(encoding="utf-8")
        self.assertEqual(len(re.findall(r"```text\n", tutorial)), 2)
        self.assertIn("C-406/10", tutorial)
        self.assertIn("keine individuelle Rechtsberatung", tutorial)


if __name__ == "__main__":
    unittest.main()
