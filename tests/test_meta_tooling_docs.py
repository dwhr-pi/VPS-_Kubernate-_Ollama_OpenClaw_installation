"""Offline Meta-interview integration checks. No tools, models, network or WSL."""
import json
from pathlib import Path
import re
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs/tutorials/meta-development-tooling.md"
SKILL = ROOT / "skills/fullstack-project-bootstrapper/SKILL.md"


class MetaToolingDocsTests(unittest.TestCase):
    def test_original_github_sources_and_all_four_kits_remain_traceable(self):
        text = DOC.read_text(encoding="utf-8")
        sources = {
            "ollama/ollama", "open-webui/open-webui", "qdrant/qdrant", "langchain-ai/langchain",
            "tmc/langchaingo", "n8n-io/n8n", "FlowiseAI/Flowise",
            "n8n-io/self-hosted-ai-starter-kit", "coleam00/local-ai-packaged", "freeaihub/ai-lab",
            "FranzDiebold/gen-ai-template", "nextest-rs/nextest", "langchain-ai/langchainjs",
        }
        for repo in sources:
            self.assertIn("](https://github.com/" + repo + ")", text)
        self.assertIn("22.10.2026", text)

    def test_local_links_and_skill_frontmatter_resolve(self):
        text = SKILL.read_text(encoding="utf-8")
        fields = dict(line.split(": ", 1) for line in text.split("---", 2)[1].strip().splitlines())
        self.assertEqual(set(fields), {"name", "description"})
        self.assertEqual(fields["name"], SKILL.parent.name)
        self.assertRegex(fields["name"], r"^[a-z0-9-]{1,63}$")
        for path in (SKILL, DOC):
            for target in re.findall(r"\]\(([^)]+)\)", path.read_text(encoding="utf-8")):
                if "://" not in target and not target.startswith("#"):
                    self.assertTrue((path.parent / target.split("#")[0]).is_file(), target)

    def test_existing_artifacts_not_misrepresented_as_meta_downloads(self):
        examples = ROOT / "examples/manus-ci-cd"
        go = (examples / "go-ci.yml.example").read_text()
        rust = (examples / "rust-ci.yml.example").read_text()
        self.assertIn("cache: false", go)
        self.assertNotIn("nextest", rust)
        self.assertNotIn("docker push", rust)
        data = json.loads((ROOT / "docs/presentations/technology-tooling-overview.json").read_text(encoding="utf-8"))
        self.assertEqual(len(data["slides"]), 13)
        with zipfile.ZipFile(ROOT / "docs/presentations/technology-tooling-overview.pptx") as archive:
            self.assertEqual(len([name for name in archive.namelist()
                                  if re.fullmatch(r"ppt/slides/slide\d+\.xml", name)]), 13)
        text = DOC.read_text(encoding="utf-8")
        self.assertIn("Keine Meta-Dateien mitgeliefert", text)
        self.assertIn("Keine Datei und kein verwendbarer Downloadlink", text)
        self.assertIn("noch kein neu integrierter Installer", text)

    def test_meta_is_discoverable_but_separate_from_other_interviews(self):
        for name in ("docs/TOOLS_CATALOG.md", "docs/TOOL_INDEX.md", "docs/tutorials/gemini-development-tooling.md",
                     "docs/tutorials/manus-interview-2026-10-22.md"):
            self.assertIn(DOC.name, (ROOT / name).read_text(encoding="utf-8"))
        self.assertFalse((ROOT / ".github/workflows/meta-ci.yml").exists())
        self.assertFalse((ROOT / ".github/workflows/fullstack-project-bootstrapper.yml").exists())

    def test_markdown_fences_and_table_rows_are_balanced(self):
        text = DOC.read_text(encoding="utf-8")
        self.assertEqual(len(re.findall(r"^```.*$", text, re.M)), 2)
        expected_columns = None
        for line in text.splitlines():
            if line.startswith("|"):
                count = line.count("|")
                if expected_columns is None:
                    expected_columns = count
                self.assertEqual(count, expected_columns, line)
            else:
                expected_columns = None


if __name__ == "__main__":
    unittest.main()
