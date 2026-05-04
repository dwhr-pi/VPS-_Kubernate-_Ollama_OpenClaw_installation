#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in changelog_generator release_please act pre_commit github_cli; do [ -f "$ROOT_DIR/scripts/tools/${s}_uninstall.sh" ] && bash "$ROOT_DIR/scripts/tools/${s}_uninstall.sh"; done
mark_profile_removed "AI_Project_Manager"
