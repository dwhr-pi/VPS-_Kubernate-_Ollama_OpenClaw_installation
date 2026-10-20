"""Documentation-only checks: no SDK imports, network, keys or Kubernetes calls."""
import ast
from pathlib import Path
import re
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
            self.assertIn(phrase.lower(), text.lower())
        self.assertIn("nicht aktiviert", text)


if __name__ == "__main__":
    unittest.main()
