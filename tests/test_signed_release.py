"""Offline-Vertragstests; Minisign wird gemockt, keine kryptografische Abnahme."""
from contextlib import nullcontext
import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


release = module('release_fixture', 'scripts/security/release_manifest.py')
updater = module('update_fixture', 'scripts/security/update_verified_release.py')
exporter = module('export_fixture', 'scripts/security/prepare_release.py')


class ManifestTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.artifacts = self.root / 'release'
        self.artifacts.mkdir()
        self.key = self.root / 'trusted.pub'
        self.key.write_text('MOCK KEY - not a real public key')
        self.data = dict(schema_version=1, tag='v1.2.3', commit='a' * 40, repo=release.REPO)
        (self.artifacts / 'install.sh').write_bytes(b'#!/bin/bash\nexit 0\n')
        (self.artifacts / 'SHA256SUMS.minisig').write_text('MOCK SIGNATURE')
        self.sign_fixture()
        self.runner = Mock(return_value=SimpleNamespace(returncode=0))

    def sign_fixture(self, raw=None):
        # Nur Pruefsummen-Fixture: erstellt absichtlich keine echte Signatur.
        (self.artifacts / 'release.json').write_text(raw or json.dumps(self.data))
        (self.artifacts / 'SHA256SUMS').write_text(''.join(
            hashlib.sha256((self.artifacts / name).read_bytes()).hexdigest() + '  ' + name + '\n'
            for name in ('install.sh', 'release.json')))

    def verify(self):
        return release.verify(self.artifacts, 'v1.2.3', self.key, runner=self.runner)

    def test_valid_contract_uses_independent_key_and_explicit_signature(self):
        self.assertEqual(self.verify(), self.data)
        args = self.runner.call_args.args[0]
        self.assertEqual(args[:2], ['minisign', '-Vm'])
        self.assertIn('-p', args)
        self.assertIn('-x', args)
        self.assertEqual(self.runner.call_args.kwargs['timeout'], 30)

    def test_invalid_signature_fails_closed(self):
        self.runner.return_value.returncode = 1
        with self.assertRaisesRegex(ValueError, 'Signatur'):
            self.verify()

    def test_payload_tampering_is_rejected(self):
        (self.artifacts / 'install.sh').write_text('tampered')
        with self.assertRaisesRegex(ValueError, 'Pruefsumme'):
            self.verify()

    def test_wrong_tag_repo_commit_and_schema_are_rejected(self):
        for field, value in [('tag', 'v2.0.0'), ('repo', 'https://evil.invalid'),
                             ('commit', '0' * 40), ('commit', '../escape'), ('schema_version', 2)]:
            with self.subTest(field=field, value=value):
                original = self.data[field]
                self.data[field] = value
                self.sign_fixture()
                with self.assertRaises(ValueError):
                    self.verify()
                self.data[field] = original

    def test_duplicate_json_keys_are_rejected(self):
        raw = json.dumps(self.data).replace('"schema_version": 1', '"schema_version": 1, "schema_version": 1')
        self.sign_fixture(raw)
        with self.assertRaisesRegex(ValueError, 'Doppelter'):
            self.verify()

    def test_extra_duplicate_or_traversal_checksums_are_rejected(self):
        original = (self.artifacts / 'SHA256SUMS').read_text()
        for extra in (original.splitlines()[0] + '\n', 'a' * 64 + '  ../escape\n'):
            (self.artifacts / 'SHA256SUMS').write_text(original + extra)
            with self.assertRaises(ValueError):
                self.verify()

    def test_release_supplied_key_is_rejected_before_signature_call(self):
        self.key = self.artifacts / 'trusted.pub'
        self.key.write_text('untrusted release key')
        with self.assertRaises(ValueError):
            self.verify()
        self.runner.assert_not_called()

    def test_mutable_originals_are_not_reread_after_signature(self):
        def change_originals(*args, **kwargs):
            for name in ('SHA256SUMS', 'release.json', 'install.sh'):
                (self.artifacts / name).write_text('changed during verification')
            return SimpleNamespace(returncode=0)
        self.runner.side_effect = change_originals
        self.assertEqual(self.verify(), self.data)

    def test_non_versioned_tag_is_rejected_before_signature_call(self):
        with self.assertRaises(ValueError):
            release.verify(self.artifacts, 'main', self.key, runner=self.runner)
        self.runner.assert_not_called()


class UpdateTests(unittest.TestCase):
    def setUp(self):
        self.manifest = dict(tag='v1.2.3', commit='a' * 40)
        self.calls = []
        self.dirty = False
        self.risky = False
        self.target = self.manifest['commit']
        self.fake = Mock()
        self.fake.SafetyError = updater.safety.SafetyError
        self.fake.repository.return_value = Path('fixture')
        self.fake.backup_path.return_value = Path('backups')
        self.fake.operation_lock.side_effect = lambda _: nullcontext()
        snapshot = Path('snapshot')
        self.fake.backup.side_effect = lambda *args: self.event('backup', snapshot)
        self.fake.verify.side_effect = lambda *args: self.event('verify', None)
        self.fake.git.side_effect = self.git
        self.addCleanup(patch.stopall)
        patch.object(updater, 'safety', self.fake).start()

    def event(self, name, result):
        self.calls.append(name)
        return result

    def git(self, repo, *args, **kwargs):
        if args[0] == 'status':
            output = b' M user-file' if self.dirty else b''
        elif args[:3] == ('config', '--get', 'remote.origin.url'):
            output = updater.REPO.encode()
        elif args[:2] == ('config', '--local'):
            output = b'http.proxy unreviewed' if self.risky else b''
        elif args[0] == 'rev-parse':
            output = self.target.encode()
        else:
            self.calls.append('fetch' if 'fetch' in args else args[0])
            self.assertNotIn('--force', args)
            output = b''
        return SimpleNamespace(stdout=output)

    def test_default_plan_never_fetches_backs_up_or_checks_out(self):
        result = updater.update('fixture', 'backups', self.manifest, fetch=True)
        self.assertEqual(result['status'], 'planned')
        self.assertEqual(self.calls, [])
        self.fake.collision_check.assert_not_called()

    def test_dirty_or_risky_repository_is_refused_before_backup(self):
        for field in ('dirty', 'risky'):
            setattr(self, field, True)
            with self.assertRaises(ValueError):
                updater.update('fixture', 'backups', self.manifest, apply=True)
            setattr(self, field, False)
        self.assertEqual(self.calls, [])

    def test_backup_and_verification_precede_fetch_and_checkout(self):
        with patch.object(updater.os, 'name', 'posix'):
            result = updater.update('fixture', 'backups', self.manifest, apply=True, fetch=True)
        self.assertEqual(self.calls, ['backup', 'verify', 'fetch', 'checkout'])
        self.assertEqual(result['status'], 'release-checked-out-not-runtime-tested')
        self.fake.collision_check.assert_called_once()

    def test_tag_mismatch_preserves_backup_and_never_checks_out(self):
        self.target = 'b' * 40
        with patch.object(updater.os, 'name', 'posix'):
            with self.assertRaisesRegex(ValueError, 'Tag/Commit'):
                updater.update('fixture', 'backups', self.manifest, apply=True, fetch=True)
        self.assertEqual(self.calls, ['backup', 'verify', 'fetch'])
        self.fake.collision_check.assert_not_called()


class ExportTests(unittest.TestCase):
    def test_export_reads_only_local_tag_and_produces_no_signature(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp).resolve()
            repo = root / 'repo'
            repo.mkdir()
            destination = root / 'artifacts'
            commit = b'a' * 40
            installer = b'#!/bin/bash\nexit 0\n'
            with patch.object(exporter.subprocess, 'run', side_effect=[
                    SimpleNamespace(stdout=commit + b'\n'), SimpleNamespace(stdout=installer)]) as run:
                self.assertEqual(exporter.prepare(repo, 'v1.2.3', destination), commit.decode())
            self.assertEqual(len(run.call_args_list), 2)
            for call in run.call_args_list:
                self.assertNotIn('fetch', call.args[0])
                self.assertNotIn('clone', call.args[0])
                self.assertEqual(call.kwargs['env']['GIT_CONFIG_GLOBAL'], exporter.os.devnull)
            self.assertEqual(set(p.name for p in destination.iterdir()),
                             {'install.sh', 'release.json', 'SHA256SUMS'})
            self.assertEqual((destination / 'install.sh').read_bytes(), installer)
            self.assertEqual(json.loads((destination / 'release.json').read_text())['commit'], commit.decode())
            expected = hashlib.sha256(installer).hexdigest() + '  install.sh'
            self.assertIn(expected, (destination / 'SHA256SUMS').read_text())

    def test_export_refuses_existing_or_inside_repository_destination(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp).resolve()
            existing = root / 'existing'
            existing.mkdir()
            with patch.object(exporter.subprocess, 'run') as run:
                for destination in (existing, root / 'inside'):
                    with self.assertRaises(ValueError):
                        exporter.prepare(root, 'v1.2.3', destination)
                run.assert_not_called()


class GitEnvironmentTests(unittest.TestCase):
    def test_git_environment_cannot_redirect_repository_or_inject_config(self):
        safety = module('release_safety_fixture', 'scripts/lib/repo_safety.py')
        injected = {key: 'UNTRUSTED' for key in ('GIT_DIR', 'GIT_WORK_TREE', 'GIT_CONFIG_PARAMETERS',
                    'GIT_CONFIG_COUNT', 'GIT_CONFIG_KEY_0', 'GIT_CONFIG_VALUE_0', 'GIT_EXEC_PATH', 'GIT_TRACE')}
        with patch.dict(safety.os.environ, injected):
            with patch.object(safety.subprocess, 'run', return_value=SimpleNamespace(returncode=0)) as run:
                safety.git(Path('fixture'), 'status', '--porcelain')
        env = run.call_args.kwargs['env']
        for key in injected:
            self.assertNotIn(key, env)
        self.assertEqual(env['GIT_CONFIG_NOSYSTEM'], '1')
        self.assertEqual(env['GIT_CONFIG_GLOBAL'], safety.os.devnull)


if __name__ == '__main__':
    unittest.main()
