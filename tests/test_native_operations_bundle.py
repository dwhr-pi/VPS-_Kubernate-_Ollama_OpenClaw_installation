"""Offline MCP/maintenance fixtures; no real SDK, APIs, audio decoder or database."""
from contextlib import redirect_stdout, redirect_stderr
from datetime import datetime, timezone
import importlib.util
import io
import json
from pathlib import Path
import re
import sys
import tempfile
import types
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]


def module(name, relative):
    spec = importlib.util.spec_from_file_location(name, ROOT / relative)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


audio = module('dejavu_fixture', 'scripts/audio/openclaw_dejavu_mcp_server.py')
maintenance = module('maintenance_fixture', 'scripts/ops/alertmanager_maintenance.py')


def opener_for(payload, status=200):
    response = Mock(status=status)
    response.read.return_value = json.dumps(payload).encode()
    response.__enter__ = Mock(return_value=response)
    response.__exit__ = Mock(return_value=False)
    opener = Mock()
    opener.open.return_value = response
    return opener


class DejavuBridge(unittest.TestCase):
    def test_default_plan_never_loads_sdk_reads_token_or_contacts_backend(self):
        with patch.object(audio, 'token_file') as token, patch.object(audio, 'serve') as serve:
            with redirect_stdout(io.StringIO()) as out:
                self.assertEqual(audio.main([]), 0)
            self.assertFalse(json.loads(out.getvalue())['executed'])
            token.assert_not_called()
            serve.assert_not_called()

    def test_upload_and_runtime_flags_cannot_grant_themselves(self):
        for args in (['--apply'], ['--allow-audio-upload'], ['--token-file', 'never-read'], ['--serve']):
            with patch.object(audio, 'token_file') as token, redirect_stderr(io.StringIO()):
                with self.assertRaises(SystemExit):
                    audio.main(args)
                token.assert_not_called()

    def test_public_metadata_redirect_and_plain_remote_urls_are_rejected(self):
        for url in ('http://169.254.169.254', 'https://8.8.8.8', 'http://10.0.0.2',
                    'http://localhost', 'http://127.0.0.1/path', 'http://u:p@127.0.0.1',
                    'http://127.0.0.1?x=1'):
            with self.subTest(url=url), self.assertRaises(ValueError):
                audio.endpoint(url)
        self.assertEqual(audio.endpoint('https://10.0.0.2:8000'), ('https://10.0.0.2:8000', True))
        with self.assertRaises(ValueError):
            audio.NoRedirect().redirect_request(None)

    def test_audio_paths_magic_size_and_hardlinks_are_bounded(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / 'sample.wav').write_bytes(b'RIFF0000WAVEfixture')
            self.assertTrue(audio.read_audio(root, 'sample.wav').startswith(b'RIFF'))
            for name in ('../sample.wav', '/sample.wav', 'https://host/a.wav', 'x\nsample.wav'):
                with self.assertRaises(ValueError):
                    audio.read_audio(root, name)
            (root / 'wrong.wav').write_bytes(b'not a WAV file at all')
            with self.assertRaises(ValueError):
                audio.read_audio(root, 'wrong.wav')
            with patch.object(audio, 'MAX_AUDIO', 12), self.assertRaises(ValueError):
                audio.read_audio(root, 'sample.wav')
            fake_stat = Mock(st_mode=audio.stat.S_IFREG, st_nlink=2, st_size=18)
            with patch.object(audio.os, 'fstat', return_value=fake_stat), self.assertRaises(ValueError):
                audio.read_audio(root, 'sample.wav')

    def test_default_client_never_uploads_or_registers(self):
        with tempfile.TemporaryDirectory() as temporary:
            opener = opener_for({})
            client = audio.OpenClawDejavuClient('http://127.0.0.1:8000', temporary, opener=opener)
            with self.assertRaises(ValueError):
                client.recognize_audio('never-read.wav')
            opener.open.assert_not_called()
            self.assertFalse(hasattr(client, 'register_song'))
            with self.assertRaises(ValueError):
                audio.OpenClawDejavuClient('https://10.0.0.2', temporary)

    def test_backend_health_is_not_runtime_acceptance(self):
        with tempfile.TemporaryDirectory() as temporary:
            opener = opener_for({'schema_version': 1, 'status': 'ok', 'backend': 'dejavu'})
            client = audio.OpenClawDejavuClient('http://127.0.0.1:8000', temporary, opener=opener)
            self.assertFalse(client.check_health()['runtime_acceptance'])
            self.assertEqual(opener.open.call_args.args[0].method, 'GET')
            self.assertEqual(opener.open.call_args.kwargs['timeout'], 30)

    def test_recognition_emits_only_reviewed_fields_and_generic_filename(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / 'sample.wav').write_bytes(b'RIFF0000WAVEfixture')
            opener = opener_for({'match_found': True, 'song_name': 'Sample',
                                 'fingerprint_matches': 3, 'offset_seconds': 1.5, 'secret': 'do-not-return'})
            client = audio.OpenClawDejavuClient('http://127.0.0.1:8000', root,
                       allow_audio_upload=True, opener=opener)
            result = client.recognize_audio('sample.wav')
            self.assertEqual(result['fingerprint_matches'], 3)
            self.assertNotIn('confidence', result)
            self.assertNotIn('secret', result)
            request = opener.open.call_args.args[0]
            self.assertEqual(request.method, 'POST')
            self.assertIn(b'filename="input.wav"', request.data)
            self.assertNotIn(str(root).encode(), request.data)
            self.assertNotIn(b'sample.wav', request.data)
            self.assertFalse(result['runtime_acceptance'])

    def test_invalid_backend_status_and_data_are_not_echoed(self):
        with tempfile.TemporaryDirectory() as temporary:
            for status in (202, 403, 429):
                client = audio.OpenClawDejavuClient('http://127.0.0.1:8000', temporary,
                           opener=opener_for({'private': 'secret'}, status))
                with self.assertRaises(ValueError) as error:
                    client.check_health()
                self.assertNotIn('secret', str(error.exception))
            client = audio.OpenClawDejavuClient('http://127.0.0.1:8000', temporary,
                       opener=opener_for({'status': 'ok'}))
            with self.assertRaises(ValueError):
                client.check_health()

    def test_oversized_backend_reply_is_rejected_before_json_decode(self):
        with tempfile.TemporaryDirectory() as temporary:
            opener = opener_for({})
            opener.open.return_value.read.return_value = b'x' * 65537
            client = audio.OpenClawDejavuClient('http://127.0.0.1:8000', temporary, opener=opener)
            with self.assertRaises(ValueError):
                client.check_health()

    def test_stdio_sdk_is_stubbed_and_write_tool_is_not_registered(self):
        server = Mock()
        registered = {}
        def tool():
            def register(func):
                registered[func.__name__] = func
                return func
            return register
        server.tool.side_effect = tool
        fake = types.ModuleType('mcp.server.fastmcp')
        fake.FastMCP = Mock(return_value=server)
        with patch.dict(sys.modules, {'mcp': types.ModuleType('mcp'),
                        'mcp.server': types.ModuleType('mcp.server'), 'mcp.server.fastmcp': fake}), \
                patch.object(audio.importlib.metadata, 'version', return_value=audio.SDK_VERSION):
            audio.serve(types.SimpleNamespace(allow_audio_upload=False))
        self.assertEqual(set(registered), {'check_dejavu_health'})
        server.run.assert_called_once_with(transport='stdio')
        with patch.object(audio.importlib.metadata, 'version', return_value='2.0.0'), self.assertRaises(ValueError):
            audio.serve(None)


class NativeMaintenance(unittest.TestCase):
    def test_scopes_are_exact_utc_finite_and_never_global(self):
        payload = maintenance.scoped_payload('home', 'llmops', 'dejavu', 30,
                                            datetime(2026, 11, 11, 10, tzinfo=timezone.utc))
        self.assertEqual(payload['endsAt'], '2026-11-11T10:30:00Z')
        self.assertEqual({m['name'] for m in payload['matchers']}, {'cluster', 'namespace', 'job'})
        self.assertTrue(all(not m['isRegex'] and m['isEqual'] for m in payload['matchers']))
        for value in ('', '.*', 'x"y', 'x\ny'):
            with self.assertRaises(ValueError):
                maintenance.scoped_payload(value, 'llmops', 'dejavu')
        for duration in (0, 61, True):
            with self.assertRaises(ValueError):
                maintenance.scoped_payload('home', 'llmops', 'dejavu', duration)

    def test_plan_and_bad_confirmation_never_mutate(self):
        args = ['silence', '--cluster', 'home', '--namespace', 'llmops', '--job', 'dejavu']
        with patch.object(maintenance, 'perform') as perform:
            with redirect_stdout(io.StringIO()) as output:
                self.assertEqual(maintenance.main(args), 0)
            self.assertFalse(json.loads(output.getvalue())['executed'])
            with redirect_stderr(io.StringIO()):
                self.assertEqual(maintenance.main(args + ['--apply', '--confirm', 'wrong']), 2)
            perform.assert_not_called()

    def test_silence_id_and_delete_use_actual_api_contract(self):
        identifier = '12345678-1234-1234-1234-123456789abc'
        opener = opener_for({'silenceID': identifier})
        result = maintenance.perform('http://127.0.0.1:9093', 'silence', {}, opener=opener)
        self.assertEqual(result['silence_id'], identifier)
        self.assertFalse(result['discord_delivery_verified'])
        opener = opener_for({})
        maintenance.perform('http://127.0.0.1:9093', 'cancel', None, identifier, opener)
        request = opener.open.call_args.args[0]
        self.assertEqual(request.method, 'DELETE')
        self.assertEqual(request.full_url, 'http://127.0.0.1:9093/api/v2/silence/' + identifier)
        for status in (201, 202, 403):
            with self.assertRaises(ValueError):
                maintenance.perform('http://127.0.0.1:9093', 'silence', {}, opener=opener_for({}, status))
        with self.assertRaises(ValueError):
            maintenance.perform('http://127.0.0.1:9093', 'silence', {}, opener=opener_for({'silenceId': identifier}))

    def test_nonloopback_credentials_and_redirects_are_refused(self):
        for url in ('http://10.0.0.1', 'https://example.com', 'http://u:p@127.0.0.1', 'http://127.0.0.1/path'):
            with self.assertRaises(ValueError):
                maintenance.endpoint(url)
        with self.assertRaises(ValueError):
            maintenance.NoRedirect().redirect_request(None)

    def test_exact_confirmation_dispatches_only_the_scoped_operation(self):
        args = ['silence', '--cluster', 'home', '--namespace', 'llmops', '--job', 'dejavu',
                '--apply', '--confirm', 'silence:home:llmops:dejavu']
        with patch.object(maintenance, 'perform', return_value={'acknowledged': True}) as perform:
            with redirect_stdout(io.StringIO()):
                self.assertEqual(maintenance.main(args), 0)
            self.assertEqual(perform.call_args.args[1], 'silence')
            self.assertEqual(len(perform.call_args.args[2]['matchers']), 3)


class BundleDocumentation(unittest.TestCase):
    def test_oidc_patch_keeps_base_pod_and_container_security_explicit(self):
        patch_text = (ROOT / 'examples/open-webui/openwebui-oidc.patch.yaml').read_text()
        for value in ('automountServiceAccountToken: false', 'runAsNonRoot: true',
                      'runAsUser: 10001', 'runAsGroup: 10001', 'fsGroup: 10001',
                      'type: RuntimeDefault', 'allowPrivilegeEscalation: false',
                      'readOnlyRootFilesystem: true', 'drop: [ALL]'):
            self.assertIn(value, patch_text)
        self.assertIn('      securityContext:\n        runAsNonRoot: true', patch_text)
        self.assertIn('          securityContext:\n            allowPrivilegeEscalation: false', patch_text)
        self.assertNotIn('readOnlyRootFilesystem: false', patch_text)
        self.assertNotIn('runAsUser: 0', patch_text)

    def test_keycloak_and_make_defaults_are_not_privileged_or_destructive(self):
        client = json.loads((ROOT / 'examples/open-webui/keycloak-client.json').read_text())
        self.assertNotIn('secret', client)
        self.assertFalse(client['fullScopeAllowed'])
        self.assertFalse(client['directAccessGrantsEnabled'])
        self.assertEqual(client['redirectUris'], ['https://ai.example.invalid/oauth/oidc/callback'])
        make = (ROOT / 'Makefile').read_text()
        self.assertIn('.DEFAULT_GOAL := help', make)
        self.assertNotIn('%:', make)
        self.assertNotIn('docker compose', make)
        self.assertIn('@exit 3', make)

    def test_all_handbook_links_and_sso_refs_resolve(self):
        doc = ROOT / 'docs/NATIVE_OPERATIONS_HANDBOOK.md'
        for target in re.findall(r'\]\(([^\s)]+)\)', doc.read_text()):
            if '://' not in target and not target.startswith('#'):
                self.assertTrue((doc.parent / target.split('#')[0]).is_file(), target)
        patch_text = (ROOT / 'examples/open-webui/openwebui-oidc.patch.yaml').read_text()
        self.assertIn('OPENID_PROVIDER_URL', patch_text)
        self.assertNotIn('OAUTH_OPENID_PROVIDER_URL', patch_text)
        self.assertIn('name: ENABLE_OAUTH_ROLE_MANAGEMENT, value: "false"', patch_text)
        self.assertIn('secretKeyRef:', patch_text)


if __name__ == '__main__':
    unittest.main()
