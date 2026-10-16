"""Offline source-installer contracts; no upstream Git/npm/agent execution."""
import json
from pathlib import Path
import re
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
        for value in ('flock -n 9', 'require_ram_mb 8192', 'require_disk_mb 10240', 'source.disabled.'):
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


if __name__ == '__main__':
    unittest.main()
