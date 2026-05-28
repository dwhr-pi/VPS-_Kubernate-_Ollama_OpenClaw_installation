#!/usr/bin/env bash
set -euo pipefail

OLLAMA_BASE_URL="${OLLAMA_BASE_URL:-http://127.0.0.1:11434}"
OLLAMA_MODEL="${OLLAMA_MODEL:-llama3.2:1b}"

usage() {
  cat <<'USAGE'
Usage: scripts/mynextcloud/scan_files_with_ollama.sh FILE_OR_DIR [--apply]

Dry-run by default. With --apply, text-like files are summarized via local Ollama
and a .summary.md file is written next to each source file.
USAGE
}

json_escape() {
  python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}

summarize_file() {
  local file="$1"
  local out="${file}.summary.md"
  local prompt
  prompt="$(printf 'Fasse diese Datei kurz zusammen, schlage Tags vor und nenne Sicherheitsauffaelligkeiten. Datei:\n\n%s' "$(sed -n '1,400p' "$file")" | json_escape)"
  curl -fsS "$OLLAMA_BASE_URL/api/generate" \
    -H 'Content-Type: application/json' \
    -d "{\"model\":\"$OLLAMA_MODEL\",\"prompt\":$prompt,\"stream\":false}" \
    | python3 -c 'import json,sys; print(json.load(sys.stdin).get("response",""))' > "$out"
  echo "Geschrieben: $out"
}

main() {
  local target="${1:-}"
  local mode="${2:-}"
  if [ -z "$target" ] || [ "${target:-}" = "-h" ] || [ "${target:-}" = "--help" ]; then
    usage
    exit 0
  fi
  if [ "$mode" != "--apply" ]; then
    echo "DRY-RUN: wuerde Textdateien unter '$target' mit Ollama $OLLAMA_MODEL analysieren."
    echo "Ollama URL: $OLLAMA_BASE_URL"
    exit 0
  fi
  command -v python3 >/dev/null 2>&1 || { echo "Fehler: python3 fehlt" >&2; exit 1; }
  curl -fsS "$OLLAMA_BASE_URL/api/tags" >/dev/null

  if [ -f "$target" ]; then
    summarize_file "$target"
  else
    find "$target" -type f \( -name '*.txt' -o -name '*.md' -o -name '*.json' -o -name '*.csv' \) -print0 |
      while IFS= read -r -d '' file; do summarize_file "$file"; done
  fi
}

main "$@"
