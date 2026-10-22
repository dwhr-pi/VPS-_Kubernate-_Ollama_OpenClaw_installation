"""Offline source/skill/documentation checks; never installs, builds or deploys."""
import json
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills/sprach-infra-tooling/SKILL.md"
DOC = ROOT / "docs/tutorials/manus-interview-2026-10-22.md"


class ManusToolingInterviewTests(unittest.TestCase):
    def test_new_skill_frontmatter_and_repository_references(self):
        text = SKILL.read_text(encoding="utf-8")
        front = text.split("---", 2)[1]
        fields = dict(line.split(": ", 1) for line in front.strip().splitlines())
        self.assertEqual(set(fields), {"name", "description"})
        self.assertEqual(fields["name"], SKILL.parent.name)
        self.assertRegex(fields["name"], r"^[a-z0-9-]{1,63}$")
        self.assertTrue(fields["description"])
        for path in [DOC, *SKILL.parent.rglob("*.md")]:
            text = path.read_text(encoding="utf-8")
            for target in re.findall(r"\]\(([^)]+)\)", text):
                if "://" not in target and not target.startswith("#"):
                    self.assertTrue((path.parent / target.split("#")[0]).is_file(), target)

    def test_manus_claims_are_separate_from_local_artifacts(self):
        text = DOC.read_text(encoding="utf-8")
        self.assertIn("22.10.2026", text)
        self.assertIn("kein importierter Manus-Originalskill", text)
        self.assertIn("manus-resource://manus-slides/deck/", text)
        self.assertIn("Unveraendert weiterverwendet", text)
        self.assertIn("keine Neuinstallation", text)
        self.assertIn("nicht global aktiviert", text)

    def test_brief_covers_all_seven_selection_criteria(self):
        text = (SKILL.parent / "assets/tooling-brief.md").read_text(encoding="utf-8")
        for field in ("Einsatzgebiet", "Betriebsmodell", "Hardware", "Datenschutz", "Budget", "Integrationen", "Bedienniveau"):
            self.assertIn(field, text)
        skill = SKILL.read_text(encoding="utf-8")
        self.assertIn("bereits bekannten Kontext nicht erneut", skill)
        self.assertIn("GitHub statt als Docker-Installation", skill)

    def test_existing_ci_and_deck_remain_accurately_described(self):
        go = (ROOT / "examples/manus-ci-cd/go-ci.yml.example").read_text()
        rust = (ROOT / "examples/manus-ci-cd/rust-ci.yml.example").read_text()
        self.assertIn("cache: false", go)
        self.assertIn("go-version-file: go.mod", go)
        self.assertIn("go test -race", go)
        self.assertIn("cargo clippy --locked --all-targets -- -D warnings", rust)
        text = DOC.read_text(encoding="utf-8")
        self.assertIn("cache: false", text)
        self.assertIn("keine\n  byteidentischen Binaries", text)
        self.assertEqual(len(json.loads((ROOT / "docs/presentations/technology-tooling-overview.json").read_text(encoding="utf-8"))["slides"]), 13)
        self.assertIn("Dify ist hier eine zusaetzliche Referenz", text)
        for path in ("docs/TOOLS_CATALOG.md", "docs/TOOL_INDEX.md", "docs/tutorials/manus-development-workflow.md"):
            self.assertIn(DOC.name, (ROOT / path).read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
