"""Documentation checks only; no live webinar, registration or SMTP tests."""
from pathlib import Path
import re
import unittest
from urllib.parse import urlsplit


ROOT = Path(__file__).resolve().parents[1]
GUIDE = ROOT / "docs/tutorials/webinar-stack.md"


class WebinarStackDocsTests(unittest.TestCase):
    def test_local_references_resolve(self):
        doc = GUIDE.read_text(encoding="utf-8")
        for target in re.findall(r"\]\(([^)]+)\)", doc):
            if not urlsplit(target).scheme and not target.startswith("#"):
                self.assertTrue((GUIDE.parent / target.split("#")[0]).resolve().is_file(), target)

    def test_guide_reachable_from_existing_entrypoints(self):
        for path in ("docs/START_HERE.md", "docs/TOOLS_CATALOG.md", "docs/TOOL_INDEX.md",
                     "docs/media_studio/README.md", "docs/media_studio/STREAMING_PIPELINE.md",
                     "docs/tools/webinar-tools.md"):
            self.assertIn("webinar-stack.md", (ROOT / path).read_text(encoding="utf-8"))

    def test_primary_repositories_not_search_result_links(self):
        doc = GUIDE.read_text(encoding="utf-8")
        targets = re.findall(r"\]\(([^)]+)\)", doc)
        for target in ("https://github.com/marp-team/marp-cli", "https://github.com/knadh/listmonk",
                       "https://github.com/mautic/mautic", "https://github.com/obsproject/obs-studio",
                       "https://github.com/jitsi/jitsi-meet"):
            self.assertIn(target, targets)
        self.assertFalse(any(urlsplit(t).hostname == "www.google.com" for t in targets))
        self.assertIn("GPL-3.0-or-later, **nicht AGPL**", doc)

    def test_no_unbalanced_fences_or_activated_deployment_examples(self):
        doc = GUIDE.read_text(encoding="utf-8")
        fences = re.findall(r"^```(.*)$", doc, re.M)
        self.assertEqual(fences, ["text", "", "text", ""])
        self.assertNotIn("docker compose up", doc)
        self.assertNotIn("smtp_password=", doc)
        self.assertIn("kein Nachweis einer fertig eingerichteten Gesamtplattform", doc)


if __name__ == "__main__":
    unittest.main()
