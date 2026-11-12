"""Offline catalog and unreleased-entry fixtures; no third-party builds or model calls."""
from contextlib import redirect_stdout
import importlib.util
import io
import json
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('unreleased_fixture', ROOT / 'scripts/tools/helpers/unreleased_research.py')
guard = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(guard)
EXPECTED = {'levo_2': 'levo-demo/LeVo', 'moss_music': 'OpenMOSS/MOSS-Music',
            'poelm': 'aitorormazabal/poetry_generation', 'poetone': 'ZhanQu945/PoeTone',
            'copoet': 'vishakhpk/creative-instructions',
            'ctgs': 'Hellisotherpeople/Constrained-Text-Generation-Studio'}


class MusicResearchCatalog(unittest.TestCase):
    def test_each_verified_project_is_unique_pinned_and_source_only(self):
        rows = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        specs = json.loads((ROOT / 'scripts/tools/helpers/gap_tools.json').read_text())
        for key, repo in EXPECTED.items():
            row, = [row for row in rows if row['id'] == key]
            spec = specs[key]
            self.assertEqual(spec['repo'], repo)
            self.assertEqual(row['source'], 'https://github.com/' + repo + '.git')
            self.assertEqual(row['source_commit'], spec['pin'])
            self.assertRegex(spec['pin'], r'^[a-f0-9]{40}$')
            self.assertEqual(spec['mode'], 'source')
            self.assertTrue(spec['source_status_only'])
            self.assertFalse(row['auto_install'])
            self.assertEqual(row['readiness'], 'planned')
            self.assertEqual(row['ports'], [])
            for digest in spec['contracts'].values():
                self.assertRegex(digest, r'^[a-f0-9]{64}$')
            self.assertTrue((ROOT / row['doc']).is_file())

    def test_songsage_cannot_report_a_successful_install(self):
        for action in ('install', 'update', 'doctor', 'check'):
            with self.subTest(action=action), redirect_stdout(io.StringIO()) as out:
                self.assertEqual(guard.main(['songsage', action]), 3)
            state = json.loads(out.getvalue())
            for key in ('installed', 'source_prepared', 'runtime_tested', 'performed'):
                self.assertFalse(state[key])
        for action in ('plan', 'status', 'uninstall'):
            with redirect_stdout(io.StringIO()) as out:
                self.assertEqual(guard.main(['songsage', action]), 0)
            self.assertFalse(json.loads(out.getvalue())['performed'])
        with redirect_stdout(io.StringIO()):
            self.assertEqual(guard.main(['songsage', 'install', '--dry-run']), 0)

    def test_songsage_source_is_not_a_guessed_same_named_repository(self):
        row, = [r for r in json.loads((ROOT / 'config/tools.yml').read_text())['tools'] if r['id'] == 'songsage']
        self.assertEqual(row['source'], 'https://arxiv.org/abs/2601.01153')
        self.assertNotIn('source_commit', row)
        text = (ROOT / row['doc']).read_text(encoding='utf-8')
        self.assertIn('nicht ein gleichnamiger', text)
        self.assertIn('Exit 3', text)
        self.assertIn('nicht bestaetigt', text)

    def test_musicgen_keeps_its_registry_identity_without_dispatching_legacy(self):
        row, = [r for r in json.loads((ROOT / 'config/tools.yml').read_text())['tools'] if r['id'] == 'musicgen']
        self.assertEqual(row['name'], 'MusicGen')
        self.assertEqual(row['install_script'], 'scripts/tools/musicgen_source_install.sh')
        self.assertEqual(row['source_commit'], '72cb16f9fb239e9cf03f7bd997198c7d7a67a01c')
        setup = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        self.assertIn('TOOL_SCRIPT_NAMES["MusicGen"]="musicgen_source"', setup)
        self.assertTrue((ROOT / 'scripts/tools/musicgen_install.sh').is_file())
        doc = (ROOT / row['doc']).read_text(encoding='utf-8')
        self.assertIn('Legacy', doc)
        self.assertIn('CC-BY-NC-4.0', doc)

    def test_licenses_and_runtime_limits_are_not_replaced_by_open_source_claims(self):
        for name in ('poelm', 'poetone'):
            self.assertIn('Keine Root-LICENSE', (ROOT / f'docs/tools/{name}.md').read_text())
        self.assertIn('schliesst kommerzielle', (ROOT / 'docs/tools/levo-2.md').read_text())
        moss = (ROOT / 'docs/tools/moss-music.md').read_text()
        self.assertIn('Kein Songgenerator', moss)
        self.assertIn('keine separate Code-LICENSE', moss)
        ctgs = (ROOT / 'docs/tools/ctgs.md').read_text()
        self.assertIn('FastText', ctgs)
        self.assertIn('nicht automatisch phonetisch', ctgs)

    def test_catalog_local_navigation_is_complete(self):
        doc = ROOT / 'docs/MUSIC_LYRICS_MODEL_CATALOG.md'
        text = doc.read_text(encoding='utf-8')
        for name in ('YuE', 'LeVo', 'ACE-Step', 'MusicGen', 'MOSS-Music', 'SongSage',
                     'PoeLM', 'PoeTone', 'CoPoet', 'CTGS', 'Outlines', 'Logit Bias'):
            self.assertIn(name, text)
        for target in re.findall(r'\]\(([^\s)]+)\)', text):
            if '://' not in target and not target.startswith('#'):
                self.assertTrue((doc.parent / target.split('#')[0]).is_file(), target)


if __name__ == '__main__':
    unittest.main()
