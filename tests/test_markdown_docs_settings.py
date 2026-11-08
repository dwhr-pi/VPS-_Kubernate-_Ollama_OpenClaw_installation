"""Exercise Settings actions with fake dialog/Python only; no server or user files."""
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')


@unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash unavailable; no WSL fallback')
class MarkdownDocsSettings(unittest.TestCase):
    def shell(self, code, expected=0):
        script = 'scripts/markdown_docs_server_menu.sh'
        preamble = 'source ' + shlex.quote(script) + '\n'
        preamble += 'fixture_python() { printf "PYTHON:"; printf " <%s>" "$@"; printf "\\n"; }\n'
        preamble += 'GAP_TOOLS_PYTHON_BIN=fixture_python\n'
        env = {k: v for k, v in os.environ.items() if k not in ('BASH_ENV', 'ENV', 'SHELLOPTS', 'BASHOPTS')}
        result = subprocess.run([BASH, '--noprofile', '--norc', '-s'], input=preamble + code,
                                cwd=ROOT, text=True, capture_output=True, timeout=20, env=env)
        self.assertEqual(result.returncode, expected, result.stderr)
        return result.stdout

    def test_open_and_cancel_never_calls_python_or_opens_browser(self):
        output = self.shell('dialog() { return 1; }; markdown_docs_menu\n')
        self.assertNotIn('PYTHON:', output)

    def test_documentation_and_lab_guides_are_read_only(self):
        for action in ('guide', 'index', 'metrics', 'linux', 'wsl'):
            code = 'dialog() { printf "%s\\n" "$*"; }; markdown_docs_action ' + action + ' ' + shlex.quote(ROOT.as_posix())
            output = self.shell(code)
            self.assertIn('--textbox', output)
            self.assertNotIn('PYTHON:', output)
            path = self.shell('markdown_docs_document ' + action).strip()
            self.assertTrue((ROOT / path).is_file())

    def test_plan_status_doctor_do_not_apply(self):
        for action in ('plan', 'status', 'doctor'):
            output = self.shell('markdown_docs_action ' + action + ' /fixture')
            self.assertIn('PYTHON:', output)
            self.assertNotIn('--apply', output)

    def test_valid_install_and_update_need_commit_and_separate_approval(self):
        for action in ('install', 'update'):
            for approved in (True, False):
                dialog = ('dialog() { case "$*" in *--inputbox*) printf "%s\\n" ' + 'a' * 40
                          + ' ;; *) return ' + ('0' if approved else '1') + ' ;; esac; }; ')
                output = self.shell(dialog + 'markdown_docs_action ' + action + ' /fixture')
                self.assertEqual('PYTHON:' in output, approved)
                if approved:
                    self.assertIn('<--source-commit> <' + 'a' * 40 + '>', output)
                    self.assertIn('<--apply>', output)

    def test_blank_cancelled_and_invalid_commits_do_not_reach_python(self):
        for value, status in (('', 0), ('main', 2), ('$(printf unsafe)', 2), ('a' * 39, 2)):
            output = self.shell('dialog() { printf "%s\\n" ' + shlex.quote(value) + '; }; markdown_docs_action install /fixture', status)
            self.assertNotIn('PYTHON:', output)
        output = self.shell('dialog() { return 255; }; markdown_docs_action update /fixture')
        self.assertNotIn('PYTHON:', output)

    def test_source_confirmation_centers_or_uses_dialog_autosizing(self):
        for size, position, dimensions in (
            ('29 112', '<--begin><9><18>', '<11><76>'),
            ('24 80', '<--begin><6><2>', '<11><76>'),
            ('12 60', '', '<0><0>'),
            ('0 0', '', '<0><0>'),
        ):
            with self.subTest(size=size):
                output = self.shell(
                    'markdown_docs_terminal_size() { echo ' + shlex.quote(size) + '; }; '
                    'dialog() { printf "<%s>" "$@"; return 1; }; '
                    'markdown_docs_confirm_source install ' + 'a' * 40, expected=1)
                self.assertIn('<--clear><--no-shadow><--backtitle>'
                              '<OpenClaw Ultimate Setup | Offline-Handbuch>'
                              + position + '<--defaultno>', output)
                self.assertTrue(output.endswith(dimensions))
                self.assertNotIn('PYTHON:', output)

    def test_all_handbook_widgets_share_backdrop_and_fit_small_terminal(self):
        fixture = (
            'markdown_docs_terminal_size() { echo "24 80"; }; '
            'dialog() { printf "<%s>" "$@" >&2; return 1; }; '
        )
        for action, widget, position, dimensions in (
            ('markdown_docs_menu', '--menu', '2', '<20><76><0><guide>'),
            ('markdown_docs_action guide /fixture', '--textbox', '2', '<20><76>'),
            ('markdown_docs_action install /fixture', '--inputbox', '5', '<13><76>'),
            ('markdown_docs_action serve /fixture', '--inputbox', '6', '<11><76><8765>'),
            ('markdown_docs_action uninstall /fixture', '--yesno', '6', '<12><76>'),
        ):
            with self.subTest(action=action):
                output = self.shell(fixture + action + ' 2>&1')
                self.assertIn('<--backtitle><OpenClaw Ultimate Setup | Offline-Handbuch>'
                              '<--begin><' + position + '><2>', output)
                self.assertIn('<' + widget + '>', output)
                self.assertIn(dimensions, output)
                self.assertNotIn('PYTHON:', output)

    def test_tool_transaction_cancel_is_not_an_install_success(self):
        for action in ('install', 'update'):
            for dialog in ('dialog() { return 1; }; ',
                           'dialog() { return 255; }; ',
                           'dialog() { printf ""; }; ',
                           'dialog() { case "$*" in *--inputbox*) echo ' + 'a' * 40
                           + ' ;; *) return 1 ;; esac; }; '):
                output = self.shell(dialog + 'markdown_docs_action ' + action + ' /fixture 2', expected=2)
                self.assertNotIn('PYTHON:', output)
            self.shell('dialog() { return 127; }; markdown_docs_action ' + action + ' /fixture 2', expected=127)
            output = self.shell('dialog() { case "$*" in *--inputbox*) echo ' + 'a' * 40
                                + ' ;; *) return 0 ;; esac; }; markdown_docs_action ' + action + ' /fixture 2')
            self.assertIn('<--apply>', output)
            self.assertIn('<--source-commit> <' + 'a' * 40 + '>', output)
            self.shell('fixture_python() { return 7; }; dialog() { case "$*" in *--inputbox*) echo '
                       + 'a' * 40 + ' ;; *) return 0 ;; esac; }; markdown_docs_action '
                       + action + ' /fixture 2', expected=7)

    def test_setup_dispatch_requests_only_docs_install_update_dialogs(self):
        setup = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        dispatch = re.search(r'^run_tool_script\(\) \{\n.*?^\}', setup, re.M | re.S).group()
        for tool, action, interactive in (('Markdown_Docs_Server', 'install', True),
                                          ('Markdown_Docs_Server', 'update', True),
                                          ('Markdown_Docs_Server', 'status', False),
                                          ('Markdown_Docs_Server', 'uninstall', False),
                                          ('Other', 'install', False)):
            code = ('declare -A TOOL_SCRIPT_NAMES=([Markdown_Docs_Server]=markdown_docs_server [Other]=other)\n'
                    'INSTALL_DIR=/fixture\nvalidate_tool_source_policy() { return 0; }\n'
                    'run_bash_script() { printf " <%s>" "$@"; }\n' + dispatch + '\n'
                    'run_tool_script ' + tool + ' ' + action)
            output = self.shell(code)
            self.assertEqual('<--interactive>' in output, interactive)
            if action == 'install':
                self.assertIn('run_install_transaction.sh', output)
            self.assertNotIn('<--apply>', output)

    def test_real_wrappers_preserve_plan_and_explicit_interactive_approval(self):
        for action in ('install', 'update'):
            wrapper = 'scripts/tools/markdown_docs_server_' + action + '.sh'
            preamble = 'export GAP_TOOLS_PYTHON_BIN; export -f fixture_python\n'
            output = self.shell(preamble + 'bash ' + wrapper, expected=2)
            self.assertIn('PYTHON:', output)
            self.assertNotIn('<--apply>', output)
            for approved in (True, False):
                dialog = ('dialog() { case "$*" in *--inputbox*) echo ' + 'a' * 40
                          + ' ;; *) return ' + ('0' if approved else '1') + ' ;; esac; };\n'
                          'export -f dialog\n')
                output = self.shell(preamble + dialog + 'bash ' + wrapper + ' --interactive',
                                    expected=0 if approved else 2)
                self.assertEqual('PYTHON:' in output, approved)
                if approved:
                    self.assertIn('<' + action + '> <--source-commit> <' + 'a' * 40 + '> <--apply>', output)

    def test_serve_needs_valid_loopback_port_and_separate_approval(self):
        for value, status in (('', 0), ('80', 2), ('65536', 2), ('1+8764', 2), ('$(printf unsafe)', 2)):
            output = self.shell('dialog() { printf "%s\\n" ' + shlex.quote(value) + '; }; markdown_docs_action serve /fixture', status)
            self.assertNotIn('PYTHON:', output)
        for approved in (True, False):
            dialog = 'dialog() { case "$*" in *--inputbox*) echo 8765 ;; *) return ' + ('0' if approved else '1') + ' ;; esac; }; '
            output = self.shell(dialog + 'markdown_docs_action serve /fixture')
            self.assertEqual('PYTHON:' in output, approved)
            if approved:
                self.assertIn('<serve> <--port> <8765> <--apply>', output)
                self.assertNotIn('0.0.0.0', output)

    def test_uninstall_is_explicit_and_preserves_lifecycle_guard(self):
        self.assertNotIn('PYTHON:', self.shell('dialog() { return 1; }; markdown_docs_action uninstall /fixture'))
        output = self.shell('dialog() { return 0; }; markdown_docs_action uninstall /fixture')
        self.assertIn('<uninstall> <--apply>', output)

    def test_lifecycle_failures_are_not_turned_into_success(self):
        for action in ('plan', 'status', 'doctor', 'uninstall'):
            code = 'fixture_python() { return 7; }; dialog() { return 0; }; markdown_docs_action ' + action + ' /fixture'
            self.shell(code, expected=7)

    def test_dialog_execution_errors_are_not_reported_as_user_cancel(self):
        for action in ('install', 'update', 'serve', 'uninstall', 'guide'):
            self.shell('dialog() { return 127; }; markdown_docs_action ' + action + ' /fixture', expected=127)
        self.shell('dialog() { return 127; }; markdown_docs_menu', expected=127)
        self.shell('dialog() { return 255; }; markdown_docs_action guide /fixture')

    def test_menu_reports_failure_and_recovers_before_user_cancels(self):
        with tempfile.TemporaryDirectory() as directory:
            state = shlex.quote((Path(directory) / 'dialog-called').as_posix())
            code = 'STATE=' + state + '\n'
            code += 'dialog() { if [[ -e "$STATE" ]]; then return 1; fi; printf x > "$STATE"; printf status; };\n'
            code += 'fixture_python() { printf "fixture-failed\\n"; return 7; };\n'
            code += "markdown_docs_menu 2>&1 <<<' '\n"
            output = self.shell(code)
            self.assertEqual(output.count('fixture-failed'), 1)
            self.assertIn('Exitcode 7', output)


class IntegrationContract(unittest.TestCase):
    def test_settings_entry_dispatch_and_default_no_are_present(self):
        setup = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        options = re.search(r'^show_options_menu\(\) \{\n.*?^\}', setup, re.M | re.S).group()
        self.assertIn('"22" "Offline-Handbuch / Markdownserver einrichten und lesen"', options)
        self.assertRegex(options, r'22\)\s+run_bash_script "\$INSTALL_DIR/scripts/markdown_docs_server_menu.sh"')
        script = (ROOT / 'scripts/markdown_docs_server_menu.sh').read_text(encoding='utf-8')
        self.assertEqual(script.count('--defaultno'), 3)
        for forbidden in ('xdg-open', 'Start-Process', 'systemctl', 'nohup', 'eval ', 'curl ', 'docker run', 'wsl.exe'):
            self.assertNotIn(forbidden, script)


if __name__ == '__main__':
    unittest.main()
