"""Offline docs/registry/guard tests; no installer execution, downloads or WSL."""
import hashlib
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
POWERSHELL = shutil.which('pwsh') or shutil.which('powershell')


class QwenDesktopDocs(unittest.TestCase):
    def test_registry_and_unique_menu_key(self):
        tools = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        tool, = [t for t in tools if t['id'] == 'qwen_desktop']
        self.assertEqual(tool['source'], 'https://github.com/QwenLM/qwen-code')
        self.assertEqual(tool['install_mode'], 'manual-windows')
        self.assertFalse(tool['auto_install'])
        self.assertEqual(tool['ports'], [])
        for field in ('doc', 'install_script', 'uninstall_script', 'update_script', 'doctor_script'):
            self.assertTrue((ROOT / tool[field]).is_file())
        menu = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        keys = re.findall(r'"([^"]+)"', ' '.join(re.findall(r'^TOOL_KEYS\+?=\((.*?)\)', menu, re.MULTILINE)))
        self.assertEqual(keys.count('Qwen_Desktop'), 1)
        self.assertIn('TOOL_SCRIPT_NAMES["Qwen_Desktop"]="qwen_desktop"', menu)
        self.assertIn('"Qwen_Desktop"', (ROOT / 'scripts/helpers/status_tracking.sh').read_text(encoding='utf-8'))

    def test_local_links_and_prior_candidate_docs(self):
        for relative in ('docs/tools/qwen-desktop-windows.md', 'docs/media_studio/HYBRID_MODELS_AND_WAN.md'):
            doc = ROOT / relative
            for link in re.findall(r'\]\(([^)]+)\)', doc.read_text(encoding='utf-8')):
                if '://' not in link and not link.startswith('#'):
                    self.assertTrue((doc.parent / link.split('#')[0]).exists(), (relative, link))
        entries = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        for tid in ('cline', 'qwen_code', 'wan21', 'comfyui_gguf', 'wanvideo_wrapper', 'supir', 'film'):
            tool, = [t for t in entries if t['id'] == tid]
            self.assertEqual(tool['status'], 'experimental' if tid in ('qwen_code', 'cline', 'wan21', 'comfyui_gguf', 'supir', 'film') else 'planned')
            self.assertTrue((ROOT / tool['doc']).is_file())

    def test_profile_optional(self):
        profiles = json.loads((ROOT / 'config/profiles.yml').read_text(encoding='utf-8'))['profiles']
        profile, = [p for p in profiles if p['id'] == 'Agentic_Coding_Local_First']
        self.assertIn('qwen_desktop', profile['optional_tools'])
        self.assertNotIn('qwen_desktop', profile['tools'])
        self.assertEqual(profile['status'], 'planned')

    def test_model_catalog_and_refinement_stay_inactive(self):
        catalog = json.loads((ROOT / 'config/model_candidates.json').read_text(encoding='utf-8'))
        self.assertEqual({f['id'] for f in catalog['families']},
                         {'deepseek', 'qwen', 'wan', 'glm', 'kimi', 'doubao'})
        for key in ('active', 'network_enabled', 'cloud_enabled', 'automatic_downloads'):
            self.assertFalse(catalog[key])
        for family in catalog['families']:
            self.assertFalse(family['automatic_download'])
            self.assertIsNone(family['revision'])
        plan = json.loads((ROOT / 'examples/hybrid_media/wan-refinement-plan.example.json').read_text(encoding='utf-8'))
        self.assertTrue(plan['template_only'])
        self.assertFalse(plan['execution_enabled'])
        self.assertEqual(plan['format'], 'design_plan_not_comfyui_workflow')

    @unittest.skipUnless(BASH and Path(BASH).exists(), 'Git Bash/bash unavailable')
    def test_shell_guards_no_installation(self):
        with tempfile.TemporaryDirectory() as temp:
            home = Path(temp) / 'unused-home'
            for mode, args, code in (('install', [], 3), ('uninstall', [], 2),
                                     ('update', [], 3), ('install', ['--dry-run'], 0),
                                     ('doctor', [], 0)):
                result = subprocess.run([str(BASH), '--noprofile', '--norc',
                                         'scripts/tools/qwen_desktop_' + mode + '.sh', *args],
                                        cwd=ROOT, env=dict(os.environ, HOME=str(home)),
                                        capture_output=True, text=True, timeout=30)
                self.assertEqual(result.returncode, code, result.stderr)
                if code == 0:
                    self.assertFalse(json.loads(result.stdout)['installed'])
            self.assertFalse(home.exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), 'Git Bash/bash unavailable')
class QwenDesktopDownload(unittest.TestCase):
    def invoke_mock(self, code):
        return subprocess.run([str(BASH), '--noprofile', '--norc', '-c',
                               'source scripts/tools/helpers/qwen_desktop_common.sh\n' + code],
                              cwd=ROOT, capture_output=True, text=True, timeout=30)

    def test_confirmed_prompt_opens_mock_only(self):
        result = self.invoke_mock('''
qwen_desktop_can_prompt() { return 0; }
qwen_desktop_open_download() { echo MOCK_BROWSER; }
qwen_desktop_main install <<< $'j\\n\\nj'
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), 'MOCK_BROWSER')
        self.assertIn('[(j)a/(N)ein]', result.stderr)
        self.assertIn('Setup pausiert', result.stderr)
        self.assertIn('vom Benutzer bestaetigt', result.stderr)

    def test_pause_eof_or_declined_completion_is_deferred(self):
        for answers in ('j', 'j\n\nN', 'j\n\n'):
            result = self.invoke_mock('''
qwen_desktop_can_prompt() { return 0; }
qwen_desktop_open_download() { echo MOCK_BROWSER; }
qwen_desktop_main update <<< ''' + "$'" + answers.replace('\n', '\\n') + "'\n")
            self.assertEqual(result.returncode, 3, result.stderr)
            self.assertIn('Setup pausiert', result.stderr)
            self.assertNotIn('vom Benutzer bestaetigt', result.stderr)

    def test_browser_failure_stops_before_confirmation(self):
        result = self.invoke_mock('''
qwen_desktop_can_prompt() { return 0; }
qwen_desktop_open_download() { return 1; }
qwen_desktop_main install <<< $'j\\n\\nj'
''')
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertNotIn('vom Benutzer bestaetigt', result.stderr)

    def test_menu_manual_completion_not_registered_as_verified(self):
        text = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        branch = text.split('if [ "$TOOL_KEY" = "Qwen_Desktop" ] && [ "$tool_rc" -eq 0 ]; then', 1)[1]
        branch = branch.split('elif [ "$tool_rc" -eq 0 ]; then', 1)[0]
        self.assertNotIn('append_unique_line', branch)
        self.assertIn('operation_status="skipped"', branch)

    def test_default_no_and_noninteractive_never_open(self):
        for answer in ('', 'N', 'nein'):
            result = self.invoke_mock('''
qwen_desktop_can_prompt() { return 0; }
qwen_desktop_open_download() { echo UNEXPECTED_BROWSER; }
qwen_desktop_main install <<< ''' + repr(answer) + '\n')
            self.assertEqual(result.returncode, 3)
            self.assertNotIn('UNEXPECTED_BROWSER', result.stdout)
        result = self.invoke_mock('''
qwen_desktop_can_prompt() { return 1; }
qwen_desktop_open_download() { echo UNEXPECTED_BROWSER; }
qwen_desktop_main update
''')
        self.assertEqual(result.returncode, 3)
        self.assertNotIn('UNEXPECTED_BROWSER', result.stdout)
        self.assertIn('--open-download', result.stderr)

    def test_explicit_option_dispatches_mock(self):
        result = self.invoke_mock('''
qwen_desktop_open_download() { echo MOCK_BROWSER; }
qwen_desktop_main --open-download
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('MOCK_BROWSER', result.stdout)
        self.assertIn('https://github.com/QwenLM/qwen-code/releases/tag/desktop-latest', result.stdout)

    def test_read_only_and_uninstall_never_open(self):
        for mode in ('--dry-run', 'status', 'doctor', 'uninstall'):
            result = self.invoke_mock('''
qwen_desktop_open_download() { echo UNEXPECTED_BROWSER; }
qwen_desktop_main ''' + mode)
            self.assertEqual(result.returncode, 2 if mode == 'uninstall' else 0)
            self.assertNotIn('UNEXPECTED_BROWSER', result.stdout)

    def test_wsl_fixed_url_via_mock_powershell(self):
        result = self.invoke_mock('''
export WSL_DISTRO_NAME=synthetic
powershell.exe() { printf 'MOCK_PS:%s\\n' "$@"; }
qwen_desktop_open_download
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Start-Process 'https://github.com/QwenLM/qwen-code/releases/tag/desktop-latest'", result.stdout)
        self.assertIn('-NoProfile', result.stdout)

    def test_mock_fallback_and_failure(self):
        result = self.invoke_mock('''
export WSL_DISTRO_NAME=synthetic
powershell.exe() { return 42; }
cmd.exe() { printf 'MOCK_CMD:%s\\n' "$@"; }
qwen_desktop_open_download
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('MOCK_CMD:start', result.stdout)
        result = self.invoke_mock('''
export WSL_DISTRO_NAME=synthetic
powershell.exe() { return 42; }
cmd.exe() { return 43; }
qwen_desktop_main --open-download
''')
        self.assertEqual(result.returncode, 1)
        self.assertIn('manuell oeffnen', result.stderr)


@unittest.skipUnless(os.name == 'nt' and POWERSHELL, 'Windows PowerShell unavailable')
class QwenDesktopPowerShell(unittest.TestCase):
    def invoke(self, *args):
        return subprocess.run([POWERSHELL, '-NoProfile', '-NonInteractive', '-File',
                               str(ROOT / 'scripts/windows/qwen_desktop.ps1'), *args],
                              cwd=ROOT, capture_output=True, text=True, timeout=30)

    def test_plan_only(self):
        result = self.invoke('-Action', 'Plan')
        self.assertEqual(result.returncode, 0, result.stderr)
        state = json.loads(result.stdout)
        for key in ('installed', 'executed', 'network'):
            self.assertFalse(state[key])

    def test_bad_hash_stops(self):
        with tempfile.TemporaryDirectory() as temp:
            fake = Path(temp) / 'Qwen-Code-Desktop_0.25.2_x64-setup.exe'
            fake.write_bytes(b'not an executable; synthetic test fixture')
            result = self.invoke('-Action', 'CheckInstaller', '-InstallerPath', str(fake),
                                 '-ExpectedSha256', '0' * 64)
            self.assertEqual(result.returncode, 1)

    def test_unsigned_fixture_stops_without_execution(self):
        with tempfile.TemporaryDirectory() as temp:
            content = b'not an executable; synthetic unsigned fixture'
            fake = Path(temp) / 'Qwen-Code-Desktop_0.25.2_x64-setup.exe'
            fake.write_bytes(content)
            result = self.invoke('-Action', 'CheckInstaller', '-InstallerPath', str(fake),
                                 '-ExpectedSha256', hashlib.sha256(content).hexdigest())
            self.assertEqual(result.returncode, 1)
            self.assertEqual(fake.read_bytes(), content)


if __name__ == '__main__':
    unittest.main()
