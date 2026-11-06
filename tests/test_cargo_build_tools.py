"""Private Cargo prerequisite fixtures; no downloads, compiler, apt or WSL."""
import contextlib
import io
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts/tools/helpers'))
import cargo_build_tools as cli
import litellm_rust as rust
import litellm_rust_bootstrap as bootstrap
import native_github_tools as native
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')


class CargoTools(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.base = Path(temp.name)

    def test_plan_and_install_without_apply_never_inspect_or_create_workspace(self):
        for args, expected in (([], 0), (['plan'], 0), (['install'], 2)):
            out = io.StringIO()
            with mock.patch.object(cli.common, 'paths', side_effect=AssertionError('workspace')), \
                    mock.patch.object(cli.bootstrap, 'prepare', side_effect=AssertionError('download')), \
                    contextlib.redirect_stdout(out):
                self.assertEqual(cli.main(args), expected)
            record = json.loads(out.getvalue())
            self.assertFalse(record['apply'])
            self.assertFalse(record['docker'])
            self.assertEqual(record['reserve_mb'], 6144)

    def test_apply_is_not_allowed_on_read_only_actions(self):
        for action in ('plan', 'doctor', 'status'):
            with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit) as error:
                cli.main([action, '--apply'])
            self.assertEqual(error.exception.code, 2)

    def test_status_and_doctor_never_install_or_create_workspace(self):
        for action, installed, expected in (('status', False, 0), ('doctor', False, 1), ('doctor', True, 0)):
            with mock.patch.object(cli.common, 'paths', return_value=(self.base, None, None)), \
                    mock.patch.object(cli.bootstrap, 'existing', return_value=self.base if installed else None), \
                    mock.patch.object(cli.bootstrap, 'prepare') as prepare, contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(cli.main([action]), expected)
            prepare.assert_not_called()
        self.assertEqual(list(self.base.iterdir()), [])

    def test_install_uses_private_operation_and_explicit_consent(self):
        with mock.patch.object(cli.common, 'paths', return_value=(self.base, None, None)), \
                mock.patch.object(cli.common, 'operation', return_value=contextlib.nullcontext()) as operation, \
                mock.patch.object(cli.bootstrap, 'prepare', return_value=self.base) as prepare, \
                mock.patch.object(cli.os, 'geteuid', return_value=1000, create=True), \
                mock.patch.dict(os.environ, {}, clear=True), contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(cli.main(['install', '--apply']), 0)
        operation.assert_called_once_with(self.base, 'install', tool='Cargo_Build_Tools')
        prepare.assert_called_once_with(self.base, cli.SPEC, approved=True)

    def test_root_and_explicit_foreign_toolchain_never_start_installation(self):
        for uid, explicit in ((0, ''), (1000, '/foreign')):
            with mock.patch.object(cli.common, 'paths', return_value=(self.base, None, None)), \
                    mock.patch.object(cli.common, 'operation') as operation, \
                    mock.patch.object(cli.os, 'geteuid', return_value=uid, create=True), \
                    mock.patch.dict(os.environ, {'NATIVE_SOURCE_RUST_TOOLCHAIN': explicit}, clear=True):
                with self.assertRaises(ValueError):
                    cli.main(['install', '--apply'])
            operation.assert_not_called()

    def test_bootstrap_errors_are_not_success(self):
        with mock.patch.object(cli.common, 'paths', return_value=(self.base, None, None)), \
                mock.patch.object(cli.common, 'operation', return_value=contextlib.nullcontext()), \
                mock.patch.object(cli.bootstrap, 'prepare', side_effect=ValueError('checksum')), \
                mock.patch.object(cli.os, 'geteuid', return_value=1000, create=True), \
                mock.patch.dict(os.environ, {}, clear=True), contextlib.redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, 'checksum'):
                cli.main(['install', '--apply'])

    def test_shared_basis_is_verified_and_explicit_selection_wins(self):
        target = self.base / 'xerj'
        shared = self.base / 'cargo_build_tools'
        shared.mkdir()
        with mock.patch.dict(os.environ, {}, clear=True), \
                mock.patch.object(bootstrap, 'existing', return_value=self.base) as existing:
            self.assertEqual(rust.select(target), self.base)
        existing.assert_called_once_with(shared)
        with mock.patch.dict(os.environ, {'NATIVE_SOURCE_RUST_TOOLCHAIN': str(self.base)}, clear=True), \
                mock.patch.object(rust, 'verify', return_value=self.base) as verify, \
                mock.patch.object(bootstrap, 'existing') as existing:
            self.assertEqual(rust.select(target), self.base)
        verify.assert_called_once_with(self.base, target)
        existing.assert_not_called()

    def test_corrupt_shared_basis_fails_closed(self):
        (self.base / 'cargo_build_tools').mkdir()
        with mock.patch.dict(os.environ, {}, clear=True), \
                mock.patch.object(bootstrap, 'existing', side_effect=ValueError('changed')), \
                mock.patch.object(rust.shutil, 'which') as which:
            with self.assertRaisesRegex(ValueError, 'changed'):
                rust.select(self.base / 'xerj')
        which.assert_not_called()
        target = self.base / 'xerj'
        target.mkdir()
        with mock.patch.dict(os.environ, {}, clear=True), \
                mock.patch.object(bootstrap, 'existing', side_effect=[None, ValueError('changed')]), \
                mock.patch.object(bootstrap, 'download') as download:
            with self.assertRaisesRegex(ValueError, 'changed'):
                bootstrap.prepare(target, {'id': 'xerj', 'recipe': {'disk_mb': 16384}}, approved=True)
        download.assert_not_called()

    def test_xerj_activation_keeps_guards_and_parent_environment(self):
        env = {'PATH': str(self.base / 'guards') + os.pathsep + 'previous'}
        previous = dict(os.environ)
        with mock.patch.object(rust, 'select', return_value=self.base):
            rust.activate(self.base, {'id': 'xerj'}, env)
        self.assertEqual(env['PATH'].split(os.pathsep)[:2], [str(self.base / 'guards'), str(self.base / 'bin')])
        self.assertEqual(env['RUSTUP_AUTO_INSTALL'], '0')
        self.assertEqual(previous, dict(os.environ))

    def test_xerj_plan_never_bootstraps(self):
        with mock.patch.object(native, 'paths', return_value=(self.base, self.base, self.base / 'marker')), \
                mock.patch.object(bootstrap, 'prepare') as prepare, contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(native.main(['xerj', 'plan', '--install-build-deps']), 0)
        prepare.assert_not_called()

    def test_xerj_preflight_checks_private_rust_before_source_build(self):
        spec = {**native.TOOLS['xerj'], 'recipe': {**native.TOOLS['xerj']['recipe'], 'ram_mb': 0}}
        for approved in (False, True):
            with mock.patch.object(native.platform, 'system', return_value='Linux'), \
                    mock.patch.object(native.common, 'reserve'), \
                    mock.patch.object(native.common, 'executable', return_value='fixture') as executable, \
                    mock.patch.object(native.build_deps, 'prepare'), \
                    mock.patch.object(bootstrap, 'prepare') as prepare:
                native.preflight(self.base, spec, install_build_deps=approved)
            prepare.assert_called_once_with(self.base, spec, approved=approved)
            names = [call.args[0] for call in executable.call_args_list]
            self.assertNotIn('cargo', names)
            self.assertNotIn('rustc', names)
            self.assertIn('perl', names)
            self.assertIn('cc', names)

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash unavailable; no WSL fallback')
    def test_actual_wrapper_plan_uses_isolated_python_without_creating_workspace(self):
        target = self.base / 'not-created'
        env = {k: v for k, v in os.environ.items() if k not in ('BASH_ENV', 'ENV', 'SHELLOPTS', 'BASHOPTS')}
        env.update(GAP_TOOLS_PYTHON_BIN=sys.executable, OPENCLAW_USER_DATA_DIR=str(target),
                   PYTHONPATH=str(self.base / 'untrusted-imports'))
        result = subprocess.run([BASH, '--noprofile', '--norc', 'scripts/install_rust_build_tools.sh', 'plan'],
                                cwd=ROOT, capture_output=True, text=True, timeout=30, env=env)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(json.loads(result.stdout)['apply'])
        self.assertFalse(target.exists())

    def test_setup_exposes_separate_opt_in_bootstrap_without_duplicate_cargo_entry(self):
        setup = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        self.assertIn('rust "Cargo + rustc: private Build-Basis erstmals einrichten"', setup)
        self.assertIn('scripts/install_rust_build_tools.sh" install --apply', setup)
        self.assertIn('Gemeinsame Compiler bleiben bei App-Deinstallation erhalten.', setup)
        catalog = json.loads((ROOT / 'config/development_toolchains.json').read_text(encoding='utf-8'))['tools']
        self.assertEqual(sum(row['id'] == 'cargo' for row in catalog), 1)

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash unavailable; no WSL fallback')
    def test_real_setup_menu_cancel_and_approval_use_only_the_selected_action(self):
        setup = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        function = re.search(r'^show_development_toolchain_check\(\) \{\n.*?^\}', setup, re.M | re.S).group()
        for approved in (False, True):
            state = self.base / ('state-' + str(approved))
            trace = self.base / ('trace-' + str(approved))
            script = ('set -euo pipefail\nINSTALL_DIR=/fixture\nAPP_TITLE=fixture\n'
                      'STATE=' + shlex.quote(state.as_posix()) + '\nTRACE=' + shlex.quote(trace.as_posix()) + '\n'
                      'dialog() { case "$*" in *--menu*) if [[ -e "$STATE" ]]; then echo back >&2; '
                      'else printf x > "$STATE"; echo rust >&2; fi ;; *--yesno*) return '
                      + ('0' if approved else '1') + ' ;; *) return 0 ;; esac; }\n'
                      'run_bash_script() { printf "%s\\n" "$*" >> "$TRACE"; printf "{}\\n"; }\n'
                      + function + '\nshow_development_toolchain_check\n')
            env = {k: v for k, v in os.environ.items() if k not in ('BASH_ENV', 'ENV', 'SHELLOPTS', 'BASHOPTS')}
            result = subprocess.run([BASH, '--noprofile', '--norc', '-s'], input=script,
                                    cwd=ROOT, capture_output=True, text=True, timeout=30, env=env)
            self.assertEqual(result.returncode, 0, result.stderr)
            commands = trace.read_text(encoding='utf-8').splitlines()
            expected = ['/fixture/scripts/install_rust_build_tools.sh plan']
            if approved:
                expected.append('/fixture/scripts/install_rust_build_tools.sh install --apply')
            self.assertEqual(commands, expected)


if __name__ == '__main__':
    unittest.main()
