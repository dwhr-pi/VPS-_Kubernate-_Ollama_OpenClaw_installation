"""Offline MOSS_TTS tests: no SDK imports, real installation, credentials, APIs or WSL."""
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
HELPER = "scripts/tools/helpers/moss_tts_common.sh"


def sp(path):
    value = str(path).replace("\\", "/")
    return "/" + value[0].lower() + value[2:] if os.name == "nt" else value


class Contract(unittest.TestCase):
    def test_source_contract(self):
        tool, = [t for t in json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"] if t["id"] == "moss_tts"]
        self.assertEqual(tool["version"], "0.1.0")
        self.assertEqual(tool["status"], "experimental")
        self.assertEqual(tool["install_mode"], "source")
        self.assertFalse(tool["auto_install"])
        self.assertEqual(tool["ports"], [])
        text = (ROOT / HELPER).read_text(encoding="utf-8")
        self.assertIn("MT_COMMIT=" + tool["source_commit"], text)
        for field in ("doc", "install_script", "update_script", "uninstall_script", "doctor_script"):
            self.assertTrue((ROOT / tool[field]).is_file(), field)
        for required in ("MT_VERSION=0.1.0", "--no-deps",
                         '"$MT_SOURCE"', "flock -n 9", "require_ram_mb 1024",
                         "require_disk_mb 2048", "-ge 512", "direct_url.json",
                         "sys.prefix != sys.base_prefix", "unset HF_TOKEN HUGGING_FACE_HUB_TOKEN"):
            self.assertIn(required, text)
        for forbidden in ("import moss_tts", "generate_videos(", "files.upload(",
                          "docker compose", "rm -rf", "[dev]", "af_prepare_venv",
                          "run_apt_with_lock_wait", "gcloud auth", "Client(", "remt_text"):
            self.assertNotIn(forbidden, text)

    def test_menu_doc_links(self):
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('TOOL_SCRIPT_NAMES["MOSS_TTS"]="moss_tts"', menu)
        self.assertNotIn('TOOL_SCRIPT_NAMES["MOSS_TTS"]="media_candidate"', menu)
        tool, = [t for t in json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools'] if t['id'] == 'moss_tts']
        for action in ('install', 'uninstall', 'update', 'doctor'):
            self.assertEqual(tool[action + '_script'], 'scripts/tools/moss_tts_' + action + '.sh')
        self.assertTrue(tool['check_value'].endswith('/source-built'))
        doc = ROOT / "docs/tools/moss-tts.md"
        for link in re.findall(r"\]\(([^)]+)\)", doc.read_text(encoding="utf-8")):
            if "://" not in link and not link.startswith("#"):
                self.assertTrue((doc.parent / link.split("#")[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), "bash unavailable")
class Offline(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as tmp:
            prefix = f"""
export OPENCLAW_USER_DATA_DIR='{sp(Path(tmp) / "private")}'
export MOSS_TTS_PYTHON_BIN='{sp(Path(sys.executable))}'
source {HELPER}
mt_paths
"""
            return subprocess.run([str(BASH), "--noprofile", "--norc", "-c", prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=90)

    def test_dry_run_no_files(self):
        r = self.shell("""
git() { exit 99; }; python3() { exit 99; }; sudo() { exit 99; }
moss_tts_main --dry-run
test ! -e "$MT_BASE"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_status_missing(self):
        r = self.shell('moss_tts_main status; test ! -e "$MT_BASE"')
        self.assertEqual(r.returncode, 0, r.stderr)
        state = json.loads(r.stdout)
        self.assertFalse(state["installed"])
        self.assertFalse(state["runtime_dependencies"])
        self.assertFalse(state["inference_tested"])

    def test_api_actions_rejected(self):
        for action, expected in (("doctor", 1), ("login", 2), ("upload", 2), ("subscribe", 2)):
            self.assertEqual(self.shell("moss_tts_main " + action).returncode, expected)

    def test_bad_root(self):
        for path in ("/", "$MT_ROOT/private", "$HOME/../other"):
            r = self.shell('OPENCLAW_USER_DATA_DIR="' + path + '" moss_tts_main --dry-run')
            self.assertNotEqual(r.returncode, 0)

    def test_foreign_source_preserved(self):
        r = self.shell("""
mkdir -p "$MT_SOURCE"
echo keep > "$MT_SOURCE/own-file"
if mt_fetch; then exit 99; fi
test "$(cat "$MT_SOURCE/own-file")" = keep
test ! -e "$MT_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_missing_sdk_layout_rejected(self):
        r = self.shell("""
mkdir -p "$MT_SOURCE"
touch "$MT_SOURCE/pyproject.toml"
mt_source_ok() { return 0; }
if mt_fetch; then exit 99; fi
test ! -e "$MT_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_expected_subdirectory_accepted(self):
        r = self.shell("""
mkdir -p "$MT_SOURCE/moss_tts_delay"
touch "$MT_SOURCE/pyproject.toml" "$MT_SOURCE/LICENSE"
mt_source_ok() { return 0; }
mt_fetch
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_foreign_venv_rejected(self):
        r = self.shell("""
mkdir -p "$MT_VENV"
uname() { echo x86_64; }
mt_preflight
""")
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_system_site_packages_rejected(self):
        r = self.shell("""
mkdir -p "$MT_VENV"
echo 'include-system-site-packages = true' > "$MT_VENV/pyvenv.cfg"
uname() { echo x86_64; }
mt_preflight
""")
        self.assertNotEqual(r.returncode, 0)

    def test_key_environment_not_inherited(self):
        r = self.shell("""
export HF_TOKEN=SYNTHETIC_TEST_ONLY TEST_UNRELATED_KEY=SYNTHETIC_TEST_ONLY HUGGING_FACE_HUB_TOKEN=SYNTHETIC_TEST_ONLY
# A substitute probe checks only variable absence, never prints them.
mt_probe() { [[ ! -v HF_TOKEN && ! -v HUGGING_FACE_HUB_TOKEN && "$HF_HUB_OFFLINE" == 1 ]]; }
moss_tts_main status
test "$HF_TOKEN" = SYNTHETIC_TEST_ONLY
""")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue(json.loads(r.stdout)["installed"])
        self.assertNotIn("SYNTHETIC", r.stdout)

    def test_mock_package_build_targets_client_only(self):
        r = self.shell(r'''
mkdir -p "$MT_BASE"
export MT_BASE MT_VENV
mt_mock_python() {
    if [[ "$*" == *"-m venv"* ]]; then
        mkdir -p "$MT_VENV/bin"
        printf '#!/usr/bin/env bash\nmt_mock_python "$@"\n' > "$MT_VENV/bin/python"
        chmod +x "$MT_VENV/bin/python"
    elif [[ "$*" == *"pip --isolated install"* ]]; then
                printf '%s\n' "$*" > "$MT_BASE/install-args"
    elif [[ "$*" == *"pip --isolated check"* ]]; then
        touch "$MT_BASE/pip-checked"
    else return 99
    fi
}
export -f mt_mock_python
MT_PYTHON=mt_mock_python
mt_metadata() { test -f "$MT_BASE/install-args"; }
mt_source_ok() { return 0; }
mt_install_package
grep -Fq -- "--no-deps $MT_SOURCE" "$MT_BASE/install-args"
test "$(cat "$MT_MARKER")" = "$MT_COMMIT base"
test ! -e "$MT_BASE/pip-checked"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_failed_package_build_clears_marker(self):
        r = self.shell(r'''
mkdir -p "$MT_BASE"
echo old > "$MT_MARKER"
mt_mock_python() { return 42; }
MT_PYTHON=mt_mock_python
set +e
(set -e; mt_install_package)
rc=$?
test "$rc" = 42 && test ! -e "$MT_MARKER"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_deactivation_keeps_data(self):
        r = self.shell("""
mkdir -p "$MT_SOURCE" "$MT_VENV"
touch "$MT_MARKER" "$MT_SOURCE/own-file" "$MT_VENV/own-file"
mkdir -p "$OPENCLAW_USER_DATA_DIR/status"
printf 'MOSS_TTS\\nOther\\n' > "$OPENCLAW_USER_DATA_DIR/installed_tools.txt"
printf 'MOSS_TTS\\nOther\\n' > "$OPENCLAW_USER_DATA_DIR/status/installed_tools.txt"
mt_deactivate
test ! -e "$MT_MARKER" && test -f "$MT_SOURCE/own-file" && test -f "$MT_VENV/own-file"
! grep -Fxq MOSS_TTS "$OPENCLAW_USER_DATA_DIR/installed_tools.txt"
! grep -Fxq MOSS_TTS "$OPENCLAW_USER_DATA_DIR/status/installed_tools.txt"
grep -Fxq Other "$OPENCLAW_USER_DATA_DIR/installed_tools.txt"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_legacy_runtime_rejected_before_tools(self):
        r = self.shell("MOSS_TTS_INSTALL_RUNTIME=1 moss_tts_main install")
        self.assertEqual(r.returncode, 2, r.stderr)
        self.assertIn("GPU-Runtime", r.stderr)

    def test_low_total_ram_blocks_even_in_conditional(self):
        r = self.shell('''
mkdir -p "$MT_BASE"
source() { return 0; }
require_ram_mb() { return 1; }
require_disk_mb() { touch "$MT_BASE/disk-reached"; }
if mt_resources; then exit 99; fi
test ! -e "$MT_BASE/disk-reached"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_safety_documentation(self):
        doc = (ROOT / "docs/tools/moss-tts.md").read_text(encoding="utf-8")
        for warning in ("Apache-2.0", "py-modules", "Submodul", "3.12", "--no-deps"):
            self.assertIn(warning, doc)


if __name__ == "__main__":
    unittest.main()
