"""Short entry point and retained historical navigation, without online lookups."""
from pathlib import Path
import json
import os
import re
import shutil
import subprocess
import tempfile
import unicodedata
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')
HELPER = ROOT / 'scripts/helpers/documentation_menu.sh'


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
    def test_compact_readme_preserves_legacy_navigation(self):
        root = (ROOT / 'readme.md').read_text(encoding='utf-8')
        archive = (ROOT / 'docs/legacy/README_FULL_2026_11_01.md').read_text(encoding='utf-8')
        fixture = json.loads((ROOT / 'tests/fixtures/legacy_readme_navigation.json').read_text(encoding='utf-8'))
        self.assertLess(len(root.splitlines()), 200)
        self.assertEqual(headings(root), ['Hybride Kubernetes- und KI-Plattform', 'Orientierung'])
        self.assertEqual(len(re.findall(r'^- \*\*', root, re.M)), 6)
        self.assertEqual(len(fixture), 45)
        self.assertEqual([row['title'] for row in fixture], headings(archive))
        anchors = re.findall(r'<a id="([^"]+)"></a>', root)
        self.assertEqual(anchors, ['deklarativer-pruefpfad'] + [row['anchor'] for row in fixture])
        self.assertEqual(len(anchors), len(set(anchors)))
        for row in fixture:
            # These historical headings use letters, marks, spaces, underscores and hyphens.
            expected = ''.join(char for char in row['title'].lower()
                               if char.isalnum() or char in ' _-' or
                               (unicodedata.category(char).startswith('M') and char != '\ufe0f')).replace(' ', '-')
            self.assertEqual(row['anchor'], expected, row['title'])
            link = f"[{row['title']}](docs/legacy/README_FULL_2026_11_01.md#{row['anchor']})"
            self.assertIn(link, root)
            self.assertGreater(root.index(link), root.index('<details>'))
            self.assertLess(root.index(link), root.index('</details>'))
        self.assertIn('Historische Referenz', archive)

    def test_new_document_links_resolve(self):
        for relative in ('readme.md', 'docs/P1_P3_IMPLEMENTATION.md'):
            path = ROOT / relative
            text = path.read_text(encoding='utf-8')
            text = re.sub(r'```.*?```', '', text, flags=re.S)
            for target in re.findall(r'\]\(([^)]+)\)', text):
                if '://' not in target and not target.startswith('#'):
                    self.assertTrue((path.parent / target.split('#')[0]).exists(), target)

    def test_terminal_entry_and_fixed_document_targets(self):
        helper = HELPER.read_text(encoding='utf-8')
        targets = re.findall(r"^\s+([a-z]+):([a-z]+)\) printf '%s\\n' '([^']+)' ;;", helper, re.M)
        self.assertEqual(len(targets), 18)
        self.assertEqual(len({topic for topic, _, _ in targets}), 6)
        for _, _, relative in targets:
            path = (ROOT / relative).resolve()
            self.assertTrue(path.is_relative_to(ROOT))
            self.assertTrue(path.is_file(), relative)
        self.assertIn(('tools', 'keys', 'docs/_API-Keys/API_KEY_GUIDE.md'), targets)
        setup = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        self.assertIn('source "$INSTALL_DIR/scripts/helpers/documentation_menu.sh"', setup)
        self.assertRegex(setup, r'\n    10\)\s+show_documentation_menu\s+;;')


@unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash unavailable; never invoke WSL')
class DocumentationMenu(unittest.TestCase):
    def run_menu(self, responses=(), invocation='show_documentation_menu', missing_root=False):
        with tempfile.TemporaryDirectory() as directory:
            temp = Path(directory)
            (temp / 'responses').write_text('\n'.join(responses) + '\n', encoding='utf-8', newline='\n')
            env = {'PATH': os.environ.get('PATH', ''), 'HOME': directory,
                   'BASH_ENV': os.devnull, 'ENV': os.devnull,
                   'HELPER': HELPER.as_posix(), 'APP_TITLE': 'Offline fixture',
                   'INSTALL_DIR': temp.as_posix() if missing_root else ROOT.as_posix(),
                   'MENU_RESPONSES': (temp / 'responses').as_posix(),
                   'MENU_POSITION': (temp / 'position').as_posix(),
                   'MENU_LOG': (temp / 'calls').as_posix()}
            if 'SystemRoot' in os.environ:
                env['SystemRoot'] = os.environ['SystemRoot']
            script = r'''
dialog() {
  printf '%s\t' "$@" >> "$MENU_LOG"
  printf '\n' >> "$MENU_LOG"
  local index=0 entry
  local -a choices
  if [[ -f "$MENU_POSITION" ]]; then read -r index < "$MENU_POSITION"; fi
  mapfile -t choices < "$MENU_RESPONSES"
  entry="${choices[$index]:-97:}"
  printf '%s\n' "$((index + 1))" > "$MENU_POSITION"
  printf '%s' "${entry#*:}"
  return "${entry%%:*}"
}
source "$HELPER"
'''
            result = subprocess.run([BASH, '--noprofile', '--norc', '-c', script + invocation],
                                    cwd=temp, env=env, text=True, capture_output=True, timeout=15)
            log = (temp / 'calls').read_text(encoding='utf-8') if (temp / 'calls').exists() else ''
            return result, log

    def test_source_only_has_no_dialog_or_file_effects(self):
        result, log = self.run_menu(invocation=':')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(log, '')
        self.assertEqual(result.stdout, '')

    def test_cancel_and_escape_leave_without_opening_document(self):
        for code in (1, 255):
            result, log = self.run_menu([f'{code}:'])
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn('--textbox', log)

    def test_api_guide_opens_and_returns_through_both_levels(self):
        result, log = self.run_menu(['0:tools', '0:keys', '0:', '1:', '1:'])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(log.count('--textbox'), 1)
        self.assertIn('docs/_API-Keys/API_KEY_GUIDE.md', log)
        self.assertEqual(log.count('--menu'), 4)

    def test_each_topic_can_open_and_return(self):
        routes = [('start', 'status'), ('architecture', 'baseline'), ('operations', 'backup'),
                  ('security', 'releases'), ('tools', 'profiles'), ('history', 'legacy')]
        for topic, document in routes:
            with self.subTest(topic=topic):
                result, log = self.run_menu([f'0:{topic}', f'0:{document}', '255:', '255:', '255:'])
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(log.count('--textbox'), 1)

    def test_unknown_selection_and_cross_topic_document_are_rejected(self):
        for choices in (['0:../secret'], ['0:start', '0:keys']):
            result, log = self.run_menu(choices)
            self.assertEqual(result.returncode, 2, result.stderr)
            self.assertNotIn('--textbox', log)

    def test_missing_document_reports_failure_without_opening(self):
        result, log = self.run_menu(['0:start', '0:status'], missing_root=True)
        self.assertEqual(result.returncode, 1)
        self.assertIn('Dokument fehlt:', result.stderr)
        self.assertNotIn('--textbox', log)

    def test_dialog_errors_are_not_converted_to_success(self):
        for choices in (['2:'], ['0:start', '2:'], ['0:start', '0:status', '2:']):
            result, _ = self.run_menu(choices)
            self.assertEqual(result.returncode, 2, result.stderr)


if __name__ == '__main__':
    unittest.main()
