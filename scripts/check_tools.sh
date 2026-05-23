#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

python3 - <<'PY'
import json
from pathlib import Path

data = json.loads(Path("config/tools.yml").read_text(encoding="utf-8"))
tools = data.get("tools", [])
failed = False

for tool in tools:
    tid = tool.get("id", "<ohne-id>")
    for key in ("install_script", "uninstall_script"):
        value = tool.get(key)
        if not value:
            failed = True
            print(f"FEHLT {tid}: {key}")
            continue
        if not Path(value).exists():
            failed = True
            print(f"FEHLT {tid}: {key} -> {value}")
    if not tool.get("check_type"):
        failed = True
        print(f"FEHLT {tid}: check_type")
    if "github" not in " ".join(str(tool.get(k, "")) for k in ("source", "github", "url", "notes", "safety")).lower():
        print(f"HINWEIS {tid}: keine explizite GitHub-Quelle im Registry-Eintrag")

print(f"Geprueft: {len(tools)} Tools.")
raise SystemExit(1 if failed else 0)
PY

