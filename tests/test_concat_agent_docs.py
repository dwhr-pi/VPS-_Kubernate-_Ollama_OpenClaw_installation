"""Static agent setup examples; never run Concat, an MCP peer or a renderer."""
import json
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


class ConcatAgentDocs(unittest.TestCase):
    def test_native_mcp_example_uses_explicit_window_mode_and_no_network_proxy(self):
        text = (ROOT / 'docs/tools/concat.md').read_text(encoding='utf-8')
        blocks = re.findall(r'```json\n(.*?)\n```', text, re.S)
        self.assertTrue(blocks)
        config = json.loads(blocks[0])['mcpServers']['concat-review']
        self.assertEqual(config['args'], ['--mcp', 'window'])
        self.assertTrue(config['command'].startswith('/'))
        self.assertNotIn('env', config)
        self.assertNotIn('node', config['command'])

    def test_source_pins_and_real_limits_are_explicit(self):
        text = (ROOT / 'docs/tools/concat.md').read_text(encoding='utf-8')
        for value in ('79116bd0f9a103c633d888603ad27890e929dbdc',
                      '483c9d6afa7b272b816e44fdd5b21eba2d773be2',
                      'CONCAT_MCP_ROOTS', 'keine vollstaendige', 'noch nicht implementiert'):
            if value == 'keine vollstaendige':
                self.assertIn('keine Zusicherung', text)
            else:
                self.assertIn(value, text)
        self.assertIn('GitHub-Release-AppImage-Ausnahme', text)
        self.assertIn('kein echter MCP-Handshake', text)

    def test_hypothetical_http_methods_are_not_executable_code(self):
        text = (ROOT / 'docs/tools/concat.md').read_text(encoding='utf-8')
        code = '\n'.join(re.findall(r'```[^\n]*\n(.*?)\n```', text, re.S))
        for value in ('requests.post', 'project.add_clip', 'project.export', '8080/json-rpc', 'concat-mcp-wrapper.js'):
            self.assertNotIn(value, code)
        self.assertNotIn('"mcpServers"', (ROOT / 'config/tools.yml').read_text(encoding='utf-8'))


if __name__ == '__main__':
    unittest.main()
