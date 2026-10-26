"""LiteLLM build visibility/budgets; fixtures only, no uv/compiler/network."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts/tools/helpers'))
import native_github_tools as tools


class LiteLLMBuildTimeoutTests(unittest.TestCase):
    def test_default_and_explicit_bounded_budget(self):
        with patch.dict(os.environ, {}, clear=True):
            self.assertEqual(tools.litellm_build_timeout(), '7200')
        for value in ('300', '14400', '21600'):
            with patch.dict(os.environ, {'LITELLM_BUILD_TIMEOUT_SECONDS': value}):
                self.assertEqual(tools.litellm_build_timeout(), value)

    def test_invalid_budget_fails_without_launching_anything(self):
        for value in ('0', '-1', 'inf', '1.5', '7200;echo x', '21601', '999999'):
            with self.subTest(value=value), patch.dict(os.environ, {'LITELLM_BUILD_TIMEOUT_SECONDS': value}), patch.object(tools, 'run') as run:
                with self.assertRaisesRegex(ValueError, '300 und 21600'):
                    tools.litellm_build_timeout()
                run.assert_not_called()

    def test_only_heavy_pip_install_uses_streaming_not_freeze(self):
        env = {'NATIVE_BUILD_STREAM': 'litellm', 'LITELLM_BUILD_TIMEOUT_SECONDS': '14400'}
        with patch.object(tools.native_build_process, 'run', return_value='tail') as stream, patch.object(tools.common, 'run', return_value='complete-freeze') as capture:
            result = tools.run(['uv', 'pip', 'install', '--verbose', '/fixture/source[proxy]'], Path('/fixture'), env)
            self.assertEqual(result, 'tail')
            self.assertEqual(stream.call_args.kwargs['timeout'], 14400)
            self.assertEqual(tools.run(['uv', 'pip', 'freeze'], Path('/fixture'), env), 'complete-freeze')
            stream.assert_called_once()
            capture.assert_called_once()

    def test_timeout_is_not_success_or_retried(self):
        with patch.object(tools.native_build_process, 'run', side_effect=subprocess.TimeoutExpired('uv', 7200)) as stream:
            with self.assertRaises(subprocess.TimeoutExpired):
                tools.run(['uv', 'pip', 'install'], Path('/fixture'),
                          {'NATIVE_BUILD_STREAM': 'litellm', 'LITELLM_BUILD_TIMEOUT_SECONDS': '7200'})
            stream.assert_called_once()

    def test_litellm_build_commands_and_limits(self):
        spec = tools.TOOLS['litellm']
        commands = []
        with tempfile.TemporaryDirectory() as directory:
            prefix = Path(directory) / 'native-github'
            source = prefix / 'source'
            source.mkdir(parents=True)
            expected = ['venv/pyvenv.cfg'] + spec['recipe'].get('artifacts', [])
            if spec['recipe'].get('entry'):
                expected.append('source/' + spec['recipe']['entry'])
            for relative in expected:
                artifact = prefix / relative
                artifact.parent.mkdir(parents=True, exist_ok=True)
                artifact.write_text('fixture artifact')
            def run(args, cwd, env):
                commands.append(list(map(str, args)))
                self.assertEqual(env['CARGO_BUILD_JOBS'], '1')
                self.assertEqual(env['UV_CONCURRENT_BUILDS'], '1')
                self.assertEqual(env['UV_HTTP_RETRIES'], '2')
                self.assertEqual(env['NATIVE_BUILD_STREAM'], 'litellm')
                self.assertNotIn('OPENAI_API_KEY', env)
                return 'fixture==1'
            with patch.object(tools, 'run', side_effect=run), patch.object(tools.adapters, 'prepare'), patch.object(tools.native_go, 'activate'), patch.object(tools.native_uv, 'activate'), patch.object(tools.native_node, 'activate'), patch.object(tools.native_node_npm, 'activate'), patch.object(tools.litellm_rust, 'activate'):
                tools.build(prefix, spec)
            install = next(command for command in commands if command[:3] == ['uv', 'pip', 'install'])
            self.assertIn('--verbose', install)
            self.assertTrue(any(item.endswith('source[proxy]') for item in install))
            self.assertEqual((prefix / 'resolved-requirements.txt').read_text(), 'fixture==1\n')


if __name__ == '__main__':
    unittest.main()
