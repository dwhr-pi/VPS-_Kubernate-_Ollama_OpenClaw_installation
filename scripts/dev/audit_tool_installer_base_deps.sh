#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

python3 - "$REPO_ROOT" <<'PY'
from pathlib import Path
import re
import sys

repo_root = Path(sys.argv[1])
tools_dir = repo_root / "scripts" / "tools"

checks = [
    ("venv", re.compile(r"python3?\s+-m\s+venv|virtualenv|source .*/(?:\.?venv)/bin/activate"), re.compile(r"python3-venv|python3\.\d+-venv|ensure_base_apt_packages|OPENMANUS_APT_PACKAGES|TOOL_APT_PACKAGES|init_tool_tracking|scaffold_tool_common|simple_tool_common|install_base_packages"), "python3-venv pruefen"),
    ("pip", re.compile(r"pip3?(?:\s|$)|python3?\s+-m\s+pip"), re.compile(r"python3-pip|ensure_base_apt_packages|OPENMANUS_APT_PACKAGES|TOOL_APT_PACKAGES|init_tool_tracking|scaffold_tool_common|simple_tool_common|install_base_packages"), "python3-pip pruefen"),
    ("node", re.compile(r"npm\s|pnpm\s|corepack|yarn\s"), re.compile(r"nodejs|npm|ensure_base_apt_packages|TOOL_APT_PACKAGES|init_tool_tracking|scaffold_tool_common|simple_tool_common|install_base_packages"), "Node/npm pruefen"),
    ("git", re.compile(r"git\s+clone|git\s+-C|github\.com"), re.compile(r"\bgit\b|ensure_base_apt_packages|TOOL_APT_PACKAGES|init_tool_tracking|scaffold_tool_common|simple_tool_common|install_base_packages"), "git pruefen"),
    ("native", re.compile(r"build-essential|node-gyp|prebuild-install|gcc|g\+\+|make(?:\s|$)|cmake|pkg-config"), re.compile(r"build-essential|cmake|pkg-config|ensure_base_apt_packages|TOOL_APT_PACKAGES|init_tool_tracking|scaffold_tool_common|simple_tool_common|install_base_packages"), "Build-Tools pruefen"),
]

print(f"{'Installer':44} {'Erkannte Nutzung':32} Hinweis")
print(f"{'-' * 9:44} {'-' * 16:32} {'-' * 6}")

for script_path in sorted(tools_dir.glob("*_install.sh")):
    text = script_path.read_text(encoding="utf-8", errors="replace")
    uses = []
    notes = []

    for label, use_pattern, coverage_pattern, note in checks:
        if use_pattern.search(text):
            uses.append(label)
            if not coverage_pattern.search(text):
                notes.append(note)

    print(f"{script_path.name:44} {','.join(uses) or '-':32} {'; '.join(notes) if notes else 'OK oder zentral abgedeckt'}")
PY
