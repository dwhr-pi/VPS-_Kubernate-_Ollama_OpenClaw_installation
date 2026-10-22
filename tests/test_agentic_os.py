"""Agentic OS source-only integration; fixture Git only, no application imports."""
from contextlib import redirect_stdout
import importlib.util
import io
import json
import os
from pathlib import Path
import re
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
with mock.patch.object(sys, "path", [str(ROOT / "scripts/tools/helpers"), *sys.path]):
    spec = importlib.util.spec_from_file_location("agentic_os_sources", ROOT / "scripts/tools/helpers/offload_sources.py")
    sources = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(sources)


class AgenticOSIntegration(unittest.TestCase):
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

    def fixture(self):
        base, source, marker = sources.paths("agentic_os")
        config = sources.TOOLS["agentic_os"]
        for name in config["files"]:
            path = source / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("fixture only", encoding="utf-8")
        return base, source, marker, config

    def git_fixture(self, config):
        def command(location, *args):
            if args == ("rev-parse", "HEAD"):
                return config["pin"]
            if args == ("remote", "get-url", "origin"):
                return config["url"]
            return ""
        return command

    def test_registry_pin_and_source_only_scope(self):
        rows = json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"]
        row, = [t for t in rows if t["id"] == "agentic_os"]
        config = sources.TOOLS["agentic_os"]
        self.assertEqual(row["source_commit"], config["pin"])
        self.assertEqual(row["source"], config["url"])
        self.assertRegex(row["source_commit"], r"^[a-f0-9]{40}$")
        self.assertEqual(row["install_mode"], "github-source-only")
        self.assertEqual(row["status"], "experimental")
        self.assertFalse(row["auto_install"])
        self.assertEqual(row["ports"], [])
        for field in ("install_script", "uninstall_script", "update_script", "doctor_script", "doc"):
            self.assertTrue((ROOT / row[field]).is_file(), field)

    def test_menu_and_indexes(self):
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertEqual(menu.count('TOOL_KEYS+=("Agentic_OS")'), 1)
        self.assertIn('TOOL_SCRIPT_NAMES["Agentic_OS"]="agentic_os"', menu)
        for name in ("TOOLS_CATALOG", "TOOL_INDEX", "TOOL_MATRIX", "GITHUB_TOOL_SOURCES", "START_HERE"):
            self.assertIn("tools/agentic-os.md", (ROOT / "docs" / (name + ".md")).read_text(encoding="utf-8"))

    def test_wrappers_never_bootstrap_or_start(self):
        for action in ("install", "uninstall", "update", "doctor", "status", "check"):
            text = (ROOT / ("scripts/tools/agentic_os_" + action + ".sh")).read_text(encoding="utf-8")
            self.assertIn("set -euo pipefail", text)
            self.assertIn("offload_sources.py", text)
            self.assertIn('agentic_os ', text)
            self.assertIn('"$@"', text)
            for forbidden in ("pip install", "npm ", "sudo ", "start.sh", "uvicorn", "docker ", "kill "):
                self.assertNotIn(forbidden, text)

    def test_plan_has_no_files_network_or_application_execution(self):
        with mock.patch.object(sources, "git") as git, mock.patch.object(sources, "fetch") as fetch:
            self.assertEqual(sources.main(["agentic_os", "--dry-run"]), 0)
        git.assert_not_called()
        fetch.assert_not_called()
        self.assertFalse(sources.paths("agentic_os")[0].exists())
        self.assertIn("Evaluationskandidat", self.output.getvalue())

    def test_marker_update_status_and_deactivation(self):
        _, source, marker, config = self.fixture()
        with mock.patch.object(sources, "git", side_effect=self.git_fixture(config)), mock.patch.object(sources, "resources"):
            self.assertEqual(sources.main(["agentic_os", "install"]), 0)
            record = marker.read_bytes()
            self.assertFalse(json.loads(record)["runtime_ready"])
            self.assertEqual(sources.main(["agentic_os", "update"]), 0)
            self.assertEqual(marker.read_bytes(), record)
            self.assertEqual(sources.main(["agentic_os", "check"]), 0)
        self.assertEqual(sources.main(["agentic_os", "uninstall"]), 0)
        self.assertFalse(marker.exists())
        self.assertTrue((source / "server.py").is_file())

    def test_changed_source_not_reset(self):
        _, source, marker, _ = self.fixture()
        with mock.patch.object(sources, "git", return_value="changed"), mock.patch.object(sources, "resources"):
            with self.assertRaises(ValueError):
                sources.main(["agentic_os", "install"])
        self.assertFalse(marker.exists())
        self.assertTrue((source / "server.py").is_file())

    def test_low_disk_records_failure_without_fetch_or_marker(self):
        base, _, marker = sources.paths("agentic_os")
        with mock.patch.object(sources, "resources", side_effect=ValueError("Speicherplatzmangel")), mock.patch.object(sources, "fetch") as fetch:
            with self.assertRaises(ValueError):
                sources.main(["agentic_os", "install"])
        fetch.assert_not_called()
        self.assertFalse(marker.exists())
        logs = list((base.parent.parent / "install_logs").glob("agentic_os_install_*.log"))
        self.assertEqual(len(logs), 1)
        self.assertIn("Speicherplatzmangel", logs[0].read_text(encoding="utf-8"))

    def test_fetch_failure_never_writes_success_marker(self):
        with mock.patch.object(sources, "resources"), mock.patch.object(sources, "fetch", side_effect=OSError("network unavailable")):
            with self.assertRaises(OSError):
                sources.main(["agentic_os", "install"])
        self.assertFalse(sources.paths("agentic_os")[2].exists())

    def test_missing_status_is_not_runtime_ready(self):
        self.assertEqual(sources.main(["agentic_os", "status"]), 0)
        status = json.loads(self.output.getvalue())
        self.assertFalse(status["installed"])
        self.assertFalse(status["runtime_ready"])
        self.assertFalse(sources.paths("agentic_os")[0].exists())

    def test_documentation_has_corrections_limits_and_valid_links(self):
        doc = ROOT / "docs/tools/agentic-os.md"
        text = doc.read_text(encoding="utf-8")
        for phrase in ("FastAPI", "keinen Next.js", "Evaluationskandidat", "runtime_ready=false",
                       "kill -9", "~/.hermes/.env", "kein Kernbestandteil", "Nur Setup-Marker"):
            self.assertIn(phrase, text)
        for target in re.findall(r"\]\(([^)]+)\)", text):
            if "://" not in target and not target.startswith("#"):
                self.assertTrue((doc.parent / target.split("#")[0]).is_file(), target)
        self.assertEqual(len(re.findall(r"^```.*$", text, re.M)) % 2, 0)


if __name__ == "__main__":
    unittest.main()
