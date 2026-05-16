#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

python3 - <<'PY'
import json
from pathlib import Path

ok = True
for file in ["config/tools.yml", "config/profiles.yml", "config/ports.yml"]:
    try:
        json.loads(Path(file).read_text(encoding="utf-8"))
        print(f"OK JSON/YAML-kompatibel: {file}")
    except Exception as exc:
        ok = False
        print(f"FEHLER {file}: {exc}")

raise SystemExit(0 if ok else 1)
PY
