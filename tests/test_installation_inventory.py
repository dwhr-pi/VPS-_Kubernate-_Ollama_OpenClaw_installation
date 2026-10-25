"""Portable inventory fixtures; never reads user state or starts an application."""
from contextlib import nullcontext
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('installation_inventory', ROOT / 'scripts/operations/installation_inventory.py')
inv = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(inv)


class Inventory(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / 'workspace'
        self.output = Path(self.temp.name) / 'external/programmes.json'
        for context in (patch.object(inv, 'maintenance_guard', side_effect=lambda *a, **k: nullcontext()),
                        patch.object(inv.shutil, 'which', return_value=None)):
            context.start()
            self.addCleanup(context.stop)

    def status(self, relative, text):
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding='utf-8')

    def installed_node_red(self):
        _, _, specs = inv.registry()
        spec = specs['Node_Red']
        prefix = self.root / 'tools/node_red/native-github'
        artifact = prefix / 'bin/fixture'
        artifact.parent.mkdir(parents=True, exist_ok=True)
        artifact.write_bytes(b'fixture-program')
        record = {'commit': spec['source_commit'], 'artifacts': ['bin/fixture'],
                  'files': {'bin/fixture': hashlib.sha256(artifact.read_bytes()).hexdigest()}}
        marker = prefix / 'build-ready.json'
        marker.write_text(json.dumps(record))
        return marker, artifact

    def test_snapshot_merges_status_copies_and_does_not_export_unknown_contents(self):
        self.status('installed_tools.txt', 'Node_Red\nOllama\nfixture-secret-not-a-tool\n')
        self.status('status/installed_tools.txt', 'Ollama\nLiteLLM\n')
        result = inv.snapshot(self.root)
        names = {item['name'] for item in result['tools'] if item['recorded']}
        self.assertEqual(names, {'Node_Red', 'Ollama', 'LiteLLM'})
        self.assertEqual(result['ignored_status_lines'], 1)
        self.assertNotIn('fixture-secret-not-a-tool', json.dumps(result))

    def test_inventory_detects_existing_marker_without_status_file(self):
        self.installed_node_red()
        record = next(item for item in inv.snapshot(self.root)['tools'] if item['name'] == 'Node_Red')
        self.assertFalse(record['recorded'])
        self.assertEqual(record['evidence_at_export'], 'artifact-hashes-match')

    def test_export_has_readable_summary_and_valid_checksum(self):
        self.status('installed_tools.txt', 'Node_Red\n')
        inv.export(self.root, self.output)
        self.assertIn('Node_Red', self.output.with_suffix('.md').read_text())
        self.assertEqual(inv.load(self.output)['tools'][0]['name'], 'Node_Red')
        self.assertNotIn('fixture-program', self.output.read_text())

    def test_workspace_export_requires_explicit_internal_backup_flag(self):
        with self.assertRaises(ValueError):
            inv.export(self.root, self.root / 'backups/programmes.json')
        self.assertFalse(self.root.exists())

    def test_tampered_or_truncated_export_is_not_imported(self):
        inv.export(self.root, self.output)
        bundle = json.loads(self.output.read_text())
        bundle['payload']['recorded_profiles'] = ['changed']
        self.output.write_text(json.dumps(bundle))
        with self.assertRaisesRegex(ValueError, 'Pruefsumme'):
            inv.load(self.output)
        self.output.write_text('{')
        with self.assertRaises(ValueError):
            inv.load(self.output)

    def test_existing_export_is_never_overwritten(self):
        inv.export(self.root, self.output)
        original = self.output.read_bytes()
        with self.assertRaisesRegex(ValueError, 'bereits vorhanden'):
            inv.export(self.root, self.output)
        self.assertEqual(self.output.read_bytes(), original)

    def test_restore_requires_confirmation(self):
        with self.assertRaisesRegex(ValueError, 'confirm-restore'):
            inv.restore(self.root, {'tools': [], 'recorded_profiles': []})
        self.assertFalse(self.root.exists())

    def test_restore_missing_program_remains_pending_without_fake_marker(self):
        report = inv.restore(self.root, {'tools': [{'name': 'Node_Red'}], 'recorded_profiles': ['Programmierer']}, confirmed=True)
        self.assertEqual(report['restore_candidates'], [])
        self.assertEqual(report['pending_tools'][0]['name'], 'Node_Red')
        self.assertEqual((self.root / 'installed_tools.txt').read_text(), '')
        self.assertFalse((self.root / 'tools/node_red/native-github/build-ready.json').exists())
        self.assertFalse((self.root / 'installed_profiles.txt').exists())

    def test_restore_merges_both_copies_and_keeps_previous_status(self):
        self.installed_node_red()
        self.status('installed_tools.txt', 'Ollama\n')
        self.status('status/installed_tools.txt', 'LiteLLM\n')
        data = {'tools': [{'name': 'Node_Red'}], 'recorded_profiles': []}
        inv.restore(self.root, data, confirmed=True)
        expected = {'Ollama', 'LiteLLM', 'Node_Red'}
        for relative in inv.STATUS_FILES:
            self.assertEqual(set((self.root / relative).read_text().splitlines()), expected)
        before = next((self.root / 'status_restore_history').glob('*/before_0.txt'))
        self.assertEqual(before.read_text(), 'Ollama\n')
        inv.restore(self.root, data, confirmed=True)
        self.assertEqual(len((self.root / 'installed_tools.txt').read_text().splitlines()), 3)

    def test_corrupt_artifact_and_wrong_pin_never_become_candidates(self):
        marker, artifact = self.installed_node_red()
        artifact.write_bytes(b'changed')
        data = {'tools': [{'name': 'Node_Red'}], 'recorded_profiles': []}
        self.assertEqual(inv.preview(self.root, data)['restore_candidates'], [])
        marker.write_text('{}')
        self.assertEqual(inv.preview(self.root, data)['restore_candidates'], [])

    def test_preview_is_read_only_and_never_executes_checks(self):
        result = inv.preview(self.root, {'tools': [{'name': 'UnknownTool'}], 'recorded_profiles': []})
        self.assertEqual(result['pending_tools'][0]['reason'], 'unknown-tool')
        self.assertFalse(self.root.exists())

    def test_update_backup_and_menu_are_wired(self):
        update = (ROOT / 'scripts/auto_update_hard.sh').read_text()
        apply = update.split('    --apply)', 1)[1]
        self.assertLess(apply.index('installation_inventory.py'), apply.index('"$HELPER" sync'))
        backup = (ROOT / 'scripts/operations/backup_run.sh').read_text()
        self.assertIn('installation-inventory.json', backup)
        self.assertNotIn('|| true', backup)
        setup = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        self.assertIn('"21" "Installationsstatus', setup)


if __name__ == '__main__':
    unittest.main()
