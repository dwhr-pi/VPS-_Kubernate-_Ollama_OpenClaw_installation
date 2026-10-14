"""Offline documentation/registry/guard checks. No agent, model or WSL access."""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = Path('C:/Program Files/Git/bin/bash.exe') if os.name == 'nt' else shutil.which('bash')
TOOLS = ('aider', 'continue_dev', 'opencode', 'openhands', 'langgraph',
         'crewai', 'autogen', 'agent_framework', 'automaton')


class AgenticCodingDocs(unittest.TestCase):
    def test_tool_sources_and_documents(self):
        entries = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        for tid in TOOLS:
            matches = [t for t in entries if t['id'] == tid]
            self.assertEqual(len(matches), 1, tid)
            tool = matches[0]
            self.assertTrue(tool['source'].startswith('https://github.com/'), tid)
            self.assertTrue((ROOT / tool['doc']).is_file(), tid)
        framework = next(t for t in entries if t['id'] == 'agent_framework')
        self.assertEqual(framework['status'], 'planned')
        self.assertEqual(framework['ports'], [])
        for field in ('install_script', 'uninstall_script', 'update_script', 'doctor_script'):
            self.assertTrue((ROOT / framework[field]).is_file())

    def test_profile_mapping_and_scripts(self):
        profiles = json.loads((ROOT / 'config/profiles.yml').read_text(encoding='utf-8'))['profiles']
        profile, = [p for p in profiles if p['id'] == 'Agentic_Coding_Local_First']
        self.assertEqual(profile['status'], 'planned')
        for field in ('doc', 'install', 'uninstall'):
            self.assertTrue((ROOT / profile[field]).is_file())
        self.assertNotIn('automaton', profile['tools'])
        self.assertIn('automaton', profile['optional_tools'])

    def test_local_markdown_links(self):
        files = ('docs/AGENTIC_CODING_GUIDE.md', 'docs/tools/agentic-coding.md',
                 'docs/Profile/Agentic_Coding_Local_First.md', 'docs/tools/automaton.md')
        for relative in files:
            doc = ROOT / relative
            for link in re.findall(r'\]\(([^)]+)\)', doc.read_text(encoding='utf-8')):
                if '://' not in link and not link.startswith('#'):
                    self.assertTrue((doc.parent / link.split('#')[0]).exists(), f'{relative}: {link}')

    def test_menu_wiring(self):
        menu = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        self.assertIn('TOOL_KEYS+=("Microsoft_Agent_Framework")', menu)
        self.assertIn('TOOL_SCRIPT_NAMES["Microsoft_Agent_Framework"]="agent_framework"', menu)
        status = (ROOT / 'scripts/helpers/status_tracking.sh').read_text(encoding='utf-8')
        self.assertIn('TOOL_KEYS+=("Microsoft_Agent_Framework")', status)


@unittest.skipUnless(BASH and Path(BASH).exists(), 'Git Bash/bash unavailable')
class AgenticPlannedGuards(unittest.TestCase):
    def invoke(self, script, args):
        with tempfile.TemporaryDirectory() as temp:
            home = Path(temp) / 'unused-home'
            env = dict(os.environ, HOME=str(home))
            result = subprocess.run([str(BASH), '--noprofile', '--norc', script, *args],
                                    cwd=ROOT, env=env, capture_output=True, text=True, timeout=30)
            self.assertFalse(home.exists())
        return result

    def test_framework_dry_run_not_installed(self):
        result = self.invoke('scripts/tools/agent_framework_install.sh', ['--dry-run'])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(json.loads(result.stdout)['installed'])

    def test_framework_runtime_actions_blocked(self):
        for action in ('install', 'update', 'uninstall'):
            with self.subTest(action=action):
                result = self.invoke(f'scripts/tools/agent_framework_{action}.sh', [])
                self.assertEqual(result.returncode, 2, result.stderr)

    def test_profile_plan_is_not_installation(self):
        result = self.invoke('scripts/profiles/Agentic_Coding_Local_First_install.sh', ['--dry-run'])
        self.assertEqual(result.returncode, 0, result.stderr)
        for action in ('install', 'uninstall'):
            result = self.invoke(f'scripts/profiles/Agentic_Coding_Local_First_{action}.sh', [])
            self.assertEqual(result.returncode, 2, result.stderr)


if __name__ == '__main__':
    unittest.main()
