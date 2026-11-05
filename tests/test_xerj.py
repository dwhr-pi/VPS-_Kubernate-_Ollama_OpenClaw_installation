"""XERJ integration contracts with fake artifacts; no build, services or network."""
import contextlib
import copy
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
sys.path.insert(0, str(ROOT / 'scripts/tools/helpers'))
import native_github_tools as native

PIN = '83c9f0d123bac010a25ca2cf02ff093b08ee68ce'
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')


class Xerj(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name).resolve()
        self.addCleanup(mock.patch.stopall)
        mock.patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': str(self.base)}).start()
        self.spec = native.TOOLS['xerj']
        self.outer, self.prefix, self.marker = native.paths('xerj')
        (self.prefix / 'source/engine').mkdir(parents=True)
        self.sysroot = self.base / 'fixture-toolchain'
        self.sysroot.mkdir()
        self.calls = []

    def fake_run(self, args, cwd, env):
        self.calls.append((args, cwd, dict(env)))
        if args == ['rustc', '--print', 'sysroot']:
            return str(self.sysroot)
        if args[:2] == ['cargo', 'build']:
            artifact = cwd / 'target/release' / self.spec['recipe']['binary']
            artifact.parent.mkdir(parents=True)
            artifact.write_text('fake fixture, never executable', encoding='utf-8')
            return ''
        if args == [str(self.prefix / 'bin' / self.spec['recipe']['binary'])] + self.spec['recipe']['probe']:
            return 'fixture version'
        self.fail('Unexpected command: ' + repr(args))

    def test_recipe_is_pinned_locked_opt_in_without_neural_defaults(self):
        recipe = self.spec['recipe']
        self.assertEqual(recipe['pin'], PIN)
        self.assertEqual(recipe['repo'], 'xerj-org/xerj')
        self.assertEqual(recipe['kind'], 'rust')
        self.assertEqual(recipe['module_dir'], 'engine')
        self.assertEqual(recipe['cargo_package'], 'xerj-server')
        self.assertIs(recipe['no_default_features'], True)
        self.assertEqual(recipe['probe'], ['--version'])
        entry = next(row for row in json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools'] if row['id'] == 'xerj')
        self.assertFalse(entry['auto_install'])
        self.assertEqual(entry['readiness'], 'planned')
        self.assertEqual(entry['source_commit'], PIN)
        self.assertEqual(entry['ports'], [])
        self.assertTrue((ROOT / entry['doc']).is_file())
        self.assertEqual(entry['check_value'], '~/.openclaw_ultimate_user_data/tools/xerj/native-github/build-ready.json')

    def test_build_uses_engine_workspace_and_only_version_probe(self):
        with mock.patch.object(native, 'run', side_effect=self.fake_run):
            artifacts = native.build(self.prefix, self.spec)
        self.assertEqual(artifacts, ['bin/xerj'])
        args, cwd, env = self.calls[1]
        self.assertEqual(cwd, self.prefix / 'source/engine')
        self.assertEqual(args, ['cargo', 'build', '--locked', '--release', '--bin', 'xerj',
                                '--package', 'xerj-server', '--no-default-features', '-j', '2'])
        self.assertEqual(env['RUSTUP_TOOLCHAIN'], str(self.sysroot))
        self.assertEqual(env['CARGO_BUILD_JOBS'], '2')
        self.assertEqual(len(self.calls), 3)
        self.assertEqual(self.calls[-1][0][-1], '--version')
        self.assertFalse(self.marker.exists())

    def test_existing_root_rust_recipe_retains_original_command(self):
        self.spec = copy.deepcopy(native.TOOLS['qdrant'])
        with mock.patch.object(native, 'run', side_effect=self.fake_run):
            native.build(self.prefix, self.spec)
        args, cwd, _ = self.calls[1]
        self.assertEqual(cwd, self.prefix / 'source')
        self.assertEqual(args, ['cargo', 'build', '--locked', '--release', '--bin',
                                self.spec['recipe']['binary'], '-j', '2'])

    def test_missing_compiled_binary_fails_without_marker_or_probe(self):
        def no_artifact(args, cwd, env):
            return str(self.sysroot) if args[0] == 'rustc' else ''
        with mock.patch.object(native, 'run', side_effect=no_artifact) as run:
            with self.assertRaises(FileNotFoundError):
                native.build(self.prefix, self.spec)
        self.assertFalse(self.marker.exists())
        self.assertTrue(all(call.args[0][0] in ('rustc', 'cargo') for call in run.call_args_list))

    def test_failed_version_probe_is_not_build_acceptance(self):
        def fail_probe(args, cwd, env):
            if args[-1] == '--version':
                raise ValueError('fixture probe failure')
            return self.fake_run(args, cwd, env)
        with mock.patch.object(native, 'run', side_effect=fail_probe):
            with self.assertRaisesRegex(ValueError, 'fixture probe failure'):
                native.build(self.prefix, self.spec)
        self.assertFalse(self.marker.exists())

    def test_plan_and_status_never_fetch_or_start_programs(self):
        with mock.patch.object(native, 'run', side_effect=AssertionError('process')), \
                mock.patch.object(native.common, 'run', side_effect=AssertionError('process')), \
                mock.patch.object(native.common, 'git', side_effect=AssertionError('git')), \
                contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(native.main(['xerj', 'install', '--dry-run']), 0)
            self.assertEqual(native.main(['xerj', 'status']), 0)
        self.assertFalse(self.marker.exists())

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash unavailable; never start WSL')
    def test_lifecycle_wrappers_parse_without_execution(self):
        env = {'PATH': os.environ.get('PATH', ''), 'BASH_ENV': os.devnull, 'ENV': os.devnull}
        if 'SystemRoot' in os.environ:
            env['SystemRoot'] = os.environ['SystemRoot']
        for action in ('install', 'update', 'uninstall', 'doctor', 'status', 'repair', 'check'):
            path = ROOT / f'scripts/tools/xerj_{action}.sh'
            result = subprocess.run([BASH, '--noprofile', '--norc', '-n', str(path)],
                                    capture_output=True, text=True, env=env, timeout=30)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn(f'native_github_tools.py" xerj {action} "$@"', path.read_text())

    def test_menu_appends_tool_without_changing_frozen_sort_baseline(self):
        menu = (ROOT / 'scripts/helpers/native_github_menu.sh').read_text(encoding='utf-8')
        self.assertIn('NATIVE_GITHUB_TOOL_KEYS+=("XERJ")', menu)
        self.assertNotIn('XERJ', (ROOT / 'config/tool_menu_sorted_baseline.txt').read_text(encoding='utf-8'))
        setup = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        self.assertIn('TOOL_SCRIPT_NAMES["XERJ"]="xerj"', setup)


if __name__ == '__main__':
    unittest.main()
