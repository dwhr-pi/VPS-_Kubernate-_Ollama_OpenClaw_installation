"""Offline-Vertraege: kein Cluster, kein Download und keine Provider-Anfrage."""
import contextlib
import importlib.util
import io
import json
from pathlib import Path
import re
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]


def load(name, relative):
    spec = importlib.util.spec_from_file_location(name, ROOT / relative)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


helm = load('platform_helm', 'scripts/lib/platform_helm.py')
ingress = load('gpu_ingress', 'scripts/render_gpu_ingress.py')


class PlatformContracts(unittest.TestCase):
    def test_default_plan_has_no_network_subprocess_or_temp_files(self):
        for stack in ('monitoring', 'nvidia'):
            with mock.patch.object(helm, 'run', side_effect=AssertionError('process')), \
                 mock.patch.object(helm, 'fetch_chart', side_effect=AssertionError('download')), \
                 mock.patch.object(helm.tempfile, 'TemporaryDirectory', side_effect=AssertionError('write')), \
                 contextlib.redirect_stdout(io.StringIO()) as output:
                self.assertEqual(helm.main([stack]), 0)
                self.assertEqual(json.loads(output.getvalue())['mode'], 'offline-plan')

    def test_apply_requires_both_context_and_confirmation(self):
        with mock.patch.object(helm.shutil, 'which', return_value='/bin/helm'), \
             mock.patch.object(helm, 'run', side_effect=AssertionError('process')):
            for args in (['monitoring', '--apply'], ['nvidia', '--apply', '--context', 'test']):
                with self.assertRaises(ValueError):
                    helm.main(args)

    def test_chart_sources_are_versioned_and_hashed(self):
        items = json.loads((ROOT / 'config/platform_helm_releases.json').read_text())['releases']
        self.assertEqual(set(items), {'nvidia', 'prometheus', 'loki'})
        for item in items.values():
            self.assertRegex(item['sha256'], r'^[a-f0-9]{64}$')
            self.assertTrue(item['url'].startswith('https://github.com/'))
            self.assertIn('/releases/download/', item['url'])
            self.assertTrue((ROOT / item['values']).is_file())

    def test_ingress_rejects_invalid_or_public_boundary(self):
        for domain, email, cidr in [('example.invalid', 'a@real.org', '10.44.0.0/24'),
                                    ('llm.real.org', 'bad', '10.44.0.0/24'),
                                    ('llm.real.org', 'a@real.org', '0.0.0.0/0'),
                                    ('llm.real.org', 'a@real.org', '8.8.8.8/32')]:
            with self.assertRaises(ValueError):
                ingress.resources(domain, email, cidr)

    def test_ingress_never_exposes_raw_ollama(self):
        objects = ingress.resources('llm.real.org', 'admin@real.org', '10.44.0.0/24')['items']
        route = objects[-1]['spec']['rules'][0]['http']['paths'][0]
        self.assertEqual(route['backend']['service']['name'], 'litellm')
        self.assertEqual(route['path'], '/v1')
        self.assertIn('websecure', json.dumps(objects))
        self.assertNotIn('11434', json.dumps(objects))

    def test_pinned_runtime_images(self):
        for name in ('gateway-patch.yml', 'k8s-ollama-deployment.yaml'):
            content = (ROOT / 'k8s/overlays/gpu' / name).read_text()
            self.assertRegex(content, r'image: [^\s]+@sha256:[a-f0-9]{64}')
        gpu = (ROOT / 'k8s/overlays/gpu/k8s-ollama-deployment.yaml').read_text()
        self.assertEqual(gpu.count('nvidia.com/gpu:'), 2)
        self.assertIn('runtimeClassName: nvidia', gpu)

    def test_scan_precedes_login_and_publish(self):
        workflow = (ROOT / '.github/workflows/build-and-push.yml').read_text()
        self.assertLess(workflow.index('Trivy -'), workflow.index('docker login'))
        self.assertLess(workflow.index('docker login'), workflow.index('docker push'))
        self.assertNotIn('continue-on-error', workflow)
        self.assertNotIn('pull_request_target', workflow)
        self.assertNotIn('kubectl', workflow)
        self.assertTrue(all(re.search(r'@[a-f0-9]{40}$', action)
                            for action in re.findall(r'uses: ([^\s]+)', workflow)))

    def test_legacy_proxy_does_not_embed_key_in_url(self):
        content = (ROOT / 'docs/legacy/K8S_DEPLOYMENTS_LEGACY.md').read_text()
        self.assertNotIn('generateContent?key=', content)
        self.assertIn('"x-goog-api-key": GEMINI_API_KEY', content)
        self.assertNotIn('type: LoadBalancer', content)
        self.assertIn('"stream": False', content)

    def test_metrics_do_not_claim_native_ollama_exporter(self):
        content = (ROOT / 'k8s/overlays/gpu/k8s-ollama-deployment.yaml').read_text()
        self.assertIn("prometheus.io/scrape: 'false'", content)
        monitor = (ROOT / 'k8s/monitoring/litellm-service-monitor.yml').read_text()
        self.assertIn('authorization:', monitor)
        self.assertIn('credentials: {name: litellm-runtime, key: master-key}', monitor)


if __name__ == '__main__':
    unittest.main()
