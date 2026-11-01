"""Check menu ordering with native Bash, without starting the installer or WSL."""
from pathlib import Path
import importlib.util
import io
import contextlib
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = "C:/Program Files/Git/bin/bash.exe" if sys.platform == "win32" else shutil.which("bash")
SPEC = importlib.util.spec_from_file_location('menu_order_fixture', ROOT / 'scripts/helpers/tool_menu_order.py')
ordering = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(ordering)


class MenuOrderUnit(unittest.TestCase):
    def test_actual_baseline_is_unique_sorted_and_new_keys_stay_appended(self):
        path = ROOT / 'config/tool_menu_sorted_baseline.txt'
        baseline = ordering.read_baseline(path)
        lines = [line for line in path.read_text().splitlines() if line and not line.startswith('#')]
        self.assertEqual(lines, sorted(set(lines), key=str.upper))
        self.assertGreater(len(baseline), 250)
        keys = ['Ollama', 'OpenClaw', 'Ruflo', 'AAA_Future', 'Zotero', 'Traefik', 'Act', 'Next_Future']
        expected = keys[:3] + ['Act', 'Traefik', 'Zotero', 'AAA_Future', 'Next_Future']
        self.assertEqual(ordering.ordered(keys, baseline), expected)
        self.assertEqual(ordering.ordered(expected, baseline), expected)

    def test_bad_input_is_not_executed_or_echoed(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'baseline.txt'
            for value in ('Act\nAct\n', '$(synthetic-canary)\n', '# empty\n', 'a' * 65537):
                path.write_text(value)
                out, err = io.StringIO(), io.StringIO()
                with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
                    self.assertEqual(ordering.main(['--baseline', str(path), '--', 'Act']), 1)
                self.assertEqual(out.getvalue(), '')
                self.assertNotIn('synthetic-canary', err.getvalue())


@unittest.skipUnless(BASH and Path(BASH).is_file(), "Native Bash unavailable")
class ToolMenuOrderTests(unittest.TestCase):
    def run_sort(self, names, baseline_root=ROOT, preamble='', expect_failure=False):
        setup = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        function = re.search(r"^sort_tool_menu_keys\(\) \{\n.*?^\}", setup, re.M | re.S).group()
        command = function + '\nINSTALL_DIR=' + shlex.quote(str(ROOT))
        command += '\npython3() { ' + shlex.quote(sys.executable) + ' "$@"; }\n'
        command += "\nTOOL_KEYS=(" + " ".join(map(shlex.quote, names)) + ")\n" + preamble + '\n'
        call = 'sort_tool_menu_keys ' + shlex.quote(str(baseline_root / 'config/tool_menu_sorted_baseline.txt'))
        command += ('if ' + call + '; then exit 99; fi\n' if expect_failure
                    else call + ' || exit $?\n')
        command += "if ((${#TOOL_KEYS[@]})); then printf '%s\\n' \"${TOOL_KEYS[@]}\"; fi"
        result = subprocess.run([BASH, "--noprofile", "--norc", "-c", command],
                                cwd=ROOT, capture_output=True, text=True, check=True, timeout=30,
                                env={key: value for key, value in os.environ.items()
                                     if key not in ('BASH_ENV', 'ENV', 'SHELLOPTS', 'BASHOPTS')})
        return result.stdout.splitlines()

    def test_all_registered_tools_are_sorted_without_losing_entries(self):
        setup = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        names = []
        for array in re.findall(r"^TOOL_KEYS\+?=\(([^\n]*)\)", setup, re.M):
            names.extend(shlex.split(array))
        native = (ROOT / 'scripts/helpers/native_github_menu.sh').read_text(encoding='utf-8')
        for array in re.findall(r'^NATIVE_GITHUB_TOOL_KEYS\+?=\(([^\n]*)\)', native, re.M):
            for name in shlex.split(array):
                if name not in names:
                    names.append(name)
        pinned = [name for name in names if name in {"Ollama", "OpenClaw", "Ruflo"}]
        baseline = set(line.strip() for line in (ROOT / 'config/tool_menu_sorted_baseline.txt').read_text().splitlines()
                       if line.strip() and not line.startswith('#'))
        appended = [name for name in names if name not in baseline and name not in pinned]
        remaining = [name for name in names if name not in pinned and name not in appended]
        result = self.run_sort(names)
        # LC_ALL=C sort -f folds ASCII letters to uppercase, including around underscores.
        self.assertEqual(result, pinned + sorted(remaining, key=str.upper) + appended)
        self.assertCountEqual(result, names)
        self.assertGreater(len(result), 250)
        self.assertIn("ACE_Step_15", result)
        self.assertIn("Act", result)
        self.assertIn("YouTube_Agent_Skill", result)
        self.assertEqual(len(result), len(set(result)))
        self.assertIn("Hermes_Agent_Jarvis", result)
        self.assertLess(result.index("Gradio"), result.index("Qwen_Desktop_Build"))
        self.assertEqual(self.run_sort(result), result)
        for name in ('GitOps_Bootstrap', 'Kubeseal', 'Traefik'):
            self.assertIn(name, baseline)
            self.assertLess(result.index(name), result.index('Zotero'))
        menu = setup.split("show_tool_management_menu() {", 1)[1]
        self.assertLess(menu.index("sort_tool_menu_keys"), menu.index('for tool_key in "${TOOL_KEYS[@]}"'))

    def test_future_tools_and_case_insensitive_order(self):
        names = ["Ollama", "OpenClaw", "Ruflo", "Zotero", "Act", "dbt", "cAdvisor", "Aegisub"]
        expected = names[:3] + ["Act", "Aegisub", "cAdvisor", "dbt", "Zotero"]
        self.assertEqual(self.run_sort(names), expected)
        self.assertEqual(self.run_sort(expected), expected)
        self.assertEqual(self.run_sort(["Ollama"]), ["Ollama"])
        self.assertEqual(self.run_sort([]), [])
        future = ['AAA_Future_Tool', 'New_Experimental_Tool', 'ZZZ_Future_Tool']
        mixed = names[:3] + [future[0], 'Zotero', future[1], 'Act', future[2], 'dbt']
        result = names[:3] + ['Act', 'dbt', 'Zotero'] + future
        self.assertEqual(self.run_sort(mixed), result)
        self.assertEqual(self.run_sort(result), result)

    def test_formerly_appended_tools_join_the_alphabetical_list(self):
        names = ["Ollama", "OpenClaw", "Ruflo", "Zotero", "Qwen_Desktop_Build",
                 "Audacity", "Act", "Concat", "Gradio", "AI_ContentMultiplier",
                 "GitOps_Bootstrap", "Kubeseal", "Traefik"]
        self.assertEqual(self.run_sort(names), names[:3] + sorted(names[3:], key=str.upper))
        setup = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('if [ "$tool_key" = "Ruflo" ]; then', setup)
        self.assertIn('"__TOOLS_SEPARATOR__" "---------------- Weitere Tools A-Z ----------------"', setup)

    def test_browser_and_study_tools_join_a_z_after_separator(self):
        tail = ['Comet', 'BrowserOS', 'BrowserOS_Study', 'Enki_Browser', 'Enki_Browser_Study', 'Qwen_Desktop_Study', 'Browser_Use', 'Perplexity_MCP',
                'Perplexity_Python', 'Perplexity_Node', 'Perplexity_API_Cookbook']
        names = ['Ollama', 'OpenClaw', 'Ruflo', 'Zotero', 'Act'] + tail
        self.assertEqual(self.run_sort(names), names[:3] + sorted(names[3:], key=str.upper))

    def test_core_order_above_separator_is_preserved(self):
        names = ['Ruflo', 'Zotero', 'OpenClaw', 'BrowserOS', 'Ollama', 'Act']
        self.assertEqual(self.run_sort(names), ['Ruflo', 'OpenClaw', 'Ollama', 'Act', 'BrowserOS', 'Zotero'])

    def test_missing_invalid_or_duplicate_baseline_keeps_all_entries(self):
        names = ['Ollama', 'Zotero', 'Act', 'AAA_Future_Tool']
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'config').mkdir()
            path = root / 'config/tool_menu_sorted_baseline.txt'
            self.assertEqual(self.run_sort(names, root, expect_failure=True), names)
            for text in ('Act\nAct\n', '$(exit 99)\n', '# empty baseline\n'):
                path.write_text(text)
                self.assertEqual(self.run_sort(names, root, expect_failure=True), names)

    def test_crlf_and_unterminated_baseline_and_failed_sort(self):
        names = ['Ollama', 'AAA_Future_Tool', 'Zotero', 'Act']
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'config').mkdir()
            (root / 'config/tool_menu_sorted_baseline.txt').write_bytes(b'Act\r\nZotero')
            self.assertEqual(self.run_sort(names, root), ['Ollama', 'Act', 'Zotero', 'AAA_Future_Tool'])
        self.assertEqual(self.run_sort(names, preamble='python3() { return 17; }', expect_failure=True), names)

    def test_duplicate_menu_key_does_not_change_selection(self):
        names = ['Ollama', 'Act', 'Zotero', 'Act']
        self.assertEqual(self.run_sort(names, expect_failure=True), names)


if __name__ == "__main__":
    unittest.main()
