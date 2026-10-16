"""Offline native-desktop handoff tests; never open a browser or execute an installer."""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = Path("C:/Program Files/Git/bin/bash.exe") if os.name == "nt" else shutil.which("bash")


class PinokioRegistry(unittest.TestCase):
    def test_registry_and_menu(self):
        tools = json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"]
        tool, = [t for t in tools if t["id"] == "pinokio"]
        self.assertEqual(tool["install_mode"], "manual-desktop")
        self.assertEqual(tool["version"], "8.2.0")
        self.assertFalse(tool["auto_install"])
        self.assertEqual(tool["ports"], [])
        self.assertEqual(tool["check_type"], "documentation")
        for field in ("install_script", "uninstall_script", "update_script", "doctor_script", "doc"):
            self.assertTrue((ROOT / tool[field]).is_file(), field)
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('TOOL_SCRIPT_NAMES["Pinokio"]="pinokio"', menu)
        manual = menu.split('elif [ "$TOOL_KEY" = "Pinokio" ]', 1)[1]
        manual = manual.split('elif [ "$tool_rc" -eq 0 ]; then', 1)[0]
        self.assertNotIn("append_unique_line", manual)
        self.assertIn('operation_status="skipped"', manual)

    def test_docs_links(self):
        doc = ROOT / "docs/tools/pinokio.md"
        content = doc.read_text(encoding="utf-8")
        self.assertIn("3f94d8dc19bd09f966021e01d479c3440bb1d9237f4a4923bcd0d356e04c7246", content)
        for link in re.findall(r"\]\(([^)]+)\)", content):
            if "://" not in link and not link.startswith("#"):
                self.assertTrue((doc.parent / link.split("#")[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), "bash unavailable")
class PinokioHandoff(unittest.TestCase):
    def invoke(self, code, data=""):
        with tempfile.TemporaryDirectory() as temp:
            home = Path(temp) / "unused-home"
            result = subprocess.run(
                [str(BASH), "--noprofile", "--norc", "-c",
                 "source scripts/tools/helpers/pinokio_common.sh\n" + code],
                cwd=ROOT, env=dict(os.environ, HOME=str(home)), input=data,
                text=True, capture_output=True, timeout=90)
            self.assertFalse(home.exists())
        return result

    def test_dry_run_and_checks_offline(self):
        for action in ("--dry-run", "check", "status", "doctor"):
            result = self.invoke("pinokio_main " + action)
            self.assertEqual(result.returncode, 0, result.stderr)
            state = json.loads(result.stdout)
            self.assertFalse(state["installed"])
            self.assertFalse(state["network"])
            self.assertFalse(state["installation_verified"])

    def test_noninteractive_deferred(self):
        for action in ("install", "update"):
            result = self.invoke("pinokio_can_prompt() { return 1; }; pinokio_main " + action)
            self.assertEqual(result.returncode, 3, result.stderr)

    def test_confirmed_wait(self):
        result = self.invoke(
            "pinokio_can_prompt() { return 0; }\n"
            "pinokio_open_download() { echo MOCK_BROWSER; }\n"
            "pinokio_main install", "j\n\nj\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "MOCK_BROWSER")
        self.assertIn("Setup pausiert", result.stderr)
        self.assertIn("nicht automatisch geprueft", result.stderr)

    def test_default_no_browser_or_install(self):
        result = self.invoke(
            "pinokio_can_prompt() { return 0; }\n"
            "pinokio_open_download() { echo UNEXPECTED; return 1; }\n"
            "pinokio_main install", "\n\n\n")
        self.assertEqual(result.returncode, 3, result.stderr)
        self.assertNotIn("UNEXPECTED", result.stdout)

    def test_eof_deferred(self):
        result = self.invoke("pinokio_can_prompt() { return 0; }; pinokio_main install")
        self.assertEqual(result.returncode, 3, result.stderr)

    def test_browser_failure(self):
        result = self.invoke(
            "pinokio_can_prompt() { return 0; }\n"
            "pinokio_open_download() { return 1; }\n"
            "pinokio_main install", "j\n")
        self.assertEqual(result.returncode, 1)

    def test_explicit_browser_not_install(self):
        result = self.invoke("pinokio_open_download() { echo MOCK_BROWSER; }; pinokio_main --open-download")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("MOCK_BROWSER", result.stdout)
        self.assertNotIn("bestaetigt", result.stdout + result.stderr)

    def test_uninstall_does_not_delete(self):
        result = self.invoke("pinokio_main uninstall")
        self.assertEqual(result.returncode, 2)
        self.assertIn("keine automatische Datenloeschung", result.stderr)

    def test_fixed_windows_browser_target(self):
        result = self.invoke(
            'export WSL_DISTRO_NAME=MOCK_ONLY\n'
            'powershell.exe() { printf "%s\\n" "$@"; }\n'
            'pinokio_main --open-download')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Start-Process 'https://github.com/pinokiocomputer/pinokio/releases/tag/v8.2.0'", result.stdout)
        self.assertNotIn("Pinokio.exe", result.stdout)


if __name__ == "__main__":
    unittest.main()
