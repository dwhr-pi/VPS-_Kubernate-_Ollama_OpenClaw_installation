"""Registry/menu/profile integration without installing or starting any agent."""
import importlib.util
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('coding_profile_integration', ROOT / 'scripts/profiles/coding_agents.py')
profiles = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(profiles)


class CodingRegistry(unittest.TestCase):
    def test_profiles_are_independent_templates_and_do_not_autoinstall(self):
        rows = json.loads((ROOT / 'config/profiles.yml').read_text())['profiles']
        local = json.loads((ROOT / 'config/agents/local_profiles.json').read_text())
        known = {row['id'] for row in json.loads((ROOT / 'config/tools.yml').read_text())['tools']}
        menu = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        tracking = (ROOT / 'scripts/helpers/status_tracking.sh').read_text(encoding='utf-8')
        self.assertEqual(len(local['profiles']), 5)
        with tempfile.TemporaryDirectory() as directory, mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(Path(directory).resolve() / 'private')):
            for item in local['profiles']:
                row, = [row for row in rows if row['id'] == item['id']]
                self.assertFalse(row['auto_install'])
                self.assertEqual(row['status'], 'planned')
                self.assertTrue(set(row['tools']) <= known)
                for field in ('doc', 'install', 'uninstall'):
                    self.assertTrue((ROOT / row[field]).is_file())
                self.assertIn('"' + item['id'] + '"', menu)
                self.assertIn('"' + item['id'] + '"', tracking)
                with mock.patch.object(profiles.subprocess, 'run', side_effect=AssertionError('No process during template install')):
                    self.assertEqual(profiles.profile_action(item['id'], 'install', local), 0)
                    self.assertEqual(profiles.profile_action(item['id'], 'install', local), 0)
                    self.assertEqual(profiles.profile_action(item['id'], 'uninstall', local), 0)
                target = Path(directory) / 'private/agent_profiles' / item['id']
                self.assertTrue((target / 'profile.json').is_file())
                self.assertFalse((target / 'installed.json').exists())

    def test_native_entries_match_pins_and_lifecycle_paths(self):
        native = json.loads((ROOT / 'config/agents/native_clis.json').read_text())['tools']
        tools = json.loads((ROOT / 'config/tools.yml').read_text())['tools']
        for name, spec in native.items():
            row, = [row for row in tools if row['id'] == name]
            self.assertEqual(row['source_commit'], spec['commit'])
            self.assertEqual(row['source'].removesuffix('.git'), spec['origin'].removesuffix('.git'))
            self.assertFalse(row['auto_install'])
            self.assertIn('/native-coding/current/OWNED.json', row['check_value'])
            for field in ('install_script', 'uninstall_script', 'update_script', 'doctor_script', 'doc'):
                self.assertTrue((ROOT / row[field]).is_file())
            self.assertNotIn('planned_tool_stub', row['install_script'])
            self.assertNotIn('scaffold_tool_common', (ROOT / row['uninstall_script']).read_text())

    def test_menu_refresh_uses_owned_evidence_not_marker_existence(self):
        helper = (ROOT / 'scripts/helpers/native_tool_status.sh').read_text()
        for menu, slug in (('OpenCode', 'opencode'), ('Aider', 'aider'),
                           ('OpenHands', 'openhands'), ('Codex_CLI', 'codex_cli')):
            self.assertIn(menu + ') marker=' + slug + '/native-coding/current/OWNED.json', helper)
        self.assertIn('agents/install_cli.py" "$coding_slug" check', helper)
        self.assertRegex(helper, r'OpenCode\s*\|\s*Aider\s*\|\s*OpenHands\s*\|\s*Codex_CLI\)')

    def test_existing_qwen_and_proprietary_boundary_preserved(self):
        rows = {row['id']: row for row in json.loads((ROOT / 'config/tools.yml').read_text())['tools']}
        self.assertEqual(rows['qwen_code']['source_commit'], 'c1a8218f38203e272e6e965778ed6a2795cfeed7')
        self.assertIn('Proprietaer', rows['claude_code']['license'])
        self.assertEqual(rows['claude_code']['install_script'], 'scripts/tools/claude_code_install.sh')
        menu = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        self.assertIn('TOOL_SCRIPT_NAMES["Codex_CLI"]="codex_cli"', menu)


if __name__ == '__main__':
    unittest.main()
