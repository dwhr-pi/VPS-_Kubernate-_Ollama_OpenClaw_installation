#!/usr/bin/env bash
set -euo pipefail

echo "Supply-Chain-Check"
echo "- Pruefe riskante curl|bash Muster"
if grep -RInE 'curl .*\\| *bash|wget .*\\| *bash' scripts install.sh setup_ultimate.sh 2>/dev/null; then
  echo "WARNUNG: curl|bash Muster gefunden. Bitte Quellen, Signaturen und Checks pruefen."
else
  echo "OK: keine einfachen curl|bash Muster gefunden."
fi

echo "- Pruefe Tool-Registry auf Quellenhinweise"
python3 - <<'PY'
import json
from pathlib import Path
data=json.loads(Path("config/tools.yml").read_text(encoding="utf-8"))
missing=[t["id"] for t in data["tools"] if not (t.get("source") or "github" in str(t).lower())]
print(f"Tools ohne explizite Quelle: {len(missing)}")
if missing:
    print(", ".join(missing[:50]))
PY
