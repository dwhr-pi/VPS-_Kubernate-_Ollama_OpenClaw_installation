#!/bin/bash
# Gemeinsame Hilfsfunktionen für Node-basierte Tool-Installationen

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

HELPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$HELPER_DIR/../../helpers/status_tracking.sh"

check_node_tool_runtime() {
  local version required="${TOOL_NODE_MIN_VERSION:-}" node_major node_minor node_patch req_major req_minor req_patch
  if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
    echo "Fehler: Node und npm werden fuer ${TOOL_NAME} benoetigt." >&2
    return 1
  fi
  [ -n "$required" ] || return 0
  version="$(node --version)" || return 1
  if ! [[ "$version" =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then return 1; fi
  node_major="${BASH_REMATCH[1]}" node_minor="${BASH_REMATCH[2]}" node_patch="${BASH_REMATCH[3]}"
  if ! [[ "$required" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then return 2; fi
  req_major="${BASH_REMATCH[1]}" req_minor="${BASH_REMATCH[2]}" req_patch="${BASH_REMATCH[3]}"
  if ((node_major < req_major || (node_major == req_major && node_minor < req_minor) || (node_major == req_major && node_minor == req_minor && node_patch < req_patch))); then
    echo "Fehler: ${TOOL_NAME} benoetigt Node >=${required}; gefunden: ${version}. Passende Node-Version aktivieren und Installer erneut starten." >&2
    return 1
  fi
}

check_node_runtime_disk() {
  local free_mb windows_mb
  free_mb="$(df -Pm "$HOME" | awk 'NR==2 {print $4}')" || return 1
  if ! [[ "$free_mb" =~ ^[0-9]+$ ]] || ((free_mb < 4096)); then
    echo 'Fehler: Mindestens 4 GiB freie Reserve im Benutzer-Dateisystem fuer Runtime-Downloads erforderlich.' >&2
    return 1
  fi
  if [ -n "${WSL_DISTRO_NAME:-}" ] && [ -d /mnt/c ]; then
    windows_mb="$(df -Pm /mnt/c | awk 'NR==2 {print $4}')" || return 1
    if ! [[ "$windows_mb" =~ ^[0-9]+$ ]] || ((windows_mb < 10240)); then
      echo 'Fehler: Windows-C: braucht mindestens 10 GiB Reserve vor Runtime-Downloads.' >&2
      return 1
    fi
  fi
}

ensure_node_tool_runtime() {
  if check_node_tool_runtime >/dev/null 2>&1; then return 0; fi
  if [ "${EUID:-0}" -eq 0 ]; then
    echo 'Fehler: Installer ohne sudo als normaler Benutzer starten; kein nvm fuer root.' >&2
    return 1
  fi
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  if ! declare -F nvm >/dev/null && [ -s "$NVM_DIR/nvm.sh" ]; then
    # External nvm checkout, available only after runtime provisioning.
    # shellcheck source=/dev/null
    source "$NVM_DIR/nvm.sh" --no-use || return 1
  fi
  if declare -F nvm >/dev/null; then
    if nvm use 22 >/dev/null 2>&1 && check_node_tool_runtime >/dev/null 2>&1; then return 0; fi
  fi
  check_node_runtime_disk || return 1
  if ! declare -F nvm >/dev/null; then
    if [ -e "$NVM_DIR" ] || [ -L "$NVM_DIR" ]; then
      echo 'Fehler: NVM_DIR existiert ohne nutzbares nvm.sh. Manuell pruefen; kein Ueberschreiben.' >&2
      return 1
    fi
    run_apt_with_lock_wait update || return 1
    run_apt_with_lock_wait install -y git curl ca-certificates tar xz-utils || return 1
    echo 'Installiere nvm v0.40.8 aus GitHub im Benutzerkonto. Keine Shellprofil-Aenderung.'
    GIT_TERMINAL_PROMPT=0 git clone --depth 1 --branch v0.40.8 https://github.com/nvm-sh/nvm.git "$NVM_DIR" || return 1
    # Pinned external nvm checkout, not part of this repository.
    # shellcheck source=/dev/null
    source "$NVM_DIR/nvm.sh" --no-use || return 1
  fi
  echo 'Stelle Node 22 samt npm ueber nvm bereit (nur Binary, kein Source-Build).'
  if ! nvm install -b 22 || ! nvm use 22 || ! check_node_tool_runtime; then
    echo 'Fehler: Node/npm-Bereitstellung fehlgeschlagen. nvm-Ausgabe, npm-prefix und Netzwerk pruefen.' >&2
    return 1
  fi
}

install_node_tool() {
  : "${TOOL_NAME:?TOOL_NAME ist erforderlich}"
  : "${TOOL_KEY:?TOOL_KEY ist erforderlich}"
  : "${TOOL_SLUG:?TOOL_SLUG ist erforderlich}"
  : "${TOOL_NPM_PACKAGES:?TOOL_NPM_PACKAGES ist erforderlich}"

  TOOL_DIR="${TOOL_DIR:-/opt/${TOOL_SLUG}}"
  check_node_tool_runtime || return 1
  AUTO_INSTALL_TOOL_BASE_DEPS=false init_tool_tracking "$TOOL_KEY"

  echo -e "${BLUE}Starte Installation von ${TOOL_NAME}...${NC}"

  if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
    echo -e "${RED}Fehler: Node.js und npm werden für ${TOOL_NAME} benötigt.${NC}"
    exit 1
  fi

  if [ -n "${TOOL_APT_PACKAGES:-}" ]; then
    local package_name
    local -a requested_packages missing_packages=()
    read -r -a requested_packages <<<"$TOOL_APT_PACKAGES"
    for package_name in "${requested_packages[@]}"; do
      if ! dpkg -s "$package_name" >/dev/null 2>&1; then missing_packages+=("$package_name"); fi
    done
    if [ "${#missing_packages[@]}" -gt 0 ]; then
      run_apt_with_lock_wait update || return 1
      run_apt_with_lock_wait install -y "${missing_packages[@]}" || return 1
    fi
  fi

  sudo mkdir -p "$TOOL_DIR"
  sudo chown -R "$USER:$USER" "$TOOL_DIR"

  cd "$TOOL_DIR"
  if [ ! -f package.json ]; then
    npm init -y >/dev/null 2>&1
  fi
  local -a npm_packages
  read -r -a npm_packages <<<"${TOOL_NPM_PACKAGES//$'\n'/ }"
  if ! npm install --engine-strict "${npm_packages[@]}"; then
    echo "Fehler: npm-Installation von ${TOOL_NAME} fehlgeschlagen." >&2
    return 1
  fi
  if [ -n "${TOOL_POST_INSTALL_FUNCTION:-}" ]; then
    if ! declare -F "$TOOL_POST_INSTALL_FUNCTION" >/dev/null || ! "$TOOL_POST_INSTALL_FUNCTION"; then
      echo "Fehler: Smoke-Test von ${TOOL_NAME} fehlgeschlagen." >&2
      return 1
    fi
  fi

  cat >"$TOOL_DIR/README.md" <<EOF
# ${TOOL_NAME}

${TOOL_DESCRIPTION:-Kein Beschreibungstext hinterlegt.}

## Installation

Pfad: ${TOOL_DIR}

## OpenClaw / Ollama Hinweis

${TOOL_OPENCLAW_NOTE:-Keine zusätzlichen Hinweise hinterlegt.}
EOF

  if [ -n "${TOOL_PROMPT_EXAMPLE:-}" ]; then
    cat >"$TOOL_DIR/PROMPT_EXAMPLES.md" <<EOF
${TOOL_PROMPT_EXAMPLE}
EOF
  fi

  mark_current_tool_installed
  echo -e "${GREEN}${TOOL_NAME} wurde erfolgreich installiert.${NC}"
}

uninstall_node_tool() {
  : "${TOOL_NAME:?TOOL_NAME ist erforderlich}"
  : "${TOOL_KEY:?TOOL_KEY ist erforderlich}"
  : "${TOOL_SLUG:?TOOL_SLUG ist erforderlich}"

  TOOL_DIR="${TOOL_DIR:-/opt/${TOOL_SLUG}}"
  init_tool_tracking "$TOOL_KEY"

  echo -e "${BLUE}Starte Deinstallation von ${TOOL_NAME}...${NC}"
  sudo rm -rf "$TOOL_DIR"
  mark_current_tool_removed
  echo -e "${GREEN}${TOOL_NAME} wurde entfernt.${NC}"
}
