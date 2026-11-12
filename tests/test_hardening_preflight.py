"""Offline capacity and suspended sandbox contracts, never query runner hardware."""
import contextlib
import importlib.util
import io
import json
from pathlib import Path
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('capacity_health', ROOT / 'scripts/operations/platform_health.py')
health = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(health)


class HardeningPreflight(unittest.TestCase):
    def cli(self, *args):
        with contextlib.redirect_stdout(io.StringIO()) as output:
            code = health.main(list(args))
        return code, json.loads(output.getvalue())

    def test_vram_threshold_does_not_trigger_implicit_hardware_access(self):
        with patch.object(health, 'gpu_capacity', side_effect=AssertionError('hardware')):
            code, report = self.cli('doctor', '--require', 'gpu', '--min-free-vram-mib', '4096')
        self.assertEqual(code, 3)
        self.assertFalse(report['runtime_requested'])

    def test_requested_threshold_failure_is_not_runtime_acceptance(self):
        with patch.object(health, 'host_probe', return_value=(True, 'fixture')), \
                patch.object(health, 'gpu_capacity', return_value=(False, 'fixture')) as probe:
            code, report = self.cli('smoke', '--runtime', '--require', 'gpu', '--min-free-vram-mib', '4096')
        probe.assert_called_once_with(4096)
        self.assertEqual(code, 1)
        self.assertFalse(report['runtime_acceptance'])

    def test_vram_is_per_device_not_summed(self):
        with patch.object(health.shutil, 'which', return_value='/fixture/nvidia-smi'), \
                patch.object(health.subprocess, 'run', return_value=Mock(returncode=0, stdout=b'3000\n3000\n')) as run:
            self.assertFalse(health.gpu_capacity(4096)[0])
        self.assertIn('--query-gpu=memory.free', run.call_args.args[0])
        self.assertEqual(run.call_args.kwargs['timeout'], 3)

    def test_bad_or_unknown_capacity_fails_closed(self):
        for value in (b'N/A', b'-1', b'', b'9000\nPRIVATE', b'x' * 5000):
            with patch.object(health.shutil, 'which', return_value='/fixture/nvidia-smi'), \
                    patch.object(health.subprocess, 'run', return_value=Mock(returncode=0, stdout=value)):
                self.assertFalse(health.gpu_capacity(1)[0])

    def test_preflight_reuses_offline_doctor_without_docker_requirement(self):
        text = (ROOT / 'scripts/preflight.sh').read_text()
        self.assertIn('platform_health.py" doctor "$@"', text)
        self.assertNotIn('docker', text)
        self.assertNotIn('uname', text)

    def test_sandbox_is_suspended_networkless_and_unprivileged(self):
        folder = ROOT / 'k8s/optional/tool-sandbox'
        job = (folder / 'job.yaml').read_text()
        for value in ('suspend: true', 'backoffLimit: 0', 'activeDeadlineSeconds: 60',
                      'runtimeClassName: runsc', 'automountServiceAccountToken: false',
                      'readOnlyRootFilesystem: true', 'capabilities: {drop: [ALL]}'):
            self.assertIn(value, job)
        for value in ('hostPath:', 'secretKeyRef:', 'privileged: true', 'hostNetwork: true'):
            self.assertNotIn(value, job)
        policy = (folder / 'isolation.yaml').read_text()
        self.assertIn('policyTypes: [Ingress, Egress]', policy)
        self.assertNotIn('egress:', policy)
        self.assertIn("persistentvolumeclaims: '0'", policy)


if __name__ == '__main__':
    unittest.main()
