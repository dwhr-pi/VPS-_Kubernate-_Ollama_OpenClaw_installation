"""Synthetic log fixtures and failed writers; never fills a real disk or uses WSL."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')
MENU = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')


def function(name):
    return name + '() {' + MENU.split(name + '() {', 1)[1].split('\n}', 1)[0] + '\n}\n'


@unittest.skipUnless(BASH, 'Bash unavailable')
class OperationLog(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as tmp:
            path = tmp.replace('\\', '/')
            if os.name == 'nt':
                path = '/' + path[0].lower() + path[2:]
            prefix = '''set -euo pipefail
source scripts/helpers/operation_log.sh
''' + 'USER_INSTALL_LOG_DIR="' + path + '/logs"\n' + '''
YELLOW=; RED=; GREEN=; NC=
get_tool_install_min_free_mb() { echo 2048; }
get_tool_install_fallback_min_free_mb() { echo 2048; }
get_tool_install_measured_mb() { echo 0; }
format_kb_human() { printf '%s KiB' "$1"; }
get_tool_install_windows_min_free_mb() { echo 2048; }
''' + function('preflight_tool_install_storage') + function('resolve_install_log_file')
            return subprocess.run([BASH, '--noprofile', '--norc', '-c', prefix + code], cwd=ROOT,
                                  capture_output=True, text=True, encoding='utf-8', timeout=60)

    def test_linux_space_rejection_has_own_log_not_old_one(self):
        r = self.shell('''
mkdir -p "$USER_INSTALL_LOG_DIR"
echo OLD_LOG > "$USER_INSTALL_LOG_DIR/old.log"
ACTIVE_OPERATION_LOG_FILE="$USER_INSTALL_LOG_DIR/old.log"
LAST_OPERATION_LOG_FILE="$ACTIVE_OPERATION_LOG_FILE"
start_operation_log tool_install_DeepFilterNet
get_free_disk_kb() { echo 1024; }
if capture_operation_output preflight_tool_install_storage DeepFilterNet; then exit 99; fi
grep -q 'Abbruch vor der Installation' "$ACTIVE_OPERATION_LOG_FILE"
grep -q DeepFilterNet "$ACTIVE_OPERATION_LOG_FILE"
! grep -q OLD_LOG "$ACTIVE_OPERATION_LOG_FILE"
test -z "$LAST_OPERATION_LOG_FILE"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_windows_space_rejection_is_logged(self):
        r = self.shell('''
start_operation_log tool_install_Test
get_free_disk_kb() { echo 99999999; }
is_wsl_environment() { return 0; }
get_windows_host_free_kb() { echo 1024; }
if capture_operation_output preflight_tool_install_storage Test; then exit 99; fi
grep -q 'Windows-Host' "$ACTIVE_OPERATION_LOG_FILE"
grep -q 'Unter WSL sollte' "$ACTIVE_OPERATION_LOG_FILE"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_installer_output_appends_and_names_are_unique(self):
        r = self.shell('''
start_operation_log tool_install_Test
first="$ACTIVE_OPERATION_LOG_FILE"
append_operation_note PRECHECK
capture_operation_output bash -c 'echo INSTALL_OUTPUT'
grep -q PRECHECK "$first"
grep -q INSTALL_OUTPUT "$first"
start_operation_log tool_install_Test
test "$first" != "$ACTIVE_OPERATION_LOG_FILE"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_missing_log_does_not_resolve_to_history(self):
        r = self.shell('''
find_latest_install_log_file() { echo OLD_LOG; }
test -z "$(resolve_install_log_file)"
test -z "$(resolve_install_log_file /missing/log)"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_writer_failure_not_reported_as_success(self):
        r = self.shell('''
start_operation_log tool_install_Test
tee() { cat >/dev/null; return 1; }
capture_operation_output printf success
''')
        self.assertEqual(r.returncode, 74, r.stderr)
        self.assertIn('nicht vollstaendig geschrieben', r.stderr)

    def test_child_failure_exit_code_preserved(self):
        r = self.shell('start_operation_log tool_install_Test; capture_operation_output bash -c "echo ENOSPC >&2; exit 28"')
        self.assertEqual(r.returncode, 28, r.stderr)

    def test_failed_creation_clears_old_log_reference(self):
        r = self.shell('''
mkdir -p "$USER_INSTALL_LOG_DIR"
touch "$USER_INSTALL_LOG_DIR/file"
USER_INSTALL_LOG_DIR="$USER_INSTALL_LOG_DIR/file/child"
LAST_OPERATION_LOG_FILE=OLD_LOG
ACTIVE_OPERATION_LOG_FILE=OLD_LOG
if start_operation_log tool_install_Test; then exit 99; fi
test -z "$LAST_OPERATION_LOG_FILE"
test -z "$ACTIVE_OPERATION_LOG_FILE"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_begin_creates_log_before_preflight_and_runner_does_not_truncate(self):
        self.assertIn('start_operation_log', function('begin_operation_measurement'))
        install = function('install_tool')
        self.assertLess(install.index('begin_operation_measurement'), install.index('capture_operation_output preflight_tool_install_storage'))
        self.assertIn('capture_operation_output bash', function('run_bash_script'))


if __name__ == '__main__':
    unittest.main()
