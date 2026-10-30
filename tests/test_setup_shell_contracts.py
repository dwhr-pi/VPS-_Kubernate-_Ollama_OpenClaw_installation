"""Exercise extracted setup functions only; never start the installer or services."""
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


@unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash required; never start WSL')
class SetupShellContracts(unittest.TestCase):
    def setUp(self):
        self.source = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')

    def function(self, name):
        found = re.search(r'^' + re.escape(name) + r'\(\) \{\n.*?^\}', self.source, re.M | re.S)
        self.assertIsNotNone(found, name)
        return found.group()

    def shell(self, text, **extra):
        env = {key: value for key, value in os.environ.items()
               if key not in ('BASH_ENV', 'ENV', 'SHELLOPTS', 'BASHOPTS')}
        env.update(extra)
        result = subprocess.run(
            [BASH, '--noprofile', '--norc', '-c', 'set -euo pipefail\n' + text],
            cwd=ROOT, env=env, capture_output=True, timeout=30,
        )
        self.assertEqual(result.returncode, 0, result.stderr.decode('utf-8', errors='replace'))
        return result.stdout.decode('utf-8')

    def test_specific_disk_reserves_survive_fallback_deduplication(self):
        expected = {
            'Grafana': 32768, 'Nextcloud': 24576, 'Open_WebUI': 24576,
            'Qdrant': 24576, 'Meilisearch': 24576, 'Prometheus': 16384,
            'Loki': 16384, 'Ollama': 8192, 'ChromaDB': 8192,
            'Docker': 8192, 'K3s': 8192, 'Kubernetes': 8192,
            'Paperless_NGX': 8192, 'UnknownFixture': 4096,
        }
        script = self.function('get_tool_install_fallback_min_free_mb') + '\n'
        for name in expected:
            script += ('printf "%s=" ' + shlex.quote(name) + '\n'
                       + 'get_tool_install_fallback_min_free_mb ' + shlex.quote(name) + '\n'
                       + 'printf "\\n"\n')
        actual = dict(line.split('=', 1) for line in self.shell(script).splitlines())
        self.assertEqual(actual, {key: str(value) for key, value in expected.items()})

    def test_status_loader_writes_the_callers_map(self):
        with tempfile.TemporaryDirectory() as directory:
            status = Path(directory) / 'status.txt'
            status.write_bytes(b'"Ollama"\r\n\nOpenClaw\n')
            result = self.shell(self.function('load_installed_map') + r'''
declare -A installed
load_installed_map "$STATUS" installed
[[ "${installed[Ollama]}" == 1 && "${installed[OpenClaw]}" == 1 && ${#installed[@]} == 2 ]]
''', STATUS=status.as_posix())
            self.assertEqual(result, '')

    def test_both_profile_menu_variants_cancel_before_read_or_action(self):
        with tempfile.TemporaryDirectory() as directory:
            choice = (Path(directory) / 'choice').as_posix()
            function = self.function('show_profile_block_detail_menu').replace(
                '/tmp/profile_block_choice', '"$CHOICE"')
            script = function + r'''
APP_TITLE=fixture
declare -A PROFILE_SPECIAL_TOOLS PROFILE_SPECIAL_LABELS
dialog() { return "$DIALOG_STATUS"; }
cat() { printf 'Unexpected choice read' >&2; return 99; }
for special in 0 1; do
  PROFILE_SPECIAL_TOOLS[fixture]=''
  [[ "$special" == 0 ]] || PROFILE_SPECIAL_TOOLS[fixture]=Example
  for DIALOG_STATUS in 1 255; do
    show_profile_block_detail_menu fixture
  done
done
'''
            self.assertEqual(self.shell(script, CHOICE=choice), '')

    def test_profile_markers_change_only_after_successful_child(self):
        script = self.function('install_profile') + '\n' + self.function('uninstall_profile') + r'''
INSTALL_DIR=/fixture PROFILE_STATUS_FILE=/fixture/status BLUE='' GREEN='' RED='' NC=''
show_profile_action_intro() { :; }
begin_operation_measurement() { :; }
handle_manual_profile_post_action() { :; }
run_bash_script() { return "$OP_STATUS"; }
append_unique_line() { events+='added;'; }
remove_exact_line() { events+='removed;'; }
end_operation_measurement() { events+="$1"; }
for OP_STATUS in 0 17; do
  events=''
  install_profile fixture >/dev/null
  if [[ "$OP_STATUS" == 0 ]]; then [[ "$events" == 'added;success' ]]; else [[ "$events" == failed ]]; fi
  events=''
  uninstall_profile fixture >/dev/null
  if [[ "$OP_STATUS" == 0 ]]; then [[ "$events" == 'removed;success' ]]; else [[ "$events" == failed ]]; fi
done
'''
        self.assertEqual(self.shell(script), '')

    def test_loading_formats_allow_only_expected_string_slots(self):
        script = self.function('loading_translation_format_ok') + '\n'
        for path in sorted((ROOT / 'scripts/lang').glob('*.sh')):
            for line in path.read_text(encoding='utf-8').splitlines():
                if line.startswith('TXT_LOADING_NOTICE_BODY='):
                    script += line + '\nloading_translation_format_ok "$TXT_LOADING_NOTICE_BODY" 2\n'
                elif line.startswith('TXT_LOADING_GAUGE_TITLE='):
                    script += line + '\nloading_translation_format_ok "$TXT_LOADING_GAUGE_TITLE" 1\n'
        script += r'''
for format in '%n' '%b' '%s%s%s' '%s%s%q' '%%s' '%2$s'; do
  if loading_translation_format_ok "$format" 2; then exit 99; fi
done
'''
        self.assertEqual(self.shell(script), '')

    def test_loading_notice_keeps_arguments_literal(self):
        script = self.function('loading_translation_format_ok') + '\n' + self.function('show_management_loading_notice') + r'''
load_setup_language() { :; }
is_preference_enabled() { return 0; }
APP_TITLE=fixture TXT_YES_LABEL=Yes TXT_NO_LABEL=No TXT_LOADING_NOTICE_TITLE=fixture
TXT_LOADING_NOTICE_BODY='View %s\nDetails %s'
TXT_LOADING_GAUGE_TITLE='LOAD %s'
dialog() {
  while (($#)); do
    if [[ "$1" == --yesno ]]; then printf '%s' "$2"; return 1; fi
    shift
  done
  return 99
}
if show_management_loading_notice 'literal %n\path' 'data %s\z'; then exit 99; fi
'''
        self.assertEqual(self.shell(script), 'View literal %n\\path\nDetails data %s\\z')

    def test_bootstrap_terminal_redirection_does_not_truncate(self):
        source = (ROOT / 'install.sh').read_text(encoding='utf-8')
        command = next(line for line in source.splitlines() if line.startswith('bash ./setup_ultimate.sh '))
        self.assertIn('<>"$TTY_DEVICE" >&0', command)
        with tempfile.TemporaryDirectory() as directory:
            device = Path(directory) / 'mock-terminal'
            device.write_bytes(b'fixture-not-to-be-truncated')
            self.shell('bash() { :; }\n' + command, TTY_DEVICE=device.as_posix())
            self.assertEqual(device.read_bytes(), b'fixture-not-to-be-truncated')


if __name__ == '__main__':
    unittest.main()
