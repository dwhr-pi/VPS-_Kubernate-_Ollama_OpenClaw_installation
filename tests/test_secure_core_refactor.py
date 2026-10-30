"""Offline-Vertraege, keine Installation, Entschluesselung oder S3-Verbindung."""
import importlib.util
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('sops_core_env', ROOT / 'scripts/security/decrypt_sops_env.py')
sops_env = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(sops_env)
BASH = 'C:/Program Files/Git/bin/bash.exe' if sys.platform == 'win32' else shutil.which('bash')


def ciphertext():
    return {'data': 'ENC[AES256_GCM,MOCK-NOT-REAL]', 'sops': {
        'age': [{'recipient': 'age1' + 'a' * 58, 'enc': 'MOCK-NOT-REAL'}],
        'mac': 'ENC[AES256_GCM,MOCK-NOT-REAL]', 'version': '3.12.0', 'kms': [], 'pgp': []}}


class SopsEnvTests(unittest.TestCase):
    def test_ciphertext_gate_allows_only_age_and_rejects_duplicates(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / 'env.enc.json'
            path.write_text(json.dumps(ciphertext()))
            self.assertEqual(sops_env.envelope(path), path)
            for field in ('kms', 'hckms', 'pgp', 'key_groups', 'unknown_service'):
                data = ciphertext()
                data['sops'][field] = [{'key': 'mock'}]
                path.write_text(json.dumps(data))
                with self.subTest(field=field), self.assertRaises(ValueError):
                    sops_env.envelope(path)
            path.write_text('{"data":"first","data":"second","sops":{}}')
            with self.assertRaises(ValueError):
                sops_env.envelope(path)

    def test_literal_env_is_never_a_shell_script(self):
        self.assertEqual(sops_env.validate_env(b'OPENAI_API_KEY=fixture-value\n'), b'OPENAI_API_KEY=fixture-value\n')
        for value in (b'LD_PRELOAD=/tmp/evil\n', b'OPENAI_API_KEY=$(id)\n',
                      b'OPENAI_API_KEY=a\nOPENAI_API_KEY=b\n', b'OPENAI_API_KEY=REPLACE\n', b'export OPENAI_API_KEY=abc\n'):
            with self.subTest(value=value), self.assertRaises(ValueError):
                sops_env.validate_env(value)

    @unittest.skipUnless(sys.platform == 'linux', 'Linux-Dateirechte erforderlich')
    def test_decrypt_writes_0600_without_overwriting_and_suppresses_errors(self):
        with tempfile.TemporaryDirectory() as temp:
            base = Path(temp)
            workspace = base / 'workspace'
            workspace.mkdir(mode=0o700)
            identity = base / 'identity.txt'
            identity.write_text('MOCK-IDENTITY')
            identity.chmod(0o600)
            encrypted = base / 'core.enc.json'
            encrypted.write_text(json.dumps(ciphertext()))
            result = subprocess.CompletedProcess([], 0, b'OPENAI_API_KEY=fixture-value\n', b'')
            with patch.object(sops_env.subprocess, 'run', return_value=result) as run:
                sops_env.decrypt_to_workspace(encrypted, identity, workspace, 'core.env')
                self.assertEqual((workspace / 'secrets/core.env').stat().st_mode & 0o777, 0o600)
                self.assertNotIn('AWS_ACCESS_KEY_ID', run.call_args.kwargs['env'])
                with self.assertRaises(FileExistsError):
                    sops_env.decrypt_to_workspace(encrypted, identity, workspace, 'core.env')
            self.assertEqual(len(list((workspace / 'secrets').iterdir())), 1)


class SecureCoreContracts(unittest.TestCase):
    def test_documentation_links_and_inventory_match_the_playbook(self):
        doc = ROOT / 'docs/SECURE_CORE_REFACTOR.md'
        content = doc.read_text(encoding='utf-8')
        for link in re.findall(r'\]\(([^)]+)\)', content):
            if '://' not in link:
                self.assertTrue((doc.parent / link).is_file(), link)
        self.assertEqual(content.count('```') % 2, 0)
        self.assertIn('hosts: core_ai', (ROOT / 'ansible/playbooks/core_ai_setup.yml').read_text())
        self.assertIn('[core_ai]', (ROOT / 'ansible/core_ai.inventory.example.ini').read_text())
        self.assertIn('-i ansible/core_ai.inventory.example.ini', content)
        self.assertIn('docs/SECURE_CORE_REFACTOR.md', (ROOT / 'readme.md').read_text(encoding='utf-8'))

    def test_verified_bootstrap_never_executes_a_new_main(self):
        text = (ROOT / 'verify_and_install.sh').read_text()
        self.assertIn('clone --no-checkout', text)
        self.assertLess(text.index('sha256sum --status'), text.index('bash "$stage/source/install.sh"'))
        self.assertIn('--verified-source "$commit"', text)
        local = (ROOT / 'scripts/verified_source_install.sh').read_text()
        self.assertIn('--local --no-hardlinks', local)
        self.assertNotIn('pull ', local)

    def test_ansible_preserves_private_data_and_uses_success_receipts(self):
        play = (ROOT / 'ansible/playbooks/core_ai_setup.yml').read_text()
        build = (ROOT / 'ansible/tasks/core_ai_build.yml').read_text()
        self.assertIn('USER_WORKSPACE_DIR:', play)
        self.assertIn("mode: '0700'", play)
        self.assertIn('core_start_services: false', play)
        self.assertIn('core_receipt.stat.exists', build)
        self.assertIn('source_head.stdout == core_pin', build)
        self.assertIn('--frozen-lockfile', build)
        self.assertNotIn('curl ', build)
        self.assertNotIn('\\.', play)

    def test_backup_is_readonly_scoped_and_never_inits_or_unlocks(self):
        text = (ROOT / 'scripts/operations/backup_user_workspace.sh').read_text()
        self.assertLess(text.index('"$restic_bin" backup'), text.index('"$restic_bin" forget'))
        self.assertIn('--group-by host,paths,tags', text)
        self.assertIn('--keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune', text)
        self.assertNotRegex(text, r'"\$restic_bin" (?:init|unlock)')
        compose = (ROOT / 'stacks/workspace-backup/docker-compose.yml').read_text()
        self.assertIn('read_only: true', compose)
        self.assertIn('create_host_path: false', compose)
        self.assertNotIn('docker.sock', compose)
        self.assertIn('@sha256:', compose)
        timer = (ROOT / 'systemd/openclaw-workspace-backup.timer.example').read_text()
        self.assertIn('OnCalendar=', timer)
        self.assertIn('Persistent=true', timer)

    def test_limits_and_traefik_are_opt_in_and_do_not_expose_dashboard(self):
        limits = (ROOT / 'scripts/operations/apply_service_limits.sh').read_text()
        self.assertIn('memory=8G cpu=200 mode=plan', limits)
        self.assertRegex(limits, r'total\s*-\s*1073741824')
        self.assertIn('if ((restart))', limits)
        proxy = (ROOT / 'scripts/setup_traefik_local.sh').read_text()
        self.assertIn('source_commit', proxy)
        self.assertIn('if ((start))', proxy)
        self.assertIn('openssl x509', proxy)
        self.assertIn('bereits belegt', proxy)
        static = (ROOT / 'config/traefik-local/traefik.yml').read_text()
        self.assertIn('127.0.0.1:80', static)
        self.assertIn('127.0.0.1:443', static)
        self.assertIn('dashboard: false', static)

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Bash erforderlich')
    def test_bash_syntax_without_running_installers(self):
        for file in ('verify_and_install.sh', 'scripts/verified_source_install.sh',
                     'scripts/operations/backup_user_workspace.sh', 'scripts/decrypt_core_env.sh',
                     'scripts/setup_traefik_local.sh', 'scripts/operations/apply_service_limits.sh'):
            result = subprocess.run([BASH, '-n', file], cwd=ROOT, capture_output=True, text=True, timeout=30)
            self.assertEqual(result.returncode, 0, file + result.stderr)

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Bash erforderlich')
    def test_backup_failure_prevents_retention_without_any_network(self):
        # Readonly Bash-Funktionen verhindern jeden echten Restic-/S3-Aufruf.
        with tempfile.TemporaryDirectory() as temp:
            base = Path(temp)
            source, secrets_dir = base / 'source', base / 'keys'
            source.mkdir()
            secrets_dir.mkdir()
            for file in ('password', 'access-key-id', 'secret-access-key'):
                (secrets_dir / file).write_text('MOCK-SECRET')
            for status in (0, 3):
                trace = base / ('trace-' + str(status))
                env = dict(os.environ, SOURCE_NATIVE=str(source), SECRET_NATIVE=str(secrets_dir),
                           TRACE_NATIVE=str(trace), MOCK_BACKUP_STATUS=str(status))
                convert = ('BACKUP_SOURCE=$(cygpath -u "$SOURCE_NATIVE"); BACKUP_SECRET_DIR=$(cygpath -u "$SECRET_NATIVE"); TRACE=$(cygpath -u "$TRACE_NATIVE")\n'
                           if sys.platform == 'win32' else 'BACKUP_SOURCE=$SOURCE_NATIVE; BACKUP_SECRET_DIR=$SECRET_NATIVE; TRACE=$TRACE_NATIVE\n')
                command = 'set -euo pipefail\n' + convert + '''
stat() { case "$2" in %a) printf '600\n';; %u) printf '%s\n' "$EUID";; *) return 90;; esac; }
restic() { printf '%s\n' "$1" >> "$TRACE"; if [[ "$1" == backup ]]; then return "$MOCK_BACKUP_STATUS"; fi; }
readonly -f stat restic
export BACKUP_SOURCE BACKUP_SECRET_DIR BACKUP_HOST_ID=fixture RESTIC_REPOSITORY=s3:https://backup.invalid/repo
export BACKUP_TARGET_IS_EXTERNAL=1 BACKUP_ALLOW_PRUNE=1 BACKUP_DEDICATED_REPOSITORY=1
source scripts/operations/backup_user_workspace.sh
'''
                result = subprocess.run([BASH, '--noprofile', '--norc', '-s'], input=command,
                                        cwd=ROOT, env=env, capture_output=True, text=True, timeout=30)
                calls = trace.read_text().splitlines()
                self.assertEqual(result.returncode, status, result.stderr)
                self.assertEqual(calls, ['cat', 'backup', 'forget', 'check'] if status == 0 else ['cat', 'backup'])
                self.assertNotIn('MOCK-SECRET', result.stdout + result.stderr)


if __name__ == '__main__':
    unittest.main()
