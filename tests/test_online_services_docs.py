"""Offline documentation checks; no SDK imports, keys, HTTP or cluster actions."""
import ast
from pathlib import Path
import re
import unittest
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[1]
DIRECTORY = ROOT / "docs/_API-Keys/OnlineOnKeyServices"


class OnlineServicesDocs(unittest.TestCase):
    def test_provider_tables_have_consistent_official_website_columns(self):
        documents = {
            "PROVIDER_KEY_CATALOG.md": 5,
            "FREE_TIERS_AND_TRIAL_CREDITS.md": 2,
            "API_KEY_GUIDE.md": 1,
            "OnlineOnKeyServices/README.md": 1,
        }
        for relative, expected_tables in documents.items():
            lines = (DIRECTORY.parent / relative).read_text(encoding="utf-8").splitlines()
            found = 0
            for index, header in enumerate(lines):
                if not header.startswith("|") or "Offizielle Webseite" not in header:
                    continue
                found += 1
                columns = [cell.strip() for cell in header.strip("|").split("|")]
                website_column = columns.index("Offizielle Webseite")
                for row in lines[index + 2:]:
                    if not row.startswith("|"):
                        break
                    cells = [cell.strip() for cell in row.strip("|").split("|")]
                    self.assertEqual(len(cells), len(columns), (relative, row))
                    website = cells[website_column]
                    links = re.findall(r"\]\(([^)]+)\)", website)
                    if not links:
                        self.assertIn("festgelegt", website, (relative, row))
                    for link in links:
                        parsed = urlsplit(link)
                        self.assertEqual(parsed.scheme, "https", link)
                        self.assertIsNone(parsed.username, link)
                        self.assertIsNone(parsed.password, link)
                        self.assertFalse(parsed.query, link)
                        self.assertNotIn(parsed.hostname, ("localhost", "127.0.0.1"), link)
            self.assertEqual(found, expected_tables, relative)

    def test_homepages_do_not_replace_warnings_or_api_credentials(self):
        catalog = (DIRECTORY.parent / "PROVIDER_KEY_CATALOG.md").read_text(encoding="utf-8")
        for term in ("https://openai.com/", "https://www.anthropic.com/", "https://ai.google.dev/",
                     "https://www.moonshot.ai/", "https://huggingface.co/", "https://openrouter.ai/"):
            self.assertIn(term, catalog)
        for label in ("EULLM", "AI Gateway", "OIDC"):
            row = next(line for line in catalog.splitlines()
                       if line.startswith('|') and line.split('|')[1].strip() == label)
            website = row.split("|")[2]
            self.assertNotIn("https://", website)
            self.assertIn("festgelegt", website)
        token = (DIRECTORY / "token8341.md").read_text(encoding="utf-8")
        self.assertIn("kein bestaetigter API-Endpunkt", " ".join(token.split()))
        self.assertIn("https://www.token8341.com/", token)
        router = (DIRECTORY / "openrouter.md").read_text(encoding="utf-8")
        self.assertIn("**Offizielle Webseite:**", router)
        self.assertIn("https://openrouter.ai/api/v1", router)

    def test_all_local_links_resolve(self):
        for doc in DIRECTORY.parent.rglob("*.md"):
            for target in re.findall(r"\]\(([^)]+)\)", doc.read_text(encoding="utf-8")):
                if "://" not in target and not target.startswith("#"):
                    self.assertTrue((doc.parent / target.split("#")[0]).exists(), (doc.name, target))

    def test_index_and_move(self):
        index = (ROOT / "docs/TOOL_INDEX.md").read_text(encoding="utf-8")
        self.assertFalse((ROOT / "docs/tools/token8341.md").exists())
        for name in ("README", "token8341", "openrouter"):
            self.assertFalse((ROOT / "docs/tools/OnlineServices" / (name + ".md")).exists())
        for name in ("README", "token8341", "openrouter"):
            self.assertTrue((DIRECTORY / (name + ".md")).is_file())
            self.assertIn("_API-Keys/OnlineOnKeyServices/" + name + ".md", index)
        self.assertNotIn("(tools/token8341.md)", index)

    def test_key_guide_moved_and_menu_updated(self):
        self.assertFalse((ROOT / "docs/API_KEY_GUIDE.md").exists())
        target = "docs/_API-Keys/API_KEY_GUIDE.md"
        self.assertTrue((ROOT / target).is_file())
        setup = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('$INSTALL_DIR/' + target, setup)
        self.assertNotIn('$INSTALL_DIR/docs/API_KEY_GUIDE.md', setup)

    def test_guide_headings_are_outside_code_blocks(self):
        guide = (DIRECTORY.parent / "API_KEY_GUIDE.md").read_text(encoding="utf-8")
        self.assertTrue(guide.startswith("# API-Key Guide"))
        inside = False
        headings = []
        for line in guide.splitlines():
            if line.startswith("```"):
                inside = not inside
            elif line.startswith("#") and not inside:
                headings.append(line)
        self.assertFalse(inside, "Unclosed fenced code block")
        for heading in ("## 1.", "## 2.", "## 3.", "### 3.3 Nginx Rate Limiting"):
            self.assertTrue(any(line.startswith(heading) for line in headings), heading)
        self.assertNotIn("sudo ufw allow 3000", guide)

    def test_catalog_covers_declared_template_credentials(self):
        catalog = (DIRECTORY.parent / "PROVIDER_KEY_CATALOG.md").read_text(encoding="utf-8")
        for path in (ROOT / ".env.example",
                     ROOT / "scripts/config_templates/openclaw/.env.template",
                     ROOT / "tools/websitefactory/.env.example"):
            text = path.read_text(encoding="utf-8")
            for name in re.findall(r"^\s*#?\s*([A-Z][A-Z0-9_]*)=", text, re.M):
                if any(part in name for part in ("KEY", "TOKEN", "SECRET", "PASSWORD")):
                    self.assertIn("`" + name + "`", catalog, (path.name, name))

    def test_purpose_before_status(self):
        for name in ("token8341", "openrouter"):
            text = (DIRECTORY / (name + ".md")).read_text(encoding="utf-8")
            self.assertLess(text.index("Sinn und Zweck"), text.index("Pruefstand"))
            self.assertIn("API-Schluessel", text[:600])

    def test_freellmapi_support_is_versioned_and_qualified(self):
        for name in ("token8341", "openrouter"):
            text = (DIRECTORY / (name + ".md")).read_text(encoding="utf-8")
            self.assertIn("## Verwendung in FreeLLMAPI", text)
            self.assertIn("57c0669233bbe0c70a0f9f9927613192be948773", text)
            self.assertIn("http://127.0.0.1:3011/v1", text)
            self.assertIn("Unified Key", text)
        token = (DIRECTORY / "token8341.md").read_text(encoding="utf-8")
        router = (DIRECTORY / "openrouter.md").read_text(encoding="utf-8")
        self.assertIn("Custom (OpenAI-compatible)", token)
        self.assertIn("kein eigener", token)
        self.assertIn("bereits eingebaut", router)
        self.assertIn("kein Live-Nachweis", router)
        self.assertIn("nicht gratis", router)
        self.assertIn("echte Chat-Anfrage", token)
        main = (ROOT / "docs/tools/freellmapi.md").read_text(encoding="utf-8")
        self.assertIn("[OnlineOnKeyServices](../_API-Keys/OnlineOnKeyServices/README.md)", main)
        for name in ("token8341", "openrouter"):
            self.assertNotIn("../_API-Keys/OnlineOnKeyServices/" + name + ".md", main)

    def test_freellmapi_links_both_key_overviews(self):
        doc = ROOT / "docs/tools/freellmapi.md"
        text = doc.read_text(encoding="utf-8")
        for target in ("../_API-Keys/README.md", "../_API-Keys/OnlineOnKeyServices/README.md"):
            self.assertIn("](" + target + ")", text)
            self.assertTrue((doc.parent / target).is_file())
        overview = (DIRECTORY.parent / "README.md").read_text(encoding="utf-8")
        self.assertIn("keine echten Schluessel", overview)
        self.assertIn("ENV-Tresor", overview)

    def test_openrouter_examples_are_not_executed_or_enabled(self):
        text = (DIRECTORY / "openrouter.md").read_text(encoding="utf-8")
        code, = re.findall(r"```python\n(.*?)\n```", text, re.S)
        tree = ast.parse(code)
        self.assertIn('timeout=30.0, max_retries=0', code)
        self.assertNotIn('os.environ["OPENAI_API_KEY"]', code)
        self.assertFalse(any(isinstance(n, ast.Call) and isinstance(n.func, ast.Attribute)
                             and n.func.attr == "create" for n in ast.walk(tree)))
        env, = re.findall(r"```dotenv\n(.*?)\n```", text, re.S)
        values = dict(line.split("=", 1) for line in env.splitlines())
        self.assertEqual(values["OPENROUTER_API_KEY"], "")
        self.assertEqual(values["OPENROUTER_ALLOW_CLOUD"], "0")
        self.assertIn('secretKeyRef:', text)
        self.assertIn('value: "0"', text)


if __name__ == "__main__":
    unittest.main()
