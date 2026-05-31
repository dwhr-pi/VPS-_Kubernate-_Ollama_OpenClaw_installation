#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers/simple_tool_common.sh
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

TOOL_NAME="FinRAG"
INSTALL_DIR="${FINRAG_INSTALL_DIR:-/opt/finrag}"
REPO_URL="$(get_custom_repo_url "FINRAG" "https://github.com/AI4Finance-Foundation/FinRAG.git")"

usage() {
  cat <<'USAGE'
FinRAG Installer

FinRAG benoetigt Python >=3.10 und <3.12. Ubuntu 24.04 liefert standardmaessig
Python 3.12; damit bricht FinRAG beim pip-Build mit
"requires a different Python: 3.12.x not in '<3.12,>=3.10'" ab.

Optionen:
  --check      Nur Python-Kompatibilitaet und vorhandene Installation pruefen.
  --dry-run    Anzeigen, was installiert wuerde.
  --help       Hilfe anzeigen.

Umgebungsvariablen:
  FINRAG_PYTHON_BIN   Expliziter Python-Pfad, z. B. /usr/bin/python3.11
  FINRAG_INSTALL_DIR  Installationsziel, Standard: /opt/finrag
  FINRAG_REPO_URL     Alternative GitHub-Quelle
USAGE
}

log_finrag() {
  printf '%s\n' "$*"
}

python_version_ok() {
  "$1" - <<'PY'
import sys
raise SystemExit(0 if (3, 10) <= sys.version_info < (3, 12) else 1)
PY
}

python_version_text() {
  "$1" - <<'PY'
import sys
print(".".join(map(str, sys.version_info[:3])))
PY
}

find_compatible_python() {
  local candidate
  if [ -n "${FINRAG_PYTHON_BIN:-}" ]; then
    if command -v "$FINRAG_PYTHON_BIN" >/dev/null 2>&1 && python_version_ok "$FINRAG_PYTHON_BIN"; then
      printf '%s\n' "$FINRAG_PYTHON_BIN"
      return 0
    fi
    log_finrag "Fehler: FINRAG_PYTHON_BIN ist gesetzt, aber nicht kompatibel: $FINRAG_PYTHON_BIN" >&2
    return 1
  fi

  for candidate in python3.11 python3.10; do
    if command -v "$candidate" >/dev/null 2>&1 && python_version_ok "$candidate"; then
      command -v "$candidate"
      return 0
    fi
  done

  return 1
}

print_python_help() {
  local default_version="unbekannt"
  if command -v python3 >/dev/null 2>&1; then
    default_version="$(python_version_text python3 2>/dev/null || true)"
  fi

  cat <<EOF
Fehler: Kein kompatibles Python fuer FinRAG gefunden.

FinRAG benoetigt Python >=3.10 und <3.12.
Gefundenes Standard-python3: ${default_version}

Ubuntu 24.04/Noble nutzt standardmaessig Python 3.12. Das ist fuer FinRAG
aktuell nicht kompatibel. Bitte installiere oder verwende Python 3.10/3.11
und starte danach z. B.:

  FINRAG_PYTHON_BIN=/usr/bin/python3.11 bash scripts/tools/finrag_install.sh

Keine automatische Installation von Fremd-Python wird vorgenommen, damit das
System-Python nicht beschaedigt wird.
EOF
}

run_cmd() {
  if [ "${DRY_RUN:-0}" = "1" ]; then
    printf '[dry-run] %q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

main() {
  local mode="install"
  DRY_RUN=0

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --check|--status)
        mode="check"
        ;;
      --dry-run)
        DRY_RUN=1
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        log_finrag "Unbekannte Option: $1" >&2
        usage >&2
        exit 2
        ;;
    esac
    shift
  done

  local python_bin=""
  if ! python_bin="$(find_compatible_python)"; then
    print_python_help >&2
    exit 1
  fi

  log_finrag "FinRAG-kompatibles Python gefunden: $python_bin ($(python_version_text "$python_bin"))"

  if [ "$mode" = "check" ]; then
    if [ -x "$INSTALL_DIR/.venv/bin/python" ]; then
      log_finrag "FinRAG-Venv vorhanden: $INSTALL_DIR/.venv"
    else
      log_finrag "FinRAG ist noch nicht installiert."
    fi
    exit 0
  fi

  begin_measurement "tool_install_${TOOL_NAME}" "Tool installieren: ${TOOL_NAME}"

  if ! ensure_user_workspace || ! require_disk_mb 1024 /; then
    end_measurement "failed"
    return 1
  fi

  ensure_base_apt_packages git python3-venv python3-pip python3-dev build-essential pkg-config

  log_finrag "Installiere FinRAG aus GitHub: $REPO_URL"
  log_finrag "Ziel: $INSTALL_DIR"

  if [ "$DRY_RUN" = "1" ]; then
    run_cmd sudo mkdir -p "$(dirname "$INSTALL_DIR")"
    run_cmd git clone "$REPO_URL" "$INSTALL_DIR"
    run_cmd "$python_bin" -m venv "$INSTALL_DIR/.venv"
    run_cmd "$INSTALL_DIR/.venv/bin/pip" install --upgrade pip setuptools wheel
    run_cmd "$INSTALL_DIR/.venv/bin/pip" install -e "$INSTALL_DIR"
    end_measurement "success"
    exit 0
  fi

  sudo mkdir -p "$(dirname "$INSTALL_DIR")"
  sudo chown -R "$USER":"$USER" "$(dirname "$INSTALL_DIR")"

  if [ ! -d "$INSTALL_DIR/.git" ]; then
    git clone "$REPO_URL" "$INSTALL_DIR"
  else
    git -C "$INSTALL_DIR" fetch origin --prune
    git -C "$INSTALL_DIR" pull --ff-only || true
  fi

  "$python_bin" -m venv "$INSTALL_DIR/.venv"
  # shellcheck disable=SC1091
  source "$INSTALL_DIR/.venv/bin/activate"
  pip install --upgrade pip setuptools wheel
  pip install -e "$INSTALL_DIR"
  deactivate || true

  mark_tool_installed "$TOOL_NAME"
  log_success "${TOOL_NAME} installiert."
  end_measurement "success"
}

main "$@"
