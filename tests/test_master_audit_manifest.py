"""Repository-only synthetic manifests; no Git process, workspace, service or credential access."""
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts/quality'))
import master_audit


class ManifestTests(unittest.TestCase):
    def test_digest_is_order_independent_and_binds_paths_sizes_and_hashes(self):
        rows = [{'path': 'b.py', 'bytes': 1, 'sha256': 'a' * 64},
                {'path': 'a.py', 'bytes': 2, 'sha256': 'b' * 64}]
        original = master_audit.manifest_digest(rows)
        self.assertEqual(master_audit.manifest_digest(list(reversed(rows))), original)
        for field, value in (('path', 'changed.py'), ('bytes', 9), ('sha256', 'c' * 64)):
            changed = [dict(row) for row in rows]
            changed[0][field] = value
            self.assertNotEqual(master_audit.manifest_digest(changed), original)

    def test_untracked_content_is_bound_and_generated_reports_do_not_self_reference(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root / 'config').mkdir()
            for name in ('tools', 'profiles', 'ports'):
                (root / f'config/{name}.yml').write_text(json.dumps({name: []}))
            output = root / 'docs/audit'
            output.mkdir(parents=True)
            for name in ('inventory.json', 'TOOL_INVENTORY.md', 'test_results.json', 'test_recheck_results.json'):
                (output / name).write_text('{}\n')
            untracked = root / 'untracked.py'
            untracked.write_text('value = 1\n')
            def git(_root, *args):
                if args == ('rev-parse', 'HEAD'):
                    return 'a' * 40
                return '?? untracked.py' if args[0] == 'status' else ''
            with mock.patch.object(master_audit, 'git', side_effect=git):
                before = master_audit.snapshot(root)
                (output / 'inventory.json').write_text('{"synthetic": true}\n')
                unchanged = master_audit.snapshot(root)
                self.assertEqual(before['working_tree_manifest_sha256'], unchanged['working_tree_manifest_sha256'])
                untracked.write_text('value = 2\n')
                changed = master_audit.snapshot(root)
            self.assertNotEqual(before['working_tree_manifest_sha256'], changed['working_tree_manifest_sha256'])
            self.assertEqual(before['working_tree_diff_sha256'], changed['working_tree_diff_sha256'])
            paths = {row['path'] for row in before['files']}
            self.assertIn('untracked.py', paths)
            self.assertTrue(paths.isdisjoint(master_audit.GENERATED_REPORTS))
            self.assertTrue(before['working_tree_dirty'])


if __name__ == '__main__':
    unittest.main()
