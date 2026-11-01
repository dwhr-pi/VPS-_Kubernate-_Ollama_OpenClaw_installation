"""Short entry point and retained historical navigation, without online lookups."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


def headings(text):
    result = []
    fence = False
    for line in text.splitlines():
        if line.lstrip().startswith('```'):
            fence = not fence
        if not fence:
            found = re.match(r'^#{1,6} (.+)$', line)
            if found:
                result.append(found.group(1))
    return result


class PlatformNavigation(unittest.TestCase):
    def test_short_readme_retains_heading_order(self):
        root = (ROOT / 'readme.md').read_text(encoding='utf-8')
        archive = (ROOT / 'docs/legacy/README_FULL_2026_11_01.md').read_text(encoding='utf-8')
        self.assertLess(len(root.splitlines()), 200)
        retained = [re.sub(r'^\[(.*)\]\([^)]*\)$', r'\1', title) for title in headings(root)[1:]]
        self.assertEqual(retained, headings(archive))
        self.assertIn('Historische Referenz', archive)

    def test_new_document_links_resolve(self):
        for relative in ('readme.md', 'docs/P1_P3_IMPLEMENTATION.md'):
            path = ROOT / relative
            text = path.read_text(encoding='utf-8')
            text = re.sub(r'```.*?```', '', text, flags=re.S)
            for target in re.findall(r'\]\(([^)]+)\)', text):
                if '://' not in target and not target.startswith('#'):
                    self.assertTrue((path.parent / target.split('#')[0]).exists(), target)


if __name__ == '__main__':
    unittest.main()
