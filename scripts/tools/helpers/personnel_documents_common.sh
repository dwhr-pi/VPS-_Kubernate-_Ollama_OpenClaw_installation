#!/usr/bin/env bash
set -euo pipefail
PERSONNEL_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
personnel_main() {
  local mode="${1:---dry-run}"
  case "$mode" in
    --dry-run | --plan | --help) mode=plan ;;
    --check) mode=check ;;
    --status) mode=status ;;
    --repair) mode=update ;;
    --uninstall) mode=uninstall ;;
  esac
  command -v python3 >/dev/null || {
    echo 'Python 3 erforderlich; keine automatische Installation.' >&2
    return 1
  }
  python3 -I -B "$PERSONNEL_REPO_ROOT/tools/personnel_documents/manage.py" "$mode"
}
