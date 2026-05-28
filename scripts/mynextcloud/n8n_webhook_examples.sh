#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${HOME}/.openclaw_ultimate_user_data/mynextcloud/n8n_examples"

usage() {
  cat <<'USAGE'
Usage: scripts/mynextcloud/n8n_webhook_examples.sh [--apply]

Prints or writes minimal n8n workflow payload examples for myNextCloud AI.
USAGE
}

write_example() {
  local name="$1"
  local body="$2"
  if [ "${APPLY:-0}" -eq 1 ]; then
    mkdir -p "$OUT_DIR"
    printf '%s\n' "$body" > "$OUT_DIR/$name.json"
    echo "Geschrieben: $OUT_DIR/$name.json"
  else
    echo "== $name =="
    printf '%s\n' "$body"
  fi
}

APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1
[ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] && { usage; exit 0; }

write_example "new_file_upload" '{
  "name": "myNextCloud new file upload",
  "trigger": "webhook",
  "steps": ["fetch file metadata", "call Ollama", "write .summary.md"]
}'

write_example "audio_uploaded" '{
  "name": "myNextCloud audio uploaded",
  "trigger": "webhook",
  "steps": ["download audio", "call Whisper endpoint", "summarize with Ollama", "write transcript.md"]
}'

write_example "backup_report" '{
  "name": "myNextCloud backup report",
  "trigger": "schedule",
  "steps": ["run backup command", "collect log", "notify Home Assistant"]
}'
