"""XERJ build diagnostics and bounded budgets; no compiler or network."""
import contextlib
import io
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts/tools/helpers'))
import native_github_tools as tools


class XerjTimeout(unittest.TestCase):
    def test_default_and_explicit_budget(self):
        with patch.dict(os.environ, {}, clear=True):
            self.assertEqual(tools.xerj_build_timeout(), '7200')
        for value in ('300', '14400', '21600'):
            with patch.dict(os.environ, XERJ_BUILD_TIMEOUT_SECONDS=value):
                self.assertEqual(tools.xerj_build_timeout(), value)

    def test_invalid_budget_stops_preflight_before_workspace_or_download(self):
        for value in ('0', '299', '21601', '-1', 'inf', '7200;echo x', '1.5', ' 7200', '999999'):
            with self.subTest(value=value), patch.dict(os.environ, XERJ_BUILD_TIMEOUT_SECONDS=value), \
                    patch.object(tools.platform, 'system', return_value='Linux'), \
                    patch.object(tools.common, 'reserve') as reserve, \
                    patch.object(tools.litellm_rust_bootstrap, 'prepare') as prepare:
                with self.assertRaisesRegex(ValueError, '300 und 21600'):
                    tools.preflight(Path('/fixture'), tools.TOOLS['xerj'], install_build_deps=True)
                reserve.assert_not_called()
                prepare.assert_not_called()

    def test_only_cargo_build_streams_not_version_or_sysroot(self):
        env = {'NATIVE_BUILD_STREAM': 'xerj', 'XERJ_BUILD_TIMEOUT_SECONDS': '14400'}
        with patch.object(tools.native_build_process, 'run', return_value='tail') as stream, \
                patch.object(tools.common, 'run', return_value='complete') as capture:
            self.assertEqual(tools.run(['cargo', 'build', '--locked'], Path('/fixture'), env), 'tail')
            stream.assert_called_once_with(['cargo', 'build', '--locked'], Path('/fixture'), env, timeout=14400)
            for args in (['cargo', '--version'], ['rustc', '--print', 'sysroot']):
                self.assertEqual(tools.run(args, Path('/fixture'), env), 'complete')
            self.assertEqual(capture.call_count, 2)

    def test_timeout_and_compiler_errors_are_not_retried_or_success(self):
        for error in (subprocess.TimeoutExpired('cargo', 7200), subprocess.CalledProcessError(101, 'cargo')):
            with patch.object(tools.native_build_process, 'run', side_effect=error) as stream:
                with self.assertRaises(type(error)):
                    tools.run(['cargo', 'build'], Path('/fixture'),
                              {'NATIVE_BUILD_STREAM': 'xerj', 'XERJ_BUILD_TIMEOUT_SECONDS': '7200'})
                stream.assert_called_once()

    def test_timeout_removes_only_new_build_and_preserves_compiler_and_logs(self):
        with tempfile.TemporaryDirectory() as directory:
            outer = Path(directory)
            prefix = outer / 'native-github'
            marker = prefix / 'build-ready.json'
            keep = outer / 'toolchain'
            keep.mkdir()
            (keep / 'compiler-fixture').write_bytes(b'keep')
            log = outer / 'previous.log'
            log.write_bytes(b'keep-log')

            def fetch(*args):
                source = args[0]
                source.mkdir()
                (source / 'fixture').write_bytes(b'partial-build')

            with patch.object(tools, 'preflight'), patch.object(tools, 'fetch_source', side_effect=fetch), \
                    patch.object(tools, 'build', side_effect=subprocess.TimeoutExpired('cargo', 7200)), \
                    contextlib.redirect_stdout(io.StringIO()):
                with self.assertRaises(subprocess.TimeoutExpired):
                    tools.install(outer, prefix, marker, tools.TOOLS['xerj'])
            self.assertFalse(prefix.exists())
            self.assertFalse(marker.exists())
            self.assertEqual((keep / 'compiler-fixture').read_bytes(), b'keep')
            self.assertEqual(log.read_bytes(), b'keep-log')

    def test_build_keeps_locked_features_and_jobs_and_passes_selected_budget(self):
        with tempfile.TemporaryDirectory() as directory:
            prefix = Path(directory) / 'native-github'
            module = prefix / 'source/engine'
            module.mkdir(parents=True)
            commands = []

            def run(args, cwd, env):
                commands.append((args, dict(env)))
                if args == ['rustc', '--print', 'sysroot']:
                    return str(module)
                if args[:2] == ['cargo', 'build']:
                    artifact = module / 'target/release/xerj'
                    artifact.parent.mkdir(parents=True)
                    artifact.write_bytes(b'fixture-not-executable')
                return ''

            with patch.dict(os.environ, XERJ_BUILD_TIMEOUT_SECONDS='14400'), \
                    patch.object(tools, 'run', side_effect=run), \
                    patch.object(tools.litellm_rust, 'activate'), contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(tools.build(prefix, tools.TOOLS['xerj']), ['bin/xerj'])
            args, env = next(row for row in commands if row[0][:2] == ['cargo', 'build'])
            self.assertEqual(args, ['cargo', 'build', '--locked', '--release', '--bin', 'xerj',
                                    '--package', 'xerj-server', '--no-default-features', '-j', '2'])
            self.assertEqual(env['NATIVE_BUILD_STREAM'], 'xerj')
            self.assertEqual(env['XERJ_BUILD_TIMEOUT_SECONDS'], '14400')


if __name__ == '__main__':
    unittest.main()
