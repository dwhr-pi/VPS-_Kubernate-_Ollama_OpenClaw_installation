"""Existing Rust discovery only; no compiler, rustup or network execution."""
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts/tools/helpers'))
import litellm_rust as rust


class RustSelection(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.base = Path(self.temporary.name)
        self.home = self.base / 'rustup'
        self.root = self.home / 'toolchains' / (rust.VERSION + '-x86_64-unknown-linux-gnu')
        (self.root / 'bin').mkdir(parents=True)
        for name in ('cargo', 'rustc'):
            (self.root / 'bin' / name).write_bytes(b'fixture')
        for context in (patch.dict(os.environ, {'RUSTUP_HOME': str(self.home)}, clear=True),
                        patch.object(rust.shutil, 'which', return_value=None)):
            context.start()
            self.addCleanup(context.stop)

    def compiler(self, args, cwd, env):
        self.assertEqual(env['RUSTUP_TOOLCHAIN'], str(self.root.resolve()))
        self.assertEqual(env['RUSTUP_AUTO_INSTALL'], '0')
        self.assertNotIn('OPENAI_API_KEY', env)
        self.assertIn(Path(args[0]).name, ('cargo', 'rustc'))
        if '--print' in args:
            return str(self.root)
        return Path(args[0]).name + ' ' + rust.VERSION + ' (fixture 2026-10-25)'

    def test_installed_toolchain_found_without_cargo_in_path(self):
        with patch.object(rust.common, 'run', side_effect=self.compiler) as run:
            self.assertEqual(rust.select(self.base), self.root.resolve())
        self.assertEqual(run.call_count, 3)

    def test_missing_toolchain_fails_with_specific_guidance_without_commands(self):
        (self.root / 'bin/cargo').unlink()
        with patch.object(rust.common, 'run') as run:
            with self.assertRaisesRegex(ValueError, 'toolchain install 1.98.0'):
                rust.select(self.base)
        run.assert_not_called()

    def test_invalid_explicit_selection_never_falls_back(self):
        with patch.dict(os.environ, {'NATIVE_SOURCE_RUST_TOOLCHAIN': 'relative/path'}), \
             patch.object(rust.common, 'run') as run:
            with self.assertRaisesRegex(ValueError, 'keine automatische Ersetzung'):
                rust.select(self.base)
        run.assert_not_called()

    def test_wrong_version_is_rejected(self):
        with patch.object(rust.common, 'run', return_value='rustc 1.88.0 (fixture)'):
            with self.assertRaisesRegex(ValueError, 'Pin'):
                rust.verify(self.root, self.base)

    def test_mismatched_sysroot_is_rejected(self):
        with patch.object(rust.common, 'run', side_effect=[
                'rustc ' + rust.VERSION, 'cargo ' + rust.VERSION, str(self.base)]):
            with self.assertRaisesRegex(ValueError, 'sysroot'):
                rust.verify(self.root, self.base)

    def test_activation_preserves_guards_and_parent_environment(self):
        original = dict(os.environ)
        guard = self.base / 'guards'
        env = {'PATH': str(guard) + os.pathsep + 'original', 'CARGO_HOME': 'private-cache'}
        with patch.object(rust.common, 'run', side_effect=self.compiler):
            rust.activate(self.base, {'id': 'litellm'}, env)
        self.assertEqual(dict(os.environ), original)
        self.assertEqual(env['PATH'].split(os.pathsep)[:2], [str(guard), str(self.root / 'bin')])
        self.assertEqual(env['CARGO_HOME'], 'private-cache')


if __name__ == '__main__':
    unittest.main()
