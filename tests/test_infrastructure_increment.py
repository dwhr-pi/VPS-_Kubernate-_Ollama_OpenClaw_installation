"""Offline monitoring, inventory-retry and MCP boundary regressions."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import sys
import subprocess
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


broker = load('infrastructure_broker', 'scripts/agents/model_broker.py')
launcher = load('infrastructure_mcp', 'scripts/agents/mcp_launcher.py')
exporter = load('infrastructure_exporter', 'scripts/monitoring/ollama_readonly_exporter.py')


class Monitoring(unittest.TestCase):
    def test_all_supported_rules_detect_inventory_failure_not_only_exporter_http(self):
        for path in ('monitoring/alerts.yml', 'k8s/monitoring/runtime-observability.yml',
                     'charts/monitoring-lite/templates/config.yaml'):
            text = (ROOT / path).read_text(encoding='utf-8')
            self.assertEqual(text.count('alert: OllamaInventoryUnavailable'), 1)
            self.assertIn('expr: ollama_monitor_up == 0', text)
            self.assertNotIn('absent(ollama_monitor_up)', text)

    def test_bad_inventory_has_successful_metrics_response_but_backend_gauge_zero(self):
        opener = Mock()
        opener.open.return_value = io.BytesIO(b'not-json')
        values = exporter.scrape('http://127.0.0.1:11434/api/ps', opener).decode()
        self.assertIn('ollama_monitor_up 0', values)
        self.assertIn('ollama_monitor_poll_duration_seconds', values)
        self.assertNotIn('tokens_total', values)

    def test_native_and_kubernetes_gateway_metrics_require_auth(self):
        for path in ('services/inference-gateway/config.yaml',
                     'services/inference-gateway/config.local-policy.yaml', 'k8s/base/litellm.yml'):
            self.assertIn('require_auth_for_metrics_endpoint: true', (ROOT / path).read_text())
        self.assertIn('credentials_file:', (ROOT / 'monitoring/prometheus.yml').read_text())


class InventoryRetry(unittest.TestCase):
    def connection(self, status=200, after=None, raw=b'{"models":[]}'):
        connection = Mock()
        response = Mock(status=status)
        response.getheader.return_value = after
        response.read.return_value = raw
        connection.getresponse.return_value = response
        return connection

    def fetch(self, connections, **kwargs):
        with patch.object(broker.http.client, 'HTTPConnection', side_effect=connections) as factory:
            value = broker.inventory_get('127.0.0.1', 11434, 20,
                clock=lambda: 0, jitter=lambda: 0, **kwargs)
        return value, factory

    def test_transient_status_backoff_is_bounded_and_connections_close_before_sleep(self):
        for status in broker.RETRY_STATUSES:
            connections = [self.connection(status), self.connection(status), self.connection()]
            delays = []
            def sleep(delay):
                connections[len(delays)].close.assert_called_once()
                delays.append(delay)
            value, factory = self.fetch(connections, sleep=sleep)
            self.assertEqual(value, b'{"models":[]}')
            self.assertEqual(delays, [0.25, 0.5])
            self.assertEqual(factory.call_count, 3)
            for connection in connections:
                connection.request.assert_called_once_with('GET', '/api/tags')
                connection.close.assert_called_once()

    def test_permanent_error_oversize_and_redirect_are_not_retried(self):
        for connection in (self.connection(401), self.connection(302), self.connection(raw=b'x' * (broker.MAX_BODY + 1))):
            with self.assertRaises(ValueError):
                self.fetch([connection], sleep=Mock(side_effect=AssertionError('retry')))
            connection.close.assert_called_once()

    def test_retry_after_is_respected_or_fails_without_early_retry(self):
        sleep = Mock()
        self.fetch([self.connection(429, '1'), self.connection()], sleep=sleep)
        sleep.assert_called_once_with(1)
        for after in ('120', 'invalid', 'Wed, 01 Jan 2030 00:00:00 GMT', '-1'):
            sleep = Mock()
            with self.assertRaises(ValueError):
                self.fetch([self.connection(429, after)], sleep=sleep)
            sleep.assert_not_called()

    def test_transport_errors_retry_only_inventory_without_leaking_error_text(self):
        connection = self.connection()
        connection.request.side_effect = OSError('PRIVATE-TRANSPORT-TEXT')
        with self.assertRaises(ValueError) as error:
            self.fetch([connection] * 3, sleep=Mock())
        self.assertNotIn('PRIVATE-TRANSPORT-TEXT', str(error.exception))
        self.assertEqual(connection.close.call_count, 3)

    def test_expired_deadline_and_last_attempt_never_sleep(self):
        with patch.object(broker.http.client, 'HTTPConnection') as factory, self.assertRaises(ValueError):
            broker.inventory_get('127.0.0.1', 11434, 0, clock=lambda: 0)
        factory.assert_not_called()
        sleep = Mock()
        with self.assertRaises(ValueError):
            self.fetch([self.connection(503)] * 3, sleep=sleep)
        self.assertEqual(sleep.call_count, 2)

    def test_inference_post_is_not_wrapped_in_inventory_retry(self):
        source = (ROOT / 'scripts/agents/model_broker.py').read_text()
        forward = source.split('        def forward(self):', 1)[1]
        self.assertNotIn('inventory_get(', forward)
        self.assertIn('connection.request(self.command, self.path, body', forward)


class MCPBoundary(unittest.TestCase):
    def test_stdio_handshake_fixture_has_only_jsonrpc_and_exits_on_eof(self):
        requests = [dict(jsonrpc='2.0', id=1, method='initialize',
                         params={'protocolVersion': '2025-06-18'}),
                    dict(jsonrpc='2.0', id=2, method='tools/list')]
        result = subprocess.run([sys.executable, '-I', '-B', str(Path(launcher.__file__)),
                                 'run', '--approve', 'audio_plan'],
                                input=''.join(json.dumps(row) + '\n' for row in requests),
                                text=True, capture_output=True, timeout=20, cwd=ROOT)
        self.assertEqual(result.returncode, 0, result.stderr)
        replies = [json.loads(row) for row in result.stdout.splitlines()]
        self.assertEqual([row['id'] for row in replies], [1, 2])
        self.assertEqual(replies[1]['result']['tools'][0]['name'], 'plan_audio_project')
        self.assertEqual(len(replies[1]['result']['tools']), 1)

    def test_plan_never_executes_and_config_requires_approval(self):
        with patch.object(launcher.os, 'execve') as execute, contextlib.redirect_stdout(io.StringIO()) as out:
            self.assertEqual(launcher.main([]), 0)
        execute.assert_not_called()
        self.assertFalse(json.loads(out.getvalue())['apply'])
        for action in ('config', 'run'):
            with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit) as error:
                launcher.main([action])
            self.assertEqual(error.exception.code, 2)

    def test_standard_config_routes_through_fixed_approved_launcher(self):
        with contextlib.redirect_stdout(io.StringIO()) as out:
            self.assertEqual(launcher.main(['config', '--approve', 'audio_plan']), 0)
        row = json.loads(out.getvalue())['mcpServers']['audio_plan']
        self.assertEqual(row['command'], sys.executable)
        self.assertEqual(row['args'][-3:], ['run', '--approve', 'audio_plan'])
        self.assertEqual(set(row), {'command', 'args'})

    def test_execution_scrubs_secrets_and_launches_only_existing_planner(self):
        with patch.dict(os.environ, {'OPENAI_API_KEY': 'private-fixture', 'PYTHONPATH': '/foreign', 'BASH_ENV': '/foreign'}), \
                patch.object(launcher.os, 'execve') as execute:
            self.assertEqual(launcher.main(['run', '--approve', 'audio_plan']), 0)
        binary, args, env = execute.call_args.args
        self.assertEqual(binary, sys.executable)
        self.assertEqual(args, [sys.executable, '-I', '-B', str(launcher.SERVER)])
        for key in ('OPENAI_API_KEY', 'PYTHONPATH', 'BASH_ENV'):
            self.assertNotIn(key, env)

    def test_arbitrary_commands_remote_endpoints_and_paths_are_rejected(self):
        for args in (['run', '--approve', 'filesystem'], ['run', '--url', 'https://example.invalid'],
                     ['run', '--command', 'sh']):
            with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
                launcher.main(args)


if __name__ == '__main__':
    unittest.main()
