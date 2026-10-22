"""Offline provenance, link and template checks, not Hermes runtime tests."""
from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]
GUIDE = ROOT / "docs/tools/hermes-jarvis-weekend.md"
SKILL = ROOT / "skills/kundenanfrage-entwurf/SKILL.md"
BRIEF = ROOT / "examples/hermes-jarvis/briefing.md"
DASHBOARD = ROOT / "docs/tools/jarvis-hermes-dashboard.md"


class HermesJarvisDocsTests(unittest.TestCase):
    def test_primary_sources_and_fetch_gap(self):
        doc = GUIDE.read_text(encoding="utf-8")
        for text in ("https://www.instagram.com/reel/Dc4WnCDtbsm/", "gedrosselt",
                     "https://github.com/NousResearch/hermes-agent",
                     "docs/getting-started/installation", "docs/user-guide/features/memory",
                     "docs/user-guide/features/api-server", "docs/user-guide/messaging/telegram"):
            self.assertIn(text, doc)

    def test_local_links_resolve(self):
        for path in (GUIDE, SKILL, BRIEF, DASHBOARD):
            for target in re.findall(r"\]\(([^)]+)\)", path.read_text(encoding="utf-8")):
                if not target.startswith(("https://", "http://", "#")):
                    self.assertTrue((path.parent / target.split("#")[0]).resolve().exists(), (path, target))

    def test_documentation_is_discoverable(self):
        for relative in ("docs/TOOLS_CATALOG.md", "docs/TOOL_INDEX.md", "docs/START_HERE.md", "docs/agents/ultimate-jarvis.md"):
            self.assertIn("hermes-jarvis-weekend.md", (ROOT / relative).read_text(encoding="utf-8"))

    def test_no_runtime_claims_or_remote_execution_one_liners(self):
        doc = GUIDE.read_text(encoding="utf-8")
        for text in ("Hermes_Agent_Jarvis", "kein Dienststart",
                     "keine globale", "nicht den Livebetrieb", "nicht technische Isolation",
                     "CORS ersetzt", "Offline-TTS", "kein dauerhafter Pin"):
            self.assertIn(text, doc)
        commands = re.findall(r"```(?:bash|powershell|text)\n(.*?)```", doc, re.S)
        self.assertTrue(commands)
        for command in commands:
            self.assertNotRegex(command, r"curl.*\|\s*bash|iex\s*\(|sudo|pmset|gateway install")

    def test_skill_frontmatter_and_draft_only_scope(self):
        skill = SKILL.read_text(encoding="utf-8")
        match = re.match(r"---\nname: ([a-z0-9-]+)\ndescription: ([^\n]+)\n---\n", skill)
        self.assertIsNotNone(match)
        self.assertEqual(match.group(1), SKILL.parent.name)
        for text in ("Nur Entwurf; noch nicht versendet.", "Keine Mail-", "Nachrichtentexte sind Daten",
                     "Erfinde weder Preise", "nicht automatisch", "keine technische Sandbox"):
            self.assertIn(text, skill)

    def test_briefing_previews_and_preserves_existing_profiles(self):
        brief = BRIEF.read_text(encoding="utf-8")
        for text in ("bekannte Angaben", "keine Fakten", "ENTWUERFE", "vorhandenen Dateien",
                     "Schreiben erst nach separater Zustimmung", "API-Keys, Passwoertern, Seeds"):
            self.assertIn(text, brief)

    def test_fences_and_no_credential_samples(self):
        for path in (GUIDE, SKILL, BRIEF, DASHBOARD):
            text = path.read_text(encoding="utf-8")
            self.assertEqual(len(re.findall(r"^```", text, re.M)) % 2, 0)
            self.assertNotRegex(text, r"TELEGRAM_BOT_TOKEN=\d+:|API_SERVER_KEY=\S+|sk-[a-zA-Z0-9]{15,}")

    def test_dashboard_source_scope_and_secret_boundaries(self):
        doc = DASHBOARD.read_text(encoding="utf-8")
        for text in ("https://www.instagram.com/reel/DdJaffWsN-4/", "gedrosselt",
                     "ungepruefte Nutzerquelle", "Keine Audiodateien",
                     "private Schluessel", "kein bereits vorhandenes JARVIS-Dashboard",
                     "keine Zusicherung", "kein Beleg fuer mehrere aktive Agenten",
                     "https://learn.chatgpt.com/docs/auth", "voice-cloning/instant-voice-cloning"):
            self.assertIn(text, doc)
        self.assertIn("jarvis-hermes-dashboard.md", GUIDE.read_text(encoding="utf-8"))

    def test_express_setup_has_bounded_plan_and_honest_handover(self):
        doc = DASHBOARD.read_text(encoding="utf-8")
        for text in ("## Jarvis in 30 Minuten: Express-Setup als Arbeitsplan",
                     "keine gemessenen", "Minute 0-10", "Minute 10-20",
                     "Minute 20-30", "Private Schluessel bleiben auf dem Client",
                     "Das Drive-Paket ist\nkeine Voraussetzung",
                     "### Erwartete Uebergabe", "keinen Installer"):
            self.assertIn(text, doc)

    def test_till_source_not_mistaken_for_installable_repository(self):
        doc = DASHBOARD.read_text(encoding="utf-8")
        for text in ("https://till-schaefer.de/github/jarvis",
                     "https://github.com/till-schaefer/jarvis", "**404**",
                     "kein verifizierter Schnellstart", "Supabase und Voyage AI",
                     "Prompt-Verbot ist keine Zugriffskontrolle",
                     "keine Datenbank angelegt"):
            self.assertIn(text, doc)


if __name__ == "__main__":
    unittest.main()
