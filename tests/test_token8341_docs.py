"""Documentation-only checks: no SDK imports, network, keys or Kubernetes calls."""
import ast
from pathlib import Path
import re
from doc_assertions import assert_prose_in, assert_prose_not_in
import unittest

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs/_API-Keys/OnlineOnKeyServices/token8341.md"


class Token8341Docs(unittest.TestCase):
    def test_local_links_and_index(self):
        text = DOC.read_text(encoding="utf-8")
        for target in re.findall(r"\]\(([^)]+)\)", text):
            if "://" not in target and not target.startswith("#"):
                self.assertTrue((DOC.parent / target.split("#")[0]).is_file(), target)
        self.assertIn("_API-Keys/OnlineOnKeyServices/token8341.md", (ROOT / "docs/TOOL_INDEX.md").read_text(encoding="utf-8"))

    def test_python_example_syntax_without_execution(self):
        examples = re.findall(r"```python\n(.*?)\n```", DOC.read_text(encoding="utf-8"), re.S)
        self.assertEqual(len(examples), 1)
        tree = ast.parse(examples[0])
        self.assertIn('timeout=30.0, max_retries=0', examples[0])
        self.assertIn('TOKEN8341_ALLOW_CLOUD', examples[0])
        self.assertIn('http_client=DefaultHttpx2Client(follow_redirects=False)', examples[0])
        self.assertNotIn('os.environ["OPENAI_API_KEY"]', examples[0])
        calls = [node.func.attr for node in ast.walk(tree)
                 if isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute)]
        self.assertNotIn("create", calls)

    def test_examples_keep_secrets_empty_and_cloud_disabled(self):
        text = DOC.read_text(encoding="utf-8")
        env, = re.findall(r"```dotenv\n(.*?)\n```", text, re.S)
        values = dict(line.split("=", 1) for line in env.splitlines())
        self.assertEqual(values["TOKEN8341_API_KEY"], "")
        self.assertEqual(values["TOKEN8341_ALLOW_CLOUD"], "0")
        self.assertIn("secretKeyRef:", text)
        self.assertIn('value: "0"', text)
        self.assertNotIn("sk-", text)

    def test_unverified_claims_and_legal_limits_are_visible(self):
        text = DOC.read_text(encoding="utf-8")
        for phrase in ("Widerspruch", "Upstream", "keine Empfehlung",
                       "keine zutreffende pauschale Rechtsbewertung", "keine geprueften"):
            assert_prose_in(self, phrase.lower(), text.lower())
        assert_prose_in(self, "nicht aktiviert", text)

    def test_research_distinguishes_evidence_from_unverified_community_claims(self):
        text = DOC.read_text(encoding="utf-8")
        for phrase in ("## Recherche und Quellenbewertung", "keine konkret pruefbaren Reddit-",
                       "Unser eigenes Repository", "nicht belegt", "kein gemessener token8341-Vorfall",
                       "Unabhaengigkeit nicht verifiziert", "kein Nachweis eines Ausfalls"):
            assert_prose_in(self, phrase, text)
        for source in ("https://developer.cloud.tencent.com/article/2695833",
                       "https://blog.51cto.com/u_12227/14914057",
                       "https://www.scamadviser.com/check-website/token8341.com",
                       "https://token8341.com/fa/terms"):
            assert_prose_in(self, "](" + source + ")", text)

    def test_host_uncertainty_does_not_enable_cloud_or_automatic_fallback(self):
        text = DOC.read_text(encoding="utf-8")
        assert_prose_in(self, "TOKEN8341_ALLOW_CLOUD=0", text)
        assert_prose_in(self, "Keine Keys auf Hosts verteilen", text)
        assert_prose_in(self, "Host-Allowlist und Redirect-Sperre", text)
        assert_prose_in(self, "www.token8341.com/v1", text)
        assert_prose_in(self, "api.token8341.com/v1", text)


if __name__ == "__main__":
    unittest.main()
