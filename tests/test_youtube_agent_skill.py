"""Offline fixtures only: no actual downloads, agent skills, helpers or WSL."""
from contextlib import redirect_stdout
import importlib.util
import io
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
with mock.patch.object(sys, "path", [str(ROOT / "scripts/tools/helpers"), *sys.path]):
    import offload_sources
    spec = importlib.util.spec_from_file_location("youtube_agent_skill", ROOT / "scripts/tools/helpers/youtube_agent_skill.py")
    yt = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(yt)


class YouTubeAgentSkill(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.home = self.root / "home"
        self.home.mkdir()
        for patch in (mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(self.root / "private"),
                                      YOUTUBE_AGENT_SKILL_ACCEPT="1"),
                      mock.patch.object(yt.Path, "home", return_value=self.home),
                      mock.patch.object(yt, "verify"),
                      mock.patch.object(yt, "resources")):
            patch.start()
            self.addCleanup(patch.stop)
        self.output = io.StringIO()
        capture = redirect_stdout(self.output)
        capture.__enter__()
        self.addCleanup(capture.__exit__, None, None, None)
        self.base, self.source, self.marker = yt.layout()
        self.target = yt.target_for(None)
        self.voice = self.home / ".claude/youtube/voice.md"
        self.fetch_patch = mock.patch.object(yt, "fetch", side_effect=self.fixture)
        self.fetch = self.fetch_patch.start()
        self.addCleanup(self.fetch_patch.stop)

    def fixture(self, base, source, spec):
        for name in yt.SPEC["files"]:
            path = source / name
            path.parent.mkdir(parents=True, exist_ok=True)
            if path.exists():
                continue
            text = "synthetic fixture, not executable\n"
            if name.endswith("SKILL.md"):
                text = "---\nname: " + path.parent.name + "\ndescription: Fixture\n---\n"
            path.write_text(text, encoding="utf-8")

    def install(self, *args):
        return yt.main(["install", *args])

    def test_dry_runs_are_read_only_offline(self):
        for action in ("install", "update", "repair", "uninstall", "status", "doctor"):
            self.assertEqual(yt.main([action, "--dry-run"]), 0)
        self.assertFalse(self.base.exists())
        self.assertFalse((self.home / ".claude").exists())
        self.fetch.assert_not_called()

    def test_install_copies_exact_eleven_skills_and_six_helpers(self):
        with mock.patch.object(yt.subprocess, "run", side_effect=AssertionError("No runtime allowed")):
            self.assertEqual(self.install(), 0)
            self.assertEqual(yt.main(["doctor"]), 0)
        self.assertEqual(len(yt.SKILLS), 11)
        self.assertEqual(len(yt.HELPERS), 6)
        actual = {p.relative_to(self.target).as_posix() for p in self.target.rglob("*") if p.is_file()}
        self.assertEqual(actual, set(yt.FILES))
        for name in yt.FILES:
            self.assertEqual((self.target / name).read_bytes(), (self.source / "skills" / name).read_bytes())
        self.assertEqual(self.voice.read_bytes(), (self.source / "templates/voice.md").read_bytes())
        self.assertEqual(yt.read_record(self.marker)["scope"], "claude-skills")

    def test_existing_voice_never_overwritten_or_deleted(self):
        self.voice.parent.mkdir(parents=True)
        self.voice.write_text("personal voice", encoding="utf-8")
        self.install()
        yt.main(["uninstall"])
        self.assertEqual(self.voice.read_text(), "personal voice")

    def test_project_local_has_global_voice_and_recorded_target(self):
        project = self.root / "project"
        project.mkdir()
        self.install("--project", str(project))
        self.assertFalse(self.target.exists())
        self.assertTrue((project / ".claude/skills/yt-script/SKILL.md").is_file())
        self.assertTrue(self.voice.is_file())
        self.assertEqual(yt.main(["check"]), 0)
        yt.main(["uninstall"])
        self.assertFalse((project / ".claude/skills/yt-script").exists())
        self.assertTrue(self.voice.is_file())

    def test_invalid_projects_are_refused(self):
        for project in ("relative", str(self.root / "absent"), str(ROOT)):
            with self.assertRaises(ValueError):
                self.install("--project", project)
        self.fetch.assert_not_called()

    def test_moved_project_can_be_deregistered_without_touching_moved_data(self):
        project = self.root / "project"
        project.mkdir()
        self.install("--project", str(project))
        moved = self.root / "moved-project"
        project.rename(moved)
        self.assertEqual(yt.main(["check"]), 1)
        self.assertEqual(yt.main(["uninstall"]), 0)
        self.assertFalse(self.marker.exists())
        self.assertTrue((moved / ".claude/skills/yt-script/SKILL.md").is_file())

    def test_source_only_has_no_activation(self):
        self.install("--source-only")
        self.assertTrue(self.source.is_dir())
        self.assertFalse(self.marker.exists())
        self.assertFalse(self.target.exists())
        self.assertFalse(self.voice.exists())
        self.assertEqual(yt.main(["check"]), 1)

    def test_declined_or_noninteractive_never_activates(self):
        for policy in ("0", "ask"):
            with mock.patch.dict(os.environ, YOUTUBE_AGENT_SKILL_ACCEPT=policy), mock.patch.object(yt.sys.stdin, "isatty", return_value=False):
                with self.assertRaisesRegex(ValueError, "Nicht akzeptiert"):
                    self.install()
        self.assertTrue(self.source.is_dir())
        self.assertFalse(self.marker.exists())
        self.assertFalse(self.target.exists())

    def test_explicit_accept_is_supported(self):
        with mock.patch.dict(os.environ, YOUTUBE_AGENT_SKILL_ACCEPT="0"):
            self.assertEqual(self.install("--accept"), 0)

    def test_foreign_skill_blocks_all_copying(self):
        folder = self.target / "yt-edit"
        folder.mkdir(parents=True)
        (folder / "mine.txt").write_text("keep", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "fremden"):
            self.install()
        self.fetch.assert_not_called()
        self.assertFalse((self.target / "yt-script").exists())
        self.assertEqual((folder / "mine.txt").read_text(), "keep")

    def test_idempotent_update_uses_existing_pin(self):
        self.install()
        before = self.marker.read_bytes()
        self.fetch.reset_mock()
        self.assertEqual(yt.main(["update"]), 0)
        self.fetch.assert_not_called()
        self.assertEqual(self.marker.read_bytes(), before)

    def test_modified_skill_blocks_uninstall_without_partial_deletion(self):
        self.install()
        changed = self.target / "yt-edit/deadair.py"
        changed.write_text("personal changes", encoding="utf-8")
        self.assertEqual(yt.main(["doctor"]), 1)
        with self.assertRaisesRegex(ValueError, "veraendert"):
            yt.main(["uninstall"])
        self.assertTrue((self.target / "yt-script/SKILL.md").is_file())
        self.assertTrue(self.marker.exists())

    def test_extra_files_block_uninstall(self):
        self.install()
        (self.target / "yt-script/mine.txt").write_text("keep", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "Zusaetzliche"):
            yt.main(["uninstall"])
        self.assertTrue(self.marker.exists())

    def test_repair_restores_only_missing_files(self):
        self.install()
        missing = self.target / "yt-package/title.py"
        missing.unlink()
        self.assertEqual(yt.main(["check"]), 1)
        yt.main(["--repair"])
        self.assertEqual(missing.read_bytes(), (self.source / "skills/yt-package/title.py").read_bytes())
        self.assertEqual(yt.main(["check"]), 0)

    def test_uninstall_allows_missing_owned_files_preserves_sources_voice_other_skills(self):
        self.install()
        (self.target / "yt-comment/SKILL.md").unlink()
        other = self.target / "other-skill"
        other.mkdir()
        (other / "SKILL.md").write_text("other", encoding="utf-8")
        yt.main(["uninstall"])
        self.assertFalse(self.marker.exists())
        for name in yt.SKILLS:
            self.assertFalse((self.target / name).exists())
        self.assertTrue(self.source.exists())
        self.assertTrue(self.voice.exists())
        self.assertTrue(other.is_dir())
        self.assertEqual(yt.main(["status"]), 0)
        self.assertEqual(yt.main(["doctor"]), 1)

    def test_failed_copy_rolls_back_only_new_files(self):
        self.voice.parent.mkdir(parents=True)
        self.voice.write_text("keep", encoding="utf-8")
        with mock.patch.object(yt.json, "dump", side_effect=OSError("disk full fixture")):
            with self.assertRaises(OSError):
                self.install()
        self.assertFalse(self.marker.exists())
        for name in yt.SKILLS:
            self.assertFalse((self.target / name).exists())
        self.assertTrue(self.source.exists())
        self.assertEqual(self.voice.read_text(), "keep")
        self.assertIn("Rollback", self.output.getvalue())

    def test_preflight_failure_has_current_log(self):
        with mock.patch.object(yt, "resources", side_effect=ValueError("Speicherplatzmangel fixture")):
            with self.assertRaises(ValueError):
                self.install()
        self.fetch.assert_not_called()
        logs = list((self.root / "private/install_logs").glob("youtube_agent_skill_install_*.log"))
        self.assertEqual(len(logs), 1)
        self.assertIn("Speicherplatzmangel fixture", logs[0].read_text(encoding="utf-8"))
        self.assertIn("failed", logs[0].read_text(encoding="utf-8"))
        self.assertFalse(self.marker.exists())

    def test_bad_source_name_or_missing_helper_cannot_activate(self):
        self.fixture(self.base, self.source, yt.SPEC)
        skill = self.source / "skills/yt-script/SKILL.md"
        skill.write_text("name: different", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "Skill-Name"):
            self.install()
        self.assertFalse(self.target.exists())

    def test_record_tampering_is_rejected(self):
        self.install()
        record = json.loads(self.marker.read_text())
        record["hashes"]["../outside"] = "a" * 64
        self.marker.write_text(json.dumps(record), encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "Besitznachweis"):
            yt.main(["uninstall"])
        self.assertTrue((self.target / "yt-script/SKILL.md").is_file())

    def test_real_checkout_verifier_checks_git_pin_and_missing_helpers(self):
        self.fixture(self.base, self.source, yt.SPEC)
        def git(source, *args):
            if args == ("rev-parse", "HEAD"):
                return yt.PIN
            if args == ("remote", "get-url", "origin"):
                return yt.URL
            return ""
        with mock.patch.object(yt, "verify", offload_sources.verify), mock.patch.object(offload_sources, "git", side_effect=git):
            yt.source_ok(self.source)
            (self.source / "skills/yt-viral/swipe.py").unlink()
            with self.assertRaisesRegex(ValueError, "unvollstaendig"):
                yt.source_ok(self.source)

    def test_conflicting_actions_are_rejected_before_writes(self):
        with self.assertRaises(SystemExit):
            yt.main(["uninstall", "--repair"])
        self.assertFalse(self.base.exists())

    def test_registry_menu_docs_and_wrappers(self):
        tools = json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"]
        entry = next(tool for tool in tools if tool["name"] == "YouTube_Agent_Skill")
        self.assertEqual(entry["source_commit"], yt.PIN)
        self.assertFalse(entry["auto_install"])
        self.assertEqual(entry["ports"], [])
        for field in ("install_script", "uninstall_script", "update_script", "doctor_script", "doc"):
            self.assertTrue((ROOT / entry[field]).is_file())
        self.assertIn('TOOL_SCRIPT_NAMES["YouTube_Agent_Skill"]="youtube_agent_skill"', (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8"))
        self.assertIn("youtube_agent_skill/skills-ready.json", (ROOT / "scripts/helpers/native_tool_status.sh").read_text())
        docs = (ROOT / entry["doc"]).read_text(encoding="utf-8")
        for term in (yt.PIN, "kein fertiger MCP-Server", "voice.md", "--project", "--source-only", "--accept", "Windows"):
            self.assertIn(term, docs)


if __name__ == "__main__":
    unittest.main()
