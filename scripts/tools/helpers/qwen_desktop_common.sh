#!/usr/bin/env bash
set -euo pipefail
qwen_desktop_main() {
    case "${1:---dry-run}" in
        --dry-run|--plan|plan|check|--check|status|--status|doctor|--doctor)
            printf '%s\n' '{"status":"planned","installed":false,"platform":"windows-manual","network":false,"scope":"registration_only"}' ;;
        *)
            printf '%s\n' 'Qwen Code Desktop wird nativ unter Windows manuell installiert, nicht in WSL.' 'Download: https://github.com/QwenLM/qwen-code/releases/tag/desktop-latest' 'Anleitung: docs/tools/qwen-desktop-windows.md' 'Keine Installation, Aktualisierung, Deinstallation oder Datenloeschung ausgefuehrt.' >&2
            return 2 ;;
    esac
}
