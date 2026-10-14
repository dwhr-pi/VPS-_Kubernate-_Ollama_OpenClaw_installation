#!/usr/bin/env bash
set -euo pipefail
HIL_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
hil_main() {
    command -v python3 >/dev/null || { echo 'Fehler: Python 3 fuer den Offline-Prototyp erforderlich.' >&2; return 1; }
    local mode="${1:---dry-run}"
    case "$mode" in
        --dry-run|--plan|plan) mode=plan ;;
        --check|check) mode=check ;;
        --status|status) mode=status ;;
        --repair|repair) mode=repair ;;
        --uninstall|uninstall) mode=uninstall ;;
        install|update|doctor) ;;
        *) echo 'Erlaubt: --dry-run, --plan, --check, --status, --repair, --uninstall.' >&2; return 2 ;;
    esac
    python3 "$HIL_REPO_ROOT/tools/embedded_debug_hil/hil.py" "$mode"
}
