"""Registry, documentation and non-installing guards. No media runtime execution."""
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
IDS = ('alexandria_audiobook', 'qwen3_tts', 'chattts', 'audioldm2', 'audiogen',
       'stable_audio_open', 'moshi', 'moss_tts', 'yue', 'ace_step_15', 'whisperx',
       'aegisub', 'basic_pitch', 'sfizz', 'aida_x', 'propainter', 'kiwi_edit',
       'void_model', 'just_dub_it', 'vidubb')


class MediaCatalog(unittest.TestCase):
    def test_planned_tools_consistent(self):
        entries = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        menu = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        status = (ROOT / 'scripts/helpers/status_tracking.sh').read_text(encoding='utf-8')
        for tid in IDS:
            tool, = [t for t in entries if t['id'] == tid]
            self.assertEqual(tool['status'], 'experimental' if tid in ('vidubb', 'alexandria_audiobook', 'qwen3_tts', 'chattts', 'audioldm2', 'audiogen', 'stable_audio_open', 'moshi', 'just_dub_it', 'void_model', 'kiwi_edit', 'propainter', 'aida_x', 'sfizz', 'basic_pitch', 'aegisub', 'whisperx', 'ace_step_15', 'yue') else 'planned')
            self.assertEqual(tool['ports'], [])
            self.assertTrue(tool['source'].startswith('https://github.com/'))
            for field in ('doc', 'install_script', 'uninstall_script', 'update_script', 'doctor_script'):
                self.assertTrue((ROOT / tool[field]).is_file(), (tid, field))
            self.assertIn('"' + tool['name'] + '"', menu)
            self.assertIn('"' + tool['name'] + '"', status)
            script = tid if tid in ('vidubb', 'alexandria_audiobook', 'qwen3_tts', 'chattts', 'audioldm2', 'audiogen', 'stable_audio_open', 'moshi', 'just_dub_it', 'void_model', 'kiwi_edit', 'propainter', 'aida_x', 'sfizz', 'basic_pitch', 'aegisub', 'whisperx', 'ace_step_15', 'yue') else 'media_candidate'
            self.assertIn('TOOL_SCRIPT_NAMES["' + tool['name'] + '"]="' + script + '"', menu)
            if tid in ('propainter', 'void_model', 'kiwi_edit', 'yue'):
                self.assertEqual(tool['resource_class'], 'gpu-heavy')

    def test_profile_references(self):
        profiles = json.loads((ROOT / 'config/profiles.yml').read_text(encoding='utf-8'))['profiles']
        tools = {t['id'] for t in json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']}
        profile, = [p for p in profiles if p['id'] == 'Audio_Postproduction_Local_First']
        self.assertEqual(profile['status'], 'planned')
        for field in ('doc', 'install', 'uninstall'):
            self.assertTrue((ROOT / profile[field]).is_file())
        self.assertTrue(set(profile['tools'] + profile['optional_tools']) <= tools)
        menu = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        self.assertIn('PROFILE_KEYS+=("Audio_Postproduction_Local_First")', menu)

    def test_local_links(self):
        docs = list((ROOT / 'docs/media_studio').glob('*GUIDE.md'))
        docs += [ROOT / 'docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md',
                 ROOT / 'docs/Profile/Audio_Postproduction_Local_First.md',
                 ROOT / 'tools/karaoke_formats/README.md']
        for doc in docs:
            for link in re.findall(r'\]\(([^)]+)\)', doc.read_text(encoding='utf-8')):
                if '://' not in link and not link.startswith('#'):
                    self.assertTrue((doc.parent / link.split('#')[0]).exists(), (doc.name, link))

    @unittest.skipUnless(BASH and Path(BASH).exists(), 'Git Bash/bash unavailable')
    def test_guards_do_not_install_or_create_home(self):
        with tempfile.TemporaryDirectory() as temp:
            home = Path(temp) / 'unused-home'
            for mode in ('install', 'uninstall', 'update'):
                script = 'scripts/tools/media_candidate_' + mode + '.sh'
                for args, expected in (([], 2), (['--dry-run'], 0)):
                    result = subprocess.run([str(BASH), '--noprofile', '--norc', script, *args],
                                            cwd=ROOT, env=dict(os.environ, HOME=str(home)),
                                            capture_output=True, text=True, timeout=30)
                    self.assertEqual(result.returncode, expected, result.stderr)
                    if args:
                        self.assertFalse(json.loads(result.stdout)['installed'])
            self.assertFalse(home.exists())


if __name__ == '__main__':
    unittest.main()
