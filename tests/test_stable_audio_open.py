"""Offline Stable_Audio_Open tests: no SDK imports, real installation, credentials, APIs or WSL."""
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
HELPER = "scripts/tools/helpers/stable_audio_open_common.sh"


def sp(path):
    value = str(path).replace("\\", "/")
    return "/" + value[0].lower() + value[2:] if os.name == "nt" else value


class Contract(unittest.TestCase):
    def test_source_contract(self):
        tool, = [t for t in json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"] if t["id"] == "stable_audio_open"]
        self.assertEqual(tool["version"], "0.0.20")
        self.assertEqual(tool["status"], "experimental")
        self.assertEqual(tool["install_mode"], "source")
        self.assertFalse(tool["auto_install"])
        self.assertEqual(tool["ports"], [])
        text = (ROOT / HELPER).read_text(encoding="utf-8")
        self.assertIn("SA_COMMIT=" + tool["source_commit"], text)
        self.assertIn('distribution("stable-audio-tools")', text)
        self.assertIn('assert (3,10) <= sys.version_info < (3,11)', text)
        self.assertIn('SA_PYTHON="${STABLE_AUDIO_OPEN_PYTHON_BIN:-python3.10}"', text)
        self.assertIn('"$SA_SOURCE/pyproject.toml"', text)
        for field in ("doc", "install_script", "update_script", "uninstall_script", "doctor_script"):
            self.assertTrue((ROOT / tool[field]).is_file(), field)
        for required in ("SA_VERSION=0.0.20", "--no-deps",
                         '"$SA_SOURCE"', "flock -n 9", "require_ram_mb 1024",
                         "require_disk_mb 2048", "-ge 512", "direct_url.json",
                         "sys.prefix != sys.base_prefix", "unset HF_TOKEN HUGGING_FACE_HUB_TOKEN"):
            self.assertIn(required, text)
        for forbidden in ("import stable_audio_open", "generate_videos(", "files.upload(",
                          "docker compose", "rm -rf", "[dev]", "af_prepare_venv",
                          "run_apt_with_lock_wait", "gcloud auth", "Client(", "reag_text"):
            self.assertNotIn(forbidden, text)

    def test_menu_doc_links(self):
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('TOOL_SCRIPT_NAMES["Stable_Audio_Open"]="stable_audio_open"', menu)
        doc = ROOT / "docs/tools/stable-audio-open.md"
        for link in re.findall(r"\]\(([^)]+)\)", doc.read_text(encoding="utf-8")):
            if "://" not in link and not link.startswith("#"):
                self.assertTrue((doc.parent / link.split("#")[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), "bash unavailable")
class Offline(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as tmp:
            prefix = f"""
export OPENCLAW_USER_DATA_DIR='{sp(Path(tmp) / "private")}'
export STABLE_AUDIO_OPEN_PYTHON_BIN='{sp(Path(sys.executable))}'
source {HELPER}
sa_paths
"""
            return subprocess.run([str(BASH), "--noprofile", "--norc", "-c", prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=90)

    def test_dry_run_no_files(self):
        r = self.shell("""
git() { exit 99; }; python3() { exit 99; }; sudo() { exit 99; }
stable_audio_open_main --dry-run
test ! -e "$SA_BASE"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_explicit_bad_python_is_not_replaced(self):
        r = self.shell('''
SA_PYTHON=missing_python310
build_private_cpython310() { exit 99; }
sa_select_python
''')
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_compatible_interpreter_reused(self):
        r = self.shell('''
unset STABLE_AUDIO_OPEN_PYTHON_BIN
private_cpython310_ok() { [[ "$1" == python3.10 ]]; }
command() { [[ "$1" == -v ]] && return 0; builtin command "$@"; }
build_private_cpython310() { exit 99; }
sa_select_python
[[ "$SA_PYTHON" == python3.10 ]]
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_python_build_disabled_and_noninteractive_default(self):
        for policy in ('0', 'ask'):
            r = self.shell('''
unset STABLE_AUDIO_OPEN_PYTHON_BIN
private_cpython310_ok() { return 1; }
sa_python_build_resources() { exit 99; }
build_private_cpython310() { exit 99; }
STABLE_AUDIO_OPEN_BUILD_PYTHON=''' + policy + ''' sa_select_python </dev/null
''')
            self.assertEqual(r.returncode, 1, r.stderr)

    def test_authorized_build_passes_selected_path(self):
        r = self.shell('''
unset STABLE_AUDIO_OPEN_PYTHON_BIN
private_cpython310_ok() { [[ "$1" == "$SA_BASE/runtime/test-python" ]]; }
sa_python_build_resources() { return 0; }
build_private_cpython310() { printf '%s\\n' "$SA_BASE/runtime/test-python"; }
STABLE_AUDIO_OPEN_BUILD_PYTHON=1 sa_select_python
[[ "$SA_PYTHON" == "$SA_BASE/runtime/test-python" ]]
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_low_resources_prevent_python_download(self):
        r = self.shell('''
unset STABLE_AUDIO_OPEN_PYTHON_BIN
private_cpython310_ok() { return 1; }
sa_python_build_resources() { return 1; }
build_private_cpython310() { exit 99; }
STABLE_AUDIO_OPEN_BUILD_PYTHON=1 sa_select_python
''')
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_python_clone_failure_propagates_without_build(self):
        r = self.shell('''
private_cpython310_base_deps() { return 0; }
git() { return 42; }
make() { exit 99; }
build_private_cpython310 "$SA_BASE"
''')
        self.assertEqual(r.returncode, 42, r.stderr)

    def test_existing_incomplete_python_not_overwritten(self):
        r = self.shell('''
mkdir -p "$SA_BASE/runtime/python-3.10.22"
private_cpython310_base_deps() { exit 99; }
build_private_cpython310 "$SA_BASE"
''')
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_status_missing(self):
        r = self.shell('stable_audio_open_main status; test ! -e "$SA_BASE"')
        self.assertEqual(r.returncode, 0, r.stderr)
        state = json.loads(r.stdout)
        self.assertFalse(state["installed"])
        self.assertFalse(state["runtime_dependencies"])
        self.assertFalse(state["inference_tested"])

    def test_api_actions_rejected(self):
        for action, expected in (("doctor", 1), ("login", 2), ("upload", 2), ("subscribe", 2)):
            self.assertEqual(self.shell("stable_audio_open_main " + action).returncode, expected)

    def test_bad_root(self):
        for path in ("/", "$SA_ROOT/private", "$HOME/../other"):
            r = self.shell('OPENCLAW_USER_DATA_DIR="' + path + '" stable_audio_open_main --dry-run')
            self.assertNotEqual(r.returncode, 0)

    def test_foreign_source_preserved(self):
        r = self.shell("""
mkdir -p "$SA_SOURCE"
echo keep > "$SA_SOURCE/own-file"
if sa_fetch; then exit 99; fi
test "$(cat "$SA_SOURCE/own-file")" = keep
test ! -e "$SA_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_missing_sdk_layout_rejected(self):
        r = self.shell("""
mkdir -p "$SA_SOURCE"
touch "$SA_SOURCE/pyproject.toml"
sa_source_ok() { return 0; }
if sa_fetch; then exit 99; fi
test ! -e "$SA_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_expected_subdirectory_accepted(self):
        r = self.shell("""
mkdir -p "$SA_SOURCE/stable_audio_tools"
touch "$SA_SOURCE/pyproject.toml" "$SA_SOURCE/stable_audio_tools/__init__.py" "$SA_SOURCE/LICENSE"
sa_source_ok() { return 0; }
sa_fetch
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_foreign_venv_rejected(self):
        r = self.shell("""
mkdir -p "$SA_VENV"
uname() { echo x86_64; }
sa_python310() { return 0; }
SA_PYTHON=sa_python310
sa_preflight
""")
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_system_site_packages_rejected(self):
        r = self.shell("""
mkdir -p "$SA_VENV"
echo 'include-system-site-packages = true' > "$SA_VENV/pyvenv.cfg"
uname() { echo x86_64; }
BASE_PYTHON="$SA_PYTHON"
sa_python310() {
    if [[ "$*" == *'-c import sys;'* ]]; then return 0; fi
    "$BASE_PYTHON" "$@"
}
SA_PYTHON=sa_python310
sa_preflight
""")
        self.assertNotEqual(r.returncode, 0)

    def test_python_310_preflight_accepted(self):
        r = self.shell('''
uname() { echo x86_64; }
sa_python310() { return 0; }
SA_PYTHON=sa_python310
sa_preflight
test ! -e "$SA_BASE"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_incompatible_python_blocks_before_venv(self):
        r = self.shell('''
uname() { echo x86_64; }
sa_wrong_python() { return 42; }
SA_PYTHON=sa_wrong_python
if sa_preflight; then exit 99; fi
test ! -e "$SA_BASE"
''')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("Python 3.10 erforderlich", r.stderr)

    def test_key_environment_not_inherited(self):
        r = self.shell("""
export HF_TOKEN=SYNTHETIC_TEST_ONLY TEST_UNRELATED_KEY=SYNTHETIC_TEST_ONLY HUGGING_FACE_HUB_TOKEN=SYNTHETIC_TEST_ONLY
# A substitute probe checks only variable absence, never prints them.
sa_probe() { [[ ! -v HF_TOKEN && ! -v HUGGING_FACE_HUB_TOKEN && "$HF_HUB_OFFLINE" == 1 ]]; }
stable_audio_open_main status
test "$HF_TOKEN" = SYNTHETIC_TEST_ONLY
""")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue(json.loads(r.stdout)["installed"])
        self.assertNotIn("SYNTHETIC", r.stdout)

    def test_mock_package_build_targets_client_only(self):
        r = self.shell(r'''
mkdir -p "$SA_BASE"
export SA_BASE SA_VENV
sa_mock_python() {
    if [[ "$*" == *"-m venv"* ]]; then
        mkdir -p "$SA_VENV/bin"
        printf '#!/usr/bin/env bash\nsa_mock_python "$@"\n' > "$SA_VENV/bin/python"
        chmod +x "$SA_VENV/bin/python"
    elif [[ "$*" == *"pip --isolated install"* ]]; then
                printf '%s\n' "$*" > "$SA_BASE/install-args"
    elif [[ "$*" == *"pip --isolated check"* ]]; then
        touch "$SA_BASE/pip-checked"
    else return 99
    fi
}
export -f sa_mock_python
SA_PYTHON=sa_mock_python
sa_metadata() { test -f "$SA_BASE/install-args"; }
sa_source_ok() { return 0; }
sa_install_package
grep -Fq -- "--no-deps $SA_SOURCE" "$SA_BASE/install-args"
test "$(cat "$SA_MARKER")" = "$SA_COMMIT base"
test ! -e "$SA_BASE/pip-checked"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_failed_package_build_clears_marker(self):
        r = self.shell(r'''
mkdir -p "$SA_BASE"
echo old > "$SA_MARKER"
sa_mock_python() { return 42; }
SA_PYTHON=sa_mock_python
set +e
(set -e; sa_install_package)
rc=$?
test "$rc" = 42 && test ! -e "$SA_MARKER"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_deactivation_keeps_data(self):
        r = self.shell("""
mkdir -p "$SA_SOURCE" "$SA_VENV"
touch "$SA_MARKER" "$SA_SOURCE/own-file" "$SA_VENV/own-file"
sa_deactivate
test ! -e "$SA_MARKER" && test -f "$SA_SOURCE/own-file" && test -f "$SA_VENV/own-file"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_legacy_runtime_rejected_before_tools(self):
        r = self.shell("STABLE_AUDIO_OPEN_INSTALL_RUNTIME=1 stable_audio_open_main install")
        self.assertEqual(r.returncode, 2, r.stderr)
        self.assertIn("GPU-Runtime", r.stderr)

    def test_low_total_ram_blocks_even_in_conditional(self):
        r = self.shell('''
mkdir -p "$SA_BASE"
source() { return 0; }
require_ram_mb() { return 1; }
require_disk_mb() { touch "$SA_BASE/disk-reached"; }
if sa_resources; then exit 99; fi
test ! -e "$SA_BASE/disk-reached"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_safety_documentation(self):
        doc = (ROOT / "docs/tools/stable-audio-open.md").read_text(encoding="utf-8")
        for warning in ("Modelllizenz", "MIT", "2.7.1", "3.10", "3.12", "--no-deps"):
            self.assertIn(warning, doc)


if __name__ == "__main__":
    unittest.main()
