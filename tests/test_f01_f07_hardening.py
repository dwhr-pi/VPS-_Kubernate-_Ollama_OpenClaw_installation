"""Offline synthetic fixtures only; never install, read credentials or contact services."""
import contextlib
import hashlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]


def load(name):
    spec = importlib.util.spec_from_file_location(name, ROOT / 'scripts/security' / (name + '.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


private = load('private_env')
monitoring = load('native_monitoring_config')
backup = load('native_export_backup')
triage = load('history_secret_triage')


class Hardening(unittest.TestCase):
    def test_source_build_recipes_are_fixed_and_native(self):
        entries = json.loads((ROOT / 'config/docker_to_github.json').read_text(encoding='utf-8'))['tools']
        for key in ('argocd_cli', 'cloudflared'):
            row = next(item for item in entries if item['id'] == key)
            self.assertRegex(row['recipe']['pin'], '^[0-9a-f]{40}$')
            self.assertEqual(row['recipe']['kind'], 'go')
            text = (ROOT / f'scripts/tools/{key}_install.sh').read_text(encoding='utf-8')
            self.assertIn('native_github_tools.py', text)
            for forbidden in ('sudo', 'curl ', 'dpkg ', 'releases/latest', 'systemctl'):
                self.assertNotIn(forbidden, text)

    def test_legacy_removal_wrappers_do_not_delete_or_report_removal(self):
        for key in ('k3s', 'clawbake'):
            text = (ROOT / f'scripts/tools/{key}_uninstall.sh').read_text(encoding='utf-8')
            self.assertIn(f'legacy_core_uninstall.py', text)
            self.assertIn(f'"$HELPER" {key} "$@"', text)
            for forbidden in ('sudo', 'rm -', 'source ', 'mark_current_tool_removed', '|| true'):
                self.assertNotIn(forbidden, text)

    def test_docker_installation_does_not_run_commands(self):
        text = (ROOT / 'scripts/tools/docker_install.sh').read_text(encoding='utf-8')
        self.assertIn('exit 1', text)
        for forbidden in ('curl ', 'sudo ', 'source ', 'mark_current_tool_installed'):
            self.assertNotIn(forbidden, text)
        for name, function in (('docker_compose_tool_common.sh', 'ensure_docker_compose'),
                               ('simple_tool_common.sh', 'ensure_docker_compose_available')):
            text = (ROOT / 'scripts/tools/helpers' / name).read_text(encoding='utf-8')
            body = text.split(function + '() {', 1)[1].split('\n}', 1)[0]
            self.assertIn('return 1', body)
            for forbidden in ('sudo ', 'curl ', 'apt-get ', 'docker compose version'):
                self.assertNotIn(forbidden, body)
        ansible = (ROOT / 'ansible/vps_bootstrap.yml').read_text(encoding='utf-8')
        self.assertNotIn('download.docker.com', ansible)
        self.assertNotIn('docker-ce', ansible)
        for path, call in (('github_docker_stack_common.sh', 'ensure_docker_compose'),
                           ('simple_tool_common.sh', 'ensure_docker_compose_available')):
            text = (ROOT / 'scripts/tools/helpers' / path).read_text(encoding='utf-8')
            self.assertIn(call + ' || return 1', text)

    def test_monitoring_rejects_public_invalid_and_dns_targets(self):
        for target in ('8.8.8.8:4000', '0.0.0.0:4000', '100.64.1.2:0', 'host:4000',
                       '10.0.0.1:65536', '169.254.169.254:80', '[::]:4000'):
            with self.subTest(target=target), self.assertRaises(ValueError):
                monitoring.endpoint(target)
        for target in ('10.10.0.2:4000', '127.0.0.1:9100', '[fd00::2]:9210'):
            self.assertEqual(monitoring.endpoint(target), target)

    def test_monitoring_routes_alerts_and_keeps_secrets_in_files(self):
        prom, alert = monitoring.configurations('10.0.0.2:4000', '127.0.0.1:9100', '10.0.0.3:9210',
                                                '/private/token', '/private/receiver', '/repo/alerts.yml')
        self.assertIn('alertmanagers', prom['alerting'])
        self.assertEqual(alert['receivers'][0]['webhook_configs'][0]['url_file'], '/private/receiver')
        self.assertNotIn('credentials', prom['scrape_configs'][1]['authorization'])

    def test_plans_do_not_read_files_start_processes_or_notify(self):
        for module, args in ((monitoring, []), (backup, ['backup']), (backup, ['restore']), (triage, [])):
            with mock.patch.object(subprocess, 'run', side_effect=AssertionError('No processes')), \
                 contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(module.main(args), 3)

    def test_secret_triage_never_emits_match_or_value(self):
        rows = triage.metadata([{'RuleID': 'generic-api-key', 'Commit': 'a' * 40,
                                 'StartLine': 2, 'File': 'example.env',
                                 'Secret': 'SYNTHETIC-SENSITIVE-VALUE', 'Match': 'SYNTHETIC-SENSITIVE-VALUE'}])
        self.assertNotIn('SYNTHETIC-SENSITIVE-VALUE', json.dumps(rows))
        self.assertEqual(rows[0]['credential_validity'], 'not-tested')
        with self.assertRaises(ValueError):
            triage.metadata([{'RuleID': 'unsafe value', 'Commit': 'a' * 40, 'StartLine': 2}])

    def test_restic_partial_backup_is_not_success(self):
        for rc in (1, 3, 10):
            with mock.patch.object(subprocess, 'run', return_value=subprocess.CompletedProcess([], rc)), \
                 self.assertRaises(ValueError):
                backup.restic('/fixture/restic', ['backup'], {}, Path('.'))

    def test_restic_env_is_literal_and_excludes_inherited_hooks(self):
        env_path = ROOT / 'synthetic-not-read.env'
        password = ROOT / 'synthetic-not-read.password'
        content = ('RESTIC_REPOSITORY=s3:https://backup.example.invalid/bucket\n'
                   f'RESTIC_PASSWORD_FILE={password}\n'
                   'AWS_ACCESS_KEY_ID=SYNTHETIC\nAWS_SECRET_ACCESS_KEY=SYNTHETIC\n')
        def read(path):
            return content.encode() if path == env_path else b'synthetic'
        with mock.patch.object(backup.private, 'read_private', side_effect=read), \
             mock.patch.dict(os.environ, {'RESTIC_PASSWORD_COMMAND': 'must-not-run', 'AWS_PROFILE': 'must-not-read'}):
            env = backup.environment(env_path)
        self.assertNotIn('RESTIC_PASSWORD_COMMAND', env)
        self.assertNotIn('AWS_PROFILE', env)
        self.assertEqual(env['AWS_SHARED_CREDENTIALS_FILE'], '/dev/null')
        with mock.patch.object(backup.private, 'read_private', return_value=b'RESTIC_PASSWORD_COMMAND=never\n'), \
             self.assertRaises(ValueError):
            backup.environment(env_path)

    def test_local_backup_retains_partial_marker_until_last_step(self):
        text = (ROOT / 'scripts/operations/backup_run.sh').read_text(encoding='utf-8')
        self.assertLess(text.index('>"$TARGET_DIR/.backup-incomplete"'), text.index('installation_inventory.py'))
        self.assertGreater(text.index('mv -- "$TARGET_DIR/.backup-incomplete"'), text.index('cp "$VAULT_FILE"'))
        self.assertIn('nicht als Ganzes verschluesselt', text)


@unittest.skipUnless(os.name == 'posix' and hasattr(os, 'O_NOFOLLOW'), 'Native POSIX dirfd tests; no WSL fallback')
class PrivateFiles(unittest.TestCase):
    def test_existing_linked_template_cannot_be_opened_by_manager(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp).resolve()
            workspace = root / 'workspace'
            workspace.mkdir(mode=0o700)
            templates = workspace / 'llmops-platform'
            templates.mkdir(mode=0o700)
            other = root / 'outside'
            other.write_bytes(b'SYNTHETIC=unchanged')
            (templates / '.env.template').symlink_to(other)
            with contextlib.redirect_stderr(io.StringIO()):
                rc = private.main(['prepare', '--workspace', str(workspace), '--repo', str(ROOT),
                                   '--source', str(other)])
            self.assertEqual(rc, 1)
            self.assertEqual(other.read_bytes(), b'SYNTHETIC=unchanged')

    def test_atomic_private_publication_and_no_implicit_overwrite(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp).resolve()
            os.chmod(root, 0o700)
            with private.directory(root, private=True) as fd:
                private.publish(fd, '.env', b'SYNTHETIC=one\n')
                self.assertEqual((root / '.env').stat().st_mode & 0o777, 0o600)
                with self.assertRaises(ValueError):
                    private.publish(fd, '.env', b'SYNTHETIC=two\n')
                self.assertEqual((root / '.env').read_bytes(), b'SYNTHETIC=one\n')
                private.publish(fd, '.env', b'SYNTHETIC=two\n', replace=True)
                self.assertEqual((root / '.env').read_bytes(), b'SYNTHETIC=two\n')
                self.assertFalse(list(root.glob('.pending-*')))

    def test_symlink_and_hardlink_env_are_refused(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp).resolve()
            target = root / 'outside'
            target.write_bytes(b'SYNTHETIC=private')
            target.chmod(0o600)
            link = root / '.env'
            link.symlink_to(target)
            with self.assertRaises(OSError):
                private.read_private(link)
            with private.directory(root, private=True) as fd, self.assertRaises(ValueError):
                private.publish(fd, '.env', b'never', replace=True)
            link.unlink()
            os.link(target, link)
            with self.assertRaises(ValueError):
                private.read_private(link)
            self.assertEqual(target.read_bytes(), b'SYNTHETIC=private')

    def test_export_manifest_detects_partial_extra_corrupt_and_linked_files(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp).resolve()
            rows = {}
            for service in ('postgres', 'qdrant', 'minio'):
                directory = root / service
                directory.mkdir(mode=0o700)
                payload = directory / 'synthetic-export'
                payload.write_bytes(b'synthetic')
                payload.chmod(0o600)
                rows[f'{service}/synthetic-export'] = {'size': 9, 'sha256': hashlib.sha256(b'synthetic').hexdigest()}
            manifest = root / 'backup-manifest.json'
            manifest.write_text(json.dumps({'schema': 1, 'files': rows}))
            manifest.chmod(0o600)
            result = backup.verify_exports(root)
            self.assertTrue(result['file_integrity_verified'])
            self.assertFalse(result['database_restore_verified'])
            extra = root / 'extra'
            extra.write_bytes(b'extra')
            with self.assertRaises(ValueError):
                backup.verify_exports(root)
            extra.unlink()
            payload.write_bytes(b'corrupted')
            with self.assertRaises(ValueError):
                backup.verify_exports(root)


if __name__ == '__main__':
    unittest.main()
