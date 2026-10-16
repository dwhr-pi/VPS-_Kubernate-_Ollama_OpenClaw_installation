"""Offline checks only: no providers, installed tools, models or WSL."""
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
IDS = ('cogvideox', 'ltx_video', 'tgi', 'pinokio', 'sdnext', 'windmill', 'fal_client', 'veo_api')


class SocialAvatarDocs(unittest.TestCase):
    def test_registry_menu_and_sources(self):
        tools = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        menu = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        status = (ROOT / 'scripts/helpers/status_tracking.sh').read_text(encoding='utf-8')
        key_lines = re.findall(r'^TOOL_KEYS\+?=\((.*?)\)', menu, re.MULTILINE)
        keys = re.findall(r'"([^"]+)"', ' '.join(key_lines))
        for tid in IDS:
            tool, = [t for t in tools if t['id'] == tid]
            self.assertEqual(tool['status'], 'experimental' if tid == 'tgi' else 'planned')
            self.assertFalse(tool['auto_install'])
            self.assertEqual(tool['ports'], [])
            self.assertTrue(tool['source'].startswith('https://github.com/'))
            self.assertEqual(keys.count(tool['name']), 1, tid)
            self.assertIn('"' + tool['name'] + '"', status)
            script = 'tgi' if tid == 'tgi' else 'social_media_candidate'
            self.assertIn('TOOL_SCRIPT_NAMES["' + tool['name'] + '"]="' + script + '"', menu)
            for field in ('doc', 'install_script', 'uninstall_script', 'update_script', 'doctor_script'):
                self.assertTrue((ROOT / tool[field]).is_file())
            if tid in ('fal_client', 'veo_api'):
                self.assertEqual(tool['deployment'], 'cloud')

    def test_existing_profile_and_tools_not_duplicated(self):
        profiles = json.loads((ROOT / 'config/profiles.yml').read_text(encoding='utf-8'))['profiles']
        profile, = [p for p in profiles if p['id'] == 'AI_Influencer']
        self.assertEqual(profile['status'], 'planned')
        self.assertFalse(profile['auto_install'])
        self.assertIn('veo_api', profile['optional_tools'])
        self.assertNotIn('veo_api', profile['tools'])
        tools = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        for tid in ('comfyui', 'n8n', 'activepieces', 'huginn', 'musetalk', 'liveportrait', 'sadtalker', 'localai', 'vllm'):
            self.assertEqual(sum(t['id'] == tid for t in tools), 1, tid)
        tool_ids = {t['id'] for t in tools}
        self.assertTrue(set(profile['tools'] + profile['optional_tools']) <= tool_ids)

    def test_plan_is_inactive(self):
        plan = json.loads((ROOT / 'examples/social_media/content-plan.example.json').read_text(encoding='utf-8'))
        self.assertTrue(plan['template_only'])
        for key in ('execution_enabled', 'cloud_enabled', 'automatic_cloud_fallback',
                    'publishing_enabled', 'upload_enabled', 'rights_approved',
                    'voice_consent_approved', 'preview_approved'):
            self.assertFalse(plan[key])
        self.assertEqual(plan['max_cloud_cost_per_job'], 0)
        self.assertEqual(plan['max_cloud_cost_per_day'], 0)
        self.assertEqual(plan['max_parallel_gpu_jobs'], 1)
        self.assertEqual(plan['provider'], 'local')

    def test_local_links(self):
        for relative in ('docs/media_studio/SOCIAL_AVATAR_AUTOMATION.md',
                         'docs/workflows/media/Social_Avatar_Content.md',
                         'docs/agents/media/AvatarAgent.md', 'docs/Profile/AI_Influencer.md'):
            doc = ROOT / relative
            for link in re.findall(r'\]\(([^)]+)\)', doc.read_text(encoding='utf-8')):
                if '://' not in link and not link.startswith('#'):
                    self.assertTrue((doc.parent / link.split('#')[0]).exists(), (relative, link))


@unittest.skipUnless(BASH and Path(BASH).exists(), 'Git Bash/bash unavailable')
class SocialGuards(unittest.TestCase):
    def invoke(self, mode, args):
        with tempfile.TemporaryDirectory() as temp:
            home = Path(temp) / 'unused-home'
            result = subprocess.run([str(BASH), '--noprofile', '--norc',
                                     'scripts/tools/social_media_candidate_' + mode + '.sh', *args],
                                    cwd=ROOT, env=dict(os.environ, HOME=str(home)),
                                    capture_output=True, text=True, timeout=30)
            self.assertFalse(home.exists())
        return result

    def test_runtime_actions_blocked(self):
        for mode in ('install', 'update', 'uninstall'):
            self.assertEqual(self.invoke(mode, []).returncode, 2)

    def test_checks_do_not_enable_cloud_or_publish(self):
        for mode, args in (('install', ['--dry-run']), ('check', []), ('doctor', []), ('status', [])):
            result = self.invoke(mode, args)
            self.assertEqual(result.returncode, 0, result.stderr)
            state = json.loads(result.stdout)
            self.assertEqual(state['status'], 'planned')
            for key in ('installed', 'network', 'cloud_enabled', 'publishing_enabled'):
                self.assertFalse(state[key])


if __name__ == '__main__':
    unittest.main()
