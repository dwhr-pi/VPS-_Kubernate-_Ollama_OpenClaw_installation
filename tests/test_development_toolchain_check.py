"""Offline-only preflight tests: no installation, tool execution, network or WSL."""
from contextlib import redirect_stdout
import importlib.util
import io
import json
import os
from pathlib import Path
import re
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("development_toolchains", ROOT / "scripts/quality/development_toolchains.py")
check = importlib.util.module_from_spec(spec)
spec.loader.exec_module(check)


class DevelopmentToolchainCheckTests(unittest.TestCase):
    def setUp(self):
        self.rows = check.load_catalog()
        self.registry = json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"]
        self.budget = {"disk_mb": 999999, "ram_mb": 99999, "windows_c_mb": None, "wsl_detected": False}

    def row(self, key):
        return next(row for row in self.rows if row["id"] == key)

    def inspect(self, key, available=lambda name: True):
        return check.inspect(self.row(key), self.registry, self.budget, available)

    def test_exactly_62_unique_sources_in_ten_groups(self):
        self.assertEqual(len(self.rows), 62)
        self.assertEqual(len({row["repo"] for row in self.rows}), 62)
        self.assertEqual(len({row["group"] for row in self.rows}), 10)
        doc = (ROOT / "docs/tutorials/manus-language-infrastructure-sources.md").read_text(encoding="utf-8")
        for row in self.rows:
            self.assertIn("](https://github.com/" + row["repo"] + ")", doc)

    def test_reviewed_adapters_only_ever_promise_preflight(self):
        for key in check.REVIEWED:
            with mock.patch.object(check.sys, "version_info", (3, 12)), \
                    mock.patch.object(check.importlib.util, "find_spec", return_value=object()):
                result = self.inspect(key)
            self.assertEqual(result["status"], "preflight-ok")
            self.assertTrue(result["can_attempt_setup"])
            self.assertFalse(result["installation_tested"])

    def test_missing_prerequisite_blocks_sqlfluff(self):
        result = self.inspect("sqlfluff", available=lambda name: False)
        self.assertEqual(result["status"], "blocked")
        self.assertIn("git", result["missing"])

    def test_no_adapter_does_not_become_installable_when_all_commands_exist(self):
        result = self.inspect("delve")
        self.assertEqual(result["status"], "no-installer")
        self.assertFalse(result["can_attempt_setup"])
        self.assertIsNone(result["adapter"])

    def test_existing_legacy_adapter_is_not_declared_verified(self):
        result = self.inspect("helm")
        self.assertEqual(result["status"], "registered-review")
        self.assertFalse(result["can_attempt_setup"])
        self.assertIsNotNone(result["adapter"])

    def test_project_workflow_extension_are_not_global_programs(self):
        for key, kind in (("googletest", "project"), ("actions_checkout", "workflow"), ("vs_code_powershell", "extension")):
            self.assertEqual(self.inspect(key)["status"], kind)
            self.assertFalse(self.inspect(key)["can_attempt_setup"])

    def test_low_disk_ram_and_windows_host_are_visible(self):
        self.budget.update(disk_mb=1, ram_mb=1, windows_c_mb=1, wsl_detected=True)
        result = self.inspect("bats_core")
        self.assertEqual(result["status"], "blocked")
        self.assertEqual(len(result["blockers"]), 3)
        self.assertTrue(any("VHDX" in text for text in result["warnings"]))

    def test_missing_ensurepip_and_wrong_python_are_not_hidden(self):
        with mock.patch.object(check.sys, "version_info", (3, 14)), \
                mock.patch.object(check.importlib.util, "find_spec", return_value=None):
            result = self.inspect("sqlfluff")
        self.assertEqual(result["status"], "blocked")
        self.assertTrue(any("ensurepip" in reason for reason in result["blockers"]))
        self.assertTrue(any("3.10-3.13" in reason for reason in result["blockers"]))

    def test_report_caches_path_checks_without_executing_tools(self):
        with mock.patch.object(check, "executable_present", return_value=True) as present:
            result = check.report(self.rows, self.budget, self.registry)
        names = [call.args[0] for call in present.call_args_list]
        self.assertEqual(len(names), len(set(names)))
        self.assertFalse(result["network_accessed"])
        self.assertFalse(result["installed"])
        self.assertEqual(sum(result["counts"].values()), 62)
        self.assertNotIn("subprocess", check.__dict__)

    def test_list_json_and_strict_do_not_create_user_workspace(self):
        with tempfile.TemporaryDirectory() as folder:
            target = Path(folder) / "not-created"
            with mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(target)), \
                    mock.patch.object(check, "resources", return_value=self.budget), \
                    mock.patch.object(check, "executable_present", return_value=False):
                for args in (("--list",), ("--json", "--tool", "delve"), ("--tool", "delve", "--strict")):
                    out = io.StringIO()
                    with redirect_stdout(out):
                        rc = check.main(args)
                    self.assertEqual(rc, int("--strict" in args))
                    if "--json" in args:
                        self.assertEqual(json.loads(out.getvalue())["scope"], "offline-preflight")
            self.assertFalse(target.exists())

    def test_invalid_selection_is_error_not_empty_success(self):
        with mock.patch.object(sys, "stderr", io.StringIO()), self.assertRaises(SystemExit) as error:
            check.main(["--tool", "not-a-tool"])
        self.assertEqual(error.exception.code, 2)

    def test_placeholder_is_not_a_real_adapter(self):
        entry = {"id": "delve", "registry_id": "fixture"}
        registry = [{"id": "fixture", "install_script": "scripts/tools/planned_tool_stub_install.sh"}]
        self.assertIsNone(check.adapter_for(entry, registry))

    def test_setup_has_explicit_paths_and_button_never_processes_tool_selection(self):
        setup = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('"16" "62 Werkzeugquellen: Installationsvoraussetzungen pruefen"', setup)
        self.assertIn('--extra-label "62 Quellen pruefen"', setup)
        branch = setup.split('if [ "$tool_dialog_rc" -eq 3 ]; then', 1)[1].split("fi", 1)[0]
        self.assertIn("show_development_toolchain_check", branch)
        self.assertIn("return 0", branch)
        self.assertNotIn("run_ordered_tool_actions", branch)
        wrapper = (ROOT / "scripts/check_development_toolchains.sh").read_text()
        self.assertIn('development_toolchains.py" "$@"', wrapper)

    def test_overviews_and_presentation_are_discoverable(self):
        for name in ("docs/TOOLS_CATALOG.md", "docs/TOOL_MATRIX.md", "docs/TOOL_INDEX.md", "README.md"):
            text = (ROOT / name).read_text(encoding="utf-8")
            self.assertIn("development-toolchain-check.md", text)
            self.assertIn("technology-tooling-overview.pptx", text)
        doc = ROOT / "docs/tools/development-toolchain-check.md"
        content = doc.read_text(encoding="utf-8")
        self.assertIn("13 Folien", content)
        for target in re.findall(r"\]\(([^)]+)\)", content):
            if "://" not in target and not target.startswith("#"):
                self.assertTrue((doc.parent / target.split("#")[0]).exists(), target)


if __name__ == "__main__":
    unittest.main()
