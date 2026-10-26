"""Offline full-registry inventory fixtures; no runtime or network probes."""
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts/quality'))
import platform_inventory as tool


class PlatformInventoryTests(unittest.TestCase):
    def root(self, directory, tools=None, profiles=None):
        root = Path(directory)
        (root / 'config').mkdir()
        (root / 'config/tools.yml').write_text(json.dumps({'tools': tools or []}))
        (root / 'config/profiles.yml').write_text(json.dumps({'profiles': profiles or []}))
        return root

    def test_all_real_registry_entries_are_present_and_not_runtime_tested(self):
        report = tool.inventory()
        for kind in ('tools', 'profiles'):
            expected = json.loads((ROOT / 'config' / (kind + '.yml')).read_text(encoding='utf-8'))[kind]
            actual = [row for row in report['rows'] if row['kind'] == kind]
            self.assertEqual(len(actual), len(expected))
            self.assertEqual({row['id'] for row in actual}, {row['id'] for row in expected})
            self.assertTrue(all(row['readiness'] == 'not-tested' for row in actual))
            self.assertTrue(all(row['review_class'] in tool.CLASSES for row in actual))
        self.assertFalse(report['writes'])
        self.assertFalse(report['runtime_probes'])

    def test_unknown_fields_are_not_invented_and_sources_not_promoted(self):
        with tempfile.TemporaryDirectory() as directory:
            root = self.root(directory, [{'id': 'demo', 'status': 'experimental'}])
            row = tool.inventory(root)['rows'][0]
            self.assertEqual(row['review_class'], 'planned')
            self.assertEqual(row['declared_status'], 'experimental')
            self.assertEqual(row['target_hint'], 'not-declared')
            self.assertIsNone(row['ports'])
            self.assertEqual(row['risk'], 'not-assessed')

    def test_unsafe_script_paths_are_rejected_without_reading_them(self):
        with tempfile.TemporaryDirectory() as directory:
            root = self.root(directory)
            for value in ('../outside', '/etc/passwd', 'C:/private/file', 'a\\b'):
                self.assertEqual(tool.script(root, value)['state'], 'unsafe-path')

    def test_duplicate_ids_are_not_silently_dropped(self):
        with tempfile.TemporaryDirectory() as directory:
            root = self.root(directory, [{'id': 'same'}, {'id': 'same'}])
            with self.assertRaisesRegex(ValueError, 'doppelte'):
                tool.inventory(root)

    def test_reads_only_registries_and_does_not_modify_them(self):
        with tempfile.TemporaryDirectory() as directory:
            root = self.root(directory, [{'id': 'demo', 'check_type': 'path', 'check_value': '/not-accessed/secret.env'}])
            original = Path.read_text
            paths = []
            def read(path, *args, **kwargs):
                paths.append(path)
                return original(path, *args, **kwargs)
            before = {path.name: path.read_bytes() for path in (root / 'config').iterdir()}
            with patch.object(Path, 'read_text', read):
                tool.inventory(root)
            self.assertEqual(set(paths), {root / 'config/tools.yml', root / 'config/profiles.yml'})
            self.assertEqual(before, {path.name: path.read_bytes() for path in (root / 'config').iterdir()})

    def test_markdown_escapes_table_cells(self):
        with tempfile.TemporaryDirectory() as directory:
            root = self.root(directory, [{'id': 'demo', 'name': 'unused', 'risk': 'high|critical\nextra'}])
            rendered = tool.markdown(tool.inventory(root), 'tools')
            self.assertIn('high&#124;critical extra', rendered)
            self.assertIn('Ende des metadatenbasierten Inventars.', rendered)

    def test_optional_profile_dependencies_are_preserved(self):
        with tempfile.TemporaryDirectory() as directory:
            root = self.root(directory, profiles=[{'id': 'demo', 'tools': ['ollama'], 'optional_tools': ['qdrant']}])
            report = tool.inventory(root)
            self.assertEqual(report['rows'][0]['optional_dependencies'], ['qdrant'])
            self.assertIn('ollama; optional: qdrant', tool.markdown(report, 'profiles'))


if __name__ == '__main__':
    unittest.main()
