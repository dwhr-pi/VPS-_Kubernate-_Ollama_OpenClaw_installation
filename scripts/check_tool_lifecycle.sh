#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS_DIR="$ROOT_DIR/scripts/tools"
STRICT=0
MAX_REPORT="${MAX_REPORT:-120}"

if [ "${1:-}" = "--strict" ]; then
  STRICT=1
fi

if [ ! -d "$TOOLS_DIR" ]; then
  echo "FEHLER: Tool-Skriptordner fehlt: $TOOLS_DIR" >&2
  exit 1
fi

tmp_report="$(mktemp)"
trap 'rm -f "$tmp_report"' EXIT

total=0
missing=0
shopt -s nullglob

for install_file in "$TOOLS_DIR"/*_install.sh; do
  tool="$(basename "$install_file" "_install.sh")"
  total=$((total + 1))
  for action in check update uninstall doctor status; do
    file="$TOOLS_DIR/${tool}_${action}.sh"
    if [ ! -f "$file" ]; then
      missing=$((missing + 1))
      printf 'FEHLT %-28s %s\n' "$tool" "$action" >> "$tmp_report"
    fi
  done
done

echo "Tool-Lifecycle geprueft: $total Tools mit install-Skript."
if [ "$missing" -eq 0 ]; then
  echo "OK: alle Lifecycle-Dateien vorhanden."
  exit 0
fi

echo "Hinweis: $missing Lifecycle-Dateien fehlen noch."
sort "$tmp_report" | head -n "$MAX_REPORT"
if [ "$(wc -l < "$tmp_report")" -gt "$MAX_REPORT" ]; then
  echo "... weitere Eintraege ausgeblendet. MAX_REPORT=$MAX_REPORT erhoehen fuer mehr Details."
fi

if [ "$STRICT" -eq 1 ]; then
  exit 1
fi

exit 0
