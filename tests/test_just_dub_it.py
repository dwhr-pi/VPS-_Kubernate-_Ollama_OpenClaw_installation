"""Offline Just_Dub_It tests: no SDK imports, real installation, credentials, APIs or WSL."""
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
HELPER = "scripts/tools/helpers/just_dub_it_common.sh"


def sp(path):
    value = str(path).replace("\\", "/")
    return "/" + value[0].lower() + value[2:] if os.name == "nt" else value


class Contract(unittest.TestCase):
    def test_source_contract(self):
        tool, = [t for t in json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"] if t["id"] == "just_dub_it"]
        self.assertEqual(tool["version"], "0.1.0")
        self.assertEqual(tool["status"], "experimental")
        self.assertEqual(tool["install_mode"], "source")
        self.assertFalse(tool["auto_install"])
        self.assertEqual(tool["ports"], [])
        text = (ROOT / HELPER).read_text(encoding="utf-8")
        self.assertIn("JD_COMMIT=" + tool["source_commit"], text)
        self.assertIn('("ltx-core", "ltx-pipelines")', text)
        self.assertIn('assert (3,12) <= sys.version_info < (3,13)', text)
        self.assertIn('--no-deps "$JD_SOURCE/packages/ltx-core" "$JD_SOURCE/packages/ltx-pipelines"', text)
        for field in ("doc", "install_script", "update_script", "uninstall_script", "doctor_script"):
            self.assertTrue((ROOT / tool[field]).is_file(), field)
        for required in ("JD_VERSION=0.1.0", "--no-deps",
                         '"$JD_SOURCE"', "flock -n 9", "require_ram_mb 1024",
                         "require_disk_mb 2048", "-ge 512", "direct_url.json",
                         "sys.prefix != sys.base_prefix", "unset HF_TOKEN HUGGING_FACE_HUB_TOKEN"):
            self.assertIn(required, text)
        for forbidden in ("import just_dub_it", "generate_videos(", "files.upload(",
                          "docker compose", "rm -rf", "[dev]", "af_prepare_venv",
                          "run_apt_with_lock_wait", "gcloud auth", "Client(", "rejd_text"):
            self.assertNotIn(forbidden, text)

    def test_menu_doc_links(self):
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('TOOL_SCRIPT_NAMES["Just_Dub_It"]="just_dub_it"', menu)
        doc = ROOT / "docs/tools/just-dub-it.md"
        for link in re.findall(r"\]\(([^)]+)\)", doc.read_text(encoding="utf-8")):
            if "://" not in link and not link.startswith("#"):
                self.assertTrue((doc.parent / link.split("#")[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), "bash unavailable")
class Offline(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as tmp:
            prefix = f"""
export OPENCLAW_USER_DATA_DIR='{sp(Path(tmp) / "private")}'
export JUST_DUB_IT_PYTHON_BIN='{sp(Path(sys.executable))}'
source {HELPER}
jd_paths
"""
            return subprocess.run([str(BASH), "--noprofile", "--norc", "-c", prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=90)

    def test_dry_run_no_files(self):
        r = self.shell("""
git() { exit 99; }; python3() { exit 99; }; sudo() { exit 99; }
just_dub_it_main --dry-run
test ! -e "$JD_BASE"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_status_missing(self):
        r = self.shell('just_dub_it_main status; test ! -e "$JD_BASE"')
        self.assertEqual(r.returncode, 0, r.stderr)
        state = json.loads(r.stdout)
        self.assertFalse(state["installed"])
        self.assertFalse(state["runtime_dependencies"])
        self.assertFalse(state["inference_tested"])

    def test_api_actions_rejected(self):
        for action, expected in (("doctor", 1), ("login", 2), ("upload", 2), ("subscribe", 2)):
            self.assertEqual(self.shell("just_dub_it_main " + action).returncode, expected)

    def test_bad_root(self):
        for path in ("/", "$JD_ROOT/private", "$HOME/../other"):
            r = self.shell('OPENCLAW_USER_DATA_DIR="' + path + '" just_dub_it_main --dry-run')
            self.assertNotEqual(r.returncode, 0)

    def test_foreign_source_preserved(self):
        r = self.shell("""
mkdir -p "$JD_SOURCE"
echo keep > "$JD_SOURCE/own-file"
if jd_fetch; then exit 99; fi
test "$(cat "$JD_SOURCE/own-file")" = keep
test ! -e "$JD_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_missing_sdk_layout_rejected(self):
        r = self.shell("""
mkdir -p "$JD_SOURCE"
touch "$JD_SOURCE/pyproject.toml"
jd_source_ok() { return 0; }
if jd_fetch; then exit 99; fi
test ! -e "$JD_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_expected_subdirectory_accepted(self):
        r = self.shell("""
mkdir -p "$JD_SOURCE/packages/ltx-core" "$JD_SOURCE/packages/ltx-pipelines"
touch "$JD_SOURCE/packages/ltx-core/pyproject.toml" "$JD_SOURCE/packages/ltx-pipelines/pyproject.toml" "$JD_SOURCE/LICENSE"
jd_source_ok() { return 0; }
jd_fetch
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_foreign_venv_rejected(self):
        r = self.shell("""
mkdir -p "$JD_VENV"
uname() { echo x86_64; }
jd_preflight
""")
        self.assertEqual(r.returncode, 1, r.stderr)

    def test_system_site_packages_rejected(self):
        r = self.shell("""
mkdir -p "$JD_VENV"
echo 'include-system-site-packages = true' > "$JD_VENV/pyvenv.cfg"
uname() { echo x86_64; }
jd_preflight
""")
        self.assertNotEqual(r.returncode, 0)

    def test_key_environment_not_inherited(self):
        r = self.shell("""
export HF_TOKEN=SYNTHETIC_TEST_ONLY TEST_UNRELATED_KEY=SYNTHETIC_TEST_ONLY HUGGING_FACE_HUB_TOKEN=SYNTHETIC_TEST_ONLY
# A substitute probe checks only variable absence, never prints them.
jd_probe() { [[ ! -v HF_TOKEN && ! -v HUGGING_FACE_HUB_TOKEN && "$HF_HUB_OFFLINE" == 1 ]]; }
just_dub_it_main status
test "$HF_TOKEN" = SYNTHETIC_TEST_ONLY
""")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue(json.loads(r.stdout)["installed"])
        self.assertNotIn("SYNTHETIC", r.stdout)

    def test_mock_package_build_targets_client_only(self):
        r = self.shell(r'''
mkdir -p "$JD_BASE"
export JD_BASE JD_VENV
jd_mock_python() {
    if [[ "$*" == *"-m venv"* ]]; then
        mkdir -p "$JD_VENV/bin"
        printf '#!/usr/bin/env bash\njd_mock_python "$@"\n' > "$JD_VENV/bin/python"
        chmod +x "$JD_VENV/bin/python"
    elif [[ "$*" == *"pip --isolated install"* ]]; then
                printf '%s\n' "$*" > "$JD_BASE/install-args"
    elif [[ "$*" == *"pip --isolated check"* ]]; then
        touch "$JD_BASE/pip-checked"
    else return 99
    fi
}
export -f jd_mock_python
JD_PYTHON=jd_mock_python
jd_metadata() { test -f "$JD_BASE/install-args"; }
jd_source_ok() { return 0; }
jd_install_package
grep -Fq -- "--no-deps $JD_SOURCE/packages/ltx-core $JD_SOURCE/packages/ltx-pipelines" "$JD_BASE/install-args"
test "$(cat "$JD_MARKER")" = "$JD_COMMIT base"
test ! -e "$JD_BASE/pip-checked"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_failed_package_build_clears_marker(self):
        r = self.shell(r'''
mkdir -p "$JD_BASE"
echo old > "$JD_MARKER"
jd_mock_python() { return 42; }
JD_PYTHON=jd_mock_python
set +e
(set -e; jd_install_package)
rc=$?
test "$rc" = 42 && test ! -e "$JD_MARKER"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_deactivation_keeps_data(self):
        r = self.shell("""
mkdir -p "$JD_SOURCE" "$JD_VENV"
touch "$JD_MARKER" "$JD_SOURCE/own-file" "$JD_VENV/own-file"
jd_deactivate
test ! -e "$JD_MARKER" && test -f "$JD_SOURCE/own-file" && test -f "$JD_VENV/own-file"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_legacy_runtime_rejected_before_tools(self):
        r = self.shell("JUST_DUB_IT_INSTALL_RUNTIME=1 just_dub_it_main install")
        self.assertEqual(r.returncode, 2, r.stderr)
        self.assertIn("GPU-Runtime", r.stderr)

    def test_license_required_before_any_download(self):
        r = self.shell('''
git() { exit 99; }
just_dub_it_main install
''')
        self.assertEqual(r.returncode, 2, r.stderr)
        self.assertIn('JUST_DUB_IT_ACCEPT_LICENSE=1', r.stderr)

    def test_archive_warning_in_dry_run(self):
        r = self.shell('just_dub_it_main --dry-run')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn('archiviert', r.stdout)

    def test_python_312_preflight_accepted_without_creation(self):
        r = self.shell('''
uname() { echo x86_64; }
jd_python312() { return 0; }
JD_PYTHON=jd_python312
jd_preflight
test ! -e "$JD_BASE"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_low_total_ram_blocks_even_in_conditional(self):
        r = self.shell('''
mkdir -p "$JD_BASE"
source() { return 0; }
require_ram_mb() { return 1; }
require_disk_mb() { touch "$JD_BASE/disk-reached"; }
if jd_resources; then exit 99; fi
test ! -e "$JD_BASE/disk-reached"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_safety_documentation(self):
        doc = (ROOT / "docs/tools/just-dub-it.md").read_text(encoding="utf-8")
        for warning in ("archiviert", "Community License", "LTX-2", "3.12", "--no-deps"):
            self.assertIn(warning, doc)


if __name__ == "__main__":
    unittest.main()
