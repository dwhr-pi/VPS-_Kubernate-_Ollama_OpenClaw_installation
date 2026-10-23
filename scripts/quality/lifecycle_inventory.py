"""Read-only Top-20 lifecycle metadata inventory; never probes installed runtimes."""
import argparse
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[2]
TOP20 = (
    "ollama", "openclaw", "wireguard", "k3s", "litellm", "qdrant", "n8n",
    "flowise", "prometheus", "grafana", "loki", "opentelemetry", "uptime_kuma",
    "langfuse", "restic", "gitleaks", "trivy", "comfyui", "whisper_cpp", "piper",
)
FIELDS = ("install_script", "uninstall_script", "update_script", "doctor_script", "doc")


def file_state(root, value):
    if not value:
        return "not-mapped"
    if not isinstance(value, str) or "\\" in value or ":" in value:
        return "unsafe-path"
    relative = Path(value)
    if relative.is_absolute() or ".." in relative.parts:
        return "unsafe-path"
    candidate = root / relative
    if not candidate.resolve().is_relative_to(root.resolve()):
        return "unsafe-path"
    return "present" if candidate.is_file() else "missing-file"


def inventory(root=ROOT, selected=TOP20):
    root = Path(root)
    rows = json.loads((root / "config/tools.yml").read_text(encoding="utf-8-sig"))["tools"]
    if not isinstance(rows, list) or any(not isinstance(row, dict) for row in rows):
        raise ValueError("Tool-Registry muss eine Liste von Objekten enthalten.")
    result = []
    for ident in selected:
        matches = [row for row in rows if row.get("id") == ident]
        if len(matches) != 1:
            raise ValueError("Tool-ID fehlt oder ist mehrfach vorhanden: " + ident)
        row = matches[0]
        states = {field: file_state(root, row.get(field)) for field in FIELDS}
        gaps = [field + ":" + state for field, state in states.items() if state != "present"]
        if not row.get("status"):
            gaps.append("status:not-declared")
        pin = row.get("source_commit", "")
        if not isinstance(pin, str) or not re.fullmatch(r"[a-f0-9]{40}", pin):
            pin = None
            gaps.append("source_commit:not-declared-in-registry")
        planned_stub = row.get("install_script") == "scripts/tools/planned_tool_stub_install.sh"
        if planned_stub:
            gaps.append("install:planned-stub")
        result.append({
            "id": ident, "declared_status": row.get("status") or "not-declared",
            "registry_source_commit": pin, "files": states, "gaps": gaps,
            "planned_stub": planned_stub, "runtime_readiness": "not-tested",
        })
    return {"scope": "repository-metadata-only", "writes": False,
            "runtime_probes": False, "tools": result}


def markdown(report):
    lines = ["# Top-20 Lifecycle-Inventar", "",
             "Nur Registry/Dateien; kein Dienst-, Versions-, Port- oder Modelltest.",
             "Fehlender Registry-Pin beweist nicht, dass der Installer ungepinnt ist.", "",
             "| Tool-ID | Registry-Status | Doctor-Mapping | Update-Mapping | Luecken | Runtime |",
             "|---|---|---|---|---|---|"]
    for row in report["tools"]:
        status = str(row["declared_status"]).replace("|", "\\|").replace("\n", " ")
        lines.append("| " + " | ".join((row["id"], status,
                     row["files"]["doctor_script"], row["files"]["update_script"],
                     str(len(row["gaps"])), row["runtime_readiness"])) + " |")
    return "\n".join(lines) + "\n"


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--dry-run", action="store_true", help="Already read-only; no files are written")
    parser.add_argument("--strict", action="store_true", help="Fail if selected tools have metadata gaps")
    parser.add_argument("--tool", choices=TOP20, action="append")
    args = parser.parse_args(argv)
    report = inventory(selected=tuple(dict.fromkeys(args.tool or TOP20)))
    print(json.dumps(report, indent=2) if args.json else markdown(report), end="\n" if args.json else "")
    return int(args.strict and any(row["gaps"] for row in report["tools"]))


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, KeyError, TypeError):
        print("Lifecycle-Inventar fehlgeschlagen: Registry-Struktur und Tool-IDs pruefen.", file=sys.stderr)
        sys.exit(1)
