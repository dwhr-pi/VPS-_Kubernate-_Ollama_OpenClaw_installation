#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${DUCKDB_INSTALL_DIR:-/opt/duckdb}"
BIN_LINK="${DUCKDB_BIN_LINK:-/usr/local/bin/duckdb}"
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    --help|-h)
      cat <<'USAGE'
DuckDB Uninstaller

Optionen:
  --dry-run    Nur anzeigen, was entfernt wuerde.
USAGE
      exit 0
      ;;
    *)
      printf 'Unbekannte Option: %s\n' "$1" >&2
      exit 2
      ;;
  esac
  shift
done

run_cmd() {
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '[dry-run] %q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

printf 'Entferne DuckDB CLI aus %s und %s\n' "$INSTALL_DIR" "$BIN_LINK"
run_cmd sudo rm -f "$BIN_LINK"
run_cmd sudo rm -rf "$INSTALL_DIR"
printf 'DuckDB CLI entfernt. Lokale .duckdb-Datenbanken wurden nicht geloescht.\n'
