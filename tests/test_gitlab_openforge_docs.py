"""Offline-Dokumentationstests; keine Quellenabrufe, Installer oder Modellaufrufe."""
from pathlib import Path
import re
import unittest
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / 'docs/tools/gitlab-openforge-mlflow.md'


class GitLabOpenForgeDocs(unittest.TestCase):
    def test_all_requested_sources_are_preserved(self):
        text = DOC.read_text(encoding='utf-8')
        for url in (
            'https://gitlab.com/fordendk/genie-ai-replica',
            'https://gitlab.com/openforge/gridly-scheduler',
            'https://github.com/MasterworkTools/openforge-tutorials',
            'https://github.com/siriknikita/openforge',
            'https://gitlab.com/openforge/agent-runner',
            'https://github.com/mlflow/mlflow',
        ):
            self.assertIn(url, text)

    def test_local_links_resolve_and_catalogs_expose_the_document(self):
        text = DOC.read_text(encoding='utf-8')
        for target in re.findall(r'\]\(([^)]+)\)', text):
            if '://' not in target:
                path = unquote(target.split('#', 1)[0])
                self.assertTrue((DOC.parent / path).is_file(), target)
        for file in ('TOOLS_CATALOG.md', 'START_HERE.md', 'TESTED_STATUS_MATRIX.md'):
            self.assertIn('tools/gitlab-openforge-mlflow.md',
                          (ROOT / 'docs' / file).read_text(encoding='utf-8'))
        self.assertEqual(text.count('```') % 2, 0)

    def test_opt_in_and_unverified_installation_boundaries_are_explicit(self):
        text = DOC.read_text(encoding='utf-8')
        self.assertIn('Installationsstatus: **ungeprueft**', text)
        self.assertIn('Keine automatischen Produktivdeployments, Modell-Downloads', text)
        self.assertIn('Diese Seite aktiviert keine `.gitlab-ci.yml`', text)
        self.assertIn('keinen containerfreien Gesamtbetrieb', text)
        self.assertIn('keinen hier abgenommenen gepinnten GitHub-Source-Build', text)


if __name__ == '__main__':
    unittest.main()
