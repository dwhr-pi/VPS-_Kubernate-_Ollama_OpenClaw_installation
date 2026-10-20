#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

python3 - <<'PY'
import json
from collections import defaultdict
from pathlib import Path

ports = json.loads(Path("config/ports.yml").read_text(encoding="utf-8"))["ports"]
seen = defaultdict(list)
failed = False
for item in ports:
    port = item.get("port")
    if type(port) is not int or not 1 <= port <= 65535:
        failed = True
        print("FEHLER: Port muss eine ganze Zahl zwischen 1 und 65535 sein.")
        continue
    seen[port].append(item.get("service", "unknown"))

for port, services in sorted(seen.items()):
    if len(services) > 1:
        failed = True
        print(f"DOPPELT Port {port}: {', '.join(services)}")

if not failed:
    print(f"OK: {len(ports)} Ports in config/ports.yml, keine Doppelbelegung in der Registry.")

raise SystemExit(1 if failed else 0)
PY
