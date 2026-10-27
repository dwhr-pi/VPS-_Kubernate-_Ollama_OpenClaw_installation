"""Offline contracts for the remaining container-to-source entrypoints."""
import json
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class DockerRemainderTests(unittest.TestCase):
    def setUp(self):
        self.items = json.loads((ROOT / 'config/docker_to_github.json').read_text(encoding='utf-8'))['tools']
        self.tools = {item['id']: item for item in self.items}

    def test_manifest_ids_are_unique(self):
        self.assertEqual(len(self.items), len(self.tools))

    def test_new_installers_only_delegate_to_native_engine(self):
        for key in ('opentelemetry', 'autogpt', 'supabase'):
            with self.subTest(tool=key):
                text = (ROOT / f'scripts/tools/{key}_install.sh').read_text(encoding='utf-8')
                self.assertIn('set -euo pipefail', text)
                self.assertIn('https://github.com/' + self.tools[key]['repo'], text)
                self.assertIn(f'native_github_tools.py" {key} install "$@"', text)
                self.assertNotRegex(text, r'(?m)^\s*(?:source|sudo|docker|run_docker_compose)\s')
                self.assertNotIn('init_tool_tracking', text)

    def test_collector_has_pinned_native_core_build(self):
        recipe = self.tools['opentelemetry']['recipe']
        self.assertEqual(recipe['repo'], 'open-telemetry/opentelemetry-collector')
        self.assertRegex(recipe['pin'], r'^[0-9a-f]{40}$')
        self.assertEqual(recipe['pin'], '30add0562534958c3b4173fa307b5a3497d0bc9c')
        self.assertEqual(recipe['module_dir'], 'cmd/otelcorecol')
        self.assertEqual(recipe['kind'], 'go')
        self.assertEqual(recipe['package'], '.')
        self.assertEqual(recipe['binary'], 'otelcorecol')
        self.assertEqual(recipe['probe'], ['--version'])
        self.assertGreaterEqual(recipe['disk_mb'], 8192)

    def test_unverified_platforms_cannot_claim_a_native_recipe(self):
        for key in ('autogpt', 'supabase', 'airbyte', 'rhasspy'):
            with self.subTest(tool=key):
                item = self.tools[key]
                self.assertIsNone(item['recipe'])
                self.assertTrue(item['blocked_reason'])

    def test_native_collector_uninstall_preserves_legacy(self):
        text = (ROOT / 'scripts/tools/opentelemetry_uninstall.sh').read_text(encoding='utf-8')
        self.assertIn('native_github_tools.py" opentelemetry uninstall', text)
        self.assertNotIn('docker_compose_tool_common', text)
        self.assertNotRegex(text, r'\b(?:rm|docker|sudo)\s')

    def test_historical_container_implementations_are_inactive(self):
        for key in ('opentelemetry', 'autogpt', 'supabase'):
            file = ROOT / f'docs/proposals/legacy-container-installers/{key}_install.sh.example'
            self.assertTrue(file.is_file())
            self.assertIn('Historical reference only', file.read_text(encoding='utf-8'))

    def test_native_notes_and_remainder_are_linked(self):
        doc = (ROOT / 'docs/DOCKER_REMAINDER_2026-10-27.md').read_text(encoding='utf-8')
        for key in ('OpenTelemetry', 'AutoGPT Platform', 'Supabase', 'Airbyte Core', 'Rhasspy 2'):
            self.assertIn(key, doc)
        self.assertIn('DOCKER_REMAINDER_2026-10-27.md',
                      (ROOT / 'docs/DOCKER_TO_GITHUB.md').read_text(encoding='utf-8'))

    def test_collector_registry_uses_build_check_not_directory(self):
        registry = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        item = next(row for row in registry if row['id'] == 'opentelemetry')
        self.assertEqual(item['install_script'], 'scripts/tools/opentelemetry_install.sh')
        self.assertTrue(item['check_value'].endswith('/native-github/build-ready.json'))
        self.assertEqual(item['check_script'], 'scripts/tools/opentelemetry_check.sh')
        self.assertEqual(item['source_commit'], self.tools['opentelemetry']['recipe']['pin'])


if __name__ == '__main__':
    unittest.main()
