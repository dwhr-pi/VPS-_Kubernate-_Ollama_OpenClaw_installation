#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

python3 - <<'PY'
import json
from pathlib import Path

profiles = json.loads(Path("config/profiles.yml").read_text(encoding="utf-8"))["profiles"]
tools = {t["id"] for t in json.loads(Path("config/tools.yml").read_text(encoding="utf-8"))["tools"]}
failed = False

for profile in profiles:
    pid = profile["id"]
    for key in ["doc", "install", "uninstall"]:
        value = profile.get(key)
        if value and not Path(value).exists():
            failed = True
            print(f"FEHLT {pid}: {key} -> {value}")
    for tool in profile.get("tools", []):
        if tool not in tools:
            failed = True
            print(f"UNBEKANNTES TOOL {pid}: {tool}")

print(f"Geprueft: {len(profiles)} Profile, {len(tools)} Tools.")
raise SystemExit(1 if failed else 0)
PY
