"""Offline example contracts; never contact Helm repos, Kubernetes or a provider."""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]
EXAMPLES = ROOT / 'examples/hybrid-production-review'
KUSTOMIZE = os.environ.get('KUSTOMIZE_BIN') or shutil.which('kustomize')
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')


def read(name):
    return (EXAMPLES / name).read_text(encoding='utf-8')


class HybridProductionExamples(unittest.TestCase):
    def test_examples_are_not_an_automatic_deployment(self):
        self.assertFalse(any(EXAMPLES.glob('kustomization.*')))
        self.assertIn('Nicht automatisch eingebunden', read('README.md'))
        for filename in ('k8s/base/kustomization.yml', 'k8s/overlays/gpu/kustomization.yml'):
            self.assertNotIn('hybrid-production-review', (ROOT / filename).read_text(encoding='utf-8'))
        app = read('argocd.yaml')
        self.assertNotRegex(app, r'(?m)^\s+(automated|prune|selfHeal|finalizers):')
        self.assertEqual(app.count('repoURL:'), 1)
        self.assertRegex(app, r'targetRevision: [a-f0-9]{40}\b')
        self.assertIn('path: k8s/overlays/gpu', app)
        self.assertIn('namespace: llmops', app)

    def test_gpu_sharing_is_explicit_not_isolation(self):
        config = read('gpu-sharing.yaml')
        values = read('gpu-values.yaml')
        self.assertIn('renameByDefault: true', config)
        self.assertIn('failRequestsGreaterThanOne: true', config)
        self.assertIn('default: exclusive', values)
        self.assertIn('driver:\n  enabled: false', values)
        self.assertIn('autoUpgrade: false', values)
        self.assertIn('/run/k3s/containerd/containerd.sock', values)
        self.assertIn('nicht sicher VRAM', read('README.md'))

    def test_eso_has_real_provider_not_fake_sops_support(self):
        secret = read('external-secret.yaml')
        self.assertIn('apiVersion: external-secrets.io/v1', secret)
        self.assertIn('    vault:', secret)
        self.assertIn('caProvider:', secret)
        self.assertIn('serviceAccountRef:', secret)
        self.assertIn('audiences: [openbao]', secret)
        self.assertNotIn('kind: Secret\n', secret)
        self.assertNotIn('ENC[AES256_GCM', secret)

    def test_admission_is_scoped_to_opt_in_ai_namespaces(self):
        policy = read('admission.yaml')
        self.assertEqual(policy.count('namespaces: [llmops, openclaw, ollama]'), 3)
        self.assertEqual(policy.count('llmops.example/admission: enforce'), 3)
        self.assertIn('validationFailureAction: Enforce', policy)
        self.assertIn("'=(privileged)': false", policy)
        self.assertIn('nvidia.com/gpu.shared', policy)
        self.assertIn('ephemeralContainers', policy)

    def test_private_network_and_backup_defaults(self):
        net = read('network-policy.yaml')
        self.assertIn('podSelector: {}\n  policyTypes: [Ingress, Egress]', net)
        self.assertNotIn('0.0.0.0/0', net)
        self.assertNotIn('::/0', net)
        self.assertIn('port: 11434', net)
        ingress = read('private-ingress.yaml')
        self.assertIn('dns01:', ingress)
        self.assertNotIn('http01:', ingress)
        self.assertIn('llmops-private-ui-auth@kubernetescrd', ingress)
        self.assertNotIn('name: ollama,', ingress)
        schedule = read('backup-schedule.yaml')
        self.assertIn('paused: true', schedule)
        self.assertIn('defaultVolumesToFsBackup: false', schedule)
        self.assertIn('snapshotVolumes: false', schedule)
        self.assertIn('existingSecret: velero-cloud-credentials', read('velero-values.yaml'))

    def test_dashboard_has_import_datasource_and_real_gpu_metrics(self):
        dashboard = json.loads(read('rtx-dashboard.json'))
        self.assertEqual(len(dashboard['panels']), 4)
        self.assertEqual(len({panel['id'] for panel in dashboard['panels']}), 4)
        for panel in dashboard['panels']:
            self.assertEqual(panel['datasource']['uid'], '${DS_PROMETHEUS}')
            self.assertTrue(panel['targets'][0]['expr'].startswith(('DCGM_', '100 * DCGM_')))
        self.assertNotIn('11434/metrics', read('README.md'))

    def test_document_relative_links_resolve(self):
        text = re.sub(r'```.*?```', '', read('README.md'), flags=re.S)
        for link in re.findall(r'\]\(([^\s)]+)\)', text):
            if '://' in link or link.startswith('#'):
                continue
            path = (EXAMPLES / link.split('#')[0]).resolve()
            self.assertTrue(path.is_relative_to(ROOT))
            self.assertTrue(path.exists(), link)

    @unittest.skipUnless(KUSTOMIZE, 'Local Kustomize unavailable; no downloads allowed')
    def test_yaml_files_parse_offline(self):
        result = subprocess.run([KUSTOMIZE, 'cfg', 'count', str(EXAMPLES)], cwd=ROOT,
                                capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stderr)
        for kind in ('NetworkPolicy', 'ExternalSecret', 'Application', 'ClusterPolicy', 'Schedule'):
            self.assertIn(kind + ':', result.stdout)

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash unavailable; never start WSL')
    def test_bash_examples_parse_without_execution(self):
        code = '\n'.join(re.findall(r'```bash\n(.*?)```', read('README.md'), re.S))
        env = {'PATH': os.environ.get('PATH', ''), 'BASH_ENV': os.devnull, 'ENV': os.devnull}
        if 'SystemRoot' in os.environ:
            env['SystemRoot'] = os.environ['SystemRoot']
        result = subprocess.run([BASH, '--noprofile', '--norc', '-n'], input=code,
                                env=env, capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
