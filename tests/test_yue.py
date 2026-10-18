"""Offline source checkout tests. No upstream downloads, imports, pip, or WSL."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')
HELPER = 'scripts/tools/helpers/yue_common.sh'


def shell_path(path):
    value = str(path).replace('\\', '/')
    return '/' + value[0].lower() + value[2:] if os.name == 'nt' else value


class Contract(unittest.TestCase):
    def test_registry_source_and_no_runtime(self):
        tool, = [t for t in json.loads((ROOT / 'config/tools.yml').read_text())['tools'] if t['id'] == 'yue']
        self.assertEqual(tool['status'], 'experimental')
        self.assertFalse(tool['auto_install'])
        self.assertEqual(tool['ports'], [])
        for field in ('install_script', 'update_script', 'uninstall_script', 'doctor_script', 'doc'):
            self.assertTrue((ROOT / tool[field]).is_file())
        text = (ROOT / HELPER).read_text()
        self.assertIn('YU_COMMIT=' + tool['source_commit'], text)
        for token in ('--filter=blob:none', 'GIT_LFS_SKIP_SMUDGE=1', 'yu_sparse_patterns',
                      'ast.parse', 'YUE_INSTALL_RUNTIME', 'flock -n 9',
                      'require_disk_mb 1024', 'REQUIRE_WINDOWS_HOST_FREE_MB=2048'):
            self.assertIn(token, text)
        for forbidden in ('import app', 'import inference', 'pip install', 'docker compose',
                          'rm -rf', 'python app.py', 'python inference.py'):
            self.assertNotIn(forbidden, text)


@unittest.skipUnless(BASH and Path(BASH).exists(), 'Bash unavailable')
class Offline(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as temp:
            prefix = f'''
export OPENCLAW_USER_DATA_DIR='{shell_path(Path(temp) / 'private')}'
source {HELPER}
python3() {{ '{shell_path(Path(sys.executable))}' "$@"; }}
yu_paths
'''
            return subprocess.run([BASH, '--noprofile', '--norc', '-c', prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=90)

    def test_plan_and_status_no_creation(self):
        result = self.shell('''
git() { exit 99; }
yue_main --dry-run
yue_main status
test ! -e "$YU_BASE"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('"runtime_ready":false', result.stdout)

    def test_doctor_missing_and_start_blocked(self):
        for action, rc in (('doctor', 1), ('start', 2)):
            result = self.shell('yue_main ' + action)
            self.assertEqual(result.returncode, rc, result.stderr)

    def test_runtime_opt_in_still_blocked(self):
        result = self.shell('YUE_INSTALL_RUNTIME=1 yue_main install')
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertIn('GPU-Stack', result.stderr)

    def test_source_syntax_without_import(self):
        result = self.shell('''
mkdir -p "$YU_SOURCE/inference" "$YU_SOURCE/unused"
printf 'raise AssertionError("NEVER IMPORT")\\n' > "$YU_SOURCE/inference/infer.py"
cp "$YU_SOURCE/inference/infer.py" "$YU_SOURCE/inference/mmtokenizer.py"
cp "$YU_SOURCE/inference/infer.py" "$YU_SOURCE/inference/codecmanipulator.py"
touch "$YU_SOURCE/requirements.txt" "$YU_SOURCE/LICENSE"
yu_source_ok() { return 0; }
yu_inspect
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_foreign_source_preserved(self):
        result = self.shell('''
mkdir -p "$YU_SOURCE"
echo keep > "$YU_SOURCE/own-file"
if yu_fetch; then exit 99; fi
test "$(cat "$YU_SOURCE/own-file")" = keep
test ! -e "$YU_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_deactivate_preserves_files(self):
        result = self.shell('''
mkdir -p "$YU_SOURCE"
touch "$YU_MARKER" "$YU_SOURCE/own-file"
yu_deactivate
test ! -e "$YU_MARKER" && test -f "$YU_SOURCE/own-file"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_unsafe_root_rejected(self):
        result = self.shell('OPENCLAW_USER_DATA_DIR=/ yue_main --dry-run')
        self.assertNotEqual(result.returncode, 0)

    def test_keys_not_inherited_by_installer_subshell(self):
        result = self.shell('''
mkdir -p "$YU_BASE"
printf '%s\\n' "$YU_COMMIT" > "$YU_MARKER"
export GEMINI_API_KEY=SYNTHETIC_TEST_ONLY GOOGLE_API_KEY=SYNTHETIC_TEST_ONLY HF_TOKEN=SYNTHETIC_TEST_ONLY
yu_source_ok() { [[ ! -v GEMINI_API_KEY && ! -v GOOGLE_API_KEY && ! -v HF_TOKEN && "$HF_HUB_OFFLINE" == 1 ]]; }
yue_main status
test "$GEMINI_API_KEY" = SYNTHETIC_TEST_ONLY
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(json.loads(result.stdout)['source_ready'])
        self.assertNotIn('SYNTHETIC_TEST_ONLY', result.stdout)

    def test_cloud_and_gpu_limits_documented(self):
        doc = (ROOT / 'docs/tools/yue.md').read_text(encoding='utf-8')
        for word in ('YuE-v1', 'YuE2', 'xcodec', 'Apache-2.0', 'source_ready', 'runtime_ready', 'Sparse-Checkout'):
            self.assertIn(word, doc)

    def test_sparse_policy_on_unborn_repo(self):
        result = self.shell('''
mkdir -p "$YU_SOURCE"
git -c init.defaultBranch=main init "$YU_SOURCE"
yu_sparse_checkout
test "$(git -C "$YU_SOURCE" config --bool core.sparseCheckout)" = true
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_real_local_sparse_checkout_excludes_env_and_media(self):
        result = self.shell('''
mkdir -p "$YU_SOURCE/inference" "$YU_SOURCE/inference" "$YU_SOURCE/sample" "$YU_SOURCE/assets" "$YU_SOURCE/unused" "$YU_SOURCE/prompt_egs"
git -c init.defaultBranch=main init "$YU_SOURCE"
printf 'SYNTHETIC_TEST_ONLY\\n' > "$YU_SOURCE/.env"
touch "$YU_SOURCE/inference/infer.py" "$YU_SOURCE/inference/helper.py" "$YU_SOURCE/prompt_egs/settings.py" "$YU_SOURCE/README.md" "$YU_SOURCE/LICENSE" "$YU_SOURCE/requirements.txt"
touch "$YU_SOURCE/sample/test.mp4" "$YU_SOURCE/assets/test.png" "$YU_SOURCE/inference/test.safetensors" "$YU_SOURCE/notebook.ipynb" "$YU_SOURCE/unused/test.env"
git -C "$YU_SOURCE" add .
git -c core.hooksPath=/dev/null -c commit.gpgsign=false -c user.name=Fixture -c user.email=fixture@example.org -C "$YU_SOURCE" commit -m fixture
yu_sparse_checkout
test -f "$YU_SOURCE/inference/infer.py" && test -f "$YU_SOURCE/inference/helper.py" && test -f "$YU_SOURCE/prompt_egs/settings.py"
test ! -e "$YU_SOURCE/.env"
test ! -e "$YU_SOURCE/sample/test.mp4"
test ! -e "$YU_SOURCE/assets/test.png"
test ! -e "$YU_SOURCE/inference/test.safetensors"
test ! -e "$YU_SOURCE/notebook.ipynb"
''')
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
