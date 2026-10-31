"""Offline documentation navigation checks, without reading private workspaces."""
from pathlib import Path
import os
import re
import shutil
import subprocess
import unittest
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parents[1]
DOCUMENTS = ('docs/readme.md', 'docs/agents/CODING_AGENTS_ACCEPTANCE.md')
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')


class DocsNavigation(unittest.TestCase):
    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash unavailable; never invoke WSL')
    def test_bash_examples_parse_without_execution(self):
        guide = (ROOT / DOCUMENTS[1]).read_text(encoding='utf-8')
        code = '\n'.join(re.findall(r'```bash\n(.*?)```', guide, re.S))
        env = {'PATH': os.environ.get('PATH', ''), 'BASH_ENV': os.devnull, 'ENV': os.devnull}
        if 'SystemRoot' in os.environ:
            env['SystemRoot'] = os.environ['SystemRoot']
        result = subprocess.run([BASH, '--noprofile', '--norc', '-n'], input=code,
                                text=True, capture_output=True, timeout=30, env=env)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_relative_links_resolve_inside_repository(self):
        for name in DOCUMENTS:
            document = ROOT / name
            text = document.read_text(encoding='utf-8')
            for link in re.findall(r'\]\(([^\s)]+)\)', text):
                if '://' in link or link.startswith(('#', 'mailto:')):
                    continue
                target = (document.parent / unquote(link.split('#')[0])).resolve()
                with self.subTest(document=name, link=link):
                    self.assertTrue(target.is_relative_to(ROOT))
                    self.assertTrue(target.exists())

    def test_code_fences_and_root_entry_link(self):
        for name in DOCUMENTS:
            text = (ROOT / name).read_text(encoding='utf-8')
            self.assertEqual(sum(line.startswith('```') for line in text.splitlines()) % 2, 0)
            self.assertTrue(text.startswith('# '))
        root = (ROOT / 'readme.md').read_text(encoding='utf-8')
        self.assertIn('(docs/readme.md)', root)

    def test_referenced_safety_test_modules_exist(self):
        guide = (ROOT / DOCUMENTS[1]).read_text(encoding='utf-8')
        names = set(re.findall(r'\btest_[a-z_]+\.py\b', guide))
        self.assertGreaterEqual(len(names), 8)
        for name in names:
            self.assertTrue((ROOT / 'tests' / name).is_file(), name)
        code = '\n'.join(re.findall(r'```bash\n(.*?)```', guide, re.S))
        for forbidden in ('git reset', 'git clean', 'rm -rf', 'ollama pull', 'sudo ', 'curl '):
            self.assertNotIn(forbidden, code)
        self.assertIn('OPENCLAW_USER_DATA_DIR="$TEST_ROOT/workspace"', code)
        self.assertNotIn('--run --confirm', code)


if __name__ == '__main__':
    unittest.main()
