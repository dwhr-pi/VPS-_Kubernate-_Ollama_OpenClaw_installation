"""Offline review aid, not a legal decision engine or database administrator."""
import argparse
from datetime import date, datetime
import hashlib
import hmac
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[2]
MAX_BYTES = 2 * 1024**2
FEATURES = {"personal_data", "special_category_data", "external_provider", "employment_decisions",
            "automated_decisions", "synthetic_media", "training_data", "public_release"}
CONTROLS = {"lawful_basis_reviewed", "retrieval_acl", "pii_quality_review", "deletion_mapping",
            "backup_retention_plan", "minimal_logs", "transfer_review", "human_approval",
            "license_review", "transparency_review"}
STORES = {"documents", "chunks", "embeddings", "search_cache", "application_logs", "exports", "backups"}


def load_json(path):
    with Path(path).open("rb") as stream:
        raw = stream.read(MAX_BYTES + 1)
    if len(raw) > MAX_BYTES:
        raise ValueError("Eingabe ueber 2 MiB; nichts verarbeitet.")
    def unique_fields(pairs):
        result = {}
        for key, value in pairs:
            if key in result:
                raise ValueError("Mehrdeutige doppelte JSON-Felder.")
            result[key] = value
        return result

    def reject_constant(value):
        raise ValueError("Nichtstandardisierte JSON-Zahl.")

    return json.loads(raw.decode("utf-8"), object_pairs_hook=unique_fields, parse_constant=reject_constant)


def exact_keys(value, keys):
    if not isinstance(value, dict) or set(value) != set(keys):
        raise ValueError("Schema unvollstaendig oder unbekannte Felder; nichts freigegeben.")


def bool_map(value, keys):
    exact_keys(value, keys)
    if any(type(item) is not bool for item in value.values()):
        raise ValueError("Explizite boolesche Angaben erforderlich.")


def source_review(today):
    data = load_json(ROOT / "config/legal/sources.json")
    results = []
    ids = set()
    for source in data["sources"]:
        if source["id"] in ids or not re.fullmatch(r"[a-z0-9_]+", source["id"]):
            raise ValueError("Ungueltige Quellen-ID.")
        ids.add(source["id"])
        reviewed = source["reviewed_on"]
        if reviewed is None or source["status"] != "overview-reviewed":
            state = "review-required"
        else:
            age = (today - date.fromisoformat(reviewed)).days
            state = "invalid-future-date" if age < 0 else "overdue" if age >= source["review_interval_days"] else "within-review-window"
        results.append({"id": source["id"], "kind": source["kind"], "review_state": state})
    countries = load_json(ROOT / "config/legal/country_coverage.json")["countries"]
    return {"scope": "offline-source-review", "legal_approval": False, "network_accessed": False,
            "country_entries": len(countries), "national_law_review_complete": False,
            "unreviewed_country_entries": sum(row["legal_review"] == "not_reviewed" for row in countries),
            "sources": results, "open_reviews": sum(row["review_state"] != "within-review-window" for row in results)}


def assess(data):
    exact_keys(data, {"schema_version", "jurisdictions", "features", "controls"})
    if type(data["schema_version"]) is not int or data["schema_version"] != 1:
        raise ValueError("Unbekannte Schemaversion.")
    bool_map(data["features"], FEATURES)
    bool_map(data["controls"], CONTROLS)
    jurisdictions = data["jurisdictions"]
    if (not isinstance(jurisdictions, list) or not 1 <= len(jurisdictions) <= 16 or
            any(not isinstance(item, str) for item in jurisdictions)):
        raise ValueError("Ein bis 16 Jurisdiktionen erforderlich.")
    names = {row["name"] for row in load_json(ROOT / "config/legal/country_coverage.json")["countries"]}
    unknown = sum(item not in names | {"EU", "EEA", "US-CO"} for item in jurisdictions)
    f, c = data["features"], data["controls"]
    requirements = {"human_approval", "minimal_logs"}
    topics = {"applicable-law-and-role-review"}
    if f["personal_data"] or f["special_category_data"]:
        requirements.update({"lawful_basis_reviewed", "retrieval_acl", "pii_quality_review",
                             "deletion_mapping", "backup_retention_plan"})
        topics.add("privacy-retention-and-data-subject-rights")
    if f["special_category_data"]:
        topics.add("special-category-legal-basis-and-dpia-review")
    if f["external_provider"]:
        requirements.add("transfer_review")
        topics.add("provider-contract-transfer-and-routing-review")
    if f["employment_decisions"] or f["automated_decisions"]:
        topics.add("automated-decisions-and-ai-risk-classification-review")
    if f["synthetic_media"] or f["public_release"]:
        requirements.add("transparency_review")
        topics.add("disclosure-and-personality-rights-review")
    if f["training_data"] or f["public_release"]:
        requirements.add("license_review")
        topics.add("copyright-license-and-product-role-review")
    return {"scope": "offline-scenario-review", "legal_approval": False,
            "decision": "human-review-required", "unknown_jurisdiction_count": unknown,
            "missing_control_evidence": sorted(item for item in requirements if not c[item]),
            "review_topics": sorted(topics), "controls_are_self_reported": True,
            "execution_permitted": False}


def deletion_plan(data):
    exact_keys(data, {"schema_version", "scope_confirmed", "legal_review_complete", "stores"})
    if (type(data["schema_version"]) is not int or data["schema_version"] != 1 or
            type(data["scope_confirmed"]) is not bool or type(data["legal_review_complete"]) is not bool or
            not isinstance(data["stores"], list) or len(data["stores"]) > len(STORES)):
        raise ValueError("Ungueltiger Loeschplan.")
    seen, proposed, held = set(), {}, 0
    for row in data["stores"]:
        exact_keys(row, {"store", "items", "legal_hold", "retention_reviewed"})
        if (row["store"] not in STORES or row["store"] in seen or
                type(row["items"]) is not int or not 0 <= row["items"] <= 10**9 or
                type(row["legal_hold"]) is not bool or type(row["retention_reviewed"]) is not bool):
            raise ValueError("Unbekannter/mehrfacher Speicher oder ungueltige Bestandsangabe.")
        seen.add(row["store"])
        if row["legal_hold"] or not row["retention_reviewed"]:
            held += row["items"]
        else:
            proposed[row["store"]] = row["items"]
    return {"scope": "deletion-plan-only", "dry_run": True, "legal_approval": False,
            "deletions_executed": 0, "execution_permitted": False,
            "proposed_counts_subject_to_review": proposed, "held_or_unreviewed_items": held,
            "missing_store_reviews": sorted(STORES - seen),
            "scope_confirmed": data["scope_confirmed"], "legal_review_complete": data["legal_review_complete"],
            "backup_note": "Retention, Restore-Sperren und Wiederherstellungsprozess separat pruefen."}


def record_hash(record):
    fields = {key: value for key, value in record.items() if key != "record_hash"}
    encoded = json.dumps(fields, sort_keys=True, separators=(",", ":"), ensure_ascii=True, allow_nan=False)
    return hashlib.sha256(encoded.encode("utf-8")).hexdigest()


def audit_check(data, expected_head=None, expected_count=None):
    exact_keys(data, {"schema_version", "records"})
    if type(data["schema_version"]) is not int or data["schema_version"] != 1 or not isinstance(data["records"], list):
        raise ValueError("Ungueltiges Auditformat.")
    if (expected_head is None) != (expected_count is None):
        raise ValueError("Externen Head und erwartete Anzahl zusammen angeben.")
    if expected_head is not None and (not isinstance(expected_head, str) or
            not re.fullmatch(r"[0-9a-f]{64}", expected_head) or type(expected_count) is not int or expected_count < 0):
        raise ValueError("Ungueltiger externer Vergleichswert.")
    previous = "0" * 64
    for sequence, row in enumerate(data["records"], 1):
        exact_keys(row, {"sequence", "occurred_at", "action", "documents", "vectors", "previous_hash", "record_hash"})
        if (type(row["sequence"]) is not int or row["sequence"] != sequence or
                row["action"] not in ("deletion_requested", "deletion_completed", "review_required") or
                any(type(row[key]) is not int or row[key] < 0 for key in ("documents", "vectors")) or
                not isinstance(row["occurred_at"], str) or not row["occurred_at"].endswith("Z") or
                not isinstance(row["record_hash"], str) or not re.fullmatch(r"[0-9a-f]{64}", row["record_hash"])):
            raise ValueError("Auditdatensatz strukturell ungueltig; kein Reparaturversuch.")
        stamp = datetime.fromisoformat(row["occurred_at"].replace("Z", "+00:00"))
        if stamp.tzinfo is None or stamp.utcoffset().total_seconds() != 0:
            raise ValueError("UTC-Zeitstempel erforderlich.")
        if row["previous_hash"] != previous or not hmac.compare_digest(record_hash(row), row["record_hash"]):
            return {"scope": "audit-consistency-only", "status": "inconsistent", "legal_approval": False,
                    "records_checked": sequence, "authenticity_verified": False}
        previous = row["record_hash"]
    anchored = expected_head is not None
    if not data["records"] and not anchored:
        return {"scope": "audit-consistency-only", "status": "no-records", "records_checked": 0,
                "authenticity_verified": False, "legal_approval": False, "repair_performed": False}
    matches = not anchored or (hmac.compare_digest(previous, expected_head) and len(data["records"]) == expected_count)
    return {"scope": "audit-consistency-only", "status": "consistent" if matches else "anchor-mismatch",
            "records_checked": len(data["records"]), "external_comparison_supplied": anchored,
            "tail_truncation_checked_against_supplied_values": anchored,
            "authenticity_verified": False, "legal_approval": False, "repair_performed": False}


def temporal_context(data, as_of, known_on, jurisdictions, tenant, roles):
    """Filter supplied metadata only; caller identity and legal applicability are not verified."""
    exact_keys(data, {"schema_version", "records"})
    if (type(data["schema_version"]) is not int or data["schema_version"] != 1 or
            not isinstance(data["records"], list) or len(data["records"]) > 10000):
        raise ValueError("Ungueltiger Versionsbestand.")
    token = re.compile(r"[A-Za-z0-9_.:-]{1,100}")
    def identifier(value):
        if not isinstance(value, str) or not token.fullmatch(value):
            raise ValueError("Ungueltige Metadaten-ID.")
        return value

    def day(value):
        if not isinstance(value, str) or not re.fullmatch(r"\d{4}-\d{2}-\d{2}", value):
            raise ValueError("Explizites ISO-Datum erforderlich.")
        return date.fromisoformat(value)

    if not jurisdictions or not roles or len(jurisdictions) > 16 or len(roles) > 32:
        raise ValueError("Begrenzte Jurisdiktions- und Rollenauswahl erforderlich.")
    requested = {identifier(item) for item in jurisdictions}
    caller_roles = {identifier(item) for item in roles}
    identifier(tenant)
    seen, selected = set(), []
    for row in data["records"]:
        exact_keys(row, {"version_id", "chunk_id", "source_id", "jurisdiction", "tenant",
                         "allowed_roles", "valid_from", "valid_until", "recorded_on",
                         "review_state", "law_status"})
        for field in ("version_id", "chunk_id", "source_id", "jurisdiction", "tenant"):
            identifier(row[field])
        identity = (row["source_id"], row["version_id"], row["chunk_id"])
        if identity in seen:
            raise ValueError("Doppelte Versions-/Chunk-ID.")
        seen.add(identity)
        allowed = row["allowed_roles"]
        if not isinstance(allowed, list) or not 1 <= len(allowed) <= 32:
            raise ValueError("Explizite Zugriffsrollen erforderlich.")
        allowed = {identifier(item) for item in allowed}
        start, recorded = day(row["valid_from"]), day(row["recorded_on"])
        end = None if row["valid_until"] is None else day(row["valid_until"])
        if (end is not None and end <= start or row["law_status"] not in {"ACTIVE", "AMENDED", "REPEALED"}
                or row["review_state"] not in {"approved", "pending", "rejected"}):
            raise ValueError("Ungueltiger Zeitraum oder Pruefstatus.")
        # Half-open validity intervals preserve historical versions without double boundary matches.
        if (row["tenant"] == tenant and caller_roles & allowed and row["jurisdiction"] in requested
                and row["review_state"] == "approved" and recorded <= known_on
                and start <= as_of and (end is None or as_of < end)):
            selected.append({key: row[key] for key in ("source_id", "version_id", "chunk_id", "jurisdiction",
                                                       "valid_from", "valid_until", "recorded_on")})
    selected.sort(key=lambda row: (row["source_id"], row["version_id"], row["chunk_id"]))
    return {"scope": "offline-temporal-metadata-filter", "as_of": as_of.isoformat(),
            "known_on": known_on.isoformat(), "selected": selected,
            "status": "context-requires-review" if selected else "insufficient-evidence",
            "cross_jurisdiction_context": len({row["jurisdiction"] for row in selected}) > 1,
            "conflict_status": "not-assessed", "identity_verified": False,
            "metadata_is_self_reported": True, "legal_approval": False,
            "network_accessed": False, "execution_permitted": False}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    doctor = sub.add_parser("doctor", help="Offline-Faelligkeit und Abdeckung; keine Rechtsfreigabe")
    doctor.add_argument("--as-of", type=date.fromisoformat, default=date.today())
    doctor.add_argument("--strict", action="store_true")
    temporal = sub.add_parser("temporal-context", help="Zeit-/Zugriffsfilter fuer lokale Versionsmetadaten")
    temporal.add_argument("input", type=Path)
    temporal.add_argument("--as-of", type=date.fromisoformat, required=True)
    temporal.add_argument("--known-on", type=date.fromisoformat, required=True)
    temporal.add_argument("--jurisdiction", action="append", required=True)
    temporal.add_argument("--tenant", required=True)
    temporal.add_argument("--role", action="append", required=True)
    for command in ("assess", "deletion-plan", "audit-check"):
        child = sub.add_parser(command)
        child.add_argument("input", type=Path)
        if command == "audit-check":
            child.add_argument("--expected-head")
            child.add_argument("--expected-count", type=int)
    args = parser.parse_args(argv)
    if args.command == "doctor":
        result = source_review(args.as_of)
    elif args.command == "temporal-context":
        result = temporal_context(load_json(args.input), args.as_of, args.known_on,
                                  args.jurisdiction, args.tenant, args.role)
    else:
        data = load_json(args.input)
        result = assess(data) if args.command == "assess" else deletion_plan(data) if args.command == "deletion-plan" else audit_check(data, args.expected_head, args.expected_count)
    print(json.dumps(result, ensure_ascii=True, indent=2))
    if args.command == "audit-check":
        return int(result["status"] != "consistent")
    return int(args.command == "doctor" and args.strict and result["open_reviews"] > 0)


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, TypeError, KeyError):
        print("Eingabe/Pruefung fehlgeschlagen; keine Rohdaten ausgegeben und keine Aenderung ausgefuehrt.", file=sys.stderr)
        sys.exit(2)
