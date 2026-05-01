#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REGISTRY_FILE="$ROOT_DIR/config/ports.yml"

if [ ! -f "$REGISTRY_FILE" ]; then
  echo "Port-Registry nicht gefunden: $REGISTRY_FILE" >&2
  exit 1
fi

python3 - "$REGISTRY_FILE" <<'PY'
import json, sys, subprocess
from pathlib import Path

registry = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
ports = registry.get("ports", [])

print("Portkonflikt-Pruefung")
print("====================")

for entry in ports:
    port = str(entry["port"])
    label = entry.get("label", entry.get("service", port))
    try:
        result = subprocess.run(
            ["bash", "-lc", f"ss -ltnp '( sport = :{port} )' | tail -n +2"],
            capture_output=True,
            text=True,
            check=False,
        )
        output = result.stdout.strip()
    except Exception:
        output = ""
    if output:
        print(f"[BELEGT] {port} -> {label}")
        print(f"         {output}")
    else:
        print(f"[FREI]   {port} -> {label}")
PY
