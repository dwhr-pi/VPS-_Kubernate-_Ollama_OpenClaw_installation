#!/usr/bin/env bash
set -euo pipefail

TOOL_NAME="DuckDB"
DUCKDB_VERSION="${DUCKDB_VERSION:-v1.1.3}"
INSTALL_DIR="${DUCKDB_INSTALL_DIR:-/opt/duckdb}"
BIN_LINK="${DUCKDB_BIN_LINK:-/usr/local/bin/duckdb}"
RELEASE_BASE="https://github.com/duckdb/duckdb/releases/download"

usage() {
  cat <<'USAGE'
DuckDB Installer

Installiert DuckDB nicht via apt, weil Ubuntu noble kein offizielles duckdb-Paket bereitstellt.
Stattdessen wird das offizielle GitHub-Release-Binary geladen.

Optionen:
  --dry-run    Nur anzeigen, was passieren wuerde.
  --check      Pruefen, ob duckdb bereits verfuegbar ist.
  --help       Hilfe anzeigen.

Umgebungsvariablen:
  DUCKDB_VERSION     Release-Version, Standard: v1.1.3
  DUCKDB_INSTALL_DIR Installationsziel, Standard: /opt/duckdb
  DUCKDB_BIN_LINK    Symlink, Standard: /usr/local/bin/duckdb
USAGE
}

log() {
  printf '%s\n' "$*"
}

run_cmd() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    printf '[dry-run] %q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

detect_asset() {
  local machine
  machine="$(uname -m)"
  case "$machine" in
    x86_64|amd64)
      printf 'duckdb_cli-linux-amd64.zip'
      ;;
    aarch64|arm64)
      printf 'duckdb_cli-linux-aarch64.zip'
      ;;
    *)
      log "Fehler: Nicht unterstuetzte Architektur fuer DuckDB CLI: $machine" >&2
      return 1
      ;;
  esac
}

check_installed() {
  if command -v duckdb >/dev/null 2>&1; then
    duckdb --version
    return 0
  fi
  log "DuckDB ist noch nicht installiert oder nicht im PATH."
  return 1
}

main() {
  local mode="install"
  DRY_RUN=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        DRY_RUN=1
        ;;
      --check|--status)
        mode="check"
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        log "Unbekannte Option: $1" >&2
        usage >&2
        exit 2
        ;;
    esac
    shift
  done

  if [[ "$mode" == "check" ]]; then
    check_installed
    exit $?
  fi

  if command -v duckdb >/dev/null 2>&1; then
    log "DuckDB ist bereits verfuegbar:"
    duckdb --version
    exit 0
  fi

  local asset url tmpdir archive
  asset="$(detect_asset)"
  url="${RELEASE_BASE}/${DUCKDB_VERSION}/${asset}"
  tmpdir="$(mktemp -d)"
  archive="${tmpdir}/${asset}"

  log "Installiere DuckDB aus offiziellem GitHub-Release:"
  log "  Version: ${DUCKDB_VERSION}"
  log "  Quelle:  ${url}"
  log "  Ziel:    ${INSTALL_DIR}"
  log "Hinweis: DuckDB oeffnet keinen Server-Port und ist fuer lokale Analyse geeignet."

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    run_cmd sudo mkdir -p "$INSTALL_DIR"
    run_cmd curl -fsSL "$url" -o "$archive"
    run_cmd unzip -o "$archive" -d "$INSTALL_DIR"
    run_cmd sudo ln -sf "${INSTALL_DIR}/duckdb" "$BIN_LINK"
    exit 0
  fi

  command -v curl >/dev/null 2>&1 || {
    log "Fehler: curl fehlt. Bitte zuerst curl installieren." >&2
    exit 1
  }
  command -v unzip >/dev/null 2>&1 || {
    log "Fehler: unzip fehlt. Bitte zuerst unzip installieren." >&2
    exit 1
  }

  curl -fsSL "$url" -o "$archive"
  sudo mkdir -p "$INSTALL_DIR"
  sudo unzip -o "$archive" -d "$INSTALL_DIR" >/dev/null
  sudo chmod 0755 "${INSTALL_DIR}/duckdb"
  sudo ln -sf "${INSTALL_DIR}/duckdb" "$BIN_LINK"

  rm -rf "$tmpdir"

  log "DuckDB installiert:"
  duckdb --version
}

main "$@"
