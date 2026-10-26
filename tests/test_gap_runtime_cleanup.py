"""Offline readonly/partial-uninstall fixtures; no WSL or real installation."""
from contextlib import redirect_stdout
import io
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts/tools/helpers'))
import gap_tools as tools


class RuntimeCleanupTests(unittest.TestCase):
    def fixture(self):
        base, runtime, marker = tools.paths('perplexity_node')
        package = runtime / 'package'
        package.mkdir(parents=True)
        (package / 'package.json').write_text('{}')
        (package / 'index.js').write_text('fixture SDK')
        spec = tools.SPECS['perplexity_node']
        marker.write_text(json.dumps(dict(repo=spec['repo'], pin=spec['pin'], mode=spec['mode'],
            entries=['package/package.json', 'package/index.js'], files=tools.inventory(runtime))))
        (base / 'toolchain').mkdir()
        (base / 'toolchain/keep').write_text('keep prerequisites')
        return base, runtime, marker

    def git(self, runtime, *args):
        spec = tools.SPECS['perplexity_node']
        return spec['pin'] if args[:2] == ('rev-parse', 'HEAD') else 'https://github.com/' + spec['repo'] + '.git'

    def test_readonly_package_uninstalls_and_preserves_toolchain(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': directory}):
            base, runtime, marker = self.fixture()
            (runtime / 'package/package.json').chmod(0o444)
            (runtime / 'package').chmod(0o555)
            runtime.chmod(0o555)
            with patch.object(tools, 'git', side_effect=self.git), patch.object(tools, 'operation'), redirect_stdout(io.StringIO()):
                self.assertEqual(tools.main(['perplexity_node', 'uninstall']), 0)
            self.assertFalse(runtime.exists())
            self.assertFalse(marker.exists())
            self.assertEqual((base / 'toolchain/keep').read_text(), 'keep prerequisites')

    def test_partial_uninstall_requires_explicit_resume(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': directory}):
            base, runtime, marker = self.fixture()
            (runtime / 'package/package.json').unlink()
            with patch.object(tools, 'git', side_effect=self.git), patch.object(tools, 'operation'), patch.object(tools, 'remove_runtime_tree') as remove, redirect_stdout(io.StringIO()) as output:
                with self.assertRaisesRegex(ValueError, 'Installationsartefakt fehlt'):
                    tools.main(['perplexity_node', 'uninstall'])
                remove.assert_not_called()
            self.assertIn('--resume-uninstall', output.getvalue())
            with patch.object(tools, 'operation'), patch.object(tools, 'git') as git, redirect_stdout(io.StringIO()):
                self.assertEqual(tools.main(['perplexity_node', 'uninstall', '--resume-uninstall']), 0)
                git.assert_not_called()
            self.assertFalse(runtime.exists())
            self.assertFalse(marker.exists())
            self.assertTrue((base / 'toolchain/keep').is_file())

    def test_resume_rejects_changes_additions_or_invalid_proof(self):
        for change in ('changed', 'added', 'pin', 'missing-proof'):
            with self.subTest(change=change), tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': directory}):
                base, runtime, marker = self.fixture()
                if change == 'changed':
                    (runtime / 'package/index.js').write_text('own development')
                elif change == 'added':
                    (runtime / 'notes.txt').write_text('private notes')
                elif change == 'pin':
                    data = json.loads(marker.read_text())
                    data['pin'] = '0' * 40
                    marker.write_text(json.dumps(data))
                else:
                    marker.unlink()
                with patch.object(tools, 'operation'), patch.object(tools, 'remove_runtime_tree') as remove, redirect_stdout(io.StringIO()):
                    with self.assertRaises((ValueError, OSError)):
                        tools.main(['perplexity_node', 'uninstall', '--resume-uninstall'])
                    remove.assert_not_called()
                self.assertTrue(runtime.is_dir())
                self.assertTrue((base / 'toolchain/keep').exists())

    def test_failed_removal_retains_proof_for_resume(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': directory}):
            _, runtime, marker = self.fixture()
            def fail(path):
                (path / 'package/package.json').unlink()
                raise PermissionError('fixture busy file')
            with patch.object(tools, 'git', side_effect=self.git), patch.object(tools, 'operation'), patch.object(tools.shutil, 'rmtree', side_effect=fail), redirect_stdout(io.StringIO()):
                with self.assertRaises(PermissionError):
                    tools.main(['perplexity_node', 'uninstall'])
            self.assertTrue(marker.exists())
            with patch.object(tools, 'operation'), redirect_stdout(io.StringIO()):
                tools.main(['perplexity_node', 'uninstall', '--resume-uninstall'])
            self.assertFalse(marker.exists())

    def test_resume_dry_run_is_read_only(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': directory}):
            _, runtime, marker = self.fixture()
            before = tools.inventory(runtime)
            with patch.object(tools, 'remove_runtime_tree') as remove, redirect_stdout(io.StringIO()):
                self.assertEqual(tools.main(['perplexity_node', 'uninstall', '--resume-uninstall', '--dry-run']), 0)
                remove.assert_not_called()
            self.assertEqual(before, tools.inventory(runtime))
            self.assertTrue(marker.exists())

    def test_nonruntime_tree_is_never_changed(self):
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(ValueError, 'privaten Runtime-Ordner'):
                tools.remove_runtime_tree(Path(directory))
            self.assertTrue(Path(directory).exists())

    def test_foreign_owner_blocks_permission_changes_and_removal(self):
        with tempfile.TemporaryDirectory() as directory:
            runtime = Path(directory) / 'runtime'
            runtime.mkdir()
            foreign_uid = runtime.stat().st_uid + 1
            with patch.object(tools.os, 'geteuid', return_value=foreign_uid, create=True), patch.object(Path, 'chmod') as chmod, patch.object(tools.shutil, 'rmtree') as remove:
                with self.assertRaisesRegex(PermissionError, 'Fremder Dateieigentuemer'):
                    tools.remove_runtime_tree(runtime)
                chmod.assert_not_called()
                remove.assert_not_called()


if __name__ == '__main__':
    unittest.main()
