"""Synthetic lock directories only; never reset user installations or kill jobs."""
from contextlib import nullcontext
import importlib.util
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('reset_installation', ROOT / 'scripts/operations/reset_installation.py')
reset = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(reset)
from installation_maintenance import maintenance_guard


class InstallationReset(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / 'workspace'
        self.lock = self.root / 'install_transactions/.runner-lock'
        self._real_scan = reset.scan_processes
        for context in (patch.object(reset, 'maintenance_guard', side_effect=lambda *a, **k: nullcontext()),
                        patch.object(reset, 'scan_processes', return_value={'active': [], 'unreadable': []}),
                        patch.object(reset.os, 'geteuid', return_value=0 if os.name == 'nt' else os.geteuid(), create=True)):
            context.start()
            self.addCleanup(context.stop)

    def old_lock(self):
        self.lock.mkdir(parents=True)

    def test_check_does_not_create_any_files(self):
        report = reset.review(self.root)
        self.assertFalse(report['global']['exists'])
        self.assertFalse(self.root.exists())

    def test_confirmation_and_legacy_acknowledgement_required(self):
        self.old_lock()
        for confirmed, reviewed in ((False, False), (False, True), (True, False)):
            with self.assertRaises(ValueError):
                reset.reset(self.root, confirmed=confirmed, legacy_reviewed=reviewed)
            self.assertTrue(self.lock.is_dir())
        self.assertFalse((self.root / 'install_logs').exists())

    def test_empty_legacy_lock_is_archived_not_deleted(self):
        self.old_lock()
        logfile = reset.reset(self.root, confirmed=True, legacy_reviewed=True)
        self.assertFalse(self.lock.exists())
        self.assertEqual(len(list((self.root / 'install_transactions/reset_archives').glob('*/global.lock'))), 1)
        records = [json.loads(line) for line in logfile.read_text().splitlines()]
        self.assertEqual(records[-1]['event'], 'success')
        self.assertFalse(records[-1]['data_removed'])

    def test_owner_metadata_preserved_in_archive(self):
        self.old_lock()
        (self.lock / 'owner.json').write_text('{}')
        reset.reset(self.root, confirmed=True, legacy_reviewed=True)
        archived = next((self.root / 'install_transactions/reset_archives').glob('*/global.lock/owner.json'))
        self.assertEqual(archived.read_text(), '{}')

    def test_tool_lock_is_optional_and_flow_data_is_preserved(self):
        self.old_lock()
        directory = self.root / 'tools/node_red'
        (directory / 'operation.lock').mkdir(parents=True)
        (directory / 'flows.json').write_text('fixture-keep')
        reset.reset(self.root, tool='node_red', confirmed=True, legacy_reviewed=True)
        self.assertFalse((directory / 'operation.lock').exists())
        self.assertEqual((directory / 'flows.json').read_text(), 'fixture-keep')

    def test_unknown_tool_and_paths_are_rejected(self):
        for value in ('../../data', '/root', 'unregistered_tool'):
            with self.assertRaises(ValueError):
                reset.targets(self.root, value)

    def test_active_installer_or_package_manager_never_unlocks(self):
        self.old_lock()
        with patch.object(reset, 'scan_processes', return_value={'active': [{'pid': 42, 'name': 'cargo'}], 'unreadable': []}):
            with self.assertRaisesRegex(ValueError, 'Aktive Installation'):
                reset.reset(self.root, confirmed=True, legacy_reviewed=True)
        self.assertTrue(self.lock.exists())

    def test_live_owner_never_unlocks(self):
        self.old_lock()
        with patch.object(reset, 'inspect_lock', return_value={'state': 'owner-process-active'}):
            with self.assertRaisesRegex(ValueError, 'Aktive Installation'):
                reset.reset(self.root, confirmed=True, legacy_reviewed=True)
        self.assertTrue(self.lock.exists())

    def test_unreadable_process_state_is_fail_closed(self):
        self.old_lock()
        with patch.object(reset, 'scan_processes', return_value={'active': [], 'unreadable': [42]}):
            with self.assertRaisesRegex(ValueError, 'unvollstaendig'):
                reset.reset(self.root, confirmed=True, legacy_reviewed=True)
        self.assertTrue(self.lock.exists())

    def test_unknown_lock_content_is_preserved(self):
        self.old_lock()
        (self.lock / 'keep').write_text('fixture-data')
        with self.assertRaisesRegex(ValueError, 'Unbekannter Inhalt'):
            reset.reset(self.root, confirmed=True, legacy_reviewed=True)
        self.assertEqual((self.lock / 'keep').read_text(), 'fixture-data')

    def test_confirmed_blocked_attempt_gets_a_new_failure_log(self):
        self.old_lock()
        with patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': str(self.root)}), \
             patch.object(reset, 'scan_processes', return_value={'active': [{'pid': 42, 'name': 'cargo'}], 'unreadable': []}):
            self.assertEqual(reset.main(['--apply', '--confirm-reset', '--acknowledge-legacy']), 1)
        files = list((self.root / 'install_logs').glob('installation_reset_failed_*.log'))
        self.assertEqual(len(files), 1)
        self.assertEqual(json.loads(files[0].read_text())['event'], 'blocked-or-failed')
        self.assertTrue(self.lock.exists())

    def test_process_becoming_active_between_checks_blocks_reset(self):
        self.old_lock()
        with patch.object(reset, 'scan_processes', side_effect=[
                {'active': [], 'unreadable': []}, {'active': [{'pid': 42}], 'unreadable': []}]):
            with self.assertRaisesRegex(ValueError, 'inzwischen geaendert'):
                reset.reset(self.root, confirmed=True, legacy_reviewed=True)
        self.assertTrue(self.lock.exists())

    def test_process_scan_redacts_arguments(self):
        proc = Path(self.temp.name) / 'proc'
        (proc / 'self').mkdir(parents=True)
        (proc / 'self/status').write_text('fixture')
        process = proc / '424242'
        process.mkdir()
        (process / 'comm').write_text('node\n')
        (process / 'cmdline').write_bytes(b'node\0/private/native-github/build.js\0fixture-sensitive-argument\0')
        # setUp mocks discovery for reset fixtures; call the actual module function here.
        with patch.object(reset, 'scan_processes', self._real_scan):
            result = reset.scan_processes(self.root, proc)
        self.assertEqual(result['active'][0]['pid'], 424242)
        self.assertNotIn('fixture-sensitive-argument', json.dumps(result))

    def test_changed_lock_snapshot_is_not_archived(self):
        self.old_lock()
        with patch.object(reset, 'snapshot', side_effect=[{'inode': 1}, {'inode': 2}]):
            with self.assertRaisesRegex(ValueError, 'veraendert'):
                reset.reset(self.root, confirmed=True, legacy_reviewed=True)
        self.assertTrue(self.lock.exists())

    def test_menu_and_shared_helper_are_wired(self):
        setup = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        self.assertIn('"20" "Installations-Reset', setup)
        self.assertIn('"7" "Installations-Reset', setup)
        self.assertIn('scripts/installation_reset_menu.sh', setup)
        helper = (ROOT / 'scripts/tools/helpers/find_skills.py').read_text()
        self.assertIn('maintenance_guard(base.parent.parent)', helper)
        source = (ROOT / 'scripts/operations/reset_installation.py').read_text()
        self.assertNotIn('os.kill(', source)
        self.assertNotIn('shutil.rmtree', source)


@unittest.skipUnless(os.name == 'posix', 'Linux flock integration')
class KernelCoordination(unittest.TestCase):
    def test_reset_cannot_overlap_installer_and_gate_inode_remains(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            with maintenance_guard(root):
                with self.assertRaisesRegex(ValueError, 'belegt'):
                    with maintenance_guard(root, exclusive=True):
                        self.fail('overlapping reset')
            path = root / 'install_transactions/.maintenance.lock'
            inode = path.stat().st_ino
            with maintenance_guard(root, exclusive=True):
                pass
            self.assertEqual(path.stat().st_ino, inode)


if __name__ == '__main__':
    unittest.main()
