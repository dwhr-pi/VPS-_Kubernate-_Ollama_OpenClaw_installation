"""Offline installer fixtures only: no downloads, real skills, agents or WSL."""
from contextlib import redirect_stdout
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import tempfile
import unittest
from unittest import mock
import re

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("find_skills", ROOT / "scripts/tools/helpers/find_skills.py")
fs = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(fs)


class FindSkills(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name) / "home"
        self.home.mkdir()
        self.env = mock.patch.dict(os.environ, {
            "OPENCLAW_USER_DATA_DIR": str(Path(self.tmp.name) / "private"),
            "FIND_SKILLS_ACCEPT": "1", "FIND_SKILLS_AGENT": "claude-code",
        })
        self.env.start()
        self.addCleanup(self.env.stop)
        self.home_patch = mock.patch.object(fs.Path, "home", return_value=self.home)
        self.home_patch.start()
        self.addCleanup(self.home_patch.stop)
        self.output = io.StringIO()
        self.stdout = redirect_stdout(self.output)
        self.stdout.__enter__()
        self.addCleanup(self.stdout.__exit__, None, None, None)
        self.git = mock.patch.object(fs, "git", side_effect=lambda source, *args:
                                     fs.COMMIT if args == ("rev-parse", "HEAD") else
                                     fs.SOURCE if args == ("remote", "get-url", "origin") else "")
        self.git_mock = self.git.start()
        self.addCleanup(self.git.stop)
        self.base, self.marker = fs.layout()

    def source(self):
        source = self.base / "source"
        (source / "skills/find-skills").mkdir(parents=True, exist_ok=True)
        (source / "skills/find-skills/SKILL.md").write_text(
            "---\nname: find-skills\ndescription: Fixture\n---\n", encoding="utf-8")
        (source / "LICENSE").write_text("MIT fixture\n", encoding="utf-8")
        return source

    def install(self, agent="claude-code"):
        source = self.source()
        with mock.patch.object(fs, "fetch", return_value=source), mock.patch.object(fs, "resources"):
            return fs.main(["install", "--agent", agent])

    def test_plan_is_read_only_and_offline(self):
        self.assertEqual(fs.main(["--dry-run", "--agent", "qwen-code"]), 0)
        self.assertFalse(self.base.exists())
        self.assertFalse((self.home / ".qwen").exists())
        self.git_mock.assert_not_called()

    def test_action_wrapper_dry_runs_are_read_only(self):
        for action in ("install", "update", "uninstall", "check", "status"):
            self.assertEqual(fs.main([action, "--dry-run"]), 0)
        self.assertFalse(self.base.exists())
        self.git_mock.assert_not_called()

    def test_install_owns_only_skill_and_license(self):
        self.assertEqual(self.install(), 0)
        target = fs.target_for("claude-code")
        self.assertEqual({p.name for p in target.iterdir()}, set(fs.FILES))
        self.assertEqual(fs.read_record(self.marker)["commit"], fs.COMMIT)
        self.assertEqual(fs.main(["doctor"]), 0)
        self.assertIn("success", self.output.getvalue())

    def test_qwen_target_and_record(self):
        self.install("qwen-code")
        self.assertTrue((self.home / ".qwen/skills/find-skills/SKILL.md").is_file())
        self.assertFalse((self.home / ".claude").exists())
        self.assertEqual(fs.read_record(self.marker)["agent"], "qwen-code")

    def test_idempotent_update_does_not_download(self):
        self.install()
        before = self.marker.read_bytes()
        with mock.patch.object(fs, "fetch", side_effect=AssertionError("no fetch")), mock.patch.object(fs, "resources"):
            self.assertEqual(fs.main(["update"]), 0)
        self.assertEqual(self.marker.read_bytes(), before)

    def test_decline_creates_no_activation_marker(self):
        source = self.source()
        with mock.patch.dict(os.environ, FIND_SKILLS_ACCEPT="0"), mock.patch.object(fs, "fetch", return_value=source), mock.patch.object(fs, "resources"):
            with self.assertRaisesRegex(ValueError, "Nicht akzeptiert"):
                fs.main(["install"])
        self.assertFalse(self.marker.exists())
        self.assertFalse(fs.target_for("claude-code").exists())
        self.assertTrue(source.exists())

    def test_no_tty_default_does_not_accept(self):
        source = self.source()
        with mock.patch.dict(os.environ, FIND_SKILLS_ACCEPT="ask"), mock.patch.object(fs.sys.stdin, "isatty", return_value=False), mock.patch.object(fs, "fetch", return_value=source), mock.patch.object(fs, "resources"):
            with self.assertRaises(ValueError):
                fs.main(["install"])
        self.assertFalse(self.marker.exists())

    def test_foreign_skill_is_preserved(self):
        target = fs.target_for("claude-code")
        target.mkdir(parents=True)
        (target / "SKILL.md").write_text("foreign", encoding="utf-8")
        with mock.patch.object(fs, "resources"), mock.patch.object(fs, "fetch") as fetch:
            with self.assertRaisesRegex(ValueError, "fremden"):
                fs.main(["install"])
            fetch.assert_not_called()
        self.assertEqual((target / "SKILL.md").read_text(), "foreign")

    def test_doctor_detects_changes_without_execution(self):
        self.install()
        (fs.target_for("claude-code") / "SKILL.md").write_text("changed", encoding="utf-8")
        self.assertEqual(fs.main(["--check"]), 1)

    def test_uninstall_preserves_modified_or_extra_files(self):
        self.install()
        target = fs.target_for("claude-code")
        (target / "notes.txt").write_text("keep", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "Zusaetzliche"):
            fs.main(["uninstall"])
        self.assertTrue(self.marker.exists())
        self.assertTrue((target / "SKILL.md").exists())

    def test_uninstall_removes_owned_files_but_not_sources_or_tools(self):
        self.install()
        self.assertEqual(fs.main(["--uninstall"]), 0)
        self.assertFalse(self.marker.exists())
        self.assertFalse(fs.target_for("claude-code").exists())
        self.assertTrue((self.base / "source/LICENSE").exists())
        self.assertTrue((self.home / ".claude").exists())
        self.assertEqual(fs.main(["status"]), 0)

    def test_new_install_failure_rolls_back_only_new_files(self):
        with mock.patch.object(fs.json, "dump", side_effect=OSError("disk full")):
            with self.assertRaises(OSError):
                self.install()
        self.assertFalse(self.marker.exists())
        self.assertFalse(fs.target_for("claude-code").exists())
        self.assertTrue((self.base / "source").exists())
        self.assertIn("Rollback", self.output.getvalue())

    def test_low_disk_error_has_current_log_before_download(self):
        with mock.patch.object(fs, "resources", side_effect=ValueError("Speicherplatzmangel")), mock.patch.object(fs, "fetch") as fetch:
            with self.assertRaises(ValueError):
                fs.main(["install"])
            fetch.assert_not_called()
        logs = list((self.base.parent.parent / "install_logs").glob("find_skills_install_*.log"))
        self.assertEqual(len(logs), 1)
        self.assertIn("Speicherplatzmangel", logs[0].read_text(encoding="utf-8"))
        self.assertFalse(self.marker.exists())

    def test_resource_floor(self):
        with mock.patch.object(fs.shutil, "disk_usage", return_value=shutil._ntuple_diskusage(100, 99, 1)):
            with self.assertRaisesRegex(ValueError, "256 MiB"):
                fs.resources(self.home, self.home)

    def test_fetch_uses_exact_pin_without_executing_source(self):
        self.base.mkdir(parents=True)
        with mock.patch.object(fs, "verify_source"):
            source = fs.fetch(self.base)
        self.assertEqual(source, self.base / "source")
        self.assertTrue(source.is_dir())
        commands = [call.args[1:] for call in self.git_mock.call_args_list]
        self.assertIn(("fetch", "--depth=1", "origin", fs.COMMIT), commands)
        self.assertIn(("remote", "add", "origin", fs.SOURCE), commands)
        self.assertNotIn(("pull",), commands)

    def test_failed_fetch_cleans_only_own_staging_directory(self):
        self.base.mkdir(parents=True)
        retained = self.base / "keep.txt"
        retained.write_text("keep", encoding="utf-8")
        self.git_mock.side_effect = OSError("download failed")
        with self.assertRaises(OSError):
            fs.fetch(self.base)
        self.assertEqual(list(self.base.iterdir()), [retained])

    def test_lock_blocks_second_operation(self):
        self.base.mkdir(parents=True)
        (self.base / "operation.lock").mkdir()
        with self.assertRaises(FileExistsError), mock.patch.object(fs, "fetch") as fetch:
            fs.main(["install"])
        fetch.assert_not_called()
        self.assertTrue((self.base / "operation.lock").exists())

    def test_repo_workspace_rejected(self):
        with mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(ROOT / "private")):
            with self.assertRaisesRegex(ValueError, "Setup-Repository"):
                fs.layout()

    def test_invalid_pin_and_agent_switch_rejected(self):
        self.install()
        with mock.patch.object(fs, "resources"):
            with self.assertRaisesRegex(ValueError, "Anderer Agent"):
                fs.main(["install", "--agent", "qwen-code"])
        self.git_mock.side_effect = lambda *args: "wrong"
        with self.assertRaisesRegex(ValueError, "Quelle"):
            fs.verify_source(self.base / "source")

    def test_registry_docs_links_and_menu(self):
        tools = json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"]
        row, = [t for t in tools if t["id"] == "find_skills"]
        self.assertEqual(row["source_commit"], fs.COMMIT)
        self.assertFalse(row["auto_install"])
        self.assertEqual(row["ports"], [])
        for field in ("install_script", "uninstall_script", "update_script", "doctor_script", "doc"):
            self.assertTrue((ROOT / row[field]).is_file())
        self.assertIn('TOOL_SCRIPT_NAMES["Find_Skills"]="find_skills"', (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8"))
        doc = ROOT / row["doc"]
        text = doc.read_text(encoding="utf-8")
        for target in re.findall(r"\]\(([^)]+)\)", text):
            if "://" not in target:
                self.assertTrue((doc.parent / target.split("#")[0]).is_file(), target)
        self.assertEqual(len(re.findall(r"```text\n", text)), 3)
        self.assertIn("Kein automatischer Sicherheitsfilter", text)
        self.assertIn("nicht GitHub-only", text)
        self.assertIn("Kein Desktop-Live-Test", text)


if __name__ == "__main__":
    unittest.main()
