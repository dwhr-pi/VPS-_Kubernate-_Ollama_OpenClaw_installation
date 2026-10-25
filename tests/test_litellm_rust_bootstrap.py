"""Fixture-only private Rust bootstrap: no downloads, compiler or rustup execution."""
import io
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts/tools/helpers'))
import litellm_rust_bootstrap as bootstrap


class PrivateRustTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.base = Path(temporary.name) / 'litellm'
        self.base.mkdir()
        self.spec = {'id': 'litellm', 'recipe': {'disk_mb': 8192}}
        for context in (patch.dict(os.environ, {}, clear=True),
                        patch.object(bootstrap.releases, 'host_key', return_value='linux-amd64'),
                        patch.object(bootstrap.rust, 'select', side_effect=ValueError('missing')),
                        patch.object(bootstrap.sys.stdin, 'isatty', return_value=False)):
            context.start()
            self.addCleanup(context.stop)

    def fake_download(self, url, target, size, digest):
        self.assertTrue(url.startswith('https://static.rust-lang.org/rustup/archive/1.29.2/'))
        target.write_bytes(b'fixture')

    def fake_run(self, args, cwd, env):
        self.assertNotIn('OPENAI_API_KEY', env)
        self.assertEqual(env['RUSTUP_DIST_SERVER'], 'https://static.rust-lang.org')
        self.assertTrue(Path(env['CARGO_HOME']).is_relative_to(self.base))
        self.assertTrue(Path(env['HOME']).is_relative_to(self.base))
        if '--version' in args:
            return 'rustup-init 1.29.2 (fixture)'
        self.assertIn('--no-modify-path', args)
        self.assertEqual(args[-1], bootstrap.rust.VERSION)
        root = Path(env['RUSTUP_HOME']) / 'toolchains' / (bootstrap.rust.VERSION + '-x86_64-unknown-linux-gnu')
        (root / 'bin').mkdir(parents=True)
        for name in ('cargo', 'rustc'):
            (root / 'bin' / name).write_bytes(b'fixture')
        return ''

    def test_no_consent_no_download_or_mutation(self):
        with patch.object(bootstrap, 'download') as download, patch.object(bootstrap.common, 'run') as run:
            with self.assertRaisesRegex(ValueError, 'nicht freigegeben'):
                bootstrap.prepare(self.base, self.spec)
        download.assert_not_called()
        run.assert_not_called()
        self.assertEqual(list(self.base.iterdir()), [])

    def test_explicit_invalid_path_never_bootstraps(self):
        with patch.dict(os.environ, {'NATIVE_SOURCE_RUST_TOOLCHAIN': '/explicit'}), patch.object(bootstrap, 'download') as download:
            with self.assertRaises(ValueError):
                bootstrap.prepare(self.base, self.spec, approved=True)
        download.assert_not_called()

    def test_success_reuse_and_private_environment(self):
        with patch.object(bootstrap, 'download', side_effect=self.fake_download) as download, patch.object(bootstrap.common, 'run', side_effect=self.fake_run), patch.object(bootstrap.common, 'reserve') as reserve, patch.object(bootstrap.rust, 'verify', side_effect=lambda root, cwd: root.resolve()):
            root = bootstrap.prepare(self.base, self.spec, approved=True)
            self.assertTrue((root / 'bin/cargo').is_file())
            self.assertEqual(bootstrap.prepare(self.base, self.spec), root)
            self.assertEqual(download.call_count, 1)
            reserve.assert_called_once_with(self.base, {'reserve_mb': 10240})
            self.assertFalse(list((self.base / 'toolchain').glob('rust-bootstrap-*')))

    def test_failed_download_cleans_only_its_staging(self):
        keep = self.base / 'keep.txt'
        keep.write_bytes(b'keep')
        with patch.object(bootstrap, 'download', side_effect=ValueError('checksum')), patch.object(bootstrap.common, 'reserve'), patch.object(bootstrap.common, 'run') as run:
            with self.assertRaisesRegex(ValueError, 'checksum'):
                bootstrap.prepare(self.base, self.spec, approved=True)
        run.assert_not_called()
        self.assertEqual(keep.read_bytes(), b'keep')
        slot, _, _, _ = bootstrap.location(self.base)
        self.assertFalse(slot.exists())
        self.assertFalse(list(slot.parent.glob('rust-bootstrap-*')))

    def test_partial_or_changed_slot_is_not_overwritten(self):
        slot, _, _, _ = bootstrap.location(self.base)
        slot.mkdir(parents=True)
        (slot / 'foreign.txt').write_bytes(b'keep')
        with patch.object(bootstrap, 'download') as download:
            with self.assertRaises(OSError):
                bootstrap.prepare(self.base, self.spec, approved=True)
        download.assert_not_called()
        self.assertEqual((slot / 'foreign.txt').read_bytes(), b'keep')

    def test_corrupt_payload_not_executed(self):
        class Response(io.BytesIO):
            def __enter__(self):
                return self
            def __exit__(self, *args):
                self.close()
        with patch.object(bootstrap, 'build_opener') as opener:
            opener.return_value.open.return_value = Response(b'wrong')
            with self.assertRaisesRegex(ValueError, 'SHA256'):
                bootstrap.download('https://static.rust-lang.org/fixture', self.base / 'payload', 5, '0' * 64)
        with self.assertRaisesRegex(ValueError, 'Host'):
            bootstrap.download('https://evil.example/fixture', self.base / 'another', 5, '0' * 64)


if __name__ == '__main__':
    unittest.main()
