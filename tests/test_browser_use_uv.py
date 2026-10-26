"""Browser Use private uv integration, no actual downloads or package installs."""
from contextlib import redirect_stdout
import io
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts/tools/helpers'))
import gap_tools as tools
import native_uv as uv


class BrowserUseUvTests(unittest.TestCase):
    def test_bootstrap_contract_and_explicit_consent_forwarded(self):
        with patch.object(tools.platform, 'system', return_value='Linux'), patch.object(tools, 'executable', return_value='python3'), patch.object(tools, 'run') as run, patch.object(uv, 'prepare') as prepare:
            tools.browser_use_prepare(Path('/fixture'), approved=True)
            self.assertIn('(3,11)', run.call_args.args[0][-1])
            prepare.assert_called_once_with(Path('/fixture'),
                {'id': 'browser_use', 'recipe': {'private_uv': '0.13.5', 'disk_mb': 4096}}, approved=True)

    def test_python_failure_prevents_bootstrap(self):
        with patch.object(tools.platform, 'system', return_value='Linux'), patch.object(tools, 'executable', return_value='python3'), patch.object(tools, 'run', side_effect=subprocess.CalledProcessError(1, 'python')), patch.object(uv, 'prepare') as prepare:
            with self.assertRaises(subprocess.CalledProcessError):
                tools.browser_use_prepare(Path('/fixture'), approved=True)
            prepare.assert_not_called()

    def test_missing_uv_without_consent_never_downloads(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(uv.shutil, 'which', return_value=None), patch.object(uv.releases, 'host_key', return_value='linux-amd64'), patch.object(uv.sys.stdin, 'isatty', return_value=False), patch.object(uv.releases, 'download') as download:
            with redirect_stdout(io.StringIO()) as output, self.assertRaisesRegex(ValueError, 'nicht freigegeben'):
                uv.prepare(Path(directory), tools.browser_use_uv_spec())
            self.assertIn('browser_use_install.sh --install-build-deps', output.getvalue())
            self.assertIn('Browser_Use', output.getvalue())
            self.assertEqual(list(Path(directory).iterdir()), [])
            download.assert_not_called()

    def test_dry_run_with_consent_remains_readonly(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': directory}), patch.object(uv, 'prepare') as prepare, patch.object(tools, 'git') as git:
            with redirect_stdout(io.StringIO()):
                self.assertEqual(tools.main(['browser_use', 'install', '--install-build-deps', '--dry-run']), 0)
            self.assertEqual(list(Path(directory).iterdir()), [])
            prepare.assert_not_called()
            git.assert_not_called()

    def test_prerequisite_failure_prevents_checkout_and_ready_marker(self):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            with patch.object(tools, 'reserve'), patch.object(tools, 'browser_use_prepare', side_effect=ValueError('no consent')), patch.object(tools, 'git') as git:
                with self.assertRaisesRegex(ValueError, 'no consent'):
                    tools.install(base / 'runtime', base / 'ready.json', base, tools.SPECS['browser_use'])
            self.assertFalse((base / 'runtime').exists())
            self.assertFalse((base / 'ready.json').exists())
            git.assert_not_called()

    def test_build_uses_absolute_private_uv_not_global_path(self):
        with tempfile.TemporaryDirectory() as directory:
            runtime = Path(directory) / 'runtime'
            runtime.mkdir()
            metadata = runtime / '.venv/lib/python3.12/site-packages/browser_use-1.0.dist-info/METADATA'
            metadata.parent.mkdir(parents=True)
            metadata.write_text('Version: 1.0')
            (runtime / 'uv.lock').write_text('version = 1\n')
            with patch.object(tools.platform, 'system', return_value='Linux'), patch.object(tools, 'executable', side_effect=lambda name: 'python3' if name == 'python3' else self.fail('Global uv must not be required')), patch.object(uv, 'select', return_value='/private/toolchain/uv') as select, patch.object(tools, 'run', return_value='1.0') as run:
                env = {}
                tools.browser_research_build(runtime, env, 'browser-python')
            select.assert_called_once_with(runtime.parent, tools.browser_use_uv_spec())
            command = next(call.args[0] for call in run.call_args_list if 'sync' in call.args[0])
            self.assertEqual(command[0], '/private/toolchain/uv')
            self.assertIn('--frozen', command)
            self.assertEqual(env['UV_PYTHON_DOWNLOADS'], 'never')

    def test_missing_lock_is_created_before_frozen_sync_and_recorded(self):
        for upstream in (False, True):
            with self.subTest(upstream=upstream), tempfile.TemporaryDirectory() as directory:
                runtime = Path(directory)
                lock = runtime / 'uv.lock'
                if upstream:
                    lock.write_text('version = 1\n')
                calls = []
                def run(args, cwd, env):
                    calls.append(list(map(str, args)))
                    if args[1] == 'lock':
                        lock.write_text('version = 1\n')
                    if args[1] == 'sync':
                        self.assertTrue(lock.is_file())
                        self.assertIn('--frozen', args)
                        metadata = runtime / '.venv/lib/python3.12/site-packages/browser_use-1.0.dist-info/METADATA'
                        metadata.parent.mkdir(parents=True)
                        metadata.write_text('Version: 1.0')
                    return '1.0'
                with patch.object(tools.platform, 'system', return_value='Linux'), patch.object(tools, 'executable', return_value='python3'), patch.object(uv, 'select', return_value='/private/uv'), patch.object(tools, 'run', side_effect=run):
                    entries = tools.browser_research_build(runtime, {}, 'browser-python')
                locks = [command for command in calls if command[1] == 'lock']
                self.assertEqual(len(locks), 0 if upstream else 1)
                if not upstream:
                    self.assertEqual(locks[0], ['/private/uv', 'lock', '--no-python-downloads', '--python', 'python3'])
                    self.assertLess(calls.index(locks[0]), next(i for i, command in enumerate(calls) if command[1] == 'sync'))
                self.assertIn('uv.lock', entries)
                self.assertIn('browser-use-dependency-lock.json', entries)
                proof = json.loads((runtime / 'browser-use-dependency-lock.json').read_text())
                self.assertEqual(proof['origin'], 'upstream' if upstream else 'locally-resolved')
                self.assertEqual(proof['sha256'], hashlib.sha256(lock.read_bytes()).hexdigest())
                self.assertEqual(proof['source_pin'], tools.SPECS['browser_use']['pin'])

    def test_failed_or_empty_lock_never_syncs_or_records_success(self):
        for failure in ('missing', 'empty', 'resolver'):
            with self.subTest(failure=failure), tempfile.TemporaryDirectory() as directory:
                runtime = Path(directory)
                calls = []
                def run(args, cwd, env):
                    calls.append(list(args))
                    if args[1] == 'lock':
                        if failure == 'resolver':
                            raise subprocess.CalledProcessError(1, args)
                        if failure == 'empty':
                            (runtime / 'uv.lock').write_text('')
                    return ''
                with patch.object(tools.platform, 'system', return_value='Linux'), patch.object(tools, 'executable', return_value='python3'), patch.object(uv, 'select', return_value='/private/uv'), patch.object(tools, 'run', side_effect=run):
                    with self.assertRaises((ValueError, subprocess.CalledProcessError)):
                        tools.browser_research_build(runtime, {}, 'browser-python')
                self.assertFalse(any('sync' in command for command in calls))
                self.assertFalse((runtime / 'browser-use-dependency-lock.json').exists())

    def test_frozen_sync_cannot_silently_change_lock(self):
        with tempfile.TemporaryDirectory() as directory:
            runtime = Path(directory)
            (runtime / 'uv.lock').write_text('version = 1\n')
            def run(args, cwd, env):
                if args[1] == 'sync':
                    (runtime / 'uv.lock').write_text('changed by fixture')
                return ''
            with patch.object(tools.platform, 'system', return_value='Linux'), patch.object(tools, 'executable', return_value='python3'), patch.object(uv, 'select', return_value='/private/uv'), patch.object(tools, 'run', side_effect=run):
                with self.assertRaisesRegex(ValueError, 'Lock waehrend frozen Sync veraendert'):
                    tools.browser_research_build(runtime, {}, 'browser-python')
            self.assertFalse((runtime / 'browser-use-dependency-lock.json').exists())


if __name__ == '__main__':
    unittest.main()
