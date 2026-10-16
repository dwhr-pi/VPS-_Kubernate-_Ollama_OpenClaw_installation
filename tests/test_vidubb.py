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
HELPER = 'scripts/tools/helpers/vidubb_common.sh'


def shell_path(path):
    value = str(path).replace('\\', '/')
    return '/' + value[0].lower() + value[2:] if os.name == 'nt' else value


class Contract(unittest.TestCase):
    def test_registry_source_and_no_runtime(self):
        tool, = [t for t in json.loads((ROOT / 'config/tools.yml').read_text())['tools'] if t['id'] == 'vidubb']
        self.assertEqual(tool['status'], 'experimental')
        self.assertFalse(tool['auto_install'])
        self.assertEqual(tool['ports'], [])
        for field in ('install_script', 'update_script', 'uninstall_script', 'doctor_script', 'doc'):
            self.assertTrue((ROOT / tool[field]).is_file())
        text = (ROOT / HELPER).read_text()
        self.assertIn('VD_COMMIT=' + tool['source_commit'], text)
        for token in ('--filter=blob:none', 'GIT_LFS_SKIP_SMUDGE=1', 'vd_sparse_patterns',
                      'ast.parse', 'VIDUBB_INSTALL_RUNTIME', 'flock -n 9',
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
vd_paths
'''
            return subprocess.run([BASH, '--noprofile', '--norc', '-c', prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=90)

    def test_plan_and_status_no_creation(self):
        result = self.shell('''
git() { exit 99; }
vidubb_main --dry-run
vidubb_main status
test ! -e "$VD_BASE"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('"runtime_ready":false', result.stdout)

    def test_doctor_missing_and_start_blocked(self):
        for action, rc in (('doctor', 1), ('start', 2)):
            result = self.shell('vidubb_main ' + action)
            self.assertEqual(result.returncode, rc, result.stderr)

    def test_runtime_opt_in_still_blocked(self):
        result = self.shell('VIDUBB_INSTALL_RUNTIME=1 vidubb_main install')
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertIn('Legacy-Abhaengigkeiten', result.stderr)

    def test_source_syntax_without_import(self):
        result = self.shell('''
mkdir -p "$VD_SOURCE"
printf 'raise AssertionError("NEVER IMPORT")\\n' > "$VD_SOURCE/app.py"
cp "$VD_SOURCE/app.py" "$VD_SOURCE/inference.py"
touch "$VD_SOURCE/requirements.txt" "$VD_SOURCE/LICENSE"
vd_source_ok() { return 0; }
vd_inspect
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_foreign_source_preserved(self):
        result = self.shell('''
mkdir -p "$VD_SOURCE"
echo keep > "$VD_SOURCE/own-file"
if vd_fetch; then exit 99; fi
test "$(cat "$VD_SOURCE/own-file")" = keep
test ! -e "$VD_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_deactivate_preserves_files(self):
        result = self.shell('''
mkdir -p "$VD_SOURCE"
touch "$VD_MARKER" "$VD_SOURCE/own-file"
vd_deactivate
test ! -e "$VD_MARKER" && test -f "$VD_SOURCE/own-file"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_unsafe_root_rejected(self):
        result = self.shell('OPENCLAW_USER_DATA_DIR=/ vidubb_main --dry-run')
        self.assertNotEqual(result.returncode, 0)

    def test_sparse_policy_on_unborn_repo(self):
        result = self.shell('''
mkdir -p "$VD_SOURCE"
git -c init.defaultBranch=main init "$VD_SOURCE"
vd_sparse_checkout
test "$(git -C "$VD_SOURCE" config --bool core.sparseCheckout)" = true
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_real_local_sparse_checkout_excludes_env_and_media(self):
        result = self.shell('''
mkdir -p "$VD_SOURCE/tools" "$VD_SOURCE/Wav2Lip/checkpoints" "$VD_SOURCE/videos"
git -c init.defaultBranch=main init "$VD_SOURCE"
printf 'SYNTHETIC_TEST_ONLY\\n' > "$VD_SOURCE/.env"
touch "$VD_SOURCE/app.py" "$VD_SOURCE/inference.py" "$VD_SOURCE/README.md" "$VD_SOURCE/LICENSE" "$VD_SOURCE/requirements.txt" "$VD_SOURCE/tools/helper.py" "$VD_SOURCE/Wav2Lip/inference.py" "$VD_SOURCE/Wav2Lip/checkpoints/test.pth" "$VD_SOURCE/videos/test.mp4"
git -C "$VD_SOURCE" add .
git -c core.hooksPath=/dev/null -c commit.gpgsign=false -c user.name=Fixture -c user.email=fixture@example.org -C "$VD_SOURCE" commit -m fixture
vd_sparse_checkout
test -f "$VD_SOURCE/app.py" && test -f "$VD_SOURCE/tools/helper.py" && test -f "$VD_SOURCE/Wav2Lip/inference.py"
test ! -e "$VD_SOURCE/.env"
test ! -e "$VD_SOURCE/videos/test.mp4"
test ! -e "$VD_SOURCE/Wav2Lip/checkpoints/test.pth"
''')
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
