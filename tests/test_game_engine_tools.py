"""Offline fixtures only; no engine downloads, builds, GUI, XR or user workspace."""
import contextlib
import importlib
import io
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts/tools/helpers'))
G = importlib.import_module('gap_tools')
B = importlib.import_module('game_engine_build')
KEYS = ('godot_source', 'godot_build', 'godot_xr_tools', 'o3de_source', 'lively_wallpaper_source')
DOC = ROOT / 'docs/tools/ai-game-engines-xr-wallpaper.md'


class GameEngineToolsTests(unittest.TestCase):
    def test_registry_menu_status_and_all_lifecycle_scripts(self):
        registry = {t['id']: t for t in json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']}
        setup = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        tracking = (ROOT / 'scripts/helpers/status_tracking.sh').read_text(encoding='utf-8')
        status = (ROOT / 'scripts/helpers/native_tool_status.sh').read_text(encoding='utf-8')
        for key in KEYS:
            spec, entry = G.SPECS[key], registry[key]
            self.assertFalse(entry['auto_install'])
            self.assertEqual(entry['source_commit'], spec['pin'])
            self.assertRegex(spec['pin'], r'^[a-f0-9]{40}$')
            self.assertIn('"' + spec['name'] + '"', setup)
            self.assertIn('"' + spec['name'] + '"', tracking)
            self.assertIn(spec['name'] + ') marker=' + key + '/ready.json', status)
            self.assertEqual(spec['mode'], 'godot-build' if key == 'godot_build' else 'source')
            for action in ('install', 'uninstall', 'update', 'doctor', 'status', 'check'):
                script = ROOT / ('scripts/tools/' + key + '_' + action + '.sh')
                self.assertTrue(script.is_file())
                self.assertIn(key + ' ' + action + ' "$@"', script.read_text(encoding='utf-8'))

    def test_plans_do_not_create_workspace_or_call_git(self):
        with tempfile.TemporaryDirectory() as temp:
            workspace = Path(temp) / 'absent'
            with patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': str(workspace)}), patch.object(G, 'git', side_effect=AssertionError('network')), patch.object(G, 'reserve', side_effect=AssertionError('disk')):
                for key in KEYS:
                    with contextlib.redirect_stdout(io.StringIO()) as output:
                        self.assertEqual(G.main([key, '--dry-run']), 0)
                    self.assertIn('Nur Plan', output.getvalue())
            self.assertFalse(workspace.exists())

    def test_build_opt_in_is_required_before_source_fetch(self):
        with tempfile.TemporaryDirectory() as temp:
            base = Path(temp)
            runtime, marker = base / 'runtime', base / 'ready.json'
            with patch.dict(os.environ, {'INSTALL_HEAVY_TOOLS': '0'}), patch.object(G, 'reserve'), patch.object(G, 'git') as git:
                with self.assertRaisesRegex(ValueError, 'INSTALL_HEAVY_TOOLS'):
                    G.install(runtime, marker, base, G.SPECS['godot_build'])
                git.assert_not_called()
                self.assertFalse(runtime.exists())
                self.assertFalse(marker.exists())

    def test_unsupported_host_and_unbounded_parallelism_are_rejected(self):
        with patch.dict(os.environ, {'INSTALL_HEAVY_TOOLS': '1', 'GODOT_BUILD_JOBS': '1'}), patch.object(B.platform, 'system', return_value='Windows'):
            with self.assertRaisesRegex(ValueError, 'Linux'):
                B.settings()
        with patch.dict(os.environ, {'INSTALL_HEAVY_TOOLS': '1', 'GODOT_BUILD_JOBS': '128'}), patch.object(B.platform, 'system', return_value='Linux'), patch.object(B.platform, 'machine', return_value='x86_64'):
            with self.assertRaisesRegex(ValueError, '1 oder 2'):
                B.settings()

    def fake_git(self, runtime, *args):
        if args[0] == 'init':
            (runtime / '.git').mkdir()
            (runtime / '.git/HEAD').write_text('fixture')
            (runtime / 'README.md').write_text('fixture source, not runtime')
        if args[:2] == ('rev-parse', 'HEAD'):
            return G.SPECS['godot_build']['pin']
        if args[:3] == ('remote', 'get-url', 'origin'):
            return 'https://github.com/godotengine/godot.git'
        return ''

    def test_low_memory_blocks_preflight(self):
        with patch.object(B, 'settings', return_value=('1', 'x86_64')), patch.object(B.Path, 'read_text', return_value='MemAvailable: 1024 kB\n'), patch.object(B.subprocess, 'run') as run:
            with self.assertRaisesRegex(ValueError, '6 GiB'):
                B.preflight()
            run.assert_not_called()

    def test_build_verifies_version_without_gui_or_project(self):
        def compile_fixture(args, runtime, env, **kwargs):
            binary = runtime / 'bin/godot.linuxbsd.editor.x86_64'
            binary.parent.mkdir()
            binary.write_text('mock compiler output')
            binary.chmod(0o755)
            self.assertIn('-j1', args)
            self.assertEqual(kwargs['timeout'], 14400)
        with tempfile.TemporaryDirectory() as temp:
            runtime = Path(temp)
            with patch.object(B, 'settings', return_value=('1', 'x86_64')), patch.object(B.shutil, 'which', return_value='/fixture/scons'), patch('native_build_process.run', side_effect=compile_fixture), patch.object(G, 'run', return_value='4.7.2.stable.fixture') as probe:
                entries = B.build(runtime, {}, G.SPECS['godot_build']['pin'])
                self.assertIn('bin/godot.linuxbsd.editor.x86_64', entries)
                self.assertEqual(probe.call_args.args[0][1:], ['--headless', '--version'])

    def test_failed_build_keeps_no_marker_and_preserves_existing_neighbor(self):
        with tempfile.TemporaryDirectory() as temp:
            base = Path(temp)
            neighbor = base / 'own-project'
            neighbor.write_text('preserve me')
            with patch.object(G, 'reserve'), patch.object(B, 'preflight'), patch.object(G, 'git', side_effect=self.fake_git), patch.object(B, 'build', side_effect=ValueError('fixture build failed')):
                with self.assertRaisesRegex(ValueError, 'fixture build failed'):
                    G.install(base / 'runtime', base / 'ready.json', base, G.SPECS['godot_build'])
            self.assertFalse((base / 'ready.json').exists())
            self.assertFalse((base / 'runtime').exists())
            self.assertEqual(neighbor.read_text(), 'preserve me')

    def test_missing_build_artifact_never_becomes_ready(self):
        with tempfile.TemporaryDirectory() as temp:
            base = Path(temp)
            with patch.object(G, 'reserve'), patch.object(B, 'preflight'), patch.object(G, 'git', side_effect=self.fake_git), patch.object(B, 'build', return_value=['bin/missing']):
                with self.assertRaisesRegex(ValueError, 'Artefakt fehlt'):
                    G.install(base / 'runtime', base / 'ready.json', base, G.SPECS['godot_build'])
            self.assertFalse((base / 'ready.json').exists())

    def test_successful_fixture_build_is_idempotent_and_modified_binary_is_protected(self):
        def build(runtime, env, pin):
            (runtime / 'fake-editor').write_text('fixture binary; not executable')
            return ['fake-editor']
        with tempfile.TemporaryDirectory() as temp:
            base = Path(temp)
            runtime, marker, spec = base / 'runtime', base / 'ready.json', G.SPECS['godot_build']
            with patch.object(G, 'reserve'), patch.object(B, 'preflight'), patch.object(G, 'git', side_effect=self.fake_git), patch.object(B, 'build', side_effect=build) as compiler:
                G.install(runtime, marker, base, spec)
                G.install(runtime, marker, base, spec)
                self.assertEqual(compiler.call_count, 1)
                self.assertFalse(json.loads(marker.read_text())['runtime_tested'])
                (runtime / 'fake-editor').write_text('user modified')
                with self.assertRaises(ValueError):
                    G.validate(runtime, marker, spec, full=True)
                self.assertTrue(runtime.exists())

    def test_documentation_links_limits_and_honest_scope(self):
        text = DOC.read_text(encoding='utf-8')
        for required in ('Valve Index', 'ARCore/ARKit', 'WebGL 2.0', 'C#', '.scr', 'macOS', 'iOS', 'ungeprueft', 'keine fertigen Apps', 'LFS', 'Epic-EULA'):
            self.assertIn(required, text)
        for link in re.findall(r'\]\(([^)]+)\)', text):
            if '://' not in link:
                self.assertTrue((DOC.parent / link.split('#', 1)[0]).is_file(), link)
        self.assertEqual(text.count('```') % 2, 0)
        for file in ('TOOLS_CATALOG.md', 'START_HERE.md', 'TESTED_STATUS_MATRIX.md'):
            self.assertIn('tools/ai-game-engines-xr-wallpaper.md', (ROOT / 'docs' / file).read_text(encoding='utf-8'))


if __name__ == '__main__':
    unittest.main()
