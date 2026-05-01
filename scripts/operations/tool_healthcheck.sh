#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REGISTRY_FILE="$ROOT_DIR/config/tools.yml"

if [ ! -f "$REGISTRY_FILE" ]; then
  echo "Tool-Registry nicht gefunden: $REGISTRY_FILE" >&2
  exit 1
fi

python3 - "$REGISTRY_FILE" <<'PY'
import json, subprocess, sys
from pathlib import Path

registry = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
tools = registry.get("tools", [])

def ok(cmd):
    return subprocess.run(["bash", "-lc", cmd], capture_output=True, text=True).returncode == 0

print("Tool-Healthcheck")
print("================")

for tool in tools:
    tid = tool["id"]
    name = tool.get("name", tid)
    ctype = tool.get("check_type")
    cvalue = tool.get("check_value", "")
    healthy = False

    if ctype == "command":
        healthy = ok(f"command -v {cvalue} >/dev/null 2>&1")
    elif ctype == "path":
        healthy = Path(cvalue).exists()
    elif ctype == "port":
        healthy = ok(f"ss -ltn '( sport = :{cvalue} )' | tail -n +2 | grep -q .")

    state = "OK" if healthy else "UNBEKANNT/INAKTIV"
    print(f"[{state}] {name} ({tid})")
PY
