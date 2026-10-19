"""Offline custom-node lifecycle tests; no ComfyUI imports, pip/network or WSL."""
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
HELPER = ROOT / 'scripts/tools/helpers/comfyui_gguf_common.sh'


def shell_path(path):
    text = str(path).replace('\\', '/')
    return '/' + text[0].lower() + text[2:] if os.name == 'nt' else text


class GGUFContract(unittest.TestCase):
    def test_registry_and_menu(self):
        tool = next(t for t in json.loads((ROOT / 'config/tools.yml').read_text())['tools']
                    if t['id'] == 'comfyui_gguf')
        self.assertEqual(tool['status'], 'experimental')
        self.assertEqual(tool['install_mode'], 'source')
        self.assertFalse(tool['auto_install'])
        self.assertEqual(tool['ports'], [])
        self.assertIn(tool['source_commit'], HELPER.read_text())
        for field in ('doc', 'install_script', 'update_script', 'uninstall_script', 'doctor_script'):
            self.assertTrue((ROOT / tool[field]).is_file())
            self.assertNotIn('hybrid_media_candidate', tool[field])
        self.assertIn('TOOL_SCRIPT_NAMES["ComfyUI_GGUF"]="comfyui_gguf"',
                      (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8'))

    def test_dependencies_and_safety(self):
        text = HELPER.read_text()
        for token in ('https://github.com/city96/ComfyUI-GGUF.git', 'gguf==0.19.0',
                      'distributions()', 'packages-before.', '-c "$constraints"',
                      '--only-binary=:all:', 'flock -n 9', 'require_disk_mb 1024',
                      'GIT_TERMINAL_PROMPT=0', 'ast.parse', 'COMFYUI_GGUF_MODE'):
            self.assertIn(token, text)
        for forbidden in ('docker compose', 'rm -rf', 'pip install --upgrade',
                          'python main.py', 'import torch', 'sudo chown'):
            self.assertNotIn(forbidden, text)
        activate = text[text.index('cg_activate()'):text.index('cg_deactivate()')]
        self.assertLess(activate.index('cg_install_dependency'), activate.index('ln -s'))
        self.assertLess(activate.index('ln -s'), activate.index('> "$CG_MARKER"'))

    def test_document_links(self):
        doc = ROOT / 'docs/tools/comfyui-gguf.md'
        for link in re.findall(r'\]\(([^)]+)\)', doc.read_text(encoding='utf-8')):
            if '://' not in link and not link.startswith('#'):
                self.assertTrue((doc.parent / link.split('#')[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), 'Git Bash/bash unavailable')
class GGUFOffline(unittest.TestCase):
    def invoke(self, script, native_link=False):
        with tempfile.TemporaryDirectory() as temp:
            folder = Path(temp)
            if native_link:
                try:
                    (folder / 'link-probe-target').mkdir()
                    os.symlink(folder / 'link-probe-target', folder / 'link-probe', target_is_directory=True)
                except OSError:
                    self.skipTest('Native directory symlinks unavailable')
            env = dict(os.environ, MSYS='winsymlinks:nativestrict')
            prefix = f'''
source scripts/tools/helpers/comfyui_gguf_common.sh
export OPENCLAW_USER_DATA_DIR='{shell_path(folder / 'private')}'
export COMFYUI_ROOT='{shell_path(folder / 'comfy')}'
python3() {{ '{shell_path(Path(sys.executable))}' "$@"; }}
cg_paths
'''
            return subprocess.run([str(BASH), '--noprofile', '--norc', '-c', prefix + script],
                                  cwd=ROOT, env=env, capture_output=True, text=True, timeout=40)

    def fixture(self):
        return '''
mkdir -p "$CG_SOURCE" "$CG_COMFY/custom_nodes"
for name in __init__.py nodes.py loader.py ops.py dequant.py; do
    printf 'raise AssertionError("NEVER IMPORT")\\n' > "$CG_SOURCE/$name"
done
cg_source_ok() { return 0; }
'''

    def test_plan_status_no_creation_or_network(self):
        result = self.invoke('''
git() { echo UNEXPECTED_NETWORK; return 91; }
comfyui_gguf_main --dry-run
comfyui_gguf_main status
test ! -e "$OPENCLAW_USER_DATA_DIR"
test ! -e "$COMFYUI_ROOT"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('UNEXPECTED_NETWORK', result.stdout)
        self.assertIn('"integrated":false', result.stdout)

    def test_base_check_missing_custom_path_does_not_offer_wrong_base_target(self):
        r = self.invoke('git() { exit 99; }; comfyui_gguf_main --check-base')
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_base_check_does_not_confuse_bad_venv_with_missing_source(self):
        r = self.invoke('''
mkdir -p "$CG_COMFY/comfy" "$CG_COMFY/custom_nodes"
touch "$CG_COMFY/main.py"
git() { exit 99; }
cg_comfy_preflight() { return 1; }
comfyui_gguf_main --check-base
''')
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_base_check_success_does_not_create_plugin_workspace(self):
        r = self.invoke('''
mkdir -p "$CG_COMFY/comfy" "$CG_COMFY/custom_nodes"
touch "$CG_COMFY/main.py"
git() { exit 99; }
cg_comfy_preflight() { return 0; }
comfyui_gguf_main --check-base
test ! -e "$CG_BASE"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_missing_comfy_blocks(self):
        result = self.invoke('cg_comfy_preflight')
        self.assertEqual(result.returncode, 1)
        self.assertIn('ComfyUI fehlt', result.stderr)
        self.assertIn('main.py', result.stderr)
        self.assertIn('COMFYUI_GGUF_MODE=source', result.stderr)

    def test_explicit_root_does_not_fall_back(self):
        result = self.invoke('''
cg_candidate_paths() { echo /must-not-be-used; }
cg_paths
test "$CG_COMFY" = "$COMFYUI_ROOT"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_auto_root_and_dotvenv_without_running_python(self):
        result = self.invoke('''
mkdir -p "$CG_COMFY/comfy" "$CG_COMFY/.venv/bin"
touch "$CG_COMFY/main.py"
printf '#!/usr/bin/env bash\\nexit 99\\n' > "$CG_COMFY/.venv/bin/python"
chmod +x "$CG_COMFY/.venv/bin/python"
FOUND_ROOT="$CG_COMFY"
cg_candidate_paths() { printf '%s\\n' "$FOUND_ROOT"; }
unset COMFYUI_ROOT
cg_paths
test "$CG_COMFY" = "$FOUND_ROOT"
test "$CG_PYTHON" = "$FOUND_ROOT/.venv/bin/python"
test ! -e "$CG_BASE"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_ambiguous_roots_rejected(self):
        result = self.invoke('''
mkdir -p "$CG_COMFY/comfy" "$CG_COMFY/other/comfy"
touch "$CG_COMFY/main.py" "$CG_COMFY/other/main.py"
FIRST="$CG_COMFY"
cg_candidate_paths() { printf '%s\\n' "$FIRST" "$FIRST/other"; }
unset COMFYUI_ROOT
if cg_paths; then exit 99; fi
test ! -e "$CG_BASE"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Mehrere ComfyUI-Installationen', result.stderr)

    def test_ambiguous_venvs_rejected(self):
        result = self.invoke('''
mkdir -p "$CG_COMFY/venv/bin" "$CG_COMFY/.venv/bin"
for env in venv .venv; do
    printf '#!/usr/bin/env bash\\nexit 99\\n' > "$CG_COMFY/$env/bin/python"
    chmod +x "$CG_COMFY/$env/bin/python"
done
if cg_paths; then exit 99; fi
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Mehrere ComfyUI-venvs', result.stderr)

    def test_registered_paths_reused_without_overrides_or_scan(self):
        result = self.invoke('''
mkdir -p "$CG_BASE"
SAVED_COMFY="$CG_COMFY"
SAVED_PYTHON="$CG_COMFY/.venv/bin/python"
printf '%s\\n' "$CG_COMMIT" "$CG_TARGET" "$SAVED_PYTHON" > "$CG_MARKER"
unset COMFYUI_ROOT COMFYUI_GGUF_PYTHON_BIN
cg_candidate_paths() { echo SCAN_MUST_NOT_RUN >&2; return 99; }
cg_paths
test "$CG_COMFY" = "$SAVED_COMFY"
test "$CG_PYTHON" = "$SAVED_PYTHON"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('SCAN_MUST_NOT_RUN', result.stderr)

    def test_doctor_missing_fails(self):
        result = self.invoke('comfyui_gguf_main doctor')
        self.assertEqual(result.returncode, 1)

    def test_syntax_not_model_import(self):
        result = self.invoke(self.fixture() + 'cg_syntax')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_source_only_no_link_or_package(self):
        result = self.invoke(self.fixture() + '''
cg_fetch_source
test "$(cat "$CG_SOURCE_MARKER")" = "$CG_COMMIT"
test ! -e "$CG_TARGET"
test ! -e "$CG_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_foreign_target_preserved(self):
        result = self.invoke('''
mkdir -p "$CG_TARGET"
printf keep > "$CG_TARGET/own.txt"
if cg_paths; then exit 99; fi
test "$(cat "$CG_TARGET/own.txt")" = keep
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_wrong_registration_preserved(self):
        result = self.invoke('''
mkdir -p "$CG_BASE"
printf foreign > "$CG_MARKER"
if cg_paths; then exit 99; fi
test "$(cat "$CG_MARKER")" = foreign
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_existing_dependency_no_pip(self):
        result = self.invoke('''
cg_dependency_ok() { return 0; }
CG_PYTHON=must_not_execute
cg_install_dependency
test ! -e "$CG_BASE"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_dependency_failure_prevents_activation(self):
        result = self.invoke(self.fixture() + '''
cg_install_dependency() { return 42; }
if cg_activate; then exit 99; fi
test ! -e "$CG_TARGET"
test ! -L "$CG_TARGET"
test ! -e "$CG_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_missing_dependency_uses_constraints_with_mock_pip(self):
        result = self.invoke('''
mkdir -p "$CG_BASE"
cg_dependency_ok() { [[ "${NEW_GGUF:-0}" == 1 ]]; }
fake_python() {
    case "$*" in
        '-I -B -') printf 'torch==0.0.0\\nnumpy==1.0.0\\n' ;;
        *'pip --isolated install'*) printf '%s\\n' "$*" > "$CG_BASE/pip-args"; NEW_GGUF=1 ;;
        *'pip --isolated check'*) : ;;
        *) return 99 ;;
    esac
}
CG_PYTHON=fake_python
cg_install_dependency
grep -q -- '-c ' "$CG_BASE/pip-args"
grep -q -- 'gguf==0.19.0' "$CG_BASE/pip-args"
grep -q -- 'torch==0.0.0' "$CG_BASE"/packages-before.*.txt
test ! -e "$CG_TARGET"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_mock_package_conflict_keeps_marker_absent(self):
        result = self.invoke('''
mkdir -p "$CG_BASE"
cg_dependency_ok() { return 1; }
fake_python() {
    if [[ "$*" == '-I -B -' ]]; then printf 'gguf==0.12.0\\n'; else return 42; fi
}
CG_PYTHON=fake_python
if cg_install_dependency; then exit 99; fi
test ! -e "$CG_MARKER"
test ! -e "$CG_TARGET"
grep -q 'gguf==0.12.0' "$CG_BASE"/packages-before.*.txt
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_activate_and_deactivate_preserve_source_media(self):
        result = self.invoke(self.fixture() + '''
cg_install_dependency() { return 0; }
printf keep > "$CG_SOURCE/own-model.gguf"
cg_activate
test -L "$CG_TARGET"
test "$(readlink "$CG_TARGET")" = "$CG_SOURCE"
test -f "$CG_MARKER"
cg_paths
cg_deactivate
test ! -L "$CG_TARGET"
test ! -e "$CG_MARKER"
test "$(cat "$CG_SOURCE/own-model.gguf")" = keep
''', native_link=True)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_unlink_rechecks_foreign_target(self):
        result = self.invoke(self.fixture() + '''
mkdir "$CG_TARGET"
printf keep > "$CG_TARGET/own.txt"
if cg_deactivate; then exit 99; fi
test "$(cat "$CG_TARGET/own.txt")" = keep
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_start_rejected(self):
        result = self.invoke('comfyui_gguf_main start')
        self.assertEqual(result.returncode, 2)


if __name__ == '__main__':
    unittest.main()
