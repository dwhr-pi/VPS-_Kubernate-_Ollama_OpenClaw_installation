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
HELPER = 'scripts/tools/helpers/sfizz_common.sh'


def sp(path):
    value = str(path).replace('\\', '/')
    return '/' + value[0].lower() + value[2:] if os.name == 'nt' else value


class Contract(unittest.TestCase):
    def test_registry_and_source_contract(self):
        tools = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        t, = [t for t in tools if t['id'] == 'sfizz']
        self.assertEqual(t['version'], '1.2.3')
        self.assertEqual(t['status'], 'experimental')
        self.assertFalse(t['auto_install'])
        self.assertEqual(t['ports'], [])
        helper = (ROOT / HELPER).read_text()
        self.assertIn('SF_COMMIT=' + t['source_commit'], helper)
        pins = re.findall(r'^(external/\S+) (https://github.com/\S+) ([0-9a-f]{40})$', helper, re.M)
        self.assertEqual(len(pins), 6)
        for field in ('doc', 'install_script', 'update_script', 'uninstall_script', 'doctor_script'):
            self.assertTrue((ROOT / t[field]).is_file())
        for phrase in ('--target sfizz_render', '--parallel "$SF_JOBS"',
                       '-DSFIZZ_JACK=OFF', '-DFETCHCONTENT_FULLY_DISCONNECTED=ON',
                       'require_ram_mb 4096', 'require_disk_mb "$reserve"', 'flock -n 9'):
            self.assertIn(phrase, helper)
        self.assertNotRegex(helper, r'(?m)^\s*sudo\s')
        for forbidden in ('apt install', 'docker compose', 'cmake --install',
                          'submodule update', 'rm -rf', 'git reset'):
            self.assertNotIn(forbidden, helper)

    def test_menu_and_doc_links(self):
        self.assertIn('TOOL_SCRIPT_NAMES["Sfizz"]="sfizz"', (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8'))
        doc = ROOT / 'docs/tools/sfizz.md'
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
sf_paths
'''
            return subprocess.run([str(BASH), '--noprofile', '--norc', '-c', prefix + code],
                                  cwd=ROOT, text=True, capture_output=True, timeout=90)

    def test_dry_run_and_missing_status_do_not_write(self):
        r = self.shell('''
git() { exit 99; }; cmake() { exit 99; }
sfizz_main --dry-run
sfizz_main status
test ! -e "$SF_BASE"
''')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn('"audio_tested":false', r.stdout)

    def test_missing_doctor_fails_and_start_rejected(self):
        self.assertEqual(self.shell('sfizz_main doctor').returncode, 1)
        self.assertEqual(self.shell('sfizz_main start').returncode, 2)

    def test_unsafe_root_rejected(self):
        for value in ('/', '$SF_ROOT/private', '$HOME/../other'):
            self.assertNotEqual(self.shell('OPENCLAW_USER_DATA_DIR="' + value + '" sfizz_main --dry-run').returncode, 0)

    def test_foreign_checkout_preserved(self):
        r = self.shell('''
mkdir -p "$SF_SOURCE"
echo keep > "$SF_SOURCE/own"
if sf_checkout "$SF_SOURCE" "$SF_URL" "$SF_COMMIT"; then exit 99; fi
test "$(cat "$SF_SOURCE/own")" = keep
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_all_pinned_modules_orchestrated_without_real_git(self):
        r = self.shell('''
mkdir -p "$SF_BASE"
sf_checkout() { printf '%s %s %s\\n' "$1" "$2" "$3" >> "$SF_BASE/calls"; }
sf_source_ok() { return 0; }
sf_fetch
test "$(wc -l < "$SF_BASE/calls")" -eq 7
test "$(cat "$SF_MARKER")" = "$SF_COMMIT"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_failed_fetch_never_sets_marker(self):
        r = self.shell('''
mkdir -p "$SF_BASE"
sf_checkout() { return 42; }
if sf_fetch; then exit 99; fi
test ! -e "$SF_MARKER"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_build_commands_mocked_no_execution(self):
        r = self.shell('''
mkdir -p "$SF_BASE"
SF_JOBS=1
cmake() { printf '%s\\n' "$*" >> "$SF_BASE/cmake-args"; }
sf_source_ok() { return 0; }
sf_native_record() { test "$1" = write; touch "$SF_NATIVE"; }
sf_build_native
grep -Fq -- '-DSFIZZ_JACK=OFF' "$SF_BASE/cmake-args"
grep -Fq -- '--target sfizz_render --parallel 1' "$SF_BASE/cmake-args"
test -f "$SF_NATIVE"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_build_failure_clears_stale_success(self):
        r = self.shell('''
mkdir -p "$SF_BASE"
touch "$SF_NATIVE"
SF_JOBS=1
cmake() { return 42; }
if sf_build_native; then exit 99; fi
test ! -e "$SF_NATIVE"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_elf_hash_check_without_running_binary(self):
        r = self.shell('''
mkdir -p "$SF_BUILD/library/bin"
python3 -I -B - "$SF_BINARY" <<'PY'
from pathlib import Path
import platform
import sys
h = bytearray(32)
h[:6] = bytes([127,69,76,70,2,1])
h[18:20] = (183 if platform.machine().lower() in ('aarch64','arm64') else 62).to_bytes(2,'little')
Path(sys.argv[1]).write_bytes(h)
PY
sf_native_record write
sf_native_record check
echo changed >> "$SF_BINARY"
if sf_native_record check; then exit 99; fi
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_parallelism_and_foreign_build_rejected(self):
        prefix = 'cmake() { echo "cmake version 3.28.3"; }; make() { :; }; cc() { :; }; c++() { :; }; '
        self.assertNotEqual(self.shell(prefix + 'SFIZZ_BUILD_JOBS=8 sf_build_preflight').returncode, 0)
        self.assertNotEqual(self.shell(prefix + 'mkdir -p "$SF_BUILD"; sf_build_preflight').returncode, 0)

    def test_real_local_nested_git_provenance_and_dirty_detection(self):
        r = self.shell('''
mkdir -p "$SF_SOURCE/clients" "$SF_SOURCE/modules/test"
git -c init.defaultBranch=main init "$SF_SOURCE"
git -C "$SF_SOURCE" remote add origin "$SF_URL"
touch "$SF_SOURCE/CMakeLists.txt" "$SF_SOURCE/LICENSE" "$SF_SOURCE/clients/sfizz_render.cpp"
git -c init.defaultBranch=main init "$SF_SOURCE/modules/test"
git -C "$SF_SOURCE/modules/test" remote add origin https://github.com/fixture/test.git
touch "$SF_SOURCE/modules/test/file"
git -C "$SF_SOURCE/modules/test" add .
git -c core.hooksPath=/dev/null -c commit.gpgsign=false -c user.name=Fixture -c user.email=fixture@example.org -C "$SF_SOURCE/modules/test" commit -m fixture
child_pin="$(git -C "$SF_SOURCE/modules/test" rev-parse HEAD)"
git -C "$SF_SOURCE" add .
git -c core.hooksPath=/dev/null -c commit.gpgsign=false -c user.name=Fixture -c user.email=fixture@example.org -C "$SF_SOURCE" commit -m fixture
SF_COMMIT="$(git -C "$SF_SOURCE" rev-parse HEAD)"
sf_modules() { echo "modules/test https://github.com/fixture/test.git $child_pin"; }
sf_source_ok
echo changed > "$SF_SOURCE/modules/test/file"
if sf_source_ok; then exit 99; fi
''')
        self.assertEqual(r.returncode, 0, r.stderr)


if __name__ == '__main__':
    unittest.main()
