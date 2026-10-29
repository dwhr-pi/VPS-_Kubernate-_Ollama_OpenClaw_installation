"""Offline dataset registry, inactive template and guard checks; no HF calls."""
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
TOOLS = {'hf_datasets': 'HF_Datasets', 'hf_hub': 'HF_Hub', 'video2dataset': 'Video2Dataset'}


class VideoDatasetsDocs(unittest.TestCase):
    def test_registry_explicit_source_or_planned(self):
        tools = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        for tid in TOOLS:
            tool, = [t for t in tools if t['id'] == tid]
            self.assertEqual(tool['status'], 'experimental')
            self.assertFalse(tool['auto_install'])
            self.assertEqual(tool['ports'], [])
            self.assertEqual(tool['install_mode'], 'github-source' if tid == 'video2dataset' else 'source')
            self.assertTrue(tool['source'].startswith('https://github.com/'))
            for field in ('doc', 'install_script', 'uninstall_script', 'update_script', 'doctor_script'):
                self.assertTrue((ROOT / tool[field]).is_file(), (tid, field))

    def test_menu_and_status(self):
        menu = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        status = (ROOT / 'scripts/helpers/status_tracking.sh').read_text(encoding='utf-8')
        for name in TOOLS.values():
            self.assertIn('"' + name + '"', menu)
            self.assertIn('"' + name + '"', status)
            script = {'HF_Datasets': 'hf_datasets', 'HF_Hub': 'hf_hub', 'Video2Dataset': 'video2dataset'}[name]
            self.assertIn('TOOL_SCRIPT_NAMES["' + name + '"]="' + script + '"', menu)

    def test_existing_profile_reused(self):
        profiles = json.loads((ROOT / 'config/profiles.yml').read_text(encoding='utf-8'))['profiles']
        profile, = [p for p in profiles if p['id'] == 'Dataset_Curator']
        self.assertEqual(profile['status'], 'planned')
        self.assertFalse(profile['auto_install'])
        self.assertTrue(set(TOOLS) <= set(profile['optional_tools']))
        self.assertFalse(set(TOOLS) & set(profile['tools']))
        self.assertEqual(profile['tools'], ['docling', 'unstructured', 'duckdb'])

    def test_example_is_inactive(self):
        example = json.loads((ROOT / 'examples/video_datasets/review.example.json').read_text(encoding='utf-8'))
        self.assertTrue(example['template_only'])
        for key in ('network_enabled', 'training_enabled', 'automatic_uploads'):
            self.assertFalse(example[key])
        for key in ('max_download_bytes', 'dataset_revision', 'private_cache_path', 'private_output_path'):
            self.assertIsNone(example[key])
        self.assertEqual(example['rights_review'], 'pending')
        self.assertEqual(example['max_parallel_jobs'], 1)

    def test_local_links_and_source_catalog(self):
        doc = ROOT / 'docs/media_studio/VIDEO_TRAINING_DATASETS.md'
        text = doc.read_text(encoding='utf-8')
        for link in re.findall(r'\]\(([^)]+)\)', text):
            if '://' not in link and not link.startswith('#'):
                self.assertTrue((doc.parent / link.split('#')[0]).exists(), link)
        for source in ('HuggingFaceFV/finevideo', 'Fudan-FUXI/VIDGEN-1M',
                       'snap-research/Panda-70M', 'TencentARC/MiraData', 'ontocord/VALID'):
            self.assertIn(source, text)


@unittest.skipUnless(BASH and Path(BASH).exists(), 'Git Bash/bash unavailable')
class VideoDatasetGuards(unittest.TestCase):
    def invoke(self, mode, args):
        with tempfile.TemporaryDirectory() as temp:
            home = Path(temp) / 'unused-home'
            result = subprocess.run([str(BASH), '--noprofile', '--norc',
                                     'scripts/tools/video_dataset_candidate_' + mode + '.sh', *args],
                                    cwd=ROOT, env=dict(os.environ, HOME=str(home)),
                                    capture_output=True, text=True, timeout=30)
            self.assertFalse(home.exists())
        return result

    def test_install_update_uninstall_blocked(self):
        for mode in ('install', 'update', 'uninstall'):
            with self.subTest(mode=mode):
                self.assertEqual(self.invoke(mode, []).returncode, 2)

    def test_dry_run_and_checks_do_not_claim_installation(self):
        for mode, args in (('install', ['--dry-run']), ('check', []), ('doctor', []), ('status', [])):
            result = self.invoke(mode, args)
            self.assertEqual(result.returncode, 0, result.stderr)
            state = json.loads(result.stdout)
            self.assertEqual(state['status'], 'planned')
            for key in ('installed', 'network', 'training_enabled'):
                self.assertFalse(state[key])


if __name__ == '__main__':
    unittest.main()
