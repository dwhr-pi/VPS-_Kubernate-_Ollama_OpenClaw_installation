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
HELPER = 'scripts/tools/helpers/aegisub_common.sh'


def sp(path):
    value = str(path).replace('\\', '/')
    return '/' + value[0].lower() + value[2:] if os.name == 'nt' else value


class Contract(unittest.TestCase):
    def test_registry_and_source_contract(self):
        tools = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        t, = [t for t in tools if t['id'] == 'aegisub']
        self.assertEqual(t['version'], '3.5.1')
        self.assertEqual(t['status'], 'experimental')
        self.assertFalse(t['auto_install'])
        self.assertEqual(t['ports'], [])
        helper = (ROOT / HELPER).read_text()
        self.assertIn('AE_COMMIT=' + t['source_commit'], helper)
        for field in ('doc', 'install_script', 'update_script', 'uninstall_script', 'doctor_script'):
            self.assertTrue((ROOT / t[field]).is_file())
        for phrase in ('--wrap-mode=nofallback', '-Dsystem_luajit=true',
                       '-Denable_update_checker=false', '--no-rebuild --skip-subprojects',
                       'require_ram_mb 4096', 'reserve=8192', 'flock -n 9'):
            self.assertIn(phrase, helper)
        self.assertNotRegex(helper, r'(?m)^\s*sudo\s')
        for forbidden in ('apt install', 'docker compose', 'cmake --install',
                          'submodule update', 'rm -rf', 'git reset'):
            self.assertNotIn(forbidden, helper)

    def test_menu_and_doc_links(self):
        self.assertIn('TOOL_SCRIPT_NAMES["Aegisub"]="aegisub"', (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8'))
        doc = ROOT / 'docs/tools/aegisub.md'
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
ae_paths
'''
            return subprocess.run([str(BASH), '--noprofile', '--norc', '-c', prefix + code],
                                  cwd=ROOT, text=True, capture_output=True, timeout=90)

    def test_dry_run_and_missing_status_do_not_write(self):
        r = self.shell('''
git() { exit 99; }; cmake() { exit 99; }
aegisub_main --dry-run
aegisub_main status
test ! -e "$AE_BASE"
''')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn('"gui_tested":false', r.stdout)

    def test_missing_doctor_fails_and_start_rejected(self):
        self.assertEqual(self.shell('aegisub_main doctor').returncode, 1)
        self.assertEqual(self.shell('aegisub_main start').returncode, 2)

    def test_unsafe_root_rejected(self):
        for value in ('/', '$AE_ROOT/private', '$HOME/../other'):
            self.assertNotEqual(self.shell('OPENCLAW_USER_DATA_DIR="' + value + '" aegisub_main --dry-run').returncode, 0)

    def test_foreign_checkout_preserved(self):
        r = self.shell('''
mkdir -p "$AE_SOURCE"
echo keep > "$AE_SOURCE/own"
if ae_checkout "$AE_SOURCE" "$AE_URL" "$AE_COMMIT"; then exit 99; fi
test "$(cat "$AE_SOURCE/own")" = keep
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_pinned_source_orchestrated_without_real_git(self):
        r = self.shell('''
mkdir -p "$AE_BASE"
ae_checkout() { printf '%s %s %s\\n' "$1" "$2" "$3" > "$AE_BASE/calls"; }
ae_source_ok() { return 0; }
ae_fetch
test "$(wc -l < "$AE_BASE/calls")" -eq 1
test "$(cat "$AE_MARKER")" = "$AE_COMMIT"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_failed_fetch_never_sets_marker(self):
        r = self.shell('''
mkdir -p "$AE_BASE"
ae_checkout() { return 42; }
if ae_fetch; then exit 99; fi
test ! -e "$AE_MARKER"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_build_commands_mocked_no_execution(self):
        r = self.shell('''
mkdir -p "$AE_BASE"
AE_JOBS=1
meson() { printf '%s\\n' "$*" >> "$AE_BASE/meson-args"; }
ae_source_ok() { return 0; }
ae_native_record() { test "$1" = write; touch "$AE_NATIVE"; }
ae_build_native
grep -Fq -- '--wrap-mode=nofallback' "$AE_BASE/meson-args"
grep -Fq -- "compile -C $AE_BUILD -j 1" "$AE_BASE/meson-args"
test -f "$AE_NATIVE"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_build_failure_clears_stale_success(self):
        r = self.shell('''
mkdir -p "$AE_BASE"
touch "$AE_NATIVE"
AE_JOBS=1
meson() { return 42; }
if ae_build_native; then exit 99; fi
test ! -e "$AE_NATIVE"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_elf_hash_check_without_running_binary(self):
        r = self.shell('''
mkdir -p "$AE_PREFIX/bin" "$AE_PREFIX/share/aegisub/automation/include"
touch "$AE_PREFIX/share/aegisub/automation/include/utils.lua"
python3 -I -B - "$AE_BINARY" <<'PY'
from pathlib import Path
import platform
import sys
h = bytearray(32)
h[:6] = bytes([127,69,76,70,2,1])
h[18:20] = (183 if platform.machine().lower() in ('aarch64','arm64') else 62).to_bytes(2,'little')
Path(sys.argv[1]).write_bytes(h)
PY
ae_native_record write
ae_native_record check
echo changed >> "$AE_BINARY"
if ae_native_record check; then exit 99; fi
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_parallelism_and_foreign_build_rejected(self):
        prefix = 'meson() { echo "1.3.2"; }; ninja() { :; }; cc() { :; }; c++() { :; }; pkg-config() { :; }; wx-config() { echo "3.2.4"; }; msgfmt() { :; }; '
        self.assertNotEqual(self.shell(prefix + 'AEGISUB_BUILD_JOBS=8 ae_build_preflight').returncode, 0)
        self.assertNotEqual(self.shell(prefix + 'mkdir -p "$AE_BUILD"; ae_build_preflight').returncode, 0)

    def test_real_local_git_provenance_and_dirty_detection(self):
        r = self.shell('''
mkdir -p "$AE_SOURCE/src"
git -c init.defaultBranch=main init "$AE_SOURCE"
git -C "$AE_SOURCE" remote add origin "$AE_URL"
touch "$AE_SOURCE/meson.build" "$AE_SOURCE/LICENCE" "$AE_SOURCE/src/main.cpp"
git -C "$AE_SOURCE" add .
git -c core.hooksPath=/dev/null -c commit.gpgsign=false -c user.name=Fixture -c user.email=fixture@example.org -C "$AE_SOURCE" commit -m fixture
AE_COMMIT="$(git -C "$AE_SOURCE" rev-parse HEAD)"
ae_source_ok
echo changed > "$AE_SOURCE/src/main.cpp"
if ae_source_ok; then exit 99; fi
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_failed_private_install_never_sets_native_marker(self):
        r = self.shell('''
mkdir -p "$AE_BASE"
AE_JOBS=1
meson() { if [[ "$1" == install ]]; then return 42; fi; }
ae_native_record() { touch "$AE_NATIVE"; }
if ae_build_native; then exit 99; fi
test ! -e "$AE_NATIVE"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_native_install_unsets_destdir(self):
        r = self.shell('''
mkdir -p "$AE_BASE"
AE_JOBS=1
export DESTDIR=/DO_NOT_WRITE_HERE
meson() {
    if [[ "$1" == install ]]; then
        test ! -v DESTDIR || return 99
        touch "$AE_BASE/install-checked"
    fi
}
ae_source_ok() { return 0; }
ae_native_record() { touch "$AE_NATIVE"; }
ae_build_native
test -f "$AE_BASE/install-checked"
test "$DESTDIR" = /DO_NOT_WRITE_HERE
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_reconfigure_owned_build_without_wipe(self):
        r = self.shell('''
mkdir -p "$AE_BUILD/meson-private"
touch "$AE_BUILD/meson-private/coredata.dat"
AE_JOBS=1
meson() { printf '%s\\n' "$*" >> "$AE_BASE/args"; }
ae_source_ok() { return 0; }
ae_native_record() { touch "$AE_NATIVE"; }
ae_build_native
grep -Fq -- '--reconfigure' "$AE_BASE/args"
if grep -Fq -- '--wipe' "$AE_BASE/args"; then exit 99; fi
''')
        self.assertEqual(r.returncode, 0, r.stderr)


if __name__ == '__main__':
    unittest.main()
