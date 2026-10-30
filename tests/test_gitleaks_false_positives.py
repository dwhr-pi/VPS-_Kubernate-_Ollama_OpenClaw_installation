"""Only immutable, reviewed fingerprints may be ignored."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class GitleaksExceptions(unittest.TestCase):
    def test_exact_two_immutable_fingerprints_no_wildcards(self):
        lines = (ROOT / '.gitleaksignore').read_text(encoding='utf-8').splitlines()
        entries = [line for line in lines if line and not line.startswith('#')]
        commit = '73307e569f046583030d3435fc0fe4362aebb617'
        self.assertEqual(entries, [
            commit + ':CHANGELOG.md:generic-api-key:658',
            commit + ':scripts/tools/helpers/veo_api_common.sh:generic-api-key:285',
        ])
        self.assertNotIn('*', '\n'.join(entries))
        self.assertFalse((ROOT / '.gitleaks.toml').exists())
        self.assertTrue((ROOT / 'docs/quality/GITLEAKS_FALSE_POSITIVES.md').is_file())


if __name__ == '__main__':
    unittest.main()
