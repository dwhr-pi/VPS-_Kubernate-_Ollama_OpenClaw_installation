"""Offline checks for Gemini interview documentation and existing source scope."""

import json
from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs/tutorials/gemini-development-tooling.md"


class GeminiDevelopmentDocsTests(unittest.TestCase):
    def test_scope_is_explicit(self):
        content = DOC.read_text(encoding="utf-8")
        for phrase in (
            "Gemini-Interview", "runtime_ready=false", "github-source-not-built",
            "keine verifizierte interne Toolliste", "keine Masseninstallation",
            "keine Sandbox", "System-Python", "Windows-Host-Speicher",
        ):
            self.assertIn(phrase, content)

    def test_source_pin_matches_agent_config(self):
        config = json.loads((ROOT / "config/agents/coding_agents.json").read_text(encoding="utf-8"))
        # Compare the documented commit against the versioned configuration,
        # without fetching upstream or reading private installation state.
        pins = re.findall(r"[0-9a-f]{40}", json.dumps(config))
        documented = re.search(r"`([0-9a-f]{40})`", DOC.read_text(encoding="utf-8"))
        self.assertIsNotNone(documented)
        self.assertIn(documented.group(1), pins)

    def test_local_links_exist(self):
        for relative in (
            "docs/tutorials/gemini-development-tooling.md",
            "docs/TOOL_INDEX.md",
            "docs/agents/coding-agent-profiles.md",
        ):
            path = ROOT / relative
            content = path.read_text(encoding="utf-8")
            for target in re.findall(r"\]\(([^)]+)\)", content):
                if "://" in target or target.startswith("#"):
                    continue
                self.assertTrue((path.parent / target.split("#")[0]).exists(), target)

    def test_key_github_sources_are_present(self):
        content = DOC.read_text(encoding="utf-8")
        for repo in (
            "google-gemini/gemini-cli", "pola-rs/polars", "mwaskom/seaborn",
            "colinhacks/zod", "tokio-rs/axum", "dtolnay/thiserror",
            "prisma/orm", "sqlite/sqlite", "scikit-learn/scikit-learn",
        ):
            self.assertIn("https://github.com/" + repo, content)


if __name__ == "__main__":
    unittest.main()
