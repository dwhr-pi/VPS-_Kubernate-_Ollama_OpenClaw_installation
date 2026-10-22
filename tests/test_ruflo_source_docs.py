"""Offline source provenance and existing Ruflo integration documentation."""
import json
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs/tools/ruflo.md"


class RufloSourceDocsTests(unittest.TestCase):
    def test_user_sources_and_retrieval_limits(self):
        text = DOC.read_text(encoding="utf-8")
        self.assertIn("https://www.instagram.com/reel/DeRCVWllVC2/", text)
        self.assertIn("scientific-calcium-e74.notion.site/Ruflo-der-Befehl-mit-dem-aus-Claude-eine-Firma-wird-3fbc501ffd45811f8738c955cdeb6f94", text)
        self.assertIn("Abruf gedrosselt", text)
        self.assertIn("kein reel angesehen", text.lower())
        self.assertIn("22.10.2026", text)
        self.assertNotIn("?mdxt=", text)

    def test_existing_registry_and_wrapper_match_documentation(self):
        tools = json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"]
        tool = next(item for item in tools if item["id"] == "ruflo")
        text = DOC.read_text(encoding="utf-8")
        self.assertIn(tool["install_script"], text)
        self.assertIn(tool["uninstall_script"], text)
        self.assertIn(tool["check_value"], text)
        self.assertTrue((ROOT / tool["install_script"]).is_file())
        self.assertIn("scripts/ruflo_install.sh", (ROOT / tool["install_script"]).read_text())

    def test_local_links_and_navigation(self):
        for target in re.findall(r"\]\(([^)]+)\)", DOC.read_text(encoding="utf-8")):
            if "://" not in target and not target.startswith("#"):
                self.assertTrue((DOC.parent / target.split("#")[0]).is_file(), target)
        for name in ("docs/TOOLS_CATALOG.md", "docs/TOOL_INDEX.md"):
            self.assertIn("tools/ruflo.md", (ROOT / name).read_text(encoding="utf-8"))

    def test_legacy_behavior_not_claimed_private_or_pinned(self):
        text = DOC.read_text(encoding="utf-8")
        for phrase in ("NodeSource", "pnpm@latest", "--no-frozen-lockfile",
                       "git pull", "Skripte und Registry bleiben", "Keine Installation"):
            self.assertIn(phrase, text)

    def test_markdown_tables(self):
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
