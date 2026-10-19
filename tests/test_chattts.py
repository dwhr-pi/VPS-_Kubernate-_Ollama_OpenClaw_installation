"""Offline ChatTTS tests: no SDK imports, real installation, credentials, APIs or WSL."""
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
HELPER = "scripts/tools/helpers/chattts_common.sh"


def sp(path):
    value = str(path).replace("\\", "/")
    return "/" + value[0].lower() + value[2:] if os.name == "nt" else value


class Contract(unittest.TestCase):
    def test_source_contract(self):
        tool, = [t for t in json.loads((ROOT / "config/tools.yml").read_text())["tools"] if t["id"] == "chattts"]
        self.assertEqual(tool["package_version"], "0.0.0")
        self.assertEqual(tool["status"], "experimental")
        self.assertEqual(tool["install_mode"], "source")
        self.assertFalse(tool["auto_install"])
        self.assertEqual(tool["ports"], [])
        text = (ROOT / HELPER).read_text()
        self.assertIn("CT_COMMIT=" + tool["source_commit"], text)
        for field in ("doc", "install_script", "update_script", "uninstall_script", "doctor_script"):
            self.assertTrue((ROOT / tool[field]).is_file(), field)
        for required in ("CT_VERSION=0.0.0", "--no-deps",
                         '"$CT_SOURCE"', "flock -n 9", "require_ram_mb 1024",
                         "require_disk_mb 2048", "-ge 512", "direct_url.json",
                         "sys.prefix != sys.base_prefix", "INSTALL_HEAVY_TOOLS"):
            self.assertIn(required, text)
        for forbidden in ("import ChatTTS", "from_pretrained(", "import torch",
                          "docker compose", "rm -rf", "[dev]", "af_prepare_venv",
                          "gcloud auth", "Client("):
            self.assertNotIn(forbidden, text)

    def test_dependency_order_and_scope(self):
        text = (ROOT / HELPER).read_text()
        main = text.split('chattts_main() (', 1)[1]
        for guard in ('ct_resources', 'ct_runtime_preflight', 'flock -n 9', 'exec > >(tee'):
            self.assertLess(main.index(guard), main.index('ct_prepare_python'))
        self.assertLess(main.index('ct_prepare_python'), main.index('ct_fetch'))
        self.assertIn('ct_prepare_python || return 1', main)
        self.assertIn('sys.prefix == sys.base_prefix', text)
        self.assertIn('Path(sys.executable).resolve() == expected.resolve()', text)
        self.assertIn('assert (3, 10) <= sys.version_info < (3, 13)', text)
        self.assertIn('run_apt_with_lock_wait update || return 1', text)
        self.assertIn('install -y --no-install-recommends "$1"', text)

    def test_menu_doc_links(self):
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('TOOL_SCRIPT_NAMES["ChatTTS"]="chattts"', menu)
        doc = ROOT / "docs/tools/chattts.md"
        for link in re.findall(r"\]\(([^)]+)\)", doc.read_text()):
            if "://" not in link and not link.startswith("#"):
                self.assertTrue((doc.parent / link.split("#")[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), "bash unavailable")
class Offline(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as tmp:
            prefix = f"""
export OPENCLAW_USER_DATA_DIR='{sp(Path(tmp) / "private")}'
export CHATTTS_PYTHON_BIN='{sp(Path(sys.executable))}'
unset CHATTTS_INSTALL_RUNTIME INSTALL_HEAVY_TOOLS
source {HELPER}
ct_paths
"""
            return subprocess.run([str(BASH), "--noprofile", "--norc", "-c", prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=90)

    def test_dry_run_no_files(self):
        r = self.shell("""
git() { exit 99; }; python3() { exit 99; }; sudo() { exit 99; }
chattts_main --dry-run
test ! -e "$CT_BASE"
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
ct_python_core_ok() {{ {core}; }}
ct_python_venv_ok() {{ {venv}; }}
ct_venv_package() {{ {package}; }}
command() {{ return 0; }}
ct_install_venv_package() {{
    [[ "$1" == python3.12-venv ]] || return 99
    echo MOCK_PACKAGE_INSTALL
    {install};
}}
CHATTTS_INSTALL_VENV_DEPS={policy} ct_prepare_python
''')
                self.assertEqual(r.returncode, expected, r.stderr)
                self.assertEqual('MOCK_PACKAGE_INSTALL' in r.stdout, called)

    def test_read_only_actions_never_prepare_dependencies(self):
        for action, expected in (('--dry-run', 0), ('status', 0), ('doctor', 1)):
            with self.subTest(action=action):
                r = self.shell('ct_prepare_python() { echo UNEXPECTED_REPAIR; return 99; }; chattts_main ' + action)
                self.assertEqual(r.returncode, expected, r.stderr)
                self.assertNotIn('UNEXPECTED_REPAIR', r.stdout)

    def test_status_missing(self):
        r = self.shell('chattts_main status; test ! -e "$CT_BASE"')
        self.assertEqual(r.returncode, 0, r.stderr)
        state = json.loads(r.stdout)
        self.assertFalse(state["installed"])
        self.assertFalse(state["models_checked"])
        self.assertFalse(state["inference_tested"])

    def test_api_actions_rejected(self):
        for action, expected in (("doctor", 1), ("login", 2), ("upload", 2), ("subscribe", 2)):
            self.assertEqual(self.shell("chattts_main " + action).returncode, expected)

    def test_bad_root(self):
        for path in ("/", "$CT_ROOT/private", "$HOME/../other"):
            r = self.shell('OPENCLAW_USER_DATA_DIR="' + path + '" chattts_main --dry-run')
            self.assertNotEqual(r.returncode, 0)

    def test_foreign_source_preserved(self):
        r = self.shell("""
mkdir -p "$CT_SOURCE"
echo keep > "$CT_SOURCE/own-file"
if ct_fetch; then exit 99; fi
test "$(cat "$CT_SOURCE/own-file")" = keep
test ! -e "$CT_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_missing_sdk_layout_rejected(self):
        r = self.shell("""
mkdir -p "$CT_SOURCE"
touch "$CT_SOURCE/pyproject.toml"
ct_source_ok() { return 0; }
if ct_fetch; then exit 99; fi
test ! -e "$CT_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_expected_subdirectory_accepted(self):
        r = self.shell("""
mkdir -p "$CT_SOURCE/ChatTTS"
touch "$CT_SOURCE/setup.py" "$CT_SOURCE/ChatTTS/__init__.py" "$CT_SOURCE/requirements.txt"
ct_source_ok() { return 0; }
ct_fetch
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_foreign_venv_rejected(self):
        r = self.shell("""
mkdir -p "$CT_VENV"
uname() { echo x86_64; }
ct_preflight
""")
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_system_site_packages_rejected(self):
        r = self.shell("""
mkdir -p "$CT_VENV"
echo 'include-system-site-packages = true' > "$CT_VENV/pyvenv.cfg"
uname() { echo x86_64; }
ct_preflight
""")
        self.assertNotEqual(r.returncode, 0)

    def test_key_environment_not_inherited(self):
        r = self.shell("""
export HF_TOKEN=SYNTHETIC_TEST_ONLY TEST_UNRELATED_KEY=SYNTHETIC_TEST_ONLY HUGGING_FACE_HUB_TOKEN=SYNTHETIC_TEST_ONLY
# A substitute probe checks only variable absence, never prints them.
ct_probe() { [[ ! -v HF_TOKEN && ! -v HUGGING_FACE_HUB_TOKEN && "$HF_HUB_OFFLINE" == 1 ]]; }
mkdir -p "$CT_BASE"
echo "$CT_COMMIT package" > "$CT_MARKER"
chattts_main status
test "$HF_TOKEN" = SYNTHETIC_TEST_ONLY
""")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue(json.loads(r.stdout)["installed"])
        self.assertNotIn("SYNTHETIC", r.stdout)

    def test_mock_package_build_targets_client_only(self):
        r = self.shell(r'''
mkdir -p "$CT_BASE"
export CT_BASE CT_VENV
ct_mock_python() {
    if [[ "$*" == *"-m venv"* ]]; then
        mkdir -p "$CT_VENV/bin"
        printf '#!/usr/bin/env bash\nct_mock_python "$@"\n' > "$CT_VENV/bin/python"
        chmod +x "$CT_VENV/bin/python"
    elif [[ "$*" == *"pip --isolated install"* ]]; then
        test "$CHTTS_VER" = 0.0.0 || return 96
                printf '%s\n' "$*" > "$CT_BASE/install-args"
    elif [[ "$*" == *"pip --isolated check"* ]]; then
        touch "$CT_BASE/pip-checked"
    else return 99
    fi
}
export -f ct_mock_python
CT_PYTHON=ct_mock_python
export CHTTS_VER=99.99.99
ct_metadata() { test -f "$CT_BASE/install-args"; }
ct_source_ok() { return 0; }
ct_install_package
grep -Fq -- "--no-deps $CT_SOURCE" "$CT_BASE/install-args"
test "$(cat "$CT_MARKER")" = "$CT_COMMIT package"
test ! -e "$CT_BASE/pip-checked"
test "$CHTTS_VER" = 99.99.99
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_failed_package_build_clears_marker(self):
        r = self.shell(r'''
mkdir -p "$CT_BASE"
echo old > "$CT_MARKER"
ct_mock_python() { return 42; }
CT_PYTHON=ct_mock_python
set +e
(set -e; ct_install_package)
rc=$?
test "$rc" = 42 && test ! -e "$CT_MARKER"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_deactivation_keeps_data(self):
        r = self.shell("""
mkdir -p "$CT_SOURCE" "$CT_VENV"
touch "$CT_MARKER" "$CT_SOURCE/own-file" "$CT_VENV/own-file"
ct_deactivate
test ! -e "$CT_MARKER" && test -f "$CT_SOURCE/own-file" && test -f "$CT_VENV/own-file"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_runtime_requires_heavy_opt_in(self):
        r = self.shell("INSTALL_HEAVY_TOOLS=0 ct_runtime_preflight")
        self.assertEqual(r.returncode, 2, r.stderr)
        self.assertIn("INSTALL_HEAVY_TOOLS", r.stderr)

    def test_runtime_requires_existing_torch(self):
        r = self.shell("INSTALL_HEAVY_TOOLS=1 ct_runtime_preflight")
        self.assertEqual(r.returncode, 1, r.stderr)
        self.assertIn("Torch", r.stderr)

    def test_runtime_constraints_are_passed_and_pip_checked(self):
        r = self.shell(r'''
mkdir -p "$CT_BASE"
export CT_BASE CT_VENV
ct_mock_python() {
    if [[ "$*" == *"-m venv"* ]]; then
        mkdir -p "$CT_VENV/bin"
        printf '#!/usr/bin/env bash\nct_mock_python "$@"\n' > "$CT_VENV/bin/python"
        chmod +x "$CT_VENV/bin/python"
    elif [[ "$*" == *"pip --isolated install"* ]]; then
        test "$CHTTS_VER" = 0.0.0 || return 96
        printf '%s\n' "$*" > "$CT_BASE/install-args"
        while [[ "$#" -gt 0 ]]; do
            if [[ "$1" == --constraint ]]; then
                grep -Fxq 'torch==2.7.0+cpu' "$2" || return 99
                grep -Fxq 'torchaudio==2.7.0+cpu' "$2" || return 99
                return 0
            fi
            shift
        done
        return 98
    elif [[ "$*" == *"pip --isolated check"* ]]; then
        touch "$CT_BASE/pip-checked"
    else return 97
    fi
}
export -f ct_mock_python
CT_PYTHON=ct_mock_python
CHATTTS_INSTALL_RUNTIME=1
ct_torch_constraints() { printf 'torch==2.7.0+cpu\ntorchaudio==2.7.0+cpu\n'; }
ct_source_ok() { return 0; }
ct_metadata() { return 0; }
ct_install_package
test "$(cat "$CT_MARKER")" = "$CT_COMMIT runtime"
test -e "$CT_BASE/pip-checked"
grep -Fq -- '--only-binary=torch,torchaudio,numba,llvmlite,numpy' "$CT_BASE/install-args"
''')
        self.assertEqual(r.returncode, 0, r.stderr)


if __name__ == "__main__":
    unittest.main()
