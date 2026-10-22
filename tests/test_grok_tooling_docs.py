"""Offline checks for the Grok interview documentation and inventory skill."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs/tutorials/grok-development-tooling.md"
SKILL = ROOT / "skills/sandbox-tooling-overview/SKILL.md"
REPORT = SKILL.parent / "assets/capability-report.md"


class GrokToolingDocsTests(unittest.TestCase):
    def test_primary_sources_and_corrections_remain_traceable(self):
        text = DOC.read_text(encoding="utf-8")
        for url in (
            "https://www.crummy.com/software/BeautifulSoup/",
            "https://code.launchpad.net/beautifulsoup",
            "https://github.com/Kludex/starlette",
            "https://github.com/huggingface/text-generation-inference",
            "https://github.com/sgl-project/sglang",
            "https://github.com/pydantic/pydantic-ai",
            "https://github.com/mastra-ai/mastra",
        ):
            self.assertIn("](" + url + ")", text)
        self.assertEqual(text.count("](https://github.com/encode/httpx)"), 1)
        self.assertIn("22.10.2026", text)
        self.assertIn("Wartungsmodus", text)

    def test_skill_metadata_and_relative_links(self):
        fields = dict(line.split(": ", 1) for line in
                      SKILL.read_text(encoding="utf-8").split("---", 2)[1].strip().splitlines())
        self.assertEqual(set(fields), {"name", "description"})
        self.assertEqual(fields["name"], SKILL.parent.name)
        self.assertRegex(fields["name"], r"^[a-z0-9-]{1,63}$")
        for path in (DOC, SKILL, REPORT):
            for target in re.findall(r"\]\(([^)]+)\)", path.read_text(encoding="utf-8")):
                if "://" not in target and not target.startswith("#"):
                    self.assertTrue((path.parent / target.split("#")[0]).is_file(), target)

    def test_report_preserves_evidence_and_not_run_state(self):
        text = REPORT.read_text(encoding="utf-8")
        for state in ("found", "observed", "passed", "failed", "not-found", "not-run"):
            self.assertIn("- " + state + ":", text)
        for field in ("timezone", "Authorized scope", "Exit code", "Evidence / timestamp"):
            self.assertIn(field, text)
        self.assertIn("| not-run | n/a |", text)

    def test_integration_is_discoverable_without_active_workflow(self):
        for name in ("docs/TOOLS_CATALOG.md", "docs/TOOL_INDEX.md",
                     "docs/tutorials/meta-development-tooling.md"):
            self.assertIn(DOC.name, (ROOT / name).read_text(encoding="utf-8"))
        self.assertFalse((ROOT / ".github/workflows/grok-ci.yml").exists())
        text = DOC.read_text(encoding="utf-8")
        self.assertIn("Keine Originaldateien", text)
        self.assertIn("Keine Praesentationsdatei mitgeliefert", text)
        self.assertIn("keine neuen Installer", text)

    def test_markdown_tables_have_consistent_columns(self):
        for path in (DOC, REPORT):
            columns = None
            for line in path.read_text(encoding="utf-8").splitlines():
                if line.startswith("|"):
                    if columns is None:
                        columns = line.count("|")
                    self.assertEqual(line.count("|"), columns, line)
                else:
                    columns = None


if __name__ == "__main__":
    unittest.main()
