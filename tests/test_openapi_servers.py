"""Offline fixtures: no downloads, installed packages, sockets or real keys."""
import asyncio
import contextlib
import importlib
import io
import json
import os
from pathlib import Path
import re
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts/tools/helpers'))
G = importlib.import_module('gap_tools')
R = importlib.import_module('openapi_servers_runtime')
A = importlib.import_module('openapi_time_guard')
KEY = 'fixture_token_not_a_real_secret_0123456789'


def config(**kwargs):
    return dict(version=1, port=8021, bearer_token=KEY, allowed_origins=[], **kwargs)


class OpenAPIServersTests(unittest.TestCase):
    def test_registration_pins_six_wrappers_and_ports(self):
        entry = next(t for t in json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools'] if t['id'] == 'openapi_servers')
        spec = G.SPECS['openapi_servers']
        self.assertEqual(entry['source_commit'], spec['pin'])
        self.assertEqual(spec['mode'], 'openapi-time')
        self.assertFalse(entry['auto_install'])
        self.assertEqual(entry['ports'], [8021])
        for action in ('install', 'update', 'uninstall', 'check', 'status', 'doctor'):
            self.assertIn('gap_tools.py" openapi_servers ' + action,
                          (ROOT / ('scripts/tools/openapi_servers_' + action + '.sh')).read_text())
        for file in ('setup_ultimate.sh', 'scripts/helpers/native_tool_status.sh', 'scripts/helpers/status_tracking.sh'):
            self.assertIn('OpenAPI_Servers', (ROOT / file).read_text(encoding='utf-8'))
        ports = json.loads((ROOT / 'config/ports.yml').read_text())['ports']
        self.assertEqual([p['service'] for p in ports if p['port'] == 8021], ['openapi_servers'])

    def test_plans_do_not_write_download_configure_or_start(self):
        with tempfile.TemporaryDirectory() as temp:
            workspace = Path(temp) / 'absent'
            with patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': str(workspace)}), patch.object(G, 'git', side_effect=AssertionError('network')), patch.object(R, 'prepare', side_effect=AssertionError('download')), patch.object(os, 'execve', side_effect=AssertionError('start')), contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(G.main(['openapi_servers', '--dry-run', '--install-build-deps']), 0)
                self.assertEqual(R.main(['plan']), 0)
            self.assertFalse(workspace.exists())

    def test_runtime_build_is_time_only_wheel_locked_and_does_not_import_server(self):
        with tempfile.TemporaryDirectory() as temp:
            runtime = Path(temp) / 'runtime'
            (runtime / 'servers/time').mkdir(parents=True)
            (runtime / 'servers/time/requirements.txt').write_text('fastapi\nuvicorn\npytz\npython-dateutil\n')
            (runtime / 'servers/time/main.py').write_text('raise AssertionError("must not import during install")')
            with patch('native_uv.select', return_value='/fixture/uv'), patch.object(G, 'run', return_value='fixture') as run, patch.object(os, 'execve', side_effect=AssertionError('start')):
                env = {}
                entries = R.build(runtime, env)
            commands = [list(map(str, c.args[0])) for c in run.call_args_list]
            self.assertEqual(commands[0][1:3], ['pip', 'compile'])
            self.assertIn('--generate-hashes', commands[0])
            self.assertIn('--require-hashes', commands[2])
            self.assertIn('--only-binary', commands[0])
            self.assertIn('--only-binary', commands[2])
            self.assertIn('time-requirements.lock', entries)
            self.assertEqual(env['UV_PYTHON_DOWNLOADS'], 'never')
            self.assertNotIn('bearer_token', (runtime / 'openapi_time_guard.py').read_text().split("if __name__", 1)[-1])
            self.assertFalse((runtime.parent / 'config').exists())

    def test_private_configuration_is_not_overwritten_or_printed(self):
        with tempfile.TemporaryDirectory() as temp:
            with contextlib.redirect_stdout(io.StringIO()) as output:
                path = R.configure(Path(temp))
                content = path.read_bytes()
                R.configure(Path(temp), port=8022)
            self.assertEqual(content, path.read_bytes())
            data = A.load_config(path)
            self.assertNotIn(data['bearer_token'], output.getvalue())
            self.assertEqual(data['port'], 8021)
            self.assertEqual(data['allowed_origins'], [])
            if os.name == 'posix':
                self.assertEqual(path.stat().st_mode & 0o777, 0o600)

    def test_invalid_configs_and_wildcard_origins_fail(self):
        for change in ({'port': 80}, {'port': True}, {'bearer_token': 'short'},
                       {'allowed_origins': ['*']}, {'allowed_origins': ['http://localhost:3000/path']},
                       {'allowed_origins': ['http://u:p@localhost:3000']}, {'allowed_origins': ['https://x\n']}):
            data = config()
            data.update(change)
            with self.subTest(change=change), self.assertRaises(ValueError):
                A.validate_config(data)

    def test_missing_configuration_blocks_start_without_exec(self):
        with tempfile.TemporaryDirectory() as temp:
            with patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': temp}), patch.object(G, 'validate'), patch.object(os, 'execve') as execute:
                with self.assertRaises(OSError):
                    R.main(['start'])
                execute.assert_not_called()

    def test_start_is_explicit_loopback_and_keeps_keys_out_of_args_and_environment(self):
        with tempfile.TemporaryDirectory() as temp:
            with patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': temp, 'OPENAI_API_KEY': 'fixture-provider-secret'}):
                base, runtime, marker = G.paths('openapi_servers')
                (runtime / '.venv/bin').mkdir(parents=True)
                (runtime / '.venv/bin/python').write_text('fixture')
                R.configure(base)
                token = A.load_config(base / 'config/time.json')['bearer_token']
                with patch.object(G, 'validate') as validate, patch.object(os, 'execve') as execute:
                    self.assertEqual(R.main(['start']), 0)
                    validate.assert_called_once()
                    self.assertTrue(validate.call_args.kwargs['full'])
                    args = execute.call_args.args
                    self.assertIn('-B', args[1])
                    self.assertNotIn(token, repr(args))
                    self.assertNotIn('OPENAI_API_KEY', args[2])

    def request(self, *, path='/get_current_utc_time', token=KEY, origin=None, host='127.0.0.1:8021', method='GET', duplicate=False, allowed=()):
        messages = []
        called = []
        async def app(scope, receive, send):
            called.append(scope['path'])
            await send({'type': 'http.response.start', 'status': 200, 'headers': []})
            await send({'type': 'http.response.body', 'body': b'fixture time'})
        async def receive():
            return {'type': 'http.request', 'body': b''}
        async def send(msg):
            messages.append(msg)
        headers = [(b'host', host.encode())]
        if token is not None:
            headers.append((b'authorization', ('Bearer ' + token).encode()))
        if duplicate:
            headers.append((b'authorization', b'Bearer duplicate'))
        if origin:
            headers.append((b'origin', origin.encode()))
        data = config()
        data['allowed_origins'] = list(allowed)
        asyncio.run(A.TimeGuard(app, data)({'type': 'http', 'path': path, 'method': method, 'headers': headers}, receive, send))
        return messages, called

    def test_every_route_including_schema_requires_auth(self):
        for path in ('/', '/openapi.json', '/docs', '/get_current_utc_time'):
            messages, called = self.request(path=path, token=None)
            self.assertEqual(messages[0]['status'], 401)
            self.assertFalse(called)
        self.assertEqual(self.request(token='wrong')[0][0]['status'], 401)
        self.assertEqual(self.request(duplicate=True)[0][0]['status'], 401)
        self.assertEqual(self.request()[0][0]['status'], 200)

    def test_dns_rebinding_and_unapproved_browser_origins_fail_closed(self):
        for host in ('evil.example:8021', '0.0.0.0:8021'):
            messages, called = self.request(host=host)
            self.assertEqual(messages[0]['status'], 403)
            self.assertFalse(called)
        self.assertEqual(self.request(origin='https://evil.example')[0][0]['status'], 403)

    def test_explicit_origin_preflight_and_authenticated_request(self):
        origin = 'http://127.0.0.1:3000'
        messages, called = self.request(token=None, origin=origin, method='OPTIONS', allowed=[origin])
        self.assertEqual(messages[0]['status'], 204)
        self.assertFalse(called)
        self.assertIn((b'access-control-allow-origin', origin.encode()), messages[0]['headers'])
        self.assertEqual(self.request(origin=origin, allowed=[origin])[0][0]['status'], 200)
        self.assertEqual(self.request(token=None, origin=origin, allowed=[origin])[0][0]['status'], 401)

    def test_documentation_and_local_links(self):
        doc = ROOT / 'docs/tools/openapi-servers.md'
        text = doc.read_text(encoding='utf-8')
        for phrase in ('ungeprueft', 'show-key', '127.0.0.1:8021', 'Bearer', 'deaktiviert', 'MCPO', 'time-requirements.lock'):
            self.assertIn(phrase, text)
        for link in re.findall(r'\]\(([^)]+)\)', text):
            if '://' not in link:
                self.assertTrue((doc.parent / link.split('#')[0]).is_file(), link)
        self.assertEqual(text.count('```') % 2, 0)


if __name__ == '__main__':
    unittest.main()
