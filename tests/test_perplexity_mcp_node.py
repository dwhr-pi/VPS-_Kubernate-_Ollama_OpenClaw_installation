"""MCP Node/npm prerequisites using offline fixtures, never starts an MCP server."""
from contextlib import redirect_stdout
import io
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts/tools/helpers'))
import gap_tools as tools
import native_node_npm as helper


class PerplexityMcpNodeTests(unittest.TestCase):
    def test_prepare_uses_approved_private_contract(self):
        with patch.object(tools.platform, 'system', return_value='Linux'), patch.object(helper, 'prepare') as prepare:
            tools.perplexity_mcp_prepare(Path('/fixture'), approved=True)
        prepare.assert_called_once_with(Path('/fixture'),
            {'id': 'perplexity_mcp', 'recipe': {'private_node_npm': helper.node.NODE, 'disk_mb': 4096}}, approved=True)

    def test_dry_run_with_consent_is_readonly(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': directory}), patch.object(helper, 'prepare') as prepare, patch.object(tools, 'git') as git:
            with redirect_stdout(io.StringIO()):
                self.assertEqual(tools.main(['perplexity_mcp', 'install', '--install-build-deps', '--dry-run']), 0)
            prepare.assert_not_called()
            git.assert_not_called()
            self.assertEqual(list(Path(directory).iterdir()), [])

    def test_refused_prerequisite_does_not_checkout_or_mark_installed(self):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            with patch.object(tools, 'reserve'), patch.object(tools, 'perplexity_mcp_prepare', side_effect=ValueError('not approved')), patch.object(tools, 'git') as git:
                with self.assertRaisesRegex(ValueError, 'not approved'):
                    tools.install(base / 'runtime', base / 'ready.json', base, tools.SPECS['perplexity_mcp'])
            git.assert_not_called()
            self.assertFalse((base / 'runtime').exists())
            self.assertFalse((base / 'ready.json').exists())

    def test_missing_pair_names_mcp_and_never_downloads_without_consent(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(helper.shutil, 'which', return_value=None), patch.object(helper.releases, 'host_key', return_value='linux-amd64'), patch.object(helper.node, 'confirm', return_value=False), patch.object(helper.node, 'download_node') as download:
            with redirect_stdout(io.StringIO()) as output, self.assertRaisesRegex(ValueError, 'nicht freigegeben'):
                helper.prepare(Path(directory), tools.perplexity_mcp_node_spec())
            self.assertIn('Perplexity_MCP', output.getvalue())
            self.assertIn('perplexity_mcp_install.sh --install-build-deps', output.getvalue())
            self.assertNotIn('Node-RED', output.getvalue())
            download.assert_not_called()

    def test_bootstrap_private_configs_reserve_and_reuse(self):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            def unpack(archive, payload, arch):
                (payload / 'node').write_bytes(b'node fixture')
                (payload / 'npm').write_bytes(b'npm fixture')
            def versions(args, cwd, env):
                self.assertNotEqual(env['npm_config_userconfig'], env['npm_config_globalconfig'])
                self.assertEqual(Path(env['npm_config_userconfig']).read_bytes(), b'')
                return 'v' + helper.node.NODE if Path(args[0]).name == 'node' else helper.NPM
            with patch.object(helper.shutil, 'which', return_value=None), patch.object(helper.releases, 'host_key', return_value='linux-amd64'), patch.object(helper.node, 'download_node') as download, patch.object(helper, 'unpack', side_effect=unpack), patch.object(helper.common, 'run', side_effect=versions), patch.object(helper.releases, 'reserve') as reserve, redirect_stdout(io.StringIO()):
                helper.prepare(base, tools.perplexity_mcp_node_spec(), approved=True)
                env = {'PATH': 'original'}
                helper.activate(base, tools.perplexity_mcp_node_spec(), env)
            download.assert_called_once()
            reserve.assert_called_once_with(base, {'reserve_mb': 5120})
            self.assertNotEqual(env['npm_config_userconfig'], env['npm_config_globalconfig'])
            self.assertTrue(env['PATH'].endswith(os.pathsep + 'original'))

    def test_build_resolves_both_programs_from_private_child_path(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(tools.platform, 'system', return_value='Linux'):
            def activate(base, spec, env):
                env['PATH'] = '/fixture/private/bin'
            def which(name, path=None):
                self.assertEqual(path, '/fixture/private/bin')
                return '/fixture/private/bin/' + name
            def run(args, cwd, env):
                return 'v22.23.4' if args[-1] == '--version' else ''
            with patch.object(helper, 'activate', side_effect=activate), patch.object(tools.shutil, 'which', side_effect=which), patch.object(tools, 'run', side_effect=run) as commands:
                tools.browser_research_build(Path(directory), {}, 'perplexity-mcp')
            calls = [call.args[0] for call in commands.call_args_list]
            self.assertIn(['/fixture/private/bin/npm', 'ci', '--ignore-scripts', '--no-audit', '--no-fund'], calls)
            self.assertIn(['/fixture/private/bin/node', '--check', 'dist/index.js'], calls)
            self.assertFalse(any('start' in call or 'start:http' in call for call in calls))


if __name__ == '__main__':
    unittest.main()
