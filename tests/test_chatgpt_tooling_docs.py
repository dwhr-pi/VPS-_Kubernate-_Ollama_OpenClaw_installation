"""Offline interview navigation, source provenance and SQLite example tests."""
import json
from pathlib import Path
import re
import sqlite3
from doc_assertions import assert_prose_in, assert_prose_not_in
import unittest

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs/tutorials/chatgpt-development-tooling.md"
SOURCES = ROOT / "docs/tutorials/chatgpt-tooling-sources.md"
SQL = ROOT / "examples/chatgpt-tooling/model-inventory.sql"


class ChatGPTToolingDocsTests(unittest.TestCase):
    def test_all_original_repository_urls_are_preserved_without_tracking(self):
        fixture = json.loads((ROOT / "tests/fixtures/chatgpt_interview_sources.json").read_text(encoding="utf-8"))
        expected = fixture["repositories"]
        self.assertEqual(len(expected), 90)
        self.assertEqual(len(set(expected)), len(expected))
        actual = re.findall(r"\]\((https://github\.com/[^)]+)\)", SOURCES.read_text(encoding="utf-8"))
        self.assertEqual(set(actual), set(expected))
        self.assertEqual(len(actual), len(expected))
        self.assertNotIn("utm_source", "\n".join(actual))

    def test_primary_sources_for_corrections_and_openai_boundaries(self):
        text = DOC.read_text(encoding="utf-8")
        for url in (
            "https://github.com/OHF-Voice/piper1-gpl",
            "https://github.com/facebookresearch/demucs",
            "https://github.com/prisma/orm",
            "https://github.com/FFmpeg/FFmpeg",
            "https://docs.nvidia.com/datacenter/dcgm/latest/user-guide/getting-started.html",
            "https://developers.openai.com/blog/codex-as-a-platform",
            "https://learn.chatgpt.com/docs/codex/cli",
        ):
            self.assertIn("](" + url + ")", text)
        self.assertIn("22.10.2026", text)

    def test_local_links_resolve(self):
        for path in (DOC, SOURCES):
            for target in re.findall(r"\]\(([^)]+)\)", path.read_text(encoding="utf-8")):
                if "://" not in target and not target.startswith("#"):
                    self.assertTrue((path.parent / target.split("#")[0]).is_file(), target)

    def test_artifact_claims_and_execution_boundaries(self):
        text = DOC.read_text(encoding="utf-8")
        assert_prose_in(self, "keine nutzbaren Datei-URLs", text)
        assert_prose_in(self, "ohne Provenienznachweis", text)
        assert_prose_in(self, "Keine Toolinstallation, WSL-Aktion", text)
        assert_prose_in(self, "kein hier\ninstallierter Skill", text)
        assert_prose_not_in(self, "images.openai.com/static-rsc", text)
        self.assertFalse((ROOT / ".github/workflows/chatgpt-interview-ci.yml").exists())

    def test_navigation(self):
        for name in ("docs/TOOLS_CATALOG.md", "docs/TOOL_INDEX.md",
                     "docs/tutorials/claude-development-tooling.md"):
            self.assertIn(DOC.name, (ROOT / name).read_text(encoding="utf-8"))

    def test_sql_configuration_inventory_and_filter(self):
        with sqlite3.connect(":memory:") as db:
            db.executescript(SQL.read_text(encoding="utf-8"))
            self.assertEqual(db.execute("SELECT name, backend FROM ai_models WHERE enabled = TRUE").fetchall(),
                             [("Qwen", "llama.cpp")])
            db.execute("INSERT INTO ai_models (id, name, backend) VALUES (2, 'Disabled', 'example')")
            self.assertEqual(db.execute("SELECT enabled FROM ai_models WHERE id=2").fetchone(), (0,))
            self.assertEqual(db.execute("SELECT COUNT(*) FROM ai_models WHERE enabled=TRUE").fetchone(), (1,))

    def test_sql_required_fields_and_unique_primary_key(self):
        with sqlite3.connect(":memory:") as db:
            db.executescript(SQL.read_text(encoding="utf-8"))
            for statement in (
                "INSERT INTO ai_models (id, backend) VALUES (3, 'example')",
                "INSERT INTO ai_models (id, name) VALUES (4, 'Missing backend')",
                "INSERT INTO ai_models VALUES (1, 'Duplicate', 'example', FALSE)",
            ):
                with self.assertRaises(sqlite3.IntegrityError):
                    db.execute(statement)

    def test_markdown_tables(self):
        for path in (DOC, SOURCES):
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
