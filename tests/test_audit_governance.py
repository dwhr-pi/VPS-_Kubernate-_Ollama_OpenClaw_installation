"""Offline-Vertraege fuer explizite Lizenzwahl und getrennte Laufzeitdaten."""
import hashlib
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


class AuditGovernance(unittest.TestCase):
    def test_apache_license_is_complete_official_text(self):
        # Canonical ASF LICENSE-2.0.txt, retrieved after the explicit maintainer choice.
        digest = hashlib.sha256((ROOT / 'LICENSE').read_bytes().replace(b'\r\n', b'\n')).hexdigest()
        self.assertEqual(digest, 'cfc7749b96f63bd31c3c42b5c471bf756814053e847c10f3eb003417bc523d30')

    def test_legacy_status_is_ignored_while_runtime_paths_stay_external(self):
        ignored = (ROOT / '.gitignore').read_text().splitlines()
        for name in ('installed_tools.txt', 'installed_profiles.txt'):
            self.assertIn('/' + name, ignored)
        setup = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        self.assertIn('TOOL_STATUS_FILE="$USER_WORKSPACE_DIR/installed_tools.txt"', setup)
        self.assertIn('PROFILE_STATUS_FILE="$USER_WORKSPACE_DIR/installed_profiles.txt"', setup)

    def test_support_wording_does_not_claim_prevention_or_add_license_terms(self):
        readme = (ROOT / 'readme.md').read_text(encoding='utf-8')
        self.assertNotIn('ist das Original vor nicht autorisierten Veraenderungen', readme)
        self.assertIn('keine zusaetzliche Lizenzbedingung', readme)
        self.assertIn('[Apache-2.0](LICENSE)', readme)

    def test_third_party_notice_local_links_exist(self):
        notice = ROOT / 'THIRD_PARTY_NOTICES.md'
        text = notice.read_text(encoding='utf-8')
        for target in re.findall(r'\]\(([^)]+)\)', text):
            if '://' not in target:
                self.assertTrue((notice.parent / target).is_file(), target)
        self.assertIn('kein vollstaendiger SBOM-', text)


if __name__ == '__main__':
    unittest.main()
