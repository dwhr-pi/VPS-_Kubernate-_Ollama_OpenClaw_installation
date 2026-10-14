#!/usr/bin/env bash
set -euo pipefail
audio_review_candidate_main() {
    case "${1:---dry-run}" in
        --dry-run|--plan|plan|check|--check|status|--status|doctor|--doctor)
            printf '%s\n' '{"status":"planned","installed":false,"network":false,"processing_enabled":false,"authenticity_verdict":null,"scope":"audio_review_registration_only"}' ;;
        *)
            echo 'Audio-Review-Kandidat ist documentation-first: keine Installation, Bearbeitung, Modelle oder Echtheitsbewertung. Siehe docs/media_studio/AUDIO_DEEPFAKE_REVIEW.md.' >&2
            return 2 ;;
    esac
}
