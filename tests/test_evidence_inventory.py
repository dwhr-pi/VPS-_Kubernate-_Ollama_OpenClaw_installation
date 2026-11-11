import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('evidence_inventory', ROOT / 'scripts/quality/evidence_inventory.py')
inventory = importlib.util.module_from_spec(spec)
spec.loader.exec_module(inventory)


class EvidenceInventory(unittest.TestCase):
    def fixture(self, directory):
        root = Path(directory)
        for folder in ('config', 'scripts/tools', 'tests', 'docs/generated', 'stacks/example'):
            (root / folder).mkdir(parents=True, exist_ok=True)
        (root / 'config/tools.yml').write_text('{"tools":[]}', encoding='utf-8')
        (root / 'scripts/tools/example_install.sh').write_text(
            '# git clone is a candidate, not proof\nprintf never-report-this-fixture\n', encoding='utf-8')
        (root / 'tests/test_example.py').write_text(
            'def test_fixture_not_runtime():\n    assert True\n', encoding='utf-8')
        (root / 'stacks/example/config.yaml').write_text(
            'privileged: false\naddress: 127.0.0.1\n', encoding='utf-8')
        return root, ['config/tools.yml', 'scripts/tools/example_install.sh',
                      'tests/test_example.py', 'stacks/example/config.yaml']

    def test_default_inventory_never_executes_source_or_echoes_lines(self):
        with tempfile.TemporaryDirectory() as directory:
            root, files = self.fixture(directory)
            with patch.object(inventory.subprocess, 'run', side_effect=AssertionError):
                results = inventory.render(root, files)
            combined = '\n'.join(results.values())
            self.assertIn('scripts/tools/example_install.sh:1', combined)
            self.assertNotIn('never-report-this-fixture', combined)
            self.assertNotIn('privileged: false', combined)
            self.assertIn('stacks/example/config.yaml:1', combined)
            self.assertIn('test_fixture_not_runtime', combined)

    def test_untracked_and_private_env_are_not_read(self):
        with tempfile.TemporaryDirectory() as directory:
            root, files = self.fixture(directory)
            (root / '.env').write_text('private-fixture', encoding='utf-8')
            (root / 'untracked.py').write_text('raise Exception()', encoding='utf-8')
            self.assertIsNone(inventory.read_tracked(root, '.env'))
            results = inventory.render(root, files + ['.env'])
            self.assertNotIn('private-fixture', '\n'.join(results.values()))
            self.assertNotIn('untracked.py', '\n'.join(results.values()))

    def test_generated_reports_do_not_change_their_own_reference_counts(self):
        with tempfile.TemporaryDirectory() as directory:
            root, files = self.fixture(directory)
            results = inventory.render(root, files)
            for name, text in results.items():
                (root / name).write_text(text, encoding='utf-8')
            self.assertEqual(results, inventory.render(root, files + list(results)))

    def test_unreferenced_is_never_called_dead(self):
        with tempfile.TemporaryDirectory() as directory:
            root, files = self.fixture(directory)
            result = inventory.render(root, files)[inventory.OUTPUTS[2]]
            self.assertIn('kein Beweis fuer toten Code', result)
            self.assertIn('scripts/tools/example_install.sh', result)

    def test_link_and_outside_paths_not_followed(self):
        with tempfile.TemporaryDirectory() as directory:
            root, _ = self.fixture(directory)
            with self.assertRaises(ValueError):
                inventory.read_tracked(root, '../outside.py')
            with patch.object(Path, 'is_symlink', return_value=True), patch.object(
                    Path, 'read_bytes', side_effect=AssertionError):
                self.assertIsNone(inventory.read_tracked(root, 'config/tools.yml'))

    def test_bats_and_syntax_errors_are_visible(self):
        with tempfile.TemporaryDirectory() as directory:
            root, files = self.fixture(directory)
            (root / 'tests/broken.py').write_text('def invalid(', encoding='utf-8')
            (root / 'tests/example.bats').write_text('@test "fixture" { true; }', encoding='utf-8')
            result = inventory.render(root, files + ['tests/broken.py', 'tests/example.bats'])[inventory.OUTPUTS[1]]
            self.assertIn('Syntax statisch nicht auswertbar', result)
            self.assertIn('tests/example.bats:1', result)

    def test_extensionless_build_definitions_are_included_not_executed(self):
        with tempfile.TemporaryDirectory() as directory:
            root, files = self.fixture(directory)
            (root / 'stacks/example/Dockerfile').write_text('FROM example:latest\n', encoding='utf-8')
            results = inventory.render(root, files + ['stacks/example/Dockerfile'])
            self.assertIn('stacks/example/Dockerfile:1', results[inventory.OUTPUTS[0]])

    def test_audit_status_never_promotes_structural_metadata_to_verified(self):
        path = ROOT / 'scripts/quality/tool_truth_table.py'
        spec = importlib.util.spec_from_file_location('truth_table_fixture', path)
        table = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(table)
        with tempfile.TemporaryDirectory() as directory:
            root, _ = self.fixture(directory)
            self.assertEqual(table.audit_status({'id': 'example', 'install_script':
                                                'scripts/tools/example_install.sh'}, root), 'STUB')
            self.assertEqual(table.audit_status({'id': 'example'}, root), 'DOKU-ONLY')
            self.assertEqual(table.audit_status({'id': 'openhands'}, root), 'WIDERSPRUCH')

    def test_index_command_is_read_only_and_bounded(self):
        with patch.object(inventory.subprocess, 'run') as run:
            run.return_value.stdout = b'scripts/a.sh\0'
            self.assertEqual(inventory.tracked_files(ROOT), ['scripts/a.sh'])
            self.assertEqual(run.call_args.args[0], ['git', 'ls-files', '-z'])
            self.assertEqual(run.call_args.kwargs['timeout'], 20)
            self.assertNotIn('shell', run.call_args.kwargs)


if __name__ == '__main__':
    unittest.main()
