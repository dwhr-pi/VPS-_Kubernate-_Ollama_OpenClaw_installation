"""Offline integration gate. Does not import, install or run Conway Automaton."""
import argparse
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
SOURCE_COMMIT = "d8f816881fd24b6f5e3d616e59edec387a447667"
POLICY = ROOT / "config/automaton.policy.example.json"
ACTIONS = {"repo_audit", "backtest_report", "wallet_balance_report"}


def validate(proposal):
    fields = {"action", "max_turns", "retry_limit", "requires_network",
              "requires_signing", "requires_write"}
    if not isinstance(proposal, dict) or set(proposal) != fields:
        raise ValueError("Unerwartete oder fehlende Vorschlagsfelder.")
    if not isinstance(proposal["action"], str) or proposal["action"] not in ACTIONS:
        raise ValueError("Aktion nicht fuer den Offline-Review zugelassen.")
    for field, limit in (("max_turns", 10), ("retry_limit", 2)):
        value = proposal[field]
        minimum = 1 if field == "max_turns" else 0
        if type(value) is not int or not minimum <= value <= limit:
            raise ValueError("Turn-/Retry-Grenze verletzt.")
    if any(proposal[key] is not False for key in
           ("requires_network", "requires_signing", "requires_write")):
        raise ValueError("Netzwerk-, Signatur- oder Schreibaktion gesperrt.")
    return {"decision": "manual_review_required", "approved_for_execution": False,
            "executed": False}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=("plan", "check", "doctor", "status", "review",
                                        "install", "update", "uninstall", "repair", "run"))
    parser.add_argument("proposal", nargs="?")
    args = parser.parse_args(argv)
    if args.mode in {"install", "update", "uninstall", "repair", "run"}:
        print("Automaton ist documentation-first/planned. Runtime-Aktion gesperrt; "
              "kein Download, Wallet-Zugriff, Start oder Loeschen. Siehe docs/tools/automaton.md.",
              file=sys.stderr)
        return 2
    try:
        if args.mode == "review":
            if not args.proposal:
                raise ValueError("Vorschlagsdatei fehlt.")
            path = Path(args.proposal)
            if path.is_symlink() or not path.is_file() or path.stat().st_size > 65536:
                raise ValueError("Vorschlagsdatei ungueltig oder zu gross.")
            result = validate(json.loads(path.read_text(encoding="utf-8")))
        else:
            # Validate our integration assets only. Never inspect ~/.automaton.
            policy = json.loads(POLICY.read_text(encoding="utf-8"))
            if policy.get("runtime_enabled") is not False:
                raise ValueError("Integrationsvorlage muss Runtime deaktiviert lassen.")
            validate(json.loads((ROOT / "examples/automaton/review-proposal.json").read_text()))
            result = {"status": "planned", "installed": False,
                      "source_commit": SOURCE_COMMIT, "runtime_enabled": False,
                      "check_scope": "integration_assets_only"}
        print(json.dumps(result, ensure_ascii=True))
        return 0
    except (OSError, ValueError, TypeError):
        print("Review fehlgeschlagen/gesperrt. Dateiformat und Grenzen pruefen; "
              "keine Inhalte oder geheimen Werte ausgegeben.", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
