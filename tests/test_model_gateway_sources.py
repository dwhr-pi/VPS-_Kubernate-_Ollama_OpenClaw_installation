"""Offline source lifecycle fixtures; no upstream checkout, compiler, API or service."""
from contextlib import redirect_stdout
import hashlib
import io
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts/tools/helpers'))
import gap_tools as tool

KEYS = ('minimax_m3', 'obot', 'deepseek_r1', 'qwen_coder', 'outlines', 'espeak_ng')


class SourceLifecycle(unittest.TestCase):
    def fixture_spec(self, key):
        return dict(tool.SPECS[key], contracts={
            'README.md': hashlib.sha256(b'fixture source\n').hexdigest()})

    def fake_git(self, directory, *args):
        directory = Path(directory)
        if args[0] == 'init':
            (directory / '.git').mkdir()
            (directory / '.git/HEAD').write_bytes(b'fixture head\n')
            (directory / 'README.md').write_bytes(b'fixture source\n')
        if args[:2] == ('rev-parse', 'HEAD'):
            return self.spec['pin']
        if args[:3] == ('remote', 'get-url', 'origin'):
            return 'https://github.com/' + self.spec['repo'] + '.git'
        return ''

    def test_plan_and_missing_status_never_create_or_fetch(self):
        with tempfile.TemporaryDirectory() as temporary, patch.dict(os.environ, {
                'OPENCLAW_USER_DATA_DIR': temporary}), patch.object(tool, 'git') as git:
            for key in KEYS:
                for action in ('plan', 'status', 'doctor'):
                    with redirect_stdout(io.StringIO()) as output:
                        code = tool.main([key, action])
                    self.assertEqual(code, 1 if action == 'doctor' else 0)
                    if action != 'plan':
                        state = json.loads(output.getvalue())
                        self.assertFalse(state['installed'])
                        self.assertFalse(state['source_prepared'])
                        self.assertFalse(state['runtime_tested'])
            git.assert_not_called()
            self.assertEqual(list(Path(temporary).iterdir()), [])

    def test_source_install_status_update_and_idempotent_uninstall(self):
        for key in KEYS:
            with self.subTest(key=key), tempfile.TemporaryDirectory() as temporary, patch.dict(
                    os.environ, {'OPENCLAW_USER_DATA_DIR': temporary}):
                self.spec = self.fixture_spec(key)
                with patch.dict(tool.SPECS, {key: self.spec}), patch.object(tool, 'git',
                        side_effect=self.fake_git), patch.object(tool, 'reserve'), redirect_stdout(io.StringIO()):
                    self.assertEqual(tool.main([key, 'install']), 0)
                    base, runtime, marker = tool.paths(key)
                    first = marker.read_bytes()
                    record = json.loads(first)
                    self.assertFalse(record['installed'])
                    self.assertTrue(record['source_prepared'])
                    self.assertEqual(tool.main([key, 'doctor']), 0)
                    with redirect_stdout(io.StringIO()) as output:
                        self.assertEqual(tool.main([key, 'status']), 0)
                    self.assertEqual(json.loads(output.getvalue()), dict(installed=False,
                        source_prepared=True, runtime_tested=False, scope='source'))
                    self.assertEqual(tool.main([key, 'update']), 0)
                    self.assertEqual(marker.read_bytes(), first)
                    (base / 'keep-user-data.txt').write_text('keep')
                    self.assertEqual(tool.main([key, 'uninstall']), 0)
                    self.assertEqual(tool.main([key, 'uninstall']), 0)
                    self.assertFalse(runtime.exists())
                    self.assertFalse(marker.exists())
                    self.assertEqual((base / 'keep-user-data.txt').read_text(), 'keep')

    def test_manifest_contract_cannot_be_overridden_by_changed_marker(self):
        with tempfile.TemporaryDirectory() as temporary:
            base = Path(temporary)
            runtime, marker = base / 'runtime', base / 'ready.json'
            self.spec = self.fixture_spec('obot')
            with patch.object(tool, 'git', side_effect=self.fake_git), patch.object(tool, 'reserve'), redirect_stdout(io.StringIO()):
                tool.install(runtime, marker, base, self.spec)
                (runtime / 'README.md').write_bytes(b'tampered')
                record = json.loads(marker.read_text())
                record['files'] = tool.inventory(runtime)
                marker.write_text(json.dumps(record))
                with self.assertRaisesRegex(ValueError, 'Quellvertrag'):
                    tool.validate(runtime, marker, self.spec, full=True)
                self.assertTrue(runtime.is_dir())

    def test_failed_contract_rolls_back_only_new_runtime(self):
        with tempfile.TemporaryDirectory() as temporary:
            base = Path(temporary)
            runtime, marker = base / 'runtime', base / 'ready.json'
            (base / 'keep.txt').write_text('keep')
            self.spec = self.fixture_spec('obot')
            self.spec['contracts'] = {'README.md': '0' * 64}
            with patch.object(tool, 'git', side_effect=self.fake_git), patch.object(tool, 'reserve'), redirect_stdout(io.StringIO()):
                with self.assertRaisesRegex(ValueError, 'Quellvertrag'):
                    tool.install(runtime, marker, base, self.spec)
            self.assertFalse(runtime.exists())
            self.assertFalse(marker.exists())
            self.assertEqual((base / 'keep.txt').read_text(), 'keep')

    def test_unsafe_contract_paths_and_unmanaged_directories_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            runtime = Path(temporary)
            for name in ('../outside', '/outside', 'C:/outside', 'a\\b'):
                with self.subTest(name=name), self.assertRaisesRegex(ValueError, 'Unsicherer'):
                    tool.source_contracts(runtime, {'contracts': {name: '0' * 64}})
            (runtime / 'keep').write_text('keep')
            with self.assertRaisesRegex(ValueError, 'Besitznachweis'):
                tool.install(runtime, runtime.parent / 'absent-marker.json', runtime.parent,
                             self.fixture_spec('obot'))
            self.assertTrue((runtime / 'keep').exists())

    def test_registry_has_only_pinned_opt_in_source_entries(self):
        registry = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        for key in KEYS:
            spec = tool.SPECS[key]
            row, = [row for row in registry if row['id'] == key]
            self.assertEqual(row['source_commit'], spec['pin'])
            self.assertEqual(row['readiness'], 'planned')
            self.assertFalse(row['auto_install'])
            self.assertEqual(row['ports'], [])
            self.assertEqual(spec['mode'], 'source')
            self.assertTrue(spec['source_status_only'])
            for digest in spec['contracts'].values():
                self.assertRegex(digest, r'^[a-f0-9]{64}$')
            doc = (ROOT / row['doc']).read_text(encoding='utf-8')
            self.assertIn('runtime_tested: false', doc)
            self.assertIn('source_prepared', doc)

    def test_provider_docs_keep_cloud_and_local_sources_separate(self):
        folder = ROOT / 'docs/_API-Keys/OnlineOnKeyServices'
        for name, key in (('minimax', 'MINIMAX_API_KEY'), ('deepseek', 'DEEPSEEK_API_KEY'),
                          ('ltx', 'LTXV_API_KEY'), ('together', 'TOGETHER_API_KEY')):
            text = (folder / (name + '.md')).read_text(encoding='utf-8')
            self.assertIn(key, text)
            self.assertIn('11.11.2026', text)
            self.assertIn(name + '.md', (folder.parent / 'README.md').read_text(encoding='utf-8'))
        self.assertIn('Lightricks', (ROOT / 'docs/tools/ltx-video.md').read_text())
        deepseek = (ROOT / 'docs/tools/deepseek-r1.md').read_text(encoding='utf-8')
        self.assertIn('MIT', deepseek)
        self.assertIn('Basismodells', deepseek)


if __name__ == '__main__':
    unittest.main()
