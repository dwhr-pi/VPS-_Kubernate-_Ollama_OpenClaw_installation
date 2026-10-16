"""Offline SUPIR source-only checks; no legacy packages, models, rendering or WSL."""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = Path('C:/Program Files/Git/bin/bash.exe') if os.name == 'nt' else shutil.which('bash')
HELPER = ROOT / 'scripts/tools/helpers/supir_common.sh'


def shell_path(path):
    text = str(path).replace('\\', '/')
    return '/' + text[0].lower() + text[2:] if os.name == 'nt' else text


class SupirContract(unittest.TestCase):
    def test_registry_and_menu(self):
        tool = next(t for t in json.loads((ROOT / 'config/tools.yml').read_text())['tools'] if t['id'] == 'supir')
        self.assertEqual(tool['status'], 'experimental')
        self.assertEqual(tool['install_mode'], 'source')
        self.assertFalse(tool['auto_install'])
        self.assertEqual(tool['ports'], [])
        self.assertIn(tool['source_commit'], HELPER.read_text())
        self.assertIn('SUPIR Software License Agreement', tool['license'])
        self.assertTrue(tool['check_value'].endswith('/source-ready'))
        for field in ('doc', 'install_script', 'update_script', 'uninstall_script', 'doctor_script'):
            self.assertTrue((ROOT / tool[field]).is_file())
            self.assertNotIn('hybrid_media_candidate', tool[field])
        self.assertIn('TOOL_SCRIPT_NAMES["SUPIR"]="supir"', (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8'))

    def test_safety_contract(self):
        text = HELPER.read_text()
        for token in ('https://github.com/Fanghua-Yu/SUPIR.git', 'GIT_TERMINAL_PROMPT=0',
                      'flock -n 9', 'require_disk_mb 1024', 'REQUIRE_WINDOWS_HOST_FREE_MB=2048',
                      'ast.parse', 'runtime_ready', 'supir_runtime_guard'):
            self.assertIn(token, text)
        for forbidden in ('docker compose', 'pip install', 'conda create',
                          'rm -rf', 'python test.py', 'import torch'):
            self.assertNotIn(forbidden, text)

    def test_docs_explain_limitations(self):
        doc = ROOT / 'docs/tools/supir.md'
        text = doc.read_text(encoding='utf-8')
        for value in ('0.95.1', '4.16.0', 'runtime_ready: false', '3.8',
                      'Lizenz', 'keine fertige', 'CKPT_PTH.py'):
            self.assertIn(value, text)
        for link in re.findall(r'\]\(([^)]+)\)', text):
            if '://' not in link and not link.startswith('#'):
                self.assertTrue((doc.parent / link.split('#')[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), 'Git Bash/bash unavailable')
class SupirOffline(unittest.TestCase):
    def invoke(self, code):
        with tempfile.TemporaryDirectory() as temp:
            root = shell_path(Path(temp) / 'private')
            python = shell_path(Path(sys.executable))
            prefix = f'''
source scripts/tools/helpers/supir_common.sh
export OPENCLAW_USER_DATA_DIR='{root}'
python3() {{ '{python}' "$@"; }}
supir_paths
'''
            return subprocess.run([str(BASH), '--noprofile', '--norc', '-c', prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=40)

    def fixture(self):
        return '''
mkdir -p "$SUPIR_SOURCE"
for name in test.py gradio_demo.py CKPT_PTH.py; do
    printf 'raise AssertionError("NEVER IMPORT")\\n' > "$SUPIR_SOURCE/$name"
done
printf fixture > "$SUPIR_SOURCE/LICENSE"
printf 'fastapi==0.95.1\\ngradio==4.16.0\\n' > "$SUPIR_SOURCE/requirements.txt"
supir_source_ok() { return 0; }
'''

    def test_plan_status_no_network_or_creation(self):
        result = self.invoke('''
git() { echo UNEXPECTED_NETWORK; return 99; }
supir_main --dry-run
supir_main status
test ! -e "$SUPIR_BASE"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('UNEXPECTED_NETWORK', result.stdout)
        self.assertIn('"runtime_ready":false', result.stdout)

    def test_missing_doctor_fails(self):
        result = self.invoke('supir_main doctor')
        self.assertEqual(result.returncode, 1)

    def test_inspection_does_not_import_code(self):
        result = self.invoke(self.fixture() + 'supir_inspect')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_source_registration_is_idempotent_no_runtime(self):
        result = self.invoke(self.fixture() + '''
supir_fetch_source
supir_fetch_source
test "$(cat "$SUPIR_MARKER")" = "$SUPIR_COMMIT"
test ! -e "$SUPIR_BASE/venv"
supir_main status
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('"source_ready":true', result.stdout)
        self.assertIn('"runtime_ready":false', result.stdout)

    def test_runtime_opt_in_fails_before_creation(self):
        result = self.invoke('''
SUPIR_INSTALL_RUNTIME=1 INSTALL_HEAVY_TOOLS=1 supir_main install
''')
        self.assertEqual(result.returncode, 2)
        self.assertIn('Pydantic', result.stderr)

    def test_runtime_guard_ignores_heavy_permission(self):
        result = self.invoke('''
SUPIR_INSTALL_RUNTIME=1
INSTALL_HEAVY_TOOLS=1
if supir_runtime_guard; then exit 99; fi
test ! -e "$SUPIR_BASE"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_foreign_checkout_preserved(self):
        result = self.invoke('''
mkdir -p "$SUPIR_SOURCE"
printf keep > "$SUPIR_SOURCE/own-file"
if supir_fetch_source; then exit 99; fi
test "$(cat "$SUPIR_SOURCE/own-file")" = keep
test ! -e "$SUPIR_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_invalid_syntax_no_success_marker(self):
        result = self.invoke(self.fixture() + '''
printf 'def broken(\\n' > "$SUPIR_SOURCE/test.py"
if supir_fetch_source; then exit 99; fi
test ! -e "$SUPIR_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_deactivation_preserves_models_and_sources(self):
        result = self.invoke(self.fixture() + '''
supir_fetch_source
printf keep > "$SUPIR_BASE/own-model.safetensors"
supir_deactivate
test ! -e "$SUPIR_MARKER"
test -f "$SUPIR_SOURCE/test.py"
test "$(cat "$SUPIR_BASE/own-model.safetensors")" = keep
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_start_blocked_and_unsafe_workspace_rejected(self):
        result = self.invoke('supir_main start')
        self.assertEqual(result.returncode, 2)
        result = self.invoke('OPENCLAW_USER_DATA_DIR=/; supir_paths')
        self.assertEqual(result.returncode, 1)


if __name__ == '__main__':
    unittest.main()
