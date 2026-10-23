"""Offline safety checks; never install a tool or contact a running service."""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest
import importlib.util

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('production_preflight', ROOT / 'scripts/quality/production_preflight.py')
preflight = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(preflight)


class BaselineFiles(unittest.TestCase):
    def test_manifest_preflight_rejects_examples_and_unpinned_images(self):
        for text in ('image: example.invalid/service:REPLACE', 'image: service:latest', 'kind: ConfigMap'):
            with self.assertRaises(ValueError):
                preflight.validate_manifest(text)
        preflight.validate_manifest('image: service@sha256:' + 'a' * 64)

    def test_monitoring_preflight_rejects_the_template(self):
        with self.assertRaises(ValueError):
            preflight.validate_monitoring((ROOT / 'monitoring/.env.example').read_text())

    def test_dashboard_has_real_datasource_and_unique_panel_ids(self):
        dashboard = json.loads((ROOT / 'monitoring/grafana/dashboards/llmops.json').read_text())
        panels = dashboard['panels']
        self.assertEqual(len({p['id'] for p in panels}), len(panels))
        self.assertTrue(all(p['datasource']['uid'] == 'prometheus' for p in panels))
        self.assertIn('litellm_total_tokens_metric_total', panels[0]['targets'][0]['expr'])

    def test_native_ollama_metrics_are_not_invented(self):
        self.assertEqual(json.loads((ROOT / 'monitoring/ollama-metrics.targets.json').read_text()), [])
        prometheus = (ROOT / 'monitoring/prometheus.yml').read_text()
        self.assertNotIn('11434', '\n'.join(l for l in prometheus.splitlines() if not l.lstrip().startswith('#')))
        self.assertIn('credentials_file:', prometheus)

    def test_sops_is_fail_closed_and_does_not_contain_fake_ciphertext(self):
        config = (ROOT / '.sops.yaml').read_text()
        template = (ROOT / 'k8s/secrets.template.yml').read_text()
        self.assertIn('REPLACE_WITH_YOUR_PUBLIC_RECIPIENT', config)
        self.assertNotIn('ENC[AES256_GCM', template)
        self.assertNotIn('secrets.template', (ROOT / 'k8s/base/kustomization.yml').read_text())

    def test_ci_actions_are_pinned_and_secret_scan_is_enforced(self):
        workflow = (ROOT / '.github/workflows/test-install-scripts.yml').read_text()
        actions = re.findall(r'uses: ([^\s]+)', workflow)
        self.assertGreaterEqual(len(actions), 3)
        self.assertTrue(all(re.search(r'@[a-f0-9]{40}$', action) for action in actions))
        self.assertIn('scanners: secret', workflow)
        self.assertIn("exit-code: '1'", workflow)
        self.assertNotIn('continue-on-error', workflow)
        self.assertNotIn('pull_request_target', workflow)

    def test_runtime_boundaries(self):
        for name in ('ollama', 'litellm'):
            text = (ROOT / f'k8s/base/{name}.yml').read_text()
            self.assertIn('runAsNonRoot: true', text)
            self.assertIn('allowPrivilegeEscalation: false', text)
            self.assertIn('readOnlyRootFilesystem: true', text)
            self.assertIn('automountServiceAccountToken: false', text)
            self.assertNotIn('type: LoadBalancer', text)
        compose = (ROOT / 'docker-compose.monitoring.yml').read_text()
        self.assertNotIn('docker.sock', compose)
        self.assertNotIn(':latest', compose)
        self.assertIn('127.0.0.1:3030:3000', compose)


@unittest.skipUnless(os.name == 'posix' and shutil.which('bash') and shutil.which('flock'),
                     'Linux/POSIX mock execution required; runs in Ubuntu CI')
class BackupBehavior(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.work = Path(self.temp.name)
        self.bin = self.work / 'bin'
        self.bin.mkdir()
        self.log = self.work / 'calls'
        self.lock = self.work / 'locks'
        self.lock.mkdir(mode=0o700)
        self.compose = self.work / 'compose.yml'
        self.compose.write_text('services: {}\n')
        self.password = self.work / 'password'
        self.password.write_text('fixture-only\n')
        self.password.chmod(0o600)
        self.dirs = {}
        for name in ('postgres', 'minio', 'qdrant'):
            self.dirs[name] = self.work / name
            self.dirs[name].mkdir()
        self.env_file = self.work / 'backup.env'
        self.entries = {
            'RESTIC_REPOSITORY': 's3:https://backup.example.invalid/bucket',
            'RESTIC_PASSWORD_FILE': str(self.password),
            'COMPOSE_FILE': str(self.compose),
            'BACKUP_LOCK_DIR': str(self.lock),
            'BACKUP_TARGET_IS_EXTERNAL': '1',
            'BACKUP_ALLOW_DOWNTIME': '1',
            **{f'{name.upper()}_DATA_DIR': str(directory) for name, directory in self.dirs.items()},
        }
        self.write_env()
        self.environment = dict(os.environ, PATH=f'{self.bin}:{os.environ["PATH"]}',
                                MOCK_ROOT=str(self.work), MOCK_LOG=str(self.log))
        self.write_tool('docker', '''#!/usr/bin/env python3
import json, os, pathlib, sys
root = pathlib.Path(os.environ['MOCK_ROOT'])
args = sys.argv[1:]
with open(os.environ['MOCK_LOG'], 'a') as log:
    log.write('docker ' + ' '.join(args) + '\\n')
names = ['postgres', 'minio', 'qdrant']
ids = {name: str(i + 1) * 64 for i, name in enumerate(names)}
if args[0] == 'compose':
    op = args[3]
    if op == 'ps': print(ids[args[-1]])
    elif op == 'stop': (root / ('stopped-' + args[-1])).touch()
    elif op == 'start':
        for name in args[4:]: (root / ('stopped-' + name)).unlink(missing_ok=True)
elif args[0] == 'inspect':
    name = next(name for name in names if ids[name] == args[-1])
    fmt = args[2]
    stopped = (root / ('stopped-' + name)).exists()
    if 'Mounts' in fmt:
        target = {'postgres':'/var/lib/postgresql/data', 'minio':'/data', 'qdrant':'/qdrant/storage'}[name]
        print(json.dumps([{'Source':str(root / name), 'Destination':target}]))
    elif 'ExitCode' in fmt: print('false 0' if stopped else 'true 0')
    else: print('false' if stopped else 'true')
else: raise SystemExit(88)
''')
        self.write_tool('restic', '''#!/usr/bin/env python3
import os, sys
with open(os.environ['MOCK_LOG'], 'a') as log: log.write('restic ' + sys.argv[1] + '\\n')
if sys.argv[1] == 'backup': raise SystemExit(int(os.environ.get('MOCK_BACKUP_EXIT', '0')))
''')

    def write_tool(self, name, content):
        file = self.bin / name
        file.write_text(content)
        file.chmod(0o700)

    def write_env(self):
        self.env_file.write_text(''.join(f'{key}={value}\n' for key, value in self.entries.items()))
        self.env_file.chmod(0o600)

    def run_backup(self, mode='--run'):
        return subprocess.run(['bash', str(ROOT / 'scripts/backup_stateful_services.sh'),
                               str(self.env_file), mode], env=self.environment,
                              text=True, capture_output=True, timeout=20)

    def test_dry_run_never_contacts_docker_or_restic(self):
        result = self.run_backup('--dry-run')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.log.exists())

    def test_success_restarts_previously_running_services(self):
        result = self.run_backup()
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = self.log.read_text()
        self.assertIn('restic backup', calls)
        self.assertIn('start postgres minio qdrant', calls)
        self.assertFalse(list(self.work.glob('stopped-*')))

    def test_restic_failure_still_restarts_services_and_fails(self):
        self.environment['MOCK_BACKUP_EXIT'] = '3'
        result = self.run_backup()
        self.assertEqual(result.returncode, 3, result.stderr)
        self.assertIn('start postgres minio qdrant', self.log.read_text())
        self.assertFalse(list(self.work.glob('stopped-*')))

    def test_env_is_not_executed(self):
        sentinel = self.work / 'must-not-exist'
        self.entries['AWS_ACCESS_KEY_ID'] = f'$(touch {sentinel})'
        self.write_env()
        result = self.run_backup('--dry-run')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(sentinel.exists())

    def test_unapproved_downtime_fails_before_docker(self):
        self.entries['BACKUP_ALLOW_DOWNTIME'] = '0'
        self.write_env()
        result = self.run_backup()
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.log.exists())

    def test_insecure_env_permissions_fail(self):
        self.env_file.chmod(0o644)
        result = self.run_backup('--dry-run')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.log.exists())


if __name__ == '__main__':
    unittest.main()
