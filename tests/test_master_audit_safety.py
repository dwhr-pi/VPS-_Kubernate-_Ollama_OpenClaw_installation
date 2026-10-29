"""Offline fixtures only: no user workspace, services, models or network."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import sys
import subprocess
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts/security'))
import credentials_backup as credentials
sys.path.insert(0, str(ROOT / 'scripts/quality'))
import platform_inventory
from repository_audit import Audit
from audit_reports import write_report


def module(name, relative):
    spec = importlib.util.spec_from_file_location(name, ROOT / relative)
    item = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(item)
    return item


dispatch = module('tool_dispatch_audit_test', 'scripts/lib/tool_dispatch.py')
rag = module('rag_evaluate_audit_test', 'scripts/benchmarks/rag_evaluate.py')


class MasterAuditSafety(unittest.TestCase):
    def fixture(self, directory, script='scripts/tools/demo_uninstall.sh'):
        root = Path(directory)
        (root / 'config').mkdir()
        (root / 'scripts/tools').mkdir(parents=True)
        (root / 'scripts/tools/demo_uninstall.sh').write_text('# fixture, never executed\n')
        (root / 'config/tools.yml').write_text(json.dumps({'tools': [
            {'id': 'demo', 'name': 'Demo Tool', 'uninstall_script': script}]}))
        return root

    def test_dispatch_resolves_only_registered_paths(self):
        with tempfile.TemporaryDirectory() as directory:
            root = self.fixture(directory)
            expected = root / 'scripts/tools/demo_uninstall.sh'
            self.assertEqual(dispatch.resolve(root, 'DEMO', 'uninstall'), expected)
            self.assertEqual(dispatch.resolve(root, 'Demo Tool', 'uninstall'), expected)
            for bad in ('../demo', '../../outside', '/etc/passwd', 'C:\\data', 'unknown', 'demo\n'):
                with self.assertRaises(ValueError):
                    dispatch.resolve(root, bad, 'uninstall')
            with self.assertRaises(ValueError):
                dispatch.resolve(root, 'demo', 'update')

    def test_registry_cannot_redirect_dispatch_outside_tools(self):
        with tempfile.TemporaryDirectory() as directory:
            root = self.fixture(directory, 'scripts/tools/../../payload_uninstall.sh')
            with self.assertRaises(ValueError):
                dispatch.resolve(root, 'demo', 'uninstall')

    def test_symlink_dispatch_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = self.fixture(directory)
            target = root / 'scripts/tools/demo_uninstall.sh'
            target.unlink()
            outside = root / 'payload_uninstall.sh'
            outside.write_text('# never execute\n')
            try:
                target.symlink_to(outside)
            except OSError:
                self.skipTest('Symlink privileges unavailable on this host')
            with self.assertRaises(ValueError):
                dispatch.resolve(root, 'demo', 'uninstall')

    def test_workspace_menu_never_recursively_purges_workspace(self):
        text = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        start = text.index('show_user_workspace_menu()')
        end = text.index('show_options_menu()', start)
        menu = text[start:end]
        self.assertNotIn('rm -rf', menu)
        self.assertIn('SEC-001', menu)

    def test_large_export_can_be_read_for_recovery(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'sample.env').write_bytes(b'x' * credentials.LIMIT)
            settings = {'version': 1, 'paths': ['sample.env'], 'sender': '', 'recipient': '', 'hint': ''}
            payload = credentials.pack(root, settings)
            self.assertGreater(len(payload), credentials.LIMIT)
            source = root / 'synthetic.tar.age'
            source.write_bytes(payload)  # Synthetic transport; no actual age invocation.
            with self.assertRaises(credentials.VaultError):
                credentials.read_bounded(source)
            self.assertEqual(credentials.read_bounded(source, credentials.CIPHERTEXT_LIMIT), payload)
            with mock.patch.object(credentials, 'Workspace'), \
                 mock.patch.object(credentials, 'age_run', return_value=payload) as age, \
                 contextlib.redirect_stdout(io.StringIO()):
                credentials.recover(source, root / 'new-recovery', apply=False)
                age.assert_called_once_with(['--decrypt'], payload)
            self.assertFalse((root / 'new-recovery').exists())

    def test_build_caches_are_excluded_from_audit(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / '.codex-build').mkdir()
            (root / '.codex-build/broken.py').write_text('not python @@@')
            (root / 'good.py').write_text('answer = 42\n')
            audit = Audit(root)
            audit.code()
            self.assertEqual(audit.result()['errors'], 0)
            self.assertEqual(audit.counts['python_files'], 1)

    def test_report_replacement_preserves_hardlink_peer(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            write_report(root, 'inventory.json', 'old report\n')
            peer = root / 'peer.json'
            try:
                os.link(root / 'docs/audit/inventory.json', peer)
            except OSError:
                self.skipTest('Hardlinks unavailable on this filesystem')
            write_report(root, 'inventory.json', 'new report\n')
            self.assertEqual(peer.read_text(), 'old report\n')
            self.assertEqual((root / 'docs/audit/inventory.json').read_text(), 'new report\n')
            self.assertFalse(list((root / 'docs/audit').glob('.audit-stage-*')))
            with self.assertRaises(ValueError):
                write_report(root, '../not-allowed', 'rejected')

    def test_no_inventory_row_is_promoted_to_production(self):
        rows = platform_inventory.inventory()['rows']
        self.assertTrue(rows)
        for row in rows:
            self.assertFalse(row['verification']['implemented'])
            self.assertFalse(row['verification']['staging_verified'])
            self.assertFalse(row['verification']['production_verified'])
            self.assertEqual(row['metadata_verification'], 'registry-declarations-only')

    def test_rag_scores_supplied_rankings_and_rejects_acl_hits(self):
        dataset = {'queries': [{'id': 'q', 'relevant': ['a'], 'forbidden': ['b']}]}
        result = rag.evaluate(dataset, {'q': ['a']}, k=1)
        self.assertEqual(result['recall_at_k'], 1)
        self.assertEqual(result['mrr_at_k'], 1)
        self.assertEqual(result['forbidden_hits'], 0)
        result = rag.evaluate(dataset, {'q': ['b', 'a']}, k=2)
        self.assertEqual(result['forbidden_hits'], 1)
        self.assertEqual(result['mrr_at_k'], 0.5)
        for ranking in ({}, {'q': ['a', 'a']}):
            with self.assertRaises(ValueError):
                rag.evaluate(dataset, ranking)
        with self.assertRaises(ValueError):
            rag.evaluate({'queries': [{'id': 'q', 'relevant': 'not-a-list'}]}, {'q': ['a']})

    def test_compose_config_uses_runtime_environment_lookup(self):
        config = (ROOT / 'stacks/llmops-platform/litellm-config.yaml').read_text()
        self.assertNotIn('${', config)
        self.assertIn('master_key: os.environ/LITELLM_MASTER_KEY', config)
        self.assertIn('fallbacks: []', config)

    def test_monitoring_helm_retains_namespace_and_storage(self):
        for name in ('namespace.yaml', 'workloads.yaml'):
            self.assertIn('helm.sh/resource-policy: keep',
                          (ROOT / 'charts/monitoring-lite/templates' / name).read_text())

    @unittest.skipUnless(os.name == 'posix', 'Linux Bash fixture; no WSL execution')
    def test_secret_fallback_rejects_matches_and_scan_errors_without_values(self):
        path = ROOT / 'scripts/secret_scan.sh'
        for code, expected in ((0, 1), (1, 0), (2, 2), (141, 2)):
            harness = '''command() {
  if [[ "$2" == gitleaks || "$2" == trufflehog ]]; then return 1; fi
  builtin command "$@"
}
grep() { printf 'SECRET_SENTINEL'; return "$SCAN_STATUS"; }
export -f command grep
bash "$SCAN_SCRIPT"
'''
            result = subprocess.run(['bash', '-c', harness], text=True, capture_output=True,
                                    timeout=20, env={**os.environ, 'SCAN_STATUS': str(code), 'SCAN_SCRIPT': str(path)})
            self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
            self.assertNotIn('SECRET_SENTINEL', result.stdout + result.stderr)


if __name__ == '__main__':
    unittest.main()
