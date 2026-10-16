"""Offline Windmill tests. Fake ELF downloads only; no remote fetch, binary execution or WSL."""
import hashlib
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
HELPER = "scripts/tools/helpers/windmill_common.sh"
FAKE_ELF = bytes([127, 69, 76, 70, 2, 1]) + bytes(12) + bytes([62, 0]) + b"TEST DATA - DO NOT EXECUTE"


def sp(path):
    value = str(path).replace("\\", "/")
    return "/" + value[0].lower() + value[2:] if os.name == "nt" else value


class Contract(unittest.TestCase):
    def test_registry(self):
        tool, = [t for t in json.loads((ROOT / "config/tools.yml").read_text())["tools"] if t["id"] == "windmill"]
        self.assertEqual(tool["status"], "experimental")
        self.assertFalse(tool["auto_install"])
        self.assertEqual(tool["ports"], [])
        self.assertEqual(tool["install_mode"], "source")
        text = (ROOT / HELPER).read_text()
        self.assertIn("WM_COMMIT=" + tool["source_commit"], text)
        self.assertIn("WM_RELEASE=v" + tool["version"], text)
        self.assertIn("5879cd22b178d8871031cc072e5de5052ab46c4bd134e3358ff8a96d25d229aa", text)
        for field in ("install_script", "update_script", "doctor_script", "uninstall_script", "doc"):
            self.assertTrue((ROOT / tool[field]).is_file())
        for token in ("flock -n 9", "require_disk_mb 4096", "WINDMILL_ACCEPT_RELEASE_TERMS",
                      "sha256sum --check --status", "--proto-redir '=https'", "GIT_TERMINAL_PROMPT=0"):
            self.assertIn(token, text)
        for forbidden in ('"$WM_BINARY" --', "cargo build", "npm install", "docker compose", "rm -rf", "git reset"):
            self.assertNotIn(forbidden, text)

    def test_menu_and_doc_links(self):
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('TOOL_SCRIPT_NAMES["Windmill"]="windmill"', menu)
        branch = menu.split('elif [ "$TOOL_KEY" = "Windmill" ]', 1)[1].split('elif [ "$tool_rc" -eq 0 ]; then', 1)[0]
        self.assertNotIn("append_unique_line", branch)
        doc = ROOT / "docs/tools/windmill.md"
        for link in re.findall(r"\]\(([^)]+)\)", doc.read_text()):
            if "://" not in link and not link.startswith("#"):
                self.assertTrue((doc.parent / link.split("#")[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), "bash unavailable")
class Offline(unittest.TestCase):
    def shell(self, code, fixture=FAKE_ELF):
        with tempfile.TemporaryDirectory() as tmp:
            blob = Path(tmp) / "fixture"
            blob.write_bytes(fixture)
            prefix = f"""
export OPENCLAW_USER_DATA_DIR='{sp(Path(tmp) / "private")}'
source {HELPER}
python3() {{ '{sp(Path(sys.executable))}' "$@"; }}
wm_paths
MOCK_DOWNLOAD='{sp(blob)}'
WM_SHA256='{hashlib.sha256(fixture).hexdigest()}'
curl() {{
    while [[ "$#" -gt 0 ]]; do
        if [[ "$1" == --output ]]; then cp "$MOCK_DOWNLOAD" "$2"; return; fi
        shift
    done
    return 99
}}
"""
            if os.name == "nt":
                # Git Bash does not report ELF files executable on NTFS.
                # Mock only that Linux permission probe, not hash/header checks.
                prefix += "\nwm_binary_executable() { return 0; }\n"
            return subprocess.run([str(BASH), "--noprofile", "--norc", "-c", prefix + code],
                                  cwd=ROOT, text=True, capture_output=True, timeout=90)

    def test_plan_no_files(self):
        r = self.shell("""
git() { exit 99; }; curl() { exit 99; }
windmill_main --dry-run
test ! -e "$WM_BASE"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_empty_status(self):
        r = self.shell('windmill_main status; test ! -e "$WM_BASE"')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertEqual(json.loads(r.stdout), dict(source_ready=False, binary_installed=False, runtime_ready=False))

    def test_start_blocked(self):
        for action in ("serve", "start", "--build"):
            self.assertEqual(self.shell("windmill_main " + action).returncode, 2)

    def test_missing_doctor(self):
        self.assertEqual(self.shell("windmill_main doctor").returncode, 1)

    def test_license_opt_in(self):
        r = self.shell("WINDMILL_ACCEPT_RELEASE_TERMS=0 wm_binary_preflight")
        self.assertEqual(r.returncode, 2)
        self.assertIn("Bedingungen", r.stderr)

    def test_arm_no_wrong_asset(self):
        r = self.shell("""
uname() { if [[ "$1" == -s ]]; then echo Linux; else echo aarch64; fi; }
WINDMILL_ACCEPT_RELEASE_TERMS=1 wm_binary_preflight
""")
        self.assertEqual(r.returncode, 1)
        self.assertIn("ARM", r.stderr)

    def test_bad_root(self):
        self.assertNotEqual(self.shell("OPENCLAW_USER_DATA_DIR=/ windmill_main --dry-run").returncode, 0)

    def test_source_only_no_execution(self):
        r = self.shell("""
mkdir -p "$WM_SOURCE/backend/src" "$WM_SOURCE/frontend"
touch "$WM_SOURCE/backend/Cargo.toml" "$WM_SOURCE/backend/Cargo.lock" "$WM_SOURCE/backend/src/main.rs"
touch "$WM_SOURCE/LICENSE" "$WM_SOURCE/LICENSE-AGPL" "$WM_SOURCE/LICENSE-APACHE"
printf '{"version":"1.837.0"}' > "$WM_SOURCE/frontend/package.json"
wm_source_ok() { return 0; }
wm_fetch
test "$(cat "$WM_MARKER")" = "$WM_COMMIT"
test ! -e "$WM_BINARY"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_foreign_source_preserved(self):
        r = self.shell("""
mkdir -p "$WM_SOURCE"
echo keep > "$WM_SOURCE/own-file"
if wm_fetch; then exit 99; fi
test "$(cat "$WM_SOURCE/own-file")" = keep
test ! -e "$WM_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_mock_binary_install_reuse_status(self):
        r = self.shell("""
mkdir -p "$WM_BASE"
wm_install_binary
curl() { exit 99; }
wm_install_binary
wm_binary_ok
wm_source_ok() { return 0; }
echo "$WM_COMMIT" > "$WM_MARKER"
windmill_main status
""")
        self.assertEqual(r.returncode, 0, r.stderr)
        state = json.loads(r.stdout.strip().splitlines()[-1])
        self.assertTrue(state["binary_installed"])
        self.assertFalse(state["runtime_ready"])

    def test_wrong_hash_never_promoted(self):
        r = self.shell("""
mkdir -p "$WM_BASE"
WM_SHA256=0000000000000000000000000000000000000000000000000000000000000000
set +e
(set -e; wm_install_binary)
rc=$?
test "$rc" != 0 && test ! -e "$WM_BINARY" && test ! -e "$WM_BINARY_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_not_elf_never_promoted(self):
        r = self.shell("""
mkdir -p "$WM_BASE"
set +e
(set -e; wm_install_binary)
rc=$?
test "$rc" != 0 && test ! -e "$WM_BINARY" && test ! -e "$WM_BINARY_MARKER"
""", fixture=b"NOT AN ELF")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_failed_download(self):
        r = self.shell("""
mkdir -p "$WM_BASE"
curl() { return 42; }
set +e
(set -e; wm_install_binary)
rc=$?
test "$rc" = 42 && test ! -e "$WM_BINARY" && test ! -e "$WM_BINARY_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_existing_binary_preserved(self):
        r = self.shell("""
mkdir -p "$WM_BASE/bin"
echo keep > "$WM_BINARY"
if wm_install_binary; then exit 99; fi
test "$(cat "$WM_BINARY")" = keep
test ! -e "$WM_BINARY_MARKER"
""")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_deactivation_preserves_data(self):
        r = self.shell("""
mkdir -p "$WM_SOURCE" "$WM_BASE/bin"
touch "$WM_MARKER" "$WM_BINARY_MARKER" "$WM_BINARY" "$WM_SOURCE/own-file"
wm_deactivate
test ! -e "$WM_MARKER" && test ! -e "$WM_BINARY_MARKER"
test -f "$WM_BINARY" && test -f "$WM_SOURCE/own-file"
""")
        self.assertEqual(r.returncode, 0, r.stderr)


if __name__ == "__main__":
    unittest.main()
