#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/mynextcloud/install_server_dev.sh /path/to/myNextCloud-server [--apply]

Documentation-first dev helper. It checks prerequisites and prints next steps.
It does not install packages unless future versions explicitly add guarded actions.
USAGE
}

need_cmd() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "OK: $cmd"
  else
    echo "FEHLT: $cmd"
  fi
}

main() {
  local repo_dir="${1:-}"
  local mode="${2:-}"
  if [ -z "$repo_dir" ] || [ "${repo_dir:-}" = "-h" ] || [ "${repo_dir:-}" = "--help" ]; then
    usage
    exit 0
  fi
  if [ ! -d "$repo_dir" ]; then
    echo "Fehler: Zielordner fehlt: $repo_dir" >&2
    exit 1
  fi

  echo "myNextCloud Server Dev-Check"
  echo "Repo: $repo_dir"
  echo "Modus: ${mode:-dry-run}"
  need_cmd git
  need_cmd php
  need_cmd composer
  need_cmd node
  need_cmd npm
  need_cmd psql
  need_cmd curl
  df -h "$repo_dir" || true

  cat <<'NEXT'

Naechste manuelle Schritte:
1. .env.example mit scripts/mynextcloud/setup_env.sh erzeugen.
2. Datenverzeichnis ausserhalb des Webroots planen.
3. Datenbank und Webserver lokal einrichten.
4. Branding-/Lizenz-Checkliste vor erstem Build abarbeiten.

Docker ist optional und wird hier nicht erzwungen.
NEXT
}

main "$@"
