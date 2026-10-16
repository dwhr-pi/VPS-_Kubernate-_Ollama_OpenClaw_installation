"""Offline source-installer contracts; no upstream Git/npm/agent execution."""
import json
from pathlib import Path
import re
import os
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class QwenCodeTests(unittest.TestCase):
    def test_registry_and_menu(self):
        tools = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        tool, = [t for t in tools if t['id'] == 'qwen_code']
        self.assertEqual(tool['install_mode'], 'source')
        self.assertEqual(tool['status'], 'experimental')
        self.assertFalse(tool['auto_install'])
        self.assertEqual(tool['resource_class'], 'heavy')
        self.assertEqual(tool['ports'], [])
        self.assertTrue(tool['check_value'].endswith('/source-built'))
        for field in ('install_script', 'update_script', 'uninstall_script', 'doctor_script', 'doc'):
            self.assertTrue((ROOT / tool[field]).is_file())
            self.assertNotIn('hybrid_media_candidate', tool[field])
        self.assertIn('TOOL_SCRIPT_NAMES["Qwen_Code"]="qwen_code"',
                      (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8'))

    def test_build_contract(self):
        helper = (ROOT / 'scripts/tools/helpers/qwen_code_common.sh').read_text()
        for value in ('c1a8218f38203e272e6e965778ed6a2795cfeed7',
                      'https://github.com/QwenLM/qwen-code.git', '11.24.0',
                      'BUILD_SANDBOX=0', 'QWEN_SANDBOX=false', 'QWEN_SKIP_PREPARE=1',
                      'COREPACK_ENABLE_NETWORK=0', 'pnpm install --frozen-lockfile',
                      'pnpm run build --cli-only', 'pnpm run bundle'):
            self.assertIn(value, helper)
        for forbidden in ('build:all', 'build:sandbox', 'build-and-start', 'npm install -g',
                          'docker_compose_tool_common', 'pnpm start', 'npm start'):
            self.assertNotIn(forbidden, helper)
        self.assertIn('node --check dist/cli.js', helper)
        self.assertNotIn('node dist/cli.js', helper)

    def test_success_marker_and_preservation(self):
        helper = (ROOT / 'scripts/tools/helpers/qwen_code_common.sh').read_text()
        self.assertLess(helper.index('rm -f -- "$QWEN_CODE_MARKER"'), helper.index('pnpm install'))
        self.assertLess(helper.index('qwen_code_smoke || {'), helper.index('> "$QWEN_CODE_MARKER"'))
        for value in ('flock -n 9', 'qwen_code_ram_budget', 'require_disk_mb 10240', 'source.disabled.'):
            self.assertIn(value, helper)
        self.assertNotIn('rm -rf', helper)

    def test_free_router_revision(self):
        helper = (ROOT / 'scripts/tools/helpers/freellmapi_common.sh').read_text()
        self.assertIn('2026-10-16-github-source-no-docker', helper)
        self.assertNotIn('FREELLMAPI_ENABLE_DOCKER', helper)
        self.assertNotIn('docker_compose_tool_common', helper)

    def test_documentation_links(self):
        for relative in ('docs/tools/qwen-code.md', 'docs/tools/freellmapi.md'):
            doc = ROOT / relative
            for link in re.findall(r'\]\(([^)]+)\)', doc.read_text(encoding='utf-8')):
                if '://' not in link and not link.startswith('#'):
                    self.assertTrue((doc.parent / link.split('#')[0]).exists(), link)


class QwenCodeBootstrapTests(unittest.TestCase):
    def test_ram_budget(self):
        for total, available, expected in ((7769, 6000, 0), (7769, 5120, 0),
                                         (7769, 5119, 1), (7167, 6000, 1),
                                         (16384, 2000, 1), ('unknown', 6000, 1),
                                         (8192, '', 1)):
            with self.subTest(total=total, available=available):
                result = self.shell(f'qwen_code_ram_budget "{total}" "{available}"')
                self.assertEqual(result.returncode, expected, result.stderr)

    def test_resource_guards(self):
        helper = (ROOT / 'scripts/tools/helpers/qwen_code_common.sh').read_text()
        self.assertIn('/^MemAvailable:/', helper)
        self.assertIn('--child-concurrency=1 --network-concurrency=4', helper)
        self.assertLess(helper.index('qwen_code_resources "$mount"'),
                        helper.index('qwen_code_prepare_runtime ||'))

    def shell(self, script):
        bash = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')
        if not bash or not Path(bash).exists():
            self.skipTest('Bash unavailable')
        with tempfile.TemporaryDirectory() as temp:
            workspace = Path(temp) / 'private'
            path = str(workspace).replace('\\', '/')
            if os.name == 'nt':
                path = '/' + path[0].lower() + path[2:]
            prefix = ('source scripts/tools/helpers/qwen_code_common.sh\n'
                      f'export OPENCLAW_USER_DATA_DIR="{path}"\n')
            result = subprocess.run([bash, '--noprofile', '--norc', '-c', prefix + script],
                                    cwd=ROOT, capture_output=True, text=True, timeout=45)
            self.assertFalse(workspace.exists())
            return result

    def mocks(self):
        return r'''
qwen_code_paths
qwen_code_require_base_tools() { :; }
qwen_code_node_compatible() { [[ "${NODE_READY:-0}" == 1 ]]; }
qwen_code_tools_compatible() { [[ "${TOOLS_READY:-0}" == 1 && "${CACHE_READY:-0}" == 1 ]]; }
qwen_code_activate_private_node() { return 1; }
qwen_code_activate_private_tools() { [[ "${TOOLS_READY:-0}" == 1 ]]; }
qwen_code_load_node_helper() {
    ensure_node_tool_runtime() {
        [[ "$NVM_DIR" == "$OPENCLAW_USER_DATA_DIR/tools/qwen_code/runtime/nvm" ]] || return 90
        echo NODE_BOOTSTRAP
        [[ "${FAIL_NODE:-0}" != 1 ]] || return 1
        NODE_READY=1
    }
}
qwen_code_install_private_tools() {
    echo COREPACK_BOOTSTRAP
    [[ "${FAIL_TOOLS:-0}" != 1 ]] || return 1
    TOOLS_READY=1
}
qwen_code_cache_package_manager() {
    [[ "$COREPACK_HOME" == "$OPENCLAW_USER_DATA_DIR/tools/qwen_code/runtime/corepack-cache" ]] || return 91
    [[ "$QWEN_CODE_PNPM_SPEC" == pnpm@11.24.0+sha512.* ]] || return 92
    echo PNPM_CACHE
    [[ "${FAIL_CACHE:-0}" != 1 ]] || return 1
    CACHE_READY=1
}
'''

    def test_missing_tools_prepared_once(self):
        result = self.shell(self.mocks() + 'qwen_code_prepare_runtime\nqwen_code_prepare_runtime')
        self.assertEqual(result.returncode, 0, result.stderr)
        for value in ('NODE_BOOTSTRAP', 'COREPACK_BOOTSTRAP', 'PNPM_CACHE'):
            self.assertEqual(result.stdout.count(value), 1)

    def test_compatible_runtime_untouched(self):
        result = self.shell(self.mocks() + 'NODE_READY=1; TOOLS_READY=1; CACHE_READY=1; qwen_code_prepare_runtime')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, '')

    def test_only_missing_cache_is_prepared(self):
        result = self.shell(self.mocks() + 'NODE_READY=1; TOOLS_READY=1; qwen_code_prepare_runtime')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('BOOTSTRAP', result.stdout)
        self.assertIn('PNPM_CACHE', result.stdout)

    def test_opt_out(self):
        result = self.shell(self.mocks() + 'export QWEN_CODE_AUTO_RUNTIME=0; qwen_code_prepare_runtime')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, '')

    def test_node_failure_stops_tools(self):
        result = self.shell(self.mocks() + 'FAIL_NODE=1; qwen_code_prepare_runtime')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('COREPACK_BOOTSTRAP', result.stdout)

    def test_corepack_failure_stops_cache(self):
        result = self.shell(self.mocks() + 'NODE_READY=1; FAIL_TOOLS=1; qwen_code_prepare_runtime')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('PNPM_CACHE', result.stdout)

    def test_cache_failure_stops(self):
        result = self.shell(self.mocks() + 'NODE_READY=1; TOOLS_READY=1; FAIL_CACHE=1; qwen_code_prepare_runtime && echo UNEXPECTED')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('UNEXPECTED', result.stdout)

    def test_check_never_installs(self):
        result = self.shell(self.mocks() + 'qwen_code_runtime_check')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, '')

    def test_dry_run_no_install(self):
        result = self.shell('qwen_code_main --dry-run')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('2026-10-16-private-node-corepack-bootstrap', result.stdout)

    def test_cache_and_prefix_contract(self):
        helper = (ROOT / 'scripts/tools/helpers/qwen_code_common.sh').read_text()
        self.assertIn('--prefix "$QWEN_CODE_COREPACK_DIR" --global=false --ignore-scripts', helper)
        self.assertIn('corepack@0.34.0', helper)
        self.assertIn('export COREPACK_HOME="$QWEN_CODE_BASE/runtime/corepack-cache"', helper)
        self.assertIn('COREPACK_ENABLE_PROJECT_SPEC=0 COREPACK_ENABLE_NETWORK=0 corepack pnpm --version', helper)


if __name__ == '__main__':
    unittest.main()
