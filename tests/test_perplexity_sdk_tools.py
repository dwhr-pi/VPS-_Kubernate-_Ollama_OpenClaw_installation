"""Offline SDK prerequisite tests: no binary download, Bazel build or live API."""
from contextlib import redirect_stdout
import io
import json
import os
import subprocess
from pathlib import Path
import sys
import tempfile
import tarfile
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

    def pnpm_archive(self, target, files):
        with tarfile.open(target, 'w:gz') as archive:
            for name, data in files.items():
                item = tarfile.TarInfo(name)
                item.size = len(data)
                item.mode = 0o755 if name.endswith('pnpm') else 0o644
                archive.addfile(item, io.BytesIO(data))

    def test_pnpm_retains_complete_bundle_and_verifies_sidecars_on_reuse(self):
        for host, prefix in (('linux-amd64', ''), ('linux-arm64', 'package/')):
            with self.subTest(host=host), tempfile.TemporaryDirectory() as directory:
                base = Path(directory)
                payload = {'pnpm': b'fixture executable', 'dist/pnpm.mjs': b'fixture main',
                           'dist/worker.js': b'fixture worker',
                           'dist/node_modules/example/index.js': b'fixture dependency',
                           'dist/vendor/helper.node': b'fixture native helper'}
                def download(url, path, size, digest):
                    self.pnpm_archive(path, {prefix + name: data for name, data in payload.items()})
                def probe(binary, name, parent, env, **kwargs):
                    app = Path(binary).parent
                    for relative, data in payload.items():
                        self.assertEqual((app / relative).read_bytes(), data)
                with patch.object(sdk.releases, 'host_key', return_value=host), patch.object(sdk.releases, 'download', side_effect=download) as fetch, patch.object(sdk, 'probe', side_effect=probe) as version, patch.object(sdk.shutil, 'which', return_value=None):
                    binary = sdk.install_one(base, 'pnpm', {})
                    app = Path(binary).parent
                    proof = json.loads((app.parent / 'ready.json').read_text())
                    self.assertEqual(set(proof['hashes']), set(payload))
                    self.assertEqual(sdk.selected(base, 'pnpm', {}), binary)
                    fetch.assert_called_once()
                    version.reset_mock()
                    (app / 'dist/worker.js').write_bytes(b'corrupted')
                    with self.assertRaises(ValueError):
                        sdk.selected(base, 'pnpm', {})
                    version.assert_not_called()

    def test_bad_pnpm_layout_never_runs_or_publishes_and_keeps_other_tools(self):
        cases = ({'pnpm': b'launcher'},
                 {'pnpm': b'launcher', 'dist/pnpm.mjs': b'main', 'dist/worker.js': b''},
                 {'a/pnpm': b'a', 'b/pnpm': b'b'},
                 {'../outside': b'unsafe', 'pnpm': b'launcher'})
        for files in cases:
            with self.subTest(files=list(files)), tempfile.TemporaryDirectory() as directory:
                base = Path(directory)
                existing = base / 'toolchain/bazel-existing/app/bazel'
                existing.parent.mkdir(parents=True)
                existing.write_bytes(b'keep previously installed tool')
                def download(url, path, size, digest):
                    self.pnpm_archive(path, files)
                with patch.object(sdk.releases, 'host_key', return_value='linux-amd64'), patch.object(sdk.releases, 'download', side_effect=download), patch.object(sdk, 'probe') as probe:
                    with self.assertRaises(ValueError):
                        sdk.install_one(base, 'pnpm', {})
                    probe.assert_not_called()
                    slot, _ = sdk.slot_for(base, 'pnpm')
                    self.assertFalse(slot.exists())
                    self.assertEqual(list(base.glob('sdk-bootstrap-*')), [])
                    self.assertEqual(existing.read_bytes(), b'keep previously installed tool')

    def test_dry_run_with_consent_never_prepares(self):
        for key in ('perplexity_python', 'perplexity_node'):
            with self.subTest(key=key), tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': directory}), patch.object(sdk, 'prepare') as prepare:
                with redirect_stdout(io.StringIO()):
                    self.assertEqual(tools.main([key, 'install', '--install-build-deps', '--dry-run']), 0)
                prepare.assert_not_called()
                self.assertEqual(list(Path(directory).iterdir()), [])

    def test_heavy_build_streams_without_starting_a_bazel_server(self):
        args = ['/private/bazel', '--batch', '--output_user_root=/fixture/sdk-bazel-private/user-root',
                'build', '--repo_contents_cache=/fixture/sdk-bazel-private/repo-contents', '--jobs=2', '//:pkg']
        with patch.object(native_build_process, 'run', return_value='fixture') as run:
            self.assertEqual(tools.run(args, Path('/fixture'), {'NATIVE_BUILD_STREAM': 'perplexity-sdk'}), 'fixture')
        run.assert_called_once_with(args, Path('/fixture'), {'NATIVE_BUILD_STREAM': 'perplexity-sdk'}, timeout=14400)

    def link(self, path, target):
        try:
            path.symlink_to(target, target_is_directory=target.is_dir())
        except OSError as error:
            self.skipTest('Symlink fixture unavailable: ' + str(error))

    def test_bazel_cache_is_external_and_artifacts_survive_temporary_cleanup(self):
        for mode in ('perplexity-python', 'perplexity-node'):
            with self.subTest(mode=mode), tempfile.TemporaryDirectory() as directory:
                base = Path(directory)
                runtime = base / 'runtime'
                runtime.mkdir()
                outputs = []
                def run(args, cwd, env):
                    user_root = Path(next(arg.split('=', 1)[1] for arg in args if arg.startswith('--output_user_root=')))
                    repo_cache = Path(next(arg.split('=', 1)[1] for arg in args if arg.startswith('--repo_contents_cache=')))
                    self.assertFalse(user_root.is_relative_to(runtime))
                    self.assertFalse(repo_cache.is_relative_to(runtime))
                    self.assertEqual(user_root.parent, repo_cache.parent)
                    self.assertEqual(user_root.parent.parent, base)
                    self.assertIn('--batch', args)
                    outputs.append(user_root.parent)
                    binary = user_root / 'execroot/bin'
                    binary.mkdir(parents=True)
                    if mode == 'perplexity-node':
                        (binary / 'package/dist').mkdir(parents=True)
                        (binary / 'package/package.json').write_text('{}')
                        (binary / 'package/dist/index.js').write_text('fixture SDK')
                    else:
                        (binary / 'sdk.whl').write_bytes(b'fixture wheel')
                    self.link(runtime / 'bazel-bin', binary)
                    self.link(runtime / 'bazel-out', user_root)
                    return ''
                with patch.object(sdk.common, 'run', side_effect=run):
                    result = sdk.build_artifact(runtime, {}, {'bazel': '/private/bazel'}, mode)
                self.assertTrue(result.exists())
                if mode == 'perplexity-node':
                    self.assertEqual((result / 'dist/index.js').read_text(), 'fixture SDK')
                else:
                    self.assertEqual(result.read_bytes(), b'fixture wheel')
                self.assertFalse((runtime / 'bazel-bin').is_symlink())
                self.assertFalse((runtime / 'bazel-out').is_symlink())
                self.assertTrue(all(not output.exists() for output in outputs))

    def test_failed_bazel_cleans_only_new_output_not_sources_or_toolchains(self):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            runtime = base / 'runtime'
            runtime.mkdir()
            (runtime / 'notes.txt').write_text('keep sources')
            tools = base / 'toolchain'
            tools.mkdir()
            (tools / 'bazel').write_text('keep toolchain')
            def run(args, cwd, env):
                root = Path(next(arg.split('=', 1)[1] for arg in args if arg.startswith('--output_user_root=')))
                root.mkdir()
                (root / 'partial-output').write_text('fixture')
                raise subprocess.CalledProcessError(2, args)
            with patch.object(sdk.common, 'run', side_effect=run):
                with self.assertRaises(subprocess.CalledProcessError):
                    sdk.build_artifact(runtime, {}, {'bazel': '/private/bazel'}, 'perplexity-python')
            self.assertEqual(list(base.glob('sdk-bazel-*')), [])
            self.assertEqual((runtime / 'notes.txt').read_text(), 'keep sources')
            self.assertEqual((tools / 'bazel').read_text(), 'keep toolchain')

    def test_foreign_bazel_output_is_not_copied_or_deleted(self):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            runtime = base / 'runtime'
            runtime.mkdir()
            foreign = base / 'foreign'
            foreign.mkdir()
            (foreign / 'sdk.whl').write_bytes(b'not owned by this build')
            self.link(runtime / 'bazel-bin', foreign)
            with patch.object(sdk.common, 'run'):
                with self.assertRaisesRegex(ValueError, 'Externes Bazel-Artefakt'):
                    sdk.build_artifact(runtime, {}, {'bazel': '/private/bazel'}, 'perplexity-python')
            self.assertEqual((foreign / 'sdk.whl').read_bytes(), b'not owned by this build')
            self.assertTrue((runtime / 'bazel-bin').is_symlink())
            self.assertFalse((runtime / 'sdk.whl').exists())
            self.assertEqual(list(base.glob('sdk-bazel-*')), [])

    def test_global_bazelisk_is_not_invoked_for_discovery(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(sdk.releases, 'host_key', return_value='linux-amd64'), patch.object(sdk.shutil, 'which', return_value='/global/bazel') as which, patch.object(sdk, 'probe') as probe:
            self.assertIsNone(sdk.selected(Path(directory), 'bazel', {'PATH': '/global'}))
            which.assert_not_called()
            probe.assert_not_called()


if __name__ == '__main__':
    unittest.main()
