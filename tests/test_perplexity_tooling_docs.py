"""Offline evidence and navigation checks for the Perplexity interview."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs/tutorials/perplexity-development-tooling.md"
SKILL = ROOT / "skills/sprach-infra-tooling/SKILL.md"
REVIEW = SKILL.parent / "references/interview-source-review.md"


class PerplexityToolingDocsTests(unittest.TestCase):
    def test_corrected_primary_sources_are_explicit(self):
        text = DOC.read_text(encoding="utf-8")
        for url in (
            "https://github.com/testcontainers/testcontainers-python",
            "https://github.com/testcontainers/testcontainers-go",
            "https://github.com/microsoft/pylance-release",
            "https://github.com/microsoft/pyright",
            "https://github.com/kubernetes/kubectl",
            "https://github.com/pytest-dev/pytest-cov",
            "https://docs.astral.sh/uv/concepts/projects/dependencies/",
        ):
            self.assertIn("](" + url + ")", text)
        self.assertIn("22.10.2026", text)

    def test_local_document_and_skill_links_resolve(self):
        for path in (DOC, SKILL, REVIEW):
            for target in re.findall(r"\]\(([^)]+)\)", path.read_text(encoding="utf-8")):
                if "://" not in target and not target.startswith("#"):
                    self.assertTrue((path.parent / target.split("#")[0]).is_file(), target)
        self.assertIn(REVIEW.name, SKILL.read_text(encoding="utf-8"))

    def test_missing_artifacts_are_not_reported_as_generated(self):
        text = DOC.read_text(encoding="utf-8")
        self.assertIn("Keine PPTX angehaengt", text)
        self.assertIn("nur elf Folien", text)
        self.assertIn("keine vollstaendigen Go-/Rust-Workflow-Dateien", text)
        self.assertIn("kein Perplexity-Original", text)
        self.assertFalse((ROOT / ".github/workflows/perplexity-ci.yml").exists())

    def test_navigation_and_action_boundaries(self):
        for name in ("docs/TOOLS_CATALOG.md", "docs/TOOL_INDEX.md",
                     "docs/tutorials/gemini-development-tooling.md"):
            self.assertIn(DOC.name, (ROOT / name).read_text(encoding="utf-8"))
        text = DOC.read_text(encoding="utf-8")
        for phrase in ("cache: false", "keine neuen Installer", "WSL-Aktion",
                       "keine automatische Sandbox", "nicht vollstaendig nachgeprueft"):
            self.assertIn(phrase, text)

    def test_tables_remain_consistent(self):
        columns = None
        for line in DOC.read_text(encoding="utf-8").splitlines():
            if line.startswith("|"):
                if columns is None:
                    columns = line.count("|")
                self.assertEqual(line.count("|"), columns, line)
            else:
                columns = None


if __name__ == "__main__":
    unittest.main()
