"""Mocked menu actions only: no packages, ComfyUI build or WSL."""
import os
from pathlib import Path
import shutil
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')


@unittest.skipUnless(BASH, 'Bash unavailable')
class Dependency(unittest.TestCase):
    def shell(self, code):
        prefix = '''set -euo pipefail
unset COMFYUI_ROOT COMFYUI_GGUF_MODE TOOL_BATCH_ABORT_REQUESTED
source scripts/helpers/comfyui_gguf_dependency.sh
install_tool() { exit 99; }
'''
        return subprocess.run([BASH, '--noprofile', '--norc', '-c', prefix + code], cwd=ROOT,
                              capture_output=True, text=True, encoding='utf-8', timeout=40)

    def test_existing_base_never_prompts_or_installs(self):
        r = self.shell('gguf_check_base() { return 0; }; gguf_read_dependency_choice() { exit 99; }; gguf_prepare_dependency')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_noninteractive_missing_base_does_not_install(self):
        r = self.shell('gguf_check_base() { return 3; }; gguf_prepare_dependency </dev/null')
        self.assertEqual(r.returncode, 3, r.stderr)

    def test_bad_venv_does_not_offer_base_reinstall(self):
        r = self.shell('gguf_check_base() { return 1; }; gguf_read_dependency_choice() { exit 99; }; gguf_prepare_dependency')
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_decline_and_invalid_choices_do_not_install(self):
        for choice in ('N', '', 'unexpected'):
            r = self.shell('gguf_check_base() { return 3; }; gguf_read_dependency_choice() { GGUF_DEPENDENCY_CHOICE="' + choice + '"; }; gguf_prepare_dependency')
            self.assertEqual(r.returncode, 3, r.stderr)

    def test_source_only_without_base_install(self):
        r = self.shell('''
gguf_check_base() { return 3; }
gguf_read_dependency_choice() { GGUF_DEPENDENCY_CHOICE=2; }
gguf_prepare_dependency
test "$COMFYUI_GGUF_MODE" = source
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_custom_target_is_not_overridden(self):
        r = self.shell('''
COMFYUI_ROOT=/somewhere/ComfyUI
gguf_check_base() { return 3; }
gguf_read_dependency_choice() { GGUF_DEPENDENCY_CHOICE=1; }
gguf_prepare_dependency
''')
        self.assertEqual(r.returncode, 3, r.stderr)

    def test_explicit_install_requires_successful_recheck(self):
        r = self.shell('''
ready=0
gguf_check_base() { [[ "$ready" == 1 ]] && return 0; return 3; }
gguf_read_dependency_choice() { GGUF_DEPENDENCY_CHOICE=1; }
install_tool() { [[ "$1" == ComfyUI ]] || return 99; ready=1; }
gguf_prepare_dependency
test "$ready" = 1
''')
        self.assertEqual(r.returncode, 0, r.stderr)
        r = self.shell('''
gguf_check_base() { return 3; }
gguf_read_dependency_choice() { GGUF_DEPENDENCY_CHOICE=1; }
install_tool() { return 0; }
gguf_prepare_dependency
''')
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_menu_guidance_precedes_measurement(self):
        menu = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        install = menu.split('install_tool() {', 1)[1].split('uninstall_tool() {', 1)[0]
        self.assertLess(install.index('gguf_prepare_dependency'), install.index('begin_operation_measurement'))
        branch = install.split('if [ "$TOOL_KEY" = ComfyUI_GGUF ] && [ "$COMFYUI_GGUF_MODE" = source ]', 1)[1].split('elif', 1)[0]
        self.assertNotIn('append_unique_line', branch)

    def test_user_abort_after_base_is_respected(self):
        r = self.shell('''
gguf_check_base() { return 3; }
gguf_read_dependency_choice() { GGUF_DEPENDENCY_CHOICE=1; }
install_tool() { TOOL_BATCH_ABORT_REQUESTED=1; }
gguf_prepare_dependency
''')
        self.assertEqual(r.returncode, 3, r.stderr)


if __name__ == '__main__':
    unittest.main()
