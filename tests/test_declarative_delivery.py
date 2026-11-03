"""Offline delivery contracts; never contact a cluster or start a runtime."""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import textwrap
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = shutil.which('bash')
if os.name == 'nt':
    candidate = Path('C:/Program Files/Git/bin/bash.exe')
    BASH = str(candidate) if candidate.exists() else None
KUSTOMIZE = os.environ.get('KUSTOMIZE_BIN') or shutil.which('kustomize')


def read(path):
    return (ROOT / path).read_text(encoding='utf-8')


class DeliveryContracts(unittest.TestCase):
    def test_documentation_links_resolve(self):
        for source in ('docs/GITOPS_DEPLOYMENT_PATH.md', 'deploy/kustomize/README.md'):
            text = re.sub(r'```.*?```', '', read(source), flags=re.S)
            for link in re.findall(r'\]\(([^\s)]+)\)', text):
                if '://' in link or link.startswith('#'):
                    continue
                path = ((ROOT / source).parent / link.split('#')[0]).resolve()
                self.assertTrue(path.is_relative_to(ROOT))
                self.assertTrue(path.exists(), link)

    def test_probe_inventory_is_not_inference(self):
        text = read('k8s/base/ollama.yml')
        self.assertEqual(text.count('path: /api/tags'), 2)
        self.assertIn('path: /api/version', text)
        for field in ('runAsNonRoot: true', 'allowPrivilegeEscalation: false',
                      'readOnlyRootFilesystem: true', 'volumeClaimTemplates:'):
            self.assertIn(field, text)
        self.assertIn('leere', read('docs/GITOPS_DEPLOYMENT_PATH.md').lower())

    def test_metrics_auth_and_selectors(self):
        for path in ('k8s/base/litellm.yml', 'k8s/overlays/vps-cpu/gateway.yaml'):
            self.assertIn('require_auth_for_metrics_endpoint: true', read(path))
        self.assertIn('llmops-metrics: litellm', read('k8s/base/litellm.yml'))
        rule = read('k8s/monitoring/runtime-observability.yml')
        self.assertIn('sampleLimit: 128', rule)
        self.assertIn('release: llmops-monitoring', rule)
        self.assertIn('absent(up{', rule)
        values = read('k8s/monitoring/prometheus-values.yml')
        self.assertIn('llmops-monitoring', values)
        self.assertIn('ai-monitoring', values)
        self.assertIn('replicas: 0', read('k8s/platform/ollama-exporter.yaml'))

    def test_dashboard_real_metrics_and_unique_panels(self):
        dashboard = json.loads(read('monitoring/grafana/dashboards/llmops.json'))
        panels = dashboard['panels']
        self.assertEqual(len(panels), len({p['id'] for p in panels}))
        queries = '\n'.join(t.get('expr', '') for p in panels for t in p.get('targets', []))
        for metric in ('DCGM_FI_DEV_FB_USED', 'DCGM_FI_DEV_GPU_UTIL',
                       'litellm_request_total_latency_metric_bucket', 'litellm_proxy_total_requests_metric'):
            self.assertIn(metric, queries)
        self.assertNotIn('or vector(0)', queries)

    def test_ci_does_not_deploy_on_push_or_pr(self):
        workflow = read('.github/workflows/deploy.yml')
        actions = re.findall(r'uses: ([^\s]+)', workflow)
        self.assertTrue(actions)
        for action in actions:
            self.assertRegex(action, r'@[0-9a-f]{40}$')
        for gate in ("github.event_name == 'workflow_dispatch'", 'inputs.deploy_staging == true',
                     "github.ref == 'refs/heads/main'", 'environment: llmops-staging',
                     'test "$REVIEWED_SHA" = "$GITHUB_SHA"', '--confirm-apply',
                     'go mod verify', 'helm" lint', 'kube-linter" lint'):
            self.assertIn(gate, workflow)
        self.assertNotIn('continue-on-error', workflow)
        self.assertNotIn('docker run', workflow)

    def test_private_ingress_never_routes_to_raw_ollama(self):
        ingress = read('deploy/kustomize/overlays/private-ingress/ingress.yaml')
        self.assertIn('cert-manager.io/cluster-issuer: llmops-private-dns01', ingress)
        self.assertIn('path: /v1', ingress)
        self.assertIn('name: litellm', ingress)
        self.assertNotIn('11434', ingress)
        self.assertIn('sourceRange:', ingress)
        self.assertIn('kubernetes.io/metadata.name: kube-system', ingress)
        self.assertIn('app.kubernetes.io/name: traefik', ingress)
        self.assertIn('dns01:', read('deploy/kustomize/platform-dns01/cluster-issuer.yaml'))


@unittest.skipUnless(BASH, 'Git Bash or native bash required; never use WSL')
class EntrypointFixtures(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        folder = self.root / 'scripts'
        (folder / 'operations').mkdir(parents=True)
        self.script = folder / 'setup-cluster.sh'
        self.script.write_text(read('scripts/setup-cluster.sh'), encoding='utf-8', newline='\n')
        fixture = '#!/usr/bin/env bash\nprintf "fixture:%s\\n" "$@"\n'
        (folder / 'operations/deploy_vps_baseline.sh').write_text(fixture, newline='\n')
        (folder / 'bootstrap_gitops.sh').write_text(fixture, newline='\n')

    def run_script(self, *args):
        return subprocess.run([BASH, self.script.as_posix(), *args], capture_output=True,
                              text=True, timeout=15)

    def test_default_and_help_do_not_dispatch(self):
        for args in ((), ('--help',)):
            result = self.run_script(*args)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn('fixture:', result.stdout)

    def test_workflow_shell_blocks_parse_without_execution(self):
        blocks = re.findall(r'(?m)^        run: \|\n((?:          .*\n|\n)+)',
                            read('.github/workflows/deploy.yml'))
        self.assertEqual(len(blocks), 3)
        for block in blocks:
            result = subprocess.run([BASH, '--noprofile', '--norc', '-n'],
                                    input=textwrap.dedent(block), capture_output=True,
                                    text=True, timeout=15)
            self.assertEqual(result.returncode, 0, result.stderr)

    def test_mixed_actions_and_provision_fail_closed(self):
        for args in (('--check', '--apply'), ('--plan', '--apply'), ('--provision',),
                     ('--render', '../../foreign'), ('--unknown',)):
            result = self.run_script(*args)
            self.assertEqual(result.returncode, 2, result.stderr)
            self.assertNotIn('fixture:', result.stdout)

    def test_modes_are_explicitly_mapped(self):
        for action, delegated in (('--check', '--check'), ('--validate', '--plan'),
                                  ('--apply', '--apply'), ('--bootstrap-plan', '--plan')):
            result = self.run_script(action, '--context', 'isolated-fixture')
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout.splitlines(),
                             [f'fixture:{delegated}', 'fixture:--context', 'fixture:isolated-fixture'])


@unittest.skipUnless(KUSTOMIZE, 'Existing reviewed Kustomize required; no download')
class RenderFixtures(unittest.TestCase):
    def render(self, path):
        result = subprocess.run([KUSTOMIZE, 'build', str(ROOT / path)],
                                capture_output=True, text=True, timeout=40)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout

    def test_aliases_equal_existing_authoritative_manifests(self):
        for name in ('vps-cpu', 'gpu', 'production'):
            self.assertEqual(self.render(f'deploy/kustomize/overlays/{name}'),
                             self.render(f'k8s/overlays/{name}'))
        self.assertEqual(self.render('deploy/kustomize/base'), self.render('k8s/base'))

    def test_optional_bundles_and_retained_local_storage(self):
        text = self.render('deploy/kustomize/overlays/vps-cpu-local-storage')
        self.assertIn('storageClassName: local-path', text)
        self.assertIn('whenDeleted: Retain', text)
        private = self.render('deploy/kustomize/overlays/private-ingress')
        self.assertIn('kind: Ingress', private)
        self.assertNotIn('type: LoadBalancer', private)
        monitor = self.render('deploy/kustomize/monitoring-operator')
        self.assertIn('kind: PrometheusRule', monitor)
        self.assertIn('replicas: 0', monitor)
        self.render('deploy/kustomize/platform-dns01')
        self.render('deploy/kustomize/optional/direct-openclaw-ollama')
        self.assertNotIn('kind: ServiceMonitor', text)


if __name__ == '__main__':
    unittest.main()
