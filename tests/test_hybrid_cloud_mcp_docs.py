"""Offline documentation contracts; no models, services, credentials or provider requests."""
from pathlib import Path
import re
import unittest
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[1]
CHAPTER = ROOT / 'docs/HYBRID_CLOUD_MCP.md'


class HybridCloudDocumentation(unittest.TestCase):
    def setUp(self):
        self.text = CHAPTER.read_text(encoding='utf-8')

    def test_chapter_separates_candidates_from_installed_runtimes(self):
        for phrase in ('documentation-first', 'nicht installiert', 'Runtime nicht verifiziert',
                       'kein Docker-Fallback', 'keine fertigen Runtime-Installationen'):
            self.assertIn(phrase, self.text)
        self.assertNotRegex(self.text, r'(?im)^\s*(?:docker\s+(?:run|compose)|curl\b[^\n]*\|\s*(?:ba)?sh)')

    def test_minimax_has_license_and_hardware_boundaries(self):
        for phrase in ('428 Milliarden', '23 Milliarden', 'MiniMax Community License',
                       '1 Million', '199 GiB', 'Rohgewichte', 'nicht automatisch uneingeschraenkt Open Source'):
            self.assertIn(phrase, self.text)
        self.assertEqual(round(428e9 * 4 / 8 / 2**30), 199)
        self.assertIn('kein freigegebener Voll-GPU-Standard', self.text)
        self.assertIn('SHA256 jeder Datei', self.text)
        self.assertIn('trust_remote_code=True', self.text)

    def test_obot_has_source_license_and_operational_caveats(self):
        for phrase in ('100 Nutzern', '100 verwalteten Geraeten', 'PostgreSQL 17+',
                       'keine OAuth-Zertifizierung', 'kein freigegebenes natives Produktions-Buildrezept'):
            self.assertIn(phrase, self.text)
        pins = re.findall(r'https://github\.com/obot-platform/obot/(?:tree|blob)/([a-f0-9]{40})', self.text)
        self.assertEqual(set(pins), {'251f96eb1ddae99d61e78a15b7a96115fc45630b'})
        self.assertGreaterEqual(len(pins), 3)
        self.assertIn('Lizenzkeys', self.text)
        self.assertIn('Air-Gap', self.text)

    def test_together_is_paid_and_requires_explicit_cloud_approval(self):
        for phrase in ('paid-prepaid', '15 USD', '5 USD', 'kein allgemeines kostenloses',
                       'Cloud-Fallback standardmaessig aus', 'Human Approval',
                       'Organisationsbezogenes ZDR', 'Passthrough'):
            self.assertIn(phrase, self.text)
        self.assertIn('nicht heimlich umleiten', self.text)
        self.assertIn('nicht einschalten', self.text)
        self.assertIn('nicht, dass Together dieses konkrete Modell', self.text)

    def test_external_citations_are_specific_https_sources_without_credentials(self):
        urls = re.findall(r'\]\((https?://[^\s)]+)\)', self.text)
        self.assertGreaterEqual(len(urls), 9)
        for url in urls:
            parsed = urlsplit(url)
            self.assertEqual(parsed.scheme, 'https')
            self.assertIsNone(parsed.username)
            self.assertIsNone(parsed.password)
            self.assertIn(parsed.hostname, {'huggingface.co', 'www.minimax.io', 'github.com',
                                           'docs.obot.ai', 'docs.together.ai'})
        self.assertIn('https://docs.together.ai/docs/billing-credits', urls)
        self.assertIn('https://docs.together.ai/docs/privacy-and-security', urls)

    def test_local_navigation_targets_exist(self):
        for target in re.findall(r'\]\(([^\s)]+)\)', self.text):
            if urlsplit(target).scheme or target.startswith('#'):
                continue
            self.assertTrue((CHAPTER.parent / target.split('#')[0]).is_file(), target)

    def test_existing_guides_link_the_chapter_without_replacing_history(self):
        for file in ('docs/readme.md', 'docs/MCP_SERVER_HUB.md',
                     'docs/_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md'):
            self.assertIn('HYBRID_CLOUD_MCP.md', (ROOT / file).read_text(encoding='utf-8'))
        tiers = (ROOT / 'docs/_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md').read_text(encoding='utf-8')
        self.assertIn('reviews/2026-11-09.md', tiers)
        self.assertIn('Keine neue Vollpruefung', tiers)


if __name__ == '__main__':
    unittest.main()
