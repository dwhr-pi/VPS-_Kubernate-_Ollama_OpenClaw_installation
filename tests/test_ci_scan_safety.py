"""Offline contracts for public build metadata and credential-free examples."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class CIScanSafety(unittest.TestCase):
    def test_public_signing_digest_still_guards_download(self):
        for name in ('ansible/vps_bootstrap.yml', 'docs/PRODUCTION_BASELINE_CODE.md'):
            text = (ROOT / name).read_text(encoding='utf-8')
            self.assertIn("docker_key_sha256 | default('1500c1f56fa9e26b9b8f42452a553675796ade0807cdce11975eb98170b3a570')", text)
            self.assertIn('docker_signing_sha256:', text)
            self.assertIn('checksum: "sha256:{{ docker_signing_sha256 }}"', text)

    def test_source_pin_and_marker_checks_are_preserved(self):
        text = (ROOT / 'scripts/tools/helpers/freellmapi_common.sh').read_text(encoding='utf-8')
        self.assertIn('FREE_LLM_SOURCE_COMMIT=57c0669233bbe0c70a0f9f9927613192be948773', text)
        self.assertIn('rev-parse HEAD)" == "$FREE_LLM_SOURCE_COMMIT"', text)
        self.assertIn('grep -Fxq "$FREE_LLM_SOURCE_COMMIT" "$FREELLMAPI_MARKER"', text)

    def test_examples_never_publish_reusable_gateway_hex_tokens(self):
        text = (ROOT / 'docs/OPENCLAW_ENV_GUIDE.md').read_text(encoding='utf-8')
        self.assertNotRegex(text, r'OPENCLAW_GATEWAY_TOKEN=[a-f0-9]{32,}')
        self.assertEqual(text.count('OPENCLAW_GATEWAY_TOKEN=<GENERATE_LOCALLY>'), 2)
        self.assertIn('openssl rand -hex 32', text)
        self.assertIn('rotieren', text)

    def test_private_guide_uses_ssh_and_signature_not_pat_arguments(self):
        text = (ROOT / 'docs/PRIVATE_REPO_GUIDE.md').read_text(encoding='utf-8')
        self.assertIn('git clone --no-recurse-submodules git@github.com:', text)
        self.assertIn('(SIGNED_RELEASES.md)', text)
        self.assertNotIn('https://DEIN_TOKEN@', text)
        self.assertNotIn('curl -H', text)

    def test_scan_retains_fail_closed_redacted_diagnostics(self):
        text = (ROOT / 'scripts/secret_scan.sh').read_text(encoding='utf-8')
        self.assertIn('set -euo pipefail', text)
        self.assertIn('gitleaks detect --source "$ROOT_DIR" --no-git --redact --verbose', text)
        self.assertNotIn('gitleaks:allow', text)
        self.assertNotIn('continue-on-error', text)

    def test_macos_coverage_migrates_without_skip_or_fail_fast(self):
        text = (ROOT / '.github/workflows/coding-agents.yml').read_text(encoding='utf-8')
        self.assertIn('os: [ubuntu-24.04, windows-latest, macos-15]', text)
        self.assertIn('fail-fast: false', text)
        self.assertNotIn('continue-on-error', text)
        self.assertNotIn('macos-14', text)


if __name__ == '__main__':
    unittest.main()
