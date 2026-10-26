"""Offline SDK prerequisite tests: no binary download, Bazel build or live API."""
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
import perplexity_sdk_tools as sdk
import native_build_process


class SdkToolsTests(unittest.TestCase):
    def test_assets_have_fixed_official_hosts_sizes_and_hashes(self):
        for host, assets in sdk.ASSETS.items():
            self.assertIn(host, ('linux-amd64', 'linux-arm64'))
            for name, (url, size, digest) in assets.items():
                self.assertRegex(digest, r'^[0-9a-f]{64}$')
                self.assertGreater(size, 1024)
                self.assertTrue(url.startswith('https://nodejs.org/') if name == 'node' else url.startswith('https://github.com/'))

    def test_refusal_prevents_download_or_slot_creation(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(sdk.releases, 'host_key', return_value='linux-amd64'), patch.object(sdk.common, 'executable', return_value='python3'), patch.object(sdk.common, 'run'), patch.object(sdk, 'selected', return_value=None), patch.object(sdk.native_node, 'confirm', return_value=False), patch.object(sdk, 'install_one') as install:
            with redirect_stdout(io.StringIO()), self.assertRaisesRegex(ValueError, 'nicht freigegeben'):
                sdk.prepare(Path(directory), 'perplexity_node')
            install.assert_not_called()
            self.assertEqual(list(Path(directory).iterdir()), [])

    def test_missing_tools_are_prepared_together_with_headroom(self):
        for key in ('perplexity_python', 'perplexity_node'):
            with self.subTest(key=key), tempfile.TemporaryDirectory() as directory, patch.object(sdk.releases, 'host_key', return_value='linux-amd64'), patch.object(sdk.common, 'executable', return_value='python3'), patch.object(sdk.common, 'run'), patch.object(sdk, 'selected', return_value=None), patch.object(sdk, 'install_one', side_effect=lambda base, name, env: '/fixture/bin/' + name) as install, patch.object(sdk.common, 'reserve') as reserve, patch.object(sdk.native_uv, 'prepare') as uv:
                with redirect_stdout(io.StringIO()):
                    result = sdk.prepare(Path(directory), key, approved=True)
                self.assertEqual(list(result), ['bazel', 'node', 'pnpm'])
                self.assertEqual(install.call_count, 3)
                reserve.assert_called_once_with(Path(directory), {'reserve_mb': 9472})
                if key == 'perplexity_python':
                    uv.assert_called_once_with(Path(directory), sdk.uv_spec(), approved=True)
                else:
                    uv.assert_not_called()

    def test_bad_python_stops_before_toolchain_download(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(sdk.releases, 'host_key', return_value='linux-amd64'), patch.object(sdk.common, 'executable', return_value='python3'), patch.object(sdk.common, 'run', side_effect=ValueError('python')), patch.object(sdk, 'selected') as select:
            with self.assertRaisesRegex(ValueError, 'python'):
                sdk.prepare(Path(directory), 'perplexity_python', True)
            select.assert_not_called()

    def test_activation_requires_existing_tools_and_private_home(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(sdk, 'selected', side_effect=lambda base, name, env: '/private/bin/' + name):
            before = dict(os.environ)
            env = {'PATH': 'original', 'HOME': directory}
            result = sdk.activate(Path(directory), env)
            self.assertEqual(result['bazel'], '/private/bin/bazel')
            self.assertNotEqual(env['npm_config_userconfig'], env['npm_config_globalconfig'])
            self.assertEqual(dict(os.environ), before)
        with patch.object(sdk, 'selected', return_value=None):
            with self.assertRaisesRegex(ValueError, 'SDK-Buildbasis fehlt'):
                sdk.activate(Path('/fixture'), {'HOME': '/fixture'})

    def test_component_hash_failure_leaves_no_slot(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(sdk.releases, 'host_key', return_value='linux-amd64'), patch.object(sdk.releases, 'download', side_effect=ValueError('hash')), patch.object(sdk, 'probe') as probe:
            with self.assertRaisesRegex(ValueError, 'hash'):
                sdk.install_one(Path(directory), 'bazel', {})
            probe.assert_not_called()
            self.assertEqual(list(Path(directory).iterdir()), [])

    def test_component_installs_once_and_is_reused(self):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            def download(url, path, size, digest):
                path.write_bytes(b'fixture bazel')
            with patch.object(sdk.releases, 'host_key', return_value='linux-amd64'), patch.object(sdk.releases, 'download', side_effect=download) as fetch, patch.object(sdk, 'probe'), patch.object(sdk.shutil, 'which', return_value=None):
                with redirect_stdout(io.StringIO()):
                    binary = sdk.install_one(base, 'bazel', {})
                    self.assertEqual(sdk.selected(base, 'bazel', {}), binary)
                fetch.assert_called_once()
                Path(binary).write_bytes(b'corrupted')
                with self.assertRaises(ValueError):
                    sdk.selected(base, 'bazel', {})

    def test_dry_run_with_consent_never_prepares(self):
        for key in ('perplexity_python', 'perplexity_node'):
            with self.subTest(key=key), tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': directory}), patch.object(sdk, 'prepare') as prepare:
                with redirect_stdout(io.StringIO()):
                    self.assertEqual(tools.main([key, 'install', '--install-build-deps', '--dry-run']), 0)
                prepare.assert_not_called()
                self.assertEqual(list(Path(directory).iterdir()), [])

    def test_heavy_build_streams_without_starting_a_bazel_server(self):
        args = ['/private/bazel', '--batch', '--output_user_root=/fixture/.bazel', 'build', '--jobs=2', '//:pkg']
        with patch.object(native_build_process, 'run', return_value='fixture') as run:
            self.assertEqual(tools.run(args, Path('/fixture'), {'NATIVE_BUILD_STREAM': 'perplexity-sdk'}), 'fixture')
        run.assert_called_once_with(args, Path('/fixture'), {'NATIVE_BUILD_STREAM': 'perplexity-sdk'}, timeout=14400)

    def test_global_bazelisk_is_not_invoked_for_discovery(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(sdk.releases, 'host_key', return_value='linux-amd64'), patch.object(sdk.shutil, 'which', return_value='/global/bazel') as which, patch.object(sdk, 'probe') as probe:
            self.assertIsNone(sdk.selected(Path(directory), 'bazel', {'PATH': '/global'}))
            which.assert_not_called()
            probe.assert_not_called()


if __name__ == '__main__':
    unittest.main()
