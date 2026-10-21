"""Offline documentation checks; no provider, GitHub, runtime or WSL calls."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "docs/tutorials/manus-development-sources.md"
REPOS = (
    "python/cpython", "pypa/pip", "pypa/packaging.python.org", "astral-sh/uv", "jupyter/notebook",
    "pytest-dev/pytest", "astral-sh/ruff", "psf/black", "python/mypy", "pre-commit/pre-commit",
    "nedbat/coveragepy", "HypothesisWorks/hypothesis", "fastapi/fastapi", "pallets/flask",
    "django/django", "Kludex/starlette", "pydantic/pydantic", "encode/uvicorn", "facebook/react",
    "microsoft/TypeScript", "vitejs/vite", "nodejs/node", "pnpm/pnpm", "microsoft/playwright",
    "git/git", "actions/checkout", "actions/runner", "cli/cli", "astral-sh/ruff-action",
    "microsoft/playwright-github-action",
)


class ManusSourcesDocs(unittest.TestCase):
    def setUp(self):
        self.text = CATALOG.read_text(encoding="utf-8")

    def test_all_thirty_supplied_sources_remain_clickable(self):
        self.assertEqual(len(REPOS), 30)
        for repo in REPOS:
            self.assertIn(f"](https://github.com/{repo})", self.text)

    def test_exactly_thirty_project_rows_have_purpose_and_status(self):
        rows = re.findall(r"^\| \[.*$", self.text, re.MULTILINE)
        self.assertEqual(len(rows), 30)
        for row in rows:
            self.assertEqual(row.count("|"), 4)
            self.assertTrue(all(part.strip() for part in row.split("|")[1:-1]))

    def test_redirects_keep_original_and_current_repositories(self):
        for before, after in (("nedbat/coveragepy", "coveragepy/coveragepy"),
                              ("encode/uvicorn", "Kludex/uvicorn"), ("facebook/react", "react/react")):
            self.assertIn("https://github.com/" + before, self.text)
            self.assertIn("https://github.com/" + after, self.text)

    def test_archived_action_is_not_presented_as_recommended_workflow(self):
        for phrase in ("23.01.2025", "Archiviert / deprecated", "Playwright-CLI",
                       "https://playwright.dev/docs/ci-intro", "nicht fuer neue Workflows verwenden"):
            self.assertIn(phrase, self.text)
        self.assertNotIn("uses: microsoft/playwright-github-action", self.text)

    def test_boundaries_and_cross_links_are_explicit(self):
        for phrase in ("nicht auf Manus-Quellcode", "Integration bedeutet nicht Installation",
                       "kein neuer Menue-Installer", "noch kein Setup-Installer", "pull_request_target",
                       "keine Sandbox", "NOASSERTION", "Pruefstand: **21.10.2026**"):
            self.assertIn(phrase, self.text)
        for path in ("docs/TOOL_INDEX.md", "docs/tutorials/manus-development-workflow.md"):
            self.assertIn("manus-development-sources.md", (ROOT / path).read_text(encoding="utf-8"))

    def test_local_document_links_resolve(self):
        for target in re.findall(r"\]\(([^)]+)\)", self.text):
            if "://" not in target and not target.startswith("#"):
                self.assertTrue((CATALOG.parent / target.split("#")[0]).is_file(), target)


if __name__ == "__main__":
    unittest.main()
