"""Offline Qwen study fixtures; no real download, compiler or desktop execution."""
from contextlib import redirect_stdout
import io
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts/tools/helpers'))
import qwen_desktop_study as study


class QwenStudyTests(unittest.TestCase):
    def test_plan_and_absent_status_are_read_only(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': directory}), patch.object(study.common, 'git') as git, patch.object(study.common, 'run') as run:
            with redirect_stdout(io.StringIO()) as output:
                self.assertEqual(study.main(['install', '--build-desktop', '--dry-run']), 0)
                self.assertEqual(study.main(['status']), 0)
            self.assertIn('Studienzwecke und Weiterentwicklung', output.getvalue())
            self.assertIn('"scope": "study-sources"', output.getvalue())
            self.assertEqual(list(Path(directory).iterdir()), [])
            git.assert_not_called()
            run.assert_not_called()

    def test_separate_build_sources_and_proof(self):
        for system in ('Linux', 'Windows'):
            with self.subTest(system=system), tempfile.TemporaryDirectory() as directory:
                base = Path(directory)
                runtime = base / 'runtime'
                runtime.mkdir()
                (runtime / 'README.md').write_text('fixture original')
                entries = ['packages/desktop/src-tauri/target/release/qwen-code-desktop',
                           'packages/desktop/runtime/qwen-code/manifest.json',
                           'packages/desktop/src-tauri/target/release/bundle/appimage/local.AppImage']
                def fake_build(source, env):
                    self.assertEqual(source, base / 'development/source')
                    self.assertNotIn('OPENAI_API_KEY', env)
                    for entry in entries:
                        path = source / entry
                        path.parent.mkdir(parents=True, exist_ok=True)
                        path.write_bytes(b'fixture output')
                    return entries
                with patch.dict(os.environ, {'OPENAI_API_KEY': 'fixture'}), patch.object(study.common, 'validate'), patch.object(study, 'preflight'), patch.object(study.platform, 'system', return_value=system), patch.object(study.common, 'qwen_build', side_effect=fake_build) as builder:
                    study.build(base, runtime, base / 'ready.json')
                    self.assertTrue(study.build_status(base))
                    study.build(base, runtime, base / 'ready.json')
                    self.assertEqual(builder.call_count, 1)
                self.assertEqual((runtime / 'README.md').read_text(), 'fixture original')
                self.assertFalse((runtime / 'packages').exists())
                record = json.loads((base / 'desktop-build.json').read_text())
                self.assertFalse(record['application_tested'])
                (base / 'development/source' / entries[0]).write_bytes(b'changed')
                self.assertFalse(study.build_status(base))

    def test_failed_build_keeps_development_but_no_success_marker(self):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            runtime = base / 'runtime'
            runtime.mkdir()
            with patch.object(study.common, 'validate'), patch.object(study, 'preflight'), patch.object(study.common, 'qwen_build', side_effect=ValueError('fixture compiler failure')):
                with self.assertRaisesRegex(ValueError, 'compiler failure'):
                    study.build(base, runtime, base / 'ready.json')
            self.assertTrue((base / 'development/source').is_dir())
            self.assertFalse((base / 'desktop-build.json').exists())
            self.assertTrue(runtime.is_dir())

    def test_existing_development_is_never_overwritten(self):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            (base / 'development').mkdir()
            note = base / 'development/notes.txt'
            note.write_text('keep')
            with patch.object(study.common, 'validate'), patch.object(study, 'preflight'), patch.object(study.common, 'qwen_build') as builder:
                with self.assertRaisesRegex(ValueError, 'Entwicklungsdaten vorhanden'):
                    study.build(base, base / 'runtime', base / 'ready.json')
                builder.assert_not_called()
            self.assertEqual(note.read_text(), 'keep')

    def test_uninstall_blocks_development_data(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': directory}):
            base, runtime, marker = study.common.paths(study.KEY)
            (base / 'development').mkdir(parents=True)
            with patch.object(study.common, 'operation'), patch.object(study.shutil, 'rmtree') as remove:
                with self.assertRaisesRegex(ValueError, 'Entwicklungs-/Builddaten vorhanden'):
                    study.main(['uninstall'])
                remove.assert_not_called()

    def test_build_space_preflight_precedes_checkout(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': directory}), patch.object(study.common, 'operation'), patch.object(study, 'preflight', side_effect=ValueError('fixture disk full')), patch.object(study.common, 'install') as install:
            with self.assertRaisesRegex(ValueError, 'disk full'):
                study.main(['install', '--build-desktop'])
            install.assert_not_called()

    def test_paths_cannot_escape_development(self):
        with tempfile.TemporaryDirectory() as directory:
            for relative in ('../../escape', '/tmp/file', 'packages/desktop/../../escape',
                             'packages/desktop/C:/escape', 'packages/desktop/..\\escape'):
                with self.subTest(relative=relative), self.assertRaisesRegex(ValueError, 'Buildpfad'):
                    study.artifact(Path(directory), relative)


if __name__ == '__main__':
    unittest.main()
