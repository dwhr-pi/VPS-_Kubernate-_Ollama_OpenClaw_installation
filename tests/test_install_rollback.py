"""Synthetic private directories only; never invokes a real installer or WSL."""
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
spec = importlib.util.spec_from_file_location("rollback", ROOT / "scripts/lib/install_rollback.py")
rb = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rb)


class Rollback(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name) / "private"
        self.target = self.root / "tools/qwen_code"
        self.script = ROOT / "scripts/tools/qwen_code_install.sh"
        self.patch = mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(self.root), INSTALL_DISK_ROLLBACK="1")
        self.patch.start()

    def tearDown(self):
        self.patch.stop()
        self.temp.cleanup()

    def run_fake(self, callback):
        with mock.patch.object(rb, "stream", side_effect=callback):
            return rb.main(["Qwen_Code", str(self.script)])

    def journal(self):
        files = list((self.root / "install_transactions").glob("*.json"))
        self.assertEqual(len(files), 1)
        return json.loads(files[0].read_text())

    def test_new_disk_failure_removes_only_owned_root(self):
        unrelated = self.root / "tools/other"
        unrelated.mkdir(parents=True)
        (unrelated / "keep").write_text("data")
        def fake(_):
            (self.target / "node_modules").mkdir()
            (self.target / "node_modules/partial").write_text("partial")
            return 1, True
        self.assertEqual(self.run_fake(fake), 1)
        self.assertFalse(self.target.exists())
        self.assertTrue((unrelated / "keep").exists())
        self.assertEqual(self.journal()["state"], "removed-new-root")

    def test_success_preserved_even_if_log_mentions_disk(self):
        def fake(_):
            (self.target / "source-built").write_text("success")
            return 0, True
        self.assertEqual(self.run_fake(fake), 0)
        self.assertTrue((self.target / "source-built").exists())
        self.assertFalse((self.target / rb.OWNER).exists())
        self.assertEqual(self.journal()["state"], "success-preserved")

    def test_existing_success_never_deleted_by_later_failed_attempt(self):
        self.target.mkdir(parents=True)
        (self.target / "source-built").write_text("prior success")
        self.assertEqual(self.run_fake(lambda _: (1, True)), 1)
        self.assertEqual((self.target / "source-built").read_text(), "prior success")
        self.assertFalse(list((self.root / "install_transactions").glob("*.json")))

    def test_non_disk_failure_preserves_new_files(self):
        def fake(_):
            (self.target / "source").mkdir()
            return 42, False
        self.assertEqual(self.run_fake(fake), 42)
        self.assertTrue((self.target / "source").is_dir())
        self.assertEqual(self.journal()["state"], "non-disk-failure-preserved")

    def test_protected_data_is_not_removed(self):
        for name in (".env", "wallets", "models"):
            with self.subTest(name=name):
                iteration_root = self.root / name.replace(".", "fixture")
                self.target = iteration_root / "tools/qwen_code"
                def fake(_):
                    (self.target / name).write_text("SYNTHETIC_ONLY")
                    return 1, True
                with mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(iteration_root)):
                    self.assertEqual(self.run_fake(fake), 1)
                self.assertTrue((self.target / name).exists())

    def test_cleanup_failure_preserves_original_exit_code(self):
        with mock.patch.object(rb, "cleanup", side_effect=PermissionError("synthetic")):
            self.assertEqual(self.run_fake(lambda _: (28, True)), 28)
        self.assertEqual(self.journal()["state"], "cleanup-incomplete-manual-inspection-required")

    def test_missing_ownership_token_refuses_cleanup(self):
        def fake(_):
            (self.target / rb.OWNER).unlink()
            (self.target / "partial").touch()
            return 1, True
        self.assertEqual(self.run_fake(fake), 1)
        self.assertTrue((self.target / "partial").exists())
        self.assertEqual(self.journal()["state"], "preserved-ownership-mismatch")

    def test_symlink_target_outside_owned_root_is_preserved(self):
        external = Path(self.temp.name) / "outside"
        external.mkdir()
        (external / "keep").touch()
        def fake(_):
            try:
                (self.target / "link").symlink_to(external, target_is_directory=True)
            except OSError:
                self.skipTest("symlinks unavailable")
            return 1, True
        self.assertEqual(self.run_fake(fake), 1)
        self.assertTrue((external / "keep").exists())

    def test_unenrolled_plugin_never_removed(self):
        script = ROOT / "scripts/tools/comfyui_gguf_install.sh"
        target = self.root / "tools/comfyui_gguf"
        def fake(_):
            target.mkdir(parents=True)
            return 1, True
        with mock.patch.object(rb, "stream", side_effect=fake):
            self.assertEqual(rb.main(["ComfyUI_GGUF", str(script)]), 1)
        self.assertTrue(target.exists())

    def test_opt_out_does_not_own_or_remove_root(self):
        def fake(_):
            self.target.mkdir(parents=True)
            return 1, True
        with mock.patch.dict(os.environ, INSTALL_DISK_ROLLBACK="0"):
            self.assertEqual(self.run_fake(fake), 1)
        self.assertTrue(self.target.exists())

    def test_conflicting_installation_is_blocked(self):
        lock = self.root / "install_transactions/.runner-lock"
        lock.mkdir(parents=True)
        with mock.patch.object(rb, "stream", side_effect=AssertionError("must not run")):
            self.assertEqual(rb.main(["Qwen_Code", str(self.script)]), 1)
        self.assertTrue(lock.exists())

    def test_lock_inspection_is_read_only_and_does_not_create_workspace(self):
        with mock.patch.object(rb, 'run') as run:
            self.assertEqual(rb.main(['--inspect-lock']), 0)
        run.assert_not_called()
        self.assertFalse(self.root.exists())

    def test_legacy_lock_is_not_automatically_removed(self):
        lock = self.root / 'install_transactions/.runner-lock'
        lock.mkdir(parents=True)
        report = rb.inspect_lock(self.root)
        self.assertIn('legacy', report['state'])
        self.assertFalse(report['automatic_recovery'])
        self.assertEqual(list(lock.iterdir()), [])

    def test_owner_identity_is_written_and_normal_completion_unlocks(self):
        identity = {'boot_id': 'fixture', 'start_ticks': '42'}
        def fake(_):
            report = rb.inspect_lock(self.root)
            self.assertEqual(report['pid'], os.getpid())
            self.assertEqual(report['state'], 'owner-process-active')
            return 0, False
        with mock.patch.object(rb, 'process_identity', return_value=identity):
            self.assertEqual(self.run_fake(fake), 0)
        self.assertFalse((self.root / 'install_transactions/.runner-lock').exists())

    def test_changed_pid_identity_does_not_unlock(self):
        lock = self.root / 'install_transactions/.runner-lock'
        lock.mkdir(parents=True)
        owner = lock / 'owner.json'
        owner.write_text(json.dumps({'pid': 123, 'identity': {'boot_id': 'old', 'start_ticks': '1'}}))
        with mock.patch.object(rb, 'process_identity', return_value={'boot_id': 'new', 'start_ticks': '1'}):
            report = rb.inspect_lock(self.root)
        self.assertIn('identity-changed', report['state'])
        self.assertTrue(owner.exists())

    def test_unsafe_root_rejected_without_installer(self):
        for path in (str(ROOT / "private"), str(Path(self.temp.name).anchor), str(Path(self.temp.name) / ".." / "other")):
            with mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=path), mock.patch.object(rb, "stream", side_effect=AssertionError("must not run")):
                self.assertEqual(rb.main(["Qwen_Code", str(self.script)]), 1)

    def test_disk_error_patterns_exclude_ram_and_warnings(self):
        for text in ("ENOSPC", "No space left on device", "Zu wenig freier Windows-Host-Speicher.", "Disk quota exceeded"):
            self.assertIsNotNone(rb.DISK_ERROR.search(text))
        for text in ("Zu wenig RAM", "Warnung: wenig Windows-Host-Speicher", "Build fehlgeschlagen"):
            self.assertIsNone(rb.DISK_ERROR.search(text))

    def test_output_is_streamed_without_running_tool(self):
        fake_stdout = mock.Mock(buffer=io.BytesIO())
        with mock.patch.object(sys, "stdout", fake_stdout):
            rc, disk = rb.stream([sys.executable, "-B", "-c", "import sys; print('ENOSPC: synthetic'); sys.exit(7)"])
        self.assertEqual(rc, 7)
        self.assertTrue(disk)

    def test_preflight_precedes_transaction_and_no_uninstall_called(self):
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        body = menu.split("install_tool() {", 1)[1].split("uninstall_tool() {", 1)[0]
        self.assertLess(body.index("preflight_tool_install_storage"), body.index('run_tool_script "$TOOL_KEY" "install"'))
        self.assertIn("nichts zurueckzurollen", body)
        self.assertNotIn('run_tool_script "$TOOL_KEY" "uninstall"', body)


if __name__ == "__main__":
    unittest.main()
