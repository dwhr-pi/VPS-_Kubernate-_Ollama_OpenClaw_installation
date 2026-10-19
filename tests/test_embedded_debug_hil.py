"""Offline fixtures only: no network, package build, debugger or WSL."""
import importlib.util
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


def sp(path):
    value = str(path).replace('\\', '/')
    return '/' + value[0].lower() + value[2:] if os.name == 'nt' else value


class Contract(unittest.TestCase):
    def test_registry_is_source_base_not_hardware(self):
        tool, = [t for t in json.loads((ROOT / 'config/tools.yml').read_text())['tools'] if t['id'] == 'embedded_debug_hil']
        self.assertEqual(tool['source'], 'https://github.com/cs01/pygdbmi')
        self.assertEqual(tool['status'], 'experimental')
        self.assertFalse(tool['auto_install'])
        self.assertTrue(tool['check_value'].endswith('/source-built'))
        for key in ('doc', 'install_script', 'update_script', 'uninstall_script', 'doctor_script'):
            self.assertTrue((ROOT / tool[key]).is_file())
        helper = (ROOT / 'scripts/tools/helpers/embedded_debug_hil_source.sh').read_text()
        self.assertIn('HIL_COMMIT=' + tool['source_commit'], helper)
        for forbidden in ('GdbController(', 'docker compose', 'rm -rf', 'import pygdbmi'):
            self.assertNotIn(forbidden, helper)
        self.assertNotRegex(helper, r'(?m)^\s*(?:sudo|openocd|pyocd|gdb)\s')

    def test_dependency_order_and_scope(self):
        text = (ROOT / 'scripts/tools/helpers/embedded_debug_hil_source.sh').read_text()
        main = text.split('hil_main() (', 1)[1]
        for guard in ('hil_resources', 'flock -n 9', 'exec > >(tee'):
            self.assertLess(main.index(guard), main.index('hil_prepare_python'))
        self.assertLess(main.index('hil_prepare_python'), main.index('hil_fetch'))
        self.assertIn('sys.prefix == sys.base_prefix', text)
        self.assertIn('Path(sys.executable).resolve() == expected.resolve()', text)
        self.assertIn('assert (3, 10) <= sys.version_info < (3, 13)', text)
        self.assertIn('run_apt_with_lock_wait update || return 1', text)
        self.assertIn('install -y --no-install-recommends "$1"', text)

    def test_offline_report_still_works(self):
        spec = importlib.util.spec_from_file_location('hil_offline', ROOT / 'tools/embedded_debug_hil/hil.py')
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        data = module.load_snapshot(ROOT / 'tools/embedded_debug_hil/snapshot.example.json')
        self.assertIn('Keine Hardware wurde gelesen', module.report(data))


@unittest.skipUnless(BASH, 'Bash unavailable')
class Offline(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as tmp:
            prefix = f'''set -e
export OPENCLAW_USER_DATA_DIR='{sp(Path(tmp) / 'private')}'
export EMBEDDED_DEBUG_HIL_PYTHON_BIN='{sp(Path(sys.executable))}'
source scripts/tools/helpers/embedded_debug_hil_common.sh
hil_paths
'''
            return subprocess.run([BASH, '--noprofile', '--norc', '-c', prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, encoding='utf-8', timeout=60)

    def test_dry_run_no_download_or_creation(self):
        r = self.shell('git() { exit 99; }; hil_main --dry-run; test ! -e "$HIL_BASE"')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_python_dependency_decisions(self):
        cases = (
            ('ask', 'return 0', 'return 1', 'echo python3.12-venv', 'return 0', 1, False),
            ('0', 'return 0', 'return 1', 'echo python3.12-venv', 'return 0', 1, False),
            ('invalid', 'return 0', 'return 1', 'echo python3.12-venv', 'return 0', 2, False),
            ('1', 'return 1', 'return 1', 'echo python3.12-venv', 'return 0', 1, False),
            ('1', 'return 0', 'return 1', 'return 1', 'return 0', 1, False),
            ('1', 'return 0', 'return 0', 'echo python3.12-venv', 'return 0', 0, False),
            ('1', 'return 0', 'return 1', 'echo python3.12-venv', 'return 42', 1, True),
            ('1', 'return 0', 'return 1', 'echo python3.12-venv', 'return 0', 1, True),
            ('1', 'return 0', '[[ "${repaired:-0}" == 1 ]]', 'echo python3.12-venv', 'repaired=1', 0, True),
        )
        for policy, core, venv, package, install, expected, called in cases:
            with self.subTest(policy=policy, core=core, venv=venv, install=install):
                r = self.shell(f'''
hil_fake_core() {{ {core}; }}
HIL_PYTHON=hil_fake_core
hil_python_venv_ok() {{ {venv}; }}
hil_venv_package() {{ {package}; }}
command() {{ return 0; }}
hil_install_venv_package() {{
    [[ "$1" == python3.12-venv ]] || return 99
    echo MOCK_PACKAGE_INSTALL
    {install};
}}
EMBEDDED_DEBUG_HIL_INSTALL_VENV_DEPS={policy} hil_prepare_python
''')
                self.assertEqual(r.returncode, expected, r.stderr)
                self.assertEqual('MOCK_PACKAGE_INSTALL' in r.stdout, called)

    def test_read_only_actions_never_prepare_dependencies(self):
        for action, expected in (('--dry-run', 0), ('status', 0), ('doctor', 1)):
            with self.subTest(action=action):
                r = self.shell('hil_prepare_python() { echo UNEXPECTED_REPAIR; return 99; }; hil_main ' + action)
                self.assertEqual(r.returncode, expected, r.stderr)
                self.assertNotIn('UNEXPECTED_REPAIR', r.stdout)

    def test_status_does_not_create_or_claim_hardware(self):
        r = self.shell('hil_main status; test ! -e "$HIL_BASE"')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertEqual(json.loads(r.stdout), dict(installed=False, scope='pygdbmi-base', hardware_ready=False))

    def test_missing_doctor_fails(self):
        self.assertEqual(self.shell('hil_main doctor').returncode, 1)

    def test_hardware_actions_rejected(self):
        for action in ('flash', 'attach', 'reset', 'start'):
            self.assertEqual(self.shell('hil_main ' + action).returncode, 2)

    def test_unsafe_roots_rejected(self):
        for path in ('/', '$HIL_REPO_ROOT/private', '$HOME/../other'):
            r = self.shell('OPENCLAW_USER_DATA_DIR="' + path + '" hil_main --dry-run')
            self.assertNotEqual(r.returncode, 0)

    def test_foreign_source_preserved(self):
        r = self.shell('''
mkdir -p "$HIL_SOURCE"
echo keep > "$HIL_SOURCE/own"
git() { return 1; }
if hil_fetch; then exit 99; fi
test "$(cat "$HIL_SOURCE/own")" = keep
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_foreign_venv_rejected(self):
        r = self.shell('mkdir -p "$HIL_VENV"; HIL_PYTHON=true; hil_preflight')
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_failed_build_removes_success_marker(self):
        r = self.shell('''
mkdir -p "$HIL_BASE"
echo old > "$HIL_MARKER"
HIL_PYTHON=false
if hil_install_package; then exit 99; fi
test ! -e "$HIL_MARKER"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_mock_package_install_uses_local_github_source_only(self):
        r = self.shell(r'''
mkdir -p "$HIL_BASE"
export HIL_BASE HIL_VENV
hil_fake_python() {
    if [[ "$*" == *'-m venv'* ]]; then
        mkdir -p "$HIL_VENV/bin"
        printf '#!/usr/bin/env bash\nhil_fake_python "$@"\n' > "$HIL_VENV/bin/python"
        chmod +x "$HIL_VENV/bin/python"
    elif [[ "$*" == *'pip --isolated install'* ]]; then
        printf '%s\n' "$*" > "$HIL_BASE/install-args"
    else return 99
    fi
}
export -f hil_fake_python
HIL_PYTHON=hil_fake_python
hil_metadata() { test -f "$HIL_BASE/install-args"; }
hil_source_ok() { return 0; }
hil_install_package
grep -Fq -- "--no-deps $HIL_SOURCE" "$HIL_BASE/install-args"
test "$(cat "$HIL_MARKER")" = "$HIL_COMMIT base"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_low_ram_prevents_disk_and_download(self):
        r = self.shell('''
source() { return 0; }
require_ram_mb() { return 1; }
require_disk_mb() { exit 99; }
if hil_resources; then exit 99; fi
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_deactivation_preserves_data_and_clears_status(self):
        r = self.shell('''
mkdir -p "$HIL_SOURCE" "$OPENCLAW_USER_DATA_DIR/status"
touch "$HIL_MARKER" "$HIL_SOURCE/own"
printf 'Embedded_Debug_HIL\\nOther\\n' > "$OPENCLAW_USER_DATA_DIR/installed_tools.txt"
printf 'Embedded_Debug_HIL\\n' > "$OPENCLAW_USER_DATA_DIR/status/installed_tools.txt"
hil_deactivate
test ! -e "$HIL_MARKER" && test -f "$HIL_SOURCE/own"
! grep -Fxq Embedded_Debug_HIL "$OPENCLAW_USER_DATA_DIR/installed_tools.txt"
! grep -Fxq Embedded_Debug_HIL "$OPENCLAW_USER_DATA_DIR/status/installed_tools.txt"
grep -Fxq Other "$OPENCLAW_USER_DATA_DIR/installed_tools.txt"
''')
        self.assertEqual(r.returncode, 0, r.stderr)


if __name__ == '__main__':
    unittest.main()
