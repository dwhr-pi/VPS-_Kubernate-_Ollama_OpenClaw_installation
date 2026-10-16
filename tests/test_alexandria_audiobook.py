"""Offline Alexandria source/venv checks. No real clone, package installation or WSL."""
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
HELPER = "scripts/tools/helpers/alexandria_audiobook_common.sh"


def shell_path(path):
    value = str(path).replace("\\", "/")
    return "/" + value[0].lower() + value[2:] if os.name == "nt" else value


class Registry(unittest.TestCase):
    def test_contract(self):
        tool, = [t for t in json.loads((ROOT / "config/tools.yml").read_text())["tools"] if t["id"] == "alexandria_audiobook"]
        self.assertEqual(tool["status"], "experimental")
        self.assertEqual(tool["install_mode"], "source")
        self.assertFalse(tool["auto_install"])
        self.assertEqual(tool["ports"], [])
        helper = (ROOT / HELPER).read_text()
        self.assertIn("AA_COMMIT=" + tool["source_commit"], helper)
        for field in ("install_script", "update_script", "uninstall_script", "doctor_script", "doc"):
            self.assertTrue((ROOT / tool[field]).is_file())
        for required in ("flock -n 9", "require_disk_mb 2048", "REQUIRE_WINDOWS_HOST_FREE_MB=4096",
                         '"$AA_PYTHON" -m venv "$AA_VENV"', "GIT_TERMINAL_PROMPT=0",
                         "GIT_LFS_SKIP_SMUDGE=1", "sys.prefix != sys.base_prefix"):
            self.assertIn(required, helper)
        for forbidden in ("pip install", "docker compose", "rm -rf", "git reset",
                          "bash webui.sh", "import installer", "import torch", "submodule update"):
            self.assertNotIn(forbidden, helper)

    def test_docs_menu(self):
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('TOOL_SCRIPT_NAMES["Alexandria_Audiobook"]="alexandria_audiobook"', menu)
        manual = menu.split('elif [ "$TOOL_KEY" = "Alexandria_Audiobook" ]', 1)[1].split('elif [ "$tool_rc" -eq 0 ]; then', 1)[0]
        self.assertNotIn("append_unique_line", manual)
        doc = ROOT / "docs/tools/alexandria-audiobook.md"
        for link in re.findall(r"\]\(([^)]+)\)", doc.read_text()):
            if "://" not in link and not link.startswith("#"):
                self.assertTrue((doc.parent / link.split("#")[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), "bash unavailable")
class Offline(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as tmp:
            prefix = f"""
export OPENCLAW_USER_DATA_DIR='{shell_path(Path(tmp) / "private")}'
export ALEXANDRIA_PYTHON_BIN='{shell_path(Path(sys.executable))}'
source {HELPER}
aa_paths
"""
            return subprocess.run([str(BASH), "--noprofile", "--norc", "-c", prefix + code],
                                  cwd=ROOT, text=True, capture_output=True, timeout=90)

    def test_dry_run_no_creation(self):
        result = self.shell("""
git() { exit 99; }
alexandria_audiobook_main --dry-run
test ! -e "$AA_BASE"
""")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_status_no_install(self):
        result = self.shell("""
alexandria_audiobook_main status
test ! -e "$AA_BASE"
""")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(json.loads(result.stdout)["runtime_ready"])
        self.assertFalse(json.loads(result.stdout)["source_ready"])

    def test_doctor_missing(self):
        self.assertEqual(self.shell("alexandria_audiobook_main doctor").returncode, 1)

    def test_start_blocked(self):
        for mode in ("start", "serve", "--bootstrap-runtime"):
            self.assertEqual(self.shell("alexandria_audiobook_main " + mode).returncode, 2)

    def test_bad_path(self):
        self.assertNotEqual(self.shell("OPENCLAW_USER_DATA_DIR=/ alexandria_audiobook_main --dry-run").returncode, 0)

    def test_sparse_excludes_weights_audio_and_configs(self):
        result = self.shell("aa_sparse_patterns")
        self.assertEqual(result.returncode, 0, result.stderr)
        for excluded in ("!*.safetensors", "!*.pth", "!*.wav", "!*.mp3", "!config.json", "!.env"):
            self.assertIn(excluded, result.stdout)
        self.assertNotIn("/builtin_lora/", result.stdout)

    def test_repo_path_rejected(self):
        self.assertNotEqual(self.shell('OPENCLAW_USER_DATA_DIR="$AA_ROOT/private" alexandria_audiobook_main --dry-run').returncode, 0)

    def test_foreign_source_preserved(self):
        result = self.shell("""
mkdir -p "$AA_SOURCE"
echo keep > "$AA_SOURCE/own-file"
if aa_fetch; then exit 99; fi
test "$(cat "$AA_SOURCE/own-file")" = keep
test ! -e "$AA_MARKER"
""")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_syntax_check_no_import_and_venv_reuse(self):
        result = self.shell("""
mkdir -p "$AA_SOURCE/app" "$AA_VENV"
for file in app/app.py; do
    printf 'raise AssertionError("NEVER IMPORT")\\n' > "$AA_SOURCE/$file"
done
touch "$AA_SOURCE/app/requirements.txt" "$AA_SOURCE/LICENSE"
aa_source_ok() { return 0; }
aa_venv_ok() { return 0; }
aa_fetch
aa_fetch
test "$(cat "$AA_MARKER")" = "$AA_COMMIT"
""")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("nicht betriebsbereit", result.stdout)

    def test_bad_venv_preserved(self):
        result = self.shell("""
mkdir -p "$AA_SOURCE" "$AA_VENV"
touch "$AA_VENV/own-file"
aa_source_ok() { return 0; }
aa_inspect() { return 0; }
aa_venv_ok() { return 1; }
if aa_fetch; then exit 99; fi
test -f "$AA_VENV/own-file"
test ! -e "$AA_MARKER"
""")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_clone_failure_does_not_make_venv(self):
        result = self.shell("""
mkdir -p "$AA_BASE"
git() {
    if [[ "$*" == *sparse-checkout* ]]; then cat >/dev/null; return 0; fi
    if [[ "$*" == *fetch* ]]; then return 42; fi
    return 0
}
set +e
(set -e; aa_fetch)
rc=$?
test "$rc" = 42 && test ! -e "$AA_MARKER" && test ! -e "$AA_VENV"
""")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_source_identity_checks(self):
        result = self.shell("""
mkdir -p "$AA_SOURCE/.git"
git() {
    case "$*" in
        *--show-toplevel*) echo "$AA_SOURCE" ;;
        *get-url*) echo https://github.com/foreign/project.git ;;
        *) echo "$AA_COMMIT" ;;
    esac
}
if aa_source_ok; then exit 99; fi
""")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_deactivate_keeps_all_data(self):
        result = self.shell("""
mkdir -p "$AA_SOURCE" "$AA_VENV"
touch "$AA_MARKER" "$AA_SOURCE/own-file" "$AA_VENV/own-file"
aa_deactivate
test ! -e "$AA_MARKER" && test -f "$AA_SOURCE/own-file" && test -f "$AA_VENV/own-file"
""")
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main()
