"""Offline documentation checks; no accounts, network, scheduler or installers."""
from pathlib import Path
import re
from doc_assertions import assert_prose_in, assert_prose_not_in
import unittest
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "docs/_API-Keys"
OVERVIEW = BASE / "FREE_TIERS_AND_TRIAL_CREDITS.md"
PROMPT = BASE / "FREE_TIER_REVIEW_PROMPT.md"
REPORT = BASE / "reviews/2026-10-21.md"
CLAUDE = ROOT / "docs/tools/claude-code.md"


class FreeTierSourcesDocs(unittest.TestCase):
    def test_named_sources_are_concrete_owner_repository_links(self):
        text = OVERVIEW.read_text(encoding="utf-8")
        for repository in ("mnfst/awesome-free-llm-apis", "freellms/awesome-freellm-apis",
                           "raffiihza/free-llm-coding-credits", "devanasolver/awesome-free-llm-apis"):
            self.assertIn("https://github.com/" + repository, text)
        self.assertIn("Primaer", text)
        self.assertIn("404", text)
        self.assertIn("unverified", text)

    def test_all_requested_providers_are_evaluated_with_primary_sources(self):
        text = OVERVIEW.read_text(encoding="utf-8")
        for name, domain in (("Cloudflare", "developers.cloudflare.com"), ("Gemini", "ai.google.dev"),
                             ("Groq", "console.groq.com"), ("Cerebras", "inference-docs.cerebras.ai"),
                             ("NVIDIA", "forums.developer.nvidia.com"), ("OpenRouter", "openrouter.ai"),
                             ("Together", "docs.together.ai"), ("Mistral", "docs.mistral.ai"),
                             ("Ollama lokal", "github.com/ollama/ollama")):
            self.assertIn(name, text)
            self.assertIn(domain, text)
        for category in ("free-tier", "trial", "promotion", "paid-prepaid", "local", "unverified"):
            self.assertIn("`" + category + "`", text)

    def test_initial_findings_preserve_corrections_and_sources(self):
        text = REPORT.read_text(encoding="utf-8")
        for term in ("5 USD Trial", "30 Tage", "Zahlungsmittel", "15 USD",
                     "Kein Konto", "nicht synchronen Dateiinhalt", "keine Live", "2026"):
            assert_prose_in(self, term.casefold(), text.casefold())
        assert_prose_in(self, "billing-credits", text)
        assert_prose_in(self, "Cerebras", text)
        assert_prose_in(self, "Commercial Terms", text)

    def test_claude_code_is_not_silently_replaced_or_relicensed(self):
        text = CLAUDE.read_text(encoding="utf-8")
        for term in ("nicht als Open Source", "Commercial Terms", "kein", "ant",
                     "Referenzmaterial/Plugins", "Qwen", "Gemini", "OpenCode"):
            self.assertIn(term, text)
        self.assertIn("https://github.com/anthropics/claude-code/blob/main/LICENSE.md", text)
        self.assertNotIn("curl -", text)
        self.assertNotIn("| iex", text)

    def test_review_retains_evidence_and_forbids_runtime_side_effects(self):
        text = PROMPT.read_text(encoding="utf-8")
        for term in ("Primaerquellen", "Alte Berichte", "Kein Zugriff auf WSL", "Kein Auslesen",
                     "Keine Provider-Inferenz", "Kein `git pull`", "Suchsnippet", "unverified",
                     "Cerebras", "NVIDIA", "OpenRouter", "Together", "Mistral"):
            self.assertIn(term, text)

    def test_schedule_is_not_misrepresented_as_github_workflow(self):
        text = OVERVIEW.read_text(encoding="utf-8")
        for term in ("Codex-Thread-Automation", "montags 09:00", "Europe/Berlin",
                     "kein bei GitHub installierter", "Push fuehrt daher nicht sofort", "laufender App"):
            assert_prose_in(self, term, text)

    def test_navigation_links_to_sources_and_history(self):
        for path in (BASE / "README.md", ROOT / "docs/tools/freellmapi.md",
                     BASE / "OnlineOnKeyServices/README.md", ROOT / "docs/TOOL_INDEX.md"):
            self.assertIn("FREE_TIERS_AND_TRIAL_CREDITS.md", path.read_text(encoding="utf-8"))
        self.assertIn("2026-10-21.md", (BASE / "reviews/README.md").read_text(encoding="utf-8"))

    def test_new_markdown_has_resolvable_local_links_and_balanced_fences(self):
        files = (OVERVIEW, PROMPT, REPORT, CLAUDE, BASE / "reviews/README.md")
        for path in files:
            text = path.read_text(encoding="utf-8")
            self.assertEqual(len(re.findall(r"(?m)^```", text)) % 2, 0, str(path))
            for link in re.findall(r"\]\(([^)]+)\)", text):
                self.assertNotIn(" ", link, link)
                parts = urlsplit(link)
                if parts.scheme:
                    self.assertEqual(parts.scheme, "https", link)
                    self.assertIsNone(parts.username, link)
                    self.assertIsNone(parts.password, link)
                elif parts.path:
                    self.assertTrue((path.parent / unquote(parts.path)).exists(), link)


if __name__ == "__main__":
    unittest.main()
