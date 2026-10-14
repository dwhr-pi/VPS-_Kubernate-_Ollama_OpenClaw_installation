"""Offline tests for the setup integration; no upstream runtime is imported."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import re
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("automaton_review", ROOT / "tools/automaton/review.py")
review = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(review)


class AutomatonTests(unittest.TestCase):
    def setUp(self):
        self.proposal = json.loads((ROOT / "examples/automaton/review-proposal.json").read_text())

    def invoke(self, args):
        stdout, stderr = io.StringIO(), io.StringIO()
        with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
            code = review.main(args)
        return code, stdout.getvalue(), stderr.getvalue()

    def test_valid_proposal_never_authorizes_execution(self):
        result = review.validate(self.proposal)
        self.assertFalse(result["approved_for_execution"])
        self.assertFalse(result["executed"])
        self.assertEqual(result["decision"], "manual_review_required")

    def test_write_signing_and_network_rejected(self):
        for flag in ("requires_network", "requires_signing", "requires_write"):
            with self.subTest(flag=flag), self.assertRaises(ValueError):
                review.validate({**self.proposal, flag: True})

    def test_string_false_is_not_false(self):
        with self.assertRaises(ValueError):
            review.validate({**self.proposal, "requires_signing": "false"})

    def test_turn_and_retry_limits(self):
        for field, value in (("max_turns", 11), ("max_turns", 0), ("max_turns", True),
                             ("retry_limit", 3), ("retry_limit", -1)):
            with self.subTest(field=field, value=value), self.assertRaises(ValueError):
                review.validate({**self.proposal, field: value})

    def test_no_generic_command_or_key_input(self):
        for extra in ({"command": "not-executed"}, {"private_key": "fixture-not-a-key"}):
            with self.assertRaises(ValueError):
                review.validate({**self.proposal, **extra})

    def test_trade_or_provisioning_rejected(self):
        for action in ("trade", "transfer", "sign", "spawn", "flash_firmware"):
            with self.subTest(action=action), self.assertRaises(ValueError):
                review.validate({**self.proposal, "action": action})

    def test_all_runtime_actions_blocked_no_home_created(self):
        with tempfile.TemporaryDirectory() as temp:
            home = Path(temp) / "isolated-home"
            with patch.dict(os.environ, {"HOME": str(home)}):
                for mode in ("install", "update", "uninstall", "repair", "run"):
                    self.assertEqual(self.invoke([mode])[0], 2)
            self.assertFalse(home.exists())

    def test_check_scope_does_not_claim_installed(self):
        for mode in ("plan", "status", "check", "doctor"):
            code, output, _ = self.invoke([mode])
            self.assertEqual(code, 0)
            result = json.loads(output)
            self.assertFalse(result["installed"])
            self.assertFalse(result["runtime_enabled"])
            self.assertEqual(result["check_scope"], "integration_assets_only")

    def test_cli_rejects_without_disclosing_contents(self):
        with tempfile.TemporaryDirectory() as temp:
            proposal = Path(temp) / "proposal.json"
            proposal.write_text('{"private_key":"fixture-do-not-print"}')
            code, out, err = self.invoke(["review", str(proposal)])
        self.assertEqual(code, 1)
        self.assertNotIn("fixture-do-not-print", out + err)

    def test_review_example(self):
        code, output, _ = self.invoke(["review", str(ROOT / "examples/automaton/review-proposal.json")])
        self.assertEqual(code, 0)
        self.assertFalse(json.loads(output)["executed"])

    def test_registry_and_menu(self):
        tools = json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"]
        tool, = [entry for entry in tools if entry["id"] == "automaton"]
        self.assertEqual(tool["status"], "planned")
        self.assertEqual(tool["risk"], "high")
        self.assertEqual(tool["source_commit"], review.SOURCE_COMMIT)
        self.assertEqual(tool["ports"], [])
        for key in ("install_script", "uninstall_script", "update_script", "doctor_script", "doc"):
            self.assertTrue((ROOT / tool[key]).is_file())
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('TOOL_KEYS+=("Automaton")', menu)
        self.assertIn('TOOL_SCRIPT_NAMES["Automaton"]="automaton"', menu)
        profiles = json.loads((ROOT / "config/profiles.yml").read_text(encoding="utf-8"))["profiles"]
        self.assertFalse(any("automaton" in entry.get("tools", []) for entry in profiles))

    def test_documentation_links(self):
        doc = ROOT / "docs/tools/automaton.md"
        for link in re.findall(r'\]\(([^)]+)\)', doc.read_text(encoding="utf-8")):
            if "://" not in link and not link.startswith("#"):
                self.assertTrue((doc.parent / link.split("#")[0]).exists(), link)


if __name__ == "__main__":
    unittest.main()
