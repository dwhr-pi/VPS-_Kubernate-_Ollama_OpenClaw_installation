"""Synthetic file restores and mocked hybrid readiness, never real SSH/keys/models."""
import argparse
import contextlib
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]


def load(name, relative):
    spec = importlib.util.spec_from_file_location(name, ROOT / relative)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


restore = load('restore_fixture', 'scripts/operations/restore_drill.py')
gate = load('gpu_fixture', 'scripts/home-watcher/gpu_health_gate.py')


class Operations(unittest.TestCase):
    def args(self):
        return argparse.Namespace(pi_ip='10.7.0.2', worker_ip='192.168.1.20', control_ip='10.7.0.1',
                                  mac='02:11:22:33:44:55', node='home-gpu', ssh_user='operator',
                                  timeout=20, identity_file=Path('/synthetic/key'),
                                  known_hosts=Path('/synthetic/known-hosts'))

    def node(self):
        return {'metadata': {'name': 'home-gpu'}, 'status': {'conditions': [{'type': 'Ready', 'status': 'True'}],
                'capacity': {'nvidia.com/gpu': '1'}, 'allocatable': {'nvidia.com/gpu': '1'}}}

    def test_default_restore_plan_never_reads_data(self):
        with patch.object(restore, 'restore', side_effect=AssertionError('No restore')), \
                contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(restore.main([]), 3)

    def test_real_restore_without_explicit_data_approval_never_opens_backup(self):
        with patch.object(restore, 'restore', side_effect=AssertionError('No restore')), \
                contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(restore.main(['--apply']), 1)

    def test_fixture_really_copies_and_verifies_but_never_claims_runtime(self):
        result = restore.fixture()
        self.assertEqual(result['files'], 2)
        self.assertEqual(result['scope'], 'synthetic-file-restore-fixture')
        self.assertFalse(result['runtime_verified'])
        self.assertFalse(result['database_consistency_verified'])

    def test_bad_archive_names_fail(self):
        for name in ('../secret', '/secret', 'a/../b', 'a//b', 'a\\b', 'C:/secret',
                     '.', 'a\nname', 'a' * 1025, '/'.join(['a'] * 33)):
            with self.subTest(name=name), self.assertRaises(ValueError):
                restore.safe_name(name)

    def test_malformed_manifest_is_rejected_without_output(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            archive, manifest = root / 'fixture.tar', root / 'manifest.json'
            archive.write_bytes(b'')
            manifest.write_text('[]')
            with self.assertRaises(ValueError):
                restore.restore(archive, manifest, root / 'output')
            self.assertFalse((root / 'output').exists())

    def test_restore_rejects_incomplete_and_link_archives_before_output(self):
        import tarfile
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            manifest = root / 'manifest.json'
            manifest.write_text(json.dumps({'schema': 1, 'files': {'safe': {'size': 1, 'sha256': 'a' * 64}}}))
            archive = root / 'fixture.tar'
            for link in (False, True):
                with tarfile.open(archive, 'w') as tar:
                    if link:
                        member = tarfile.TarInfo('safe')
                        member.type = tarfile.SYMTYPE
                        member.linkname = '/must-not-follow'
                        tar.addfile(member)
                with self.assertRaises(ValueError):
                    restore.restore(archive, manifest, root / 'output')
                self.assertFalse((root / 'output').exists())

    def test_hash_failure_retains_partial_without_success(self):
        import tarfile
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            archive, manifest = root / 'fixture.tar', root / 'manifest.json'
            with tarfile.open(archive, 'w') as tar:
                member = tarfile.TarInfo('safe')
                member.size = 1
                tar.addfile(member, io.BytesIO(b'x'))
            manifest.write_text(json.dumps({'schema': 1, 'files': {'safe': {'size': 1, 'sha256': '0' * 64}}}))
            with self.assertRaises(ValueError):
                restore.restore(archive, manifest, root / 'output')
            self.assertEqual((root / 'output/safe').read_bytes(), b'x')
            with self.assertRaises(ValueError):
                restore.restore(archive, manifest, root / 'output')

    def test_public_targets_root_user_and_injected_node_are_rejected(self):
        for field, value in [('worker_ip', '8.8.8.8'), ('pi_ip', '127.0.0.1'),
                             ('control_ip', 'example.org'), ('ssh_user', 'root'),
                             ('node', 'name; shutdown'), ('mac', 'ff:ff:ff:ff:ff:ff')]:
            args = self.args()
            setattr(args, field, value)
            with self.subTest(field=field), self.assertRaises(ValueError):
                gate.contract(args)

    def test_node_requires_matching_name_ready_and_gpu(self):
        node = self.node()
        self.assertTrue(gate.node_ready(json.dumps(node), 'home-gpu'))
        self.assertFalse(gate.node_ready(json.dumps(node), 'other'))
        node['status']['allocatable']['nvidia.com/gpu'] = '0'
        self.assertFalse(gate.node_ready(json.dumps(node), 'home-gpu'))
        self.assertFalse(gate.node_ready('[]', 'home-gpu'))

    def test_ordered_health_gate_uses_pi_and_control_not_arbitrary_shell(self):
        commands = []
        def runner(command, timeout):
            commands.append(command)
            self.assertLessEqual(timeout, 5)
            return json.dumps(self.node()).encode() if 'kubectl' in command[-1] else b''
        result = gate.run_gate(self.args(), runner=runner, version=lambda ip, timeout: True)
        self.assertEqual(result['phases'], ['wake-requested', 'worker-ssh', 'node-ready-gpu', 'ollama-version'])
        self.assertIn('operator@10.7.0.2', commands[0])
        self.assertIn('operator@10.7.0.1', commands[-1])
        for command in commands:
            self.assertIn('StrictHostKeyChecking=yes', command)
            self.assertIn('IdentityAgent=none', command)
            self.assertNotIn('sudo', command[-1])
        self.assertFalse(result['inference_tested'])

    def test_failed_ssh_never_advances_to_model_or_node(self):
        calls = []
        def runner(command, timeout):
            calls.append(command[-1])
            if command[-1] != 'true':
                return b''
            raise ValueError('synthetic failure')
        with self.assertRaises(ValueError):
            gate.run_gate(self.args(), runner=runner,
                          version=lambda *args: self.fail('No model readiness'), sleep=lambda delay: None)
        self.assertEqual(len(calls), 7)
        self.assertFalse(any('kubectl' in call for call in calls))


if __name__ == '__main__':
    unittest.main()
