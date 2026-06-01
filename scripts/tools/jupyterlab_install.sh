#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers/simple_tool_common.sh
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

TOOL_NAME="JupyterLab"
INSTALL_DIR="${JUPYTERLAB_DIR:-/opt/jupyterlab}"
VENV_DIR="${INSTALL_DIR}/.venv"
BIN_LINK="${JUPYTERLAB_BIN:-/usr/local/bin/jupyter-lab-openclaw}"
INSTALL_MODE="${JUPYTERLAB_INSTALL_MODE:-pypi}"
JUPYTERLAB_VERSION="${JUPYTERLAB_VERSION:-}"
SOURCE_REPO="${JUPYTERLAB_SOURCE_REPO:-https://github.com/jupyterlab/jupyterlab.git}"
SOURCE_REF="${JUPYTERLAB_SOURCE_REF:-}"

usage() {
  cat <<'USAGE'
JupyterLab Installer

Standardpfad:
  Installiert den stabilen JupyterLab-Release in ein isoliertes Python-venv.
  Das vermeidet den schweren GitHub-Source-Build, der Node.js 20.19+ oder
  22.12+ benoetigt und auf Ubuntu/WSL mit Node 18 haeufig scheitert.

Optionen:
  --check      JupyterLab-Version pruefen
  --dry-run    Nur anzeigen, was passieren wuerde
  --help       Hilfe anzeigen

Umgebungsvariablen:
  JUPYTERLAB_VERSION       optionale feste Version, z. B. 4.3.5
  JUPYTERLAB_INSTALL_MODE  pypi (Standard) oder source
  JUPYTERLAB_DIR           Ziel, Standard: /opt/jupyterlab
  JUPYTERLAB_BIN           Symlink, Standard: /usr/local/bin/jupyter-lab-openclaw

Source-Modus:
  JUPYTERLAB_INSTALL_MODE=source bash scripts/tools/jupyterlab_install.sh
  Nur fuer Entwickler. Benoetigt Node.js 20.19+ oder 22.12+.
USAGE
}

DRY_RUN=0

run_cmd() {
  if [ "$DRY_RUN" = "1" ]; then
    printf '[dry-run] %q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

node_version_supported_for_source_build() {
  command -v node >/dev/null 2>&1 || return 1
  node -e '
const v = process.versions.node.split(".").map(Number);
const ok = (v[0] === 20 && v[1] >= 19) || v[0] > 20 || (v[0] === 22 && v[1] >= 12);
process.exit(ok ? 0 : 1);
' >/dev/null 2>&1
}

check_installed() {
  if [ -x "$VENV_DIR/bin/jupyter-lab" ]; then
    "$VENV_DIR/bin/jupyter-lab" --version
    return 0
  fi
  if command -v jupyter-lab-openclaw >/dev/null 2>&1; then
    jupyter-lab-openclaw --version
    return 0
  fi
  if command -v jupyter >/dev/null 2>&1; then
    jupyter lab --version
    return 0
  fi
  log_warn "JupyterLab ist noch nicht installiert oder nicht im PATH."
  return 1
}

install_from_pypi() {
  local package_spec="jupyterlab"
  if [ -n "$JUPYTERLAB_VERSION" ]; then
    package_spec="jupyterlab==${JUPYTERLAB_VERSION}"
  fi

  log_info "Installiere JupyterLab stabil ueber PyPI in isoliertes venv."
  log_info "GitHub-Projekt zur Nachvollziehbarkeit: https://github.com/jupyterlab/jupyterlab"
  log_info "Ziel: ${INSTALL_DIR}"
  log_info "CLI-Symlink: ${BIN_LINK}"

  run_cmd sudo mkdir -p "$INSTALL_DIR"
  run_cmd sudo chown -R "$USER:$USER" "$INSTALL_DIR"
  run_cmd python3 -m venv "$VENV_DIR"
  run_cmd "$VENV_DIR/bin/python" -m pip install --upgrade pip setuptools wheel
  run_cmd "$VENV_DIR/bin/python" -m pip install "$package_spec"
  run_cmd sudo ln -sf "$VENV_DIR/bin/jupyter-lab" "$BIN_LINK"
}

install_from_source() {
  log_warn "JupyterLab Source-Build ist schwer und fuer normale Installationen nicht empfohlen."
  if ! node_version_supported_for_source_build; then
    log_error "JupyterLab Source-Build benoetigt Node.js 20.19+ oder 22.12+."
    log_error "Gefunden: $(node --version 2>/dev/null || echo 'node nicht installiert')"
    log_error "Nutze den Standardpfad ohne Source-Build: JUPYTERLAB_INSTALL_MODE=pypi"
    return 1
  fi

  ensure_base_apt_packages git python3 python3-venv python3-pip python3-dev build-essential pkg-config
  run_cmd sudo mkdir -p "$(dirname "$INSTALL_DIR")"
  run_cmd sudo chown -R "$USER:$USER" "$(dirname "$INSTALL_DIR")"
  if [ "$DRY_RUN" = "1" ]; then
    run_cmd git clone "$SOURCE_REPO" "$INSTALL_DIR"
  else
    clone_or_update_git_target "$TOOL_NAME" "$SOURCE_REPO" "$INSTALL_DIR"
    if [ -n "$SOURCE_REF" ]; then
      git -C "$INSTALL_DIR" checkout "$SOURCE_REF"
    fi
  fi
  run_cmd python3 -m venv "$VENV_DIR"
  run_cmd "$VENV_DIR/bin/python" -m pip install --upgrade pip setuptools wheel
  run_cmd "$VENV_DIR/bin/python" -m pip install -e "$INSTALL_DIR"
  run_cmd sudo ln -sf "$VENV_DIR/bin/jupyter-lab" "$BIN_LINK"
}

main() {
  local mode="install"
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
        log_error "Unbekannte Option: $1"
        usage >&2
        exit 2
        ;;
    esac
    shift
  done

  if [ "$mode" = "check" ]; then
    check_installed
    exit $?
  fi

  begin_measurement "tool_install_${TOOL_NAME}" "Tool installieren: ${TOOL_NAME}"
  if ! ensure_user_workspace || ! require_disk_mb 1024 /; then
    end_measurement "failed"
    return 1
  fi

  ensure_base_apt_packages python3 python3-venv python3-pip

  case "$INSTALL_MODE" in
    pypi)
      install_from_pypi
      ;;
    source)
      install_from_source
      ;;
    *)
      log_error "Unbekannter JUPYTERLAB_INSTALL_MODE=${INSTALL_MODE}. Erlaubt: pypi, source."
      end_measurement "failed"
      return 2
      ;;
  esac

  if [ "$DRY_RUN" != "1" ]; then
    "$VENV_DIR/bin/jupyter-lab" --version
    mark_tool_installed "$TOOL_NAME"
  fi
  log_success "${TOOL_NAME} installiert."
  end_measurement "success"
}

main "$@"

