"""Offline CI contracts: complete history and inert public examples, never secrets."""
from pathlib import Path
import os
import re
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')


class CiRepairContracts(unittest.TestCase):
    def test_global_shellcheck_follows_sources_without_disabling_rules(self):
        settings = [line.strip() for line in (ROOT / '.shellcheckrc').read_text(
            encoding='utf-8').splitlines() if line.strip() and not line.startswith('#')]
        self.assertEqual(settings, ['external-sources=true', 'source-path=SCRIPTDIR'])

    def test_overlay_patches_repeat_base_security_invariants(self):
        for relative in ('k8s/overlays/production/resources.yml',
                         'k8s/overlays/vps-cpu/deployment.yaml'):
            documents = (ROOT / relative).read_text(encoding='utf-8').split('---')
            self.assertEqual(len(documents), 2)
            for document, base in zip(documents, ('ollama.yml', 'litellm.yml')):
                base_text = (ROOT / 'k8s/base' / base).read_text(encoding='utf-8')
                for pattern in (r'runAsNonRoot:\s*true', r'runAsUser:\s*10001',
                                r'runAsGroup:\s*10001', r'fsGroup:\s*10001',
                                r'type:\s*RuntimeDefault',
                                r'allowPrivilegeEscalation:\s*false',
                                r'readOnlyRootFilesystem:\s*true', r'drop:\s*\[ALL\]'):
                    self.assertRegex(base_text, pattern)
                    self.assertRegex(document, pattern)

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash unavailable')
    def test_scan_wrapper_handles_nonexecutable_helper_and_preserves_failure(self):
        with tempfile.TemporaryDirectory(prefix='scan wrapper ') as directory:
            root = Path(directory).resolve()
            scripts = root / 'scripts'
            (scripts / 'security').mkdir(parents=True)
            wrapper = scripts / 'security/scan_secrets.sh'
            shutil.copyfile(ROOT / 'scripts/security/scan_secrets.sh', wrapper)
            helper = scripts / 'check_secrets.sh'
            helper.write_text('#!/usr/bin/env bash\n'
                              '[[ "$#" == 1 && "$1" == --dry-run ]] || exit 99\n'
                              'printf "fixture scan only\\n"\n'
                              'exit "${FIXTURE_SCAN_EXIT:?}"\n', encoding='utf-8')
            helper.chmod(0o600)
            for expected in (0, 23):
                with self.subTest(exit_code=expected):
                    result = subprocess.run(
                        [BASH, '--noprofile', '--norc', str(wrapper)], cwd=root,
                        env={**os.environ, 'FIXTURE_SCAN_EXIT': str(expected)},
                        capture_output=True, text=True, timeout=20)
                    self.assertEqual(result.returncode, expected, result.stderr)
                    self.assertEqual(result.stdout.strip(), 'fixture scan only')

    def test_queue_lint_resolves_real_sources_without_suppressions(self):
        workflow = (ROOT / '.github/workflows/next-level-health.yml').read_text(encoding='utf-8')
        self.assertIn('shellcheck -x --source-path=SCRIPTDIR', workflow)
        self.assertNotIn('--exclude', workflow)
        self.assertNotIn('continue-on-error', workflow)
        for path in (ROOT / 'scripts/queue').glob('*.sh'):
            text = path.read_text(encoding='utf-8')
            self.assertNotIn('disable=SC1091', text)
            for filename in re.findall(r'# shellcheck source=(queue_\w+\.sh)', text):
                self.assertTrue((path.parent / filename).is_file(), filename)

    def test_gitleaks_checks_full_history_without_disabling_scan(self):
        for filename in ('secret-scan.yml', 'ci.yml', 'repo-health.yml'):
            with self.subTest(workflow=filename):
                workflow = (ROOT / '.github/workflows' / filename).read_text(encoding='utf-8')
                self.assertIn('fetch-depth: 0', workflow)
                self.assertIn('persist-credentials: false', workflow)
                self.assertIn('contents: read', workflow)
                self.assertIn('gitleaks/gitleaks-action@ff98106e4c7b2bc287b24eaf42907196329070c7', workflow)
                self.assertNotIn('continue-on-error', workflow)
                self.assertNotIn('|| true', workflow)
                self.assertNotIn('pull_request_target', workflow)

    def test_public_env_template_contains_only_placeholders_and_loopback(self):
        template = ROOT / 'config/examples/core.env.template'
        text = template.read_text(encoding='utf-8')
        self.assertIn('PUBLIC TEMPLATE ONLY', text)
        allowed = {'OPENCLAW_GATEWAY_TOKEN', 'OPENAI_BASE_URL', 'OPENAI_API_KEY',
                   'ANTHROPIC_API_KEY', 'GEMINI_API_KEY', 'MANUS_API_KEY'}
        found = set()
        for line in text.splitlines():
            if not line or line.startswith('#'):
                continue
            key, separator, value = line.partition('=')
            self.assertEqual(separator, '=')
            self.assertIn(key, allowed)
            self.assertNotIn(key, found)
            found.add(key)
            if key == 'OPENAI_BASE_URL':
                self.assertEqual(value, 'http://127.0.0.1:11434/v1')
            else:
                self.assertTrue(value.startswith('REPLACE_WITH_'))
        self.assertEqual(found, allowed)

    def test_sealed_structure_is_explicitly_not_deployable_ciphertext(self):
        example = ROOT / 'k8s/gitops/examples/openclaw-api.sealed.yaml.example'
        text = example.read_text(encoding='utf-8')
        self.assertTrue(example.name.endswith('.yaml.example'))
        self.assertIn('not valid ciphertext', text)
        self.assertIn('REPLACE_WITH_REAL_KUBESEAL_CIPHERTEXT', text)
        self.assertNotIn('AgA', text)
        self.assertIn('secrets/', (ROOT / '.gitignore').read_text(encoding='utf-8'))

    def test_documentation_points_at_public_examples(self):
        for doc in ('docs/SECURE_CORE_REFACTOR.md', 'docs/GITOPS_SMALL_VPS.md'):
            path = ROOT / doc
            for link in re.findall(r'\]\(([^)]+)\)', path.read_text(encoding='utf-8')):
                if '://' not in link and not link.startswith('#'):
                    self.assertTrue((path.parent / link.split('#')[0]).is_file(), link)


if __name__ == '__main__':
    unittest.main()
