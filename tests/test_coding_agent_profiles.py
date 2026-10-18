"""Offline template, routing and mocked source tests: no agents, downloads or WSL."""
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("coding_agents", ROOT / "scripts/profiles/coding_agents.py")
agents = importlib.util.module_from_spec(spec)
spec.loader.exec_module(agents)


class Profiles(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name) / "private"
        self.environment = mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(self.root))
        self.environment.start()

    def tearDown(self):
        self.environment.stop()
        self.temp.cleanup()

    def test_registry_menu_tools_and_docs(self):
        profiles = json.loads((ROOT / "config/profiles.yml").read_text(encoding="utf-8"))["profiles"]
        tools = json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"]
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        status = (ROOT / "scripts/helpers/status_tracking.sh").read_text(encoding="utf-8")
        expected = agents.catalog()["profiles"]
        self.assertEqual(len(expected), 7)
        for item in expected:
            row, = [p for p in profiles if p["id"] == item["id"]]
            self.assertEqual(row["status"], "planned")
            self.assertFalse(row["auto_install"])
            self.assertTrue(set(row["tools"]) <= {t["id"] for t in tools})
            for field in ("doc", "install", "uninstall"):
                self.assertTrue((ROOT / row[field]).is_file())
            self.assertIn('"' + item["id"] + '"', menu)
            self.assertIn('"' + item["id"] + '"', status)
        for provider, source in agents.catalog()["providers"].items():
            row, = [t for t in tools if t["id"] == provider]
            self.assertEqual(row["source_commit"], source["commit"])
            self.assertTrue((ROOT / row["install_script"]).is_file())

    def test_plan_does_not_write_or_run(self):
        with mock.patch.object(agents.subprocess, "run", side_effect=AssertionError("must not run")):
            self.assertEqual(agents.main(["profile", "Claude_Code_Agent", "--dry-run"]), 0)
            self.assertEqual(agents.main(["source", "gemini_cli", "--dry-run"]), 0)
            self.assertEqual(agents.main(["route", "planning"]), 0)
        self.assertFalse(self.root.exists())

    def test_cloud_default_is_local_and_opt_in_is_plan_only(self):
        for task in ("planning", "refactoring", "architecture", "documentation", "research", "google", "multimodal"):
            self.assertEqual(agents.route(task)["selected_profile"], "Ollama_Coder")
            allowed = agents.route(task, True)
            self.assertNotEqual(allowed["selected_profile"], "Ollama_Coder")
            self.assertFalse(allowed["executed"])
        for task, profile in (("orchestrate", "Jarvis_Core"), ("runtime", "OpenClaw_Runtime"), ("scale", "Kubernetes_Agent_Scaling"), ("tools", "MCP_Tool_Layer")):
            self.assertEqual(agents.route(task)["selected_profile"], profile)

    def test_install_idempotent_check_and_non_destructive_uninstall(self):
        for row in agents.catalog()["profiles"]:
            name = row["id"]
            self.assertEqual(agents.profile_action(name, "check"), 1)
            self.assertEqual(agents.profile_action(name, "install"), 0)
            self.assertEqual(agents.profile_action(name, "install"), 0)
            self.assertEqual(agents.profile_action(name, "check"), 0)
            self.assertEqual(agents.profile_action(name, "uninstall"), 0)
            self.assertTrue((self.root / "agent_profiles" / name / "profile.json").is_file())
            self.assertEqual(agents.profile_action(name, "check"), 1)

    def test_modified_template_preserved(self):
        agents.profile_action("Jarvis_Core", "install")
        path = self.root / "agent_profiles/Jarvis_Core/profile.json"
        path.write_text("own config", encoding="utf-8")
        with self.assertRaises(ValueError):
            agents.profile_action("Jarvis_Core", "--repair")
        self.assertEqual(path.read_text(), "own config")

    def test_lock_blocks_concurrent_update(self):
        agents.profile_action("Jarvis_Core", "install")
        path = self.root / "agent_profiles/Jarvis_Core/.operation-lock"
        path.mkdir()
        with self.assertRaises(ValueError):
            agents.profile_action("Jarvis_Core", "update")
        self.assertTrue(path.is_dir())

    def test_unsafe_paths_rejected(self):
        for path in (str(ROOT / "private"), str(Path(self.temp.name) / ".." / "other"), str(Path(self.temp.name).anchor)):
            with mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=path), self.assertRaises(ValueError):
                agents.private_root()

    def test_source_missing_status_does_not_fetch(self):
        with mock.patch.object(agents.subprocess, "run", side_effect=AssertionError("must not run")):
            self.assertEqual(agents.source_action("gemini_cli", "status"), 0)
            self.assertEqual(agents.source_action("claude_code", "doctor"), 1)
        self.assertFalse(self.root.exists())

    def test_mocked_source_fetch_never_builds_or_executes_cli(self):
        calls = []
        def fake_git(path, *args):
            calls.append(args)
            return ""
        with mock.patch.object(agents, "git", side_effect=fake_git), mock.patch.object(agents, "source_ok", return_value=True), mock.patch.object(agents.shutil, "disk_usage", return_value=mock.Mock(free=4 * 1024**3)):
            agents.source_action("gemini_cli", "install")
        self.assertEqual([c[0] for c in calls], ["init", "remote", "fetch", "checkout"])
        pin = agents.catalog()["providers"]["gemini_cli"]["commit"]
        self.assertEqual(calls[2][-1], pin)
        self.assertFalse(json.loads((self.root / "tools/gemini_cli/source-ready.json").read_text())["runtime_ready"])

    def test_failed_fetch_leaves_no_success_marker(self):
        with mock.patch.object(agents, "git", side_effect=subprocess.CalledProcessError(1, "git")), mock.patch.object(agents.shutil, "disk_usage", return_value=mock.Mock(free=4 * 1024**3)):
            self.assertEqual(agents.main(["source", "gemini_cli", "install"]), 2)
        self.assertFalse((self.root / "tools/gemini_cli/source-ready.json").exists())
        self.assertFalse((self.root / "tools/gemini_cli/.operation-lock").exists())

    def test_profile_install_rejects_low_disk(self):
        with mock.patch.object(agents.shutil, "disk_usage", return_value=mock.Mock(free=0)), self.assertRaises(ValueError):
            agents.profile_action("Jarvis_Core", "install")
        self.assertFalse((self.root / "agent_profiles/Jarvis_Core/installed.json").exists())

    def test_documentation_is_explicit_about_missing_runtime(self):
        doc = (ROOT / "docs/agents/coding-agent-profiles.md").read_text(encoding="utf-8")
        for word in ("nicht Open Source", "Offline-Routingplan", "keine Sandbox", "runtime_ready", "nur GitHub"):
            self.assertIn(word, doc)


if __name__ == "__main__":
    unittest.main()
