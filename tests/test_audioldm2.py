"""Offline AudioLDM2 tests: no SDK imports, real installation, credentials, APIs or WSL."""
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
HELPER = "scripts/tools/helpers/audioldm2_common.sh"


def sp(path):
    value = str(path).replace("\\", "/")
    return "/" + value[0].lower() + value[2:] if os.name == "nt" else value


class Contract(unittest.TestCase):
    def test_source_contract(self):
        tool, = [t for t in json.loads((ROOT / "config/tools.yml").read_text())["tools"] if t["id"] == "audioldm2"]
        self.assertEqual(tool["version"], "0.1.0")
        self.assertEqual(tool["status"], "experimental")
        self.assertEqual(tool["install_mode"], "source")
        self.assertFalse(tool["auto_install"])
        self.assertEqual(tool["ports"], [])
        text = (ROOT / HELPER).read_text()
        self.assertIn("AD_COMMIT=" + tool["source_commit"], text)
        for field in ("doc", "install_script", "update_script", "uninstall_script", "doctor_script"):
            self.assertTrue((ROOT / tool[field]).is_file(), field)
        for required in ("AD_VERSION=0.1.0", "--no-deps",
                         '"$AD_SOURCE"', "flock -n 9", "require_ram_mb 1024",
                         "require_disk_mb 2048", "-ge 512", "direct_url.json",
                         "sys.prefix != sys.base_prefix", "unset HF_TOKEN HUGGING_FACE_HUB_TOKEN"):
            self.assertIn(required, text)
        for forbidden in ("import audioldm2", "generate_videos(", "files.upload(",
                          "docker compose", "rm -rf", "[dev]", "af_prepare_venv",
                          "run_apt_with_lock_wait", "gcloud auth", "Client("):
            self.assertNotIn(forbidden, text)

    def test_menu_doc_links(self):
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('TOOL_SCRIPT_NAMES["AudioLDM2"]="audioldm2"', menu)
        doc = ROOT / "docs/tools/audioldm2.md"
        for link in re.findall(r"\]\(([^)]+)\)", doc.read_text()):
            if "://" not in link and not link.startswith("#"):
                self.assertTrue((doc.parent / link.split("#")[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), "bash unavailable")
class Offline(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as tmp:
            prefix = f"""
export OPENCLAW_USER_DATA_DIR='{sp(Path(tmp) / "private")}'
export AUDIOLDM2_PYTHON_BIN='{sp(Path(sys.executable))}'
source {HELPER}
ad_paths
"""
            return subprocess.run([str(BASH), "--noprofile", "--norc", "-c", prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=90)

    def test_dry_run_no_files(self):
        r = self.shell("""
git() { exit 99; }; python3() { exit 99; }; sudo() { exit 99; }
audioldm2_main --dry-run
test ! -e "$AD_BASE"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_status_missing(self):
        r = self.shell('audioldm2_main status; test ! -e "$AD_BASE"')
        self.assertEqual(r.returncode, 0, r.stderr)
        state = json.loads(r.stdout)
        self.assertFalse(state["installed"])
        self.assertFalse(state["runtime_dependencies"])
        self.assertFalse(state["inference_tested"])

    def test_api_actions_rejected(self):
        for action, expected in (("doctor", 1), ("login", 2), ("upload", 2), ("subscribe", 2)):
            self.assertEqual(self.shell("audioldm2_main " + action).returncode, expected)

    def test_bad_root(self):
        for path in ("/", "$AD_ROOT/private", "$HOME/../other"):
            r = self.shell('OPENCLAW_USER_DATA_DIR="' + path + '" audioldm2_main --dry-run')
            self.assertNotEqual(r.returncode, 0)

    def test_foreign_source_preserved(self):
        r = self.shell("""
mkdir -p "$AD_SOURCE"
echo keep > "$AD_SOURCE/own-file"
if ad_fetch; then exit 99; fi
test "$(cat "$AD_SOURCE/own-file")" = keep
test ! -e "$AD_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_missing_sdk_layout_rejected(self):
        r = self.shell("""
mkdir -p "$AD_SOURCE"
touch "$AD_SOURCE/pyproject.toml"
ad_source_ok() { return 0; }
if ad_fetch; then exit 99; fi
test ! -e "$AD_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_expected_subdirectory_accepted(self):
        r = self.shell("""
mkdir -p "$AD_SOURCE/audioldm2"
touch "$AD_SOURCE/setup.py" "$AD_SOURCE/audioldm2/__init__.py" "$AD_SOURCE/LICENSE"
ad_source_ok() { return 0; }
ad_fetch
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_foreign_venv_rejected(self):
        r = self.shell("""
mkdir -p "$AD_VENV"
uname() { echo x86_64; }
ad_preflight
""")
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_system_site_packages_rejected(self):
        r = self.shell("""
mkdir -p "$AD_VENV"
echo 'include-system-site-packages = true' > "$AD_VENV/pyvenv.cfg"
uname() { echo x86_64; }
ad_preflight
""")
        self.assertNotEqual(r.returncode, 0)

    def test_key_environment_not_inherited(self):
        r = self.shell("""
export HF_TOKEN=SYNTHETIC_TEST_ONLY TEST_UNRELATED_KEY=SYNTHETIC_TEST_ONLY HUGGING_FACE_HUB_TOKEN=SYNTHETIC_TEST_ONLY
# A substitute probe checks only variable absence, never prints them.
ad_probe() { [[ ! -v HF_TOKEN && ! -v HUGGING_FACE_HUB_TOKEN && "$HF_HUB_OFFLINE" == 1 ]]; }
audioldm2_main status
test "$HF_TOKEN" = SYNTHETIC_TEST_ONLY
""")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue(json.loads(r.stdout)["installed"])
        self.assertNotIn("SYNTHETIC", r.stdout)

    def test_mock_package_build_targets_client_only(self):
        r = self.shell(r'''
mkdir -p "$AD_BASE"
export AD_BASE AD_VENV
ad_mock_python() {
    if [[ "$*" == *"-m venv"* ]]; then
        mkdir -p "$AD_VENV/bin"
        printf '#!/usr/bin/env bash\nad_mock_python "$@"\n' > "$AD_VENV/bin/python"
        chmod +x "$AD_VENV/bin/python"
    elif [[ "$*" == *"pip --isolated install"* ]]; then
                printf '%s\n' "$*" > "$AD_BASE/install-args"
    elif [[ "$*" == *"pip --isolated check"* ]]; then
        touch "$AD_BASE/pip-checked"
    else return 99
    fi
}
export -f ad_mock_python
AD_PYTHON=ad_mock_python
ad_metadata() { test -f "$AD_BASE/install-args"; }
ad_source_ok() { return 0; }
ad_install_package
grep -Fq -- "--no-deps $AD_SOURCE" "$AD_BASE/install-args"
test "$(cat "$AD_MARKER")" = "$AD_COMMIT base"
test ! -e "$AD_BASE/pip-checked"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_failed_package_build_clears_marker(self):
        r = self.shell(r'''
mkdir -p "$AD_BASE"
echo old > "$AD_MARKER"
ad_mock_python() { return 42; }
AD_PYTHON=ad_mock_python
set +e
(set -e; ad_install_package)
rc=$?
test "$rc" = 42 && test ! -e "$AD_MARKER"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_deactivation_keeps_data(self):
        r = self.shell("""
mkdir -p "$AD_SOURCE" "$AD_VENV"
touch "$AD_MARKER" "$AD_SOURCE/own-file" "$AD_VENV/own-file"
ad_deactivate
test ! -e "$AD_MARKER" && test -f "$AD_SOURCE/own-file" && test -f "$AD_VENV/own-file"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_legacy_runtime_rejected_before_tools(self):
        r = self.shell("AUDIOLDM2_INSTALL_RUNTIME=1 audioldm2_main install")
        self.assertEqual(r.returncode, 2, r.stderr)
        self.assertIn("Legacy-Runtime", r.stderr)

    def test_safety_documentation(self):
        doc = (ROOT / "docs/tools/audioldm2.md").read_text()
        for warning in ("CC BY-NC-SA 4.0", "MIT", "share=True", "1.23.5", "3.12", "--no-deps"):
            self.assertIn(warning, doc)


if __name__ == "__main__":
    unittest.main()
