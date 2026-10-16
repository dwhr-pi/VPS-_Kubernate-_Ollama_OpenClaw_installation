"""Offline Qwen3 TTS tests: no SDK imports, real installation, credentials, APIs or WSL."""
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
HELPER = "scripts/tools/helpers/qwen3_tts_common.sh"


def sp(path):
    value = str(path).replace("\\", "/")
    return "/" + value[0].lower() + value[2:] if os.name == "nt" else value


class Contract(unittest.TestCase):
    def test_source_contract(self):
        tool, = [t for t in json.loads((ROOT / "config/tools.yml").read_text())["tools"] if t["id"] == "qwen3_tts"]
        self.assertEqual(tool["version"], "0.1.1")
        self.assertEqual(tool["status"], "experimental")
        self.assertEqual(tool["install_mode"], "source")
        self.assertFalse(tool["auto_install"])
        self.assertEqual(tool["ports"], [])
        text = (ROOT / HELPER).read_text()
        self.assertIn("QT_COMMIT=" + tool["source_commit"], text)
        for field in ("doc", "install_script", "update_script", "uninstall_script", "doctor_script"):
            self.assertTrue((ROOT / tool[field]).is_file(), field)
        for required in ("QT_VERSION=0.1.1", "--no-deps",
                         '"$QT_SOURCE"', "flock -n 9", "require_ram_mb 1024",
                         "require_disk_mb 2048", "-ge 512", "direct_url.json",
                         "sys.prefix != sys.base_prefix", "INSTALL_HEAVY_TOOLS"):
            self.assertIn(required, text)
        for forbidden in ("import qwen_tts", "from_pretrained(", "import torch",
                          "docker compose", "rm -rf", "[dev]", "af_prepare_venv",
                          "run_apt_with_lock_wait", "gcloud auth", "Client("):
            self.assertNotIn(forbidden, text)

    def test_menu_doc_links(self):
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('TOOL_SCRIPT_NAMES["Qwen3_TTS"]="qwen3_tts"', menu)
        doc = ROOT / "docs/tools/qwen3-tts.md"
        for link in re.findall(r"\]\(([^)]+)\)", doc.read_text()):
            if "://" not in link and not link.startswith("#"):
                self.assertTrue((doc.parent / link.split("#")[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), "bash unavailable")
class Offline(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as tmp:
            prefix = f"""
export OPENCLAW_USER_DATA_DIR='{sp(Path(tmp) / "private")}'
export QWEN3_TTS_PYTHON_BIN='{sp(Path(sys.executable))}'
unset QWEN3_TTS_INSTALL_RUNTIME INSTALL_HEAVY_TOOLS
source {HELPER}
qt_paths
"""
            return subprocess.run([str(BASH), "--noprofile", "--norc", "-c", prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=90)

    def test_dry_run_no_files(self):
        r = self.shell("""
git() { exit 99; }; python3() { exit 99; }; sudo() { exit 99; }
qwen3_tts_main --dry-run
test ! -e "$QT_BASE"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_status_missing(self):
        r = self.shell('qwen3_tts_main status; test ! -e "$QT_BASE"')
        self.assertEqual(r.returncode, 0, r.stderr)
        state = json.loads(r.stdout)
        self.assertFalse(state["installed"])
        self.assertFalse(state["models_checked"])
        self.assertFalse(state["inference_tested"])

    def test_api_actions_rejected(self):
        for action, expected in (("doctor", 1), ("login", 2), ("upload", 2), ("subscribe", 2)):
            self.assertEqual(self.shell("qwen3_tts_main " + action).returncode, expected)

    def test_bad_root(self):
        for path in ("/", "$QT_ROOT/private", "$HOME/../other"):
            r = self.shell('OPENCLAW_USER_DATA_DIR="' + path + '" qwen3_tts_main --dry-run')
            self.assertNotEqual(r.returncode, 0)

    def test_foreign_source_preserved(self):
        r = self.shell("""
mkdir -p "$QT_SOURCE"
echo keep > "$QT_SOURCE/own-file"
if qt_fetch; then exit 99; fi
test "$(cat "$QT_SOURCE/own-file")" = keep
test ! -e "$QT_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_missing_sdk_layout_rejected(self):
        r = self.shell("""
mkdir -p "$QT_SOURCE"
touch "$QT_SOURCE/pyproject.toml"
qt_source_ok() { return 0; }
if qt_fetch; then exit 99; fi
test ! -e "$QT_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_expected_subdirectory_accepted(self):
        r = self.shell("""
mkdir -p "$QT_SOURCE/qwen_tts"
touch "$QT_SOURCE/pyproject.toml" "$QT_SOURCE/qwen_tts/__init__.py"
qt_source_ok() { return 0; }
qt_fetch
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_foreign_venv_rejected(self):
        r = self.shell("""
mkdir -p "$QT_VENV"
uname() { echo x86_64; }
qt_preflight
""")
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_system_site_packages_rejected(self):
        r = self.shell("""
mkdir -p "$QT_VENV"
echo 'include-system-site-packages = true' > "$QT_VENV/pyvenv.cfg"
uname() { echo x86_64; }
qt_preflight
""")
        self.assertNotEqual(r.returncode, 0)

    def test_key_environment_not_inherited(self):
        r = self.shell("""
export HF_TOKEN=SYNTHETIC_TEST_ONLY TEST_UNRELATED_KEY=SYNTHETIC_TEST_ONLY HUGGING_FACE_HUB_TOKEN=SYNTHETIC_TEST_ONLY
# A substitute probe checks only variable absence, never prints them.
qt_probe() { [[ ! -v HF_TOKEN && ! -v HUGGING_FACE_HUB_TOKEN && "$HF_HUB_OFFLINE" == 1 ]]; }
mkdir -p "$QT_BASE"
echo "$QT_COMMIT package" > "$QT_MARKER"
qwen3_tts_main status
test "$HF_TOKEN" = SYNTHETIC_TEST_ONLY
""")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue(json.loads(r.stdout)["installed"])
        self.assertNotIn("SYNTHETIC", r.stdout)

    def test_mock_package_build_targets_client_only(self):
        r = self.shell(r'''
mkdir -p "$QT_BASE"
export QT_BASE QT_VENV
qt_mock_python() {
    if [[ "$*" == *"-m venv"* ]]; then
        mkdir -p "$QT_VENV/bin"
        printf '#!/usr/bin/env bash\nqt_mock_python "$@"\n' > "$QT_VENV/bin/python"
        chmod +x "$QT_VENV/bin/python"
    elif [[ "$*" == *"pip --isolated install"* ]]; then
                printf '%s\n' "$*" > "$QT_BASE/install-args"
    elif [[ "$*" == *"pip --isolated check"* ]]; then
        touch "$QT_BASE/pip-checked"
    else return 99
    fi
}
export -f qt_mock_python
QT_PYTHON=qt_mock_python
qt_metadata() { test -f "$QT_BASE/install-args"; }
qt_source_ok() { return 0; }
qt_install_package
grep -Fq -- "--no-deps $QT_SOURCE" "$QT_BASE/install-args"
test "$(cat "$QT_MARKER")" = "$QT_COMMIT package"
test ! -e "$QT_BASE/pip-checked"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_failed_package_build_clears_marker(self):
        r = self.shell(r'''
mkdir -p "$QT_BASE"
echo old > "$QT_MARKER"
qt_mock_python() { return 42; }
QT_PYTHON=qt_mock_python
set +e
(set -e; qt_install_package)
rc=$?
test "$rc" = 42 && test ! -e "$QT_MARKER"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_deactivation_keeps_data(self):
        r = self.shell("""
mkdir -p "$QT_SOURCE" "$QT_VENV"
touch "$QT_MARKER" "$QT_SOURCE/own-file" "$QT_VENV/own-file"
qt_deactivate
test ! -e "$QT_MARKER" && test -f "$QT_SOURCE/own-file" && test -f "$QT_VENV/own-file"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_runtime_requires_heavy_opt_in(self):
        r = self.shell("INSTALL_HEAVY_TOOLS=0 qt_runtime_preflight")
        self.assertEqual(r.returncode, 2, r.stderr)
        self.assertIn("INSTALL_HEAVY_TOOLS", r.stderr)

    def test_runtime_requires_existing_torch(self):
        r = self.shell("INSTALL_HEAVY_TOOLS=1 qt_runtime_preflight")
        self.assertEqual(r.returncode, 1, r.stderr)
        self.assertIn("Torch", r.stderr)

    def test_runtime_constraints_are_passed_and_pip_checked(self):
        r = self.shell(r'''
mkdir -p "$QT_BASE"
export QT_BASE QT_VENV
qt_mock_python() {
    if [[ "$*" == *"-m venv"* ]]; then
        mkdir -p "$QT_VENV/bin"
        printf '#!/usr/bin/env bash\nqt_mock_python "$@"\n' > "$QT_VENV/bin/python"
        chmod +x "$QT_VENV/bin/python"
    elif [[ "$*" == *"pip --isolated install"* ]]; then
        printf '%s\n' "$*" > "$QT_BASE/install-args"
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
        touch "$QT_BASE/pip-checked"
    else return 97
    fi
}
export -f qt_mock_python
QT_PYTHON=qt_mock_python
QWEN3_TTS_INSTALL_RUNTIME=1
qt_torch_constraints() { printf 'torch==2.7.0+cpu\ntorchaudio==2.7.0+cpu\n'; }
qt_source_ok() { return 0; }
qt_metadata() { return 0; }
qt_install_package
test "$(cat "$QT_MARKER")" = "$QT_COMMIT runtime"
test -e "$QT_BASE/pip-checked"
grep -Fq -- '--only-binary=torch,torchaudio,onnxruntime,numpy,scipy' "$QT_BASE/install-args"
''')
        self.assertEqual(r.returncode, 0, r.stderr)


if __name__ == "__main__":
    unittest.main()
