"""Offline orchestration tests only. No real builds, GitHub, audio or WSL."""
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
HELPER = 'scripts/tools/helpers/aida_x_common.sh'


def sp(path):
    value = str(path).replace('\\', '/')
    return '/' + value[0].lower() + value[2:] if os.name == 'nt' else value


class Contract(unittest.TestCase):
    def test_registry_and_source_contract(self):
        tools = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        t, = [t for t in tools if t['id'] == 'aida_x']
        self.assertEqual(t['version'], '1.1.0')
        self.assertEqual(t['status'], 'experimental')
        self.assertFalse(t['auto_install'])
        self.assertEqual(t['ports'], [])
        helper = (ROOT / HELPER).read_text()
        self.assertIn('AX_COMMIT=' + t['source_commit'], helper)
        pins = re.findall(r'^(modules/\S+) (https://github.com/\S+) ([0-9a-f]{40})$', helper, re.M)
        self.assertEqual(len(pins), 8)
        for field in ('doc', 'install_script', 'update_script', 'uninstall_script', 'doctor_script'):
            self.assertTrue((ROOT / t[field]).is_file())
        for phrase in ('--target AIDA-X-Standalone-jack', '--parallel "$AX_JOBS"',
                       '-DJUCE_EXTRA=OFF', '-DFETCHCONTENT_FULLY_DISCONNECTED=ON',
                       'require_ram_mb 4096', 'require_disk_mb "$reserve"', 'flock -n 9'):
            self.assertIn(phrase, helper)
        self.assertNotRegex(helper, r'(?m)^\s*sudo\s')
        for forbidden in ('apt install', 'docker compose', 'cmake --install',
                          'submodule update', 'rm -rf', 'git reset'):
            self.assertNotIn(forbidden, helper)

    def test_menu_and_doc_links(self):
        self.assertIn('TOOL_SCRIPT_NAMES["AIDA_X"]="aida_x"', (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8'))
        doc = ROOT / 'docs/tools/aida-x.md'
        for link in re.findall(r'\]\(([^)]+)\)', doc.read_text(encoding='utf-8')):
            if '://' not in link and not link.startswith('#'):
                self.assertTrue((doc.parent / link.split('#')[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), 'bash unavailable')
class Offline(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as temp:
            prefix = f'''
export OPENCLAW_USER_DATA_DIR='{sp(Path(temp).resolve() / 'private')}'
source {HELPER}
python3() {{ '{sp(Path(sys.executable))}' "$@"; }}
ax_paths
'''
            return subprocess.run([str(BASH), '--noprofile', '--norc', '-c', prefix + code],
                                  cwd=ROOT, text=True, capture_output=True, timeout=90)

    def test_dry_run_and_missing_status_do_not_write(self):
        r = self.shell('''
git() { exit 99; }; cmake() { exit 99; }
aida_x_main --dry-run
aida_x_main status
test ! -e "$AX_BASE"
''')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn('"audio_tested":false', r.stdout)

    def test_missing_doctor_fails_and_start_rejected(self):
        self.assertEqual(self.shell('aida_x_main doctor').returncode, 1)
        self.assertEqual(self.shell('aida_x_main start').returncode, 2)

    def test_unsafe_root_rejected(self):
        for value in ('/', '$AX_ROOT/private', '$HOME/../other'):
            self.assertNotEqual(self.shell('OPENCLAW_USER_DATA_DIR="' + value + '" aida_x_main --dry-run').returncode, 0)

    def test_foreign_checkout_preserved(self):
        r = self.shell('''
mkdir -p "$AX_SOURCE"
echo keep > "$AX_SOURCE/own"
if ax_checkout "$AX_SOURCE" "$AX_URL" "$AX_COMMIT"; then exit 99; fi
test "$(cat "$AX_SOURCE/own")" = keep
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_all_pinned_modules_orchestrated_without_real_git(self):
        r = self.shell('''
mkdir -p "$AX_BASE"
ax_checkout() { printf '%s %s %s\\n' "$1" "$2" "$3" >> "$AX_BASE/calls"; }
ax_source_ok() { return 0; }
ax_fetch
test "$(wc -l < "$AX_BASE/calls")" -eq 9
test "$(cat "$AX_MARKER")" = "$AX_COMMIT"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_failed_fetch_never_sets_marker(self):
        r = self.shell('''
mkdir -p "$AX_BASE"
ax_checkout() { return 42; }
if ax_fetch; then exit 99; fi
test ! -e "$AX_MARKER"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_build_commands_mocked_no_execution(self):
        r = self.shell('''
mkdir -p "$AX_BASE"
AX_JOBS=1
cmake() { printf '%s\\n' "$*" >> "$AX_BASE/cmake-args"; }
ax_source_ok() { return 0; }
ax_native_record() { test "$1" = write; touch "$AX_NATIVE"; }
ax_build_native
grep -Fq -- '-DJUCE_EXTRA=OFF' "$AX_BASE/cmake-args"
grep -Fq -- '--target AIDA-X-Standalone-jack --parallel 1' "$AX_BASE/cmake-args"
test -f "$AX_NATIVE"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_build_failure_clears_stale_success(self):
        r = self.shell('''
mkdir -p "$AX_BASE"
touch "$AX_NATIVE"
AX_JOBS=1
cmake() { return 42; }
if ax_build_native; then exit 99; fi
test ! -e "$AX_NATIVE"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_elf_hash_check_without_running_binary(self):
        r = self.shell('''
mkdir -p "$AX_BUILD/bin"
python3 -I -B - "$AX_BINARY" <<'PY'
from pathlib import Path
import platform
import sys
h = bytearray(32)
h[:6] = bytes([127,69,76,70,2,1])
h[18:20] = (183 if platform.machine().lower() in ('aarch64','arm64') else 62).to_bytes(2,'little')
Path(sys.argv[1]).write_bytes(h)
PY
ax_native_record write
ax_native_record check
echo changed >> "$AX_BINARY"
if ax_native_record check; then exit 99; fi
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_parallelism_and_foreign_build_rejected(self):
        prefix = 'cmake() { :; }; make() { :; }; cc() { :; }; c++() { :; }; pkg-config() { :; }; '
        self.assertNotEqual(self.shell(prefix + 'AIDA_X_BUILD_JOBS=8 ax_build_preflight').returncode, 0)
        self.assertNotEqual(self.shell(prefix + 'mkdir -p "$AX_BUILD"; ax_build_preflight').returncode, 0)

    def test_real_local_nested_git_provenance_and_dirty_detection(self):
        r = self.shell('''
mkdir -p "$AX_SOURCE/src" "$AX_SOURCE/modules/test"
git -c init.defaultBranch=main init "$AX_SOURCE"
git -C "$AX_SOURCE" remote add origin "$AX_URL"
touch "$AX_SOURCE/CMakeLists.txt" "$AX_SOURCE/LICENSE" "$AX_SOURCE/src/aidadsp-plugin.cpp"
git -c init.defaultBranch=main init "$AX_SOURCE/modules/test"
git -C "$AX_SOURCE/modules/test" remote add origin https://github.com/fixture/test.git
touch "$AX_SOURCE/modules/test/file"
git -C "$AX_SOURCE/modules/test" add .
git -c core.hooksPath=/dev/null -c commit.gpgsign=false -c user.name=Fixture -c user.email=fixture@example.org -C "$AX_SOURCE/modules/test" commit -m fixture
child_pin="$(git -C "$AX_SOURCE/modules/test" rev-parse HEAD)"
git -C "$AX_SOURCE" add .
git -c core.hooksPath=/dev/null -c commit.gpgsign=false -c user.name=Fixture -c user.email=fixture@example.org -C "$AX_SOURCE" commit -m fixture
AX_COMMIT="$(git -C "$AX_SOURCE" rev-parse HEAD)"
ax_modules() { echo "modules/test https://github.com/fixture/test.git $child_pin"; }
ax_source_ok
echo changed > "$AX_SOURCE/modules/test/file"
if ax_source_ok; then exit 99; fi
''')
        self.assertEqual(r.returncode, 0, r.stderr)


if __name__ == '__main__':
    unittest.main()
