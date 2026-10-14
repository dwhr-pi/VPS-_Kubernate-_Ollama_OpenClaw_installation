#!/usr/bin/env bash
set -euo pipefail
agent_framework_plan() {
    case "${1:---dry-run}" in
        --dry-run|--plan|plan|--check|check|doctor|status|--status)
            printf '%s\n' '{"tool":"Microsoft_Agent_Framework","status":"planned","installed":false,"scope":"registration_only"}'
            ;;
        *)
            echo 'Microsoft Agent Framework: nur geplant. Kein Download/Start/Update/Loeschen. Siehe docs/tools/agentic-coding.md.' >&2
            return 2 ;;
    esac
}
