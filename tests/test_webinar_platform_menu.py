"""Exercise platform routing without starting WSL, downloads or installers."""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import unittest


ROOT = Path(__file__).resolve().parents[1]
BASH = "C:/Program Files/Git/bin/bash.exe" if sys.platform == "win32" else shutil.which("bash")
POWERSHELL = shutil.which("powershell.exe") or shutil.which("pwsh")
MENU = ROOT / "scripts/helpers/webinar_platform_menu.sh"
PS_SCRIPT = ROOT / "scripts/windows/webinar_tools.ps1"


@unittest.skipUnless(BASH and Path(BASH).is_file(), "Native Bash unavailable")
class WebinarPlatformTests(unittest.TestCase):
    def run_bash(self, code):
        result = subprocess.run([BASH, "--noprofile", "--norc", "-c", MENU.read_text() + "\n" + code],
                                capture_output=True, text=True, timeout=30, check=True,
                                env={**os.environ, "MSYS_NO_PATHCONV": "1"})
        return result.stdout

    def test_linux_dispatch_preserves_spaces_and_action(self):
        output = self.run_bash('''
INSTALL_DIR="/setup with spaces"
WEBINAR_PYTHON_BIN=fake_python
fake_python() { printf '%s\\n' "$@"; }
run_webinar_platform_action ubuntu marp plan
''')
        self.assertEqual(output.splitlines(), ["-B", "/setup with spaces/scripts/tools/helpers/webinar_releases.py", "marp", "plan"])

    def test_windows_dispatch_uses_only_native_powershell(self):
        output = self.run_bash('''
INSTALL_DIR="/setup with spaces"
wslpath() { printf '%s\\n' 'C:\\Setup with spaces\\scripts\\windows\\webinar_tools.ps1'; }
powershell.exe() { printf '%s\\n' "$@"; }
python3() { return 99; }
run_webinar_platform_action windows listmonk status
''')
        self.assertEqual(output.splitlines(), ["-NoProfile", "-NonInteractive", "-File",
            "C:\\Setup with spaces\\scripts\\windows\\webinar_tools.ps1", "-Tool", "listmonk", "-Action", "status"])

    def test_invalid_target_tool_or_action_never_dispatches(self):
        output = self.run_bash('''
INSTALL_DIR=/test
powershell.exe() { echo BAD; }
python3() { echo BAD; }
for args in 'unknown marp install' 'ubuntu unknown install' 'windows marp unknown'; do
    run_webinar_platform_action $args
    printf 'RC=%s\\n' "$?"
done
''')
        self.assertEqual(output.splitlines(), ["RC=2"] * 3)

    def test_qwen_linux_build_uses_separate_helper(self):
        output = self.run_bash('''
INSTALL_DIR="/setup with spaces"
GAP_TOOLS_PYTHON_BIN=fake_python
fake_python() { printf '%s\\n' "$@"; }
run_webinar_platform_action ubuntu qwen_desktop_build plan
''')
        self.assertEqual(output.splitlines(), ["-B", "/setup with spaces/scripts/tools/helpers/gap_tools.py", "qwen_desktop_build", "plan"])

    def test_qwen_windows_build_uses_separate_native_launcher(self):
        output = self.run_bash('''
INSTALL_DIR="/setup with spaces"
wslpath() { printf '%s\\n' 'C:\\Setup with spaces\\scripts\\windows\\qwen_desktop_build.ps1'; }
powershell.exe() { printf '%s\\n' "$@"; }
python3() { return 99; }
run_webinar_platform_action windows qwen_desktop_build status
''')
        self.assertEqual(output.splitlines(), ["-NoProfile", "-NonInteractive", "-File",
            "C:\\Setup with spaces\\scripts\\windows\\qwen_desktop_build.ps1", "-Action", "status"])

    def test_cancel_platform_and_decline_confirmation_do_nothing(self):
        output = self.run_bash('''
APP_TITLE=Test
run_webinar_platform_action() { echo BAD; }
dialog() { return 1; }
show_webinar_platform_menu
dialog() {
    case "$*" in
        *Setupauswahl*) echo windows ;;
        *Webinar-Werkzeug*) echo marp ;;
        *Webinar-Aktion*) echo install ;;
        *) return 1 ;;
    esac
}
show_webinar_platform_menu
echo done
''')
        self.assertEqual(output.splitlines(), ["done"])

    def test_separator_is_between_core_and_alphabetical_tools(self):
        source = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        menu = source.split("show_tool_management_menu() {", 1)[1]
        start = re.search(r'(?m)^\s+TOOL_CHECKLIST_OPTIONS=\(\)', menu).start()
        end = re.search(r'(?m)^\s+if \[ "\$overview_metrics_enabled" != "true" \]; then', menu).start()
        block = menu[start:end]
        output = self.run_bash('''
declare -A TOOLS INSTALLED_TOOLS_MAP
TOOL_KEYS=(Ollama OpenClaw Ruflo ACE_Step_15 Act)
for key in "${TOOL_KEYS[@]}"; do TOOLS[$key]=description; done
overview_metrics_enabled=false
installed_tool_count=0
''' + block + '\nprintf "%s\\n" "${TOOL_CHECKLIST_OPTIONS[@]}"')
        rows = output.splitlines()
        tags = rows[::3]
        self.assertEqual(tags, ["Ollama", "OpenClaw", "Ruflo", "__TOOLS_SEPARATOR__", "ACE_Step_15", "Act"])
        self.assertNotRegex(source, r'^TOOL_KEYS.*__TOOLS_SEPARATOR__', "separator is not a tool")
        self.assertIn('/^__TOOLS_SEPARATOR__$/d', menu)

    def test_button_dispatch_does_not_change_linux_status(self):
        source = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        menu = source.split("show_tool_management_menu() {", 1)[1]
        self.assertIn('--help-button --help-label "Ubuntu / Windows"', menu)
        branch = re.search(r'if \[ "\$tool_dialog_rc" -eq 2 \]; then(.*?)fi', menu, re.S).group(1)
        self.assertIn("show_webinar_platform_menu", branch)
        self.assertIn("return 0", branch)
        helper = MENU.read_text()
        dispatcher = helper.split("show_webinar_platform_menu()", 1)[0]
        self.assertNotIn("TOOL_STATUS_FILE", dispatcher)
        self.assertNotIn("append_unique_line", dispatcher)
        self.assertIn('if [[ "$target" = ubuntu && "$result" -eq 0 ]]; then', helper)

    def test_successful_windows_action_never_updates_linux_status(self):
        output = self.run_bash('''
APP_TITLE=Test
dialog() {
    case "$*" in
        *Setupauswahl*) echo windows ;;
        *Webinar-Werkzeug*) echo marp ;;
        *Webinar-Aktion*) echo install ;;
        *) return 0 ;;
    esac
}
clear() { :; }
read() { :; }
run_webinar_platform_action() { echo windows-action; }
append_unique_line() { echo BAD-status; }
remove_exact_line() { echo BAD-status; }
show_webinar_platform_menu
''')
        self.assertIn("windows-action", output)
        self.assertNotIn("BAD-status", output)


@unittest.skipUnless(POWERSHELL and sys.platform == "win32", "Native Windows PowerShell unavailable")
class WindowsWebinarLauncherTests(unittest.TestCase):
    def test_qwen_plan_works_without_python_and_uses_windows_target(self):
        result = subprocess.run([POWERSHELL, "-NoProfile", "-NonInteractive", "-File",
                                 str(ROOT / "scripts/windows/qwen_desktop_build.ps1"),
                                 "-Action", "plan", "-PythonBin", "absent.exe"],
                                capture_output=True, text=True, timeout=30, check=True)
        plan = json.loads(result.stdout)
        self.assertEqual(plan["target"], "native-windows")
        self.assertEqual(plan["tool"], "qwen_desktop_build")
        self.assertFalse(plan["network"])
        self.assertFalse(plan["executed"])
        self.assertRegex(plan["pin"], r"^[a-f0-9]{40}$")

    def test_qwen_status_ignores_inherited_linux_user_path(self):
        result = subprocess.run([POWERSHELL, "-NoProfile", "-NonInteractive", "-File",
                                 str(ROOT / "scripts/windows/qwen_desktop_build.ps1"),
                                 "-Action", "status", "-PythonBin", sys.executable],
                                capture_output=True, text=True, timeout=30, check=True,
                                env={**os.environ, "OPENCLAW_USER_DATA_DIR": "/home/ubuntu/not-a-windows-path"})
        status = json.loads(result.stdout)
        self.assertEqual(status["scope"], "desktop-build")
        self.assertFalse(status["runtime_tested"])

    def test_plan_without_python_or_file_changes(self):
        result = subprocess.run([POWERSHELL, "-NoProfile", "-NonInteractive", "-File", str(PS_SCRIPT),
                                 "-Tool", "mautic", "-Action", "plan", "-PythonBin", "absent.exe"],
                                capture_output=True, text=True, timeout=30, check=True)
        plan = json.loads(result.stdout)
        self.assertEqual(plan["target"], "native-windows")
        self.assertFalse(plan["network"])
        self.assertFalse(plan["executed"])
        self.assertEqual(plan["tool"], "mautic")

    def test_native_python_status_does_not_install(self):
        result = subprocess.run([POWERSHELL, "-NoProfile", "-NonInteractive", "-File", str(PS_SCRIPT),
                                 "-Tool", "marp", "-Action", "status", "-PythonBin", sys.executable],
                                capture_output=True, text=True, timeout=30, check=True)
        status = json.loads(result.stdout)
        self.assertFalse(status["service_configured"])
        self.assertEqual(status["scope"], "official-github-release")


if __name__ == "__main__":
    unittest.main()
