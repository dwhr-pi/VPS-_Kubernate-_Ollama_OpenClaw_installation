"""Synthetic listener fixtures only; never inspect real host processes or sockets."""
import contextlib
import importlib.util
import io
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('listener_check', ROOT / 'scripts/security/listener_audit.py')
audit = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(audit)


def line(endpoint, protocol='tcp'):
    state = 'LISTEN' if protocol == 'tcp' else 'UNCONN'
    return f'{protocol} {state} 0 128 {endpoint} *:* users:(("synthetic-secret",pid=12,fd=3))\n'


class ListenerAudit(unittest.TestCase):
    def test_wildcards_ipv4_ipv6_and_udp_are_rejected(self):
        for endpoint in ('0.0.0.0:11434', '[::]:11434', '*:11434', ':::11434'):
            for protocol in ('tcp', 'udp'):
                result = audit.assess(line(endpoint, protocol), {11434})
                self.assertEqual(result['findings'][0]['reason'], 'wildcard')
                self.assertNotIn('synthetic-secret', json.dumps(result))

    def test_loopback_and_mapped_ipv4_are_allowed(self):
        for endpoint in ('127.0.0.1:11434', '[::1]:11434', '[::ffff:127.0.0.1]:11434'):
            self.assertEqual(audit.assess(line(endpoint), {11434})['findings'], [])

    def test_private_address_requires_exact_opt_in(self):
        text = line('10.44.0.5:11434')
        self.assertTrue(audit.assess(text, {11434})['findings'])
        allowed = (audit.private_network('10.44.0.0/24'),)
        self.assertFalse(audit.assess(text, {11434}, allowed)['findings'])
        self.assertTrue(audit.assess(line('10.45.0.5:11434'), {11434}, allowed)['findings'])
        self.assertTrue(audit.assess(line('0.0.0.0:11434'), {11434}, allowed)['findings'])

    def test_public_or_overbroad_cidr_cannot_disable_boundary(self):
        for value in ('0.0.0.0/0', '::/0', '8.8.8.0/24', '10.44.0.5/24', 'garbage'):
            with self.assertRaises(ValueError):
                audit.private_network(value)

    def test_invalid_output_is_not_silently_ignored(self):
        for text in ('unexpected header', line('127.0.0.1:bad'), line('invalid:11434'),
                     line('127.0.0.1:99999'), 'x' * (audit.MAX_INPUT + 1)):
            with self.assertRaises(ValueError):
                audit.listeners(text)

    def test_unregistered_ports_are_counted_not_certified(self):
        result = audit.assess(line('0.0.0.0:80'), {11434})
        self.assertFalse(result['findings'])
        self.assertEqual(result['unregistered_listener_count'], 1)
        self.assertFalse(result['runtime_acceptance'])

    def test_registry_preserves_control_api_and_rejects_duplicates(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'registry.json'
            path.write_text(json.dumps({'ports': [{'port': 4000}]}))
            self.assertEqual(audit.registry_ports(path), {4000, 6443, 11434, 18789})
            for rows in ([{'port': True}], [{'port': 0}], [{'port': 4000}, {'port': 4000}]):
                path.write_text(json.dumps({'ports': rows}))
                with self.assertRaises(ValueError):
                    audit.registry_ports(path)

    def invoke(self, args):
        with patch.object(sys, 'argv', ['listener_audit.py', *args]), \
                contextlib.redirect_stdout(io.StringIO()) as out, \
                contextlib.redirect_stderr(io.StringIO()) as err:
            result = audit.main()
        return result, out.getvalue(), err.getvalue()

    def test_default_and_dry_run_have_no_host_or_file_access(self):
        with patch.object(audit, 'registry_ports') as registry, \
                patch.object(audit.subprocess, 'run') as run:
            for args in ([], ['--dry-run']):
                self.assertEqual(self.invoke(args)[0], 0)
            registry.assert_not_called()
            run.assert_not_called()

    def test_missing_ss_and_command_failure_are_incomplete(self):
        with patch.object(sys, 'platform', 'linux'), patch.object(audit.shutil, 'which', return_value=None):
            self.assertEqual(self.invoke(['--check-host'])[0], 2)
        with patch.object(sys, 'platform', 'linux'), \
                patch.object(audit.shutil, 'which', return_value='/fixture/ss'), \
                patch.object(audit.subprocess, 'run',
                             side_effect=subprocess.CalledProcessError(1, 'ss', stderr='synthetic-secret')):
            status, out, err = self.invoke(['--check-host'])
            self.assertEqual(status, 2)
            self.assertNotIn('synthetic-secret', out + err)

    def test_stdin_findings_have_nonzero_exit_without_process_details(self):
        with patch.object(sys, 'stdin', io.StringIO(line('0.0.0.0:11434'))):
            status, out, err = self.invoke(['--stdin'])
        self.assertEqual(status, 1)
        self.assertNotIn('synthetic-secret', out + err)

    def test_timeout_is_bounded_and_not_a_success(self):
        with patch.object(sys, 'platform', 'linux'), \
                patch.object(audit.shutil, 'which', return_value='/fixture/ss'), \
                patch.object(audit.subprocess, 'run', side_effect=subprocess.TimeoutExpired('ss', 10)) as run:
            self.assertEqual(self.invoke(['--check-host'])[0], 2)
            self.assertEqual(run.call_args.kwargs['timeout'], 10)
            self.assertEqual(run.call_args.args[0], ['/fixture/ss', '-H', '-lntup'])


if __name__ == '__main__':
    unittest.main()
