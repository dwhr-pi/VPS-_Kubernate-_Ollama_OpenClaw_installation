"""Offline TGI source/launcher tests; no Cargo build, model, server, or WSL."""
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
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')
HELPER = 'scripts/tools/helpers/tgi_common.sh'


def shell_path(path):
    value = str(path).replace('\\', '/')
    return '/' + value[0].lower() + value[2:] if os.name == 'nt' else value


class Contract(unittest.TestCase):
    def test_registry_and_build_scope(self):
        tool, = [t for t in json.loads((ROOT / 'config/tools.yml').read_text())['tools'] if t['id'] == 'tgi']
        self.assertEqual(tool['status'], 'experimental')
        self.assertFalse(tool['auto_install'])
        self.assertEqual(tool['ports'], [])
        self.assertEqual(tool['install_mode'], 'source')
        text = (ROOT / HELPER).read_text()
        self.assertIn('TGI_COMMIT=' + tool['source_commit'], text)
        for field in ('install_script', 'update_script', 'uninstall_script', 'doctor_script', 'doc'):
            self.assertTrue((ROOT / tool[field]).is_file())
        for token in ('cargo build --locked --release --jobs 1 -p text-generation-launcher',
                      'TGI_BUILD_LAUNCHER', 'INSTALL_HEAVY_TOOLS', 'PYO3_PYTHON',
                      'require_ram_mb 6144', 'require_disk_mb 10240', 'flock -n 9'):
            self.assertIn(token, text)
        for forbidden in ('docker compose', 'make install', 'pip install', 'import torch',
                          'rm -rf', 'cargo install', '"$TGI_BINARY" --'):
            self.assertNotIn(forbidden, text)

    def test_document_links(self):
        doc = ROOT / 'docs/tools/tgi.md'
        for link in re.findall(r'\]\(([^)]+)\)', doc.read_text()):
            if '://' not in link and not link.startswith('#'):
                self.assertTrue((doc.parent / link.split('#')[0]).exists(), link)


@unittest.skipUnless(BASH and Path(BASH).exists(), 'Bash unavailable')
class Offline(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as temp:
            prefix = f'''
export OPENCLAW_USER_DATA_DIR='{shell_path(Path(temp) / 'private')}'
source {HELPER}
python3() {{ '{shell_path(Path(sys.executable))}' "$@"; }}
tgi_paths
'''
            return subprocess.run([BASH, '--noprofile', '--norc', '-c', prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=90)

    def test_dry_run_status_no_creation(self):
        result = self.shell('''
git() { exit 99; }; cargo() { exit 99; }
tgi_main --dry-run
tgi_main status
test ! -e "$TGI_BASE"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('"inference_ready":false', result.stdout)

    def test_missing_doctor_and_start_blocked(self):
        for action, rc in (('doctor', 1), ('serve', 2), ('start', 2)):
            result = self.shell('tgi_main ' + action)
            self.assertEqual(result.returncode, rc, result.stderr)

    def test_heavy_opt_in_before_tools(self):
        result = self.shell('''
INSTALL_HEAVY_TOOLS=0
cargo() { exit 99; }
tgi_launcher_preflight
''')
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn('INSTALL_HEAVY_TOOLS=1', result.stderr)

    def test_foreign_source_preserved(self):
        result = self.shell('''
mkdir -p "$TGI_SOURCE"
echo keep > "$TGI_SOURCE/own-file"
if tgi_fetch; then exit 99; fi
test "$(cat "$TGI_SOURCE/own-file")" = keep
test ! -e "$TGI_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_syntax_only_never_imports(self):
        result = self.shell('''
mkdir -p "$TGI_SOURCE/server/text_generation_server" "$TGI_SOURCE/launcher"
touch "$TGI_SOURCE/Cargo.toml" "$TGI_SOURCE/Cargo.lock" "$TGI_SOURCE/LICENSE" "$TGI_SOURCE/launcher/Cargo.toml" "$TGI_SOURCE/server/pyproject.toml"
printf 'raise AssertionError("NEVER IMPORT")\\n' > "$TGI_SOURCE/server/text_generation_server/cli.py"
tgi_source_ok() { return 0; }
tgi_fetch
test "$(cat "$TGI_MARKER")" = "$TGI_COMMIT"
test ! -e "$TGI_BUILD_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_mock_launcher_build_and_hash_without_execution(self):
        result = self.shell('''
mkdir -p "$TGI_SOURCE" "$TGI_TARGET/release"
cargo() {
    test "$CARGO_BUILD_JOBS" = 1 && test "$CARGO_TARGET_DIR" = "$TGI_TARGET" || return 99
    printf '%s\\n' "$*" > "$TGI_BASE/cargo-args"
    printf '#!/usr/bin/env bash\\nexit 99\\n' > "$TGI_BINARY"
    chmod +x "$TGI_BINARY"
}
tgi_build_launcher
tgi_launcher_ok
grep -q -- '--locked --release --jobs 1 -p text-generation-launcher' "$TGI_BASE/cargo-args"
echo changed >> "$TGI_BINARY"
if tgi_launcher_ok; then exit 99; fi
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_build_failure_clears_marker(self):
        result = self.shell('''
mkdir -p "$TGI_SOURCE"
echo old > "$TGI_BUILD_MARKER"
cargo() { return 42; }
set +e
(set -e; tgi_build_launcher)
rc=$?
test "$rc" = 42 && test ! -e "$TGI_BUILD_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_deactivate_preserves_source(self):
        result = self.shell('''
mkdir -p "$TGI_SOURCE"
touch "$TGI_MARKER" "$TGI_BUILD_MARKER" "$TGI_SOURCE/own-file"
tgi_deactivate
test ! -e "$TGI_MARKER" && test ! -e "$TGI_BUILD_MARKER" && test -f "$TGI_SOURCE/own-file"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_invalid_root(self):
        result = self.shell('OPENCLAW_USER_DATA_DIR=/ tgi_main --dry-run')
        self.assertNotEqual(result.returncode, 0)


if __name__ == '__main__':
    unittest.main()
