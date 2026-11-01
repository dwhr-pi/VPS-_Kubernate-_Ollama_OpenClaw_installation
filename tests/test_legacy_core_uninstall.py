"""Read-only legacy safety gate, fixture metadata and isolated menu contracts only."""
import ast
import contextlib
import hashlib
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import stat
import subprocess
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    'legacy_core_uninstall_fixture', ROOT / 'scripts/security/legacy_core_uninstall.py')
guard = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(guard)
BASH = ('C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash'))


class LegacyGuard(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        for relative in ('opt/openclaw', 'usr/share/ollama', 'var/lib/ollama',
                         'usr/local/bin', 'etc/systemd/system', 'home/fixture/.openclaw',
                         'home/fixture/.openclaw_ultimate_user_data'):
            (self.root / relative).mkdir(parents=True, exist_ok=True)
        for relative in ('opt/openclaw/.env', 'var/lib/ollama/model',
                         'usr/local/bin/ollama', 'etc/systemd/system/ollama.service',
                         'home/fixture/.openclaw/state',
                         'home/fixture/.openclaw_ultimate_user_data/installed_tools.txt',
                         'home/fixture/.openclaw_ultimate_user_data/autostart.sh'):
            (self.root / relative).write_text('SYNTHETIC FIXTURE - preserve\n')

    def snapshot(self):
        return {p.relative_to(self.root).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
                for p in self.root.rglob('*') if p.is_file() and not p.is_symlink()}

    def invoke(self, tool, *args, environment=None):
        out, err = io.StringIO(), io.StringIO()
        before = self.snapshot()
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err), \
                patch.object(subprocess, 'run', side_effect=AssertionError('No service/process call')):
            rc = guard.main([tool, *args], root=self.root,
                            environment={} if environment is None else environment)
        self.assertEqual(before, self.snapshot())
        return rc, out.getvalue(), err.getvalue()

    def test_both_default_and_explicit_dry_runs_preserve_everything(self):
        for tool in guard.ARTIFACTS:
            for args in ((), ('--dry-run',)):
                with self.subTest(tool=tool, args=args):
                    rc, out, _ = self.invoke(tool, *args)
                    self.assertEqual(rc, guard.PLANNED)
                    self.assertIn('NICHT deinstalliert', out)
                    self.assertIn('"removal_authorized": false', out)

    def test_apply_is_blocked_before_any_metadata_or_service_access(self):
        for tool in guard.ARTIFACTS:
            with patch.object(guard, 'plan', side_effect=AssertionError('No adoption/inspection on apply')):
                rc, _, err = self.invoke(tool, '--apply')
            self.assertEqual(rc, guard.BLOCKED)
            self.assertIn('Besitz-/Migrationsvertrag', err)

    def test_empty_or_absent_installation_is_not_reported_removed(self):
        shutil.rmtree(self.root / 'opt/openclaw')
        rc, out, _ = self.invoke('openclaw')
        self.assertEqual(rc, guard.PLANNED)
        self.assertIn('"state": "absent"', out)

    def test_repeat_and_cancellation_have_no_status_or_file_effects(self):
        for _ in range(3):
            self.assertEqual(self.invoke('openclaw')[0], guard.PLANNED)
            self.assertEqual(self.invoke('openclaw', '--apply')[0], guard.BLOCKED)

    def test_legacy_overrides_and_assume_yes_cannot_enable_actions(self):
        for environment in ({'OPENCLAW_DIR': '/'}, {'OPENCLAW_DIR': '/opt/../etc'},
                            {'OPENCLAW_DIR': 'relative'}, {'OPENCLAW_DIR': '/opt/openclaw/'},
                            {'OPENCLAW_REMOVE_STATE': 'yes'},
                            {'OPENCLAW_UNINSTALL_ASSUME_YES': 'true'},
                            {'OPENCLAW_BACKUP_STATE': 'yes'}):
            with self.subTest(environment=environment):
                self.assertEqual(self.invoke('openclaw', environment=environment)[0], guard.BLOCKED)

    def test_private_environment_values_never_appear_in_diagnostics(self):
        value = 'SYNTHETIC-PRIVATE-DO-NOT-PRINT'
        rc, out, err = self.invoke('openclaw', environment={'OPENCLAW_DIR': value})
        self.assertEqual(rc, guard.BLOCKED)
        self.assertNotIn(value, out + err)

    def test_no_user_workspace_or_home_override_is_inspected(self):
        environment = {'HOME': '/do-not-touch', 'INSTALL_DIR': '/do-not-touch',
                       'OPENCLAW_USER_DATA_DIR': '/do-not-touch'}
        self.assertEqual(self.invoke('ollama', environment=environment)[0], guard.PLANNED)

    def test_missing_marker_does_not_grant_ownership(self):
        row = guard.inspect_artifact(self.root, 'opt/openclaw')
        self.assertEqual(row['marker'], 'missing')
        self.assertEqual(row['ownership'], 'unproven')

    def test_even_a_private_marker_never_authorizes_legacy_deletion(self):
        path = self.root / 'opt/openclaw'
        marker = path / guard.MARKER
        marker.write_text('SYNTHETIC token - not installer provenance')
        path.chmod(0o700)
        marker.chmod(0o600)
        metadata = SimpleNamespace(st_mode=stat.S_IFREG | 0o600, st_uid=path.stat().st_uid,
                                   st_nlink=1)
        original = Path.lstat

        def fake_lstat(item, *args, **kwargs):
            if item == marker:
                return metadata
            if item == path:
                return SimpleNamespace(st_mode=stat.S_IFDIR | 0o700, st_uid=metadata.st_uid)
            return original(item, *args, **kwargs)

        with patch.object(Path, 'lstat', fake_lstat):
            row = guard.inspect_artifact(self.root, 'opt/openclaw')
        self.assertEqual(row['marker'], 'private-but-unverified')
        self.assertEqual(self.invoke('openclaw', '--apply')[0], guard.BLOCKED)

    def test_wrong_owner_or_public_hardlinked_markers_remain_untrusted(self):
        path = self.root / 'opt/openclaw'
        marker = path / guard.MARKER
        marker.write_text('SYNTHETIC')
        expected_uid = path.stat().st_uid
        original = Path.lstat
        for mode, owner, links in ((0o644, expected_uid, 1),
                                  (0o600, expected_uid + 1, 1),
                                  (0o600, expected_uid, 2)):
            def fake_lstat(item, *args, **kwargs):
                if item == marker:
                    return SimpleNamespace(st_mode=stat.S_IFREG | mode, st_uid=owner, st_nlink=links)
                if item == path:
                    return SimpleNamespace(st_mode=stat.S_IFDIR | 0o700, st_uid=expected_uid)
                return original(item, *args, **kwargs)
            with patch.object(Path, 'lstat', fake_lstat):
                self.assertEqual(guard.inspect_artifact(self.root, 'opt/openclaw')['marker'],
                                 'unsafe-preserved')

    def test_payload_and_marker_contents_are_never_opened(self):
        (self.root / 'opt/openclaw' / guard.MARKER).write_text('not JSON, do not read')
        with patch.object(Path, 'read_text', side_effect=AssertionError('No content read')), \
                patch.object(Path, 'read_bytes', side_effect=AssertionError('No content read')):
            self.assertFalse(guard.plan('openclaw', self.root)['removal_authorized'])

    def test_symlink_parent_and_marker_are_preserved_without_following(self):
        outside = self.root / 'outside'
        outside.mkdir()
        (outside / 'keep').write_text('preserve')
        shutil.rmtree(self.root / 'opt/openclaw')
        try:
            (self.root / 'opt/openclaw').symlink_to(outside, target_is_directory=True)
        except OSError:
            if os.name == 'nt':
                self.skipTest('Native symlink privileges unavailable')
            raise
        self.assertEqual(guard.inspect_artifact(self.root, 'opt/openclaw')['state'],
                         'linked-path-preserved')
        (self.root / 'opt/openclaw').unlink()
        (self.root / 'opt/openclaw').mkdir()
        (self.root / 'opt/openclaw' / guard.MARKER).symlink_to(outside / 'keep')
        self.assertEqual(guard.inspect_artifact(self.root, 'opt/openclaw')['marker'],
                         'unsafe-preserved')
        self.assertEqual((outside / 'keep').read_text(), 'preserve')
        (self.root / 'opt/openclaw' / guard.MARKER).unlink()
        (self.root / 'opt/openclaw').rmdir()
        (self.root / 'opt').rmdir()
        (self.root / 'opt').symlink_to(outside, target_is_directory=True)
        self.assertEqual(guard.inspect_artifact(self.root, 'opt/openclaw')['state'],
                         'linked-path-preserved')
        self.assertEqual((outside / 'keep').read_text(), 'preserve')

    def test_root_uid_has_no_special_apply_bypass(self):
        with patch.object(os, 'geteuid', return_value=0, create=True):
            for tool in guard.ARTIFACTS:
                self.assertFalse(guard.plan(tool, self.root)['removal_authorized'])
                self.assertEqual(self.invoke(tool, '--apply')[0], guard.BLOCKED)

    def test_noncanonical_paths_are_rejected(self):
        for relative in ('../etc', '/etc', 'opt/./openclaw', 'opt//openclaw', 'C:/bad', 'opt\\bad'):
            with self.subTest(relative=relative), self.assertRaises(guard.GuardError):
                guard.inspect_artifact(self.root, relative)

    def test_inspection_error_is_not_success_or_a_secret_dump(self):
        with patch.object(guard, 'inspect_artifact', side_effect=PermissionError('PRIVATE FIXTURE')):
            rc, out, err = self.invoke('ollama')
        self.assertEqual(rc, guard.BLOCKED)
        self.assertNotIn('PRIVATE FIXTURE', out + err)

    def test_no_force_or_mutually_conflicting_modes(self):
        for args in (['--force'], ['--apply', '--dry-run'], ['--target', 'PRIVATE-FIXTURE']):
            out = io.StringIO()
            with contextlib.redirect_stderr(out), self.assertRaises(SystemExit) as error:
                guard.main(['ollama', *args], root=self.root, environment={})
            self.assertEqual(error.exception.code, guard.INVALID)
            self.assertNotIn('PRIVATE-FIXTURE', out.getvalue())

    def test_guard_has_no_mutating_or_process_execution_implementation(self):
        tree = ast.parse((ROOT / 'scripts/security/legacy_core_uninstall.py').read_text())
        banned = {'unlink', 'rmtree', 'remove', 'rename', 'replace', 'mkdir', 'chmod',
                  'chown', 'write_text', 'write_bytes', 'open', 'system', 'popen', 'run', 'Popen'}
        for node in ast.walk(tree):
            if isinstance(node, ast.Call):
                name = node.func.attr if isinstance(node.func, ast.Attribute) else getattr(node.func, 'id', '')
                self.assertNotIn(name, banned)

    def test_ubuntu_ci_keeps_the_guard_suite_and_shell_entrypoints(self):
        workflow = (ROOT / '.github/workflows/p0-safety.yml').read_text(encoding='utf-8')
        self.assertIn('runs-on: ubuntu-24.04', workflow)
        self.assertIn('python3 -I -B -m unittest discover -s tests -p test_legacy_core_uninstall.py -v',
                      workflow)
        for tool in ('ollama', 'openclaw'):
            self.assertIn(f'scripts/tools/{tool}_uninstall.sh', workflow)


@unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash required; no WSL fallback')
class LegacyMenu(unittest.TestCase):
    def test_actual_wrappers_forward_arguments_and_return_code_without_tracking(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'scripts/tools').mkdir(parents=True)
            (root / 'scripts/security').mkdir()
            (root / 'bin').mkdir()
            (root / 'scripts/security/legacy_core_uninstall.py').write_text('# Never executed\n')
            shim = root / 'bin/python3'
            shim.write_text('#!/usr/bin/env bash\nprintf "ARG:%s\\n" "$@"\nexit 3\n')
            shim.chmod(0o700)
            for tool in ('ollama', 'openclaw'):
                source = ROOT / f'scripts/tools/{tool}_uninstall.sh'
                target = root / 'scripts/tools' / source.name
                shutil.copyfile(source, target)
                env = dict(os.environ, FIXTURE_ROOT=root.as_posix(), BASH_ENV='',
                           INSTALL_DIR='/must-not-be-used', OPENCLAW_USER_DATA_DIR='/must-not-be-used')
                code = f'cd "$FIXTURE_ROOT"; export PATH="$PWD/bin:$PATH"; bash scripts/tools/{tool}_uninstall.sh --dry-run'
                result = subprocess.run([BASH, '-c', code], env=env, input='',
                                        capture_output=True, text=True, timeout=20)
                self.assertEqual(result.returncode, 3, result.stderr)
                self.assertIn('ARG:-I\nARG:-B\n', result.stdout)
                self.assertIn('/scripts/security/legacy_core_uninstall.py', result.stdout)
                self.assertIn(f'ARG:{tool}\nARG:--dry-run', result.stdout)
                self.assertNotIn('/must-not-be-used', result.stdout)
            (root / 'scripts/security/legacy_core_uninstall.py').unlink()
            result = subprocess.run([BASH, '-c', code], env=env, input='',
                                    capture_output=True, text=True, timeout=20)
            self.assertEqual(result.returncode, 1)
            self.assertNotIn('ARG:', result.stdout)

    def test_real_menu_preserves_status_and_autostart_for_all_guard_results(self):
        text = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        function = text[text.index('uninstall_tool() {'):text.index('\nTOOL_KEYS+=', text.index('uninstall_tool() {'))]
        stubs = r'''
set -euo pipefail
BLUE='' YELLOW='' RED='' GREEN='' NC=''
INSTALL_DIR='/fixture-repo'
TOOL_STATUS_FILE='fixture-status' USER_STATUS_DIR='fixture-dir'
show_tool_action_intro() { printf 'INTRO\n'; }
maybe_cleanup_logs_before_operation() { printf 'LOG-CLEANUP\n'; }
begin_operation_measurement() { printf 'BEGIN\n'; }
end_operation_measurement() { printf 'END:%s\n' "$1"; }
run_tool_script() { printf 'GENERIC-RUN\n'; return "$FIXTURE_RC"; }
bash() { printf 'GUARD:%s:%s\n' "$1" "$2"; return "$FIXTURE_RC"; }
remove_exact_line() { printf 'STATUS-REMOVED\n'; }
remove_tool_from_autostart_script() { printf 'AUTOSTART-REMOVED\n'; }
handle_manual_tool_post_action() { printf 'RESULT:%s\n' "$3"; }
'''
        for tool in ('Ollama', 'OpenClaw', 'OtherFixture'):
            for rc in (0, 1, 2, 3):
                with self.subTest(tool=tool, rc=rc):
                    code = stubs + function + f'\nFIXTURE_RC={rc}\nuninstall_tool {tool}\n'
                    result = subprocess.run([BASH, '-c', code], capture_output=True,
                                            text=True, timeout=20, cwd=ROOT)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    if tool in ('Ollama', 'OpenClaw'):
                        self.assertNotIn('STATUS-REMOVED', result.stdout)
                        self.assertNotIn('AUTOSTART-REMOVED', result.stdout)
                        self.assertIn(f'GUARD:/fixture-repo/scripts/tools/{tool.lower()}_uninstall.sh:--dry-run',
                                      result.stdout)
                        for forbidden in ('LOG-CLEANUP', 'BEGIN', 'END:', 'GENERIC-RUN', 'RESULT:'):
                            self.assertNotIn(forbidden, result.stdout)
                        self.assertIn('nur Vorschau' if rc == 3 else 'nicht freigegeben', result.stdout)
                    elif rc == 0:
                        self.assertIn('GENERIC-RUN', result.stdout)
                        self.assertIn('STATUS-REMOVED', result.stdout)
                        self.assertIn('AUTOSTART-REMOVED', result.stdout)
                    else:
                        self.assertIn('RESULT:failed', result.stdout)

    def test_wrappers_are_isolated_from_tracking_and_dependency_installation(self):
        for tool in ('ollama', 'openclaw'):
            script = ROOT / f'scripts/tools/{tool}_uninstall.sh'
            text = script.read_text(encoding='utf-8')
            self.assertIn('exec python3 -I -B "$HELPER" ' + tool + ' "$@"', text)
            for forbidden in ('sudo', 'rm -', 'systemctl', 'source ', 'init_tool_tracking',
                              'mark_current_tool_removed', 'tar ', '${INSTALL_DIR'):
                self.assertNotIn(forbidden, text)
            result = subprocess.run([BASH, '-n', str(script)], capture_output=True, timeout=20)
            self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
