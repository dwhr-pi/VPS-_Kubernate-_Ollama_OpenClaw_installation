#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PERSONA_DIR="${1:-$ROOT_DIR/personas}"

if ! command -v jq >/dev/null 2>&1; then
  echo "Fehler: jq wird fuer die Persona-Validierung benoetigt." >&2
  exit 1
fi

required_keys=(id name type languages personality modes memory disclosure)

find "$PERSONA_DIR" -maxdepth 1 -type f -name '*.json' | while IFS= read -r file; do
  echo "Pruefe $file"
  jq empty "$file" >/dev/null

  for key in "${required_keys[@]}"; do
    jq -e "has(\"$key\")" "$file" >/dev/null || {
      echo "Fehler: Pflichtfeld '$key' fehlt in $file" >&2
      exit 1
    }
  done

  for mem_key in long_term daily projects; do
    path_value="$(jq -r ".memory.${mem_key} // empty" "$file")"
    if [ -z "$path_value" ]; then
      echo "Fehler: Memory-Pfad '$mem_key' fehlt in $file" >&2
      exit 1
    fi
  done
done

echo "Persona-Validierung erfolgreich."
