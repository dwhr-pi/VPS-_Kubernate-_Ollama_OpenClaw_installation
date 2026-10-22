"""Offline Claude interview and manual Windows integration documentation checks."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs/tutorials/claude-development-tooling.md"
GUIDE = ROOT / "docs/tutorials/qwen-desktop-claude-local.md"


class ClaudeToolingDocsTests(unittest.TestCase):
    def test_local_links_resolve(self):
        for path in (DOC, GUIDE):
            for target in re.findall(r"\]\(([^)]+)\)", path.read_text(encoding="utf-8")):
                if "://" not in target and not target.startswith("#"):
                    self.assertTrue((path.parent / target.split("#")[0]).is_file(), target)

    def test_primary_integration_sources(self):
        text = DOC.read_text(encoding="utf-8") + GUIDE.read_text(encoding="utf-8")
        for url in (
            "https://docs.ollama.com/integrations/claude-code",
            "https://docs.ollama.com/api/anthropic-compatibility",
            "https://docs.litellm.ai/docs/tutorials/claude_non_anthropic_models",
            "https://github.com/anthropics/claude-code/blob/main/LICENSE.md",
            "https://pip.pypa.io/en/stable/cli/pip_install/",
            "https://github.com/adrienverge/yamllint",
        ):
            self.assertIn("](" + url + ")", text)

    def test_missing_artifacts_and_client_boundaries(self):
        text = DOC.read_text(encoding="utf-8")
        self.assertIn("Keine PPTX/HTML-Datei", text)
        self.assertIn("kein vollstaendiger Rust-Workflow", text)
        self.assertIn("kein redundanter Skill-Installer", text)
        text = GUIDE.read_text(encoding="utf-8")
        self.assertIn("Claude-Code-Client bleibt proprietaer", text)
        self.assertIn("kein Claude-Code-Plugin-Host", text)
        self.assertIn("kein Zugriffsschutz", text)

    def test_powershell_sample_has_process_scope_and_cleanup(self):
        text = GUIDE.read_text(encoding="utf-8")
        blocks = re.findall(r"```powershell\n(.*?)\n```", text, re.S)
        self.assertEqual(len(blocks), 1)
        sample = blocks[0]
        self.assertIn("http://127.0.0.1:11434", sample)
        self.assertIn("finally", sample)
        self.assertIn("GetEnvironmentVariable($name, 'Process')", sample)
        self.assertIn("SetEnvironmentVariable($name, $before[$name], 'Process')", sample)
        self.assertIn("'ANTHROPIC_API_KEY', $null, 'Process'", sample)
        self.assertNotIn("setx", sample.lower())
        self.assertNotIn("0.0.0.0", sample)
        self.assertNotIn("dangerously-skip", sample)
        self.assertNotIn("ollama pull", sample)

    def test_documentation_is_discoverable(self):
        for name in ("docs/TOOLS_CATALOG.md", "docs/TOOL_INDEX.md",
                     "docs/tools/claude-code.md", "docs/tutorials/qwen-development-tooling.md"):
            self.assertIn(DOC.name, (ROOT / name).read_text(encoding="utf-8"))
        for name in ("docs/tools/claude-code.md", "docs/tools/qwen-desktop-windows.md"):
            self.assertIn(GUIDE.name, (ROOT / name).read_text(encoding="utf-8"))

    def test_no_active_claude_interview_workflow(self):
        self.assertFalse((ROOT / ".github/workflows/claude-interview-ci.yml").exists())
        self.assertIn("Keine WSL-Aktion", DOC.read_text(encoding="utf-8"))
        self.assertIn("widerspruechliche Angaben", DOC.read_text(encoding="utf-8"))

    def test_markdown_tables_and_fences(self):
        for path in (DOC, GUIDE):
            text = path.read_text(encoding="utf-8")
            self.assertEqual(len(re.findall(r"^```.*$", text, re.M)) % 2, 0)
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
