"""Offline tests: temporary files and mocked Docker only; never touch WSL."""
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
BASH = (Path('C:/Program Files/Git/bin/bash.exe') if os.name == 'nt'
        else shutil.which('bash'))
HELPER = ROOT / 'scripts/tools/helpers/freellmapi_common.sh'


def bash_path(path):
    value = str(path).replace('\\', '/')
    return '/' + value[0].lower() + value[2:] if os.name == 'nt' else value


@unittest.skipUnless(BASH and Path(BASH).exists(), 'Git Bash/bash unavailable')
class FreeLLMAPI(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.workspace = Path(self.temp.name) / 'workspace'

    def run_shell(self, script):
        prefix = (
            'source scripts/tools/helpers/freellmapi_common.sh\n'
            f'export OPENCLAW_USER_DATA_DIR="{bash_path(self.workspace)}"\n'
        )
        return subprocess.run([str(BASH), '--noprofile', '--norc', '-c', prefix + script],
                              cwd=ROOT, capture_output=True, text=True, timeout=30)

    def mocks(self):
        return '''
docker() { :; }
python3() { :; }
freellmapi_validate_env() { :; }
require_disk_mb() { :; }
require_ram_mb() { :; }
run_docker_compose_tool() { :; }
init_tool_tracking() { echo TRACK; }
mark_current_tool_installed() { echo INSTALLED; }
mark_current_tool_removed() { echo REMOVED; }
sleep() { :; }
curl() { :; }
freellmapi_compose() { echo "COMPOSE $*"; }
export FREELLMAPI_ENABLE_DOCKER=1
'''

    def test_dry_run_has_no_workspace_side_effects(self):
        result = self.run_shell('freellmapi_main --dry-run')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('127.0.0.1:3011', result.stdout)
        self.assertFalse(self.workspace.exists())

    def test_install_requires_opt_in(self):
        result = self.run_shell('unset FREELLMAPI_ENABLE_DOCKER; freellmapi_main install')
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertFalse(self.workspace.exists())

    def test_invalid_port_rejected(self):
        result = self.run_shell('export FREELLMAPI_HOST_PORT=65536; freellmapi_main --dry-run')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.workspace.exists())

    def test_install_success_and_repeat(self):
        result = self.run_shell(self.mocks() + 'freellmapi_main install\nfreellmapi_main install')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.count('INSTALLED'), 2)
        self.assertIn('COMPOSE --parallel 1 pull', result.stdout)

    def test_pull_failure_never_starts_or_marks(self):
        result = self.run_shell(self.mocks() + '''
freellmapi_compose() { echo "COMPOSE $*"; [[ "$*" != '--parallel 1 pull' ]]; }
freellmapi_main install
''')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('COMPOSE up', result.stdout)
        self.assertNotIn('INSTALLED', result.stdout)

    def test_failed_health_does_not_mark_installed(self):
        result = self.run_shell(self.mocks() + 'curl() { return 1; }; freellmapi_main install')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('INSTALLED', result.stdout)

    def test_changed_compose_preserved(self):
        compose = self.workspace / 'tools/freellmapi/compose.yml'
        compose.parent.mkdir(parents=True)
        compose.write_text('# personal changes', encoding='utf-8')
        result = self.run_shell(self.mocks() + 'freellmapi_main update')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(compose.read_text(), '# personal changes')
        self.assertNotIn('COMPOSE up', result.stdout)

    def test_uninstall_preserves_data(self):
        compose = self.workspace / 'tools/freellmapi/compose.yml'
        compose.parent.mkdir(parents=True)
        compose.write_text('# fixture', encoding='utf-8')
        data = compose.parent / 'data'
        data.mkdir()
        result = self.run_shell(self.mocks() + 'freellmapi_main uninstall')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('COMPOSE down\n', result.stdout)
        self.assertNotIn('down -v', result.stdout)
        self.assertTrue(data.exists())


class FreeLLMAPIConfig(unittest.TestCase):
    def test_registry_paths_and_safety(self):
        entries = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        entry, = [tool for tool in entries if tool['id'] == 'freellmapi']
        self.assertEqual(entry['status'], 'experimental')
        menu = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        self.assertIn('TOOL_KEYS+=("FreeLLMAPI")', menu)
        self.assertIn('TOOL_SCRIPT_NAMES["FreeLLMAPI"]="freellmapi"', menu)
        tracking = (ROOT / 'scripts/helpers/status_tracking.sh').read_text(encoding='utf-8')
        self.assertIn('TOOL_KEYS+=("FreeLLMAPI")', tracking)
        for field in ('install_script', 'uninstall_script', 'update_script', 'doctor_script', 'doc'):
            self.assertTrue((ROOT / entry[field]).is_file())
        ports = json.loads((ROOT / 'config/ports.yml').read_text())['ports']
        self.assertEqual([port['port'] for port in ports if port['service'] == 'freellmapi'], [3011])
        compose = (ROOT / 'stacks/freellmapi/compose.yml').read_text()
        self.assertIn('127.0.0.1:${FREELLMAPI_HOST_PORT:-3011}:3001', compose)
        self.assertIn('freellmapi:v0.14.2', compose)
        for forbidden in ('docker.sock', 'watchtower', 'privileged:', 'network_mode: host', ':latest'):
            self.assertNotIn(forbidden, compose)

    def test_invalid_env_does_not_disclose_value(self):
        source = HELPER.read_text()
        validator = source.split("<<'PY'\n", 1)[1].split('\nPY', 1)[0]
        with tempfile.TemporaryDirectory() as temp:
            env = Path(temp) / '.env'
            env.write_text('ENCRYPTION_KEY=invalid-test-fixture\n')
            result = subprocess.run([sys.executable, '-c', validator, str(env)],
                                    capture_output=True, text=True, timeout=10)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('invalid-test-fixture', result.stdout + result.stderr)

    def test_documentation_local_links(self):
        doc = ROOT / 'docs/tools/freellmapi.md'
        for link in re.findall(r'\]\(([^)]+)\)', doc.read_text()):
            if '://' not in link and not link.startswith('#'):
                self.assertTrue((doc.parent / link.split('#')[0]).exists(), link)


if __name__ == '__main__':
    unittest.main()
