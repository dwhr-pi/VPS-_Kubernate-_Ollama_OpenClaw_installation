import contextlib
import importlib.util
import io
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]


def load(name, file):
    spec = importlib.util.spec_from_file_location(name, ROOT / file)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


health = load('platform_health', 'scripts/operations/platform_health.py')
backup = load('backup_restore_test', 'scripts/operations/backup_restore_test.py')


class Diagnostics(unittest.TestCase):
    def cli(self, *args):
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            code = health.main(list(args))
        return code, json.loads(output.getvalue())

    def test_default_offline_never_executes_or_contacts_services(self):
        with patch.object(health, 'host_probe', side_effect=AssertionError), patch.object(
                health, 'http_probe', side_effect=AssertionError), patch.object(
                health, 'private_metadata', side_effect=AssertionError):
            code, report = self.cli('doctor', '--json')
        self.assertEqual(code, 3)
        self.assertFalse(report['runtime_acceptance'])
        self.assertFalse(report['selected_probes_passed'])
        self.assertEqual(len(report['not_checked']), 11)
        self.assertEqual(report['checks'][0]['status'], 'passed')

    def test_dry_run_overrides_runtime_and_metadata_paths(self):
        with patch.object(health, 'http_probe', side_effect=AssertionError):
            code, report = self.cli('smoke', '--runtime', '--dry-run', '--require', 'ollama',
                                    '--secret-metadata', '/does-not-exist')
        self.assertEqual(code, 3)
        self.assertFalse(report['runtime_requested'])

    def test_selected_success_is_not_global_acceptance(self):
        with patch.object(health, 'http_probe', return_value=(True, 'fixture')) as probe:
            code, report = self.cli('smoke', '--runtime', '--require', 'ollama', '--require', 'ollama')
        probe.assert_called_once_with('ollama')
        self.assertEqual(code, 0)
        self.assertTrue(report['selected_probes_passed'])
        self.assertFalse(report['runtime_acceptance'])

    def test_selected_failure_is_nonzero(self):
        with patch.object(health, 'http_probe', return_value=(False, 'fixture')):
            code, report = self.cli('smoke', '--runtime', '--require', 'n8n')
        self.assertEqual(code, 1)
        self.assertFalse(report['selected_probes_passed'])

    def test_unknown_probe_and_invalid_limits_rejected(self):
        for extra in (['--require', 'shell'], ['--min-free-gib', 'nan'],
                      ['--min-free-gib', '0'], ['--max-backup-age-hours', 'inf']):
            with self.subTest(extra=extra), contextlib.redirect_stderr(io.StringIO()):
                with self.assertRaises(SystemExit):
                    self.cli('doctor', *extra)

    def test_missing_runtime_selection_remains_incomplete(self):
        code, _ = self.cli('smoke', '--runtime')
        self.assertEqual(code, 3)

    def test_p0_pin_failure(self):
        with patch.object(health, 'pin_check', return_value=(False, 'fixture')):
            code, report = self.cli('doctor')
        self.assertEqual(code, 1)
        self.assertEqual(report['checks'][0]['severity'], 'P0')

    def test_low_disk_is_p0(self):
        with patch.object(health.shutil, 'disk_usage', return_value=Mock(free=0)):
            code, report = self.cli('doctor', '--runtime')
        self.assertEqual(code, 1)
        self.assertEqual(report['checks'][-1]['severity'], 'P0')

    def test_backup_freshness_is_not_restore_proof(self):
        with tempfile.TemporaryDirectory() as directory:
            # Use the physical fixture path; /var on macOS is intentionally rejected.
            evidence = Path(directory).resolve() / 'evidence'
            evidence.write_text('not a backup')
            with patch.object(health, 'http_probe', return_value=(True, 'fixture')), \
                    patch.object(health.time, 'time', return_value=evidence.stat().st_mtime + 60):
                code, report = self.cli('doctor', '--runtime', '--min-free-gib', '0.001',
                                        '--require', 'ollama', '--backup-evidence', str(evidence))
            self.assertEqual(code, 0)
            self.assertFalse(report['backup_contents_verified'])

    def test_stale_backup_fails(self):
        with patch.object(health, 'private_metadata', return_value=Mock(st_mtime=0)):
            code, report = self.cli('smoke', '--runtime', '--backup-evidence', '/unused')
        self.assertEqual(code, 1)
        self.assertEqual(report['checks'][0]['status'], 'failed')

    def test_secret_metadata_never_reads_content(self):
        with patch.object(health, 'private_metadata', side_effect=ValueError), patch.object(
                Path, 'read_bytes', side_effect=AssertionError):
            code, report = self.cli('smoke', '--runtime', '--secret-metadata', '/unused')
        self.assertEqual(code, 1)
        self.assertFalse(report['secret_contents_read'])

    def test_cli_is_fixed_bounded_and_output_not_logged(self):
        for name in health.HOSTS:
            with self.subTest(name=name), patch.object(health.shutil, 'which', return_value='/fixed'), patch.object(
                    health.subprocess, 'run', side_effect=subprocess.TimeoutExpired('fixture', 3)) as run:
                passed, message = health.host_probe(name, 'k3s-agent')
                self.assertFalse(passed)
                self.assertEqual(run.call_args.kwargs['timeout'], 3)
                self.assertNotIn('shell', run.call_args.kwargs)
                self.assertNotIn('fixture', message)

    def test_wireguard_link_down_is_not_healthy(self):
        with patch.object(health.shutil, 'which', return_value='/fixed'), patch.object(
                health.subprocess, 'run', return_value=Mock(returncode=0, stdout=b'[{"flags":[]}]')):
            self.assertFalse(health.host_probe('wireguard', 'k3s')[0])

    def test_http_status_redirect_body_limit_and_ollama_schema(self):
        for status, payload, expected in (
                (200, b'{"models":[]}', True), (202, b'', False), (302, b'', False),
                (403, b'private', False), (200, b'{}', False),
                (200, b'not-json', False), (200, b'x' * 65537, False)):
            with self.subTest(status=status, size=len(payload)):
                response = Mock(status=status)
                stream = io.BytesIO(payload)
                response.read1.side_effect = stream.read1
                connection = Mock()
                connection.getresponse.return_value = response
                with patch.object(health.http.client, 'HTTPConnection', return_value=connection) as factory:
                    passed, message = health.http_probe('ollama')
                self.assertEqual(passed, expected)
                factory.assert_called_once_with('127.0.0.1', 11434, timeout=3)
                connection.close.assert_called_once()
                self.assertNotIn('private', message)

    def test_http_failure_is_closed(self):
        connection = Mock()
        connection.connect.side_effect = TimeoutError()
        with patch.object(health.http.client, 'HTTPConnection', return_value=connection):
            self.assertFalse(health.http_probe('ollama')[0])
        connection.close.assert_called_once()

    def test_http_wall_budget_expires(self):
        connection = Mock()
        connection.getresponse.return_value = Mock(status=200)
        with patch.object(health.http.client, 'HTTPConnection', return_value=connection), patch.object(
                health.time, 'monotonic', side_effect=[0, 1, 1, 4]):
            self.assertFalse(health.http_probe('ollama')[0])
        connection.close.assert_called_once()

    def test_missing_or_moving_pin_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'config').mkdir()
            (root / 'config/tools.yml').write_text('{"tools":[]}')
            for pin in ('latest', 'main', '', '0' * 39):
                (root / 'config/docker_to_github.json').write_text(json.dumps(
                    {'tools': [{'recipe': {'pin': pin}}]}))
                self.assertFalse(health.pin_check(root)[0])

    def test_evidence_symlinks_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            (root / 'actual').write_text('fixture')
            try:
                (root / 'linked').symlink_to(root / 'actual')
            except OSError:
                self.skipTest('Symlink privilege unavailable')
            with self.assertRaises(ValueError):
                health.private_metadata(root / 'linked')


class BackupEvidence(unittest.TestCase):
    def test_default_writes_nothing(self):
        with patch.object(backup, 'fixture', side_effect=AssertionError), patch.object(
                backup, 'write_report', side_effect=AssertionError), contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(backup.main(['--report', '/unused']), 3)

    def test_fixture_has_checksum_evidence_not_production_acceptance(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory).resolve() / 'evidence.json'
            output = io.StringIO()
            with contextlib.redirect_stdout(output):
                self.assertEqual(backup.main(['--fixture', '--apply', '--report', str(path)]), 0)
            report = json.loads(path.read_text())
            self.assertEqual(report, json.loads(output.getvalue()))
            self.assertEqual(report['files'], 2)
            self.assertEqual(report['checksum'], 'sha256')
            self.assertRegex(report['archive_sha256'], '^[0-9a-f]{64}$')
            self.assertRegex(report['manifest_sha256'], '^[0-9a-f]{64}$')
            self.assertEqual(report['result'], 'passed')
            self.assertFalse(report['production_backup_verified'])
            self.assertFalse(report['runtime_verified'])
            self.assertFalse(report['database_consistency_verified'])

    def test_existing_report_not_overwritten(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory).resolve() / 'existing'
            path.write_text('unchanged')
            with self.assertRaises(FileExistsError):
                backup.write_report(path, {})
            self.assertEqual(path.read_text(), 'unchanged')

    def test_apply_without_fixture_rejected(self):
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            backup.main(['--apply'])

    def test_dry_run_overrides_apply(self):
        with patch.object(backup, 'fixture', side_effect=AssertionError), contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(backup.main(['--fixture', '--apply', '--dry-run']), 3)

    def test_restore_failure_has_no_success_evidence(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'report'
            with patch.object(backup, 'fixture', side_effect=ValueError), contextlib.redirect_stderr(io.StringIO()):
                self.assertEqual(backup.main(['--fixture', '--apply', '--report', str(path)]), 1)
            self.assertFalse(path.exists())

    def test_real_restore_guard_preserved(self):
        text = (ROOT / 'scripts/operations/restore_drill.py').read_text()
        self.assertIn('allow_sensitive_data', text)
        self.assertIn('os.geteuid() == 0', text)
        self.assertIn('WSL_DISTRO_NAME', text)


class TruthTable(unittest.TestCase):
    def test_generated_inventory_is_current_and_honest(self):
        table = load('tool_truth_table', 'scripts/quality/tool_truth_table.py')
        result = table.render()
        self.assertEqual(result, (ROOT / table.OUTPUT).read_text(encoding='utf-8'))
        count = len(json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools'])
        self.assertIn(f'{count} Tools', result)
        self.assertIn('nicht verifiziert', result)
        self.assertEqual(len([line for line in result.splitlines() if line.startswith('| ')]), count + 2)


if __name__ == '__main__':
    unittest.main()
