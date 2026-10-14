#!/usr/bin/env bash
set -euo pipefail
media_candidate_main() {
    case "${1:---dry-run}" in
        --dry-run|--plan|plan|check|--check|status|--status|doctor)
            printf '%s\n' '{"status":"planned","installed":false,"scope":"media_candidate_registration_only"}' ;;
        *)
            echo 'Medien-Kandidat ist documentation-first: kein Download, Build, Start oder Loeschen. Siehe docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md.' >&2
            return 2 ;;
    esac
}
