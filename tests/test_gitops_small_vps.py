"""Offline fixtures: no installer, cluster, provider or inference requests."""
import importlib.util
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('gitops_artifacts', ROOT / 'scripts/lib/gitops_artifacts.py')
artifacts = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(artifacts)
BASH = 'C:/Program Files/Git/bin/bash.exe' if sys.platform == 'win32' else shutil.which('bash')


def fixture():
    # Synthetic hashes/versions are only validation fixtures, never downloaded.
    return {'schema_version': 1, 'argocd_images': {'registry.invalid/argo:test': 'sha256:' + 'a' * 64},
            'platforms': {'linux-amd64': {
                'k3s': {'url': 'https://github.com/k3s-io/k3s/releases/download/v1.35.0%2Bk3s1/k3s', 'sha256': '1' * 64},
                'k3s_installer': {'url': 'https://raw.githubusercontent.com/k3s-io/k3s/' + '2' * 40 + '/install.sh', 'sha256': '2' * 64},
                'cloudflared': {'url': 'https://github.com/cloudflare/cloudflared/releases/download/2026.10.0/cloudflared-linux-amd64', 'sha256': '3' * 64},
                'argocd': {'url': 'https://raw.githubusercontent.com/argoproj/argo-cd/' + '4' * 40 + '/manifests/core-install.yaml', 'sha256': '4' * 64}}}}


class ArtifactLockTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.path = Path(self.temp.name) / 'lock.json'

    def write(self, data):
        self.path.write_text(json.dumps(data), encoding='utf-8')
        return self.path

    def test_valid_pinned_sources_and_architecture(self):
        assets = artifacts.validate(self.write(fixture()), 'linux-amd64')
        self.assertEqual(set(assets), set(artifacts.PATTERNS))

    def test_placeholders_are_not_accepted_as_pins(self):
        with self.assertRaises(ValueError):
            artifacts.validate(ROOT / 'config/gitops-bootstrap.artifacts.example.json', 'linux-amd64')

    def test_invalid_source_digest_and_architecture_fail_closed(self):
        for field, value in [('url', 'http://github.com/k3s-io/k3s/releases/download/v1/k3s'),
                             ('url', 'https://evil.invalid/k3s'), ('sha256', '0' * 64),
                             ('sha256', 'not-a-hash'), ('url', 'https://github.com/k3s-io/k3s/releases/download/v1/k3s\n')]:
            data = fixture()
            data['platforms']['linux-amd64']['k3s'][field] = value
            with self.subTest(value=value), self.assertRaises(ValueError):
                artifacts.validate(self.write(data), 'linux-amd64')
        with self.assertRaises(KeyError):
            artifacts.validate(self.write(fixture()), 'linux-arm64')

    def test_old_cloudflared_and_mutable_script_ref_are_rejected(self):
        for name, url in [('cloudflared', 'https://github.com/cloudflare/cloudflared/releases/download/2025.3.0/cloudflared-linux-amd64'),
                          ('k3s_installer', 'https://raw.githubusercontent.com/k3s-io/k3s/main/install.sh')]:
            data = fixture()
            data['platforms']['linux-amd64'][name]['url'] = url
            with self.subTest(name=name), self.assertRaises(ValueError):
                artifacts.validate(self.write(data), 'linux-amd64')

    def test_duplicate_json_and_unknown_fields_are_rejected(self):
        self.path.write_text('{"schema_version":1,"schema_version":2}', encoding='utf-8')
        with self.assertRaises(ValueError):
            artifacts.validate(self.path, 'linux-amd64')
        data = fixture()
        data['script'] = 'arbitrary command'
        with self.assertRaises(ValueError):
            artifacts.validate(self.write(data), 'linux-amd64')

    def test_private_address_is_not_public_loopback_or_command(self):
        self.assertEqual(artifacts.private_address('10.7.0.2'), '10.7.0.2')
        for value in ('0.0.0.0', '127.0.0.1', '8.8.8.8', '169.254.0.1', '::1', '10.7.0.2;id'):
            with self.subTest(value=value), self.assertRaises(ValueError):
                artifacts.private_address(value)

    def test_argo_image_pinning_is_complete_and_deterministic(self):
        text = 'spec:\n  image: "registry.invalid/argo:test"\n  init:\n    image: registry.invalid/argo:test # fixture\n'
        pins = fixture()['argocd_images']
        result = artifacts.pin_manifest(text, pins)
        self.assertEqual(result.count('@sha256:' + 'a' * 64), 2)
        for bad in ({}, dict(pins, **{'extra.invalid/image:test': 'sha256:' + 'b' * 64})):
            with self.assertRaises(ValueError):
                artifacts.pin_manifest(text, bad)
        with self.assertRaises(ValueError):
            artifacts.pin_manifest('image: >\n  registry.invalid/argo:test\n', pins)

    def test_plan_cli_only_prints_metadata_and_keeps_fixture_unchanged(self):
        path = self.write(fixture())
        before = path.read_bytes()
        result = subprocess.run([sys.executable, '-I', '-B', str(ROOT / 'scripts/lib/gitops_artifacts.py'),
                                 str(path), '--arch', 'linux-amd64', '--private-address', '10.7.0.2'],
                                capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stderr)
        plan = json.loads(result.stdout)
        self.assertFalse(plan['downloads'])
        self.assertFalse(plan['host_changes'])
        self.assertEqual(path.read_bytes(), before)
        self.assertEqual(list(Path(self.temp.name).iterdir()), [path])


class GitopsContractTests(unittest.TestCase):
    def interactive_input_fixture(self, text):
        wrapper = (ROOT / 'scripts/tools/gitops_bootstrap_install.sh').read_text(encoding='utf-8')
        helper = re.search(r'^gitops_read_plan_value\(\) \{\n.*?^\}', wrapper, re.M | re.S).group()
        start = wrapper.index("  if ! gitops_read_plan_value 'Absoluter Pfad")
        end = wrapper.index('  exec 3<&-', start)
        command = ('set -euo pipefail\nexec 3<&0\n' + helper + '\n' + wrapper[start:end]
                   + '\nprintf "fixture-plan:%s|%s\\n" "$artifacts" "$address"\n')
        # Exercise real input/branch logic with a pipe, not /dev/tty or the planner.
        return subprocess.run([BASH, '--noprofile', '--norc', '-c', command], input=text,
                              cwd=ROOT, capture_output=True, text=True, timeout=30)

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash required')
    def test_empty_whitespace_crlf_and_eof_defer_before_address_prompt(self):
        for text in ('\n', '\r\n', ' \t\r\n', ''):
            with self.subTest(text=repr(text)):
                result = self.interactive_input_fixture(text)
                self.assertEqual(result.returncode, 3, result.stderr)
                self.assertIn('Planung verschoben', result.stdout)
                self.assertNotIn('Private IPv4-Adresse', result.stdout)
                self.assertNotIn('fixture-plan:', result.stdout)

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash required')
    def test_nonempty_invalid_path_fails_before_address_prompt(self):
        for path in ('relative.json', '/nonexistent-fixture/lock.json'):
            with self.subTest(path=path):
                result = self.interactive_input_fixture(path + '\n10.7.0.2\n')
                self.assertEqual(result.returncode, 1, result.stderr)
                self.assertIn('vorhandene absolute JSON', result.stderr)
                self.assertNotIn('Private IPv4-Adresse', result.stdout)
                self.assertNotIn('fixture-plan:', result.stdout)

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash required')
    def test_normalized_path_preserves_inner_spaces_and_empty_address_defers(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / 'fixture lock.json'
            path.write_text('{}')
            bash_path = path.as_posix()
            if sys.platform == 'win32':
                bash_path = '/' + bash_path[0].lower() + bash_path[2:]
            for address in ('\n', ' \t\r\n', ''):
                result = self.interactive_input_fixture('  ' + bash_path + '  \r\n' + address)
                self.assertEqual(result.returncode, 3, result.stderr)
                self.assertIn('Private IPv4-Adresse', result.stdout)
                self.assertIn('Planung verschoben', result.stdout)
                self.assertNotIn('fixture-plan:', result.stdout)
            result = self.interactive_input_fixture('  ' + bash_path + '\r\n 10.7.0.2 \r\n')
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('fixture-plan:' + bash_path + '|10.7.0.2', result.stdout)
            self.assertEqual(path.read_text(), '{}')

    def test_menu_wrapper_is_plan_only_and_can_defer_without_success_marker(self):
        wrapper = (ROOT / 'scripts/tools/gitops_bootstrap_install.sh').read_text(encoding='utf-8')
        self.assertIn('--interactive-plan', wrapper)
        self.assertIn('exit 3', wrapper)
        self.assertIn('--plan --artifacts "$artifacts" --private-address "$address"', wrapper)
        self.assertNotRegex(wrapper, re.compile(r'^\s*(?:sudo\s+)?bash[^\n]*--apply', re.M))
        self.assertIn('12 GiB Windows-Host-Reserve', wrapper)

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Bash erforderlich')
    def test_menu_planning_logs_planned_skipped_or_failed_without_installing(self):
        setup = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        functions = '\n'.join(re.search(r'^' + name + r'\(\) \{\n.*?^\}', setup, re.M | re.S).group()
                              for name in ('plan_gitops_bootstrap_from_setup', 'install_tool'))
        for code, status in ((0, 'planned'), (3, 'skipped'), (1, 'failed')):
            # Nur extrahierte Funktionen und Mocks; kein komplettes Setup starten.
            command = '''set -euo pipefail
INSTALL_DIR=/fixture
begin_operation_measurement() { printf 'begin:%s\n' "$1"; }
capture_operation_output() { printf 'wrapper:%s\n' "$3"; return MOCK_CODE; }
end_operation_measurement() { printf 'end:%s\n' "$1"; }
handle_manual_tool_post_action() { printf 'post:%s\n' "$3"; }
preflight_tool_install_storage() { exit 99; }
run_tool_script() { exit 99; }
append_unique_line() { exit 99; }
''' .replace('MOCK_CODE', str(code)) + functions + '''
rc=0
install_tool GitOps_Bootstrap || rc=$?
printf 'rc:%s\n' "$rc"
'''
            result = subprocess.run([BASH, '--noprofile', '--norc', '-s'], input=command,
                                    cwd=ROOT, capture_output=True, text=True, encoding='utf-8', timeout=30)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout.splitlines(), [
                'begin:tool_install_GitOps_Bootstrap', 'wrapper:--interactive-plan',
                'end:' + status, 'post:' + status, 'rc:' + ('1' if code == 1 else '0')])

    def test_bootstrap_defaults_to_offline_and_requires_explicit_apply(self):
        text = (ROOT / 'scripts/bootstrap_gitops.sh').read_text(encoding='utf-8')
        self.assertIn('mode=plan', text)
        self.assertLess(text.index('[[ "$mode" == apply ]]'), text.index('systemctl is-active'))
        self.assertLess(text.index('firewall_confirmed'), text.index('curl -q'))
        self.assertIn('--confirm-private-firewall', text)
        self.assertIn('sha256sum --status -c -', text)
        self.assertNotRegex(text, r'curl[^\n]*\|\s*(?:sudo\s+)?(?:bash|sh)')
        self.assertNotIn('--disable traefik', text)
        self.assertIn('--disable servicelb', text)
        self.assertIn('--pin-argocd', text)
        self.assertNotIn('force-conflicts', text)
        self.assertNotIn('apply -k', text)
        self.assertIn('Kein App-of-Apps-Apply', text)

    def test_qdrant_is_private_persistent_bounded_and_uses_secret_reference(self):
        text = (ROOT / 'k8s/gitops/memory/qdrant.yaml').read_text(encoding='utf-8')
        for expected in ('memory: 512Mi', 'cpu: 500m', 'storageClassName: local-path',
                         'secretKeyRef: {name: qdrant-auth, key: api-key}', 'type: ClusterIP',
                         'runAsNonRoot: true', 'readOnlyRootFilesystem: true', 'Prune=false,Delete=false'):
            self.assertIn(expected, text)
        self.assertNotIn('subPath: storage', text)
        self.assertNotIn('hostPort:', text)
        self.assertIn('on_disk_payload: true', text)

    def test_agent_pod_and_namespace_budgets_are_separate(self):
        text = (ROOT / 'k8s/gitops/agents/budgets.yaml').read_text(encoding='utf-8')
        self.assertIn('type: Container', text)
        self.assertIn('type: Pod', text)
        self.assertIn('memory: 1Gi', text)
        self.assertIn('limits.memory: 2Gi', text)
        self.assertIn("services.nodeports: '0'", text)
        agents = (ROOT / 'k8s/gitops/agents/network-policy.yaml').read_text(encoding='utf-8')
        memory = (ROOT / 'k8s/gitops/memory/network-policy.yaml').read_text(encoding='utf-8')
        self.assertIn('agents-to-qdrant', agents)
        self.assertNotIn('agents-to-qdrant', memory)

    def test_secret_helper_uses_stdin_certificate_pin_and_no_plaintext_file(self):
        text = (ROOT / 'scripts/seal_openclaw_secret.sh').read_text(encoding='utf-8')
        for expected in ('read -r -s', '--scope strict', 'kubeseal --cert', 'sha256sum', 'unset secret'):
            self.assertIn(expected, text)
        self.assertNotIn('--from-literal', text)
        self.assertNotIn('kubectl apply', text)
        self.assertNotIn('echo "$secret"', text)
        self.assertIn('LoadCredential=tunnel-token:', (ROOT / 'systemd/openclaw-cloudflared.service').read_text())

    def test_monitoring_does_not_invent_ollama_metrics_and_enforces_digests(self):
        text = (ROOT / 'charts/monitoring-lite/templates/config.yaml').read_text(encoding='utf-8')
        self.assertIn('job_name: ollama-exporter', text)
        self.assertNotIn('ollama:11434', text)
        workload = (ROOT / 'charts/monitoring-lite/templates/workloads.yaml').read_text(encoding='utf-8')
        self.assertIn('regexMatch', workload)
        self.assertIn('sha256:[a-f0-9]{64}', workload)
        self.assertIn('secretKeyRef:', workload)
        self.assertNotIn('LoadBalancer', workload)
        self.assertIn('retentionTime: 6h', (ROOT / 'charts/monitoring-lite/values.yaml').read_text())
        dashboard = json.loads(next(line.strip() for line in text.splitlines() if line.strip().startswith('{"uid"')))
        self.assertEqual(len(dashboard['panels']), 4)
        schema = json.loads((ROOT / 'charts/monitoring-lite/values.schema.json').read_text())
        self.assertFalse(schema['additionalProperties'])

    def test_app_of_apps_is_not_automatic_or_pruning(self):
        text = (ROOT / 'k8s/gitops/apps/applications.yaml').read_text(encoding='utf-8')
        self.assertEqual(text.count('kind: Application'), 3)
        self.assertNotIn('automated:', text)
        self.assertNotIn('prune: true', text)
        self.assertIn('REPLACE_WITH_FULL_WORKLOAD_COMMIT', text)
        root = (ROOT / 'k8s/gitops/platform/root-application.yaml.example').read_text()
        self.assertIn('REPLACE_WITH_FULL_CONFIG_COMMIT', root)

    def test_new_documentation_links_resolve_locally(self):
        file = ROOT / 'docs/GITOPS_SMALL_VPS.md'
        text = file.read_text(encoding='utf-8')
        for match in re.finditer(r'\]\(([^)]+)\)', text):
            target = match.group(1)
            if target.startswith(('http://', 'https://', '#')):
                continue
            self.assertTrue((file.parent / target.split('#', 1)[0]).resolve().is_file(), target)

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Bash unavailable')
    def test_new_tools_stay_after_existing_sorted_z_end(self):
        setup = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        function = re.search(r'^sort_tool_menu_keys\(\) \{\n.*?^\}', setup, re.M | re.S).group()
        command = ('set -euo pipefail\n'
                   'TOOL_KEYS=(Ollama OpenClaw Ruflo Zotero Kubeseal Act GitOps_Bootstrap)\n'
                   + function + '\nsort_tool_menu_keys\nprintf "%s\\n" "${TOOL_KEYS[@]}"\n')
        result = subprocess.run([BASH, '--noprofile', '--norc', '-s'], input=command,
                                cwd=ROOT, capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(),
                         ['Ollama', 'OpenClaw', 'Ruflo', 'Act', 'Zotero', 'Kubeseal', 'GitOps_Bootstrap'])

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Bash unavailable')
    def test_shell_syntax_only_without_executing_scripts(self):
        files = ['scripts/bootstrap_gitops.sh', 'scripts/seal_openclaw_secret.sh', 'setup_ultimate.sh']
        files += [str(p.relative_to(ROOT)) for p in (ROOT / 'scripts/tools').glob('gitops_bootstrap_*.sh')]
        files += [str(p.relative_to(ROOT)) for p in (ROOT / 'scripts/tools').glob('kubeseal_*.sh')]
        for file in files:
            result = subprocess.run([BASH, '-n', file], cwd=ROOT, capture_output=True, text=True, timeout=30)
            self.assertEqual(result.returncode, 0, file + ': ' + result.stderr)

    @unittest.skipUnless(shutil.which('helm'), 'Helm unavailable; rendering not claimed')
    def test_helm_refuses_missing_digests_and_renders_pinned_fixtures(self):
        command = ['helm', 'template', 'monitoring-lite', str(ROOT / 'charts/monitoring-lite'), '--namespace', 'ai-monitoring']
        invalid = subprocess.run(command, capture_output=True, text=True, timeout=30)
        self.assertNotEqual(invalid.returncode, 0)
        with tempfile.TemporaryDirectory() as temp:
            values = Path(temp) / 'values.json'
            values.write_text(json.dumps({'prometheus': {'digest': 'sha256:' + '1' * 64},
                                          'grafana': {'digest': 'sha256:' + '2' * 64}}))
            result = subprocess.run(command + ['-f', str(values)], capture_output=True, text=True, timeout=30)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('kind: Deployment', result.stdout)


if __name__ == '__main__':
    unittest.main()
