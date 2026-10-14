#!/usr/bin/env bash
set -euo pipefail
hybrid_media_candidate_main() {
    case "${1:---dry-run}" in
        --dry-run|--plan|plan|check|--check|status|--status|doctor|--doctor)
            printf '%s\n' '{"status":"planned","installed":false,"network":false,"downloads_enabled":false,"execution_enabled":false,"scope":"hybrid_media_registration_only"}' ;;
        *)
            echo 'Hybrid-Modell-/Medienkandidat ist documentation-first: keine Installation, Modelle, Cloud, Dienste oder WSL-Aenderung. Siehe docs/media_studio/HYBRID_MODELS_AND_WAN.md.' >&2
            return 2 ;;
    esac
}
