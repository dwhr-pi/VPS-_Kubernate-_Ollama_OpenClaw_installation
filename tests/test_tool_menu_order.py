"""Check menu ordering with native Bash, without starting the installer or WSL."""
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = "C:/Program Files/Git/bin/bash.exe" if sys.platform == "win32" else shutil.which("bash")


@unittest.skipUnless(BASH and Path(BASH).is_file(), "Native Bash unavailable")
class ToolMenuOrderTests(unittest.TestCase):
    def run_sort(self, names):
        setup = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        function = re.search(r"^sort_tool_menu_keys\(\) \{\n.*?^\}", setup, re.M | re.S).group()
        command = function + "\nTOOL_KEYS=(" + " ".join(map(shlex.quote, names)) + ")\n"
        command += "sort_tool_menu_keys\nprintf '%s\\n' \"${TOOL_KEYS[@]}\""
        result = subprocess.run([BASH, "--noprofile", "--norc", "-c", command],
                                capture_output=True, text=True, check=True, timeout=30)
        return result.stdout.splitlines()

    def test_all_registered_tools_are_sorted_without_losing_entries(self):
        setup = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        names = []
        for array in re.findall(r"^TOOL_KEYS\+?=\(([^\n]*)\)", setup, re.M):
            names.extend(shlex.split(array))
        pinned = [name for name in names if name in {"Ollama", "OpenClaw", "Ruflo"}]
        remaining = [name for name in names if name not in pinned]
        result = self.run_sort(names)
        # LC_ALL=C sort -f folds ASCII letters to uppercase, including around underscores.
        self.assertEqual(result, pinned + sorted(remaining, key=str.upper))
        self.assertCountEqual(result, names)
        self.assertGreater(len(result), 250)
        self.assertIn("ACE_Step_15", result)
        self.assertIn("Act", result)
        self.assertIn("YouTube_Agent_Skill", result)
        self.assertEqual(len(result), len(set(result)))
        self.assertIn("Hermes_Agent_Jarvis", result)
        self.assertLess(result.index("Gradio"), result.index("Qwen_Desktop_Build"))
        self.assertEqual(self.run_sort(result), result)
        menu = setup.split("show_tool_management_menu() {", 1)[1]
        self.assertLess(menu.index("sort_tool_menu_keys"), menu.index('for tool_key in "${TOOL_KEYS[@]}"'))

    def test_future_tools_and_case_insensitive_order(self):
        names = ["Ollama", "OpenClaw", "Ruflo", "Zotero", "Act", "dbt", "cAdvisor", "Aegisub"]
        expected = names[:3] + ["Act", "Aegisub", "cAdvisor", "dbt", "Zotero"]
        self.assertEqual(self.run_sort(names), expected)
        self.assertEqual(self.run_sort(expected), expected)
        self.assertEqual(self.run_sort(["Ollama"]), ["Ollama"])

    def test_formerly_appended_tools_join_the_alphabetical_list(self):
        names = ["Ollama", "OpenClaw", "Ruflo", "Zotero", "Qwen_Desktop_Build",
                 "Audacity", "Act", "Concat", "Gradio", "AI_ContentMultiplier"]
        self.assertEqual(self.run_sort(names), names[:3] + sorted(names[3:], key=str.upper))
        setup = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('if [ "$tool_key" = "Ruflo" ]; then', setup)
        self.assertIn('"__TOOLS_SEPARATOR__" "---------------- Weitere Tools A-Z ----------------"', setup)


if __name__ == "__main__":
    unittest.main()
