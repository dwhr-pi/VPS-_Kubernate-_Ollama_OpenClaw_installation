"""Offline documentation checks; no Qwen, compiler, CI or cluster execution."""
from pathlib import Path
import re
from doc_assertions import assert_prose_in, assert_prose_not_in
import unittest

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs/tutorials/qwen-development-tooling.md"


class QwenToolingDocsTests(unittest.TestCase):
    def test_corrected_sources_and_retrieval_gaps(self):
        text = DOC.read_text(encoding="utf-8")
        for url in (
            "https://github.com/QwenLM/qwen-code",
            "https://github.com/golang-standards/project-layout",
            "https://github.com/golang-standards/project-template",
            "https://github.com/docker/awesome-compose",
            "https://github.com/asg017/sqlite-vss",
            "https://github.com/rust-lang/api-guidelines",
            "https://github.com/OpenHands/OpenHands",
            "https://kubernetes.io/blog/2025/11/11/ingress-nginx-retirement/",
        ):
            self.assertIn("](" + url + ")", text)
        self.assertIn("404", text)
        self.assertIn("429", text)
        self.assertIn("22.10.2026", text)

    def test_local_links_resolve(self):
        for target in re.findall(r"\]\(([^)]+)\)", DOC.read_text(encoding="utf-8")):
            if "://" not in target and not target.startswith("#"):
                self.assertTrue((DOC.parent / target.split("#")[0]).is_file(), target)

    def test_actual_inline_artifacts_are_distinguished_from_execution(self):
        text = DOC.read_text(encoding="utf-8")
        self.assertIn("Vollstaendige YAML-Textbeispiele vorhanden", text)
        self.assertIn("HTML-Quelltext mit neun Folien", text)
        self.assertIn("im Browser", text)
        self.assertIn("nicht das Qwen-Original", text)
        self.assertFalse((ROOT / ".github/workflows/qwen-interview-ci.yml").exists())

    def test_navigation_from_existing_qwen_tools(self):
        for name in ("docs/TOOLS_CATALOG.md", "docs/TOOL_INDEX.md",
                     "docs/tools/qwen-code.md", "docs/tools/qwen-desktop-windows.md",
                     "docs/tutorials/perplexity-development-tooling.md"):
            self.assertIn(DOC.name, (ROOT / name).read_text(encoding="utf-8"))

    def test_review_boundaries_and_tables(self):
        text = DOC.read_text(encoding="utf-8")
        for phrase in ("nicht coverage", "keinen Namespace", "cache: false",
                       "keine neuen Installer", "Keine WSL-Aktion"):
            assert_prose_in(self, phrase, text)
        columns = None
        for line in text.splitlines():
            if line.startswith("|"):
                if columns is None:
                    columns = line.count("|")
                self.assertEqual(line.count("|"), columns, line)
            else:
                columns = None


if __name__ == "__main__":
    unittest.main()
