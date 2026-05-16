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
for item in ports:
    seen[int(item["port"])].append(item.get("service", "unknown"))

failed = False
for port, services in sorted(seen.items()):
    if len(services) > 1:
        failed = True
        print(f"DOPPELT Port {port}: {', '.join(services)}")

if not failed:
    print(f"OK: {len(ports)} Ports in config/ports.yml, keine Doppelbelegung in der Registry.")

raise SystemExit(1 if failed else 0)
PY
