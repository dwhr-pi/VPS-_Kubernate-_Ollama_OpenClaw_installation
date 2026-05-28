#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMPLATE="$REPO_ROOT/docs/tools/mynextcloud/server_env.example"

usage() {
  cat <<'USAGE'
Usage: scripts/mynextcloud/setup_env.sh /path/to/myNextCloud-server [--apply]

Creates .env.example in the server fork from the Ultimate KI Setup template.
Never creates .env and never writes real secrets.
USAGE
}

main() {
  local target_dir="${1:-}"
  local mode="${2:-}"
  if [ -z "$target_dir" ] || [ "${target_dir:-}" = "-h" ] || [ "${target_dir:-}" = "--help" ]; then
    usage
    exit 0
  fi
  if [ ! -f "$TEMPLATE" ]; then
    echo "Fehler: Vorlage fehlt: $TEMPLATE" >&2
    exit 1
  fi
  if [ ! -d "$target_dir" ]; then
    echo "Fehler: Zielordner fehlt: $target_dir" >&2
    exit 1
  fi

  local target="$target_dir/.env.example"
  if [ "$mode" != "--apply" ]; then
    echo "DRY-RUN: wuerde $TEMPLATE nach $target kopieren."
    exit 0
  fi
  if [ -e "$target" ]; then
    echo "Abbruch: $target existiert bereits. Bitte manuell vergleichen."
    exit 1
  fi
  cp "$TEMPLATE" "$target"
  echo "Erstellt: $target"
}

main "$@"
