"""Synthetic HTTP/Secret fixtures only; never start a gateway or read real credentials."""
import contextlib
from email.message import Message
import importlib.util
import io
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]
OVERLAY = ROOT / "k8s/overlays/metrics-isolation"
SPEC = importlib.util.spec_from_file_location("metrics_bridge", OVERLAY / "litellm_metrics_proxy.py")
bridge = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(bridge)


class MetricsIsolation(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.scrape = self.root / "scrape"
        self.master = self.root / "master"
        self.token = b"synthetic-scrape-token-" + b"a" * 32
        self.upstream = b"synthetic-upstream-token-" + b"b" * 32
        self.write(self.scrape, self.token)
        self.write(self.master, self.upstream)

    @staticmethod
    def write(path, data):
        path.write_bytes(data + b"\n")
        path.chmod(0o600)

    def request(self, method="GET", path="/metrics", auth=None, extra=(), fetch=None):
        headers = Message()
        if auth is not False:
            headers["Authorization"] = "Bearer " + (self.token if auth is None else auth).decode()
        for key, value in extra:
            headers[key] = value
        fetch = fetch or Mock(return_value=b"# TYPE fixture gauge\nfixture 1\n")
        return bridge.dispatch(method, path, headers, self.scrape, self.master, fetch), fetch

    def test_scrape_uses_upstream_not_client_token(self):
        result, fetch = self.request()
        self.assertEqual(result[0], 200)
        fetch.assert_called_once_with(self.upstream)
        self.assertNotIn(self.upstream, result[1])

    def test_missing_wrong_duplicate_and_master_credentials_denied(self):
        for auth in (False, b"wrong-" + b"x" * 40, self.upstream):
            result, fetch = self.request(auth=auth)
            self.assertEqual(result[0], 401)
            fetch.assert_not_called()
        result, fetch = self.request(extra=[("Authorization", "Bearer " + self.token.decode())])
        self.assertEqual(result[0], 401)
        fetch.assert_not_called()

    def test_inference_admin_queries_encoded_paths_and_methods_never_forward(self):
        for path in ("/v1/chat/completions", "/key/generate", "/metrics?path=/v1/models", "/metrics/", "/%6detrics", "http://other/metrics"):
            result, fetch = self.request(path=path)
            self.assertEqual(result[0], 404)
            fetch.assert_not_called()
        for method in ("POST", "PUT", "DELETE", "HEAD", "OPTIONS", "PATCH", "TRACE"):
            result, fetch = self.request(method=method)
            self.assertEqual(result[0], 405)
            fetch.assert_not_called()

    def test_request_bodies_and_chunked_framing_denied(self):
        for headers in ([('Content-Length', '1')], [('Transfer-Encoding', 'chunked')],
                        [('Content-Length', '0'), ('Content-Length', '0')]):
            result, fetch = self.request(extra=headers)
            self.assertEqual(result[0], 400)
            fetch.assert_not_called()

    def test_rotation_invalidates_old_token_without_restart(self):
        old = self.token
        self.token = b"rotated-fixture-" + b"r" * 40
        self.write(self.scrape, self.token)
        result, fetch = self.request(auth=old)
        self.assertEqual(result[0], 401)
        fetch.assert_not_called()
        self.assertEqual(self.request()[0][0], 200)

    def test_equal_missing_and_malformed_secrets_fail_closed(self):
        self.write(self.master, self.token)
        self.assertEqual(self.request()[0][0], 503)
        self.write(self.master, b"bad\r\nAuthorization: injected")
        self.assertEqual(self.request()[0][0], 502)
        self.master.unlink()
        self.assertEqual(self.request()[0][0], 502)

    def test_upstream_errors_oversize_and_token_echo_never_escape(self):
        for value in (b"x" * (bridge.MAX_BYTES + 1), self.token, self.upstream, b""):
            result, _ = self.request(fetch=Mock(return_value=value))
            self.assertEqual(result, (502, b"metrics unavailable\n"))
        result, _ = self.request(fetch=Mock(side_effect=OSError("PRIVATE-DETAIL")))
        self.assertNotIn(b"PRIVATE-DETAIL", result[1])

    def test_health_does_not_read_secrets_or_probe_upstream(self):
        with patch.object(bridge, "read_token", side_effect=AssertionError("read")):
            result, fetch = self.request(path="/healthz", auth=False)
        self.assertEqual(result[0], 200)
        fetch.assert_not_called()

    def test_default_plan_never_opens_a_file_or_socket(self):
        with patch.object(bridge.os, "open", side_effect=AssertionError("read")), \
                patch.object(bridge.HTTPServer, "__init__", side_effect=AssertionError("socket")), \
                contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(bridge.main([]), 0)

    def test_transport_is_fixed_get_no_redirect_and_closes(self):
        for status in (301, 302, 401, 500):
            connection = Mock()
            connection.getresponse.return_value = Mock(status=status)
            with patch.object(bridge.http.client, "HTTPConnection", return_value=connection) as factory, \
                    patch.object(bridge.threading, "Timer"), self.assertRaises(ValueError):
                bridge.fetch_metrics(self.upstream)
            factory.assert_called_once_with("127.0.0.1", 4000, timeout=3)
            self.assertEqual(connection.request.call_args.args, ("GET", "/metrics"))
            connection.close.assert_called_once()

    def test_transport_success_and_body_size_limit(self):
        connection = Mock()
        response = connection.getresponse.return_value
        response.status = 200
        response.getheader.side_effect = lambda name, default=None: {"Content-Type": "text/plain; version=0.0.4"}.get(name, default)
        response.read1.side_effect = [b"fixture 1\n", b""]
        with patch.object(bridge.http.client, "HTTPConnection", return_value=connection), patch.object(bridge.threading, "Timer"):
            self.assertEqual(bridge.fetch_metrics(self.upstream), b"fixture 1\n")
        response.read1.side_effect = [b"x" * (bridge.MAX_BYTES + 1)]
        with patch.object(bridge.http.client, "HTTPConnection", return_value=connection), patch.object(bridge.threading, "Timer"), self.assertRaises(ValueError):
            bridge.fetch_metrics(self.upstream)

    def test_manifest_token_boundary_and_no_unrestricted_listener_service(self):
        monitor = (ROOT / "k8s/monitoring/litellm-service-monitor.yml").read_text()
        self.assertIn("credentials: {name: litellm-metrics-scrape, key: token}", monitor)
        self.assertNotIn("master-key", monitor)
        self.assertIn("port: metrics", monitor)
        service = (OVERLAY / "metrics-service.yaml").read_text()
        self.assertIn("type: ClusterIP", service)
        self.assertNotIn("4000", service)
        config = (OVERLAY / "kustomization.yaml").read_text()
        self.assertIn("op: replace", config)
        self.assertIn("/spec/ingress", config)
        self.assertNotIn("metadata.name: monitoring", config)
        policy = (OVERLAY / "network-policy.yaml").read_text()
        self.assertIn("metadata.name: monitoring", policy)
        self.assertIn("port: 9092", policy)
        self.assertNotIn("port: 4000", policy)
        sidecar = (OVERLAY / "gateway-sidecar.yaml").read_text()
        for item in ("readOnlyRootFilesystem: true", "limits:", "capabilities: {drop: [ALL]}", "defaultMode: 0440"):
            self.assertIn(item, sidecar)

    def test_standalone_patch_preserves_base_nonroot_identity(self):
        sidecar = (OVERLAY / 'gateway-sidecar.yaml').read_text()
        base = (ROOT / 'k8s/base/litellm.yml').read_text()
        block = r'^      securityContext:\n((?:^        \S[^\n]*\n)+)'
        expected = re.findall(block, base, re.M)
        self.assertEqual(len(expected), 1)
        self.assertEqual(re.findall(block, sidecar, re.M), expected)
        self.assertIn('automountServiceAccountToken: false', sidecar)
        for value in ('runAsNonRoot: true', 'runAsUser: 10001', 'runAsGroup: 10001'):
            self.assertEqual(sidecar.count(value), 2)


@unittest.skipUnless(os.environ.get('KUSTOMIZE_BIN'), 'Pinned Kustomize unavailable; CI renders the real overlay')
class RenderContracts(unittest.TestCase):
    def test_actual_overlay_removes_direct_scrape_and_reuses_runtime(self):
        result = subprocess.run([os.environ['KUSTOMIZE_BIN'], 'build', str(OVERLAY)],
                                capture_output=True, text=True, timeout=30, check=True)
        documents = result.stdout.split('---')
        policy = next(doc for doc in documents if re.search(r'^  name: gateway-and-monitoring-to-litellm$', doc, re.M))
        self.assertNotIn('kubernetes.io/metadata.name: monitoring', policy)
        self.assertIn('port: 4000', policy)
        deployment = next(doc for doc in documents if 'kind: Deployment' in doc)
        images = re.findall(r'^\s+image: (.+)$', deployment, re.M)
        self.assertEqual(len(images), 2)
        self.assertEqual(images[0], images[1])
        self.assertIn('litellm-metrics-code-', deployment)
        service = next(doc for doc in documents if 'kind: Service\n' in doc and '  name: litellm\n' in doc)
        self.assertNotIn('llmops-metrics: litellm', service)


if __name__ == "__main__":
    unittest.main()
