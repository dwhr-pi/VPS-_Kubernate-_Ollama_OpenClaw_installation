"""Offline interpreter selection fixtures; no runtimes are downloaded."""
from contextlib import redirect_stdout
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import Mock, patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts/tools/helpers'))
import archivebox_python as runtime
import native_github_tools as tools


class ArchivePythonTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.base = Path(self.temporary.name)
        self.spec = tools.TOOLS['archivebox']
        for context in (patch.dict(os.environ, {}, clear=True),
                        patch.object(runtime.shutil, 'which', return_value=None),
                        patch.object(runtime.sys, 'stdin', Mock(isatty=Mock(return_value=False))),
                        redirect_stdout(io.StringIO())):
            context.__enter__()
            self.addCleanup(context.__exit__, None, None, None)

    def unavailable(self, *args):
        raise subprocess.CalledProcessError(1, 'fixture-python')

    def test_explicit_python_is_respected(self):
        with patch.dict(os.environ, {'NATIVE_SOURCE_PYTHON_BIN': '/selected/python'}), \
             patch.object(runtime, 'probe') as probe, patch.object(runtime.native_uv, 'select') as uv:
            self.assertEqual(runtime.select(self.base, self.spec), '/selected/python')
        probe.assert_called_once()
        uv.assert_not_called()

    def test_invalid_explicit_python_never_downloads_or_falls_back(self):
        with patch.dict(os.environ, {'NATIVE_SOURCE_PYTHON_BIN': '/old/python'}), \
             patch.object(runtime, 'probe', side_effect=self.unavailable), \
             patch.object(runtime.native_uv, 'select') as uv:
            with self.assertRaisesRegex(ValueError, 'keine automatische Ersetzung'):
                runtime.select(self.base, self.spec, approved=True, allow_download=True)
        uv.assert_not_called()

    def test_detects_existing_python313(self):
        with patch.object(runtime.shutil, 'which', side_effect=lambda name: '/local/python313' if name == 'python3.13' else None), \
             patch.object(runtime, 'probe'), patch.object(runtime.native_uv, 'select') as uv:
            self.assertEqual(runtime.select(self.base, self.spec), '/local/python313')
        uv.assert_not_called()

    def test_missing_python_requires_consent_without_writes(self):
        with patch.object(runtime, 'probe', side_effect=self.unavailable), \
             patch.object(runtime.native_uv, 'select') as uv:
            with self.assertRaisesRegex(ValueError, '--install-build-deps'):
                runtime.select(self.base, self.spec, allow_download=True)
        uv.assert_not_called()
        self.assertEqual(list(self.base.iterdir()), [])

    def test_no_download_during_build_selection(self):
        with patch.object(runtime, 'probe', side_effect=self.unavailable), \
             patch.object(runtime.native_uv, 'select') as uv:
            with self.assertRaises(ValueError):
                runtime.select(self.base, self.spec, approved=True)
        uv.assert_not_called()

    def bootstrap(self, fail=False):
        def run(args, cwd, env):
            if 'install' in args:
                target = Path(env['UV_PYTHON_INSTALL_DIR']) / 'cpython/bin/python3.13'
                target.parent.mkdir(parents=True)
                target.write_bytes(b'fixture-runtime')
                if fail:
                    raise ValueError('fixture-download-failed')
                return ''
            return str(self.base / 'toolchain/archivebox-python313/managed/cpython/bin/python3.13')

        def probe(python, *args):
            if str(python) == sys.executable:
                self.unavailable()
            return str(python)

        with patch.object(runtime, 'probe', side_effect=probe), \
             patch.object(runtime.common, 'reserve') as reserve, \
             patch.object(runtime.native_uv, 'select', return_value='/fixture/uv'), \
             patch.object(runtime.common, 'run', side_effect=run) as command:
            result = runtime.select(self.base, self.spec, approved=True, allow_download=True)
        return result, reserve, command

    def test_private_bootstrap_reuse_and_tamper_detection(self):
        original = dict(os.environ)
        result, reserve, command = self.bootstrap()
        reserve.assert_called_once_with(self.base, {'reserve_mb': 9216})
        self.assertIn('--no-bin', command.call_args_list[0].args[0])
        self.assertEqual(dict(os.environ), original)
        with patch.object(runtime, 'probe', side_effect=[subprocess.CalledProcessError(1, 'fixture'), result]), \
             patch.object(runtime.native_uv, 'select') as uv:
            self.assertEqual(runtime.select(self.base, self.spec), result)
        uv.assert_not_called()
        Path(result).write_bytes(b'changed')
        with patch.object(runtime, 'probe', side_effect=self.unavailable):
            with self.assertRaisesRegex(ValueError, 'veraendert'):
                runtime.select(self.base, self.spec)

    def test_failed_new_bootstrap_removes_only_new_slot(self):
        existing = self.base / 'preserve.txt'
        existing.write_text('keep')
        with self.assertRaisesRegex(ValueError, 'fixture-download-failed'):
            self.bootstrap(fail=True)
        self.assertEqual(existing.read_text(), 'keep')
        self.assertFalse((self.base / 'toolchain/archivebox-python313').exists())

    def test_low_disk_prevents_uv_bootstrap(self):
        with patch.object(runtime, 'probe', side_effect=self.unavailable), \
             patch.object(runtime.common, 'reserve', side_effect=ValueError('disk')), \
             patch.object(runtime.native_uv, 'select') as uv:
            with self.assertRaisesRegex(ValueError, 'disk'):
                runtime.select(self.base, self.spec, approved=True, allow_download=True)
        uv.assert_not_called()


if __name__ == '__main__':
    unittest.main()
