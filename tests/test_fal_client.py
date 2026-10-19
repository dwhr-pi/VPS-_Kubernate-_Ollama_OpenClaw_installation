"""Offline Fal Client tests: no SDK imports, real installation, credentials, APIs or WSL."""
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
BASH = "C:/Program Files/Git/bin/bash.exe" if os.name == "nt" else shutil.which("bash")
HELPER = "scripts/tools/helpers/fal_client_common.sh"


def sp(path):
    value = str(path).replace("\\", "/")
    return "/" + value[0].lower() + value[2:] if os.name == "nt" else value


class Contract(unittest.TestCase):
    def test_source_contract(self):
        tool, = [t for t in json.loads((ROOT / "config/tools.yml").read_text())["tools"] if t["id"] == "fal_client"]
        self.assertEqual(tool["version"], "1.0.3")
        self.assertEqual(tool["status"], "experimental")
        self.assertEqual(tool["install_mode"], "source")
        self.assertFalse(tool["auto_install"])
        self.assertEqual(tool["ports"], [])
        text = (ROOT / HELPER).read_text()
        self.assertIn("FC_COMMIT=" + tool["source_commit"], text)
        for field in ("doc", "install_script", "update_script", "uninstall_script", "doctor_script"):
            self.assertTrue((ROOT / tool[field]).is_file(), field)
        for required in ("SETUPTOOLS_SCM_PRETEND_VERSION_FOR_FAL_CLIENT", "--only-binary=:all:",
                         '"$FC_SOURCE/projects/fal_client"', "flock -n 9", "require_ram_mb 1024",
                         "require_disk_mb 2048", "-ge 512", "direct_url.json",
                         "sys.prefix != sys.base_prefix", "unset FAL_KEY FAL_KEY_ID FAL_KEY_SECRET"):
            self.assertIn(required, text)
        for forbidden in ("import fal_client", "fal_client.subscribe", "fal_client.upload",
                          "docker compose", "rm -rf", "[dev]", "af_prepare_venv",
                          "fal auth", "fal deploy"):
            self.assertNotIn(forbidden, text)

    def test_dependency_order_and_scope(self):
        text = (ROOT / HELPER).read_text()
        main = text.split('fal_client_main() (', 1)[1]
        for guard in ('fc_resources', 'flock -n 9', 'exec > >(tee'):
            self.assertLess(main.index(guard), main.index('fc_prepare_python'))
        self.assertLess(main.index('fc_prepare_python'), main.index('fc_fetch'))
        self.assertIn('fc_prepare_python || return 1', main)
        self.assertIn("sys.prefix == sys.base_prefix", text)
        self.assertIn("Path(sys.executable).resolve() == expected.resolve()", text)
        self.assertIn('run_apt_with_lock_wait update || return 1', text)
        self.assertIn('install -y --no-install-recommends "$1"', text)

    def test_menu_doc_links(self):
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('TOOL_SCRIPT_NAMES["Fal_Client"]="fal_client"', menu)
        doc = ROOT / "docs/tools/fal-client.md"
        for link in re.findall(r"\]\(([^)]+)\)", doc.read_text()):
            if "://" not in link and not link.startswith("#"):
                self.assertTrue((doc.parent / link.split("#")[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), "bash unavailable")
class Offline(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as tmp:
            prefix = f"""
export OPENCLAW_USER_DATA_DIR='{sp(Path(tmp) / "private")}'
export FAL_CLIENT_PYTHON_BIN='{sp(Path(sys.executable))}'
source {HELPER}
fc_paths
"""
            return subprocess.run([str(BASH), "--noprofile", "--norc", "-c", prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=90)

    def test_dry_run_no_files(self):
        r = self.shell("""
git() { exit 99; }; python3() { exit 99; }; sudo() { exit 99; }
fal_client_main --dry-run
test ! -e "$FC_BASE"
""")
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
fc_python_core_ok() {{ {core}; }}
fc_python_venv_ok() {{ {venv}; }}
fc_venv_package() {{ {package}; }}
command() {{ return 0; }}
fc_install_venv_package() {{
    [[ "$1" == python3.12-venv ]] || return 99
    echo MOCK_PACKAGE_INSTALL
    {install};
}}
FAL_CLIENT_INSTALL_VENV_DEPS={policy} fc_prepare_python
''')
                self.assertEqual(r.returncode, expected, r.stderr)
                self.assertEqual('MOCK_PACKAGE_INSTALL' in r.stdout, called)

    def test_read_only_actions_never_prepare_dependencies(self):
        for action, expected in (('--dry-run', 0), ('status', 0), ('doctor', 1)):
            with self.subTest(action=action):
                r = self.shell('fc_prepare_python() { echo UNEXPECTED_REPAIR; return 99; }; fal_client_main ' + action)
                self.assertEqual(r.returncode, expected, r.stderr)
                self.assertNotIn('UNEXPECTED_REPAIR', r.stdout)

    def test_status_missing(self):
        r = self.shell('fal_client_main status; test ! -e "$FC_BASE"')
        self.assertEqual(r.returncode, 0, r.stderr)
        state = json.loads(r.stdout)
        self.assertFalse(state["installed"])
        self.assertFalse(state["cloud_called"])

    def test_api_actions_rejected(self):
        for action, expected in (("doctor", 1), ("login", 2), ("upload", 2), ("subscribe", 2)):
            self.assertEqual(self.shell("fal_client_main " + action).returncode, expected)

    def test_bad_root(self):
        for path in ("/", "$FC_ROOT/private", "$HOME/../other"):
            r = self.shell('OPENCLAW_USER_DATA_DIR="' + path + '" fal_client_main --dry-run')
            self.assertNotEqual(r.returncode, 0)

    def test_foreign_source_preserved(self):
        r = self.shell("""
mkdir -p "$FC_SOURCE"
echo keep > "$FC_SOURCE/own-file"
if fc_fetch; then exit 99; fi
test "$(cat "$FC_SOURCE/own-file")" = keep
test ! -e "$FC_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_monorepo_subdirectory_required(self):
        r = self.shell("""
mkdir -p "$FC_SOURCE"
touch "$FC_SOURCE/pyproject.toml"
fc_source_ok() { return 0; }
if fc_fetch; then exit 99; fi
test ! -e "$FC_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_expected_subdirectory_accepted(self):
        r = self.shell("""
mkdir -p "$FC_SOURCE/projects/fal_client/src/fal_client"
touch "$FC_SOURCE/projects/fal_client/pyproject.toml" "$FC_SOURCE/projects/fal_client/src/fal_client/__init__.py"
fc_source_ok() { return 0; }
fc_fetch
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_foreign_venv_rejected(self):
        r = self.shell("""
mkdir -p "$FC_VENV"
uname() { echo x86_64; }
fc_preflight
""")
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_system_site_packages_rejected(self):
        r = self.shell("""
mkdir -p "$FC_VENV"
echo 'include-system-site-packages = true' > "$FC_VENV/pyvenv.cfg"
uname() { echo x86_64; }
fc_preflight
""")
        self.assertNotEqual(r.returncode, 0)

    def test_key_environment_not_inherited(self):
        r = self.shell("""
export FAL_KEY=SYNTHETIC_TEST_ONLY FAL_KEY_ID=SYNTHETIC_TEST_ONLY FAL_KEY_SECRET=SYNTHETIC_TEST_ONLY
# A substitute probe checks only variable absence, never prints them.
fc_probe() { [[ ! -v FAL_KEY && ! -v FAL_KEY_ID && ! -v FAL_KEY_SECRET ]]; }
fal_client_main status
test "$FAL_KEY" = SYNTHETIC_TEST_ONLY
""")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue(json.loads(r.stdout)["installed"])
        self.assertNotIn("SYNTHETIC", r.stdout)

    def test_mock_package_build_targets_client_only(self):
        r = self.shell(r'''
mkdir -p "$FC_BASE"
export FC_BASE FC_VENV
fc_mock_python() {
    if [[ "$*" == *"-m venv"* ]]; then
        mkdir -p "$FC_VENV/bin"
        printf '#!/usr/bin/env bash\nfc_mock_python "$@"\n' > "$FC_VENV/bin/python"
        chmod +x "$FC_VENV/bin/python"
    elif [[ "$*" == *"pip --isolated install"* ]]; then
        test "$SETUPTOOLS_SCM_PRETEND_VERSION_FOR_FAL_CLIENT" = 1.0.3 || return 98
        printf '%s\n' "$*" > "$FC_BASE/install-args"
    elif [[ "$*" == *"pip --isolated check"* ]]; then
        touch "$FC_BASE/pip-checked"
    else return 99
    fi
}
export -f fc_mock_python
FC_PYTHON=fc_mock_python
fc_metadata() { test -f "$FC_BASE/pip-checked"; }
fc_source_ok() { return 0; }
fc_install_package
grep -Fq -- "--only-binary=:all: $FC_SOURCE/projects/fal_client" "$FC_BASE/install-args"
test "$(cat "$FC_MARKER")" = "$FC_COMMIT base"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_failed_package_build_clears_marker(self):
        r = self.shell(r'''
mkdir -p "$FC_BASE"
echo old > "$FC_MARKER"
fc_mock_python() { return 42; }
FC_PYTHON=fc_mock_python
set +e
(set -e; fc_install_package)
rc=$?
test "$rc" = 42 && test ! -e "$FC_MARKER"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_deactivation_keeps_data(self):
        r = self.shell("""
mkdir -p "$FC_SOURCE" "$FC_VENV"
touch "$FC_MARKER" "$FC_SOURCE/own-file" "$FC_VENV/own-file"
fc_deactivate
test ! -e "$FC_MARKER" && test -f "$FC_SOURCE/own-file" && test -f "$FC_VENV/own-file"
""")
        self.assertEqual(r.returncode, 0, r.stderr)


if __name__ == "__main__":
    unittest.main()
