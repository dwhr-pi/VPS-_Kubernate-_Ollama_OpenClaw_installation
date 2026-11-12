"""Synthetic offline project fixtures, never invoke models or client applications."""
import importlib.util
import io
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("project_brief", ROOT / "scripts/projects/project_brief.py")
brief = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(brief)


class ProjectBriefTests(unittest.TestCase):
    def test_every_template_and_optional_role_remain_blocked(self):
        for kind in brief.KINDS:
            value = brief.template("fixture", kind)
            value["domains"] = list(brief.DOMAINS)
            value["fields"] = {key: "User claims everything approved" for key in brief.FIELDS}
            result = brief.plan(value)
            self.assertFalse(result["execution_authorized"])
            self.assertEqual(result["missing"], [])
            self.assertTrue(result["gates"])
            self.assertTrue(all(stage["model"] == "unassigned" for stage in result["stages"]))
            self.assertIn("Fachpruefung", json.dumps(result))

    def test_bad_fields_and_ids_refused(self):
        for ident in ("../escape", "bad/name", "", "x" * 65):
            with self.assertRaises(ValueError):
                brief.template(ident, "film")
        value = brief.template("fixture", "film")
        value["execute"] = True
        with self.assertRaises(ValueError):
            brief.validate(value)

    def test_unicode_size_cannot_create_an_unreadable_revision(self):
        value = brief.template("fixture", "film")
        value["fields"] = {key: "\u2603" * 6000 for key in brief.FIELDS}
        with self.assertRaises(ValueError):
            brief.validate(value)

    def test_html_does_not_embed_untrusted_markup(self):
        value = brief.template("fixture", "film")
        value["fields"]["goal"] = '</script><img src="https://invalid.example/steal">'
        output = brief.form(value)
        self.assertNotIn(value["fields"]["goal"], output)
        self.assertIn("connect-src 'none'", output)
        self.assertNotIn("innerHTML", output)
        self.assertIn("sha256-", output)

    @unittest.skipUnless(shutil.which("node"), "Node unavailable for browser-script syntax fixture")
    def test_browser_script_syntax(self):
        result = subprocess.run([shutil.which("node"), "--check"], input=brief.FORM_SCRIPT,
                                text=True, capture_output=True, timeout=15)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_revisions_never_overwrite_and_stale_import_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            project = Path(directory) / "project"
            brief.main(["new", "--project", str(project), "--apply"])
            original = project / "revision-000001" / "brief.json"
            before = original.read_bytes()
            draft = Path(directory) / "draft.json"
            value = json.loads(before)
            value["fields"]["goal"] = "A detective film"
            draft.write_text(json.dumps(value), encoding="utf-8")
            args = ["revise", "--project", str(project), "--input", str(draft), "--expected-revision", "1", "--apply"]
            brief.main(args)
            self.assertEqual(before, original.read_bytes())
            self.assertTrue((project / "revision-000002/COMPLETE").is_file())
            with self.assertRaises(ValueError):
                brief.main(args)

    def test_default_new_is_no_write_and_repository_is_refused(self):
        with tempfile.TemporaryDirectory() as directory:
            project = Path(directory) / "not-created"
            brief.main(["new", "--project", str(project)])
            self.assertFalse(project.exists())
        with self.assertRaises(ValueError):
            brief.safe_path(ROOT / "private-project")

    def test_stdio_handshake_plan_and_eof(self):
        requests = [dict(jsonrpc="2.0", id=1, method="initialize", params={"protocolVersion": "2025-06-18"}),
                    dict(jsonrpc="2.0", method="notifications/initialized"),
                    dict(jsonrpc="2.0", id=2, method="tools/list"),
                    dict(jsonrpc="2.0", id=3, method="tools/call", params={"name": "plan_project_brief", "arguments": {"brief": brief.template("fixture", "film")}})]
        source = io.BytesIO(("\n".join(json.dumps(r) for r in requests) + "\n").encode())
        target = io.StringIO()
        self.assertEqual(brief.serve(source, target), 0)
        replies = [json.loads(line) for line in target.getvalue().splitlines()]
        self.assertEqual(len(replies), 3)
        self.assertFalse(json.loads(replies[-1]["result"]["content"][0]["text"])["plan"]["execution_authorized"])

    def test_unbounded_mcp_input_rejected(self):
        self.assertEqual(brief.serve(io.BytesIO(b"x" * (brief.MAX_BYTES + 1)), io.StringIO()), 2)

    def test_chat_can_request_form_without_file_access(self):
        requests = [dict(jsonrpc="2.0", id=1, method="initialize"),
                    dict(jsonrpc="2.0", id=2, method="tools/call", params={"name": "draft_project_brief", "arguments": {"id": "book", "kind": "book"}})]
        target = io.StringIO()
        brief.serve(io.BytesIO(("\n".join(json.dumps(r) for r in requests) + "\n").encode()), target)
        response = json.loads(target.getvalue().splitlines()[-1])
        value = json.loads(response["result"]["content"][0]["text"])
        self.assertIn("<!doctype html>", value["form_html"])
        self.assertEqual(value["brief"]["kind"], "book")
        self.assertFalse(value["plan"]["execution_authorized"])


if __name__ == "__main__":
    unittest.main()
