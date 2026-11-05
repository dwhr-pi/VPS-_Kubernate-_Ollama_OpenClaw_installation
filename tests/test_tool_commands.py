"""Headless catalog fixtures; never invoke installers or read user workspaces."""
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
SPEC = importlib.util.spec_from_file_location('headless_commands_fixture', ROOT / 'scripts/tool_commands.py')
commands = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(commands)
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')


class Catalog(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'config').mkdir()
        (self.root / 'docs').mkdir()
        (self.root / 'scripts/tools/helpers').mkdir(parents=True)
        (self.root / 'docs/demo.md').write_text('# Demo')
        (self.root / 'scripts/tools/helpers/native_github_tools.py').write_text('# fixture')
        (self.root / 'scripts/tools/demo_install.sh').write_text('# fixture, never execute')
        self.rows = [dict(id='demo', name='Demo', status='experimental', doc='docs/demo.md',
                          install_script='scripts/tools/demo_install.sh'),
                     dict(id='legacy', install_script='missing.sh')]
        self.native = [dict(id='demo', recipe=dict(repo='example/demo', pin='a' * 40, source_host='github.com'), blocked_reason=None)]
        self.save()

    def save(self):
        (self.root / 'config/tools.yml').write_text(json.dumps(dict(tools=self.rows)))
        (self.root / 'config/docker_to_github.json').write_text(json.dumps(dict(tools=self.native)))

    def test_catalog_is_read_only_and_has_every_tool(self):
        with mock.patch.object(commands.subprocess, 'run', side_effect=AssertionError('process')):
            result = commands.catalog(self.root)
        self.assertEqual([r['id'] for r in result], ['demo', 'legacy'])
        self.assertEqual(result[0]['actions']['install']['command'][-2:], ['demo', 'install'])
        self.assertIsNone(result[1]['actions']['install']['command'])
        self.assertIsNone(result[1]['actions']['install']['registered_script'])
        self.assertFalse(result[0]['runtime_verified'])
        (self.root / 'scripts/tools/helpers/native_github_tools.py').unlink()
        missing = commands.one('demo', self.root)
        self.assertEqual(missing['unattended'], 'not-reviewed')
        self.assertIsNone(missing['actions']['install']['command'])

    def test_missing_or_non_github_recipe_and_blockers_do_not_get_execution(self):
        for spec in ({}, dict(recipe={'pin': 'main'}), dict(recipe={'pin': 'a' * 40}, blocked_reason='review required'),
                     dict(recipe={'pin': 'a' * 40, 'source_host': 'codeberg.org'})):
            self.native = [dict(id='demo', **spec)]
            self.save()
            self.assertIsNone(commands.one('demo', self.root)['actions']['install']['command'])

    def test_path_and_argument_injection_and_duplicate_ids_are_rejected(self):
        for path in ('../private', '/etc/passwd', 'scripts/a;evil.sh', 'C:/private', 'scripts/../private'):
            self.assertIsNone(commands.file_in_repo(self.root, path))
        for key in ('demo;false', '$(false)', '../demo'):
            with self.assertRaises(ValueError):
                commands.one(key, self.root)
        self.rows.append(self.rows[0])
        self.save()
        with self.assertRaises(ValueError):
            commands.catalog(self.root)

    def test_writes_need_matching_tool_action_and_apply(self):
        item = commands.one('demo', self.root)
        with mock.patch.object(commands.subprocess, 'run', side_effect=AssertionError('execution')):
            for action in ('install', 'update', 'uninstall'):
                for apply, confirm in ((False, 'demo:' + action), (True, None), (True, 'other:' + action), (True, 'demo:doctor')):
                    with self.assertRaises(ValueError):
                        commands.run(item, action, apply, confirm)

    def test_approved_dispatch_is_argv_only_sanitized_and_preserves_exit(self):
        item = commands.one('demo', self.root)
        with mock.patch.dict(os.environ, {'PYTHONPATH': 'bad', 'BASH_ENV': 'bad', 'API_KEY': 'never-forward', 'SYSTEMROOT': 'C:/Windows'}):
            with mock.patch.object(commands.sys, 'platform', 'linux'), mock.patch.object(commands.subprocess, 'run', return_value=mock.Mock(returncode=7)) as run:
                self.assertEqual(commands.run(item, 'install', True, 'demo:install', True), 7)
        args, kwargs = run.call_args
        self.assertEqual(args[0][-3:], ['demo', 'install', '--install-build-deps'])
        self.assertNotIn('shell', kwargs)
        self.assertIs(kwargs['stdin'], subprocess.DEVNULL)
        for key in ('PYTHONPATH', 'BASH_ENV', 'API_KEY'):
            self.assertNotIn(key, kwargs['env'])
        self.assertEqual(kwargs['env']['SYSTEMROOT'], 'C:/Windows')

    def test_unreviewed_tool_never_executes_even_with_confirmation(self):
        with mock.patch.object(commands.subprocess, 'run', side_effect=AssertionError('execution')):
            with self.assertRaises(ValueError):
                commands.run(commands.one('legacy', self.root), 'install', True, 'legacy:install')

    def test_read_actions_do_not_accept_dependency_bootstrap(self):
        with self.assertRaises(ValueError):
            commands.run(commands.one('demo', self.root), 'doctor', deps=True)

    def test_windows_execution_never_falls_back_to_wsl(self):
        with mock.patch.object(commands.sys, 'platform', 'win32'), mock.patch.object(commands.subprocess, 'run', side_effect=AssertionError('process')):
            with self.assertRaisesRegex(ValueError, 'kein automatischer WSL-Aufruf'):
                commands.run(commands.one('demo', self.root), 'status')

    def test_generated_table_covers_real_registry_and_has_no_drift(self):
        rows = commands.catalog(ROOT)
        self.assertEqual(len(rows), len(json.loads((ROOT / 'config/tools.yml').read_text())['tools']))
        rendered = commands.render(ROOT)
        self.assertEqual((ROOT / commands.TARGET).read_text(encoding='utf-8'), rendered)
        for row in rows:
            self.assertIn('| ' + row['id'] + ' |', rendered)

    def test_default_show_never_runs_a_process(self):
        with mock.patch.object(commands.subprocess, 'run', side_effect=AssertionError('process')):
            with contextlib.redirect_stdout(io.StringIO()) as output:
                self.assertEqual(commands.main(['show', 'searxng']), 0)
        self.assertFalse(json.loads(output.getvalue())['executed'])

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash unavailable; no WSL fallback')
    def test_early_setup_entry_precedes_workspace_and_dialog(self):
        text = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        early = text.split('# Farben & UI', 1)[0]
        self.assertNotIn('load_setup_language', early)
        self.assertNotIn('USER_WORKSPACE_DIR=', early)
        with tempfile.TemporaryDirectory() as directory:
            fixture = Path(directory)
            (fixture / 'bin').mkdir()
            shim = fixture / 'bin/python3'
            shim.write_text('#!/bin/sh\nprintf "spy"\nprintf " <%s>" "$@"\n', encoding='utf-8')
            shim.chmod(0o700)
            entry = fixture / 'entry.sh'
            entry.write_text(early, encoding='utf-8')
            env = dict(os.environ, PATH=str(fixture / 'bin') + os.pathsep + os.environ.get('PATH', ''))
            for option, extra in (('--tools-json', ''), ('--tool-plan', ' searxng')):
                result = subprocess.run([BASH, '--noprofile', '--norc', str(entry), option, *extra.split()],
                                        text=True, capture_output=True, timeout=20, env=env)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('tool_commands.py', result.stdout)
            result = subprocess.run([BASH, '--noprofile', '--norc', str(entry), '--tools-json', 'unsafe'],
                                    text=True, capture_output=True, timeout=20, env=env)
            self.assertEqual(result.returncode, 2)
            self.assertNotIn('spy', result.stdout)


if __name__ == '__main__':
    unittest.main()
