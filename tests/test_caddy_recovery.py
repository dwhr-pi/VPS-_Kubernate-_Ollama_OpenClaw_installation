"""Caddy orphan recovery preserves unknown contents; no builds or downloads."""
from contextlib import redirect_stderr, redirect_stdout
import io
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts/tools/helpers"))
import native_github_tools as tool


class CaddyRecoveryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.env = patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": self.temp.name})
        self.env.start()
        self.addCleanup(self.env.stop)
        stdin = patch.object(tool.sys, "stdin", Mock(isatty=Mock(return_value=False)))
        stdin.start()
        self.addCleanup(stdin.stop)
        self.spec = tool.TOOLS["caddy"]
        self.outer, self.prefix, self.marker = tool.paths("caddy")
        self.prefix.mkdir(parents=True)
        self.keep = self.prefix / "unknown-user-notes.txt"
        self.keep.write_text("private user notes")
        self.basis = self.outer / "toolchain/preserved.txt"
        self.basis.parent.mkdir()
        self.basis.write_text("verified basis")

    def fetch(self, checkout, marker, prefix, spec, recipe):
        checkout.mkdir()
        (checkout / "main.go").write_text("source fixture")

    def build(self, prefix, spec):
        (prefix / "bin").mkdir()
        (prefix / "bin/caddy").write_bytes(b"fresh binary")
        return ["bin/caddy"]

    def backups(self):
        return list(self.outer.glob("native-github-incomplete-*/native-github"))

    def test_noninteractive_default_preserves_orphan_without_preflight(self):
        with patch.object(tool, "preflight") as preflight, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Reparatur nicht freigegeben"):
                tool.install(self.outer, self.prefix, self.marker, self.spec)
        preflight.assert_not_called()
        self.assertEqual(self.keep.read_text(), "private user notes")
        self.assertFalse(self.backups())

    def test_interactive_refusal_does_not_move_or_build(self):
        with patch.object(tool.sys.stdin, "isatty", return_value=True), patch("builtins.input", return_value="n"), \
             patch.object(tool, "preflight") as preflight, redirect_stdout(io.StringIO()):
            with self.assertRaises(ValueError):
                tool.install(self.outer, self.prefix, self.marker, self.spec)
        preflight.assert_not_called()
        self.assertTrue(self.keep.exists())
        self.assertFalse(self.backups())

    def test_storage_failure_precedes_any_move(self):
        with patch.object(tool, "preflight", side_effect=ValueError("Speicherplatzmangel")), \
             patch.object(tool, "fetch_source") as fetch, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Speicherplatzmangel"):
                tool.install(self.outer, self.prefix, self.marker, self.spec, quarantine_incomplete=True)
        fetch.assert_not_called()
        self.assertTrue(self.keep.exists())
        self.assertFalse(self.backups())

    def test_explicit_repair_preserves_all_old_data_and_creates_only_fresh_marker(self):
        output = io.StringIO()
        with patch.object(tool, "preflight"), patch.object(tool, "fetch_source", side_effect=self.fetch), \
             patch.object(tool, "build", side_effect=self.build), redirect_stdout(output):
            self.assertEqual(tool.main(["caddy", "install", "--repair", "--quarantine-incomplete"]), 0)
        saved, = self.backups()
        self.assertEqual((saved / self.keep.name).read_text(), "private user notes")
        self.assertFalse(self.keep.exists())
        self.assertFalse((saved / "build-ready.json").exists())
        receipt = json.loads((saved.parent / "RECOVERY.json").read_text())
        self.assertFalse(receipt["installed"])
        self.assertTrue(self.marker.is_file())
        self.assertEqual((self.prefix / "bin/caddy").read_bytes(), b"fresh binary")
        self.assertEqual(self.basis.read_text(), "verified basis")
        log = next((Path(self.temp.name) / "install_logs").glob("*.log"))
        self.assertIn(str(saved), log.read_text())
        self.assertNotIn("private user notes", log.read_text())

    def test_interactive_install_can_offer_recovery_without_extra_cli_flags(self):
        with patch.object(tool.sys.stdin, "isatty", return_value=True), patch("builtins.input", return_value="j"), \
             patch.object(tool, "preflight"), patch.object(tool, "fetch_source", side_effect=self.fetch), \
             patch.object(tool, "build", side_effect=self.build), redirect_stdout(io.StringIO()):
            tool.install(self.outer, self.prefix, self.marker, self.spec)
        self.assertEqual(len(self.backups()), 1)
        self.assertTrue(self.marker.exists())

    def test_new_build_failure_never_removes_preserved_orphan(self):
        with patch.object(tool, "preflight"), patch.object(tool, "fetch_source", side_effect=self.fetch), \
             patch.object(tool, "build", side_effect=ValueError("new build failed")), redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "new build failed"):
                tool.install(self.outer, self.prefix, self.marker, self.spec, quarantine_incomplete=True)
        saved, = self.backups()
        self.assertEqual((saved / self.keep.name).read_text(), "private user notes")
        self.assertFalse(self.prefix.exists())
        self.assertTrue(self.basis.exists())

    def test_invalid_existing_marker_is_not_quarantined_or_adopted(self):
        self.marker.write_text("{}")
        with patch.object(tool, "preflight") as preflight, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Buildmarkierung"):
                tool.install(self.outer, self.prefix, self.marker, self.spec, quarantine_incomplete=True)
        preflight.assert_not_called()
        self.assertFalse(self.backups())
        self.assertTrue(self.keep.exists())

    def test_dry_run_never_moves_existing_files(self):
        with patch.object(tool, "preflight") as preflight, redirect_stdout(io.StringIO()):
            self.assertEqual(tool.main(["caddy", "repair", "--quarantine-incomplete", "--dry-run"]), 0)
        preflight.assert_not_called()
        self.assertFalse(self.backups())
        self.assertFalse((Path(self.temp.name) / "install_logs").exists())
        self.assertTrue(self.keep.exists())

    def test_failed_rename_keeps_original_and_removes_only_empty_recovery_directory(self):
        with patch.object(Path, "rename", side_effect=PermissionError("cannot rename")), redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(PermissionError, "cannot rename"):
                tool.quarantine_incomplete_caddy(self.outer, self.prefix, self.marker, self.spec)
        self.assertFalse(list(self.outer.glob("native-github-incomplete-*")))
        self.assertTrue(self.keep.exists())

    def test_changed_marker_after_preflight_prevents_move(self):
        self.marker.write_text("marker appeared")
        with self.assertRaisesRegex(ValueError, "Zustand geaendert"):
            tool.quarantine_incomplete_caddy(self.outer, self.prefix, self.marker, self.spec)
        self.assertTrue(self.keep.exists())
        self.assertFalse(self.backups())

    def test_option_rejects_other_tools_and_uninstall_before_any_operation(self):
        for args in (["watchtower", "repair", "--quarantine-incomplete"],
                     ["caddy", "uninstall", "--quarantine-incomplete"],
                     ["caddy", "install", "--quarantine-incomplete"]):
            with self.subTest(args=args), patch.object(tool.common, "operation") as operation, redirect_stderr(io.StringIO()):
                with self.assertRaises(SystemExit):
                    tool.main(args)
            operation.assert_not_called()


if __name__ == "__main__":
    unittest.main()
