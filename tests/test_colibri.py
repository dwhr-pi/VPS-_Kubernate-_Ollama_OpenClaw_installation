"""Colibri integration contracts; no upstream execution or hardware probing."""
import json
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


class ColibriIntegration(unittest.TestCase):
    def test_registry_is_explicitly_source_only(self):
        rows = json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"]
        row, = [r for r in rows if r["id"] == "colibri"]
        self.assertEqual(row["name"], "Colibri")
        self.assertEqual(row["source"], "https://github.com/JustVugg/colibri.git")
        self.assertRegex(row["source_commit"], r"^[a-f0-9]{40}$")
        self.assertEqual(row["install_mode"], "github-source-only")
        self.assertEqual(row["status"], "experimental")
        self.assertFalse(row["auto_install"])
        self.assertEqual(row["ports"], [])

    def test_wrappers_only_dispatch_to_shared_source_installer(self):
        for action in ("install", "update", "uninstall", "doctor", "status", "check"):
            text = (ROOT / f"scripts/tools/colibri_{action}.sh").read_text(encoding="utf-8")
            self.assertIn("set -euo pipefail", text)
            self.assertIn("offload_sources.py", text)
            self.assertIn('"$@"', text)
            for forbidden in ("start-here", "npm ", "pip ", "sudo ", "docker ", "make "):
                self.assertNotIn(forbidden, text)

    def test_document_links_and_limits(self):
        doc = ROOT / "docs/tools/colibri.md"
        text = doc.read_text(encoding="utf-8")
        for target in re.findall(r"\]\(([^)]+)\)", text):
            if "://" not in target:
                self.assertTrue((doc.parent / target.split("#")[0]).is_file(), target)
        for required in ("Letsung", "RTX 5080", "runtime_ready=false", "VHDX",
                         "kein Modell-Preflight", "Quellen vorbereitet", "1-GiB",
                         "keine Garantie", "start-here.sh", "nur den Setup-Marker"):
            self.assertIn(required, text)
        self.assertEqual(text.count("```") % 2, 0)

    def test_menu_and_indexes(self):
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertEqual(menu.count('TOOL_KEYS+=("Colibri")'), 1)
        self.assertIn('TOOL_SCRIPT_NAMES["Colibri"]="colibri"', menu)
        for file in ("docs/TOOLS_CATALOG.md", "docs/TOOL_INDEX.md", "docs/TOOL_MATRIX.md",
                     "docs/GITHUB_TOOL_SOURCES.md", "docs/START_HERE.md"):
            self.assertIn("tools/colibri.md", (ROOT / file).read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
