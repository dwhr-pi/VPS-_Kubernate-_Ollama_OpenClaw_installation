#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

STRICT_SOURCES="${1:-}" python3 - <<'PY'
import json
import os
from pathlib import Path

data = json.loads(Path("config/tools.yml").read_text(encoding="utf-8"))
tools = data.get("tools", [])
failed = False
strict_sources = os.environ.get("STRICT_SOURCES") in ("--strict-sources", "strict", "1", "true")
source_doc = Path("docs/GITHUB_TOOL_SOURCES.md")
source_text = source_doc.read_text(encoding="utf-8").lower() if source_doc.exists() else ""
missing_sources = []
ids = set()

def norm(value):
    return str(value or "").lower().replace("_", "").replace("-", "").replace(" ", "")

for tool in tools:
    tid = tool.get("id", "<ohne-id>")
    if not isinstance(tid, str) or tid == "<ohne-id>" or tid in ids:
        failed = True
        print("FEHLER: fehlende/ungueltige/doppelte Tool-ID")
        continue
    ids.add(tid)
    for key in ("install_script", "uninstall_script"):
        value = tool.get(key)
        if not value:
            failed = True
            print(f"FEHLT {tid}: {key}")
            continue
        if not Path(value).is_file():
            failed = True
            print(f"FEHLT {tid}: {key} -> {value}")
    for key in ("doc", "update_script", "doctor_script"):
        value = tool.get(key)
        if value and not Path(value).is_file():
            failed = True
            print(f"FEHLT {tid}: {key} -> {value}")
    if not tool.get("check_type"):
        failed = True
        print(f"FEHLT {tid}: check_type")
    source_blob = " ".join(str(tool.get(k, "")) for k in ("source", "github", "url", "notes", "safety")).lower()
    has_inline_source = "github.com" in source_blob or "github" in source_blob
    has_documented_source = any(value and value in norm(source_text)
                                for value in (norm(tid), norm(tool.get("name"))))
    if not has_inline_source and not has_documented_source:
        missing_sources.append(tid)

print(f"Geprueft: {len(tools)} Tools.")
if missing_sources:
    if strict_sources:
        print(
            "HINWEIS: Fuer diese Tools fehlt noch eine GitHub-/Primaerquellen-Zuordnung "
            f"in config/tools.yml oder docs/GITHUB_TOOL_SOURCES.md: {', '.join(missing_sources)}"
        )
    else:
        print(
            f"Hinweis: {len(missing_sources)} Tools haben noch keine maschinenlesbare "
            "Primaerquellen-Zuordnung. Details mit: bash scripts/check_tools.sh --strict-sources"
        )
    print("Quellenhinweise sind nicht kritisch, solange Installer/Uninstaller und check_type vorhanden sind.")
raise SystemExit(1 if failed else 0)
PY
