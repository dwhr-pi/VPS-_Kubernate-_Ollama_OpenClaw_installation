"""Offline mocked Rust lifecycle; no network, Cargo build, audio, or WSL."""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')
HELPER = 'scripts/tools/helpers/deepfilternet_common.sh'


class Registry(unittest.TestCase):
    def test_source_contract(self):
        tool, = [t for t in json.loads((ROOT / 'config/tools.yml').read_text())['tools']
                 if t['id'] == 'deepfilternet']
        self.assertEqual(tool['status'], 'experimental')
        self.assertFalse(tool['auto_install'])
        self.assertEqual(tool['install_mode'], 'source')
        self.assertEqual(tool['ports'], [])
        text = (ROOT / HELPER).read_text()
        self.assertIn('DF_COMMIT=' + tool['source_commit'], text)
        for key in ('doc', 'install_script', 'update_script', 'uninstall_script', 'doctor_script'):
            self.assertTrue((ROOT / tool[key]).is_file())
        for token in ('cargo build --locked --release --jobs 1', 'default-model',
                      'require_ram_mb 6144', '-ge 4096', 'require_disk_mb 8192',
                      'REQUIRE_WINDOWS_HOST_FREE_MB=8192', 'flock -n 9',
                      'timeout 15', 'sha256sum', 'GIT_TERMINAL_PROMPT=0'):
            self.assertIn(token, text)
        for forbidden in ('docker compose', 'pip install', 'rm -rf', 'curl |', '--output-dir'):
            self.assertNotIn(forbidden, text)

    def test_links(self):
        doc = ROOT / 'docs/tools/deepfilternet.md'
        for link in re.findall(r'\]\(([^)]+)\)', doc.read_text()):
            if '://' not in link and not link.startswith('#'):
                self.assertTrue((doc.parent / link.split('#')[0]).exists(), link)


@unittest.skipUnless(BASH and Path(BASH).exists(), 'Bash unavailable')
class OfflineBehavior(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as temp:
            path = temp.replace('\\', '/')
            if os.name == 'nt':
                path = '/' + path[0].lower() + path[2:]
            prefix = f'export HOME="{path}"\nunset OPENCLAW_USER_DATA_DIR\nsource {HELPER}\n'
            return subprocess.run([BASH, '--noprofile', '--norc', '-c', prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=40)

    def test_dry_run_no_tools_or_workspace(self):
        result = self.shell('''
git() { exit 99; }; cargo() { exit 99; }
deepfilternet_main --dry-run
test ! -e "$HOME/.openclaw_ultimate_user_data"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Dry-Run ohne Download', result.stdout)

    def test_missing_status_no_creation(self):
        result = self.shell('deepfilternet_main status; test ! -e "$HOME/.openclaw_ultimate_user_data"')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(json.loads(result.stdout)['installed'])

    def test_missing_doctor_fails(self):
        result = self.shell('deepfilternet_main doctor')
        self.assertEqual(result.returncode, 1, result.stderr)

    def test_start_rejected(self):
        result = self.shell('deepfilternet_main start')
        self.assertEqual(result.returncode, 2, result.stderr)

    def test_unsafe_workspace_rejected(self):
        for root in ('/', '$DF_ROOT/data', '$HOME/../foreign'):
            result = self.shell(f'export OPENCLAW_USER_DATA_DIR="{root}"; deepfilternet_main --dry-run')
            self.assertNotEqual(result.returncode, 0, result.stderr)

    def test_foreign_source_preserved(self):
        result = self.shell('''
df_paths
mkdir -p "$DF_SOURCE"
echo keep > "$DF_SOURCE/own-file"
if df_fetch; then exit 99; fi
test "$(cat "$DF_SOURCE/own-file")" = keep
test ! -e "$DF_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_clean_source_reused_without_fetch(self):
        result = self.shell('''
df_paths
mkdir -p "$DF_SOURCE/libDF" "$DF_SOURCE/models"
touch "$DF_SOURCE/Cargo.lock" "$DF_SOURCE/libDF/Cargo.toml" "$DF_SOURCE/models/DeepFilterNet3_onnx.tar.gz"
df_source_ok() { return 0; }
git() { exit 99; }
df_fetch
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_cargo_flags_and_build_target(self):
        result = self.shell('''
df_paths
mkdir -p "$DF_SOURCE"
cargo() {
    test "$CARGO_BUILD_JOBS" = 1 && test "$CARGO_TARGET_DIR" = "$DF_TARGET" || return 99
    printf '%s\\n' "$*"
}
df_build
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('--locked --release --jobs 1 -p deep_filter --bin deep-filter', result.stdout)
        self.assertIn('--no-default-features --features bin,tract,wav-utils,transforms,default-model', result.stdout)

    def test_mock_binary_marker_and_tampering(self):
        result = self.shell('''
df_paths
mkdir -p "$DF_TARGET/release"
printf '#!/usr/bin/env bash\necho "deep_filter 0.5.6"\n' > "$DF_BINARY"
chmod +x "$DF_BINARY"
df_source_ok() { return 0; }
df_finish
df_probe
echo changed >> "$DF_BINARY"
if df_probe; then exit 99; fi
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_failed_version_does_not_mark_success(self):
        result = self.shell('''
df_paths
mkdir -p "$DF_TARGET/release"
printf '#!/usr/bin/env bash\necho wrong-version\n' > "$DF_BINARY"
chmod +x "$DF_BINARY"
set +e
(set -e; df_finish)
rc=$?
test "$rc" != 0 && test ! -e "$DF_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
