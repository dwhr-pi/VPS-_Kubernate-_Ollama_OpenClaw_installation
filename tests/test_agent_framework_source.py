"""Offline source-installer tests; no downloads, pip installs, agents or WSL."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = Path('C:/Program Files/Git/bin/bash.exe') if os.name == 'nt' else shutil.which('bash')
HELPER = 'scripts/tools/helpers/agent_framework_common.sh'


class SourceContract(unittest.TestCase):
    def test_pinned_core_only(self):
        text = (ROOT / HELPER).read_text(encoding='utf-8')
        tool = next(t for t in json.loads((ROOT / 'config/tools.yml').read_text())['tools']
                    if t['id'] == 'agent_framework')
        self.assertIn('AF_COMMIT=' + tool['source_commit'], text)
        self.assertIn('"$AF_SOURCE/python/packages/core"', text)
        self.assertIn('--index-url https://pypi.org/simple', text)
        self.assertNotIn('docker compose', text)
        self.assertNotIn('pip install agent-framework', text)
        self.assertFalse(tool['auto_install'])

    def test_guards_and_lifecycle(self):
        text = (ROOT / HELPER).read_text(encoding='utf-8')
        for token in ('flock -n 9', 'require_ram_mb 2048', 'require_disk_mb 2048',
                      'REQUIRE_WINDOWS_HOST_FREE_MB=10240', 'GIT_TERMINAL_PROMPT=0',
                      'af_source_ok', '--repair', 'pip --isolated check'):
            self.assertIn(token, text)
        self.assertNotIn('rm -rf', text)
        self.assertNotIn('agent.run(', text)


@unittest.skipUnless(BASH and Path(BASH).exists(), 'Git Bash/bash unavailable')
class OfflineBehavior(unittest.TestCase):
    def run_bash(self, code):
        with tempfile.TemporaryDirectory() as temp:
            env = dict(os.environ, HOME=temp, OPENCLAW_USER_DATA_DIR='',
                       PIP_NO_INDEX='1', GIT_TERMINAL_PROMPT='0')
            return subprocess.run([str(BASH), '--noprofile', '--norc', '-c', code],
                                  cwd=ROOT, env=env, capture_output=True, text=True, timeout=40)

    def test_dry_run_no_mutation_or_tools(self):
        result = self.run_bash('''
git() { return 91; }; python3() { return 92; }
export -f git python3
bash scripts/tools/agent_framework_install.sh --dry-run
test ! -e "$HOME/.openclaw_ultimate_user_data"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(json.loads(result.stdout)['docker'])

    def test_status_missing_is_offline(self):
        result = self.run_bash('''
bash scripts/tools/agent_framework_status.sh
test ! -e "$HOME/.openclaw_ultimate_user_data"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(json.loads(result.stdout)['installed'])

    def test_doctor_missing_fails_without_creation(self):
        result = self.run_bash('''
bash scripts/tools/agent_framework_doctor.sh
rc=$?
test ! -e "$HOME/.openclaw_ultimate_user_data" || exit 99
exit "$rc"
''')
        self.assertEqual(result.returncode, 1, result.stderr)

    def test_unknown_start_rejected(self):
        result = self.run_bash('bash scripts/tools/agent_framework_install.sh start')
        self.assertEqual(result.returncode, 2, result.stderr)

    def test_ready_python_never_uses_sudo(self):
        result = self.run_bash('''
source scripts/tools/helpers/agent_framework_common.sh
af_venv_ready() { return 0; }
sudo() { exit 99; }
af_prepare_venv /mock/python
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_missing_venv_repairs_versioned_package_and_rechecks(self):
        result = self.run_bash('''
source scripts/tools/helpers/agent_framework_common.sh
af_venv_ready() { test -f "$HOME/repaired"; }
af_venv_package() { echo python3.12-venv; }
sudo() {
    printf '%s\\n' "$*" >> "$HOME/apt-calls"
    case "$*" in *'install -y --no-install-recommends python3.12-venv') touch "$HOME/repaired" ;; esac
    return 0
}
af_prepare_venv /mock/python
grep -q '^ -v$\\|^-v$' "$HOME/apt-calls"
grep -q 'apt-get.*update' "$HOME/apt-calls"
grep -q 'install -y --no-install-recommends python3.12-venv' "$HOME/apt-calls"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_repair_opt_out_and_custom_python_never_use_sudo(self):
        for policy in ('AGENT_FRAMEWORK_AUTO_VENV=0', 'af_venv_package() { return 1; }'):
            with self.subTest(policy=policy):
                result = self.run_bash('''
source scripts/tools/helpers/agent_framework_common.sh
af_venv_ready() { return 1; }
sudo() { exit 99; }
''' + policy + '\naf_prepare_venv /mock/python\n')
                self.assertEqual(result.returncode, 1, result.stderr)

    def test_sudo_failure_stops_before_apt(self):
        result = self.run_bash('''
source scripts/tools/helpers/agent_framework_common.sh
af_venv_ready() { return 1; }
af_venv_package() { echo python3.12-venv; }
sudo() { [[ "$1" == -v ]] && return 1; exit 99; }
af_prepare_venv /mock/python
''')
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn('sudo-Freigabe fehlgeschlagen', result.stderr)

    def test_failed_apt_or_failed_recheck_cannot_continue(self):
        for rc in (0, 42):
            result = self.run_bash('''
source scripts/tools/helpers/agent_framework_common.sh
af_venv_ready() { return 1; }
af_venv_package() { echo python3.12-venv; }
sudo() { [[ "$1" == -v ]] && return 0; return ''' + str(rc) + '''; }
af_prepare_venv /mock/python
''')
            self.assertNotEqual(result.returncode, 0, result.stderr)

    def test_bootstrap_before_clone_and_not_in_read_only_actions(self):
        text = (ROOT / HELPER).read_text(encoding='utf-8')
        main = text.split('agent_framework_main() (', 1)[1]
        self.assertLess(main.index('af_prepare_venv "$python"'), main.index('af_install_source "$python"'))
        self.assertGreater(main.index('af_prepare_venv "$python"'), main.index('af_probe >/dev/null 2>&1'))
        self.assertIn('dpkg-query -S "$executable"', text)
        self.assertIn('sys.prefix == sys.base_prefix', text)
        self.assertNotIn('--clear', text)

    def test_unsafe_paths_rejected(self):
        result = self.run_bash('OPENCLAW_USER_DATA_DIR=/ bash scripts/tools/agent_framework_install.sh --dry-run')
        self.assertNotEqual(result.returncode, 0)

    def test_foreign_source_not_overwritten(self):
        result = self.run_bash('''
source scripts/tools/helpers/agent_framework_common.sh
af_paths
mkdir -p "$AF_SOURCE"
printf keep > "$AF_SOURCE/own-file"
if af_install_source /no/python; then exit 99; fi
test "$(cat "$AF_SOURCE/own-file")" = keep
test ! -e "$AF_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_mock_success_marks_only_after_checks(self):
        result = self.run_bash('''
source scripts/tools/helpers/agent_framework_common.sh
af_paths
mkdir -p "$AF_SOURCE/python/packages/core" "$AF_VENV/bin"
touch "$AF_SOURCE/python/packages/core/pyproject.toml" "$AF_VENV/pyvenv.cfg"
af_source_ok() { return 0; }
fake_python() { return 0; }
printf '#!/usr/bin/env bash\nprintf "%%s\\n" "$*" >> "$HOME/pip-calls"\nexit 0\n' > "$AF_VENV/bin/python"
chmod +x "$AF_VENV/bin/python"
af_install_source fake_python
test "$(cat "$AF_MARKER")" = "$AF_COMMIT"
grep -q 'python/packages/core' "$HOME/pip-calls"
grep -q 'pip --isolated check' "$HOME/pip-calls"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_mock_failure_leaves_no_success_marker(self):
        result = self.run_bash('''
source scripts/tools/helpers/agent_framework_common.sh
af_paths
mkdir -p "$AF_SOURCE/python/packages/core" "$AF_VENV/bin"
touch "$AF_SOURCE/python/packages/core/pyproject.toml" "$AF_VENV/pyvenv.cfg"
printf old > "$AF_MARKER"
af_source_ok() { return 0; }
fake_python() { return 0; }
printf '#!/usr/bin/env bash\nexit 42\n' > "$AF_VENV/bin/python"
chmod +x "$AF_VENV/bin/python"
set +e
(set -e; af_install_source fake_python)
rc=$?
test "$rc" = 42 && test ! -e "$AF_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
