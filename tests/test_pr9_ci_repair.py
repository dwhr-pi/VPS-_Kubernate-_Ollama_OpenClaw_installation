"""PR9 regressions; never build a scanner, install dependencies or contact a service."""
import os
from pathlib import Path
import re
import shutil
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')


class CIContracts(unittest.TestCase):
    def test_legacy_entrypoints_only_delegate_and_archives_refuse_execution(self):
        for name, tool in (('base_install', 'ollama'), ('vps_standalone', 'k3s')):
            wrapper = (ROOT / f'scripts/{name}.sh').read_text(encoding='utf-8')
            self.assertIn(f'exec bash "$CORE_ROOT/scripts/tools/{tool}_install.sh" "$@"', wrapper)
            for forbidden in ('sudo ', 'apt-get ', 'git clone ', 'source ', 'mark_current_tool_installed'):
                self.assertNotIn(forbidden, wrapper)
            self.assertLess(len(wrapper.splitlines()), 10)
            archive = (ROOT / f'docs/legacy/{name.upper()}_REFERENCE.sh.txt').read_text(encoding='utf-8')
            self.assertTrue(archive.startswith('# Historical reference only; explicit execution is refused.'))
            self.assertLess(archive.index('exit 3'), archive.index('#!/bin/bash'))

    def test_scanner_is_source_pinned_and_build_failure_cannot_be_ignored(self):
        text = (ROOT / 'scripts/ci/build_trivy.sh').read_text(encoding='utf-8')
        for contract in ('set -Eeuo pipefail', 'e713f67f7d54decdcd9b3132c9751833dcced698',
                         'https://github.com/aquasecurity/trivy.git', 'go mod verify',
                         'git diff --exit-code -- go.mod go.sum', '-mod=readonly',
                         'pkg/version/app.ver=0.76.1', './cmd/trivy', 'go1.27.3'):
            self.assertIn(contract, text)
        for forbidden in ('curl ', 'wget ', 'sudo ', 'docker run', '|| true', 'rm -rf'):
            self.assertNotIn(forbidden, text)
        self.assertLess(text.index('export GOTOOLCHAIN=local'), text.index('go env GOVERSION'))

    def test_both_scan_gates_remain_strict_and_secret_output_is_redacted(self):
        text = (ROOT / '.github/workflows/test-install-scripts.yml').read_text(encoding='utf-8')
        self.assertEqual(text.count('bash scripts/ci/build_trivy.sh --build'), 2)
        self.assertIn('trivy fs --scanners secret --exit-code 1', text)
        self.assertIn('trivy config --severity HIGH,CRITICAL --exit-code 1', text)
        self.assertIn('.RuleID', text)
        self.assertNotIn('.Match', text)
        self.assertNotIn('continue-on-error', text)
        self.assertNotIn('aquasecurity/trivy-action@', text)
        for action in re.findall(r'uses: ([^\s]+)', text):
            self.assertRegex(action, r'@[0-9a-f]{40}$')

    def test_native_new_members_have_labels_scripts_and_markers(self):
        menu = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        status = (ROOT / 'scripts/helpers/native_tool_status.sh').read_text(encoding='utf-8')
        for key, slug in (('ArgoCD_CLI', 'argocd_cli'), ('Cloudflared', 'cloudflared')):
            self.assertIn(f'TOOL_SCRIPT_NAMES["{key}"]="{slug}"', menu)
            self.assertIn(f'TOOLS["{key}"]=', menu)
            self.assertIn(f'marker={slug}/native-github/build-ready.json', status)
            for action in ('install', 'update', 'status', 'doctor', 'check', 'uninstall'):
                self.assertTrue((ROOT / f'scripts/tools/{slug}_{action}.sh').is_file())

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Existing native Bash required; no WSL fallback')
    def test_builder_plan_and_unapproved_build_never_run_tools_or_create_output(self):
        env = dict(os.environ, BASH_ENV='', ENV='', GITHUB_ACTIONS='', RUNNER_OS='unapproved')
        for args, expected in (([], 0), (['--dry-run'], 0), (['--build'], 2), (['--unknown'], 2)):
            result = subprocess.run([BASH, '--noprofile', '--norc', 'scripts/ci/build_trivy.sh', *args],
                                    cwd=ROOT, env=env, capture_output=True, text=True, timeout=20)
            self.assertEqual(result.returncode, expected, result.stderr)
            self.assertNotIn('Cloning', result.stdout + result.stderr)


if __name__ == '__main__':
    unittest.main()
