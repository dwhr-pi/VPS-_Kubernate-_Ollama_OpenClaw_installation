"""Offline lab fixtures only: no WSL, downloads, compiler or real tool installation."""
import argparse
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('install_lab', ROOT / 'scripts/benchmarks/install_lab.py')
lab = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(lab)
PS = Path(shutil.which('pwsh') or (Path(os.environ.get('SystemRoot', 'C:/Windows')) /
                                  'System32/WindowsPowerShell/v1.0/powershell.exe'))


class LabContracts(unittest.TestCase):
    def test_default_plan_covers_registry_without_execution_or_writes(self):
        with mock.patch.object(lab.subprocess, 'Popen', side_effect=AssertionError('No process')):
            with mock.patch.object(lab, 'validate_lab', side_effect=AssertionError('No WSL probe')):
                with mock.patch.object(lab, 'write_report', side_effect=AssertionError('No write')):
                    with contextlib.redirect_stdout(io.StringIO()) as out:
                        self.assertEqual(lab.main([]), 0)
        result = json.loads(out.getvalue())
        registry = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        self.assertEqual({r['tool'] for r in result['tools']}, {r['id'] for r in registry})
        self.assertFalse(result['executed'])
        self.assertTrue(all(not r['executed'] and not r['installed_after_cycle'] for r in result['tools']))
        self.assertTrue(any(r['tool'] == 'caddy' and r['eligible'] for r in result['tools']))
        self.assertTrue(any(not r['eligible'] for r in result['tools']))

    def test_source_only_and_container_tools_are_not_passes(self):
        rows = lab.plan()
        for row in rows:
            if row['eligible']:
                self.assertIn(row['tool'], lab.SUPPORTED)
                self.assertRegex(row['pin'], r'^[a-f0-9]{40}$')
                self.assertTrue(row['source'].startswith('https://github.com/'))
                self.assertEqual(row['status'], 'awaiting_license_approval')
            else:
                self.assertEqual(row['status'], 'skipped_unsupported_contract')

    def test_approval_is_exact_and_changed_recipe_invalidates_it(self):
        row = next(r for r in lab.plan() if r['tool'] == 'caddy')
        approvals = {row['tool']: {'recipe_sha256': row['recipe_sha256'],
                                 'source_and_dependency_terms_reviewed': True}}
        self.assertTrue(lab.approved(row, approvals))
        changed = dict(row, recipe_sha256='0' * 64)
        self.assertFalse(lab.approved(changed, approvals))
        approvals['caddy']['source_and_dependency_terms_reviewed'] = 'yes'
        self.assertFalse(lab.approved(row, approvals))
        self.assertFalse(lab.approved(row, {'caddy': 'yes'}))

    def test_installer_dependency_changes_invalidate_approvals_but_crlf_does_not(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            helper = root / 'scripts/tools/helpers'
            helper.mkdir(parents=True)
            file = helper / 'private_go.py'
            file.write_bytes(b'VERSION = "fixture"\n')
            one = lab.installer_contract(root)
            file.write_bytes(b'VERSION = "fixture"\r\n')
            self.assertEqual(lab.installer_contract(root), one)
            file.write_bytes(b'VERSION = "changed"\n')
            self.assertNotEqual(lab.installer_contract(root), one)

    def test_insufficient_linux_or_host_space_is_a_skip(self):
        row = next(r for r in lab.plan() if r['tool'] == 'caddy')
        approval = {'caddy': {'recipe_sha256': row['recipe_sha256'],
                              'source_and_dependency_terms_reviewed': True}}
        self.assertEqual(lab.skip_reason(row, {}, 100000, 100000, 8192), 'skipped_license_not_approved')
        for linux, host in ((1, 100000), (100000, 1)):
            self.assertEqual(lab.skip_reason(row, approval, linux, host, 8192), 'skipped_insufficient_space')
        self.assertIsNone(lab.skip_reason(row, approval, 100000, 100000, 8192))

    def test_run_needs_approval_before_any_lab_access(self):
        with mock.patch.object(lab, 'validate_lab', side_effect=AssertionError('Not approved')):
            with self.assertRaises(ValueError):
                lab.main(['run-one', '--tool', 'caddy'])

    def test_personal_distribution_is_refused_before_marker_read(self):
        with mock.patch.object(lab.platform, 'system', return_value='Linux'):
            with mock.patch.object(lab.os, 'getuid', return_value=20000, create=True):
                with mock.patch.object(lab, 'read_json', side_effect=AssertionError('No marker read')):
                    with self.assertRaises(ValueError):
                        lab.validate_lab('Ubuntu', 'a' * 32)

    def test_new_reports_cannot_overwrite_previous_results(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'report.json'
            lab.write_report(path, {'original': True})
            with self.assertRaises(FileExistsError):
                lab.write_report(path, {'original': False})
            self.assertEqual(json.loads(path.read_text()), {'original': True})

    def test_cycle_success_failure_and_cleanup_preserve_correct_status(self):
        for failure in (None, 'install', 'uninstall', 'orphan', 'timeout'):
            with self.subTest(failure=failure), tempfile.TemporaryDirectory() as directory, contextlib.ExitStack() as stack:
                home = Path(directory)
                stack.enter_context(mock.patch.object(lab.Path, 'home', return_value=home))
                stack.enter_context(mock.patch.object(lab.os, 'getuid', return_value=home.stat().st_uid, create=True))
                if os.name == 'nt':
                    stack.enter_context(mock.patch.object(lab.stat, 'S_IMODE', return_value=0o700))
                row = next(r for r in lab.plan() if r['tool'] == 'caddy')
                approvals = {'caddy': {'recipe_sha256': row['recipe_sha256'],
                                      'source_and_dependency_terms_reviewed': True}}
                args = argparse.Namespace(host_free_mib=1000000, host_reserve_mib=8192, timeout_seconds=60)
                stack.enter_context(mock.patch.object(lab, 'skip_reason', return_value=None))
                stack.enter_context(mock.patch.object(lab, 'memory_available_mib', return_value=8192))

                def fake_command(argv, env, log, _seconds):
                    phase = log.stem
                    data = Path(env['OPENCLAW_USER_DATA_DIR'])
                    prefix = data / 'tools/caddy/native-github'
                    if phase == 'install' and failure != 'install':
                        prefix.mkdir(parents=True)
                        (prefix / 'artifact').write_bytes(b'fixture, not a binary')
                    if phase == 'uninstall' and failure != 'uninstall' and prefix.exists():
                        shutil.rmtree(prefix)
                    return {'returncode': 1 if phase == failure else 0, 'seconds': 0.01,
                            'observed_peak_disk_delta_mib': 1,
                            'process_group_gone': failure != 'orphan',
                            'stop_reason': 'timeout' if failure == 'timeout' else None}

                stack.enter_context(mock.patch.object(lab, 'command', side_effect=fake_command))
                result = lab.cycle(row, approvals, args)
                self.assertFalse(result['runtime_verified'])
                self.assertTrue(result['executed'])
                if failure is None:
                    self.assertEqual(result['status'], 'passed_build_probe_uninstall')
                    self.assertTrue(result['cleanup_ok'])
                    self.assertFalse(result['installed_after_cycle'])
                elif failure == 'install':
                    self.assertEqual(result['status'], 'failed_install')
                    self.assertTrue(result['cleanup_ok'])
                else:
                    self.assertTrue(result['status'].startswith('failed_'))
                    self.assertFalse(result['cleanup_ok'])
                    self.assertTrue((Path(result['report_dir']) / 'data').exists())

    @unittest.skipUnless(os.name == 'posix', 'POSIX process sessions required; no WSL fallback')
    def test_real_supervisor_uses_only_harmless_temporary_process(self):
        with tempfile.TemporaryDirectory() as directory:
            with mock.patch.object(lab, 'memory_available_mib', return_value=8192):
                result = lab.command([sys.executable, '-I', '-c', 'print("fixture")'],
                                     dict(os.environ), Path(directory) / 'probe.log', 10, reserve_mib=0)
            self.assertEqual(result['returncode'], 0)
            self.assertTrue(result['process_group_gone'])
            self.assertIsNone(result['stop_reason'])

    def test_memory_guard_has_no_host_configuration_side_effects(self):
        with mock.patch.object(lab.Path, 'read_text', return_value='MemTotal: 99999 kB\nMemAvailable: 8192000 kB\n'):
            self.assertEqual(lab.memory_available_mib(), 8000)
        with mock.patch.object(lab.Path, 'read_text', return_value='MemTotal: 99999 kB\n'):
            with self.assertRaises(ValueError):
                lab.memory_available_mib()

    def test_host_contract_never_adopts_or_unregisters_distributions(self):
        script = (ROOT / 'scripts/benchmarks/wsl_install_lab.ps1').read_text(encoding='utf-8')
        for required in ('--import', '--version 2', '--terminate $Distribution', 'already exists',
                         'enabled=false', 'source_and_dependency_terms_reviewed', 'CYCLE_INCOMPLETE'):
            self.assertIn(required, script)
        for forbidden in ('--unregister', '--shutdown', 'docker run', 'Set-Content $env:USERPROFILE', 'yes |'):
            self.assertNotIn(forbidden, script)
        self.assertLess(script.index("if ($Action -eq 'Plan')"), script.index('--list --quiet'))
        self.assertIn('not_attempted_cleanup_blocked', script)

class WindowsLauncher(unittest.TestCase):
    @unittest.skipUnless(os.name == 'nt' and PS.is_file(), 'Windows host launcher requires native Windows PowerShell; no WSL fallback')
    def test_powershell_parses_and_plan_never_launches_wsl(self):
        script = ROOT / 'scripts/benchmarks/wsl_install_lab.ps1'
        parse = "$e=$null;$t=$null;[void][System.Management.Automation.Language.Parser]::ParseFile($args[0],[ref]$t,[ref]$e);if($e.Count){$e|% ToString;exit 1}"
        # ParseFile uses an explicit literal path to avoid argument-binding ambiguity in -Command.
        parse = parse.replace('$args[0]', "'" + script.as_posix().replace("'", "''") + "'")
        checked = subprocess.run([str(PS), '-NoProfile', '-NonInteractive', '-Command', parse],
                                 text=True, capture_output=True, timeout=60)
        self.assertEqual(checked.returncode, 0, checked.stdout + checked.stderr)
        result = subprocess.run([str(PS), '-NoProfile', '-NonInteractive', '-File', str(script),
                                 '-Python', sys.executable, '-Action', 'Plan'],
                                text=True, capture_output=True, timeout=60)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(json.loads(result.stdout)['executed'])


if __name__ == '__main__':
    unittest.main()
