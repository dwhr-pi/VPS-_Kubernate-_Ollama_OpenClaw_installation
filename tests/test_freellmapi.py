"""Offline source-install tests: mocked Git/npm/Node, temporary data, no WSL/network."""
import importlib.util
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
BASH = Path('C:/Program Files/Git/bin/bash.exe') if os.name == 'nt' else shutil.which('bash')
spec = importlib.util.spec_from_file_location('freellmapi_run', ROOT / 'scripts/tools/freellmapi_run.py')
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)


def bash_path(path):
    value = str(path).replace('\\', '/')
    return '/' + value[0].lower() + value[2:] if os.name == 'nt' else value


@unittest.skipUnless(BASH and Path(BASH).exists(), 'Git Bash/bash unavailable')
class FreeLLMAPISource(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.workspace = Path(self.temp.name) / 'workspace'
        self.base = self.workspace / 'tools/freellmapi'

    def run_shell(self, script):
        prefix = ('source scripts/tools/helpers/freellmapi_common.sh\n'
                  f'export OPENCLAW_USER_DATA_DIR="{bash_path(self.workspace)}"\n')
        return subprocess.run([str(BASH), '--noprofile', '--norc', '-c', prefix + script],
                              cwd=ROOT, capture_output=True, text=True, timeout=120)

    def mocks(self):
        return r'''
freellmapi_require_user() { :; }
freellmapi_require_runtime() { :; }
freellmapi_port_free() { :; }
freellmapi_resources() { :; }
require_disk_mb() { :; }
require_ram_mb() { :; }
flock() { :; }
docker() { echo FORBIDDEN_DOCKER; return 99; }
node() { echo NODE_SMOKE; }
git() {
    case "$*" in
        *clone*)
            echo CLONE
            [[ "${FAIL_CLONE:-0}" != 1 ]] || return 1
            mkdir -p "$FREELLMAPI_SOURCE_DIR/.git" "$FREELLMAPI_SOURCE_DIR/server" "$FREELLMAPI_SOURCE_DIR/client"
            printf '{}' > "$FREELLMAPI_SOURCE_DIR/package-lock.json"
            printf '{}' > "$FREELLMAPI_SOURCE_DIR/server/package.json"
            printf '{}' > "$FREELLMAPI_SOURCE_DIR/client/package.json" ;;
        *'remote get-url origin') printf '%s\n' "$FREELLMAPI_SOURCE_URL" ;;
        *'rev-parse HEAD') printf '%s\n' "${MOCK_COMMIT:-$FREELLMAPI_SOURCE_COMMIT}" ;;
        *'status --porcelain'*)
            if [[ "${DIRTY:-0}" == 1 ]]; then echo ' M README.md'; fi ;;
        *) return 99 ;;
    esac
}
npm() {
    echo "NPM $*"
    [[ "${FAIL_NPM:-0}" != 1 ]] || return 1
    if [[ "$*" == 'run build' ]]; then
        mkdir -p server/dist client/dist
        printf '// synthetic fixture' > server/dist/index.js
        printf '<!-- synthetic fixture -->' > client/dist/index.html
    fi
}
'''

    def test_dry_run_never_writes(self):
        result = self.run_shell('freellmapi_main --dry-run')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('127.0.0.1:3011', result.stdout)
        self.assertFalse(self.workspace.exists())

    def test_invalid_port_rejected(self):
        result = self.run_shell('export FREELLMAPI_HOST_PORT=65536; freellmapi_main --dry-run')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.workspace.exists())

    def test_source_install_idempotent_no_start_or_env(self):
        result = self.run_shell(self.mocks() + 'freellmapi_main install\nfreellmapi_main install')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.count('CLONE'), 1)
        self.assertEqual(result.stdout.count('NPM ci '), 1)
        self.assertNotIn('FORBIDDEN_DOCKER', result.stdout)
        self.assertTrue((self.base / 'source-built').is_file())
        self.assertFalse((self.base / 'native-data').exists())
        self.assertFalse((self.workspace / 'env').exists())
        logs = list((self.workspace / 'install_logs').glob('*.log'))
        self.assertEqual(len(logs), 1)
        self.assertIn('Disk-vorher-KiB', logs[0].read_text())

    def test_clone_failure_stops_before_npm(self):
        result = self.run_shell(self.mocks() + 'export FAIL_CLONE=1; freellmapi_main install')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('NPM ', result.stdout)
        self.assertFalse((self.base / 'source-built').exists())

    def test_commit_mismatch_stops_before_npm(self):
        result = self.run_shell(self.mocks() + 'export MOCK_COMMIT=wrong; freellmapi_main install')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('NPM ', result.stdout)

    def test_npm_failure_does_not_mark_built(self):
        result = self.run_shell(self.mocks() + 'export FAIL_NPM=1; freellmapi_main install')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.base / 'source-built').exists())

    def test_smoke_failure_does_not_mark_built(self):
        result = self.run_shell(self.mocks() + 'node() { return 1; }; freellmapi_main install')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.base / 'source-built').exists())

    def test_dirty_source_blocks_update(self):
        result = self.run_shell(self.mocks() + 'freellmapi_main install\nexport DIRTY=1\nfreellmapi_main update')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout.count('NPM ci '), 1)

    def test_port_conflict_blocks_build(self):
        result = self.run_shell(self.mocks() + 'freellmapi_port_free() { return 1; }; freellmapi_main install')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('CLONE', result.stdout)

    def test_lock_conflict_blocks_clone(self):
        result = self.run_shell(self.mocks() + 'flock() { return 1; }; freellmapi_main install')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('CLONE', result.stdout)

    def test_legacy_data_and_env_untouched(self):
        data = self.base / 'data'
        data.mkdir(parents=True)
        (data / 'freeapi.db').write_bytes(b'synthetic-old-db')
        (self.base / 'compose.yml').write_text('# existing personal stack')
        result = self.run_shell(self.mocks() + 'freellmapi_main install')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((data / 'freeapi.db').read_bytes(), b'synthetic-old-db')
        self.assertEqual((self.base / 'compose.yml').read_text(), '# existing personal stack')

    def test_uninstall_keeps_code_and_data(self):
        data = self.base / 'native-data'
        data.mkdir(parents=True)
        (data / 'freeapi.db').write_bytes(b'synthetic-native-db')
        result = self.run_shell(self.mocks() + 'freellmapi_main install\nfreellmapi_main uninstall')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((self.base / 'source').exists())
        self.assertEqual(len(list(self.base.glob('source.disabled.*'))), 1)
        self.assertEqual((data / 'freeapi.db').read_bytes(), b'synthetic-native-db')

    def test_start_requires_separate_network_consent(self):
        result = self.run_shell(self.mocks() + 'unset FREELLMAPI_ENABLE_NETWORK; freellmapi_main start')
        self.assertEqual(result.returncode, 2)
        self.assertFalse(self.workspace.exists())


class FreeLLMAPIConfig(unittest.TestCase):
    def test_registry_uses_source_not_docker(self):
        entries = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        entry, = [t for t in entries if t['id'] == 'freellmapi']
        self.assertEqual(entry['install_mode'], 'source')
        self.assertEqual(entry['check_type'], 'path')
        self.assertNotIn('ENABLE_DOCKER', entry['security_note'])
        helper = (ROOT / 'scripts/tools/helpers/freellmapi_common.sh').read_text(encoding='utf-8')
        for forbidden in ('run_docker_compose_tool', 'freellmapi_compose', 'docker_compose_tool_common.sh'):
            self.assertNotIn(forbidden, helper)
        for field in ('install_script', 'uninstall_script', 'update_script', 'doctor_script', 'doc'):
            self.assertTrue((ROOT / entry[field]).is_file())

    def test_invalid_env_never_discloses_value(self):
        with tempfile.TemporaryDirectory() as temp:
            env = Path(temp) / '.env'
            env.write_text('ENCRYPTION_KEY=invalid-test-fixture\n')
            env.chmod(0o600)
            result = subprocess.run([sys.executable, str(ROOT / 'scripts/tools/freellmapi_run.py'),
                                     '--check-env', '--env-file', str(env)],
                                    capture_output=True, text=True, timeout=10)
        self.assertEqual(result.returncode, 1)
        self.assertNotIn('invalid-test-fixture', result.stdout + result.stderr)

    def test_env_is_not_shell_code_and_rejects_extra_keys(self):
        with tempfile.TemporaryDirectory() as temp:
            env = Path(temp) / '.env'
            for suffix in ('NODE_OPTIONS=--require bad\n', 'ENCRYPTION_KEY=duplicate\n',
                           'HOST=0.0.0.0\n', '$(touch NEVER)\n'):
                env.write_text('ENCRYPTION_KEY=' + 'a' * 64 + '\n' + suffix)
                env.chmod(0o600)
                with self.assertRaises(ValueError):
                    runner.read_env(env)

    def test_runtime_overrides_external_environment(self):
        from unittest.mock import patch
        with patch.dict(os.environ, {'NODE_OPTIONS': '--require bad', 'HOST': '0.0.0.0',
                                     'PORT': '9999', 'FREEAPI_CONFIG_JSON': 'private'}):
            env = runner.runtime_env({'ENCRYPTION_KEY': 'a' * 64},
                                     Path('/source'), Path('/private-data'), 3011)
        self.assertEqual(env['HOST'], '127.0.0.1')
        self.assertEqual(env['PORT'], '3011')
        self.assertEqual(env['NODE_ENV'], 'production')
        self.assertNotIn('NODE_OPTIONS', env)
        self.assertNotIn('FREEAPI_CONFIG_JSON', env)

    def test_documentation_local_links(self):
        doc = ROOT / 'docs/tools/freellmapi.md'
        for link in re.findall(r'\]\(([^)]+)\)', doc.read_text(encoding='utf-8')):
            if '://' not in link and not link.startswith('#'):
                self.assertTrue((doc.parent / link.split('#')[0]).exists(), link)


if __name__ == '__main__':
    unittest.main()
