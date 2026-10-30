"""Offline contracts for exact auth decisions, failure defaults and provenance."""

import importlib.util
import json
from pathlib import Path
import re
import unittest
from urllib.error import HTTPError, URLError
from urllib.parse import urlsplit
from unittest.mock import Mock


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "external_link_probe", ROOT / "scripts/quality/external_link_probe.py"
)
PROBE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(PROBE)


class Response:
    def __init__(self, status):
        self.status = status

    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False


class ExternalLinkPolicyTests(unittest.TestCase):
    def setUp(self):
        self.config = json.loads(
            (ROOT / ".github/markdown-link-check.json").read_text(encoding="utf-8")
        )

    def ignored(self, url):
        return any(re.search(item["pattern"], url) for item in self.config["ignorePatterns"])

    def test_only_exact_account_entries_are_exempt(self):
        self.assertEqual(len(self.config["ignorePatterns"]), 6)
        for url in PROBE.AUTH_URLS:
            self.assertTrue(self.ignored(url), url)
            opener = Mock(side_effect=AssertionError("No account access"))
            self.assertEqual(PROBE.probe(url, opener=opener)[0], "AUTH")
            opener.assert_not_called()
            for suffix in ("/public", "?query=1", ".attacker.invalid"):
                self.assertFalse(self.ignored(url + suffix), url + suffix)
        for item in self.config["ignorePatterns"][2:]:
            self.assertIn("keine Inhaltsverifikation", item["reason"])

    def test_public_failures_are_not_exempt_or_alive(self):
        for url in (
            "https://docs.paperless-ngx.com/api/",
            "https://eur-lex.europa.eu/eli/reg/2016/679/oj",
            "https://ai.google.dev/gemini-api/docs/pricing",
            "https://huggingface.co/datasets/ontocord/VALID",
            "https://ndpc.gov.ng/",
            "http://127.0.0.1:9999",
            "https://console.mistral.ai/public",
        ):
            self.assertFalse(self.ignored(url), url)
        for status in (0, 202, 401, 403, 404, 429, 503):
            self.assertNotIn(status, self.config["aliveStatusCodes"])
        self.assertEqual(self.config["replacementPatterns"], [])

    def test_ci_link_gates_use_the_same_explicit_configuration(self):
        for name in ("ci.yml", "repo-health.yml", "linkcheck.yml"):
            text = (ROOT / ".github/workflows" / name).read_text(encoding="utf-8")
            self.assertIn('markdown-link-check@3.15.0', text)
            self.assertIn('node scripts/quality/link_checker_contract.cjs', text)
            for line in text.splitlines():
                if "markdown-link-check " in line and "npm install" not in line:
                    self.assertIn("-c .github/markdown-link-check.json", line)
        dedicated = (ROOT / ".github/workflows/linkcheck.yml").read_text(encoding="utf-8")
        self.assertIn("-c .github/markdown-link-check.json", dedicated)
        self.assertIn("find . -type f -name '*.md'", dedicated)
        self.assertNotIn("continue-on-error", dedicated)
        health = (ROOT / ".github/workflows/repo-health.yml").read_text(encoding="utf-8")
        self.assertIn("find docs -name '*.md' -print0", health)

    def test_status_failures_stay_failures_after_bounded_retries(self):
        for status in (202, 401, 403, 404, 429, 500, 503):
            with self.subTest(status=status):
                opener = Mock(side_effect=HTTPError("https://example.org/", status, "", {}, None))
                sleep = Mock()
                result = PROBE.probe("https://example.org/", opener=opener, sleep=sleep)
                self.assertEqual(result, ("FAIL", str(status)))
                attempts = 2 if status in (202, 429, 500, 503) else 1
                self.assertEqual(opener.call_count, attempts)
                self.assertEqual(sleep.call_count, attempts - 1)
                self.assertEqual(opener.call_args.kwargs["timeout"], 10)

    def test_transport_failure_never_becomes_success(self):
        opener = Mock(side_effect=URLError("fixture transport failure"))
        result = PROBE.probe("https://example.org/", opener=opener, sleep=Mock())
        self.assertEqual(result[0], "FAIL")
        self.assertTrue(result[1].startswith("0 "))
        self.assertEqual(opener.call_count, 2)

    def test_retry_can_recover_without_weakening_success_codes(self):
        opener = Mock(side_effect=[Response(503), Response(200)])
        self.assertEqual(PROBE.probe("https://example.org/", opener=opener, sleep=Mock()), ("OK", "200"))
        request = opener.call_args.args[0]
        self.assertEqual(request.get_method(), "GET")
        self.assertNotIn("Authorization", request.headers)
        self.assertNotIn("Cookie", request.headers)
        for status in (200, 206):
            self.assertEqual(PROBE.probe("https://example.org/", opener=Mock(return_value=Response(status)))[0], "OK")

    def test_local_examples_are_syntax_only(self):
        for name, port in (("sdnext.md", 7860), ("alexandria-audiobook.md", 4200)):
            text = (ROOT / "docs/tools" / name).read_text(encoding="utf-8")
            url = f"http://127.0.0.1:{port}"
            self.assertIn(f"`{url}`", text)
            self.assertIn("lokales Beispiel", text)
            self.assertNotIn(url, PROBE.markdown_urls(text))
            parts = urlsplit(url)
            self.assertEqual((parts.scheme, parts.hostname, parts.port), ("http", "127.0.0.1", port))

    def test_history_is_preserved_at_original_locations(self):
        cases = {
            "docs/tutorials/qwen-development-tooling.md": ["https://github.com/Microsoft/TypeScript-Node-Starter"],
            "docs/tutorials/chatgpt-tooling-sources.md": ["https://github.com/bminor/bash"],
            "docs/tutorials/meta-development-tooling.md": ["https://hg.reportlab.com/hg-public/reportlab"],
            "docs/tools/jarvis-hermes-dashboard.md": ["https://github.com/till-schaefer/jarvis"],
            "docs/_API-Keys/reviews/2026-10-26.md": ["https://github.com/cheahjs/free-llm-api-resources"],
            "docs/KUSTOMIZE_INSTALLATION_NOTES.md": ["https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize%2Fv5.8.2"],
            "docs/MISTRAL_AI_INTEGRATION.md": ["https://docs.mistral.ai/getting-started/models/weights/"],
            "docs/media_studio/SOCIAL_AVATAR_AUTOMATION.md": ["https://docs.n8n.io/sustainable-use-license/"],
            "docs/audit/TOOL_INVENTORY.md": ["https://github.com/canonical/ufw", "https://github.com/dwhr-pi/content-multiplier.git", "https://codeberg.org/forgejo/forgejo.git", "https://github.com/modelcontextprotocol/servers/tree/main/src/sqlite"],
            "docs/TOOL_SETUP_AUDIT.md": ["https://github.com/deinname/fingpt", "https://github.com/username/huginn", "https://github.com/flowiseai/flowisechatbot", "https://github.com/modelcontextprotocol/server-sqlite", "https://github.com/modelcontextprotocol/server-postgres", "https://github.com/modelcontextprotocol/server-git", "https://github.com/modelcontextprotocol/server-filesystem", "https://github.com/openclaw/clawbake", "https://github.com/till-schaefer/jarvis"],
        }
        for path, urls in cases.items():
            text = (ROOT / path).read_text(encoding="utf-8")
            for url in urls:
                with self.subTest(path=path, url=url):
                    self.assertTrue(f"`{url}`" in text, f"Historische URL fehlt: {path}: {url}")
                    self.assertNotIn(url, PROBE.markdown_urls(text))

    def test_equivalent_primary_records_keep_original_addresses(self):
        sources = {
            "docs/legal/INTERNATIONAL_SOURCES.md": [
                ("https://eur-lex.europa.eu/eli/reg/2016/679/oj",
                 "https://op.europa.eu/en/publication-detail/-/publication/3e485e15-11bd-11e6-ba9a-01aa75ed71a1/language-de"),
                ("https://eur-lex.europa.eu/eli/reg/2024/1689/oj",
                 "https://op.europa.eu/en/publication-detail/-/publication/dc8116a1-3fe6-11ef-865a-01aa75ed71a1/language-de"),
                ("https://eur-lex.europa.eu/eli/dir/2019/790/oj",
                 "https://op.europa.eu/en/publication-detail/-/publication/214471fe-786e-11e9-9f05-01aa75ed71a1/language-de"),
                ("https://eur-lex.europa.eu/eli/dir/2022/2555/oj",
                 "https://op.europa.eu/en/publication-detail/-/publication/9b84d482-85bd-11ed-9887-01aa75ed71a1/language-de"),
            ],
            "docs/_API-Keys/SERVICE_TOKEN_REGISTRATION.md": [
                ("https://docs.paperless-ngx.com/api/",
                 "https://github.com/paperless-ngx/paperless-ngx/blob/main/docs/api.md"),
            ],
        }
        for path, pairs in sources.items():
            text = (ROOT / path).read_text(encoding="utf-8")
            active = PROBE.markdown_urls(text)
            for original, replacement in pairs:
                with self.subTest(path=path, original=original):
                    self.assertIn(f"`{original}`", text)
                    self.assertNotIn(original, active)
                    self.assertIn(replacement, active)
            self.assertIn("Originalveroeffentlichung, nicht eine aktuelle konsolidierte Rechtspruefung", " ".join(text.split()))

    def test_unavailable_card_is_not_silently_replaced(self):
        text = (ROOT / "docs/media_studio/VIDEO_TRAINING_DATASETS.md").read_text(encoding="utf-8")
        self.assertIn("1758855b0f16da2ba0edda156099cc5a78405a94/README.md`", text)
        self.assertIn("Abruf 401, Inhalt und aktuelle Lizenz nicht verifiziert", text)

    def test_probe_excludes_code_not_public_links(self):
        text = "`https://old.invalid/` [Live](https://example.org/)\n```sh\n[Code](https://code.invalid/)\n```\n"
        self.assertEqual(PROBE.markdown_urls(text), ["https://example.org/"])


if __name__ == "__main__":
    unittest.main()
