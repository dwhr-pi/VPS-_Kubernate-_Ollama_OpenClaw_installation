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
from pathlib import Path

root, config_file = sys.argv[1], sys.argv[2]
errors = []
warnings = []

with open(config_file, "r", encoding="utf-8") as fh:
    data = json.load(fh)

profiles = data.get("profiles", [])
ids = set()
tool_ids = set()
tools_file = Path(root) / "config" / "tools.yml"
if tools_file.exists():
    with open(tools_file, "r", encoding="utf-8") as fh:
        tool_ids = {tool.get("id") for tool in json.load(fh).get("tools", []) if tool.get("id")}

alias_groups = {
    "Image_Generation_Studio": {"Image_Generation", "Visual_Creator"},
    "Video_Generation_Studio": {"Video_Generation", "Video_Generation_ComfyUI_Wan"},
    "Personal_Memory_Knowledge_OS": {"Personal_Knowledge_Memory", "Memory_Import_Export", "Knowledge_Librarian"},
    "Security_DevSecOps": {"Security_Analyst", "Cyber_Security_AI", "Ethical_HackerGPT"},
}

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
            continue
        if tool_ids and tool not in tool_ids:
            errors.append(f"{pid}: Tool nicht in config/tools.yml registriert: {tool}")

profile_docs = {
    os.path.splitext(name)[0]
    for name in os.listdir(os.path.join(root, "docs", "Profile"))
    if name.endswith(".md")
}
missing_in_registry = sorted(profile_docs - ids)
if missing_in_registry:
    warnings.append("Docs ohne Registry-Eintrag: " + ", ".join(missing_in_registry[:40]))

script_dir = Path(root) / "scripts" / "profiles"
for script in script_dir.glob("*_install.sh"):
    pid = script.name[:-len("_install.sh")]
    if pid not in ids:
        warnings.append(f"Installer ohne Registry-Eintrag: {script.relative_to(root)}")
for script in script_dir.glob("*_uninstall.sh"):
    pid = script.name[:-len("_uninstall.sh")]
    if pid not in ids:
        warnings.append(f"Uninstaller ohne Registry-Eintrag: {script.relative_to(root)}")

for canonical, aliases in alias_groups.items():
    present_aliases = sorted(alias for alias in aliases if alias in ids or alias in profile_docs)
    if present_aliases:
        warnings.append(f"Alias/Legacy-Gruppe: {canonical} <- {', '.join(present_aliases)}")

print("Profile geprueft:", len(profiles))
print("Fehler:", len(errors))
print("Warnungen:", len(warnings))
for item in errors:
    print("ERROR:", item)
for item in warnings:
    print("WARN:", item)

sys.exit(1 if errors else 0)
PY
