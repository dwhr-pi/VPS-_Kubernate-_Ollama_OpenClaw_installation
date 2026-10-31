"""Synthetic source/runtime contracts; no CUDA, packages, models, WSL or network."""
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
HELPER = ROOT / 'scripts/tools/helpers/wan21_common.sh'


def shell_path(path):
    text = str(path).replace('\\', '/')
    return '/' + text[0].lower() + text[2:] if os.name == 'nt' else text


class WanContract(unittest.TestCase):
    def test_registry_and_menu(self):
        tool = next(t for t in json.loads((ROOT / 'config/tools.yml').read_text())['tools'] if t['id'] == 'wan21')
        self.assertEqual(tool['status'], 'experimental')
        self.assertEqual(tool['install_mode'], 'source')
        self.assertFalse(tool['auto_install'])
        self.assertEqual(tool['resource_class'], 'gpu-heavy')
        self.assertEqual(tool['ports'], [])
        self.assertIn(tool['source_commit'], HELPER.read_text())
        self.assertTrue(tool['check_value'].endswith('/source-ready'))
        for field in ('install_script', 'update_script', 'uninstall_script', 'doctor_script', 'doc'):
            self.assertTrue((ROOT / tool[field]).is_file())
            self.assertNotIn('hybrid_media_candidate', tool[field])
        self.assertIn('TOOL_SCRIPT_NAMES["Wan21"]="wan21"', (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8'))

    def test_guards_and_dependency_contract(self):
        text = HELPER.read_text()
        for token in ('https://github.com/Wan-Video/Wan2.1.git', 'WAN21_INSTALL_RUNTIME',
                      'INSTALL_HEAVY_TOOLS', 'require_ram_mb 16384', 'require_disk_mb 32768',
                      'GIT_TERMINAL_PROMPT=0', 'flock -n 9', 'ast.parse',
                      'torch==2.10.0', 'torchvision==0.25.0', 'numpy==1.26.4',
                      '--no-build-isolation', 'flash-attn', 'HF_HUB_OFFLINE=1',
                      'git -C "$WAN21_SOURCE" archive'):
            self.assertIn(token, text)
        for token in ('docker compose', 'snapshot_download', 'huggingface-cli download',
                      'python generate.py', 'rm -rf', 'sudo apt'):
            self.assertNotIn(token, text)
        start = text.index('wan21_install_runtime()')
        self.assertLess(text.index('pip --isolated check', start),
                        re.search(r'>\s*"\$WAN21_RUNTIME_MARKER"', text[start:]).start() + start)

    def test_document_links(self):
        doc = ROOT / 'docs/tools/wan21.md'
        for link in re.findall(r'\]\(([^)]+)\)', doc.read_text(encoding='utf-8')):
            if '://' not in link and not link.startswith('#'):
                self.assertTrue((doc.parent / link.split('#')[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), 'Git Bash/bash unavailable')
class WanOffline(unittest.TestCase):
    def invoke(self, script):
        with tempfile.TemporaryDirectory() as temp:
            folder = Path(temp)
            prefix = f'''
source scripts/tools/helpers/wan21_common.sh
export OPENCLAW_USER_DATA_DIR='{shell_path(folder / 'private')}'
python3() {{ '{shell_path(Path(sys.executable))}' "$@"; }}
WAN21_PYTHON=python3
wan21_paths
'''
            return subprocess.run([str(BASH), '--noprofile', '--norc', '-c', prefix + script],
                                  cwd=ROOT, capture_output=True, text=True, timeout=40)

    def source_fixture(self):
        return '''
mkdir -p "$WAN21_SOURCE/wan/modules"
printf 'raise AssertionError("must never import")\\n' > "$WAN21_SOURCE/generate.py"
printf 'raise AssertionError("must never import")\\n' > "$WAN21_SOURCE/wan/modules/model.py"
printf 'raise AssertionError("must never import")\\n' > "$WAN21_SOURCE/wan/modules/attention.py"
touch "$WAN21_SOURCE/requirements.txt"
wan21_source_ok() { return 0; }
'''

    def test_plan_and_status_create_nothing(self):
        result = self.invoke('''
git() { echo UNEXPECTED_GIT; return 91; }
wan21_main --dry-run
wan21_main status
test ! -e "$OPENCLAW_USER_DATA_DIR"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('UNEXPECTED_GIT', result.stdout)
        self.assertIn('"source_ready":false', result.stdout)

    def test_doctor_missing_fails_without_creation(self):
        result = self.invoke('wan21_main doctor')
        self.assertEqual(result.returncode, 1)

    def test_syntax_checks_do_not_import_model(self):
        result = self.invoke(self.source_fixture() + 'wan21_source_check')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_source_ready_is_not_runtime_ready(self):
        result = self.invoke(self.source_fixture() + '''
wan21_fetch_source
test "$(cat "$WAN21_MARKER")" = "$WAN21_COMMIT"
test ! -e "$WAN21_RUNTIME_MARKER"
test ! -e "$WAN21_VENV"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_foreign_source_preserved(self):
        result = self.invoke('''
mkdir -p "$WAN21_SOURCE"
printf keep > "$WAN21_SOURCE/own.txt"
if wan21_fetch_source; then exit 99; fi
test "$(cat "$WAN21_SOURCE/own.txt")" = keep
test ! -e "$WAN21_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_heavy_preflight_requires_opt_in_before_gpu(self):
        result = self.invoke('''
INSTALL_HEAVY_TOOLS=0
nvidia-smi() { echo UNEXPECTED_GPU; return 99; }
wan21_runtime_preflight
''')
        self.assertEqual(result.returncode, 1)
        self.assertNotIn('UNEXPECTED_GPU', result.stdout)

    def test_unknown_runtime_start_blocked(self):
        result = self.invoke('wan21_main start')
        self.assertEqual(result.returncode, 2)

    def test_unsafe_workspace_rejected(self):
        result = self.invoke('OPENCLAW_USER_DATA_DIR=/; wan21_paths')
        self.assertEqual(result.returncode, 1)

    def test_mock_runtime_sequence(self):
        result = self.invoke('''
mkdir -p "$WAN21_SOURCE" "$WAN21_VENV/bin"
touch "$WAN21_VENV/pyvenv.cfg"
git() { :; }; tar() { :; }
fake_python() { :; }; WAN21_PYTHON=fake_python
printf '#!/usr/bin/env bash\nprintf "%%s\\n" "$*" >> "$OPENCLAW_USER_DATA_DIR/pip-args"\n' > "$WAN21_VENV/bin/python"
chmod +x "$WAN21_VENV/bin/python"
wan21_install_runtime
test "$(cat "$WAN21_RUNTIME_MARKER")" = "$WAN21_COMMIT"
grep -q 'torch==2.10.0' "$OPENCLAW_USER_DATA_DIR/pip-args"
grep -q 'flash-attn' "$OPENCLAW_USER_DATA_DIR/pip-args"
grep -q 'pip --isolated check' "$OPENCLAW_USER_DATA_DIR/pip-args"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_mock_runtime_failure_removes_marker(self):
        result = self.invoke('''
mkdir -p "$WAN21_SOURCE" "$WAN21_VENV/bin"
touch "$WAN21_VENV/pyvenv.cfg"
printf old > "$WAN21_RUNTIME_MARKER"
git() { :; }; tar() { :; }
fake_python() { :; }; WAN21_PYTHON=fake_python
printf '#!/usr/bin/env bash\nexit 42\n' > "$WAN21_VENV/bin/python"
chmod +x "$WAN21_VENV/bin/python"
set +e
(set -e; wan21_install_runtime)
rc=$?
test "$rc" = 42 && test ! -e "$WAN21_RUNTIME_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
