"""Opt-in monitor fixtures; no cluster, credentials or external requests."""
from contextlib import redirect_stdout
import importlib.util
import io
import json
from pathlib import Path
import subprocess
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('log_monitor_fixture', ROOT / 'scripts/monitoring/ollama_log_monitor.py')
monitor = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(monitor)


class LogMonitor(unittest.TestCase):
    def test_default_plan_never_accesses_cluster_or_credentials(self):
        with patch.object(monitor, 'snapshot') as poll, patch.object(monitor, 'read_webhook') as read:
            with redirect_stdout(io.StringIO()) as output:
                self.assertEqual(monitor.main([]), 0)
            self.assertFalse(json.loads(output.getvalue())['executed'])
            poll.assert_not_called()
            read.assert_not_called()

    def test_runtime_and_external_delivery_need_explicit_approvals(self):
        for argv in (['--watch'], ['--watch', '--apply'], ['--send-discord'],
                     ['--watch', '--apply', '--context', 'test', '--webhook-file', 'never-read']):
            with patch.object(monitor, 'read_webhook') as read, patch.object(monitor, 'snapshot') as poll:
                with self.assertRaises(SystemExit):
                    monitor.main(argv)
                read.assert_not_called()
                poll.assert_not_called()

    def test_bounded_command_and_rejected_shell_fragments(self):
        args = monitor.command('test-cluster', 'llmops', 'app=ollama', 'ollama')
        self.assertIn('--limit-bytes=65536', args)
        self.assertIn('--request-timeout=15s', args)
        self.assertNotIn('-f', args)
        for namespace, selector in [('x;id', 'app=ollama'), ('llmops', '--all-namespaces'),
                                    ('llmops', 'app=ollama;id')]:
            with self.assertRaises(ValueError):
                monitor.command('test', namespace, selector, 'ollama')
        runner = Mock(return_value=subprocess.CompletedProcess(args, 0, b'ERROR fake-secret', b''))
        self.assertEqual(monitor.snapshot(args, runner), ['error'])
        self.assertNotIn('shell', runner.call_args.kwargs)
        self.assertEqual(runner.call_args.kwargs['timeout'], 20)
        self.assertEqual(runner.call_args.kwargs['stderr'], subprocess.DEVNULL)

    def test_categories_cooldown_and_failed_delivery_are_redacted(self):
        now = [100.0]
        def sleep(seconds):
            now[0] += seconds
        send = Mock(return_value=False)
        poll = Mock(return_value=['gpu-memory'])
        with redirect_stdout(io.StringIO()) as output:
            code = monitor.monitor([], duration=61, interval=10, cooldown=60, url='never-log-this',
                                   clock=lambda: now[0], sleep=sleep, poll=poll, send=send)
        self.assertEqual(code, 1)
        self.assertEqual(send.call_count, 2)
        self.assertNotIn('never-log-this', output.getvalue())
        self.assertIn('gpu-memory', output.getvalue())

    def test_failures_back_off_without_exposing_exception_text(self):
        now, waits = [0.0], []
        def sleep(seconds):
            waits.append(seconds)
            now[0] += seconds
        poll = Mock(side_effect=OSError('secret token'))
        with redirect_stdout(io.StringIO()) as output:
            code = monitor.monitor([], duration=100, interval=10, cooldown=60,
                                   clock=lambda: now[0], sleep=sleep, poll=poll)
        self.assertEqual(code, 1)
        self.assertEqual(waits, [20, 40, 40])
        self.assertNotIn('secret', output.getvalue())

    def test_native_discord_payload_and_no_redirect_or_proxy(self):
        url = 'https://discord.com/api/webhooks/' + '1' * 18 + '/' + 'A' * 24
        response = Mock(status=204)
        response.__enter__ = Mock(return_value=response)
        response.__exit__ = Mock(return_value=False)
        opener = Mock()
        opener.open.return_value = response
        self.assertTrue(monitor.notify(url, 'error', opener))
        request = opener.open.call_args.args[0]
        payload = json.loads(request.data)
        self.assertEqual(payload['allowed_mentions'], {'parse': []})
        self.assertEqual(payload['content'], 'OpenClaw Ollama monitor: error')
        self.assertNotIn('text', payload)
        for invalid in (url + '/slack', url + '?wait=true', url.replace('discord.com', 'example.com')):
            with self.assertRaises(ValueError):
                monitor.notify(invalid, 'error', opener)
        with self.assertRaises(ValueError):
            monitor.NoRedirect().redirect_request(None)

    def test_snapshot_size_and_crash_status_fail_closed(self):
        for result in (subprocess.CompletedProcess([], 1, b'', b''),
                       subprocess.CompletedProcess([], 0, b'x' * 65537, b'')):
            with self.assertRaises(ValueError):
                monitor.snapshot([], Mock(return_value=result))
        self.assertIn('oom-killed', monitor.classify('OOMKilled'))
        self.assertIn('crash', monitor.classify('panic: ignored private detail'))
        self.assertEqual(monitor.classify('healthy status'), [])

    def test_child_environment_does_not_inherit_provider_tokens(self):
        args = monitor.command('test', 'llmops', 'app=ollama', 'ollama')
        runner = Mock(return_value=subprocess.CompletedProcess(args, 0, b'healthy', b''))
        with patch.dict(monitor.os.environ, {'PROVIDER_TOKEN': 'fixture-only', 'KUBECONFIG': 'approved-config'}):
            monitor.snapshot(args, runner)
        env = runner.call_args.kwargs['env']
        self.assertNotIn('PROVIDER_TOKEN', env)
        self.assertEqual(env['KUBECONFIG'], 'approved-config')


if __name__ == '__main__':
    unittest.main()
