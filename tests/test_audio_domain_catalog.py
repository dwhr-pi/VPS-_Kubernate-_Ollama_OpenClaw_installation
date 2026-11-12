"""Offline source contracts; no third-party execution or model downloads."""
import json
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
EXPECTED = {
    'audile': 'AudileTeam/Audile', 'songrec': 'marin-m/SongRec',
    'mousai': 'SeaDve/Mousai', 'dejavu': 'worldveil/dejavu',
    'qwen3_235b': 'QwenLM/Qwen3', 'qwq_32b': 'QwenLM/QwQ',
    'gpt_oss_120b': 'openai/gpt-oss',
}


class AudioDomainCatalog(unittest.TestCase):
    def test_unique_pinned_source_entries(self):
        rows = json.loads((ROOT / 'config/tools.yml').read_text())['tools']
        specs = json.loads((ROOT / 'scripts/tools/helpers/gap_tools.json').read_text())
        setup = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        for key, repo in EXPECTED.items():
            with self.subTest(key=key):
                row, = [x for x in rows if x['id'] == key]
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
                self.assertIn('TOOL_SCRIPT_NAMES["' + row['name'] + '"]="' + key + '"', setup)
                for action in ('install', 'update', 'uninstall', 'status', 'doctor', 'check'):
                    script = ROOT / ('scripts/tools/' + key + '_' + action + '.sh')
                    text = script.read_text()
                    self.assertIn('gap_tools.py" ' + key + ' ' + action, text)
                    self.assertIn('"$@"', text)
                doc = (ROOT / row['doc']).read_text()
                for marker in ('installed: false', 'runtime_tested: false', '2048 MiB', spec['pin']):
                    self.assertIn(marker, doc)

    def test_existing_deepseek_identity_is_not_duplicated(self):
        rows = json.loads((ROOT / 'config/tools.yml').read_text())['tools']
        self.assertEqual(len([x for x in rows if x['id'] == 'deepseek_r1']), 1)

    def test_platform_and_external_service_boundaries(self):
        for name, marker in [('audile', 'Android'), ('songrec', 'Shazam'),
                             ('mousai', 'AudD'), ('dejavu', 'Referenzdatenbank')]:
            self.assertIn(marker, (ROOT / ('docs/tools/' + name + '.md')).read_text())
        prompt = (ROOT / 'docs/prompts/LEGAL_FINANCIAL_ASSISTANT.md').read_text()
        for marker in ('Jurisdiktion', 'deterministischen', 'menschliche Freigabe', 'keine private interne Gedankenkette'):
            self.assertIn(marker, prompt)

    def test_document_navigation_resolves(self):
        for doc in [ROOT / 'docs/AUDIO_RECOGNITION_AND_DOMAIN_MODELS.md',
                    ROOT / 'docs/prompts/LEGAL_FINANCIAL_ASSISTANT.md']:
            for target in re.findall(r'\]\(([^\s)]+)\)', doc.read_text()):
                if '://' not in target and not target.startswith('#'):
                    self.assertTrue((doc.parent / target.split('#')[0]).is_file(), target)


if __name__ == '__main__':
    unittest.main()
