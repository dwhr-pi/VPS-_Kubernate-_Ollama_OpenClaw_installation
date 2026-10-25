"""Offline VPS delivery tests; no cluster, runtime, swap or Secret access."""
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('hostcheck', ROOT / 'scripts/quality/vps_host_preflight.py')
hostcheck = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(hostcheck)


class HostChecks(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.mem = self.base / 'meminfo'
        self.mem.write_text('MemTotal: 8388608 kB\nMemAvailable: 4194304 kB\n')
        self.swaps = self.base / 'swaps'
        self.swaps.write_text('Filename Type Size Used Priority\n')

    def check(self, free=80 * 1024**3):
        with patch.object(hostcheck.shutil, 'disk_usage', return_value=Mock(free=free)), \
             patch.dict(os.environ, {'WSL_DISTRO_NAME': ''}):
            hostcheck.check(self.base, self.mem, self.swaps)

    def test_success_is_read_only(self):
        before = sorted(p.name for p in self.base.iterdir())
        self.check()
        self.assertEqual(sorted(p.name for p in self.base.iterdir()), before)

    def test_low_disk_fails(self):
        with self.assertRaisesRegex(ValueError, '64 GiB'):
            self.check(free=10 * 1024**3)

    def test_low_total_or_available_ram_fails(self):
        for total, available in ((2 * 1024**2, 2 * 1024**2), (8 * 1024**2, 1024**2)):
            self.mem.write_text(f'MemTotal: {total} kB\nMemAvailable: {available} kB\n')
            with self.assertRaisesRegex(ValueError, 'RAM'):
                self.check()

    def test_active_swap_fails_without_changes(self):
        self.swaps.write_text('Filename Type Size Used Priority\n/swapfile file 1 0 -2\n')
        with self.assertRaisesRegex(ValueError, 'Swap'):
            self.check()
        self.assertIn('/swapfile', self.swaps.read_text())

    def test_relative_data_path_rejected(self):
        with self.assertRaises(ValueError):
            hostcheck.check(Path('relative'), self.mem, self.swaps)


class DeliveryFiles(unittest.TestCase):
    def test_overlay_reuses_existing_base_and_claim(self):
        folder = ROOT / 'k8s/overlays/vps-cpu'
        self.assertIn('../../base', (folder / 'kustomization.yml').read_text())
        pvc = (folder / 'pvc.yaml').read_text()
        self.assertIn('whenDeleted: Retain', pvc)
        self.assertIn('whenScaled: Retain', pvc)
        self.assertNotIn('kind: PersistentVolumeClaim', pvc)
        self.assertIn('storage: 50Gi', (ROOT / 'k8s/base/ollama.yml').read_text())

    def test_gateway_uses_secret_reference_and_no_fallback(self):
        config = (ROOT / 'k8s/overlays/vps-cpu/gateway.yaml').read_text()
        self.assertIn('os.environ/LITELLM_MASTER_KEY', config)
        self.assertIn('num_retries: 0', config)
        self.assertNotIn('fallbacks:', config)
        self.assertNotIn('sk-', config)

    def test_plan_and_apply_boundaries(self):
        script = (ROOT / 'scripts/operations/deploy_vps_baseline.sh').read_text()
        self.assertIn('set -euo pipefail', script)
        self.assertIn('umask 077', script)
        self.assertIn('mode=check', script)
        self.assertIn('kubeconform -strict', script)
        self.assertIn('--dry-run=server', script)
        self.assertIn('--context und --confirm-apply', script)
        self.assertNotIn('--force-conflicts', script)
        self.assertNotIn('swapoff ', script)
        self.assertNotIn('sudo ', script)

    def test_dashboard_has_latency_and_unique_panels(self):
        dashboard = json.loads((ROOT / 'monitoring/grafana/dashboards/llmops.json').read_text())
        ids = [p['id'] for p in dashboard['panels']]
        self.assertEqual(len(ids), len(set(ids)))
        self.assertTrue(any('litellm_request_total_latency_metric_bucket' in t['expr']
                            for p in dashboard['panels'] for t in p['targets']))


@unittest.skipUnless(os.name == 'posix', 'Bash process fixtures run in Linux CI')
class ScriptBehavior(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.bin = self.base / 'bin'
        self.bin.mkdir()
        self.overlay = self.base / 'overlay'
        self.overlay.mkdir()
        self.log = self.base / 'calls'
        self.manifest = self.base / 'fixture.yaml'
        self.manifest.write_text('apiVersion: apps/v1\nkind: Deployment\nmetadata:\n  name: litellm\n'
                                 'spec:\n  template:\n    spec:\n      containers:\n        - image: test@sha256:' + 'a' * 64 + '\n')
        for tool, body in {
            'python3': 'exit 0',
            'systemctl': 'exit 0',
            'kubeconform': 'exit 0',
            'kubectl': '''case "$1" in
  kustomize) cat "$FIXTURE_MANIFEST" ;;
  --context)
    if [ "$4" = get ] && [ "$5" = secret ]; then printf present; fi
    if [ "$4" = apply ] && [ "${FAIL_APPLY:-0}" = 1 ]; then exit 23; fi
    ;;
  *) exit 24 ;;
esac''',
        }.items():
            file = self.bin / tool
            file.write_text('#!/bin/sh\nprintf "%s\\n" "' + tool + ' $*" >> "$FIXTURE_LOG"\n' + body + '\n')
            file.chmod(0o700)
        self.env = dict(os.environ, PATH=str(self.bin) + os.pathsep + os.environ['PATH'],
                        FIXTURE_LOG=str(self.log), FIXTURE_MANIFEST=str(self.manifest))

    def run_script(self, *args):
        return subprocess.run(['bash', str(ROOT / 'scripts/operations/deploy_vps_baseline.sh'), *args],
                              capture_output=True, text=True, timeout=10, env=self.env)

    def test_help_does_not_touch_runtime(self):
        result = subprocess.run(['bash', str(ROOT / 'scripts/operations/deploy_vps_baseline.sh'), '--help'],
                                capture_output=True, text=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_unknown_option_fails_before_hostcheck(self):
        result = subprocess.run(['bash', str(ROOT / 'scripts/operations/deploy_vps_baseline.sh'), '--bad'],
                                capture_output=True, text=True, timeout=10)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Unbekannte Option', result.stderr)

    def test_apply_requires_explicit_context_and_confirmation_before_checks(self):
        result = self.run_script('--apply')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.log.exists())

    def test_plan_has_no_remote_kubectl_commands(self):
        result = self.run_script('--plan', '--overlay', str(self.overlay))
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = self.log.read_text()
        self.assertIn('kubectl kustomize', calls)
        self.assertNotIn('kubectl --context', calls)

    def test_secret_manifest_rejected_before_apply(self):
        self.manifest.write_text('apiVersion: v1\nkind: Secret\nmetadata:\n  name: fixture\n')
        result = self.run_script('--apply', '--overlay', str(self.overlay), '--context', 'fixture', '--confirm-apply')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Secrets separat', result.stderr)
        self.assertNotIn('kubectl --context', self.log.read_text())

    def test_server_dry_run_precedes_apply_and_rollout(self):
        result = self.run_script('--apply', '--overlay', str(self.overlay), '--context', 'fixture', '--confirm-apply')
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = self.log.read_text().splitlines()
        dry = next(i for i, line in enumerate(calls) if '--dry-run=server' in line)
        apply = next(i for i, line in enumerate(calls) if ' apply ' in line and '--dry-run' not in line)
        rollout = next(i for i, line in enumerate(calls) if 'rollout status' in line)
        self.assertLess(dry, apply)
        self.assertLess(apply, rollout)

    def test_failed_server_validation_never_applies_or_waits_for_rollout(self):
        self.env['FAIL_APPLY'] = '1'
        result = self.run_script('--apply', '--overlay', str(self.overlay), '--context', 'fixture', '--confirm-apply')
        self.assertEqual(result.returncode, 23)
        calls = self.log.read_text()
        self.assertIn('--dry-run=server', calls)
        self.assertNotIn('rollout status', calls)
        self.assertEqual(sum(' apply ' in line for line in calls.splitlines()), 1)


if __name__ == '__main__':
    unittest.main()
