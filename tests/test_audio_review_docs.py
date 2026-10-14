"""Offline registry/docs and non-processing guards. No audio or model access."""
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
IDS = ('pyannote_audio', 'deepfilternet', 'audioseal')


class AudioReviewDocs(unittest.TestCase):
    def test_registry_and_menu(self):
        tools = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        menu = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        status = (ROOT / 'scripts/helpers/status_tracking.sh').read_text(encoding='utf-8')
        keys = re.findall(r'"([^"]+)"', ' '.join(re.findall(r'^TOOL_KEYS\+?=\((.*?)\)', menu, re.MULTILINE)))
        for tid in IDS:
            tool, = [t for t in tools if t['id'] == tid]
            self.assertEqual(tool['status'], 'planned')
            self.assertFalse(tool['auto_install'])
            self.assertEqual(tool['ports'], [])
            self.assertTrue(tool['source'].startswith('https://github.com/'))
            for field in ('doc', 'install_script', 'uninstall_script', 'update_script', 'doctor_script'):
                self.assertTrue((ROOT / tool[field]).is_file())
            self.assertEqual(keys.count(tool['name']), 1)
            self.assertIn('"' + tool['name'] + '"', status)
            self.assertIn('TOOL_SCRIPT_NAMES["' + tool['name'] + '"]="audio_review_candidate"', menu)

    def test_existing_tools_not_duplicated(self):
        tools = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        for tid in ('demucs', 'uvr5', 'rvc', 'audacity'):
            tool, = [t for t in tools if t['id'] == tid]
            self.assertTrue((ROOT / tool['doc']).is_file())
        demucs, = [t for t in tools if t['id'] == 'demucs']
        self.assertIn('archiviert', demucs['maintenance_note'])
        self.assertEqual(demucs['install_script'], 'scripts/tools/demucs_install.sh')

    def test_profile_optional_only(self):
        profiles = json.loads((ROOT / 'config/profiles.yml').read_text(encoding='utf-8'))['profiles']
        profile, = [p for p in profiles if p['id'] == 'Audio_Postproduction_Local_First']
        self.assertEqual(profile['status'], 'planned')
        self.assertTrue(set(IDS) <= set(profile['optional_tools']))
        self.assertFalse(set(IDS) & set(profile['tools']))

    def test_local_links(self):
        for relative in ('docs/media_studio/AUDIO_DEEPFAKE_REVIEW.md',
                         'docs/workflows/media/Audio_Review_And_Redaction.md'):
            doc = ROOT / relative
            for link in re.findall(r'\]\(([^)]+)\)', doc.read_text(encoding='utf-8')):
                if '://' not in link and not link.startswith('#'):
                    self.assertTrue((doc.parent / link.split('#')[0]).exists(), (relative, link))


@unittest.skipUnless(BASH and Path(BASH).exists(), 'Git Bash/bash unavailable')
class AudioReviewGuards(unittest.TestCase):
    def invoke(self, mode, args):
        with tempfile.TemporaryDirectory() as temp:
            home = Path(temp) / 'unused-home'
            result = subprocess.run([str(BASH), '--noprofile', '--norc',
                                     'scripts/tools/audio_review_candidate_' + mode + '.sh', *args],
                                    cwd=ROOT, env=dict(os.environ, HOME=str(home)),
                                    capture_output=True, text=True, timeout=30)
            self.assertFalse(home.exists())
        return result

    def test_runtime_actions_blocked(self):
        for mode in ('install', 'update', 'uninstall'):
            self.assertEqual(self.invoke(mode, []).returncode, 2)

    def test_checks_never_process_or_judge(self):
        for mode, args in (('install', ['--dry-run']), ('check', []), ('doctor', []), ('status', [])):
            result = self.invoke(mode, args)
            self.assertEqual(result.returncode, 0, result.stderr)
            state = json.loads(result.stdout)
            self.assertEqual(state['status'], 'planned')
            self.assertIsNone(state['authenticity_verdict'])
            for key in ('installed', 'network', 'processing_enabled'):
                self.assertFalse(state[key])


if __name__ == '__main__':
    unittest.main()
