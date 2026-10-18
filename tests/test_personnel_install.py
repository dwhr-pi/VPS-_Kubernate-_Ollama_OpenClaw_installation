"""Private temporary launchers and synthetic fixtures only; no WSL/services."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('personnel_manage', ROOT / 'tools/personnel_documents/manage.py')
manage = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(manage)


class Installer(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        root = Path(self.temp.name).resolve()
        self.private = root / 'private'
        self.base = self.private / 'tools/personnel_documents'
        self.source = root / 'checkout/tools/personnel_documents/pipeline.py'
        self.fixture = root / 'checkout/examples/personnel_documents/proposal.json'
        self.source.parent.mkdir(parents=True)
        self.fixture.parent.mkdir(parents=True)
        self.source.write_text((ROOT / 'tools/personnel_documents/pipeline.py').read_text(encoding='utf-8'), encoding='utf-8')
        self.fixture.write_text((ROOT / 'examples/personnel_documents/proposal.json').read_text(encoding='utf-8'), encoding='utf-8')
        for p in (patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(self.private)),
                  patch.object(manage, 'SOURCE', self.source), patch.object(manage, 'FIXTURE', self.fixture)):
            p.start()
            self.addCleanup(p.stop)

    def run_mode(self, mode):
        out, err = io.StringIO(), io.StringIO()
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
            rc = manage.main([mode])
        return rc, out.getvalue(), err.getvalue()

    def test_plan_and_missing_status_are_read_only(self):
        for mode in ('plan', 'status'):
            rc, out, err = self.run_mode(mode)
            self.assertEqual(rc, 0, err)
            self.assertFalse(json.loads(out)['installed'])
            self.assertFalse(self.private.exists())
        self.assertEqual(self.run_mode('doctor')[0], 1)

    def test_install_repeat_and_offline_launcher(self):
        self.assertEqual(self.run_mode('install')[0], 0)
        self.assertTrue(manage.installed(self.base))
        launcher = self.base / 'bin/personnel-documents-ai'
        before = launcher.read_bytes()
        self.assertEqual(self.run_mode('install')[0], 0)
        self.assertEqual(launcher.read_bytes(), before)
        result = subprocess.run([sys.executable, '-I', '-B', str(launcher), 'validate', '--input', str(self.fixture)],
                                capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(json.loads(result.stdout)['human_review_required'])
        self.assertFalse(json.loads(result.stdout)['applied'])
        logs = list((self.private / 'install_logs').glob('*.log'))
        self.assertTrue(logs)
        self.assertIn('Disk frei vorher:', logs[0].read_text())
        self.assertIn('Disk frei nachher:', logs[0].read_text())

    def test_source_change_requires_explicit_update(self):
        self.assertEqual(self.run_mode('install')[0], 0)
        self.source.write_text(self.source.read_text() + '\n# synthetic change\n', encoding='utf-8')
        self.assertEqual(self.run_mode('doctor')[0], 1)
        result = subprocess.run([sys.executable, '-I', '-B', str(self.base / 'bin/personnel-documents-ai'), 'plan'],
                                capture_output=True, text=True, timeout=30)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.run_mode('update')[0], 0)
        self.assertTrue(manage.installed(self.base))

    def test_fixture_change_detected_and_repaired(self):
        self.assertEqual(self.run_mode('install')[0], 0)
        self.fixture.write_text(self.fixture.read_text() + '\n', encoding='utf-8')
        self.assertFalse(manage.installed(self.base))
        self.assertEqual(self.run_mode('--repair')[0], 0)
        self.assertTrue(manage.installed(self.base))

    def test_foreign_launcher_preserved(self):
        launcher = self.base / 'bin/personnel-documents-ai'
        launcher.parent.mkdir(parents=True)
        launcher.write_text('foreign-starter')
        self.assertEqual(self.run_mode('install')[0], 1)
        self.assertEqual(launcher.read_text(), 'foreign-starter')

    def test_modified_launcher_never_overwritten_or_deleted(self):
        self.assertEqual(self.run_mode('install')[0], 0)
        launcher = self.base / 'bin/personnel-documents-ai'
        launcher.write_text('own-starter')
        for mode in ('update', 'uninstall'):
            self.assertEqual(self.run_mode(mode)[0], 1)
            self.assertEqual(launcher.read_text(), 'own-starter')

    def test_uninstall_preserves_source_and_own_files(self):
        self.assertEqual(self.run_mode('install')[0], 0)
        own = self.base / 'own-synthetic-data'
        own.write_text('keep')
        self.assertEqual(self.run_mode('uninstall')[0], 0)
        self.assertFalse((self.base / 'bin/personnel-documents-ai').exists())
        self.assertFalse((self.base / 'installed.json').exists())
        self.assertTrue(self.source.exists())
        self.assertEqual(own.read_text(), 'keep')

    def test_low_disk_blocks_before_writes(self):
        with patch.object(manage.shutil, 'disk_usage', return_value=SimpleNamespace(free=1)):
            self.assertEqual(self.run_mode('install')[0], 1)
        self.assertFalse(self.private.exists())

    def test_bad_workspace_rejected(self):
        for root in ('relative', str(ROOT / 'private'), str(Path(self.temp.name).anchor)):
            with patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=root):
                self.assertEqual(self.run_mode('plan')[0], 1)

    def test_lock_prevents_parallel_operation(self):
        self.base.mkdir(parents=True)
        lock = self.base / 'operation.lock'
        lock.mkdir()
        self.assertEqual(self.run_mode('install')[0], 1)
        self.assertTrue(lock.is_dir())
        self.assertFalse((self.base / 'bin').exists())

    def test_registry_and_wrapper_use_checkout_manager(self):
        entries = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        tool, = [t for t in entries if t['id'] == 'personnel_documents']
        self.assertIn('dwhr-pi/', tool['source'])
        self.assertFalse(tool['auto_install'])
        self.assertEqual(tool['ports'], [])
        helper = (ROOT / 'scripts/tools/helpers/personnel_documents_common.sh').read_text()
        self.assertIn('personnel_documents/manage.py', helper)
        self.assertNotIn('docker', helper)
        self.assertNotIn('pip install', helper)


if __name__ == '__main__':
    unittest.main()
