"""Offline SD.Next source/venv checks. No real clone, package installation or WSL."""
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
HELPER = "scripts/tools/helpers/sdnext_common.sh"


def shell_path(path):
    value = str(path).replace("\\", "/")
    return "/" + value[0].lower() + value[2:] if os.name == "nt" else value


class Registry(unittest.TestCase):
    def test_contract(self):
        tool, = [t for t in json.loads((ROOT / "config/tools.yml").read_text())["tools"] if t["id"] == "sdnext"]
        self.assertEqual(tool["status"], "experimental")
        self.assertEqual(tool["install_mode"], "source")
        self.assertFalse(tool["auto_install"])
        self.assertEqual(tool["ports"], [])
        helper = (ROOT / HELPER).read_text()
        self.assertIn("SN_COMMIT=" + tool["source_commit"], helper)
        for field in ("install_script", "update_script", "uninstall_script", "doctor_script", "doc"):
            self.assertTrue((ROOT / tool[field]).is_file())
        for required in ("flock -n 9", "require_disk_mb 2048", "REQUIRE_WINDOWS_HOST_FREE_MB=4096",
                         '"$SN_PYTHON" -m venv "$SN_VENV"', "GIT_TERMINAL_PROMPT=0",
                         "GIT_LFS_SKIP_SMUDGE=1", "sys.prefix != sys.base_prefix"):
            self.assertIn(required, helper)
        for forbidden in ("pip install", "docker compose", "rm -rf", "git reset",
                          "bash webui.sh", "import installer", "import torch", "submodule update"):
            self.assertNotIn(forbidden, helper)

    def test_docs_menu(self):
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('TOOL_SCRIPT_NAMES["SD_Next"]="sdnext"', menu)
        manual = menu.split('elif [ "$TOOL_KEY" = "SD_Next" ]', 1)[1].split('elif [ "$tool_rc" -eq 0 ]; then', 1)[0]
        self.assertNotIn("append_unique_line", manual)
        doc = ROOT / "docs/tools/sdnext.md"
        for link in re.findall(r"\]\(([^)]+)\)", doc.read_text()):
            if "://" not in link and not link.startswith("#"):
                self.assertTrue((doc.parent / link.split("#")[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), "bash unavailable")
class Offline(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as tmp:
            prefix = f"""
export OPENCLAW_USER_DATA_DIR='{shell_path(Path(tmp) / "private")}'
export SDNEXT_PYTHON_BIN='{shell_path(Path(sys.executable))}'
source {HELPER}
sn_paths
"""
            return subprocess.run([str(BASH), "--noprofile", "--norc", "-c", prefix + code],
                                  cwd=ROOT, text=True, capture_output=True, timeout=90)

    def test_dry_run_no_creation(self):
        result = self.shell("""
git() { exit 99; }
sdnext_main --dry-run
test ! -e "$SN_BASE"
""")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_missing_ensurepip_without_consent(self):
        result = self.shell("""
sn_python_core_ok() { return 0; }
sn_python_venv_ok() { return 1; }
sn_venv_package() { echo python3.12-venv; }
command() { return 0; }
sn_install_venv_package() { echo UNEXPECTED_INSTALL; return 99; }
if sn_prepare_python; then exit 99; fi
""")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("UNEXPECTED_INSTALL", result.stdout)
        self.assertIn("Nicht installiert", result.stderr)

    def test_explicit_consent_installs_matching_package_and_rechecks(self):
        result = self.shell("""
sn_python_core_ok() { return 0; }
sn_python_venv_ok() { [[ "${repaired:-0}" == 1 ]]; }
sn_venv_package() { echo python3.12-venv; }
command() { return 0; }
sn_install_venv_package() { [[ "$1" == python3.12-venv ]] || return 99; repaired=1; }
SDNEXT_INSTALL_VENV_DEPS=1 sn_prepare_python
""")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_package_failure_stops(self):
        result = self.shell("""
sn_python_core_ok() { return 0; }
sn_python_venv_ok() { return 1; }
sn_venv_package() { echo python3.12-venv; }
command() { return 0; }
sn_install_venv_package() { return 42; }
SDNEXT_INSTALL_VENV_DEPS=1 sn_prepare_python
""")
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("fehlgeschlagen", result.stderr)

    def test_custom_interpreter_not_repaired_with_apt(self):
        result = self.shell("""
sn_python_core_ok() { return 0; }
sn_python_venv_ok() { return 1; }
sn_venv_package() { return 1; }
sn_install_venv_package() { echo UNEXPECTED_INSTALL; return 99; }
SDNEXT_INSTALL_VENV_DEPS=1 sn_prepare_python
""")
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertNotIn("UNEXPECTED_INSTALL", result.stdout)

    def test_working_python_needs_no_packages(self):
        result = self.shell("""
sn_python_core_ok() { return 0; }
sn_python_venv_ok() { return 0; }
sn_venv_package() { echo UNEXPECTED_PROBE; return 99; }
sn_prepare_python
""")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("UNEXPECTED_PROBE", result.stdout)

    def test_package_success_without_ensurepip_still_fails(self):
        result = self.shell("""
sn_python_core_ok() { return 0; }
sn_python_venv_ok() { return 1; }
sn_venv_package() { echo python3.12-venv; }
command() { return 0; }
sn_install_venv_package() { return 0; }
SDNEXT_INSTALL_VENV_DEPS=1 sn_prepare_python
""")
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("fehlt weiterhin", result.stderr)

    def test_dependency_preparation_after_guard_and_log_before_clone(self):
        helper = (ROOT / HELPER).read_text()
        main = helper.split('sdnext_main() (', 1)[1]
        self.assertLess(main.index('require_disk_mb 2048'), main.index('sn_prepare_python'))
        self.assertLess(main.index('exec > >(tee'), main.index('sn_prepare_python'))
        self.assertLess(main.index('flock -n 9'), main.index('sn_prepare_python'))
        self.assertLess(main.index('sn_prepare_python'), main.index('sn_fetch'))

    def test_status_no_install(self):
        result = self.shell("""
sdnext_main status
test ! -e "$SN_BASE"
""")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(json.loads(result.stdout)["runtime_ready"])
        self.assertFalse(json.loads(result.stdout)["source_ready"])

    def test_doctor_missing(self):
        self.assertEqual(self.shell("sdnext_main doctor").returncode, 1)

    def test_start_blocked(self):
        for mode in ("start", "serve", "--bootstrap-runtime"):
            self.assertEqual(self.shell("sdnext_main " + mode).returncode, 2)

    def test_bad_path(self):
        self.assertNotEqual(self.shell("OPENCLAW_USER_DATA_DIR=/ sdnext_main --dry-run").returncode, 0)

    def test_repo_path_rejected(self):
        self.assertNotEqual(self.shell('OPENCLAW_USER_DATA_DIR="$SN_ROOT/private" sdnext_main --dry-run').returncode, 0)

    def test_foreign_source_preserved(self):
        result = self.shell("""
mkdir -p "$SN_SOURCE"
echo keep > "$SN_SOURCE/own-file"
if sn_fetch; then exit 99; fi
test "$(cat "$SN_SOURCE/own-file")" = keep
test ! -e "$SN_MARKER"
""")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_syntax_check_no_import_and_venv_reuse(self):
        result = self.shell("""
mkdir -p "$SN_SOURCE/modules" "$SN_VENV"
for file in launch.py installer.py modules/cmd_args.py; do
    printf 'raise AssertionError("NEVER IMPORT")\\n' > "$SN_SOURCE/$file"
done
touch "$SN_SOURCE/requirements.txt" "$SN_SOURCE/LICENSE.txt" "$SN_SOURCE/webui.sh" "$SN_SOURCE/constraints.txt"
sn_source_ok() { return 0; }
sn_venv_ok() { return 0; }
sn_fetch
sn_fetch
test "$(cat "$SN_MARKER")" = "$SN_COMMIT"
""")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("nicht betriebsbereit", result.stdout)

    def test_bad_venv_preserved(self):
        result = self.shell("""
mkdir -p "$SN_SOURCE" "$SN_VENV"
touch "$SN_VENV/own-file"
sn_source_ok() { return 0; }
sn_inspect() { return 0; }
sn_venv_ok() { return 1; }
if sn_fetch; then exit 99; fi
test -f "$SN_VENV/own-file"
test ! -e "$SN_MARKER"
""")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_clone_failure_does_not_make_venv(self):
        result = self.shell("""
mkdir -p "$SN_BASE"
git() {
    if [[ "$*" == *fetch* ]]; then return 42; fi
    return 0
}
set +e
(set -e; sn_fetch)
rc=$?
test "$rc" = 42 && test ! -e "$SN_MARKER" && test ! -e "$SN_VENV"
""")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_source_identity_checks(self):
        result = self.shell("""
mkdir -p "$SN_SOURCE/.git"
git() {
    case "$*" in
        *--show-toplevel*) echo "$SN_SOURCE" ;;
        *get-url*) echo https://github.com/foreign/project.git ;;
        *) echo "$SN_COMMIT" ;;
    esac
}
if sn_source_ok; then exit 99; fi
""")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_deactivate_keeps_all_data(self):
        result = self.shell("""
mkdir -p "$SN_SOURCE" "$SN_VENV"
touch "$SN_MARKER" "$SN_SOURCE/own-file" "$SN_VENV/own-file"
sn_deactivate
test ! -e "$SN_MARKER" && test -f "$SN_SOURCE/own-file" && test -f "$SN_VENV/own-file"
""")
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main()
