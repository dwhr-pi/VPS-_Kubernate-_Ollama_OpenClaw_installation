#!/usr/bin/env bash
set -euo pipefail
AUTOMATON_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
automaton_main() {
    local mode="${1:---dry-run}"
    case "$mode" in
        --dry-run|--plan) mode=plan ;;
        --check) mode=check ;;
        --status) mode=status ;;
        --repair) mode=repair ;;
        --uninstall) mode=uninstall ;;
    esac
    command -v python3 >/dev/null || { echo 'Python 3 fuer den Offline-Integrationscheck erforderlich.' >&2; return 1; }
    python3 "$AUTOMATON_REPO_ROOT/tools/automaton/review.py" "$mode"
}
