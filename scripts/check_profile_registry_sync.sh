#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$ROOT_DIR/config/profiles.yml"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 fehlt; Registry-Check kann nicht ausgefuehrt werden." >&2
  exit 2
fi

python3 - "$ROOT_DIR" "$CONFIG_FILE" <<'PY'
import json
import os
import sys

root, config_file = sys.argv[1], sys.argv[2]
errors = []
warnings = []

with open(config_file, "r", encoding="utf-8") as fh:
    data = json.load(fh)

profiles = data.get("profiles", [])
ids = set()

for profile in profiles:
    pid = profile.get("id")
    if not pid:
        errors.append("Profil ohne id")
        continue
    if pid in ids:
        errors.append(f"Doppelte Profil-ID: {pid}")
    ids.add(pid)

    for key in ("doc", "install", "uninstall"):
        value = profile.get(key)
        if not value:
            errors.append(f"{pid}: Feld {key} fehlt")
            continue
        if not os.path.exists(os.path.join(root, value)):
            errors.append(f"{pid}: {key} fehlt: {value}")

    for tool in profile.get("tools", []):
        if not isinstance(tool, str) or not tool:
            warnings.append(f"{pid}: ungueltiger Tool-Eintrag: {tool!r}")

profile_docs = {
    os.path.splitext(name)[0]
    for name in os.listdir(os.path.join(root, "docs", "Profile"))
    if name.endswith(".md")
}
missing_in_registry = sorted(profile_docs - ids)
if missing_in_registry:
    warnings.append("Docs ohne Registry-Eintrag: " + ", ".join(missing_in_registry[:40]))

print("Profile geprueft:", len(profiles))
print("Fehler:", len(errors))
print("Warnungen:", len(warnings))
for item in errors:
    print("ERROR:", item)
for item in warnings:
    print("WARN:", item)

sys.exit(1 if errors else 0)
PY
