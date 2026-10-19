"""Offline Veo API tests: no SDK imports, real installation, credentials, APIs or WSL."""
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
HELPER = "scripts/tools/helpers/veo_api_common.sh"


def sp(path):
    value = str(path).replace("\\", "/")
    return "/" + value[0].lower() + value[2:] if os.name == "nt" else value


class Contract(unittest.TestCase):
    def test_source_contract(self):
        tool, = [t for t in json.loads((ROOT / "config/tools.yml").read_text())["tools"] if t["id"] == "veo_api"]
        self.assertEqual(tool["version"], "2.31.0")
        self.assertEqual(tool["status"], "experimental")
        self.assertEqual(tool["install_mode"], "source")
        self.assertFalse(tool["auto_install"])
        self.assertEqual(tool["ports"], [])
        text = (ROOT / HELPER).read_text()
        self.assertIn("VA_COMMIT=" + tool["source_commit"], text)
        for field in ("doc", "install_script", "update_script", "uninstall_script", "doctor_script"):
            self.assertTrue((ROOT / tool[field]).is_file(), field)
        for required in ("VA_VERSION=2.31.0", "--only-binary=:all:",
                         '"$VA_SOURCE"', "flock -n 9", "require_ram_mb 1024",
                         "require_disk_mb 2048", "-ge 512", "direct_url.json",
                         "sys.prefix != sys.base_prefix", "unset GOOGLE_API_KEY GEMINI_API_KEY GOOGLE_APPLICATION_CREDENTIALS"):
            self.assertIn(required, text)
        for forbidden in ("import google.genai", "generate_videos(", "files.upload(",
                          "docker compose", "rm -rf", "[dev]", "af_prepare_venv",
                          "gcloud auth", "Client("):
            self.assertNotIn(forbidden, text)

    def test_dependency_order_and_scope(self):
        text = (ROOT / HELPER).read_text()
        main = text.split('veo_api_main() (', 1)[1]
        for guard in ('va_resources', 'flock -n 9', 'exec > >(tee'):
            self.assertLess(main.index(guard), main.index('va_prepare_python'))
        self.assertLess(main.index('va_prepare_python'), main.index('va_fetch'))
        self.assertIn('va_prepare_python || return 1', main)
        self.assertIn('sys.prefix == sys.base_prefix', text)
        self.assertIn('Path(sys.executable).resolve() == expected.resolve()', text)
        self.assertIn('run_apt_with_lock_wait update || return 1', text)
        self.assertIn('install -y --no-install-recommends "$1"', text)

    def test_menu_doc_links(self):
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('TOOL_SCRIPT_NAMES["Veo_API"]="veo_api"', menu)
        doc = ROOT / "docs/tools/veo-api.md"
        for link in re.findall(r"\]\(([^)]+)\)", doc.read_text()):
            if "://" not in link and not link.startswith("#"):
                self.assertTrue((doc.parent / link.split("#")[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), "bash unavailable")
class Offline(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as tmp:
            prefix = f"""
export OPENCLAW_USER_DATA_DIR='{sp(Path(tmp) / "private")}'
export VEO_API_PYTHON_BIN='{sp(Path(sys.executable))}'
source {HELPER}
va_paths
"""
            return subprocess.run([str(BASH), "--noprofile", "--norc", "-c", prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=90)

    def test_dry_run_no_files(self):
        r = self.shell("""
git() { exit 99; }; python3() { exit 99; }; sudo() { exit 99; }
veo_api_main --dry-run
test ! -e "$VA_BASE"
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
va_python_core_ok() {{ {core}; }}
va_python_venv_ok() {{ {venv}; }}
va_venv_package() {{ {package}; }}
command() {{ return 0; }}
va_install_venv_package() {{
    [[ "$1" == python3.12-venv ]] || return 99
    echo MOCK_PACKAGE_INSTALL
    {install};
}}
VEO_API_INSTALL_VENV_DEPS={policy} va_prepare_python
''')
                self.assertEqual(r.returncode, expected, r.stderr)
                self.assertEqual('MOCK_PACKAGE_INSTALL' in r.stdout, called)

    def test_read_only_actions_never_prepare_dependencies(self):
        for action, expected in (('--dry-run', 0), ('status', 0), ('doctor', 1)):
            with self.subTest(action=action):
                r = self.shell('va_prepare_python() { echo UNEXPECTED_REPAIR; return 99; }; veo_api_main ' + action)
                self.assertEqual(r.returncode, expected, r.stderr)
                self.assertNotIn('UNEXPECTED_REPAIR', r.stdout)

    def test_status_missing(self):
        r = self.shell('veo_api_main status; test ! -e "$VA_BASE"')
        self.assertEqual(r.returncode, 0, r.stderr)
        state = json.loads(r.stdout)
        self.assertFalse(state["installed"])
        self.assertFalse(state["cloud_called"])

    def test_api_actions_rejected(self):
        for action, expected in (("doctor", 1), ("login", 2), ("upload", 2), ("subscribe", 2)):
            self.assertEqual(self.shell("veo_api_main " + action).returncode, expected)

    def test_bad_root(self):
        for path in ("/", "$VA_ROOT/private", "$HOME/../other"):
            r = self.shell('OPENCLAW_USER_DATA_DIR="' + path + '" veo_api_main --dry-run')
            self.assertNotEqual(r.returncode, 0)

    def test_foreign_source_preserved(self):
        r = self.shell("""
mkdir -p "$VA_SOURCE"
echo keep > "$VA_SOURCE/own-file"
if va_fetch; then exit 99; fi
test "$(cat "$VA_SOURCE/own-file")" = keep
test ! -e "$VA_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_missing_sdk_layout_rejected(self):
        r = self.shell("""
mkdir -p "$VA_SOURCE"
touch "$VA_SOURCE/pyproject.toml"
va_source_ok() { return 0; }
if va_fetch; then exit 99; fi
test ! -e "$VA_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_expected_subdirectory_accepted(self):
        r = self.shell("""
mkdir -p "$VA_SOURCE/google/genai"
touch "$VA_SOURCE/pyproject.toml" "$VA_SOURCE/google/genai/__init__.py" "$VA_SOURCE/setup.cfg"
va_source_ok() { return 0; }
va_fetch
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_foreign_venv_rejected(self):
        r = self.shell("""
mkdir -p "$VA_VENV"
uname() { echo x86_64; }
va_preflight
""")
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_system_site_packages_rejected(self):
        r = self.shell("""
mkdir -p "$VA_VENV"
echo 'include-system-site-packages = true' > "$VA_VENV/pyvenv.cfg"
uname() { echo x86_64; }
va_preflight
""")
        self.assertNotEqual(r.returncode, 0)

    def test_key_environment_not_inherited(self):
        r = self.shell("""
export GOOGLE_API_KEY=SYNTHETIC_TEST_ONLY GEMINI_API_KEY=SYNTHETIC_TEST_ONLY GOOGLE_APPLICATION_CREDENTIALS=SYNTHETIC_TEST_ONLY
# A substitute probe checks only variable absence, never prints them.
va_probe() { [[ ! -v GOOGLE_API_KEY && ! -v GEMINI_API_KEY && ! -v GOOGLE_APPLICATION_CREDENTIALS ]]; }
veo_api_main status
test "$GOOGLE_API_KEY" = SYNTHETIC_TEST_ONLY
""")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue(json.loads(r.stdout)["installed"])
        self.assertNotIn("SYNTHETIC", r.stdout)

    def test_mock_package_build_targets_client_only(self):
        r = self.shell(r'''
mkdir -p "$VA_BASE"
export VA_BASE VA_VENV
va_mock_python() {
    if [[ "$*" == *"-m venv"* ]]; then
        mkdir -p "$VA_VENV/bin"
        printf '#!/usr/bin/env bash\nva_mock_python "$@"\n' > "$VA_VENV/bin/python"
        chmod +x "$VA_VENV/bin/python"
    elif [[ "$*" == *"pip --isolated install"* ]]; then
                printf '%s\n' "$*" > "$VA_BASE/install-args"
    elif [[ "$*" == *"pip --isolated check"* ]]; then
        touch "$VA_BASE/pip-checked"
    else return 99
    fi
}
export -f va_mock_python
VA_PYTHON=va_mock_python
va_metadata() { test -f "$VA_BASE/pip-checked"; }
va_source_ok() { return 0; }
va_install_package
grep -Fq -- "--only-binary=:all: $VA_SOURCE" "$VA_BASE/install-args"
test "$(cat "$VA_MARKER")" = "$VA_COMMIT base"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_failed_package_build_clears_marker(self):
        r = self.shell(r'''
mkdir -p "$VA_BASE"
echo old > "$VA_MARKER"
va_mock_python() { return 42; }
VA_PYTHON=va_mock_python
set +e
(set -e; va_install_package)
rc=$?
test "$rc" = 42 && test ! -e "$VA_MARKER"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_deactivation_keeps_data(self):
        r = self.shell("""
mkdir -p "$VA_SOURCE" "$VA_VENV"
touch "$VA_MARKER" "$VA_SOURCE/own-file" "$VA_VENV/own-file"
va_deactivate
test ! -e "$VA_MARKER" && test -f "$VA_SOURCE/own-file" && test -f "$VA_VENV/own-file"
""")
        self.assertEqual(r.returncode, 0, r.stderr)


if __name__ == "__main__":
    unittest.main()
