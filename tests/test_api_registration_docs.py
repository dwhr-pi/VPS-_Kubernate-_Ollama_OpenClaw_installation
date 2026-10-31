"""Offline content/link checks, not checkout, account, key or pricing live tests."""
from pathlib import Path
import re
from doc_assertions import assert_prose_in, assert_prose_not_in
import unittest
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "docs/_API-Keys"
MAIN = BASE / "REGISTRATION_BILLING_AND_IDENTITY.md"
SERVICES = BASE / "SERVICE_TOKEN_REGISTRATION.md"
REPORT = BASE / "reviews/2026-10-23-registration-billing.md"


class ApiRegistrationDocsTests(unittest.TestCase):
    def test_provider_scope_includes_models_search_media_and_services(self):
        text = MAIN.read_text(encoding="utf-8") + SERVICES.read_text(encoding="utf-8")
        names = (
            "OpenAI", "Anthropic", "Gemini", "Mistral", "Groq", "Cerebras",
            "Together", "NVIDIA", "Cloudflare", "OpenRouter", "token8341",
            "DeepSeek", "Qwen", "Kimi", "Z.AI", "MiniMax", "Synthetic",
            "Hugging Face", "Brave", "Perplexity", "Firecrawl", "ElevenLabs",
            "Deepgram", "Runway", "fal", "Suno", "Udio", "Weights & Biases",
            "Ahrefs", "Semrush", "Airtable", "Notion", "HubSpot", "Buffer",
            "TikTok", "Paperless", "Zotero", "n8n", "Activepieces",
            "Telegram", "Discord", "Slack", "Mattermost", "Zalo", "Twitch",
            "Google Kalender", "Tailscale", "Hurricane Electric", "Home Assistant",
            "GitHub", "OIDC", "Authentik", "Penpot", "Automaton", "FreeLLMAPI",
            "LiteLLM", "LocalAI", "Open WebUI", "OpenClaw", "EULLM",
            "AI Gateway", "WebsiteFactory", "Ollama", "llama.cpp", "ComfyUI",
        )
        for name in names:
            self.assertIn(name, text)

    def test_requested_payment_and_identity_fields_are_explicit(self):
        main = MAIN.read_text(encoding="utf-8")
        for term in ("2026", "PayPal", "Klarna", "Krypto", "USDC",
                     "Kredit-/Debitkarte", "Einzahlung", "Mindestkauf",
                     "Ausweis", "Selfie", "3-D Secure", "UB",
                     "nicht automatisch Klarna", "nicht automatisch die Mindestaufladung"):
            assert_prose_in(self, term, main)
        assert_prose_in(self, "PayPal, Klarna und Krypto", SERVICES.read_text(encoding="utf-8"))

    def test_amounts_are_qualified_and_have_primary_sources(self):
        text = MAIN.read_text(encoding="utf-8")
        for term in ("**15 USD**", "**10 USD**", "**5 USD je Credit-Kauf**",
                     "**5 USD Trial**", "**30 Tage**", "**0,5 CNY Trial**",
                     "**5 CNY**", "**200 USD Start-Credits**",
                     "**1.000 Credits pro Monat**", "**90 Tage**",
                     "keine monatlichen Inference-Provider-Credits",
                     "Bonusschwelle", "Tarifeinstufung"):
            self.assertIn(term, text)
        for source in ("inference-docs.cerebras.ai/support/rate-limits",
                       "docs.together.ai/docs/billing-credits", "openrouter.ai/terms",
                       "deepgram.com/pricing", "www.firecrawl.dev/pricing",
                       "www.alibabacloud.com/help/en/model-studio/new-free-quota"):
            self.assertIn("https://" + source, text)

    def test_no_account_or_document_verification_claims(self):
        text = re.sub(r"\s+", " ", MAIN.read_text(encoding="utf-8"))
        for phrase in ("Keine Konten angelegt", "Checkout", "nicht live getestet",
                       "kein Beweis fuer einen Zugang ohne Ausweis",
                       "Krypto beseitigt keine KYC-", "kein weiterer Hintergrundjob"):
            self.assertIn(phrase, text)
        self.assertIn("kein amtlicher Identitaetsnachweis", SERVICES.read_text(encoding="utf-8"))

    def test_navigation_and_review_prompt_include_new_guides(self):
        for relative in ("README.md", "PROVIDER_KEY_CATALOG.md", "FREE_TIERS_AND_TRIAL_CREDITS.md",
                         "FREE_TIER_REVIEW_PROMPT.md"):
            text = (BASE / relative).read_text(encoding="utf-8")
            self.assertIn(MAIN.name, text, relative)
            self.assertIn(SERVICES.name, text, relative)
        for name in ("README.md", "openrouter.md", "token8341.md"):
            self.assertIn(MAIN.name, (BASE / "OnlineOnKeyServices" / name).read_text(encoding="utf-8"))
        self.assertTrue((BASE / "reviews/2026-10-21.md").is_file())
        self.assertIn(REPORT.name, (BASE / "reviews/README.md").read_text(encoding="utf-8"))

    def test_local_links_https_and_no_secrets_or_affiliates(self):
        for path in (MAIN, SERVICES, REPORT):
            text = path.read_text(encoding="utf-8")
            self.assertEqual(len(re.findall("(?m)^" + chr(96) * 3, text)) % 2, 0)
            self.assertNotRegex(text, r"sk-[A-Za-z0-9]{20,}")
            for link in re.findall(r"\]\(([^)]+)\)", text):
                parts = urlsplit(link)
                if parts.scheme:
                    self.assertEqual(parts.scheme, "https")
                    self.assertIsNone(parts.username)
                    self.assertIsNone(parts.password)
                    self.assertFalse(parts.query)
                elif parts.path:
                    self.assertTrue((path.parent / parts.path).exists(), (path, link))

    def test_markdown_tables_have_consistent_columns(self):
        for path in (MAIN, SERVICES):
            columns = None
            for line in path.read_text(encoding="utf-8").splitlines():
                if not line.startswith("|"):
                    columns = None
                    continue
                count = len(line.strip("|").split("|"))
                if columns is None:
                    columns = count
                self.assertEqual(count, columns, (path.name, line))


if __name__ == "__main__":
    unittest.main()
