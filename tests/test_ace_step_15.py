"""Offline ACE_Step_15 tests: no SDK imports, real installation, credentials, APIs or WSL."""
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
HELPER = "scripts/tools/helpers/ace_step_15_common.sh"


def sp(path):
    value = str(path).replace("\\", "/")
    return "/" + value[0].lower() + value[2:] if os.name == "nt" else value


class Contract(unittest.TestCase):
    def test_source_contract(self):
        tool, = [t for t in json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"] if t["id"] == "ace_step_15"]
        self.assertEqual(tool["version"], "1.5.0")
        self.assertEqual(tool["status"], "experimental")
        self.assertEqual(tool["install_mode"], "source")
        self.assertFalse(tool["auto_install"])
        self.assertEqual(tool["ports"], [])
        text = (ROOT / HELPER).read_text(encoding="utf-8")
        self.assertIn("AC_COMMIT=" + tool["source_commit"], text)
        self.assertIn('distribution("ace-step")', text)
        self.assertIn('assert (3,11) <= sys.version_info < (3,13)', text)
        self.assertIn('--filter=blob:none', text)
        self.assertIn('/.gitignore', text)
        for field in ("doc", "install_script", "update_script", "uninstall_script", "doctor_script"):
            self.assertTrue((ROOT / tool[field]).is_file(), field)
        for required in ("AC_VERSION=1.5.0", "--no-deps",
                         '"$AC_SOURCE"', "flock -n 9", "require_ram_mb 1024",
                         "require_disk_mb 2048", "-ge 512", "direct_url.json",
                         "sys.prefix != sys.base_prefix", "unset HF_TOKEN HUGGING_FACE_HUB_TOKEN"):
            self.assertIn(required, text)
        for forbidden in ("import ace_step_15", "generate_videos(", "files.upload(",
                          "docker compose", "rm -rf", "[dev]", "af_prepare_venv",
                          "run_apt_with_lock_wait", "gcloud auth", "Client(", "reac_text"):
            self.assertNotIn(forbidden, text)

    def test_menu_doc_links(self):
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('TOOL_SCRIPT_NAMES["ACE_Step_15"]="ace_step_15"', menu)
        doc = ROOT / "docs/tools/ace-step-15.md"
        for link in re.findall(r"\]\(([^)]+)\)", doc.read_text(encoding="utf-8")):
            if "://" not in link and not link.startswith("#"):
                self.assertTrue((doc.parent / link.split("#")[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), "bash unavailable")
class Offline(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as tmp:
            prefix = f"""
export OPENCLAW_USER_DATA_DIR='{sp(Path(tmp) / "private")}'
export ACE_STEP_15_PYTHON_BIN='{sp(Path(sys.executable))}'
source {HELPER}
ac_paths
"""
            return subprocess.run([str(BASH), "--noprofile", "--norc", "-c", prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=90)

    def test_dry_run_no_files(self):
        r = self.shell("""
git() { exit 99; }; python3() { exit 99; }; sudo() { exit 99; }
ace_step_15_main --dry-run
test ! -e "$AC_BASE"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_status_missing(self):
        r = self.shell('ace_step_15_main status; test ! -e "$AC_BASE"')
        self.assertEqual(r.returncode, 0, r.stderr)
        state = json.loads(r.stdout)
        self.assertFalse(state["installed"])
        self.assertFalse(state["runtime_dependencies"])
        self.assertFalse(state["inference_tested"])

    def test_api_actions_rejected(self):
        for action, expected in (("doctor", 1), ("login", 2), ("upload", 2), ("subscribe", 2)):
            self.assertEqual(self.shell("ace_step_15_main " + action).returncode, expected)

    def test_bad_root(self):
        for path in ("/", "$AC_ROOT/private", "$HOME/../other"):
            r = self.shell('OPENCLAW_USER_DATA_DIR="' + path + '" ace_step_15_main --dry-run')
            self.assertNotEqual(r.returncode, 0)

    def test_foreign_source_preserved(self):
        r = self.shell("""
mkdir -p "$AC_SOURCE"
echo keep > "$AC_SOURCE/own-file"
if ac_fetch; then exit 99; fi
test "$(cat "$AC_SOURCE/own-file")" = keep
test ! -e "$AC_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_missing_sdk_layout_rejected(self):
        r = self.shell("""
mkdir -p "$AC_SOURCE"
touch "$AC_SOURCE/pyproject.toml"
ac_source_ok() { return 0; }
if ac_fetch; then exit 99; fi
test ! -e "$AC_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_expected_subdirectory_accepted(self):
        r = self.shell("""
mkdir -p "$AC_SOURCE/acestep/ui/gradio/interfaces" "$AC_SOURCE/openrouter"
touch "$AC_SOURCE/openrouter/__init__.py" "$AC_SOURCE/acestep/ui/gradio/interfaces/audio_player_preferences.js" "$AC_SOURCE/acestep/ui/gradio/interfaces/user_preferences.js"
touch "$AC_SOURCE/pyproject.toml" "$AC_SOURCE/acestep/__init__.py" "$AC_SOURCE/LICENSE"
ac_source_ok() { return 0; }
ac_fetch
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_foreign_venv_rejected(self):
        r = self.shell("""
mkdir -p "$AC_VENV"
uname() { echo x86_64; }
ac_preflight
""")
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_system_site_packages_rejected(self):
        r = self.shell("""
mkdir -p "$AC_VENV"
echo 'include-system-site-packages = true' > "$AC_VENV/pyvenv.cfg"
uname() { echo x86_64; }
ac_preflight
""")
        self.assertNotEqual(r.returncode, 0)

    def test_key_environment_not_inherited(self):
        r = self.shell("""
export HF_TOKEN=SYNTHETIC_TEST_ONLY TEST_UNRELATED_KEY=SYNTHETIC_TEST_ONLY HUGGING_FACE_HUB_TOKEN=SYNTHETIC_TEST_ONLY
# A substitute probe checks only variable absence, never prints them.
ac_probe() { [[ ! -v HF_TOKEN && ! -v HUGGING_FACE_HUB_TOKEN && "$HF_HUB_OFFLINE" == 1 ]]; }
ace_step_15_main status
test "$HF_TOKEN" = SYNTHETIC_TEST_ONLY
""")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue(json.loads(r.stdout)["installed"])
        self.assertNotIn("SYNTHETIC", r.stdout)

    def test_mock_package_build_targets_client_only(self):
        r = self.shell(r'''
mkdir -p "$AC_BASE"
export AC_BASE AC_VENV
ac_mock_python() {
    if [[ "$*" == *"-m venv"* ]]; then
        mkdir -p "$AC_VENV/bin"
        printf '#!/usr/bin/env bash\nac_mock_python "$@"\n' > "$AC_VENV/bin/python"
        chmod +x "$AC_VENV/bin/python"
    elif [[ "$*" == *"pip --isolated install"* ]]; then
                printf '%s\n' "$*" > "$AC_BASE/install-args"
    elif [[ "$*" == *"pip --isolated check"* ]]; then
        touch "$AC_BASE/pip-checked"
    else return 99
    fi
}
export -f ac_mock_python
AC_PYTHON=ac_mock_python
ac_metadata() { test -f "$AC_BASE/install-args"; }
ac_source_ok() { return 0; }
ac_install_package
grep -Fq -- "--no-deps $AC_SOURCE" "$AC_BASE/install-args"
test "$(cat "$AC_MARKER")" = "$AC_COMMIT base"
test ! -e "$AC_BASE/pip-checked"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_failed_package_build_clears_marker(self):
        r = self.shell(r'''
mkdir -p "$AC_BASE"
echo old > "$AC_MARKER"
ac_mock_python() { return 42; }
AC_PYTHON=ac_mock_python
set +e
(set -e; ac_install_package)
rc=$?
test "$rc" = 1 && test ! -e "$AC_MARKER"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_deactivation_keeps_data(self):
        r = self.shell("""
mkdir -p "$AC_SOURCE" "$AC_VENV"
touch "$AC_MARKER" "$AC_SOURCE/own-file" "$AC_VENV/own-file"
ac_deactivate
test ! -e "$AC_MARKER" && test -f "$AC_SOURCE/own-file" && test -f "$AC_VENV/own-file"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_legacy_runtime_rejected_before_tools(self):
        r = self.shell("ACE_STEP_15_INSTALL_RUNTIME=1 ace_step_15_main install")
        self.assertEqual(r.returncode, 2, r.stderr)
        self.assertIn("GPU-Runtime", r.stderr)

    def test_low_total_ram_blocks_even_in_conditional(self):
        r = self.shell('''
mkdir -p "$AC_BASE"
source() { return 0; }
require_ram_mb() { return 1; }
require_disk_mb() { touch "$AC_BASE/disk-reached"; }
if ac_resources; then exit 99; fi
test ! -e "$AC_BASE/disk-reached"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_safety_documentation(self):
        doc = (ROOT / "docs/tools/ace-step-15.md").read_text(encoding="utf-8")
        for warning in ("MIT", "nano-vllm", "cu128", "3.12", "--no-deps"):
            self.assertIn(warning, doc)

    def test_sparse_checkout_keeps_package_excludes_models_media_env(self):
        r = self.shell(r'''
mkdir -p "$AC_SOURCE/acestep/ui/gradio/interfaces" "$AC_SOURCE/openrouter" "$AC_SOURCE/demo_data" "$AC_SOURCE/webpage" "$AC_SOURCE/models"
git -c init.defaultBranch=main init "$AC_SOURCE"
printf '*.egg-info/\nbuild/\n.env\n' > "$AC_SOURCE/.gitignore"
touch "$AC_SOURCE/pyproject.toml" "$AC_SOURCE/LICENSE" "$AC_SOURCE/README.md" "$AC_SOURCE/acestep/__init__.py" "$AC_SOURCE/openrouter/__init__.py" "$AC_SOURCE/acestep/ui/gradio/interfaces/audio_player_preferences.js" "$AC_SOURCE/acestep/ui/gradio/interfaces/user_preferences.js"
touch "$AC_SOURCE/demo_data/video.mp4" "$AC_SOURCE/webpage/index.html" "$AC_SOURCE/models/weights.safetensors" "$AC_SOURCE/acestep/example.png"
git -C "$AC_SOURCE" add .
git -c core.hooksPath=/dev/null -c commit.gpgsign=false -c user.name=Fixture -c user.email=fixture@example.org -C "$AC_SOURCE" commit -m fixture
ac_sparse_checkout
test -f "$AC_SOURCE/openrouter/__init__.py" && test -f "$AC_SOURCE/acestep/ui/gradio/interfaces/audio_player_preferences.js"
test -f "$AC_SOURCE/acestep/__init__.py" && test -f "$AC_SOURCE/pyproject.toml" && test -f "$AC_SOURCE/.gitignore"
test ! -e "$AC_SOURCE/demo_data/video.mp4" && test ! -e "$AC_SOURCE/models/weights.safetensors"
test ! -e "$AC_SOURCE/acestep/example.png" && test ! -e "$AC_SOURCE/webpage/index.html"
mkdir -p "$AC_SOURCE/acestep.egg-info"
touch "$AC_SOURCE/acestep.egg-info/PKG-INFO"
test -z "$(git -C "$AC_SOURCE" status --porcelain)"
''')
        self.assertEqual(r.returncode, 0, r.stderr)


if __name__ == "__main__":
    unittest.main()
