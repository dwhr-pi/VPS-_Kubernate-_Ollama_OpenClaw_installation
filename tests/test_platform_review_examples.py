"""Offline proposal checks; live HTTP calls are replaced by a local fixture."""
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import tempfile
import unittest
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[1]
EXAMPLES = ROOT / 'docs/proposals/platform-review-2026-10-26'
REPORT = ROOT / 'docs/reviews/2026-10-26-platform-patch-plan.md'
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')


class ReviewExamplesTests(unittest.TestCase):
    def test_review_links_and_tables_are_valid(self):
        files = [REPORT, *REPORT.parent.glob('2026-10-26-*-matrix.md')]
        for path in files:
            text = path.read_text(encoding='utf-8')
            self.assertEqual(len(re.findall(r'(?m)^```', text)) % 2, 0, str(path))
            columns = None
            for line in text.splitlines():
                if line.startswith('|'):
                    count = len(line.strip('|').split('|'))
                    if columns is not None:
                        self.assertEqual(count, columns, str(path))
                    columns = count
                else:
                    columns = None
            for link in re.findall(r'\]\(([^)]+)\)', text):
                parts = urlsplit(link)
                if not parts.scheme and parts.path:
                    self.assertTrue((path.parent / parts.path).is_file(), (path, link))

    def test_production_gate_is_inactive_and_fails_closed(self):
        workflow = EXAMPLES / 'ci-gate.yml.example'
        text = workflow.read_text()
        self.assertNotEqual(workflow.parent, ROOT / '.github/workflows')
        self.assertIn('environment: production', text)
        self.assertIn('needs: offline', text)
        self.assertIn('workflow_dispatch', text)
        self.assertIn('exit 1', text)
        self.assertNotIn('pull_request_target', text)
        self.assertNotIn('continue-on-error', text)
        self.assertNotIn('kubectl apply', text)
        for action in re.findall(r'uses: (\S+)', text):
            self.assertRegex(action, r'@[a-f0-9]{40}$')

    def test_baseline_has_least_privilege_and_no_secret_payload(self):
        baseline = (EXAMPLES / 'security-baseline.yaml.example').read_text()
        patch = (EXAMPLES / 'workload-security.patch.yaml.example').read_text()
        for term in ('enforce: restricted', 'policyTypes: [Ingress, Egress]',
                     'automountServiceAccountToken: false', 'kind: Role', 'kind: ResourceQuota'):
            self.assertIn(term, baseline)
        self.assertNotIn('ClusterRole', baseline)
        self.assertNotIn('kind: Secret', baseline)
        self.assertNotIn('pods/exec', baseline)
        for term in ('runAsNonRoot: true', 'readOnlyRootFilesystem: true', 'drop: [ALL]',
                     'ephemeral-storage:', 'RuntimeDefault'):
            self.assertIn(term, patch)

    @unittest.skipUnless(BASH, 'Native Bash unavailable')
    def test_health_plan_never_invokes_curl(self):
        result = subprocess.run([BASH, str(EXAMPLES / 'healthchecks.sh.example')],
                                input='', capture_output=True, text=True, timeout=20)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.count('GET http://127.0.0.1:'), 5)
        self.assertIn('Plan only', result.stdout)

    @unittest.skipUnless(BASH, 'Native Bash unavailable')
    def test_mocked_local_health_rejects_redirects_without_external_requests(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            log = folder / 'calls.txt'
            # A shell function takes precedence over every Windows/Git-Bash curl binary.
            command = ('curl() { printf "%s\\n" "$*" >> "$MOCK_PROBE_LOG"; printf "%s" "$MOCK_HTTP_CODE"; }; '
                       'readonly -f curl; source ' + shlex.quote((EXAMPLES / 'healthchecks.sh.example').as_posix()) + ' --local-live')
            for code, expected in (('200', 0), ('302', 1)):
                env = dict(os.environ, MOCK_PROBE_LOG=log.as_posix(), MOCK_HTTP_CODE=code)
                result = subprocess.run([BASH, '--noprofile', '--norc', '-c', command], env=env,
                                        capture_output=True, text=True, timeout=20)
                self.assertEqual(result.returncode, expected, result.stderr)
            calls = log.read_text().splitlines()
            self.assertEqual(len(calls), 10)
            for call in calls:
                self.assertIn('http://127.0.0.1:', call)
                self.assertIn('--noproxy *', call)
                self.assertIn('--max-time 5', call)
                self.assertNotIn('Authorization', call)
                self.assertNotIn('/api/generate', call)


if __name__ == '__main__':
    unittest.main()
