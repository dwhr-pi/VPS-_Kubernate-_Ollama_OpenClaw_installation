"""Offline fixtures only: no real keys, encryption prompts or SMTP traffic."""
import importlib.util
import io
import json
from pathlib import Path
import sys
import tarfile
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts/security'))
spec = importlib.util.spec_from_file_location('credentials_backup', ROOT / 'scripts/security/credentials_backup.py')
backup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(backup)


class CredentialsBackupTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.root = self.base / 'workspace'
        (self.root / 'env/demo').mkdir(parents=True)
        (self.root / 'env/demo/.env').write_bytes(b'DEMO_KEY=offline-fixture\n')
        self.settings = {'version': 1, 'paths': ['env'], 'sender': 'sender@example.org',
                         'recipient': 'receiver@example.org', 'hint': 'Separater Passwortmanager-Eintrag'}
        (self.root / backup.SETTINGS).write_text(json.dumps(self.settings))

    def test_pack_roundtrip_includes_settings_and_exact_selected_bytes(self):
        (self.root / 'unselected.env').write_bytes(b'not-selected')
        files = backup.unpack(backup.pack(self.root, self.settings))
        self.assertEqual(set(files), {'env/demo/.env', backup.SETTINGS})
        self.assertEqual(files['env/demo/.env'], b'DEMO_KEY=offline-fixture\n')
        self.assertEqual(json.loads(files[backup.SETTINGS]), self.settings)

    def test_invalid_selection_and_missing_file_refused(self):
        for name in ['../secret', '/etc/passwd', 'env/../x', 'env\\x', 'tools/x', 'backups', 'backups/x']:
            with self.subTest(name=name), self.assertRaises(backup.VaultError):
                backup.pack(self.root, {**self.settings, 'paths': [name]})
        with self.assertRaises(backup.VaultError):
            backup.pack(self.root, {**self.settings, 'paths': ['missing.env']})

    def test_email_header_injection_refused(self):
        for field in ('recipient', 'sender', 'hint'):
            with self.subTest(field=field), self.assertRaises(backup.VaultError):
                backup.settings_check({**self.settings, field: 'x\nBcc: other@example.org'})

    def test_tar_path_links_duplicates_and_corrupt_payload_refused(self):
        for name, kind in [('../escape', tarfile.REGTYPE), ('link', tarfile.SYMTYPE), ('link', tarfile.LNKTYPE)]:
            buffer = io.BytesIO()
            with tarfile.open(fileobj=buffer, mode='w') as archive:
                item = tarfile.TarInfo(name)
                item.type = kind
                archive.addfile(item)
            with self.subTest(name=name, kind=kind), self.assertRaises(backup.VaultError):
                backup.unpack(buffer.getvalue())
        payload = backup.pack(self.root, self.settings)
        with self.assertRaises(backup.VaultError):
            backup.unpack(payload.replace(b'offline-fixture', b'OFFLINE-FIXTURE'))

    def test_existing_outputs_never_overwritten(self):
        target = self.base / 'existing.tar.age'
        target.write_bytes(b'original')
        with self.assertRaises(FileExistsError):
            backup.new_file(target, b'new')
        self.assertEqual(target.read_bytes(), b'original')

    def test_duplicate_tar_names_rejected(self):
        buffer = io.BytesIO()
        with tarfile.open(fileobj=buffer, mode='w') as archive:
            archive.addfile(tarfile.TarInfo('duplicate'))
            archive.addfile(tarfile.TarInfo('duplicate'))
        with self.assertRaises(backup.VaultError):
            backup.unpack(buffer.getvalue())

    def test_symlink_source_rejected(self):
        link = self.root / 'env/link'
        try:
            link.symlink_to(self.root / 'env/demo/.env')
        except OSError:
            self.skipTest('Symlink privilege unavailable; checked on Ubuntu CI')
        with self.assertRaises(backup.VaultError):
            backup.pack(self.root, self.settings)

    def test_export_uses_age_and_no_plaintext_tar_file(self):
        target = self.base / 'external.tar.age'
        with patch.object(backup, 'age_run', return_value=b'age-encryption.org/v1\nfixture') as age:
            backup.export(self.root, target)
        self.assertEqual(age.call_args.args[0], ['--passphrase'])
        self.assertIn('env/demo/.env', backup.unpack(age.call_args.args[1]))
        self.assertEqual(target.read_bytes(), b'age-encryption.org/v1\nfixture')
        self.assertFalse(list(self.base.glob('*.tar')))

    def test_failed_encryption_does_not_export(self):
        target = self.base / 'failure.tar.age'
        with patch.object(backup, 'age_run', side_effect=backup.VaultError('aborted')):
            with self.assertRaises(backup.VaultError):
                backup.export(self.root, target)
        self.assertFalse(target.exists())

    def test_recover_check_readonly_then_isolated_restore(self):
        source = self.base / 'backup.tar.age'
        source.write_bytes(b'encrypted-fixture')
        target = self.base / 'recovery'
        original = (self.root / 'env/demo/.env').read_bytes()
        with patch.object(backup, 'age_run', return_value=backup.pack(self.root, self.settings)):
            backup.recover(source, target)
            self.assertFalse(target.exists())
            backup.recover(source, target, True)
            with self.assertRaises(backup.VaultError):
                backup.recover(source, target, True)
        self.assertEqual((target / 'env/demo/.env').read_bytes(), original)
        self.assertEqual((self.root / 'env/demo/.env').read_bytes(), original)

    def test_mail_draft_contains_only_encrypted_attachment_and_explicit_hint(self):
        source = self.base / 'backup.tar.age'
        source.write_bytes(b'age-encryption.org/v1\nfixture')
        target = self.base / 'backup.eml'
        with patch.object(backup.subprocess, 'run') as run:
            backup.mail(source, self.settings, target)
        run.assert_not_called()
        from email.parser import BytesParser
        message = BytesParser(policy=backup.SMTP).parsebytes(target.read_bytes())
        body = message.get_body().get_content()
        self.assertIn(self.settings['hint'], body)
        for instruction in ['wsl --list --verbose', 'wsl -d Ubuntu',
                            '/mnt/d/Setup-Sicherung/credentials.tar.age',
                            '$HOME/Downloads/credentials.tar.age',
                            'age --decrypt --output', 'tar -tf', 'tar -xOf',
                            '--confirm-restore', 'Ordnerrechte 0700, Dateirechte 0600',
                            'https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/blob/main/docs/CREDENTIALS_BACKUP.md',
                            'https://github.com/FiloSottile/age/releases']:
            self.assertIn(instruction, body)
        self.assertEqual(next(message.iter_attachments()).get_payload(decode=True), source.read_bytes())
        self.assertNotIn(b'offline-fixture', target.read_bytes())

    def test_mail_requires_consent_and_tls_without_network(self):
        source = self.base / 'backup.tar.age'
        source.write_bytes(b'age-encryption.org/v1\nfixture')
        with patch.object(backup.subprocess, 'run') as run:
            with self.assertRaises(backup.VaultError):
                backup.mail(source, self.settings)
            run.assert_not_called()
            run.return_value.returncode = 0
            with patch.object(backup.shutil, 'which', return_value='/fixture/msmtp'):
                backup.mail(source, self.settings, confirmed=True)
            self.assertIn('--tls=on', run.call_args.args[0])
            self.assertIn('--tls-starttls=on', run.call_args.args[0])
            self.assertIn('--tls-certcheck=on', run.call_args.args[0])
            self.assertEqual(run.call_args.args[0][-1], 'receiver@example.org')
            from email.parser import BytesParser
            sent = BytesParser(policy=backup.SMTP).parsebytes(run.call_args.kwargs['input'])
            self.assertIn('ANLEITUNG: credentials.tar.age', sent.get_body().get_content())
            self.assertIn('/blob/main/docs/CREDENTIALS_BACKUP.md', sent.get_body().get_content())

    def test_documentation_covers_manual_activation_and_platforms(self):
        doc = (ROOT / 'docs/CREDENTIALS_BACKUP.md').read_text(encoding='utf-8')
        for instruction in ['Windows nach WSL', 'Nur Linux', 'Windows ohne WSL',
                            'Kontrolliert aktivieren', 'cp -i', 'chmod 600',
                            'credentials-before.', 'tar -xOf', 'kein `source`/`eval`',
                            'Dateirechte', 'Mailtext selbst']:
            self.assertIn(instruction, doc)


if __name__ == '__main__':
    unittest.main()
