"""Offline AudioGen tests: no SDK imports, real installation, credentials, APIs or WSL."""
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
HELPER = "scripts/tools/helpers/audiogen_common.sh"


def sp(path):
    value = str(path).replace("\\", "/")
    return "/" + value[0].lower() + value[2:] if os.name == "nt" else value


class Contract(unittest.TestCase):
    def test_source_contract(self):
        tool, = [t for t in json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"] if t["id"] == "audiogen"]
        self.assertEqual(tool["version"], "1.3.0")
        self.assertEqual(tool["status"], "experimental")
        self.assertEqual(tool["install_mode"], "source")
        self.assertFalse(tool["auto_install"])
        self.assertEqual(tool["ports"], [])
        text = (ROOT / HELPER).read_text(encoding="utf-8")
        self.assertIn("AG_COMMIT=" + tool["source_commit"], text)
        for field in ("doc", "install_script", "update_script", "uninstall_script", "doctor_script"):
            self.assertTrue((ROOT / tool[field]).is_file(), field)
        for required in ("AG_VERSION=1.3.0", "--no-deps",
                         '"$AG_SOURCE"', "flock -n 9", "require_ram_mb 1024",
                         "require_disk_mb 2048", "-ge 512", "direct_url.json",
                         "sys.prefix != sys.base_prefix", "unset HF_TOKEN HUGGING_FACE_HUB_TOKEN"):
            self.assertIn(required, text)
        for forbidden in ("import audiogen", "generate_videos(", "files.upload(",
                          "docker compose", "rm -rf", "[dev]", "af_prepare_venv",
                          "run_apt_with_lock_wait", "gcloud auth", "Client(", "reag_text"):
            self.assertNotIn(forbidden, text)

    def test_menu_doc_links(self):
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('TOOL_SCRIPT_NAMES["AudioGen"]="audiogen"', menu)
        doc = ROOT / "docs/tools/audiogen.md"
        for link in re.findall(r"\]\(([^)]+)\)", doc.read_text(encoding="utf-8")):
            if "://" not in link and not link.startswith("#"):
                self.assertTrue((doc.parent / link.split("#")[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), "bash unavailable")
class Offline(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as tmp:
            prefix = f"""
export OPENCLAW_USER_DATA_DIR='{sp(Path(tmp) / "private")}'
export AUDIOGEN_PYTHON_BIN='{sp(Path(sys.executable))}'
source {HELPER}
ag_paths
"""
            return subprocess.run([str(BASH), "--noprofile", "--norc", "-c", prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=90)

    def test_dry_run_no_files(self):
        r = self.shell("""
git() { exit 99; }; python3() { exit 99; }; sudo() { exit 99; }
audiogen_main --dry-run
test ! -e "$AG_BASE"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_status_missing(self):
        r = self.shell('audiogen_main status; test ! -e "$AG_BASE"')
        self.assertEqual(r.returncode, 0, r.stderr)
        state = json.loads(r.stdout)
        self.assertFalse(state["installed"])
        self.assertFalse(state["runtime_dependencies"])
        self.assertFalse(state["inference_tested"])

    def test_api_actions_rejected(self):
        for action, expected in (("doctor", 1), ("login", 2), ("upload", 2), ("subscribe", 2)):
            self.assertEqual(self.shell("audiogen_main " + action).returncode, expected)

    def test_bad_root(self):
        for path in ("/", "$AG_ROOT/private", "$HOME/../other"):
            r = self.shell('OPENCLAW_USER_DATA_DIR="' + path + '" audiogen_main --dry-run')
            self.assertNotEqual(r.returncode, 0)

    def test_foreign_source_preserved(self):
        r = self.shell("""
mkdir -p "$AG_SOURCE"
echo keep > "$AG_SOURCE/own-file"
if ag_fetch; then exit 99; fi
test "$(cat "$AG_SOURCE/own-file")" = keep
test ! -e "$AG_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_missing_sdk_layout_rejected(self):
        r = self.shell("""
mkdir -p "$AG_SOURCE"
touch "$AG_SOURCE/pyproject.toml"
ag_source_ok() { return 0; }
if ag_fetch; then exit 99; fi
test ! -e "$AG_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_expected_subdirectory_accepted(self):
        r = self.shell("""
mkdir -p "$AG_SOURCE/audiocraft/models"
touch "$AG_SOURCE/setup.py" "$AG_SOURCE/audiocraft/models/audiogen.py" "$AG_SOURCE/LICENSE"
ag_source_ok() { return 0; }
ag_fetch
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_foreign_venv_rejected(self):
        r = self.shell("""
mkdir -p "$AG_VENV"
uname() { echo x86_64; }
ag_preflight
""")
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_system_site_packages_rejected(self):
        r = self.shell("""
mkdir -p "$AG_VENV"
echo 'include-system-site-packages = true' > "$AG_VENV/pyvenv.cfg"
uname() { echo x86_64; }
ag_preflight
""")
        self.assertNotEqual(r.returncode, 0)

    def test_key_environment_not_inherited(self):
        r = self.shell("""
export HF_TOKEN=SYNTHETIC_TEST_ONLY TEST_UNRELATED_KEY=SYNTHETIC_TEST_ONLY HUGGING_FACE_HUB_TOKEN=SYNTHETIC_TEST_ONLY
# A substitute probe checks only variable absence, never prints them.
ag_probe() { [[ ! -v HF_TOKEN && ! -v HUGGING_FACE_HUB_TOKEN && "$HF_HUB_OFFLINE" == 1 ]]; }
audiogen_main status
test "$HF_TOKEN" = SYNTHETIC_TEST_ONLY
""")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue(json.loads(r.stdout)["installed"])
        self.assertNotIn("SYNTHETIC", r.stdout)

    def test_mock_package_build_targets_client_only(self):
        r = self.shell(r'''
mkdir -p "$AG_BASE"
export AG_BASE AG_VENV
ag_mock_python() {
    if [[ "$*" == *"-m venv"* ]]; then
        mkdir -p "$AG_VENV/bin"
        printf '#!/usr/bin/env bash\nag_mock_python "$@"\n' > "$AG_VENV/bin/python"
        chmod +x "$AG_VENV/bin/python"
    elif [[ "$*" == *"pip --isolated install"* ]]; then
                printf '%s\n' "$*" > "$AG_BASE/install-args"
    elif [[ "$*" == *"pip --isolated check"* ]]; then
        touch "$AG_BASE/pip-checked"
    else return 99
    fi
}
export -f ag_mock_python
AG_PYTHON=ag_mock_python
ag_metadata() { test -f "$AG_BASE/install-args"; }
ag_source_ok() { return 0; }
ag_install_package
grep -Fq -- "--no-deps $AG_SOURCE" "$AG_BASE/install-args"
test "$(cat "$AG_MARKER")" = "$AG_COMMIT base"
test ! -e "$AG_BASE/pip-checked"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_failed_package_build_clears_marker(self):
        r = self.shell(r'''
mkdir -p "$AG_BASE"
echo old > "$AG_MARKER"
ag_mock_python() { return 42; }
AG_PYTHON=ag_mock_python
set +e
(set -e; ag_install_package)
rc=$?
test "$rc" = 42 && test ! -e "$AG_MARKER"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_deactivation_keeps_data(self):
        r = self.shell("""
mkdir -p "$AG_SOURCE" "$AG_VENV"
touch "$AG_MARKER" "$AG_SOURCE/own-file" "$AG_VENV/own-file"
ag_deactivate
test ! -e "$AG_MARKER" && test -f "$AG_SOURCE/own-file" && test -f "$AG_VENV/own-file"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_legacy_runtime_rejected_before_tools(self):
        r = self.shell("AUDIOGEN_INSTALL_RUNTIME=1 audiogen_main install")
        self.assertEqual(r.returncode, 2, r.stderr)
        self.assertIn("Legacy-Runtime", r.stderr)

    def test_low_total_ram_blocks_even_in_conditional(self):
        r = self.shell('''
mkdir -p "$AG_BASE"
source() { return 0; }
require_ram_mb() { return 1; }
require_disk_mb() { touch "$AG_BASE/disk-reached"; }
if ag_resources; then exit 99; fi
test ! -e "$AG_BASE/disk-reached"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_safety_documentation(self):
        doc = (ROOT / "docs/tools/audiogen.md").read_text(encoding="utf-8")
        for warning in ("CC-BY-NC 4.0", "MIT", "2.1.0", "11.0.0", "3.12", "--no-deps"):
            self.assertIn(warning, doc)


if __name__ == "__main__":
    unittest.main()
