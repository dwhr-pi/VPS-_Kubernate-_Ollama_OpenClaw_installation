#!/usr/bin/env bash
set -euo pipefail
video_dataset_candidate_main() {
  case "${1:---dry-run}" in
    --dry-run | --plan | plan | check | --check | status | --status | doctor | --doctor)
      printf '%s\n' '{"status":"planned","installed":false,"network":false,"training_enabled":false,"scope":"video_dataset_registration_only"}'
      ;;
    *)
      echo 'Dataset-Werkzeuge sind documentation-first: keine Installation, Downloads, Trainingsjobs oder Loeschungen. Siehe docs/media_studio/VIDEO_TRAINING_DATASETS.md.' >&2
      return 2
      ;;
  esac
}
