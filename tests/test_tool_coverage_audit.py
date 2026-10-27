"""Offline coverage audit fixtures: no shell, network or installers executed."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("coverage_audit", ROOT / "scripts/audit_tool_coverage.py")
AUDIT = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(AUDIT)


class ToolCoverageAuditTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.write("setup_ultimate.sh", 'TOOL_KEYS=("Existing" "OnlyMenu")\n'
                   'TOOL_KEYS+=("Candidate")\n'
                   'TOOL_SCRIPT_NAMES["Existing"]="existing"\n'
                   'TOOL_SCRIPT_NAMES["OnlyMenu"]="only_menu"\n'
                   'TOOL_SCRIPT_NAMES["Candidate"]="hybrid_media_candidate"\n')
        self.write("config/tools.yml", json.dumps({"tools": [
            {"id": "existing", "name": "Existing", "source": "https://github.com/Acme/App.git",
             "install_script": "scripts/tools/existing_install.sh", "doc": "docs/example.md"},
            {"id": "candidate", "name": "Candidate",
             "install_script": "scripts/tools/hybrid_media_candidate_install.sh"},
            {"id": "registry_only", "install_script": "scripts/tools/missing_install.sh",
             "uninstall_script": "scripts/tools/missing_uninstall.sh", "doc": "docs/missing.md"},
        ]}))
        self.write("config/development_toolchains.json", json.dumps({"tools": [
            {"id": "library", "name": "Library", "source": "https://github.com/acme/library"},
            {"id": "no_recipe", "name": "No recipe"},
        ]}))
        self.write("config/development_installers.json", json.dumps({"recipes": {
            "library": {"mode": "existing", "scripts": {"install": "scripts/tools/existing_install.sh"}}
        }}))
        self.write("scripts/tools/existing_install.sh", "#!/bin/bash\nexit 1\n")
        self.write("scripts/tools/only_menu_install.sh", "# https://github.com/acme/menu-only\n")
        self.write("scripts/tools/hybrid_media_candidate_install.sh", "exit 1\n")
        self.write("docs/example.md", "[App](https://github.com/acme/app/blob/main/README.md)\n"
                   "https://github.com/acme/library\nhttps://github.com/acme/unmatched\n"
                   "https://github.com/acme/menu-only\nhttps://github.com/topics/ai\n")
        self.write(AUDIT.REPORT, "https://github.com/acme/should-not-be-counted\n")

    def write(self, path, content):
        target = self.root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content, encoding="utf-8")

    def test_registry_menu_and_missing_files_are_independent(self):
        data = AUDIT.audit(self.root)
        self.assertEqual(data["counts"]["registry_without_menu"], 1)
        self.assertEqual(data["counts"]["menu_without_registry"], 1)
        self.assertEqual(data["registry"][2]["missing_files"], ["install_script", "uninstall_script"])
        self.assertTrue(data["registry"][2]["doc_missing"])
        self.assertEqual(data["menu_only"][0]["name"], "OnlyMenu")

    def test_placeholder_never_counted_as_working_installation(self):
        data = AUDIT.audit(self.root)
        self.assertEqual(data["registry"][1]["script_state"], "Platzhalter")
        self.assertIn("Runtime ungeprueft", data["registry"][0]["script_state"])

    def test_sources_deduplicate_normalize_and_keep_provenance(self):
        data = AUDIT.audit(self.root)
        refs = {t["repo"]: t for t in data["documentation_repositories"]}
        self.assertEqual(set(refs), {"acme/app", "acme/library", "acme/unmatched", "acme/menu-only"})
        self.assertEqual(refs["acme/app"]["matches"], ["Registry: existing"])
        self.assertEqual(refs["acme/library"]["matches"], ["62er-Katalog: library"])
        self.assertEqual(refs["acme/menu-only"]["matches"], ["Menue: OnlyMenu"])
        self.assertEqual(refs["acme/unmatched"]["matches"], [])
        self.assertEqual(refs["acme/app"]["docs"], ["docs/example.md"])
        self.assertEqual(data["counts"]["docs"], 1)

    def test_bare_github_references_are_included_but_topics_are_not(self):
        self.assertEqual(AUDIT.repos("`github.com/Acme/App` https://github.com/Acme/App.git "
                                    "github.com/acme/other. https://github.com/topics/ai"),
                         {"acme/app", "acme/other"})

    def test_missing_recipe_and_duplicates_reported(self):
        data = AUDIT.audit(self.root)
        self.assertEqual(data["development_catalog"][1]["mode"], "Rezept fehlt")
        self.assertEqual(data["counts"]["chain_recipes"], 1)
        self.assertEqual(data["duplicate_registry_ids"], [])
        self.assertEqual(data["duplicate_menu_keys"], [])
        setup = self.root / "setup_ultimate.sh"
        setup.write_text(setup.read_text(encoding="utf-8") + 'TOOL_KEYS+=("Existing")\n', encoding="utf-8")
        self.assertEqual(AUDIT.audit(self.root)["duplicate_menu_keys"], ["Existing"])

    def test_report_deterministic_local_links_and_scope(self):
        data = AUDIT.audit(self.root)
        report = AUDIT.markdown(data)
        self.assertEqual(report, AUDIT.markdown(AUDIT.audit(self.root)))
        self.assertIn("[docs/example.md](example.md)", report)
        self.assertIn("keine automatische Liste fehlender Programme", report)
        self.assertIn("Skript vorhanden; Runtime ungeprueft", report)
        self.assertIn("Rezept fehlt", report)

    def test_read_only_scan_does_not_change_files(self):
        before = {p.relative_to(self.root): p.read_bytes() for p in self.root.rglob("*") if p.is_file()}
        AUDIT.audit(self.root)
        after = {p.relative_to(self.root): p.read_bytes() for p in self.root.rglob("*") if p.is_file()}
        self.assertEqual(before, after)

    def test_native_registration_adds_allowlisted_keys_without_duplicate_existing(self):
        setup = self.root / 'setup_ultimate.sh'
        setup.write_text(setup.read_text() + 'register_native_github_tool_keys\n', encoding='utf-8')
        self.write('scripts/helpers/native_github_menu.sh',
                   'NATIVE_GITHUB_TOOL_KEYS=("Existing" "Native")\n'
                   'NATIVE_GITHUB_TOOL_KEYS+=("Native" "Another")\n')
        names, _ = AUDIT.menu_inventory(setup.read_text(), self.root)
        self.assertEqual(names, ['Existing', 'OnlyMenu', 'Candidate', 'Native', 'Another'])
        self.assertEqual(AUDIT.audit(self.root)['counts']['menu'], 5)

    def test_unused_native_allowlist_does_not_change_menu_inventory(self):
        self.write('scripts/helpers/native_github_menu.sh', 'NATIVE_GITHUB_TOOL_KEYS=("NotRegistered")\n')
        names, _ = AUDIT.menu_inventory((self.root / 'setup_ultimate.sh').read_text(), self.root)
        self.assertNotIn('NotRegistered', names)

    def test_shell_expressions_are_not_menu_names_and_never_executed(self):
        text = 'TOOL_KEYS=("Safe" "$(touch never-execute)" "${DYNAMIC[@]}" "`id`")\n'
        self.assertEqual(AUDIT.menu_inventory(text)[0], ['Safe'])


if __name__ == "__main__":
    unittest.main()
