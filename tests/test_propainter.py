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
HELPER = 'scripts/tools/helpers/propainter_common.sh'


def shell_path(path):
    value = str(path).replace('\\', '/')
    return '/' + value[0].lower() + value[2:] if os.name == 'nt' else value


class Contract(unittest.TestCase):
    def test_registry_source_and_no_runtime(self):
        tool, = [t for t in json.loads((ROOT / 'config/tools.yml').read_text())['tools'] if t['id'] == 'propainter']
        self.assertEqual(tool['status'], 'experimental')
        self.assertFalse(tool['auto_install'])
        self.assertEqual(tool['ports'], [])
        for field in ('install_script', 'update_script', 'uninstall_script', 'doctor_script', 'doc'):
            self.assertTrue((ROOT / tool[field]).is_file())
        text = (ROOT / HELPER).read_text()
        self.assertIn('PP_COMMIT=' + tool['source_commit'], text)
        for token in ('--filter=blob:none', 'GIT_LFS_SKIP_SMUDGE=1', 'pp_sparse_patterns',
                      'ast.parse', 'PROPAINTER_INSTALL_RUNTIME', 'flock -n 9',
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
pp_paths
'''
            return subprocess.run([BASH, '--noprofile', '--norc', '-c', prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=90)

    def test_plan_and_status_no_creation(self):
        result = self.shell('''
git() { exit 99; }
propainter_main --dry-run
propainter_main status
test ! -e "$PP_BASE"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('"runtime_ready":false', result.stdout)

    def test_doctor_missing_and_start_blocked(self):
        for action, rc in (('doctor', 1), ('start', 2)):
            result = self.shell('propainter_main ' + action)
            self.assertEqual(result.returncode, rc, result.stderr)

    def test_runtime_opt_in_still_blocked(self):
        result = self.shell('PROPAINTER_INSTALL_RUNTIME=1 propainter_main install')
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertIn('Torch-/Video-Abhaengigkeiten', result.stderr)

    def test_license_gate_before_downloads(self):
        result = self.shell('''
unset PROPAINTER_ACCEPT_LICENSE
git() { exit 99; }
propainter_main install
''')
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertIn('PROPAINTER_ACCEPT_LICENSE=1', result.stderr)

    def test_plan_mentions_noncommercial_license(self):
        result = self.shell('propainter_main --dry-run')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('nichtkommerziell', result.stdout)

    def test_source_syntax_without_import(self):
        result = self.shell('''
mkdir -p "$PP_SOURCE/model"
printf 'raise AssertionError("NEVER IMPORT")\\n' > "$PP_SOURCE/inference_propainter.py"
cp "$PP_SOURCE/inference_propainter.py" "$PP_SOURCE/model/recurrent_flow_completion.py"
cp "$PP_SOURCE/inference_propainter.py" "$PP_SOURCE/model/propainter.py"
touch "$PP_SOURCE/requirements.txt" "$PP_SOURCE/LICENSE"
pp_source_ok() { return 0; }
pp_inspect
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_foreign_source_preserved(self):
        result = self.shell('''
mkdir -p "$PP_SOURCE"
echo keep > "$PP_SOURCE/own-file"
if pp_fetch; then exit 99; fi
test "$(cat "$PP_SOURCE/own-file")" = keep
test ! -e "$PP_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_deactivate_preserves_files(self):
        result = self.shell('''
mkdir -p "$PP_SOURCE"
touch "$PP_MARKER" "$PP_SOURCE/own-file"
pp_deactivate
test ! -e "$PP_MARKER" && test -f "$PP_SOURCE/own-file"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_unsafe_root_rejected(self):
        result = self.shell('OPENCLAW_USER_DATA_DIR=/ propainter_main --dry-run')
        self.assertNotEqual(result.returncode, 0)

    def test_keys_not_inherited_by_installer_subshell(self):
        result = self.shell('''
mkdir -p "$PP_BASE"
printf '%s\\n' "$PP_COMMIT" > "$PP_MARKER"
export GEMINI_API_KEY=SYNTHETIC_TEST_ONLY GOOGLE_API_KEY=SYNTHETIC_TEST_ONLY HF_TOKEN=SYNTHETIC_TEST_ONLY
pp_source_ok() { [[ ! -v GEMINI_API_KEY && ! -v GOOGLE_API_KEY && ! -v HF_TOKEN && "$HF_HUB_OFFLINE" == 1 ]]; }
propainter_main status
test "$GEMINI_API_KEY" = SYNTHETIC_TEST_ONLY
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(json.loads(result.stdout)['source_ready'])
        self.assertNotIn('SYNTHETIC_TEST_ONLY', result.stdout)

    def test_cloud_and_gpu_limits_documented(self):
        doc = (ROOT / 'docs/tools/propainter.md').read_text(encoding='utf-8')
        for word in ('S-Lab License 1.0', 'nichtkommerziell', 'Gewichte', 'source_ready', 'runtime_ready', 'Sparse-Checkout'):
            self.assertIn(word, doc)

    def test_sparse_policy_on_unborn_repo(self):
        result = self.shell('''
mkdir -p "$PP_SOURCE"
git -c init.defaultBranch=main init "$PP_SOURCE"
pp_sparse_checkout
test "$(git -C "$PP_SOURCE" config --bool core.sparseCheckout)" = true
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_real_local_sparse_checkout_excludes_env_and_media(self):
        result = self.shell('''
mkdir -p "$PP_SOURCE/inference/cogvideox_fun" "$PP_SOURCE/model" "$PP_SOURCE/sample" "$PP_SOURCE/assets" "$PP_SOURCE/VLM-MASK-REASONER" "$PP_SOURCE/configs"
git -c init.defaultBranch=main init "$PP_SOURCE"
printf 'SYNTHETIC_TEST_ONLY\\n' > "$PP_SOURCE/.env"
touch "$PP_SOURCE/inference_propainter.py" "$PP_SOURCE/model/helper.py" "$PP_SOURCE/configs/settings.py" "$PP_SOURCE/README.md" "$PP_SOURCE/LICENSE" "$PP_SOURCE/requirements.txt"
touch "$PP_SOURCE/sample/test.mp4" "$PP_SOURCE/assets/test.png" "$PP_SOURCE/model/test.safetensors" "$PP_SOURCE/notebook.ipynb" "$PP_SOURCE/VLM-MASK-REASONER/test.env"
git -C "$PP_SOURCE" add .
git -c core.hooksPath=/dev/null -c commit.gpgsign=false -c user.name=Fixture -c user.email=fixture@example.org -C "$PP_SOURCE" commit -m fixture
pp_sparse_checkout
test -f "$PP_SOURCE/inference_propainter.py" && test -f "$PP_SOURCE/model/helper.py" && test -f "$PP_SOURCE/configs/settings.py"
test ! -e "$PP_SOURCE/.env"
test ! -e "$PP_SOURCE/sample/test.mp4"
test ! -e "$PP_SOURCE/assets/test.png"
test ! -e "$PP_SOURCE/model/test.safetensors"
test ! -e "$PP_SOURCE/notebook.ipynb"
''')
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
