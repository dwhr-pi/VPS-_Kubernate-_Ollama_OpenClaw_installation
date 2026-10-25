"""SOPS/Kubernetes fixtures only; never decrypt real user secrets."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('secret_apply', ROOT / 'scripts/security/apply_vps_sops_secret.py')
secret = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(secret)


class SecretContract(unittest.TestCase):
    def fixture(self):
        return {'apiVersion': 'v1', 'kind': 'Secret', 'type': 'Opaque',
                'metadata': {'name': 'litellm-runtime', 'namespace': 'llmops', 'annotations': {'ignored': 'fixture'}},
                'stringData': {'master-key': 'fixture-only-not-a-real-key-1234567890'}}

    def test_allowlist_strips_extra_metadata_and_normalizes_payload(self):
        output = json.loads(secret.validate(json.dumps(self.fixture())))
        self.assertNotIn('annotations', output['metadata'])
        self.assertNotIn('stringData', output)
        self.assertEqual(set(output['data']), {'master-key'})

    def test_wrong_namespace_or_key_is_rejected(self):
        for change in ('namespace', 'extra-key', 'short-key'):
            value = self.fixture()
            if change == 'namespace':
                value['metadata']['namespace'] = 'kube-system'
            elif change == 'extra-key':
                value['stringData']['another'] = 'fixture'
            else:
                value['stringData']['master-key'] = 'short'
            with self.assertRaises(ValueError):
                secret.validate(json.dumps(value))

    def test_decryption_and_apply_are_captured_without_disk_plaintext(self):
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / 'secrets.enc.yaml'
            path.write_text('fixture-ciphertext')
            with patch.object(secret.subprocess, 'run', return_value=Mock(stdout=json.dumps(self.fixture()))) as run:
                secret.apply(path, 'fixture')
            self.assertEqual(run.call_count, 3)
            self.assertTrue(all(call.kwargs['capture_output'] for call in run.call_args_list))
            self.assertIn('--dry-run=server', run.call_args_list[1].args[0])
            self.assertNotIn('--dry-run=server', run.call_args_list[2].args[0])
            self.assertEqual([f.name for f in Path(temporary).iterdir()], ['secrets.enc.yaml'])

    def test_invalid_payload_never_contacts_kubernetes(self):
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / 'secrets.enc.yaml'
            path.write_text('fixture')
            with patch.object(secret.subprocess, 'run', return_value=Mock(stdout='{}')) as run:
                with self.assertRaises(ValueError):
                    secret.apply(path, 'fixture')
            self.assertEqual(run.call_count, 1)

    def test_failed_server_dry_run_never_applies(self):
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / 'secrets.enc.yaml'
            path.write_text('fixture')
            failure = secret.subprocess.CalledProcessError(1, 'kubectl', stderr='fixture-sensitive-diagnostic')
            with patch.object(secret.subprocess, 'run', side_effect=[
                    Mock(stdout=json.dumps(self.fixture())), failure]) as run:
                with self.assertRaises(secret.subprocess.CalledProcessError):
                    secret.apply(path, 'fixture')
            self.assertEqual(run.call_count, 2)
            self.assertIn('--dry-run=server', run.call_args_list[1].args[0])


if __name__ == '__main__':
    unittest.main()
