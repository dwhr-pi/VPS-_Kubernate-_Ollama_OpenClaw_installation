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
HELPER = 'scripts/tools/helpers/void_model_common.sh'


def shell_path(path):
    value = str(path).replace('\\', '/')
    return '/' + value[0].lower() + value[2:] if os.name == 'nt' else value


class Contract(unittest.TestCase):
    def test_registry_source_and_no_runtime(self):
        tool, = [t for t in json.loads((ROOT / 'config/tools.yml').read_text())['tools'] if t['id'] == 'void_model']
        self.assertEqual(tool['status'], 'experimental')
        self.assertFalse(tool['auto_install'])
        self.assertEqual(tool['ports'], [])
        for field in ('install_script', 'update_script', 'uninstall_script', 'doctor_script', 'doc'):
            self.assertTrue((ROOT / tool[field]).is_file())
        text = (ROOT / HELPER).read_text()
        self.assertIn('VO_COMMIT=' + tool['source_commit'], text)
        for token in ('--filter=blob:none', 'GIT_LFS_SKIP_SMUDGE=1', 'vo_sparse_patterns',
                      'ast.parse', 'VOID_MODEL_INSTALL_RUNTIME', 'flock -n 9',
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
vo_paths
'''
            return subprocess.run([BASH, '--noprofile', '--norc', '-c', prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=90)

    def test_plan_and_status_no_creation(self):
        result = self.shell('''
git() { exit 99; }
void_model_main --dry-run
void_model_main status
test ! -e "$VO_BASE"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('"runtime_ready":false', result.stdout)

    def test_doctor_missing_and_start_blocked(self):
        for action, rc in (('doctor', 1), ('start', 2)):
            result = self.shell('void_model_main ' + action)
            self.assertEqual(result.returncode, rc, result.stderr)

    def test_runtime_opt_in_still_blocked(self):
        result = self.shell('VOID_MODEL_INSTALL_RUNTIME=1 void_model_main install')
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertIn('GPU-Laufzeit', result.stderr)

    def test_source_syntax_without_import(self):
        result = self.shell('''
mkdir -p "$VO_SOURCE/inference/cogvideox_fun" "$VO_SOURCE/VLM-MASK-REASONER"
printf 'raise AssertionError("NEVER IMPORT")\\n' > "$VO_SOURCE/inference/cogvideox_fun/predict_v2v.py"
cp "$VO_SOURCE/inference/cogvideox_fun/predict_v2v.py" "$VO_SOURCE/inference/cogvideox_fun/inference_with_pass1_warped_noise.py"
cp "$VO_SOURCE/inference/cogvideox_fun/predict_v2v.py" "$VO_SOURCE/VLM-MASK-REASONER/stage2_vlm_analysis.py"
touch "$VO_SOURCE/requirements.txt" "$VO_SOURCE/LICENSE"
vo_source_ok() { return 0; }
vo_inspect
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_foreign_source_preserved(self):
        result = self.shell('''
mkdir -p "$VO_SOURCE"
echo keep > "$VO_SOURCE/own-file"
if vo_fetch; then exit 99; fi
test "$(cat "$VO_SOURCE/own-file")" = keep
test ! -e "$VO_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_deactivate_preserves_files(self):
        result = self.shell('''
mkdir -p "$VO_SOURCE"
touch "$VO_MARKER" "$VO_SOURCE/own-file"
vo_deactivate
test ! -e "$VO_MARKER" && test -f "$VO_SOURCE/own-file"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_unsafe_root_rejected(self):
        result = self.shell('OPENCLAW_USER_DATA_DIR=/ void_model_main --dry-run')
        self.assertNotEqual(result.returncode, 0)

    def test_keys_not_inherited_by_installer_subshell(self):
        result = self.shell('''
mkdir -p "$VO_BASE"
printf '%s\\n' "$VO_COMMIT" > "$VO_MARKER"
export GEMINI_API_KEY=SYNTHETIC_TEST_ONLY GOOGLE_API_KEY=SYNTHETIC_TEST_ONLY HF_TOKEN=SYNTHETIC_TEST_ONLY
vo_source_ok() { [[ ! -v GEMINI_API_KEY && ! -v GOOGLE_API_KEY && ! -v HF_TOKEN && "$HF_HUB_OFFLINE" == 1 ]]; }
void_model_main status
test "$GEMINI_API_KEY" = SYNTHETIC_TEST_ONLY
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(json.loads(result.stdout)['source_ready'])
        self.assertNotIn('SYNTHETIC_TEST_ONLY', result.stdout)

    def test_cloud_and_gpu_limits_documented(self):
        doc = (ROOT / 'docs/tools/void-model.md').read_text(encoding='utf-8')
        for word in ('40 GB+', 'Gemini', 'Apache-2.0', 'source_ready', 'runtime_ready', 'Sparse-Checkout'):
            self.assertIn(word, doc)

    def test_sparse_policy_on_unborn_repo(self):
        result = self.shell('''
mkdir -p "$VO_SOURCE"
git -c init.defaultBranch=main init "$VO_SOURCE"
vo_sparse_checkout
test "$(git -C "$VO_SOURCE" config --bool core.sparseCheckout)" = true
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_real_local_sparse_checkout_excludes_env_and_media(self):
        result = self.shell('''
mkdir -p "$VO_SOURCE/inference/cogvideox_fun" "$VO_SOURCE/videox_fun" "$VO_SOURCE/sample" "$VO_SOURCE/assets" "$VO_SOURCE/VLM-MASK-REASONER" "$VO_SOURCE/config"
git -c init.defaultBranch=main init "$VO_SOURCE"
printf 'SYNTHETIC_TEST_ONLY\\n' > "$VO_SOURCE/.env"
touch "$VO_SOURCE/inference/cogvideox_fun/predict_v2v.py" "$VO_SOURCE/videox_fun/helper.py" "$VO_SOURCE/config/settings.py" "$VO_SOURCE/README.md" "$VO_SOURCE/LICENSE" "$VO_SOURCE/requirements.txt"
touch "$VO_SOURCE/sample/test.mp4" "$VO_SOURCE/assets/test.png" "$VO_SOURCE/videox_fun/test.safetensors" "$VO_SOURCE/notebook.ipynb" "$VO_SOURCE/VLM-MASK-REASONER/test.env"
git -C "$VO_SOURCE" add .
git -c core.hooksPath=/dev/null -c commit.gpgsign=false -c user.name=Fixture -c user.email=fixture@example.org -C "$VO_SOURCE" commit -m fixture
vo_sparse_checkout
test -f "$VO_SOURCE/inference/cogvideox_fun/predict_v2v.py" && test -f "$VO_SOURCE/videox_fun/helper.py" && test -f "$VO_SOURCE/config/settings.py"
test ! -e "$VO_SOURCE/.env"
test ! -e "$VO_SOURCE/sample/test.mp4"
test ! -e "$VO_SOURCE/assets/test.png"
test ! -e "$VO_SOURCE/videox_fun/test.safetensors"
test ! -e "$VO_SOURCE/notebook.ipynb"
''')
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
