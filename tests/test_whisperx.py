"""Offline WhisperX tests: no SDK imports, real installation, credentials, APIs or WSL."""
import json
import contextlib
import io
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
BASH = "C:/Program Files/Git/bin/bash.exe" if os.name == "nt" else shutil.which("bash")
HELPER = "scripts/tools/helpers/whisperx_common.sh"


def sp(path):
    value = str(path).replace("\\", "/")
    return "/" + value[0].lower() + value[2:] if os.name == "nt" else value


class Contract(unittest.TestCase):
    def test_torch_metadata_accepts_matching_stack_rejects_mixed_variants(self):
        helper = (ROOT / HELPER).read_text(encoding="utf-8")
        code = helper.split("wx_torch_constraints() {", 1)[1].split("<<'PY'", 1)[1].split("\nPY", 1)[0]
        for torch, audio, vision, valid in (
            ("2.8.0+cpu", "2.8.0+cpu", "0.23.0+cpu", True),
            ("2.8.0+cu128", "2.8.0+cu128", "0.23.0+cu128", True),
            ("2.8.0", "2.8.0", "0.23.0", True),
            ("2.8.0+cpu", "2.8.0+cu128", "0.23.0+cpu", False),
            ("2.8.0+cpu", "2.8.0+cpu", "0.23.0+cu128", False),
            ("2.7.0+cpu", "2.7.0+cpu", "0.22.0+cpu", False),
            ("2.8.0+cpu", "2.8.1+cpu", "0.23.0+cpu", False),
        ):
            values = dict(torch=torch, torchaudio=audio, torchvision=vision)
            with self.subTest(values=values), mock.patch("importlib.metadata.version", side_effect=values.__getitem__), mock.patch.object(sys, "prefix", str(ROOT)), mock.patch.object(sys, "argv", ["fixture", str(ROOT)]), contextlib.redirect_stdout(io.StringIO()):
                if valid:
                    exec(code, {})
                else:
                    with self.assertRaises(AssertionError):
                        exec(code, {})

    def test_source_contract(self):
        tool, = [t for t in json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"] if t["id"] == "whisperx"]
        self.assertEqual(tool["version"], "3.8.6")
        self.assertEqual(tool["status"], "experimental")
        self.assertEqual(tool["install_mode"], "source")
        self.assertFalse(tool["auto_install"])
        self.assertEqual(tool["ports"], [])
        text = (ROOT / HELPER).read_text(encoding="utf-8")
        self.assertIn("WX_COMMIT=" + tool["source_commit"], text)
        self.assertIn('distribution("whisperx")', text)
        self.assertIn('assert (3,10) <= sys.version_info < (3,14)', text)
        for field in ("doc", "install_script", "update_script", "uninstall_script", "doctor_script"):
            self.assertTrue((ROOT / tool[field]).is_file(), field)
        for required in ("WX_VERSION=3.8.6", "--no-deps",
                         '"$WX_SOURCE"', "flock -n 9", "require_ram_mb 1024",
                         "require_disk_mb 2048", "-ge 512", "direct_url.json",
                         "sys.prefix != sys.base_prefix", "unset HF_TOKEN HUGGING_FACE_HUB_TOKEN"):
            self.assertIn(required, text)
        for forbidden in ("import whisperx", "generate_videos(", "files.upload(",
                          "docker compose", "rm -rf", "[dev]", "af_prepare_venv",
                          "run_apt_with_lock_wait", "gcloud auth", "Client(", "rewx_text"):
            self.assertNotIn(forbidden, text)

    def test_menu_doc_links(self):
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('TOOL_SCRIPT_NAMES["WhisperX"]="whisperx"', menu)
        doc = ROOT / "docs/tools/whisperx.md"
        for link in re.findall(r"\]\(([^)]+)\)", doc.read_text(encoding="utf-8")):
            if "://" not in link and not link.startswith("#"):
                self.assertTrue((doc.parent / link.split("#")[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), "bash unavailable")
class Offline(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as tmp:
            prefix = f"""
export OPENCLAW_USER_DATA_DIR='{sp(Path(tmp) / "private")}'
export WHISPERX_PYTHON_BIN='{sp(Path(sys.executable))}'
source {HELPER}
wx_paths
"""
            return subprocess.run([str(BASH), "--noprofile", "--norc", "-c", prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=90)

    def test_dry_run_no_files(self):
        r = self.shell("""
git() { exit 99; }; python3() { exit 99; }; sudo() { exit 99; }
whisperx_main --dry-run
test ! -e "$WX_BASE"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_status_missing(self):
        r = self.shell('whisperx_main status; test ! -e "$WX_BASE"')
        self.assertEqual(r.returncode, 0, r.stderr)
        state = json.loads(r.stdout)
        self.assertFalse(state["installed"])
        self.assertFalse(state["runtime_dependencies"])
        self.assertFalse(state["inference_tested"])

    def test_api_actions_rejected(self):
        for action, expected in (("doctor", 1), ("login", 2), ("upload", 2), ("subscribe", 2)):
            self.assertEqual(self.shell("whisperx_main " + action).returncode, expected)

    def test_bad_root(self):
        for path in ("/", "$WX_ROOT/private", "$HOME/../other"):
            r = self.shell('OPENCLAW_USER_DATA_DIR="' + path + '" whisperx_main --dry-run')
            self.assertNotEqual(r.returncode, 0)

    def test_foreign_source_preserved(self):
        r = self.shell("""
mkdir -p "$WX_SOURCE"
echo keep > "$WX_SOURCE/own-file"
if wx_fetch; then exit 99; fi
test "$(cat "$WX_SOURCE/own-file")" = keep
test ! -e "$WX_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_missing_sdk_layout_rejected(self):
        r = self.shell("""
mkdir -p "$WX_SOURCE"
touch "$WX_SOURCE/pyproject.toml"
wx_source_ok() { return 0; }
if wx_fetch; then exit 99; fi
test ! -e "$WX_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_expected_subdirectory_accepted(self):
        r = self.shell("""
mkdir -p "$WX_SOURCE/whisperx/assets"
touch "$WX_SOURCE/whisperx/assets/pytorch_model.bin"
touch "$WX_SOURCE/pyproject.toml" "$WX_SOURCE/whisperx/__init__.py" "$WX_SOURCE/LICENSE"
wx_source_ok() { return 0; }
wx_fetch
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_foreign_venv_rejected(self):
        r = self.shell("""
mkdir -p "$WX_VENV"
uname() { echo x86_64; }
wx_preflight
""")
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_system_site_packages_rejected(self):
        r = self.shell("""
mkdir -p "$WX_VENV"
echo 'include-system-site-packages = true' > "$WX_VENV/pyvenv.cfg"
uname() { echo x86_64; }
wx_preflight
""")
        self.assertNotEqual(r.returncode, 0)

    def test_key_environment_not_inherited(self):
        r = self.shell("""
export HF_TOKEN=SYNTHETIC_TEST_ONLY TEST_UNRELATED_KEY=SYNTHETIC_TEST_ONLY HUGGING_FACE_HUB_TOKEN=SYNTHETIC_TEST_ONLY
mkdir -p "$WX_BASE"
echo "$WX_COMMIT base" > "$WX_MARKER"
# A substitute probe checks only variable absence, never prints them.
wx_probe() { [[ ! -v HF_TOKEN && ! -v HUGGING_FACE_HUB_TOKEN && "$HF_HUB_OFFLINE" == 1 ]]; }
whisperx_main status
test "$HF_TOKEN" = SYNTHETIC_TEST_ONLY
""")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue(json.loads(r.stdout)["installed"])
        self.assertNotIn("SYNTHETIC", r.stdout)

    def test_mock_package_build_targets_client_only(self):
        r = self.shell(r'''
mkdir -p "$WX_BASE"
export WX_BASE WX_VENV
wx_mock_python() {
    if [[ "$*" == *"-m venv"* ]]; then
        mkdir -p "$WX_VENV/bin"
        printf '#!/usr/bin/env bash\nwx_mock_python "$@"\n' > "$WX_VENV/bin/python"
        chmod +x "$WX_VENV/bin/python"
    elif [[ "$*" == *"pip --isolated install"* ]]; then
                printf '%s\n' "$*" > "$WX_BASE/install-args"
    elif [[ "$*" == *"pip --isolated check"* ]]; then
        touch "$WX_BASE/pip-checked"
    else return 99
    fi
}
export -f wx_mock_python
WX_PYTHON=wx_mock_python
wx_metadata() { test -f "$WX_BASE/install-args"; }
wx_source_ok() { return 0; }
wx_install_package
grep -Fq -- "--no-deps $WX_SOURCE" "$WX_BASE/install-args"
test "$(cat "$WX_MARKER")" = "$WX_COMMIT base"
test ! -e "$WX_BASE/pip-checked"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_failed_package_build_clears_marker(self):
        r = self.shell(r'''
mkdir -p "$WX_BASE"
echo old > "$WX_MARKER"
wx_mock_python() { return 42; }
WX_PYTHON=wx_mock_python
set +e
(set -e; wx_install_package)
rc=$?
test "$rc" = 1 && test ! -e "$WX_MARKER"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_deactivation_keeps_data(self):
        r = self.shell("""
mkdir -p "$WX_SOURCE" "$WX_VENV"
touch "$WX_MARKER" "$WX_SOURCE/own-file" "$WX_VENV/own-file"
wx_deactivate
test ! -e "$WX_MARKER" && test -f "$WX_SOURCE/own-file" && test -f "$WX_VENV/own-file"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_legacy_runtime_rejected_before_tools(self):
        r = self.shell("WHISPERX_INSTALL_RUNTIME=1 whisperx_main install")
        self.assertEqual(r.returncode, 2, r.stderr)
        self.assertIn("INSTALL_HEAVY_TOOLS", r.stderr)

    def test_low_total_ram_blocks_even_in_conditional(self):
        r = self.shell('''
mkdir -p "$WX_BASE"
source() { return 0; }
require_ram_mb() { return 1; }
require_disk_mb() { touch "$WX_BASE/disk-reached"; }
if wx_resources; then exit 99; fi
test ! -e "$WX_BASE/disk-reached"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_safety_documentation(self):
        doc = (ROOT / "docs/tools/whisperx.md").read_text(encoding="utf-8")
        for warning in ("BSD-2-Clause", "PyTorch", "3.12", "--no-deps"):
            self.assertIn(warning, doc)

    def test_runtime_package_mocked_with_constraints_and_pip_check(self):
        r = self.shell(r'''
mkdir -p "$WX_BASE"
export WX_BASE WX_VENV
wx_mock_python() {
    if [[ "$*" == *"-m venv"* ]]; then
        mkdir -p "$WX_VENV/bin"
        printf '#!/usr/bin/env bash\nwx_mock_python "$@"\n' > "$WX_VENV/bin/python"
        chmod +x "$WX_VENV/bin/python"
    elif [[ "$*" == *"pip --isolated install"* ]]; then
        printf '%s\n' "$*" > "$WX_BASE/install-args"
    elif [[ "$*" == *"pip --isolated check"* ]]; then touch "$WX_BASE/pip-checked"
    else return 99; fi
}
export -f wx_mock_python
WX_PYTHON=wx_mock_python
wx_metadata() { return 0; }
wx_source_ok() { return 0; }
wx_torch_constraints() { echo "torch==2.8.0+cpu"; }
WHISPERX_INSTALL_RUNTIME=1 wx_install_package
grep -Fq -- '--constraint' "$WX_BASE/install-args"
test -e "$WX_BASE/pip-checked"
test "$(cat "$WX_MARKER")" = "$WX_COMMIT runtime"
test -z "$(find "$WX_BASE" -name 'runtime_constraints_*' -print)"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_runtime_pip_check_failure_never_registers_success(self):
        r = self.shell(r'''
mkdir -p "$WX_BASE" "$WX_VENV/bin"
echo old > "$WX_MARKER"
export WX_VENV
wx_mock_python() {
    if [[ "$*" == *"pip --isolated check"* ]]; then return 42; fi
    return 0
}
export -f wx_mock_python
printf '#!/usr/bin/env bash\nwx_mock_python "$@"\n' > "$WX_VENV/bin/python"
chmod +x "$WX_VENV/bin/python"
WX_PYTHON=wx_mock_python
wx_metadata() { return 0; }
wx_source_ok() { return 0; }
wx_torch_constraints() { echo "torch==2.8.0+cpu"; }
if WHISPERX_INSTALL_RUNTIME=1 wx_install_package; then exit 99; fi
test ! -e "$WX_MARKER"
test -z "$(find "$WX_BASE" -name 'runtime_constraints_*' -print)"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_runtime_rejects_missing_torch_before_writes(self):
        r = self.shell('''
wx_mock_python() { return 0; }
WX_PYTHON=wx_mock_python
uname() { echo x86_64; }
ffmpeg() { :; }
if WHISPERX_INSTALL_RUNTIME=1 wx_preflight; then exit 99; fi
test ! -e "$WX_BASE"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_native_dependency_wheels_and_no_false_menu_success(self):
        helper = (ROOT / HELPER).read_text(encoding="utf-8")
        self.assertIn("--only-binary=torch,torchaudio,torchvision,torchcodec,triton,ctranslate2,numpy,scipy,numba,llvmlite", helper)
        self.assertIn("numpy>=2.1,<3", helper)
        self.assertIn("transformers<5", helper)
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        branch = menu.split('elif [ "$TOOL_KEY" = "WhisperX" ]')[1].split('elif ')[0]
        self.assertNotIn("append_unique_line", branch)


if __name__ == "__main__":
    unittest.main()
