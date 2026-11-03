"""Synthetic metadata fixtures; no private workspace, Git fetch or agent execution."""
import contextlib
import importlib.util
import io
import os
from pathlib import Path
import stat
import subprocess
import tempfile
from types import SimpleNamespace
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('coding_profile_metadata', ROOT / 'scripts/profiles/coding_agents.py')
agents = importlib.util.module_from_spec(spec)
spec.loader.exec_module(agents)


class MetadataTests(unittest.TestCase):
    def test_posix_mode_owner_and_type_checks_without_real_files(self):
        path = mock.Mock()
        for directory, mode, owner, links, valid in (
                (True, stat.S_IFDIR | 0o700, 1000, 2, True),
                (True, stat.S_IFDIR | 0o777, 1000, 2, False),
                (True, stat.S_IFDIR | 0o700, 2000, 2, False),
                (False, stat.S_IFREG | 0o600, 1000, 1, True),
                (False, stat.S_IFREG | 0o666, 1000, 1, False),
                (False, stat.S_IFREG | 0o600, 2000, 1, False),
                (False, stat.S_IFREG | 0o600, 1000, 2, False),
                (False, stat.S_IFIFO | 0o600, 1000, 1, False)):
            info = SimpleNamespace(st_mode=mode, st_uid=owner, st_nlink=links)
            path.lstat.return_value = info
            with mock.patch.object(agents, 'safe', return_value=path), \
                 mock.patch.object(agents.os, 'name', 'posix'), \
                 mock.patch.object(agents.os, 'getuid', return_value=1000, create=True):
                if valid:
                    self.assertIs(agents.metadata(path, directory=directory), info)
                else:
                    with self.assertRaises(ValueError):
                        agents.metadata(path, directory=directory)

    def test_repeated_install_rejects_hardlinks_and_preserves_payloads(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp).resolve() / 'private'
            with mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(root)), \
                 contextlib.redirect_stdout(io.StringIO()):
                agents.profile_action('Jarvis_Core', 'install')
                target = root / 'agent_profiles/Jarvis_Core/profile.json'
                before = target.read_bytes()
                try:
                    os.link(target, root / 'peer')
                except OSError:
                    self.skipTest('Native hardlinks unavailable; no WSL fallback')
                for action in ('install', 'update', 'check', 'uninstall'):
                    with self.assertRaises(ValueError):
                        agents.profile_action('Jarvis_Core', action)
                self.assertEqual(target.read_bytes(), before)
                self.assertEqual((root / 'peer').read_bytes(), before)
                self.assertTrue(target.with_name('installed.json').is_file())

    @unittest.skipUnless(os.name == 'posix', 'Actual POSIX permissions require native Unix')
    def test_insecure_existing_permissions_are_not_repaired_or_accepted(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp).resolve() / 'private'
            with mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(root)), \
                 contextlib.redirect_stdout(io.StringIO()):
                agents.profile_action('Jarvis_Core', 'install')
                target = root / 'agent_profiles/Jarvis_Core/profile.json'
                target.chmod(0o666)
                before = target.read_bytes()
                with self.assertRaises(ValueError):
                    agents.profile_action('Jarvis_Core', 'update')
                self.assertEqual(target.stat().st_mode & 0o777, 0o666)
                self.assertEqual(target.read_bytes(), before)
                target.chmod(0o600)
                target.parent.chmod(0o777)
                with self.assertRaises(ValueError):
                    agents.profile_action('Jarvis_Core', 'install')
                self.assertEqual(target.parent.stat().st_mode & 0o777, 0o777)
                target.parent.chmod(0o700)

    def test_new_file_is_exclusive_and_git_timeout_does_not_leak_details(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp).resolve()
            with mock.patch.object(agents.os, 'open', wraps=os.open) as opened:
                agents.write_new_or_same(root / 'example.json', b'synthetic\n')
            flags = opened.call_args.args[1]
            self.assertTrue(flags & os.O_EXCL)
            self.assertEqual(opened.call_args.args[2], 0o600)
            with mock.patch.object(agents.subprocess, 'run', side_effect=subprocess.TimeoutExpired('SYNTHETIC-SENTINEL', 120)):
                with self.assertRaises(subprocess.TimeoutExpired):
                    agents.git(root, 'status', '--porcelain')
            with mock.patch.object(agents, 'git', side_effect=subprocess.TimeoutExpired('SYNTHETIC-SENTINEL', 120)):
                (root / '.git').mkdir()
                self.assertFalse(agents.source_ok(root, {'github': 'fixture', 'commit': 'a' * 40}))
            error = io.StringIO()
            with mock.patch.object(agents, 'source_action', side_effect=subprocess.TimeoutExpired('SYNTHETIC-SENTINEL', 120)), \
                 contextlib.redirect_stderr(error):
                self.assertEqual(agents.main(['source', 'gemini_cli', 'install']), 2)
            self.assertNotIn('SYNTHETIC-SENTINEL', error.getvalue())


if __name__ == '__main__':
    unittest.main()
