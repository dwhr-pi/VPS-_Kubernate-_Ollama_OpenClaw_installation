"""Offline Moshi tests: no SDK imports, real installation, credentials, APIs or WSL."""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
from doc_assertions import assert_prose_in, assert_prose_not_in
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = "C:/Program Files/Git/bin/bash.exe" if os.name == "nt" else shutil.which("bash")
HELPER = "scripts/tools/helpers/moshi_common.sh"


def sp(path):
    value = str(path).replace("\\", "/")
    return "/" + value[0].lower() + value[2:] if os.name == "nt" else value


class Contract(unittest.TestCase):
    def test_source_contract(self):
        tool, = [t for t in json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"] if t["id"] == "moshi"]
        self.assertEqual(tool["version"], "0.2.13")
        self.assertEqual(tool["status"], "experimental")
        self.assertEqual(tool["install_mode"], "source")
        self.assertFalse(tool["auto_install"])
        self.assertEqual(tool["ports"], [])
        text = (ROOT / HELPER).read_text(encoding="utf-8")
        self.assertIn("MO_COMMIT=" + tool["source_commit"], text)
        self.assertIn('MO_PACKAGE="$MO_SOURCE/moshi"', text)
        self.assertIn('distribution("moshi")', text)
        self.assertIn('--no-deps "$MO_PACKAGE"', text)
        for field in ("doc", "install_script", "update_script", "uninstall_script", "doctor_script"):
            self.assertTrue((ROOT / tool[field]).is_file(), field)
        for required in ("MO_VERSION=0.2.13", "--no-deps",
                         '"$MO_SOURCE"', "flock -n 9", "require_ram_mb 1024",
                         "require_disk_mb 2048", "-ge 512", "direct_url.json",
                         "sys.prefix != sys.base_prefix", "unset HF_TOKEN HUGGING_FACE_HUB_TOKEN"):
            self.assertIn(required, text)
        for forbidden in ("import moshi", "generate_videos(", "files.upload(",
                          "docker compose", "rm -rf", "[dev]", "af_prepare_venv",
                          "gcloud auth", "Client(", "remo_text"):
            self.assertNotIn(forbidden, text)

    def test_dependency_order_and_scope(self):
        text = (ROOT / HELPER).read_text(encoding="utf-8")
        main = text.split('moshi_main() (', 1)[1]
        for guard in ('mo_resources', 'flock -n 9', 'exec > >(tee', 'MOSHI_INSTALL_RUNTIME'):
            self.assertLess(main.index(guard), main.index('mo_prepare_python'))
        self.assertLess(main.index('mo_prepare_python'), main.index('mo_fetch'))
        self.assertIn('mo_prepare_python || return 1', main)
        self.assertIn('sys.prefix == sys.base_prefix', text)
        self.assertIn('Path(sys.executable).resolve() == expected.resolve()', text)
        self.assertIn('assert (3, 10) <= sys.version_info < (3, 13)', text)
        self.assertIn('run_apt_with_lock_wait update || return 1', text)
        self.assertIn('install -y --no-install-recommends "$1"', text)

    def test_menu_doc_links(self):
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('TOOL_SCRIPT_NAMES["Moshi"]="moshi"', menu)
        doc = ROOT / "docs/tools/moshi.md"
        for link in re.findall(r"\]\(([^)]+)\)", doc.read_text(encoding="utf-8")):
            if "://" not in link and not link.startswith("#"):
                self.assertTrue((doc.parent / link.split("#")[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), "bash unavailable")
class Offline(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as tmp:
            prefix = f"""
export OPENCLAW_USER_DATA_DIR='{sp(Path(tmp) / "private")}'
export MOSHI_PYTHON_BIN='{sp(Path(sys.executable))}'
source {HELPER}
mo_paths
"""
            return subprocess.run([str(BASH), "--noprofile", "--norc", "-c", prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=90)

    def test_dry_run_no_files(self):
        r = self.shell("""
git() { exit 99; }; python3() { exit 99; }; sudo() { exit 99; }
moshi_main --dry-run
test ! -e "$MO_BASE"
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
mo_python_core_ok() {{ {core}; }}
mo_python_venv_ok() {{ {venv}; }}
mo_venv_package() {{ {package}; }}
command() {{ return 0; }}
mo_install_venv_package() {{
    [[ "$1" == python3.12-venv ]] || return 99
    echo MOCK_PACKAGE_INSTALL
    {install};
}}
MOSHI_INSTALL_VENV_DEPS={policy} mo_prepare_python
''')
                self.assertEqual(r.returncode, expected, r.stderr)
                self.assertEqual('MOCK_PACKAGE_INSTALL' in r.stdout, called)

    def test_read_only_actions_never_prepare_dependencies(self):
        for action, expected in (('--dry-run', 0), ('status', 0), ('doctor', 1)):
            with self.subTest(action=action):
                r = self.shell('mo_prepare_python() { echo UNEXPECTED_REPAIR; return 99; }; moshi_main ' + action)
                self.assertEqual(r.returncode, expected, r.stderr)
                self.assertNotIn('UNEXPECTED_REPAIR', r.stdout)

    def test_status_missing(self):
        r = self.shell('moshi_main status; test ! -e "$MO_BASE"')
        self.assertEqual(r.returncode, 0, r.stderr)
        state = json.loads(r.stdout)
        self.assertFalse(state["installed"])
        self.assertFalse(state["runtime_dependencies"])
        self.assertFalse(state["inference_tested"])

    def test_api_actions_rejected(self):
        for action, expected in (("doctor", 1), ("login", 2), ("upload", 2), ("subscribe", 2)):
            self.assertEqual(self.shell("moshi_main " + action).returncode, expected)

    def test_bad_root(self):
        for path in ("/", "$MO_ROOT/private", "$HOME/../other"):
            r = self.shell('OPENCLAW_USER_DATA_DIR="' + path + '" moshi_main --dry-run')
            self.assertNotEqual(r.returncode, 0)

    def test_foreign_source_preserved(self):
        r = self.shell("""
mkdir -p "$MO_SOURCE"
echo keep > "$MO_SOURCE/own-file"
if mo_fetch; then exit 99; fi
test "$(cat "$MO_SOURCE/own-file")" = keep
test ! -e "$MO_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_missing_sdk_layout_rejected(self):
        r = self.shell("""
mkdir -p "$MO_SOURCE"
touch "$MO_SOURCE/pyproject.toml"
mo_source_ok() { return 0; }
if mo_fetch; then exit 99; fi
test ! -e "$MO_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_expected_subdirectory_accepted(self):
        r = self.shell("""
mkdir -p "$MO_PACKAGE/moshi"
touch "$MO_PACKAGE/pyproject.toml" "$MO_PACKAGE/moshi/__init__.py" "$MO_SOURCE/LICENSE-MIT"
mo_source_ok() { return 0; }
mo_fetch
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_foreign_venv_rejected(self):
        r = self.shell("""
mkdir -p "$MO_VENV"
uname() { echo x86_64; }
mo_preflight
""")
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_system_site_packages_rejected(self):
        r = self.shell("""
mkdir -p "$MO_VENV"
echo 'include-system-site-packages = true' > "$MO_VENV/pyvenv.cfg"
uname() { echo x86_64; }
mo_preflight
""")
        self.assertNotEqual(r.returncode, 0)

    def test_key_environment_not_inherited(self):
        r = self.shell("""
export HF_TOKEN=SYNTHETIC_TEST_ONLY TEST_UNRELATED_KEY=SYNTHETIC_TEST_ONLY HUGGING_FACE_HUB_TOKEN=SYNTHETIC_TEST_ONLY
# A substitute probe checks only variable absence, never prints them.
mo_probe() { [[ ! -v HF_TOKEN && ! -v HUGGING_FACE_HUB_TOKEN && "$HF_HUB_OFFLINE" == 1 ]]; }
moshi_main status
test "$HF_TOKEN" = SYNTHETIC_TEST_ONLY
""")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue(json.loads(r.stdout)["installed"])
        self.assertNotIn("SYNTHETIC", r.stdout)

    def test_mock_package_build_targets_client_only(self):
        r = self.shell(r'''
mkdir -p "$MO_BASE"
export MO_BASE MO_VENV
mo_mock_python() {
    if [[ "$*" == *"-m venv"* ]]; then
        mkdir -p "$MO_VENV/bin"
        printf '#!/usr/bin/env bash\nmo_mock_python "$@"\n' > "$MO_VENV/bin/python"
        chmod +x "$MO_VENV/bin/python"
    elif [[ "$*" == *"pip --isolated install"* ]]; then
                printf '%s\n' "$*" > "$MO_BASE/install-args"
    elif [[ "$*" == *"pip --isolated check"* ]]; then
        touch "$MO_BASE/pip-checked"
    else return 99
    fi
}
export -f mo_mock_python
MO_PYTHON=mo_mock_python
mo_metadata() { test -f "$MO_BASE/install-args"; }
mo_source_ok() { return 0; }
mo_install_package
grep -Fq -- "--no-deps $MO_PACKAGE" "$MO_BASE/install-args"
test "$(cat "$MO_MARKER")" = "$MO_COMMIT base"
test ! -e "$MO_BASE/pip-checked"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_failed_package_build_clears_marker(self):
        r = self.shell(r'''
mkdir -p "$MO_BASE"
echo old > "$MO_MARKER"
mo_mock_python() { return 42; }
MO_PYTHON=mo_mock_python
set +e
(set -e; mo_install_package)
rc=$?
test "$rc" = 42 && test ! -e "$MO_MARKER"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_deactivation_keeps_data(self):
        r = self.shell("""
mkdir -p "$MO_SOURCE" "$MO_VENV"
touch "$MO_MARKER" "$MO_SOURCE/own-file" "$MO_VENV/own-file"
mo_deactivate
test ! -e "$MO_MARKER" && test -f "$MO_SOURCE/own-file" && test -f "$MO_VENV/own-file"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_legacy_runtime_rejected_before_tools(self):
        r = self.shell("MOSHI_INSTALL_RUNTIME=1 moshi_main install")
        self.assertEqual(r.returncode, 2, r.stderr)
        self.assertIn("GPU-Runtime", r.stderr)

    def test_low_total_ram_blocks_even_in_conditional(self):
        r = self.shell('''
mkdir -p "$MO_BASE"
source() { return 0; }
require_ram_mb() { return 1; }
require_disk_mb() { touch "$MO_BASE/disk-reached"; }
if mo_resources; then exit 99; fi
test ! -e "$MO_BASE/disk-reached"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_safety_documentation(self):
        doc = (ROOT / "docs/tools/moshi.md").read_text(encoding="utf-8")
        for warning in ("CC-BY 4.0", "MIT", "PortAudio", "Mikrofon", "3.12", "--no-deps"):
            assert_prose_in(self, warning, doc)


if __name__ == "__main__":
    unittest.main()
