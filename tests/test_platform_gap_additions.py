"""Offline-Vertraege fuer Sprachdialog und opt-in Infrastruktur, ohne Dienste oder Netzwerk."""
import http.client
import importlib.util
import io
import json
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import Mock

ROOT = Path(__file__).resolve().parents[1]
BASH = 'C:/Program Files/Git/bin/bash.exe' if sys.platform == 'win32' else shutil.which('bash')
SPEC = importlib.util.spec_from_file_location('readonly_exporter', ROOT / 'scripts/monitoring/ollama_readonly_exporter.py')
exporter = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(exporter)


class ReadonlyExporterTests(unittest.TestCase):
    def response(self, body):
        opener = Mock()
        opener.open.return_value = io.BytesIO(body)
        return opener

    def test_private_endpoints_and_listeners_reject_public_wildcard_and_credentials(self):
        for value in ('http://127.0.0.1:11434', 'http://10.7.0.2:11434',
                      'https://[fd00::1]:11434', 'http://ollama.llmops.svc.cluster.local:11434'):
            self.assertTrue(exporter.endpoint(value).endswith('/api/ps'))
        for value in ('http://0.0.0.0:11434', 'http://8.8.8.8', 'http://169.254.169.254',
                      'http://user:secret@127.0.0.1', 'http://127.0.0.1/?key=secret',
                      'file:///etc/passwd', 'http://unreviewed.invalid', 'http://127.0.0.1/api/generate'):
            with self.subTest(value=value), self.assertRaises(ValueError):
                exporter.endpoint(value)
        for value in ('0.0.0.0', '::', '8.8.8.8'):
            with self.assertRaises(ValueError):
                exporter.private_ip(value)

    def test_only_get_inventory_no_prompts_model_names_or_invented_latency(self):
        body = json.dumps({'models': [{'name': 'PRIVATE-NAME', 'size_vram': 42}]}).encode()
        opener = self.response(body)
        text = exporter.scrape('http://127.0.0.1:11434/api/ps', opener).decode()
        request = opener.open.call_args.args[0]
        self.assertEqual(request.get_method(), 'GET')
        self.assertEqual(request.full_url, 'http://127.0.0.1:11434/api/ps')
        self.assertIsNone(request.data)
        self.assertIn('ollama_monitor_up 1', text)
        self.assertIn('ollama_monitor_loaded_vram_bytes 42', text)
        self.assertNotIn('PRIVATE-NAME', text)
        self.assertNotIn('request_latency', text)
        self.assertNotIn('ollama_gpu_usage', text)
        self.assertEqual(opener.open.call_args.kwargs['timeout'], 2)

    def test_bad_or_missing_inventory_is_not_reported_as_healthy_zero(self):
        for body in (b'not-json', b'{}', b'{"models":[{}]}', b'{"models":[{"size_vram":-1}]}',
                     b'{"models":[{"size_vram":NaN}]}', b'x' * 1048577):
            with self.subTest(length=len(body)):
                text = exporter.scrape('http://127.0.0.1:11434/api/ps', self.response(body)).decode()
                self.assertIn('ollama_monitor_up 0', text)
        for error in (OSError('private-value'), http.client.IncompleteRead(b'private-value')):
            opener = Mock()
            opener.open.side_effect = error
            text = exporter.scrape('http://127.0.0.1:11434/api/ps', opener).decode()
            self.assertIn('ollama_monitor_up 0', text)
            self.assertNotIn('private-value', text)

    def test_redirects_and_oversized_numbers_are_rejected(self):
        with self.assertRaises(ValueError):
            exporter.NoRedirect().redirect_request(None, None, 302, '', {}, 'http://unreviewed.invalid')
        for value in (True, -1, 10**1000, float('nan'), '42'):
            with self.assertRaises(ValueError):
                exporter.number(value)


class PlatformGapContracts(unittest.TestCase):
    def read(self, path):
        return (ROOT / path).read_text(encoding='utf-8')

    def test_production_quota_is_patch_not_duplicate_and_compose_has_real_local_limits(self):
        overlay = self.read('k8s/overlays/production/kustomization.yml')
        self.assertIn('  - path: resource-quota.yaml', overlay)
        quota = self.read('k8s/overlays/production/resource-quota.yaml')
        self.assertIn('name: llmops-budget', quota)
        self.assertIn('requests.nvidia.com/gpu:', quota)
        compose = self.read('stacks/llmops-platform/docker-compose.yml')
        for service, container in (('litellm', 'llmops-litellm'), ('open-webui', 'llmops-open-webui'), ('qdrant', 'llmops-qdrant')):
            block = re.search(r'^  ' + service + r':\n.*?(?=^  [a-z]|\Z)', compose, re.M | re.S).group()
            for field in ('mem_limit:', 'mem_reservation:', 'cpus:', 'reservations:', 'limits:'):
                self.assertIn(field, block)
            self.assertIn(container, block)

    def test_idle_tunnel_requires_secrets_access_and_has_no_public_service(self):
        tunnel = self.read('k8s/platform/cloudflared-tunnel.yaml')
        routes = self.read('k8s/platform/ingress-routes.yaml')
        self.assertIn('replicas: 0', tunnel)
        self.assertIn('secretName: cloudflared-credentials', tunnel)
        self.assertIn('$(POD_IP):2000', tunnel)
        self.assertNotIn('0.0.0.0:', tunnel)
        self.assertNotIn('hostNetwork:', tunnel)
        self.assertNotIn('type: LoadBalancer', tunnel)
        self.assertNotIn('nodePort:', tunnel)
        self.assertEqual(routes.count('required: true'), 2)
        self.assertIn('http_status:404', routes)
        self.assertNotIn('noTLSVerify', routes)

    def test_policies_are_explicit_namespace_opt_in_and_do_not_trust_pod_skip_labels(self):
        for name in ('require-resource-limits', 'drop-root-capabilities'):
            policy = self.read('k8s/base/security/' + name + '.yaml')
            self.assertIn('validationFailureAction: Enforce', policy)
            self.assertIn('namespaceSelector:', policy)
            self.assertIn('llmops.example/security-policy: enforce', policy)
            self.assertNotIn('security/' + name, self.read('k8s/base/kustomization.yml'))
        policy = self.read('k8s/base/security/drop-root-capabilities.yaml')
        self.assertIn('namespaces: [kube-system, velero, kyverno]', policy)
        self.assertIn('llmops.example/system-exception: approved', policy)
        self.assertIn('=(ephemeralContainers)', policy)
        self.assertIn('capabilities: {drop: [ALL]}', policy)

    def test_gitops_uses_kustomize_not_compose_and_backups_are_paused_offsite(self):
        app = self.read('k8s/gitops/llmops-platform-app.yaml')
        self.assertIn('path: k8s/overlays/production', app)
        self.assertIn('REPLACE_WITH_FULL_REVIEWED_COMMIT', app)
        self.assertNotIn('automated:', app)
        self.assertNotIn('prune:', app)
        backup = self.read('k8s/platform/velero/backup-storage-location.yaml')
        for field in ('paused: true', 'defaultVolumesToFsBackup: true', 'snapshotVolumes: false',
                      'useOwnerReferencesInBackup: false', 'name: velero-cloud-credentials'):
            self.assertIn(field, backup)
        renderer = self.read('scripts/velero_setup.sh')
        for field in ('--dry-run -o yaml', '--no-secret', '--no-default-backup-location',
                      '--concurrent-backups 1', '--maintenance-job-mem-limit 1Gi'):
            self.assertIn(field, renderer)
        self.assertNotRegex(renderer, re.compile(r'^\s*(?:sudo\s+)?kubectl\s', re.M))

    def test_no_metrics_targets_are_enabled_by_default(self):
        groups = json.loads(self.read('monitoring/ollama-metrics.targets.json'))
        self.assertFalse(any(group['targets'] for group in groups))
        self.assertIn('replicas: 0', self.read('k8s/platform/ollama-exporter.yaml'))

    def test_every_native_manifest_tool_has_a_recovery_scenario(self):
        manifest = json.loads(self.read('config/docker_to_github.json'))['tools']
        text = self.read('docs/NATIVE_BUILD_RECOVERY.md')
        rows = dict(re.findall(r'^\|\s*`([^`]+)`\s*\|\s*([^|]+)\s*\|', text, re.M))
        self.assertEqual(set(rows), {tool['id'] for tool in manifest})
        for tool in manifest:
            self.assertIn('A / B' if tool['recipe'] else 'C', rows[tool['id']])

    def test_new_documentation_links_resolve(self):
        for path in ('docs/PLATFORM_GAP_IMPLEMENTATION_2026-10-27.md', 'docs/NATIVE_BUILD_RECOVERY.md'):
            file = ROOT / path
            text = file.read_text(encoding='utf-8')
            self.assertEqual(text.count('```') % 2, 0)
            for target in re.findall(r'\]\(([^)]+)\)', text):
                if '://' not in target:
                    self.assertTrue((file.parent / target).is_file(), target)

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Bash erforderlich')
    def test_velero_renderer_never_applies_and_requires_real_digest_shapes(self):
        with tempfile.TemporaryDirectory() as temp:
            mock = Path(temp) / 'velero'
            mock.write_text('#!/bin/sh\nprintf "%s\\n" "$@"\n', encoding='utf-8', newline='\n')
            mock.chmod(0o700)
            wrapper = shlex.quote((ROOT / 'scripts/velero_setup.sh').as_posix())
            directory = shlex.quote(Path(temp).as_posix())
            # Windows-Laufwerksdoppelpunkte sind keine gueltigen POSIX-PATH-Komponenten.
            prefix = 'set -euo pipefail\n'
            prefix += ('mockdir=$(cygpath -u ' + directory + ')\n' if sys.platform == 'win32'
                       else 'mockdir=' + directory + '\n')
            prefix += 'export PATH="$mockdir:$PATH"\n'
            for arguments, expected in (('', 0), ('--render', 1), ('--apply', 1),
                    ('--render --server-image registry.invalid/velero@sha256:' + '1' * 64 +
                     ' --plugin-image registry.invalid/plugin@sha256:' + '2' * 64, 0)):
                result = subprocess.run([BASH, '--noprofile', '--norc', '-s'],
                                        input=prefix + 'bash ' + wrapper + ' ' + arguments + '\n', cwd=ROOT,
                                        capture_output=True, text=True, encoding='utf-8', timeout=60)
                self.assertEqual(result.returncode, expected, result.stderr)
                if '--plugin-image' in arguments:
                    self.assertIn('--dry-run\n', result.stdout)
                    self.assertIn('--no-secret\n', result.stdout)
                    self.assertIn('--use-node-agent\n', result.stdout)
                    self.assertNotIn('--apply\n', result.stdout)
                else:
                    self.assertNotIn('install\n', result.stdout)

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Bash erforderlich')
    def test_changed_shell_files_parse_without_execution(self):
        files = ['setup_ultimate.sh', 'scripts/velero_setup.sh'] + [
            str(path.relative_to(ROOT)).replace('\\', '/') for path in (ROOT / 'scripts/lang').glob('*.sh')]
        command = 'set -euo pipefail\nfor file in ' + ' '.join(map(shlex.quote, files)) + '; do bash -n "$file"; done\n'
        result = subprocess.run([BASH, '--noprofile', '--norc', '-s'], input=command, cwd=ROOT,
                                capture_output=True, text=True, encoding='utf-8', timeout=180)
        self.assertEqual(result.returncode, 0, result.stderr)

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Bash erforderlich')
    def test_loading_dialog_has_translated_yes_no_for_all_ten_languages(self):
        setup = self.read('setup_ultimate.sh')
        validator = re.search(r'^loading_translation_format_ok\(\) \{\n.*?^\}', setup, re.M | re.S).group()
        function = re.search(r'^show_management_loading_notice\(\) \{\n.*?^\}', setup, re.M | re.S).group()
        command = '''set -euo pipefail
APP_TITLE=fixture
load_setup_language() { :; }
is_preference_enabled() { return 0; }
dialog() {
  while (($#)); do
    case "$1" in
      --yes-label) printf 'YES:%s\\n' "$2"; shift 2 ;;
      --no-label) printf 'NO:%s\\n' "$2"; shift 2 ;;
      --yesno) printf 'BODY:%s\\n' "$2"; return 1 ;;
      *) shift ;;
    esac
  done
}
''' + validator + '\n' + function + '\n' + 'for lang in de en fr zh ja ru es eo ar he; do\n' + \
            'source ' + shlex.quote(ROOT.as_posix() + '/scripts/lang') + '/"$lang".sh\n' + '''
printf 'LANG:%s\\n' "$lang"
rc=0
show_management_loading_notice "$TXT_LOADING_TOOLS_LABEL" "$TXT_LOADING_TOOLS_DETAIL" || rc=$?
printf 'RC:%s\\n' "$rc"
done
'''
        result = subprocess.run([BASH, '--noprofile', '--norc', '-s'], input=command, cwd=ROOT,
                                capture_output=True, text=True, encoding='utf-8', timeout=180)
        self.assertEqual(result.returncode, 0, result.stderr)
        labels = {'de': ('Ja', 'Nein'), 'en': ('Yes', 'No'), 'fr': ('Oui', 'Non'),
                  'zh': ('是', '否'), 'ja': ('はい', 'いいえ'), 'ru': ('Да', 'Нет'),
                  'es': ('Sí', 'No'), 'eo': ('Jes', 'Ne'), 'ar': ('نعم', 'لا'), 'he': ('כן', 'לא')}
        for language, (yes, no) in labels.items():
            block = result.stdout.split('LANG:' + language + '\n', 1)[1].split('LANG:', 1)[0]
            self.assertIn('YES:' + yes + '\n', block)
            self.assertIn('NO:' + no + '\n', block)
            self.assertIn('RC:1', block)
            self.assertNotIn('%s', block)

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Bash erforderlich')
    def test_language_pack_overrides_remain_compatible_and_do_not_leak_to_english(self):
        with tempfile.TemporaryDirectory() as temp:
            pack = Path(temp) / 'custom'
            (pack / 'setup').mkdir(parents=True)
            (pack / 'manifest.conf').write_text('PACK_LANGUAGE=de\nPACK_ENABLED=true\n')
            (pack / 'setup/de.sh').write_text('TXT_YES_LABEL=OVERLAY-JA\nTXT_NO_LABEL=OVERLAY-NEIN\n')
            command = 'set -euo pipefail\nSCRIPT_ROOT_DIR=' + shlex.quote(ROOT.as_posix()) + '\n' + \
                'source "$SCRIPT_ROOT_DIR/scripts/lang/common.sh"\nLANGUAGE_PACKS_DIR=' + shlex.quote(Path(temp).as_posix()) + '\n' + '''
source "$SCRIPT_ROOT_DIR/scripts/lang/de.sh"
load_setup_language_pack_overlays de
printf '%s|%s\\n' "$TXT_YES_LABEL" "$TXT_NO_LABEL"
source "$SCRIPT_ROOT_DIR/scripts/lang/en.sh"
load_setup_language_pack_overlays en
printf '%s|%s\\n' "$TXT_YES_LABEL" "$TXT_NO_LABEL"
'''
            result = subprocess.run([BASH, '--noprofile', '--norc', '-s'], input=command, cwd=ROOT,
                                    capture_output=True, text=True, encoding='utf-8', timeout=90)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout.splitlines(), ['OVERLAY-JA|OVERLAY-NEIN', 'Yes|No'])


if __name__ == '__main__':
    unittest.main()
