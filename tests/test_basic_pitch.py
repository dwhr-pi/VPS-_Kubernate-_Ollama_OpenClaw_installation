"""Offline Basic_Pitch tests: no SDK imports, real installation, credentials, APIs or WSL."""
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
HELPER = "scripts/tools/helpers/basic_pitch_common.sh"


def sp(path):
    value = str(path).replace("\\", "/")
    return "/" + value[0].lower() + value[2:] if os.name == "nt" else value


class Contract(unittest.TestCase):
    def test_source_contract(self):
        tool, = [t for t in json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"] if t["id"] == "basic_pitch"]
        self.assertEqual(tool["version"], "0.4.0")
        self.assertEqual(tool["status"], "experimental")
        self.assertEqual(tool["install_mode"], "source")
        self.assertFalse(tool["auto_install"])
        self.assertEqual(tool["ports"], [])
        text = (ROOT / HELPER).read_text(encoding="utf-8")
        self.assertIn("BP_COMMIT=" + tool["source_commit"], text)
        self.assertIn('distribution("basic-pitch")', text)
        self.assertIn('assert (3,10) <= sys.version_info < (3,13)', text)
        for field in ("doc", "install_script", "update_script", "uninstall_script", "doctor_script"):
            self.assertTrue((ROOT / tool[field]).is_file(), field)
        for required in ("BP_VERSION=0.4.0", "--no-deps",
                         '"$BP_SOURCE"', "flock -n 9", "require_ram_mb 1024",
                         "require_disk_mb 2048", "-ge 512", "direct_url.json",
                         "sys.prefix != sys.base_prefix", "unset HF_TOKEN HUGGING_FACE_HUB_TOKEN"):
            self.assertIn(required, text)
        for forbidden in ("import basic_pitch", "generate_videos(", "files.upload(",
                          "docker compose", "rm -rf", "[dev]", "af_prepare_venv",
                          "gcloud auth", "Client(", "rebp_text"):
            self.assertNotIn(forbidden, text)

    def test_dependency_order_and_scope(self):
        text = (ROOT / HELPER).read_text(encoding="utf-8")
        main = text.split('basic_pitch_main() (', 1)[1]
        for guard in ('bp_resources', 'bp_preflight', 'flock -n 9', 'exec > >(tee', 'BASIC_PITCH_INSTALL_RUNTIME'):
            self.assertLess(main.index(guard), main.index('bp_prepare_python'))
        self.assertLess(main.index('bp_prepare_python'), main.index('bp_fetch'))
        self.assertIn('bp_prepare_python || return 1', main)
        self.assertIn('sys.prefix == sys.base_prefix', text)
        self.assertIn('Path(sys.executable).resolve() == expected.resolve()', text)
        self.assertIn('assert (3, 10) <= sys.version_info < (3, 13)', text)
        self.assertIn('run_apt_with_lock_wait update || return 1', text)
        self.assertIn('install -y --no-install-recommends "$1"', text)

    def test_menu_doc_links(self):
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('TOOL_SCRIPT_NAMES["Basic_Pitch"]="basic_pitch"', menu)
        doc = ROOT / "docs/tools/basic-pitch.md"
        for link in re.findall(r"\]\(([^)]+)\)", doc.read_text(encoding="utf-8")):
            if "://" not in link and not link.startswith("#"):
                self.assertTrue((doc.parent / link.split("#")[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), "bash unavailable")
class Offline(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as tmp:
            prefix = f"""
export OPENCLAW_USER_DATA_DIR='{sp(Path(tmp) / "private")}'
export BASIC_PITCH_PYTHON_BIN='{sp(Path(sys.executable))}'
source {HELPER}
bp_paths
"""
            return subprocess.run([str(BASH), "--noprofile", "--norc", "-c", prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=90)

    def test_dry_run_no_files(self):
        r = self.shell("""
git() { exit 99; }; python3() { exit 99; }; sudo() { exit 99; }
basic_pitch_main --dry-run
test ! -e "$BP_BASE"
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
bp_python_core_ok() {{ {core}; }}
bp_python_venv_ok() {{ {venv}; }}
bp_venv_package() {{ {package}; }}
command() {{ return 0; }}
bp_install_venv_package() {{
    [[ "$1" == python3.12-venv ]] || return 99
    echo MOCK_PACKAGE_INSTALL
    {install};
}}
BASIC_PITCH_INSTALL_VENV_DEPS={policy} bp_prepare_python
''')
                self.assertEqual(r.returncode, expected, r.stderr)
                self.assertEqual('MOCK_PACKAGE_INSTALL' in r.stdout, called)

    def test_read_only_actions_never_prepare_dependencies(self):
        for action, expected in (('--dry-run', 0), ('status', 0), ('doctor', 1)):
            with self.subTest(action=action):
                r = self.shell('bp_prepare_python() { echo UNEXPECTED_REPAIR; return 99; }; basic_pitch_main ' + action)
                self.assertEqual(r.returncode, expected, r.stderr)
                self.assertNotIn('UNEXPECTED_REPAIR', r.stdout)

    def test_status_missing(self):
        r = self.shell('basic_pitch_main status; test ! -e "$BP_BASE"')
        self.assertEqual(r.returncode, 0, r.stderr)
        state = json.loads(r.stdout)
        self.assertFalse(state["installed"])
        self.assertFalse(state["runtime_dependencies"])
        self.assertFalse(state["inference_tested"])

    def test_api_actions_rejected(self):
        for action, expected in (("doctor", 1), ("login", 2), ("upload", 2), ("subscribe", 2)):
            self.assertEqual(self.shell("basic_pitch_main " + action).returncode, expected)

    def test_bad_root(self):
        for path in ("/", "$BP_ROOT/private", "$HOME/../other"):
            r = self.shell('OPENCLAW_USER_DATA_DIR="' + path + '" basic_pitch_main --dry-run')
            self.assertNotEqual(r.returncode, 0)

    def test_foreign_source_preserved(self):
        r = self.shell("""
mkdir -p "$BP_SOURCE"
echo keep > "$BP_SOURCE/own-file"
if bp_fetch; then exit 99; fi
test "$(cat "$BP_SOURCE/own-file")" = keep
test ! -e "$BP_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_missing_sdk_layout_rejected(self):
        r = self.shell("""
mkdir -p "$BP_SOURCE"
touch "$BP_SOURCE/pyproject.toml"
bp_source_ok() { return 0; }
if bp_fetch; then exit 99; fi
test ! -e "$BP_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_expected_subdirectory_accepted(self):
        r = self.shell("""
mkdir -p "$BP_SOURCE/basic_pitch/saved_models/icassp_2022"
touch "$BP_SOURCE/basic_pitch/saved_models/icassp_2022/nmp.onnx" "$BP_SOURCE/basic_pitch/saved_models/icassp_2022/nmp.tflite"
touch "$BP_SOURCE/pyproject.toml" "$BP_SOURCE/basic_pitch/__init__.py" "$BP_SOURCE/LICENSE"
bp_source_ok() { return 0; }
bp_fetch
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_foreign_venv_rejected(self):
        r = self.shell("""
mkdir -p "$BP_VENV"
uname() { echo x86_64; }
bp_preflight
""")
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_system_site_packages_rejected(self):
        r = self.shell("""
mkdir -p "$BP_VENV"
echo 'include-system-site-packages = true' > "$BP_VENV/pyvenv.cfg"
uname() { echo x86_64; }
bp_preflight
""")
        self.assertNotEqual(r.returncode, 0)

    def test_key_environment_not_inherited(self):
        r = self.shell("""
export HF_TOKEN=SYNTHETIC_TEST_ONLY TEST_UNRELATED_KEY=SYNTHETIC_TEST_ONLY HUGGING_FACE_HUB_TOKEN=SYNTHETIC_TEST_ONLY
mkdir -p "$BP_BASE"
echo "$BP_COMMIT base" > "$BP_MARKER"
# A substitute probe checks only variable absence, never prints them.
bp_probe() { [[ ! -v HF_TOKEN && ! -v HUGGING_FACE_HUB_TOKEN && "$HF_HUB_OFFLINE" == 1 ]]; }
basic_pitch_main status
test "$HF_TOKEN" = SYNTHETIC_TEST_ONLY
""")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue(json.loads(r.stdout)["installed"])
        self.assertNotIn("SYNTHETIC", r.stdout)

    def test_mock_package_build_targets_client_only(self):
        r = self.shell(r'''
mkdir -p "$BP_BASE"
export BP_BASE BP_VENV
bp_mock_python() {
    if [[ "$*" == *"-m venv"* ]]; then
        mkdir -p "$BP_VENV/bin"
        printf '#!/usr/bin/env bash\nbp_mock_python "$@"\n' > "$BP_VENV/bin/python"
        chmod +x "$BP_VENV/bin/python"
    elif [[ "$*" == *"pip --isolated install"* ]]; then
                printf '%s\n' "$*" > "$BP_BASE/install-args"
    elif [[ "$*" == *"pip --isolated check"* ]]; then
        touch "$BP_BASE/pip-checked"
    else return 99
    fi
}
export -f bp_mock_python
BP_PYTHON=bp_mock_python
bp_metadata() { test -f "$BP_BASE/install-args"; }
bp_source_ok() { return 0; }
bp_install_package
grep -Fq -- "--no-deps $BP_SOURCE" "$BP_BASE/install-args"
test "$(cat "$BP_MARKER")" = "$BP_COMMIT base"
test ! -e "$BP_BASE/pip-checked"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_failed_package_build_clears_marker(self):
        r = self.shell(r'''
mkdir -p "$BP_BASE"
echo old > "$BP_MARKER"
bp_mock_python() { return 42; }
BP_PYTHON=bp_mock_python
set +e
(set -e; bp_install_package)
rc=$?
test "$rc" = 1 && test ! -e "$BP_MARKER"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_deactivation_keeps_data(self):
        r = self.shell("""
mkdir -p "$BP_SOURCE" "$BP_VENV"
touch "$BP_MARKER" "$BP_SOURCE/own-file" "$BP_VENV/own-file"
bp_deactivate
test ! -e "$BP_MARKER" && test -f "$BP_SOURCE/own-file" && test -f "$BP_VENV/own-file"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_legacy_runtime_rejected_before_tools(self):
        r = self.shell("BASIC_PITCH_INSTALL_RUNTIME=1 basic_pitch_main install")
        self.assertEqual(r.returncode, 2, r.stderr)
        self.assertIn("INSTALL_HEAVY_TOOLS", r.stderr)

    def test_low_total_ram_blocks_even_in_conditional(self):
        r = self.shell('''
mkdir -p "$BP_BASE"
source() { return 0; }
require_ram_mb() { return 1; }
require_disk_mb() { touch "$BP_BASE/disk-reached"; }
if bp_resources; then exit 99; fi
test ! -e "$BP_BASE/disk-reached"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_safety_documentation(self):
        doc = (ROOT / "docs/tools/basic-pitch.md").read_text(encoding="utf-8")
        for warning in ("Apache-2.0", "TensorFlow", "3.12", "--no-deps"):
            self.assertIn(warning, doc)

    def test_runtime_package_mocked_with_constraints_and_pip_check(self):
        r = self.shell(r'''
mkdir -p "$BP_BASE"
export BP_BASE BP_VENV
bp_mock_python() {
    if [[ "$*" == *"-m venv"* ]]; then
        mkdir -p "$BP_VENV/bin"
        printf '#!/usr/bin/env bash\nbp_mock_python "$@"\n' > "$BP_VENV/bin/python"
        chmod +x "$BP_VENV/bin/python"
    elif [[ "$*" == *"pip --isolated install"* ]]; then
        printf '%s\n' "$*" > "$BP_BASE/install-args"
    elif [[ "$*" == *"pip --isolated check"* ]]; then touch "$BP_BASE/pip-checked"
    else return 99; fi
}
export -f bp_mock_python
BP_PYTHON=bp_mock_python
bp_metadata() { return 0; }
bp_source_ok() { return 0; }
BASIC_PITCH_INSTALL_RUNTIME=1 bp_install_package
grep -Fq -- '--constraint' "$BP_BASE/install-args"
test -e "$BP_BASE/pip-checked"
test "$(cat "$BP_MARKER")" = "$BP_COMMIT runtime"
test -z "$(find "$BP_BASE" -name 'runtime_constraints_*' -print)"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_runtime_pip_check_failure_never_registers_success(self):
        r = self.shell(r'''
mkdir -p "$BP_BASE" "$BP_VENV/bin"
echo old > "$BP_MARKER"
export BP_VENV
bp_mock_python() {
    if [[ "$*" == *"pip --isolated check"* ]]; then return 42; fi
    return 0
}
export -f bp_mock_python
printf '#!/usr/bin/env bash\nbp_mock_python "$@"\n' > "$BP_VENV/bin/python"
chmod +x "$BP_VENV/bin/python"
BP_PYTHON=bp_mock_python
bp_metadata() { return 0; }
bp_source_ok() { return 0; }
if BASIC_PITCH_INSTALL_RUNTIME=1 bp_install_package; then exit 99; fi
test ! -e "$BP_MARKER"
test -z "$(find "$BP_BASE" -name 'runtime_constraints_*' -print)"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_runtime_rejects_python_312_before_writes(self):
        r = self.shell('''
bp_mock_python() {
    if [[ "$*" == *"< (3,12)"* ]]; then return 1; fi
    return 0
}
BP_PYTHON=bp_mock_python
uname() { echo x86_64; }
if BASIC_PITCH_INSTALL_RUNTIME=1 bp_preflight; then exit 99; fi
test ! -e "$BP_BASE"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_native_dependency_wheels_and_no_false_menu_success(self):
        helper = (ROOT / HELPER).read_text(encoding="utf-8")
        self.assertIn("--only-binary=numpy,scipy,numba,llvmlite,tensorflow,tflite-runtime", helper)
        self.assertIn("numpy==1.26.4", helper)
        self.assertIn("librosa==0.10.2.post1", helper)
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        branch = menu.split('elif [ "$TOOL_KEY" = "Basic_Pitch" ]')[1].split('elif ')[0]
        self.assertNotIn("append_unique_line", branch)


if __name__ == "__main__":
    unittest.main()
