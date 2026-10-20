"""Repository fixtures only; audit must not import project code or contact services."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("repository_audit", ROOT / "scripts/quality/repository_audit.py")
audit = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(audit)


class RepositoryAudit(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.root = Path(tmp.name)
        (self.root / "config").mkdir()
        (self.root / "docs").mkdir()
        for file in ("install.sh", "uninstall.sh", "docs/tool.md"):
            (self.root / file).write_text("fixture\n", encoding="utf-8")
        self.tool = {"id": "example", "status": "planned", "auto_install": False,
                     "install_script": "install.sh", "uninstall_script": "uninstall.sh",
                     "doc": "docs/tool.md", "check_type": "path", "check_value": "marker"}
        self.profile = {"id": "Example", "status": "planned", "doc": "docs/tool.md", "tools": ["example"]}

    def check(self, tools=None, profiles=None, ports=None):
        for key, rows in (("tools", tools if tools is not None else [self.tool]),
                          ("profiles", profiles if profiles is not None else [self.profile]),
                          ("ports", ports if ports is not None else [{"port": 1234}])):
            (self.root / "config" / (key + ".yml")).write_text(json.dumps({key: rows}), encoding="utf-8")
        result = audit.Audit(self.root)
        result.registry()
        return result.result()

    def test_minimal_registry_and_legacy_hints(self):
        result = self.check()
        self.assertEqual(result["errors"], 0)
        self.assertEqual(result["issue_counts"]["missing-doctor_script"], 1)

    def test_duplicate_ids_fail(self):
        self.assertIn("duplicate-id", self.check(tools=[self.tool, self.tool])["issue_counts"])

    def test_invalid_status_and_boolean_fail_without_crash(self):
        self.tool.update(status=[], auto_install="false")
        result = self.check()["issue_counts"]
        self.assertIn("invalid-status", result)
        self.assertIn("invalid-auto-install", result)

    def test_unknown_and_malformed_references(self):
        self.profile["tools"] = ["unknown"]
        self.assertIn("unknown-tool-reference", self.check()["issue_counts"])
        self.profile["tools"] = "example"
        self.assertIn("invalid-tool-references", self.check()["issue_counts"])

    def test_invalid_ports_and_duplicates(self):
        for value in (True, 0, 65536, "1234"):
            self.assertIn("invalid-port", self.check(ports=[{"port": value}])["issue_counts"])
        self.assertIn("duplicate-port", self.check(ports=[{"port": 5}, {"port": 5}])["issue_counts"])

    def test_paths_cannot_escape_and_directories_are_not_scripts(self):
        self.tool["install_script"] = "../outside.sh"
        self.assertIn("unsafe-path", self.check()["issue_counts"])
        self.tool["install_script"] = "docs"
        self.assertIn("missing-file", self.check()["issue_counts"])

    def test_source_scope_and_pin(self):
        self.tool.update(install_mode="github-source-only", auto_install=True,
                         ports=[1234], source_commit="main")
        result = self.check()["issue_counts"]
        self.assertIn("invalid-source-pin", result)
        self.assertIn("source-only-policy", result)

    def test_credential_values_are_never_reported(self):
        self.tool["source"] = "https://user:DO_NOT_REPORT@example.org/project"
        result = self.check()
        self.assertIn("credential-in-source-url", result["issue_counts"])
        self.assertNotIn("DO_NOT_REPORT", json.dumps(result))

    def test_parse_errors_do_not_echo_content(self):
        self.check()
        (self.root / "config/tools.yml").write_text("DO_NOT_REPORT", encoding="utf-8")
        result = audit.Audit(self.root)
        result.registry()
        self.assertIn("invalid-registry", result.result()["issue_counts"])
        self.assertNotIn("DO_NOT_REPORT", json.dumps(result.result()))

    def test_links_ignore_code_urls_and_anchors(self):
        (self.root / "readme.md").write_text(
            "[good](docs/tool.md) [web](https://example.org) [anchor](#x)\n"
            "```md\n[example](missing.md)\n```\n`[example](missing.md)`\n", encoding="utf-8")
        result = audit.Audit(self.root)
        result.links()
        self.assertEqual(result.issues, [])

    def test_link_case_and_missing_and_fences(self):
        (self.root / "readme.md").write_text(
            "[case](docs/TOOL.md) [missing](absent.md)\n```\nunclosed\n", encoding="utf-8")
        result = audit.Audit(self.root)
        result.links()
        codes = result.result()["issue_counts"]
        for code in ("link-case-mismatch", "missing-local-link", "unclosed-code-fence"):
            self.assertIn(code, codes)

    def test_python_parse_never_executes(self):
        (self.root / "sample.py").write_text("raise RuntimeError('must not execute')\n", encoding="utf-8")
        result = audit.Audit(self.root)
        result.code()
        self.assertEqual(result.result()["errors"], 0)
        (self.root / "sample.py").write_text("def broken(:", encoding="utf-8")
        result.code()
        self.assertIn("python-syntax-or-encoding", result.result()["issue_counts"])

    def test_personal_windows_links_are_not_treated_as_web_urls(self):
        (self.root / "readme.md").write_text("[a](C:/Users/example/a.md) [b](/C:/Users/example/b.md)\n", encoding="utf-8")
        result = audit.Audit(self.root)
        result.links()
        self.assertEqual(result.result()["issue_counts"]["nonportable-local-link"], 2)


if __name__ == "__main__":
    unittest.main()
