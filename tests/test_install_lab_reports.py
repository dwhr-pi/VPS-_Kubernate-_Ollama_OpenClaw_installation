"""Measurement backup/restore and native Linux plans; no WSL or privileged actions."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import sys
import tarfile
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / 'scripts/benchmarks'


def load(name):
    spec = importlib.util.spec_from_file_location(name, SCRIPTS / (name + '.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


reports = load('install_lab_reports')
native = load('linux_install_lab')


def record():
    return {'tool': 'caddy', 'status': 'passed_build_probe_uninstall', 'executed': True,
            'cleanup_ok': True, 'installed_artifacts_verified': True, 'installed_after_cycle': False,
            'pin': 'a' * 40, 'recipe_sha256': 'b' * 64, 'source_commit': 'c' * 40,
            'installed_tree_allocated_mib': 42, 'data_with_build_caches_mib': 142,
            'observed_peak_disk_delta_mib': 200,
            'cleanup_data_seconds': 4.5, 'total_cycle_seconds': 130.5,
            'phases': {name: {'returncode': 0, 'seconds': seconds, 'observed_peak_disk_delta_mib': 200}
                       for name, seconds in (('install', 120.5), ('doctor', 2), ('probe', 0.5), ('uninstall', 3))}}


class ReportContracts(unittest.TestCase):
    def test_backup_restore_preserves_real_measurements_not_logs_or_status_files(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'cycles.jsonl'
            row = dict(record(), environment={'KEY': 'sensitive-fixture'}, raw_log='sensitive-fixture')
            source.write_text(json.dumps(row) + '\n', encoding='utf-8')
            archive = root / 'measurements.tar'
            reports.backup_report(source, archive)
            self.assertNotIn(b'sensitive-fixture', archive.read_bytes())
            stamp = reports.payload(archive)['recorded_utc']
            restored = reports.import_report(archive, root / 'workspace')
            result = json.loads(restored.read_text())
            saved = result['records'][0]
            self.assertEqual(saved['phases']['install']['seconds'], 120.5)
            self.assertEqual(saved['observed_peak_disk_delta_mib'], 200)
            self.assertEqual(saved['total_cycle_seconds'], 130.5)
            self.assertEqual(saved['cleanup_data_seconds'], 4.5)
            self.assertFalse(saved['installed_after_cycle'])
            self.assertFalse(saved['runtime_verified'])
            self.assertEqual(result['recorded_utc'], stamp)
            self.assertIsNone(result['batch_complete'])
            self.assertTrue(restored.is_relative_to(root / 'workspace/metrics_logs/install_lab'))
            self.assertFalse((root / 'workspace/tool_status.txt').exists())

    def test_existing_backup_and_installation_status_are_never_overwritten(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'cycles.jsonl'
            source.write_text(json.dumps(record()) + '\n', encoding='utf-8')
            workspace = root / 'workspace'
            workspace.mkdir(mode=0o700)
            status = workspace / 'tool_status.txt'
            status.write_text('Existing program state')
            one = reports.import_report(source, workspace)
            two = reports.import_report(source, workspace)
            self.assertNotEqual(one, two)
            self.assertEqual(status.read_text(), 'Existing program state')
            target = root / 'measurements.tar'
            reports.backup_report(source, target)
            before = target.read_bytes()
            with self.assertRaises(FileExistsError):
                reports.backup_report(source, target)
            self.assertEqual(target.read_bytes(), before)

    def test_incomplete_cycles_remain_incomplete_after_backup_and_restore(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'cycles.jsonl'
            source.write_text(json.dumps(record()) + '\n', encoding='utf-8')
            (root / 'CYCLE_INCOMPLETE').write_text('interrupted')
            archive = root / 'measurements.tar'
            reports.backup_report(source, archive)
            self.assertFalse(reports.payload(archive)['batch_complete'])

    def test_no_success_for_missing_probe_or_remaining_installation(self):
        for mutation in ('phase', 'cleanup', 'installed'):
            row = record()
            if mutation == 'phase':
                del row['phases']['probe']
            if mutation == 'cleanup':
                row['cleanup_ok'] = False
            if mutation == 'installed':
                row['installed_after_cycle'] = True
            with self.subTest(mutation=mutation), self.assertRaises(ValueError):
                reports.clean_record(row)

    def test_unknown_failed_or_skipped_measurements_do_not_become_installed(self):
        for status in ('failed_install', 'skipped_insufficient_space', 'skipped_license_not_approved'):
            row = reports.clean_record({'tool': 'caddy', 'status': status, 'executed': False,
                                        'installed_after_cycle': None})
            self.assertEqual(row['status'], status)
            self.assertIsNone(row['installed_after_cycle'])
        for value in (float('nan'), float('inf'), -1, '42'):
            row = record()
            row['observed_peak_disk_delta_mib'] = value
            with self.assertRaises(ValueError):
                reports.clean_record(row)

    def test_archive_cannot_contain_filesystem_paths_or_secret_payloads(self):
        with tempfile.TemporaryDirectory() as directory:
            archive = Path(directory) / 'bad.tar'
            with tarfile.open(archive, 'w') as stream:
                entry = tarfile.TarInfo('../../outside')
                entry.size = 1
                stream.addfile(entry, io.BytesIO(b'x'))
            with self.assertRaises(ValueError):
                reports.payload(archive)
            self.assertFalse((Path(directory).parent / 'outside').exists())

    def test_restore_plan_does_not_read_input_or_create_directories(self):
        with mock.patch.object(reports, 'payload', side_effect=AssertionError('No input access')):
            with contextlib.redirect_stdout(io.StringIO()) as output:
                self.assertEqual(reports.main(['import', '--input', 'absent.tar']), 0)
        self.assertFalse(json.loads(output.getvalue())['executed'])

    def test_workspace_backup_includes_metrics_namespace(self):
        backup = (ROOT / 'scripts/operations/backup_run.sh').read_text(encoding='utf-8')
        self.assertIn('${USER_WORKSPACE_DIR}/', backup)
        self.assertIn('${TARGET_DIR}/user_workspace/', backup)
        self.assertNotIn('--exclude "metrics_logs"', backup)
        self.assertNotIn('--exclude "/metrics_logs/"', backup)


class NativeLabContracts(unittest.TestCase):
    def test_native_plan_does_not_probe_host_or_provision_accounts(self):
        with mock.patch.object(native, 'root_guard', side_effect=AssertionError('No root operation')):
            with mock.patch.object(native, 'run', side_effect=AssertionError('No command')):
                with contextlib.redirect_stdout(io.StringIO()) as output:
                    self.assertEqual(native.main([]), 0)
        self.assertFalse(json.loads(output.getvalue())['executed'])

    def test_native_lifecycle_is_root_approved_separate_and_cgroup_limited(self):
        source = (SCRIPTS / 'linux_install_lab.py').read_text(encoding='utf-8')
        for item in ('confirm_dedicated_test_host', 'confirm_build_and_uninstall', 'Existing user or UID refused',
                     'MemoryMax=', 'CPUQuota=200%', 'TasksMax=512', 'KillMode=control-group',
                     'NoNewPrivileges=yes', 'ProtectHome=yes', 'ProtectSystem=strict', 'PrivateTmp=yes',
                     'measurements-backup.tar', 'STARTED.json'):
            self.assertIn(item, source)
        self.assertNotIn('wsl.exe', source)
        self.assertNotIn('docker run', source)
        self.assertNotIn('rm -rf', source)

    def test_native_guard_refuses_missing_cgroup_or_unbounded_resources(self):
        lab = native.lab
        nonce = 'a' * 32
        def content(path):
            name = str(path).replace('\\', '/')
            if name == '/proc/self/cgroup':
                return '0::/system.slice/openclaw-install-lab-' + nonce + '.service\n'
            if name.endswith('memory.max'):
                return 'max\n'
            if name.endswith('pids.max'):
                return '512\n'
            if name.endswith('cpu.max'):
                return '200000 100000\n'
            raise AssertionError(name)
        with mock.patch.object(lab.Path, 'read_text', content):
            with self.assertRaises(ValueError):
                lab.validate_cgroup(nonce)


if __name__ == '__main__':
    unittest.main()
