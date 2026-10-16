"""Private synthetic launcher installation only; no WSL, network, media or packages."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('karaoke_manage', ROOT / 'tools/karaoke_formats/manage.py')
manage = importlib.util.module_from_spec(spec)
spec.loader.exec_module(manage)


class KaraokeInstall(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve() / 'private'
        self.env = patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(self.root))
        self.env.start()
        self.addCleanup(self.env.stop)
        self.output = contextlib.redirect_stdout(io.StringIO())
        self.output.__enter__()
        self.addCleanup(self.output.__exit__, None, None, None)

    def test_plan_and_status_create_nothing(self):
        self.assertEqual(manage.main(['plan']), 0)
        self.assertEqual(manage.main(['status']), 0)
        self.assertFalse(self.root.exists())

    def test_missing_doctor_fails_without_creation(self):
        self.assertEqual(manage.main(['doctor']), 1)
        self.assertFalse(self.root.exists())

    def test_install_idempotent_and_doctor(self):
        self.assertEqual(manage.main(['install']), 0)
        _, base = manage.paths()
        launcher = base / 'bin/karaoke-formats'
        before = launcher.stat().st_mtime_ns
        self.assertTrue(manage.installed(base))
        self.assertEqual(manage.main(['install']), 0)
        self.assertEqual(launcher.stat().st_mtime_ns, before)
        self.assertEqual(manage.main(['doctor']), 0)
        self.assertTrue(list((self.root / 'install_logs').glob('karaoke_formats_*.log')))

    def test_launcher_works_without_conversion(self):
        self.assertEqual(manage.main(['install']), 0)
        _, base = manage.paths()
        result = subprocess.run([sys.executable, '-I', '-B', str(base / 'bin/karaoke-formats'), 'plan'],
                                capture_output=True, text=True, timeout=20)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(json.loads(result.stdout)['network'])

    def test_source_change_detected_by_starter(self):
        source = Path(self.temp.name).resolve() / 'synthetic.py'
        source.write_text('raise SystemExit(98)', encoding='utf-8')
        starter = Path(self.temp.name) / 'starter.py'
        starter.write_text(manage.launcher_text(source, manage.digest(source)), encoding='utf-8')
        source.write_text('raise SystemExit(99)', encoding='utf-8')
        result = subprocess.run([sys.executable, '-I', '-B', str(starter)],
                                capture_output=True, text=True, timeout=20)
        self.assertEqual(result.returncode, 1)
        self.assertIn('karaoke_formats_update.sh', result.stderr)

    def test_changed_launcher_repair(self):
        manage.main(['install'])
        _, base = manage.paths()
        (base / 'bin/karaoke-formats').write_text('modified', encoding='utf-8')
        self.assertFalse(manage.installed(base))
        self.assertEqual(manage.main(['update']), 0)
        self.assertTrue(manage.installed(base))

    def test_uninstall_preserves_media_and_source(self):
        manage.main(['install'])
        _, base = manage.paths()
        media = base / 'keep.lrc'
        media.write_text('synthetic', encoding='utf-8')
        self.assertEqual(manage.main(['uninstall']), 0)
        self.assertFalse((base / 'installed.json').exists())
        self.assertFalse((base / 'bin/karaoke-formats').exists())
        self.assertTrue(manage.SOURCE.exists())
        self.assertEqual(media.read_text(), 'synthetic')
        self.assertEqual(manage.main(['uninstall']), 0)

    def test_changed_launcher_not_deleted(self):
        manage.main(['install'])
        _, base = manage.paths()
        starter = base / 'bin/karaoke-formats'
        starter.write_text('own file', encoding='utf-8')
        with contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(manage.main(['uninstall']), 1)
        self.assertEqual(starter.read_text(), 'own file')

    def test_foreign_launcher_not_overwritten(self):
        _, base = manage.paths()
        starter = base / 'bin/karaoke-formats'
        starter.parent.mkdir(parents=True)
        starter.write_text('own file', encoding='utf-8')
        with contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(manage.main(['install']), 1)
        self.assertEqual(starter.read_text(), 'own file')

    def test_lock_prevents_parallel_install(self):
        _, base = manage.paths()
        (base / 'operation.lock').mkdir(parents=True)
        with contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(manage.main(['install']), 1)
        self.assertFalse((base / 'installed.json').exists())

    def test_low_disk_blocks_before_writes(self):
        usage = type('Usage', (), {'free': 1024})()
        with patch.object(manage.shutil, 'disk_usage', return_value=usage), contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(manage.main(['install']), 1)
        self.assertFalse(self.root.exists())

    def test_repo_workspace_rejected(self):
        with patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(ROOT)), contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(manage.main(['plan']), 1)


if __name__ == '__main__':
    unittest.main()
