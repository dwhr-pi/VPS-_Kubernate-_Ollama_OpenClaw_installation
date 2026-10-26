"""Offline browser/research tool wiring; never opens a browser or calls an API."""
from contextlib import redirect_stdout
import io
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts/tools/helpers'))
import gap_tools as tools
import native_uv
import native_node_npm
import perplexity_sdk_tools

NAMES = {'comet': 'Comet', 'browseros': 'BrowserOS', 'enki_browser': 'Enki_Browser',
         'browser_use': 'Browser_Use', 'perplexity_mcp': 'Perplexity_MCP',
         'perplexity_python': 'Perplexity_Python', 'perplexity_node': 'Perplexity_Node',
         'perplexity_cookbook': 'Perplexity_API_Cookbook'}
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')


class BrowserResearchTests(unittest.TestCase):
    def test_all_entries_have_lifecycle_menu_registry_and_documentation(self):
        registry = json.loads((ROOT / 'config/tools.yml').read_text())['tools']
        menu = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        status = (ROOT / 'scripts/helpers/status_tracking.sh').read_text(encoding='utf-8')
        for key, name in NAMES.items():
            entry, = [item for item in registry if item['id'] == key]
            self.assertEqual(entry['name'], name)
            self.assertFalse(entry['auto_install'])
            self.assertIn('TOOL_SCRIPT_NAMES["' + name + '"]="' + key + '"', menu)
            self.assertIn('"' + name + '"', status)
            self.assertTrue((ROOT / entry['doc']).is_file())
            for action in ('install', 'update', 'uninstall', 'status', 'check', 'doctor'):
                self.assertTrue((ROOT / 'scripts/tools' / (key + '_' + action + '.sh')).is_file())
            if key in tools.SPECS:
                self.assertEqual(entry['source_commit'], tools.SPECS[key]['pin'])
                self.assertRegex(entry['source_commit'], r'^[0-9a-f]{40}$')

    def test_plans_and_status_have_no_network_or_mutation(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': directory}), patch.object(tools, 'run') as run, patch.object(tools, 'git') as git:
            for key in NAMES.keys() & tools.SPECS.keys():
                with redirect_stdout(io.StringIO()):
                    self.assertEqual(tools.main([key, 'install', '--dry-run']), 0)
                    self.assertEqual(tools.main([key, 'status']), 0)
            self.assertEqual(list(Path(directory).iterdir()), [])
            run.assert_not_called()
            git.assert_not_called()

    def test_mcp_build_only_installs_and_syntax_checks(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(tools.platform, 'system', return_value='Linux'), patch.object(tools, 'executable', side_effect=lambda x: x), patch.object(tools, 'node_command', return_value=['npm']):
            calls = []
            def run(args, cwd, env):
                calls.append(args)
                return 'v22.23.4' if args[-1] == '--version' else ''
            with patch.object(tools, 'run', side_effect=run), patch.object(native_node_npm, 'activate'), patch.object(tools.shutil, 'which', side_effect=lambda name, **kwargs: name):
                entries = tools.browser_research_build(Path(directory), {}, 'perplexity-mcp')
            self.assertIn('dist/index.js', entries)
            self.assertIn(['npm', 'ci', '--ignore-scripts', '--no-audit', '--no-fund'], calls)
            self.assertIn(['npm', 'run', 'build'], calls)
            self.assertIn(['node', '--check', 'dist/index.js'], calls)
            self.assertNotIn(['npm', 'start'], calls)

    def test_sdk_bazel_missing_is_actionable_not_a_fake_success(self):
        with patch.object(tools.platform, 'system', return_value='Linux'), patch.object(perplexity_sdk_tools, 'activate', side_effect=ValueError('bazel fehlt')):
            with self.assertRaisesRegex(ValueError, 'bazel fehlt'):
                tools.browser_research_build(Path('/fixture'), {}, 'perplexity-python')

    def test_python_and_node_build_contracts_with_fixture_artifacts(self):
        for mode in ('browser-python', 'perplexity-python', 'perplexity-node'):
            with self.subTest(mode=mode), tempfile.TemporaryDirectory() as directory:
                runtime = Path(directory)
                calls = []
                def run(args, cwd, env):
                    args = list(map(str, args))
                    calls.append(args)
                    if args[:2] == ['uv', 'lock']:
                        (runtime / 'uv.lock').write_text('version = 1\n')
                    if args[-1] == '--version':
                        return {'bazel': 'bazel 9.2.0', 'node': 'v26.0.0', 'pnpm': '11.17.0'}.get(args[0], '')
                    if args[-1] == '//:wheel':
                        (runtime / 'bazel-bin').mkdir()
                        (runtime / 'bazel-bin/perplexityai-fixture.whl').write_bytes(b'fixture')
                    if args[-1] == '//:pkg':
                        built = runtime / 'bazel-bin/package'
                        (built / 'dist').mkdir(parents=True)
                        (built / 'package.json').write_text('{}')
                        (built / 'dist/index.js').write_text('export default {};')
                    if args[:2] == ['uv', 'sync'] or args[:3] == ['uv', 'pip', 'install']:
                        dist = 'browser_use' if mode == 'browser-python' else 'perplexityai'
                        metadata = runtime / '.venv/lib/python3.12/site-packages' / (dist + '-1.0.dist-info')
                        metadata.mkdir(parents=True)
                        (metadata / 'METADATA').write_text('Version: 1.0')
                    return ''
                with patch.object(tools.platform, 'system', return_value='Linux'), patch.object(tools, 'executable', side_effect=lambda x: x), patch.object(tools, 'run', side_effect=run), patch.object(native_uv, 'select', return_value='uv'), patch.object(perplexity_sdk_tools, 'activate', return_value={'bazel': 'bazel', 'node': 'node', 'pnpm': 'pnpm'}):
                    entries = tools.browser_research_build(runtime, {}, mode)
                self.assertTrue(entries)
                if mode == 'browser-python':
                    self.assertTrue(any('--frozen' in command for command in calls))
                    self.assertTrue(any('--no-python-downloads' in command for command in calls))
                    self.assertIn('uv.lock', entries)
                    self.assertLess(next(i for i, command in enumerate(calls) if command[:2] == ['uv', 'lock']),
                                    next(i for i, command in enumerate(calls) if command[:2] == ['uv', 'sync']))
                    proof = json.loads((runtime / 'browser-use-dependency-lock.json').read_text())
                    self.assertEqual(proof['origin'], 'locally-resolved')
                else:
                    self.assertTrue(any('--batch' in command for command in calls))
                    build = next(command for command in calls if '--batch' in command)
                    output_root = Path(next(arg.split('=', 1)[1] for arg in build if arg.startswith('--output_user_root=')))
                    repo_cache = Path(next(arg.split('=', 1)[1] for arg in build if arg.startswith('--repo_contents_cache=')))
                    self.assertFalse(output_root.is_relative_to(runtime))
                    self.assertFalse(repo_cache.is_relative_to(runtime))
                    self.assertEqual(output_root.parent, repo_cache.parent)
                    self.assertFalse(output_root.parent.exists())
                self.assertFalse(any('start' in command or 'serve' in command for command in calls))

    @unittest.skipUnless(BASH, 'Bash unavailable')
    def test_desktop_wait_confirmation_and_skip_without_opening_browser(self):
        helper = (ROOT / 'scripts/tools/helpers/browser_desktop_common.sh').as_posix()
        command = 'source "' + helper + '"; browser_desktop_can_prompt() { return 0; }; browser_desktop_main comet install'
        accepted = subprocess.run([BASH, '-c', command], input='n\n\nj\n', capture_output=True, text=True, timeout=20)
        self.assertEqual(accepted.returncode, 0, accepted.stderr)
        self.assertIn('Setup pausiert', accepted.stdout)
        self.assertIn('technisch nicht verifiziert', accepted.stdout)
        skipped = subprocess.run([BASH, '-c', command], input='n\n\n\n', capture_output=True, text=True, timeout=20)
        self.assertEqual(skipped.returncode, 3, skipped.stderr)
        self.assertIn('Kein Installationsfehler', skipped.stdout)

    @unittest.skipUnless(BASH, 'Bash unavailable')
    def test_desktop_plan_and_noninteractive_skip(self):
        for key in ('comet', 'browseros', 'enki_browser'):
            script = (ROOT / 'scripts/tools' / (key + '_install.sh')).as_posix()
            plan = subprocess.run([BASH, script, '--dry-run'], input='', capture_output=True, text=True, timeout=20)
            self.assertEqual(plan.returncode, 0, plan.stderr)
            self.assertFalse(json.loads(plan.stdout)['installed'])
            pending = subprocess.run([BASH, script], input='', capture_output=True, text=True, timeout=20)
            self.assertEqual(pending.returncode, 3, pending.stderr)
            self.assertIn('Kein Download', pending.stdout)

    def test_manual_wait_and_source_exception_are_explicit(self):
        helper = (ROOT / 'scripts/tools/helpers/browser_desktop_common.sh').read_text()
        self.assertIn('Setup pausiert', helper)
        self.assertIn('Installation/Aktualisierung erfolgreich abgeschlossen?', helper)
        self.assertNotIn('curl ', helper)
        self.assertNotIn('--no-sandbox', helper)
        menu = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        self.assertIn('user-requested-official-comet-download', menu)
        self.assertIn('^(Comet|BrowserOS|Enki_Browser)$', menu)


if __name__ == '__main__':
    unittest.main()
