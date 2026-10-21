"""Synthetic read-only legal/RAG tests. No databases, cloud, models or WSL."""
from contextlib import redirect_stderr, redirect_stdout
from copy import deepcopy
from datetime import date
import importlib.util
import io
import json
from pathlib import Path
import re
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("rag_compliance_review", ROOT / "tools/rag_compliance/review.py")
review = importlib.util.module_from_spec(spec)
spec.loader.exec_module(review)
EXAMPLES = ROOT / "tools/rag_compliance/examples"


class RAGComplianceReviewTests(unittest.TestCase):
    def example(self, name):
        return review.load_json(EXAMPLES / (name + ".json"))

    def test_worldwide_coverage_is_195_entries_not_195_completed_legal_reviews(self):
        coverage = review.load_json(ROOT / "config/legal/country_coverage.json")
        rows = coverage["countries"]
        self.assertEqual(len(rows), 195)
        self.assertEqual(len({row["name"] for row in rows}), 195)
        self.assertEqual(sum(row["un_status"] == "member" for row in rows), 193)
        self.assertEqual(sum(row["un_status"] == "observer" for row in rows), 2)
        self.assertTrue(all(row["legal_review"] == "not_reviewed" for row in rows))
        self.assertFalse(coverage["national_law_review_complete"])
        text = (ROOT / "docs/legal/COUNTRY_COVERAGE.md").read_text(encoding="utf-8")
        for row in rows:
            self.assertIn("| " + row["name"] + " |", text)

    def test_doctor_never_gives_legal_approval(self):
        result = review.source_review(date(2026, 10, 21))
        self.assertFalse(result["legal_approval"])
        self.assertFalse(result["network_accessed"])
        self.assertEqual(result["unreviewed_country_entries"], 195)
        self.assertGreater(result["open_reviews"], 0)
        blocked = next(row for row in result["sources"] if row["id"] == "gdpr")
        self.assertEqual(blocked["review_state"], "review-required")

    def test_review_age_is_overdue_at_30_days_and_future_dates_not_fresh(self):
        old = review.source_review(date(2026, 11, 20))
        future = review.source_review(date(2026, 10, 20))
        self.assertEqual(next(row for row in old["sources"] if row["id"] == "eu_ai_act")["review_state"], "overdue")
        self.assertEqual(next(row for row in future["sources"] if row["id"] == "eu_ai_act")["review_state"], "invalid-future-date")

    def test_voluntary_frameworks_and_historical_bills_are_not_laws(self):
        sources = review.load_json(ROOT / "config/legal/sources.json")["sources"]
        by_id = {row["id"]: row for row in sources}
        self.assertEqual(by_id["nist_ai_rmf"]["kind"], "voluntary-framework")
        self.assertEqual(by_id["ca_aida_44_1"]["kind"], "historical-bill")
        self.assertEqual(by_id["ca_aida_44_1"]["status"], "search-only")
        self.assertEqual(by_id["us_colorado_admt"]["kind"], "law")
        self.assertTrue(all(row["url"].startswith("https://") for row in sources))

    def test_rag_assessment_names_missing_evidence_without_releasing_execution(self):
        result = review.assess(self.example("scenario"))
        self.assertIn("lawful_basis_reviewed", result["missing_control_evidence"])
        self.assertIn("backup_retention_plan", result["missing_control_evidence"])
        self.assertFalse(result["execution_permitted"])
        self.assertFalse(result["legal_approval"])

    def test_all_checked_boxes_still_require_human_review(self):
        data = self.example("scenario")
        data["controls"] = {key: True for key in review.CONTROLS}
        result = review.assess(data)
        self.assertEqual(result["missing_control_evidence"], [])
        self.assertEqual(result["decision"], "human-review-required")
        self.assertFalse(result["legal_approval"])

    def test_unknown_jurisdiction_is_visible_without_echoing_input(self):
        data = self.example("scenario")
        data["jurisdictions"] = ["unknown-PII-example"]
        result = review.assess(data)
        self.assertEqual(result["unknown_jurisdiction_count"], 1)
        self.assertNotIn("unknown-PII-example", json.dumps(result))

    def test_schema_rejects_free_text_pii_and_non_boolean_control_values(self):
        data = self.example("scenario")
        data["raw_document"] = "private fixture"
        with self.assertRaises(ValueError):
            review.assess(data)
        data = self.example("scenario")
        data["controls"]["human_approval"] = "yes"
        with self.assertRaises(ValueError):
            review.assess(data)

    def test_external_employment_and_media_features_raise_review_topics(self):
        data = self.example("scenario")
        data["features"] = {key: True for key in review.FEATURES}
        result = review.assess(data)
        self.assertIn("transfer_review", result["missing_control_evidence"])
        self.assertIn("license_review", result["missing_control_evidence"])
        self.assertIn("transparency_review", result["missing_control_evidence"])
        self.assertIn("automated-decisions-and-ai-risk-classification-review", result["review_topics"])

    def test_deletion_is_always_a_plan_respecting_holds_and_missing_stores(self):
        result = review.deletion_plan(self.example("deletion-plan"))
        self.assertEqual(result["deletions_executed"], 0)
        self.assertFalse(result["execution_permitted"])
        self.assertEqual(result["held_or_unreviewed_items"], 1)
        self.assertNotIn("backups", result["proposed_counts_subject_to_review"])
        self.assertIn("exports", result["missing_store_reviews"])

    def test_deletion_rejects_duplicate_stores_negative_and_bool_counts(self):
        for value in (-1, True):
            data = self.example("deletion-plan")
            data["stores"][0]["items"] = value
            with self.assertRaises(ValueError):
                review.deletion_plan(data)
        data = self.example("deletion-plan")
        data["stores"].append(deepcopy(data["stores"][0]))
        with self.assertRaises(ValueError):
            review.deletion_plan(data)

    def test_audit_fixture_is_consistent_but_not_authenticated(self):
        result = review.audit_check(self.example("audit"))
        self.assertEqual(result["status"], "consistent")
        self.assertFalse(result["authenticity_verified"])
        self.assertFalse(result["legal_approval"])
        self.assertFalse(result["tail_truncation_checked_against_supplied_values"])

    def test_audit_payload_and_timestamp_tampering_are_detected(self):
        for key, value in (("vectors", 999), ("occurred_at", "2026-10-20T08:00:00Z")):
            data = self.example("audit")
            data["records"][0][key] = value
            self.assertEqual(review.audit_check(data)["status"], "inconsistent")

    def test_audit_tail_removal_needs_an_independent_comparison(self):
        original = self.example("audit")
        shortened = deepcopy(original)
        shortened["records"].pop()
        self.assertEqual(review.audit_check(shortened)["status"], "consistent")
        result = review.audit_check(shortened, original["records"][-1]["record_hash"], len(original["records"]))
        self.assertEqual(result["status"], "anchor-mismatch")
        self.assertFalse(result["authenticity_verified"])

    def test_rehashing_is_not_an_authenticity_proof(self):
        original = self.example("audit")
        changed = deepcopy(original)
        changed["records"][0]["documents"] = 99
        previous = "0" * 64
        for row in changed["records"]:
            row["previous_hash"] = previous
            row["record_hash"] = review.record_hash(row)
            previous = row["record_hash"]
        self.assertEqual(review.audit_check(changed)["status"], "consistent")
        self.assertEqual(review.audit_check(changed, original["records"][-1]["record_hash"], 2)["status"], "anchor-mismatch")

    def test_canonical_hash_is_independent_of_mapping_insertion_order(self):
        row = self.example("audit")["records"][0]
        self.assertEqual(review.record_hash(row), review.record_hash(dict(reversed(list(row.items())))))

    def test_unknown_audit_fields_and_partial_anchor_are_rejected(self):
        data = self.example("audit")
        with self.assertRaises(ValueError):
            review.audit_check(data, "0" * 64)
        data["records"][0]["personal_data"] = "private fixture"
        with self.assertRaises(ValueError):
            review.audit_check(data)

    def test_empty_audit_without_anchor_is_not_reported_consistent(self):
        result = review.audit_check({"schema_version": 1, "records": []})
        self.assertEqual(result["status"], "no-records")
        self.assertFalse(result["legal_approval"])

    def test_duplicate_json_fields_and_nonstandard_numbers_are_rejected(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / "ambiguous.json"
            for raw in ('{"approved":false,"approved":true}', '{"value":NaN}'):
                path.write_text(raw, encoding="utf-8")
                with self.assertRaises(ValueError):
                    review.load_json(path)

    def test_file_size_limit_and_read_only_cli(self):
        with tempfile.TemporaryDirectory() as folder:
            oversized = Path(folder) / "oversized.json"
            oversized.write_bytes(b"x" * (review.MAX_BYTES + 1))
            with self.assertRaises(ValueError):
                review.load_json(oversized)
        path = EXAMPLES / "audit.json"
        before = path.read_bytes()
        output = io.StringIO()
        with redirect_stdout(output), redirect_stderr(io.StringIO()):
            self.assertEqual(review.main(["audit-check", str(path)]), 0)
            self.assertEqual(review.main(["doctor", "--as-of", "2026-10-21", "--strict"]), 1)
        self.assertEqual(path.read_bytes(), before)
        self.assertNotIn("subprocess", review.__dict__)
        self.assertNotIn("requests", review.__dict__)

    def test_menu_wrapper_docs_and_profiles_link_to_review_without_install(self):
        setup = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('"18" "Recht und RAG-Compliance: Offline-Pruefung"', setup)
        self.assertIn("show_rag_compliance_review || true", setup)
        wrapper = (ROOT / "scripts/check_rag_compliance.sh").read_text()
        self.assertIn('set -- doctor', wrapper)
        self.assertIn('review.py" "$@"', wrapper)
        for path in ("readme.md", "docs/TOOLS_CATALOG.md", "docs/TOOL_INDEX.md", "docs/SECURITY_MODEL.md",
                     "docs/Profile/AI_Governance_Audit.md", "docs/Profile/Legal_Compliance_Safety_Review.md"):
            self.assertIn("legal/README.md", (ROOT / path).read_text(encoding="utf-8"))

    def temporal(self, data=None, as_of="2025-12-31", known_on="2026-10-21", **kwargs):
        return review.temporal_context(data if data is not None else self.example("temporal-versions"),
                                       date.fromisoformat(as_of), date.fromisoformat(known_on),
                                       kwargs.get("jurisdictions", ["RU"]), kwargs.get("tenant", "demo"),
                                       kwargs.get("roles", ["reviewer"]))

    def test_temporal_half_open_boundaries_and_historical_repealed_version(self):
        self.assertEqual(self.temporal()["selected"][0]["version_id"], "v1")
        boundary = self.temporal(as_of="2026-01-01")
        self.assertEqual([row["version_id"] for row in boundary["selected"]], ["v2"])
        self.assertFalse(boundary["legal_approval"])
        self.assertFalse(boundary["identity_verified"])
        self.assertFalse(boundary["network_accessed"])

    def test_temporal_knowledge_date_and_future_validity_never_broaden(self):
        for result in (self.temporal(as_of="2026-01-01", known_on="2026-01-02"),
                       self.temporal(as_of="2024-12-31"), self.temporal(jurisdictions=["EU"]),
                       self.temporal(tenant="other"), self.temporal(roles=["visitor"])):
            self.assertEqual(result["status"], "insufficient-evidence")
            self.assertEqual(result["selected"], [])

    def test_temporal_pending_metadata_and_malformed_intervals_fail_closed(self):
        data = self.example("temporal-versions")
        data["records"][0]["review_state"] = "pending"
        self.assertEqual(self.temporal(data)["selected"], [])
        for field, value in (("valid_until", "2024-01-01"), ("valid_from", "2025-1-01"),
                             ("recorded_on", None), ("allowed_roles", []), ("law_status", "UNKNOWN")):
            invalid = self.example("temporal-versions")
            invalid["records"][0][field] = value
            with self.assertRaises(ValueError):
                self.temporal(invalid)

    def test_temporal_duplicate_ids_rejected_and_multijurisdiction_is_not_conflict(self):
        data = self.example("temporal-versions")
        data["records"].append(deepcopy(data["records"][0]))
        with self.assertRaises(ValueError):
            self.temporal(data)
        data["records"][-1]["source_id"] = "synthetic-eu"
        data["records"][-1]["jurisdiction"] = "EU"
        result = self.temporal(data, jurisdictions=["RU", "EU"])
        self.assertTrue(result["cross_jurisdiction_context"])
        self.assertEqual(result["conflict_status"], "not-assessed")
        self.assertFalse(result["execution_permitted"])

    def test_temporal_cli_and_source_inventory(self):
        output = io.StringIO()
        with redirect_stdout(output):
            self.assertEqual(review.main(["temporal-context", str(EXAMPLES / "temporal-versions.json"),
                                          "--as-of", "2025-12-31", "--known-on", "2026-10-21",
                                          "--jurisdiction", "RU", "--tenant", "demo", "--role", "reviewer"]), 0)
        self.assertEqual(json.loads(output.getvalue())["selected"][0]["version_id"], "v1")
        sources = {row["id"]: row for row in review.load_json(ROOT / "config/legal/sources.json")["sources"]}
        self.assertEqual(sources["ru_pravo"]["status"], "retrieval-blocked")
        self.assertIsNone(sources["ru_pravo"]["reviewed_on"])
        self.assertTrue({"ua_rada", "pl_isap", "cz_esbirka", "sk_slovlex"} <= sources.keys())

    def test_all_local_legal_documentation_links_exist(self):
        for path in (ROOT / "docs/legal").rglob("*.md"):
            for target in re.findall(r"\]\(([^)]+)\)", path.read_text(encoding="utf-8")):
                if "://" not in target and not target.startswith("#"):
                    self.assertTrue((path.parent / target.split("#")[0]).exists(), target)
        template = (ROOT / "docs/legal/templates/DSB_HANDOVER.md").read_text(encoding="utf-8")
        self.assertIn("Entwurf / nicht produktiv freigegeben", template)
        self.assertIn("Betreiberentscheidung", template)


if __name__ == "__main__":
    unittest.main()
