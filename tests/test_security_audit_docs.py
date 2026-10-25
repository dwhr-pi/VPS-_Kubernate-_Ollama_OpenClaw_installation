"""Read-only documentation contracts, not Kubernetes policy enforcement tests."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
FILES = [ROOT / name for name in (
    'docs/security/SECURITY_ARCHITECTURE_AUDIT_2026-10-25.md',
    'docs/security/KUBERNETES_ADMIN_AUDIT.md',
    'docs/tools/comet-and-browser-research.md',
    'docs/resource-planner/README.md')]


class SecurityAuditDocs(unittest.TestCase):
    def test_local_links_exist_and_line_references_are_in_range(self):
        for file in FILES:
            text = file.read_text(encoding='utf-8')
            for link in re.findall(r'\]\(([^)]+)\)', text):
                if link.startswith(('https://', 'http://', '#')):
                    continue
                relative, _, anchor = link.partition('#')
                target = file.parent / relative
                self.assertTrue(target.is_file(), (file.name, link))
                if re.fullmatch(r'L\d+', anchor):
                    self.assertLessEqual(int(anchor[1:]), len(target.read_text(encoding='utf-8').splitlines()))

    def test_fences_are_closed_and_audit_does_not_claim_live_access(self):
        for file in FILES:
            text = file.read_text(encoding='utf-8')
            self.assertEqual(len(re.findall(r'^```', text, re.M)) % 2, 0, file.name)
        audit = FILES[0].read_text(encoding='utf-8')
        self.assertIn('152cce67cb0a76b189aa548d31f32696de8d78be', audit)
        self.assertIn('kein\nvollstaendiger Penetrationstest', audit)
        self.assertIn('```mermaid', audit)
        self.assertEqual(len(re.findall(r'^\| S\d\d \|', audit, re.M)), 16)

    def test_observer_example_has_no_privileged_resource_or_verb(self):
        text = (ROOT / 'docs/security/examples/observer-rbac.yaml').read_text()
        for value in ['cluster-admin', 'ClusterRoleBinding', 'secrets', 'pods/exec', '*', 'impersonate']:
            self.assertNotIn(value, text)
        self.assertIn('verbs: [get, list, watch]', text)
        self.assertIn('kind: Group', text)

    def test_network_examples_have_both_gateway_backend_directions(self):
        text = (ROOT / 'docs/security/examples/network-policy.yaml').read_text()
        self.assertIn('policyTypes: [Ingress, Egress]', text)
        self.assertIn('name: review-gateway-to-ollama', text)
        self.assertIn('name: review-ollama-from-gateway', text)
        self.assertIn("matchLabels: {llmops-client: 'true'}", text)
        self.assertIn("matchLabels: {llmops-gateway-client: 'true'}", text)

    def test_examples_are_not_added_to_active_kustomization(self):
        for file in (ROOT / 'k8s').rglob('kustomization.y*ml'):
            self.assertNotIn('security/examples', file.read_text())


if __name__ == '__main__':
    unittest.main()
