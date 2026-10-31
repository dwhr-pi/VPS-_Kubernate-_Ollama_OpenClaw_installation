"""Offline manager fragments: no installers, services, network or real user data."""
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')


def source(path):
    return (ROOT / 'scripts' / path).read_text(encoding='utf-8')


def function(path, name):
    return name + '() {' + source(path).split(name + '() {', 1)[1].split('\n}', 1)[0] + '\n}\n'


@unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash required; never launch WSL')
class ShellManagerContracts(unittest.TestCase):
    def shell(self, code, *args):
        with tempfile.TemporaryDirectory(prefix='shell-manager-') as tmp:
            return subprocess.run(
                [BASH, '--noprofile', '--norc', '-c', 'set -euo pipefail\n' + code,
                 'fixture', *map(str, args)],
                cwd=tmp, text=True, encoding='utf-8', capture_output=True, timeout=60,
                env={k: v for k, v in os.environ.items()
                     if k not in ('BASH_ENV', 'ENV', 'SHELLOPTS', 'BASHOPTS')},
            )

    def check(self, code, *args):
        result = self.shell(code, *args)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result

    def test_model_input_cancellation_is_success_without_actions(self):
        for name in ('install_ollama_model', 'uninstall_ollama_model'):
            for status in (1, 255):
                with self.subTest(name=name, status=status):
                    result = self.check('''
MODEL_TO_INSTALL_FILE=install.choice
MODEL_TO_UNINSTALL_FILE=uninstall.choice
dialog() { return "$1"; }
'''.replace('return "$1"', 'return ' + str(status)) + '''
ollama() { exit 90; }
begin_measurement() { exit 91; }
''' + function('ollama_model_manager.sh', name) + name + '\nprintf survived')
                    self.assertEqual(result.stdout, 'survived')

    def test_selected_model_is_one_quoted_argument(self):
        self.check(function('ollama_model_manager.sh', 'install_ollama_model') + '''
MODEL_TO_INSTALL_FILE=choice
BLUE= GREEN= RED= YELLOW= NC=
dialog() { printf 'model with spaces:tag' >&2; }
begin_measurement() { :; }
end_measurement() { test "$1" = success; }
read() { return 0; }
ollama() { test "$#" = 2 && test "$1" = pull && test "$2" = 'model with spaces:tag'; }
install_ollama_model
''')

    def test_model_metric_slug_does_not_change_the_cli_argument(self):
        definitions = function('ollama_model_manager.sh', 'install_ollama_model')
        definitions += function('ollama_model_manager.sh', 'uninstall_ollama_model')
        self.check(definitions + '''
MODEL_TO_INSTALL_FILE=choice
MODEL_TO_UNINSTALL_FILE=choice
BLUE= GREEN= RED= YELLOW= NC=
dialog() { printf '%s' 'org/model.with space:tag' >&2; }
begin_measurement() { test "$1" = "ollama_model_${action}_org_model-with-space-tag"; }
end_measurement() { test "$1" = success; }
read() { return 0; }
ollama() { test "$#" = 2 && test "$1" = "$expected_verb" && test "$2" = 'org/model.with space:tag'; }
for action in install uninstall; do
  expected_verb=pull
  if [ "$action" = uninstall ]; then expected_verb=rm; fi
  "${action}_ollama_model"
done
''')

    def test_all_prompt_cancellations_exit_cleanly_under_errexit(self):
        text = source('ollama_modelfile_assistant.sh')
        lines = re.findall(r'^prompt_input .* \|\| exit 0$', text, re.MULTILINE)
        self.assertEqual(len(lines), 5)
        for line in lines:
            result = self.check('prompt_input() { return 255; }\n' + line + '\nprintf unsafe')
            self.assertEqual(result.stdout, '')

    def test_menu_guards_handle_cancel_and_missing_choice(self):
        for path, command, choice in (
            ('ollama_model_manager.sh', 'show_ollama_menu', 'OLLAMA_CHOICE_FILE'),
            ('llmops_platform_config_manager.sh', 'show_menu', 'LLMOPS_CHOICE_FILE'),
            ('openclaw_config_manager.sh', 'show_openclaw_config_menu', 'OPENCLAW_CONFIG_CHOICE_FILE'),
        ):
            guard = next(line.strip() for line in source(path).splitlines()
                         if line.strip().startswith('if ! ' + command + ' ||'))
            for status, exists, expected in ((1, True, 'cancel'), (0, False, 'cancel'), (0, True, 'ok')):
                code = choice + '=choice\n' + ('touch choice\n' if exists else '')
                code += command + '() { return ' + str(status) + '; }\n'
                result = self.check(code + guard + '\nprintf cancel\nelse\nprintf ok\nfi')
                self.assertEqual(result.stdout, expected)

    def test_form_password_and_language_cancellation_cleanup(self):
        for path, variable in (('mail_config_manager.sh', 'tmp_form'),
                               ('mail_config_manager.sh', 'tmp_pass'),
                               ('lang/common.sh', '/tmp/setup_language_choice')):
            text = source(path)
            pattern = r'  if ! dialog --clear.*?' + re.escape(
                '2>"$' + variable + '"' if not variable.startswith('/') else '2>' + variable)
            matches = list(re.finditer(pattern, text, re.DOTALL))
            self.assertTrue(matches, variable)
            block = matches[0].group(0)
            # Select only the dialog owning this redirect, not previous dialogs.
            block = '  if ! dialog --clear' + block.rsplit('  if ! dialog --clear', 1)[1]
            block = block.replace('2>/tmp/setup_language_choice', '2>language.choice')
            defaults = '\n'.join(name + '=fixture' for name in set(re.findall(r'\$\{?([A-Z_]+)', block)))
            code = defaults + '\n' + variable + '=choice\n' if not variable.startswith('/') else defaults + '\n'
            code += 'dialog() { return 255; }\nscenario() {\n' + block
            code += '\nthen\n' + ('rm -f "$' + variable + '"\nreturn 0' if not variable.startswith('/') else 'return 1')
            code += '\nfi\nprintf unsafe\n}\n'
            code += 'scenario' if not variable.startswith('/') else 'if scenario; then exit 90; fi'
            result = self.check(code)
            self.assertEqual(result.stdout, '')

    def test_latest_log_handles_spaces_newlines_and_no_matches(self):
        code = function('huginn_status.sh', 'latest_huginn_log_matching')
        code += function('huginn_status.sh', 'detect_latest_huginn_log')
        code += function('huginn_status.sh', 'detect_latest_any_huginn_log')
        self.check(code + '''
USER_WORKSPACE_DIR="$PWD/work space"
test -z "$(detect_latest_huginn_log)"
mkdir -p "$USER_WORKSPACE_DIR/install_logs"
old="$USER_WORKSPACE_DIR/install_logs/old tool_install_Huginn.log"
new="$USER_WORKSPACE_DIR/install_logs/"$'new\nentry_tool_install_Huginn.log'
touch -t 202001010000 "$old"
touch -t 202101010000 "$new"
test "$(detect_latest_huginn_log)" = "$new"
test "$(detect_latest_any_huginn_log)" = "$new"
''')

    def test_nameref_updates_caller_map(self):
        self.check(function('helpers/status_tracking.sh', 'load_installed_map') + '''
printf '"Tool A"\r\nTool_B' >status
declare -A installed=()
load_installed_map status installed
test "${installed['Tool A']}" = 1
test "${installed[Tool_B]}" = 1
test "${#installed[@]}" = 2
''')

    def test_allowlisted_dynamic_environment_export(self):
        text = source('backup_stateful_services.sh')
        assignment = next(line.strip() for line in text.splitlines() if line.strip().startswith('printf -v "$key"'))
        export = next(line.strip() for line in text.splitlines() if line.strip().startswith('export "${key?}"'))
        self.check('key=RESTIC_REPOSITORY\nvalue="fixture with spaces"\n' + assignment + '\n' + export
                   + '\nbash --noprofile --norc -c \'test "$RESTIC_REPOSITORY" = "fixture with spaces"\'')

    def test_shared_paths_and_log_result_remain_public(self):
        assignment = next(line for line in source('lib/common.sh').splitlines() if line.startswith('REPO_ROOT='))
        self.check('mkdir -p repo/scripts/lib\nSCRIPT_LIB_DIR="$PWD/repo/scripts/lib"\n'
                   + assignment + '\ntest "$REPO_ROOT" = "$PWD/repo"')
        self.check(function('helpers/operation_log.sh', 'start_operation_log') + '''
USER_INSTALL_LOG_DIR=blocked/child
touch blocked
LAST_OPERATION_LOG_FILE=old
ACTIVE_OPERATION_LOG_FILE=old
if start_operation_log test; then exit 90; fi
test -z "$LAST_OPERATION_LOG_FILE"
test -z "$ACTIVE_OPERATION_LOG_FILE"
''')

    def test_build_approval_rejects_regular_file_without_truncation(self):
        self.check(function('base_install.sh', 'handle_ignored_build_scripts') + '''
YELLOW= RED= GREEN= NC=
TTY_DEVICE=not-a-terminal
printf sentinel >"$TTY_DEVICE"
prompt_yes_no() { return 0; }
pnpm() { if [ "$1" = ignored-builds ]; then printf ignored; else exit 90; fi; }
if handle_ignored_build_scripts; then exit 91; fi
test "$(cat "$TTY_DEVICE")" = sentinel
''')


if __name__ == '__main__':
    unittest.main()
