"""Offline SSH documentation fixtures; no SSH, installers or user-data access."""
import contextlib
import importlib.util
import io
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')
SPEC = importlib.util.spec_from_file_location('tool_ssh_docs_fixture', ROOT / 'scripts/quality/tool_ssh_docs.py')
docs = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(docs)


def row(key='demo', guide='docs/tools/demo.md', approved=True):
    return dict(id=key, doc=guide, config_script=None,
                unattended='native-helper-explicit-approval' if approved else 'not-reviewed')


class ToolSSHDocs(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'docs/tools/nested').mkdir(parents=True)
        (self.root / 'docs/agents').mkdir()
        self.files = ('docs/tools/demo.md', 'docs/tools/other-guide.md', 'docs/tools/nested/README.md',
                      'docs/agents/EXTERNAL.md')
        for name in self.files:
            (self.root / name).write_text('# Original\n\nContent remains.\n', encoding='utf-8')

    def test_every_tool_guide_and_external_registry_guide_is_included(self):
        rows = [row(), row('external', 'docs/agents/EXTERNAL.md'), row('other_guide', None)]
        with mock.patch.object(docs.catalog, 'catalog', return_value=rows):
            result = docs.guides(self.root)
        self.assertEqual(set(result), set(self.files))
        self.assertEqual(result['docs/tools/other-guide.md'][0]['id'], 'other_guide')
        self.assertEqual(result['docs/tools/nested/README.md'], [])

    def test_default_check_is_read_only_and_write_is_idempotent(self):
        original = (self.root / self.files[0]).read_bytes()
        with mock.patch.object(docs.catalog, 'catalog', return_value=[row()]), contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(docs.check(self.root), 1)
            self.assertEqual((self.root / self.files[0]).read_bytes(), original)
            self.assertEqual(docs.check(self.root, write=True), 0)
            written = {name: (self.root / name).read_bytes() for name in self.files[:3]}
            self.assertEqual(docs.check(self.root), 0)
            self.assertEqual(docs.check(self.root, write=True), 0)
        for name, content in written.items():
            self.assertEqual((self.root / name).read_bytes(), content)
            self.assertTrue(content.startswith(original.replace(b'\r\n', b'\n').rstrip()))

    def test_only_marked_section_changes_and_malformed_markers_fail(self):
        original = 'before\n' + docs.START + '\nold\n' + docs.END + '\nafter\n'
        self.assertEqual(docs.update(original, docs.START + '\nnew\n' + docs.END),
                         'before\n' + docs.START + '\nnew\n' + docs.END + '\nafter\n')
        for text in (docs.START, docs.END, docs.END + docs.START, docs.START * 2 + docs.END):
            with self.assertRaises(ValueError):
                docs.update(text, 'replacement')

    def test_malformed_late_guide_prevents_all_writes(self):
        broken = self.root / self.files[2]
        broken.write_text(docs.START, encoding='utf-8')
        original = (self.root / self.files[0]).read_bytes()
        with mock.patch.object(docs.catalog, 'catalog', return_value=[row()]):
            with self.assertRaises(ValueError):
                docs.check(self.root, write=True)
        self.assertEqual((self.root / self.files[0]).read_bytes(), original)

    def test_paths_cannot_escape_repository(self):
        for name in ('../private.md', 'docs/../../private.md', 'C:/private.md', 'docs/tools/missing.md'):
            with mock.patch.object(docs.catalog, 'catalog', return_value=[row(guide=name)]):
                with self.assertRaises(ValueError):
                    docs.guides(self.root)

    def test_unapproved_and_desktop_tools_never_get_install_commands(self):
        text = docs.render('docs/tools/demo.md', [row('desktop', approved=False)])
        self.assertIn('show desktop', text)
        self.assertNotIn('run desktop', text)
        self.assertIn('nicht zu einer VPS-Anwendung', text)
        self.assertIn('Kein freigegebener', text)
        self.assertNotIn('curl ', text)
        self.assertNotIn('StrictHostKeyChecking=no', text)
        self.assertIn('`desktop` (ID `desktop`) waehlen', text)

    def test_approved_actions_are_separate_and_require_exact_confirmation(self):
        text = docs.render('docs/tools/demo.md', [row()])
        for action in ('install', 'update', 'uninstall'):
            self.assertIn(f'--action {action} --apply --confirm demo:{action}', text)
        blocks = re.findall(r'```bash\n(.*?)\n```', text, re.S)
        for block in blocks:
            self.assertLessEqual(block.count('--apply'), 1)
        self.assertIn('--action status', text)
        self.assertIn('--action doctor', text)
        self.assertIn('cd "$HOME/openclaw_ultimate_setup" || exit 1', text)
        self.assertIn('ssh -t vps', text)

    def test_relative_links_and_new_generic_guides(self):
        for name in self.files:
            text = docs.render(name, [])
            self.assertIn('scripts/tool_commands.py list', text)
            self.assertNotIn('--apply --confirm', text)
            for link in re.findall(r'\]\(([^)]+)\)', text):
                target = (ROOT / name).parent / link
                self.assertTrue(target.is_file(), target)

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash unavailable; no WSL fallback')
    def test_generated_bash_is_syntax_checked_without_execution(self):
        text = docs.render('docs/tools/demo.md', [row(), row('desktop', approved=False)])
        code = '\n'.join(re.findall(r'```bash\n(.*?)\n```', text, re.S))
        env = {'PATH': os.environ.get('PATH', ''), 'BASH_ENV': os.devnull, 'ENV': os.devnull}
        if 'SystemRoot' in os.environ:
            env['SystemRoot'] = os.environ['SystemRoot']
        result = subprocess.run([BASH, '--noprofile', '--norc', '-n'], input=code,
                                text=True, capture_output=True, timeout=30, env=env)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_real_repository_has_no_drift_or_unregistered_plan_ids(self):
        with contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(docs.check(ROOT), 0)
        known = {row['id'] for row in docs.catalog.catalog(ROOT)}
        targets = docs.guides(ROOT)
        self.assertTrue(targets)
        for name, rows in targets.items():
            text = (ROOT / name).read_text(encoding='utf-8')
            self.assertEqual(text.count(docs.START), 1, name)
            for key in re.findall(r'scripts/tool_commands.py show ([a-z0-9_]+)', docs.render(name, rows)):
                self.assertIn(key, known)

    def test_all_registered_tools_have_an_existing_specific_ssh_guide(self):
        rows = docs.catalog.catalog(ROOT)
        texts = {name: (ROOT / name).read_text(encoding='utf-8') for name in docs.guides(ROOT, rows)}
        checked = docs.coverage(rows, texts)
        self.assertEqual(len(checked), len(rows))
        self.assertTrue(all(row['doc'] and row['covered'] for row in checked),
                        [row for row in checked if not row['covered']])
        self.assertEqual((ROOT / docs.REPORT).read_text(encoding='utf-8'), docs.report(checked))

    def test_future_tool_without_doc_blocks_check_and_write(self):
        for write in (False, True):
            with mock.patch.object(docs.catalog, 'catalog', return_value=[row(), row('future', guide=None)]):
                with contextlib.redirect_stdout(io.StringIO()):
                    self.assertEqual(docs.check(self.root, write=write), 1)
            self.assertNotIn(docs.START, (self.root / self.files[0]).read_text(encoding='utf-8'))
            self.assertFalse((self.root / docs.REPORT).exists())

    def test_generic_ssh_or_another_tools_plan_does_not_count(self):
        wrong = docs.render('docs/tools/demo.md', [row('other')])
        checked = docs.coverage([row()], {'docs/tools/demo.md': wrong})
        self.assertFalse(checked[0]['covered'])
        self.assertIn('missing-tool-plan', checked[0]['problems'])
        self.assertIn('missing-tool-instructions', checked[0]['problems'])
        checked = docs.coverage([row()], {'docs/tools/demo.md': 'ssh -t vps\nbash setup_ultimate.sh\n'})
        self.assertFalse(checked[0]['covered'])

    def test_report_includes_each_id_with_a_resolvable_guide(self):
        rows = docs.coverage([row()], {'docs/tools/demo.md': docs.render('docs/tools/demo.md', [row()])})
        text = docs.report(rows)
        self.assertIn('1 / 1 Tool-IDs', text)
        self.assertIn('[SSH-Installation](../tools/demo.md#vps-ueber-ssh-bedienen)', text)
        self.assertIn('| demo |', text)

    def test_new_entry_pages_have_only_resolvable_local_document_and_script_links(self):
        for page in (ROOT / 'docs/tools/registry').glob('*.md'):
            for link in re.findall(r'\]\(([^\s)]+)\)', page.read_text(encoding='utf-8')):
                if '://' in link or link.startswith('#'):
                    continue
                target = (page.parent / link.split('#', 1)[0]).resolve()
                self.assertTrue(target.is_relative_to(ROOT), page)
                self.assertTrue(target.is_file(), (page, link))

    def test_report_symlink_is_rejected(self):
        (self.root / 'docs/generated').mkdir()
        target = self.root / docs.REPORT
        other = self.root / 'unrelated.md'
        other.write_text('untouched', encoding='utf-8')
        try:
            target.symlink_to(other)
        except (OSError, NotImplementedError):
            self.skipTest('Symlink creation unavailable')
        with mock.patch.object(docs.catalog, 'catalog', return_value=[row()]):
            with self.assertRaises(ValueError):
                docs.check(self.root, write=True)
        self.assertEqual(other.read_text(encoding='utf-8'), 'untouched')


if __name__ == '__main__':
    unittest.main()
