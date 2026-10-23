"""Offline metadata fixtures; no shells, runtimes, services, network or user data."""
from contextlib import redirect_stdout
import importlib.util
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("lifecycle_inventory", ROOT / "scripts/quality/lifecycle_inventory.py")
inventory = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(inventory)


class LifecycleInventoryTests(unittest.TestCase):
    def fixture(self, root, rows=None):
        (root / "config").mkdir()
        if rows is None:
            rows = [{"id": "ollama", "install_script": "install.sh"}]
        (root / "config/tools.yml").write_text(json.dumps({"tools": rows}), encoding="utf-8")
        (root / "install.sh").write_text("fixture", encoding="utf-8")

    def test_twenty_unique_real_registry_ids(self):
        self.assertEqual(len(inventory.TOP20), 20)
        self.assertEqual(len(set(inventory.TOP20)), 20)
        report = inventory.inventory()
        self.assertEqual([row["id"] for row in report["tools"]], list(inventory.TOP20))
        self.assertFalse(report["writes"])
        self.assertFalse(report["runtime_probes"])
        self.assertTrue(all(row["runtime_readiness"] == "not-tested" for row in report["tools"]))

    def test_inventory_preserves_file_names_and_contents(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self.fixture(root)
            before = {p.relative_to(root).as_posix(): p.read_bytes() for p in root.rglob("*") if p.is_file()}
            inventory.inventory(root, ("ollama",))
            after = {p.relative_to(root).as_posix(): p.read_bytes() for p in root.rglob("*") if p.is_file()}
            self.assertEqual(before, after)

    def test_missing_fields_are_not_runtime_success(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self.fixture(root)
            row = inventory.inventory(root, ("ollama",))["tools"][0]
            self.assertEqual(row["declared_status"], "not-declared")
            self.assertEqual(row["files"]["install_script"], "present")
            self.assertIn("doctor_script:not-mapped", row["gaps"])
            self.assertIn("source_commit:not-declared-in-registry", row["gaps"])
            self.assertEqual(row["runtime_readiness"], "not-tested")

    def test_stub_is_detected_even_when_file_exists(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self.fixture(root, [{"id": "ollama", "status": "planned", "install_script": "scripts/tools/planned_tool_stub_install.sh"}])
            stub = root / "scripts/tools/planned_tool_stub_install.sh"
            stub.parent.mkdir(parents=True)
            stub.write_text("fixture", encoding="utf-8")
            row = inventory.inventory(root, ("ollama",))["tools"][0]
            self.assertEqual(row["files"]["install_script"], "present")
            self.assertTrue(row["planned_stub"])
            self.assertIn("install:planned-stub", row["gaps"])

    def test_unsafe_paths_and_missing_files(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            for value in ("../escape", "/tmp/escape", "C:/escape", "folder\\escape", ["invalid"]):
                self.assertEqual(inventory.file_state(root, value), "unsafe-path")
            self.assertEqual(inventory.file_state(root, "absent.sh"), "missing-file")
            self.assertEqual(inventory.file_state(root, None), "not-mapped")

    def test_duplicate_unknown_and_malformed_registry_fail(self):
        for rows in ([], [{"id": "ollama"}, {"id": "ollama"}], ["invalid"], {}):
            with self.subTest(rows=rows), tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp)
                self.fixture(root, rows)
                with self.assertRaises(ValueError):
                    inventory.inventory(root, ("ollama",))

    def test_pin_and_complete_metadata_remain_unverified_runtime(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            row = {"id": "ollama", "status": "experimental", "source_commit": "a" * 40}
            row.update({field: "install.sh" for field in inventory.FIELDS})
            self.fixture(root, [row])
            result = inventory.inventory(root, ("ollama",))["tools"][0]
            self.assertEqual(result["gaps"], [])
            self.assertEqual(result["registry_source_commit"], "a" * 40)
            self.assertEqual(result["runtime_readiness"], "not-tested")

    def test_cli_dry_run_and_json_are_read_only(self):
        report = {"scope": "repository-metadata-only", "writes": False, "runtime_probes": False, "tools": []}
        with patch.object(inventory, "inventory", return_value=report), redirect_stdout(io.StringIO()) as output:
            self.assertEqual(inventory.main(["--dry-run", "--json"]), 0)
        self.assertEqual(json.loads(output.getvalue()), report)

    def test_strict_does_not_hide_metadata_gaps(self):
        with patch.object(inventory, "inventory", return_value={"tools": [{"gaps": ["fixture"]}]}), patch.object(inventory, "markdown", return_value="fixture"), redirect_stdout(io.StringIO()):
            self.assertEqual(inventory.main(["--strict"]), 1)
            self.assertEqual(inventory.main([]), 0)

    def test_grok_followup_is_discoverable_and_not_a_fake_installation(self):
        followup = "grok-repo-review-2026-10-23.md"
        for name in ("docs/tutorials/grok-development-tooling.md", "docs/MISSING_TOOLS_AND_PROFILES.md", "readme.md"):
            self.assertIn(followup, (ROOT / name).read_text(encoding="utf-8"))
        text = (ROOT / "docs/tutorials" / followup).read_text(encoding="utf-8")
        for state in ("already present", "planned", "recommend add", "reject"):
            self.assertIn(state, text)
        self.assertIn("20 fehlende Doctors/Updater", text)
        self.assertIn("nicht lokal installiert", text)
        self.assertIn("keine erneute externe", text)


if __name__ == "__main__":
    unittest.main()
