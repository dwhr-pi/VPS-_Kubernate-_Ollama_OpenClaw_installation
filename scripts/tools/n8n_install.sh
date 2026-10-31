#!/bin/bash
# ==============================================================================

set -euo pipefail
# N8N_INSTALL.SH - Installation von n8n
# n8n ist ein Workflow-Automatisierungstool, das viele Apps und Dienste verbindet.
# ==============================================================================

# Farben
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"

N8N_DIR="/opt/n8n"
N8N_MIN_FREE_GB="${N8N_MIN_FREE_GB:-20}"
N8N_RECOMMENDED_FREE_GB="${N8N_RECOMMENDED_FREE_GB:-40}"

check_n8n_node_version() {
  local version major minor
  if ! command -v node >/dev/null 2>&1; then
    echo 'Fehler: Node fehlt. n8n benoetigt mindestens Node 22.22.0.' >&2
    return 1
  fi
  version="$(node --version)" || return 1
  if ! [[ "$version" =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    echo "Fehler: Node-Version nicht auswertbar: $version" >&2
    return 1
  fi
  major="${BASH_REMATCH[1]}" minor="${BASH_REMATCH[2]}"
  if ((major < 22 || (major == 22 && minor < 22))); then
    echo "Fehler: n8n benoetigt Node >=22.22.0; gefunden: $version." >&2
    echo 'Eine passende Node-Version aktivieren und den Installer erneut starten. Das System-Node wird nicht automatisch ersetzt.' >&2
    return 1
  fi
}

free_gb_for_path() {
  local path="$1"
  df -BG "$path" 2>/dev/null | awk 'NR==2 {gsub("G","",$4); print $4}'
}

check_n8n_disk_space() {
  local target_parent="/opt"
  local free_gb

  free_gb="$(free_gb_for_path "$target_parent")"
  if [ -z "$free_gb" ]; then
    free_gb="$(free_gb_for_path /)"
  fi

  echo -e "${BLUE}Speicherplatzpruefung fuer n8n GitHub-Build:${NC}"
  echo -e "${BLUE}- Freier Speicher auf $target_parent: ${free_gb:-unbekannt} GB${NC}"
  echo -e "${BLUE}- Geschaetzter Bedarf fuer n8n aus GitHub: ca. 5-15 GB dauerhaft, zusaetzlich temporaerer pnpm-/Build-Cache.${NC}"
  echo -e "${BLUE}- Empfohlen vor Start: ${N8N_RECOMMENDED_FREE_GB} GB frei; absolutes Minimum: ${N8N_MIN_FREE_GB} GB frei.${NC}"
  echo -e "${YELLOW}Hinweis: Der n8n-Monorepo-Build kann bei @n8n/chat:build mit 'Terminated' abbrechen, wenn RAM, Swap oder freier Speicher knapp sind.${NC}"

  if [ -n "$free_gb" ] && [ "$free_gb" -lt "$N8N_MIN_FREE_GB" ]; then
    echo -e "${RED}Fehler: Zu wenig freier Speicher fuer den n8n GitHub-Build. Bitte Speicher freigeben oder Zielsystem erweitern.${NC}"
    exit 1
  fi

  if [ -n "$free_gb" ] && [ "$free_gb" -lt "$N8N_RECOMMENDED_FREE_GB" ]; then
    echo -e "${YELLOW}Warnung: Der freie Speicher liegt unter der Empfehlung. Der Build kann trotzdem starten, aber Abbrueche sind wahrscheinlicher.${NC}"
  fi
}

echo -e "${BLUE}Starte Installation von n8n aus GitHub...${NC}"
check_n8n_node_version || exit 1
# Do not infer Ubuntu nodejs/npm: those can provide an incompatible Node 18.
AUTO_INSTALL_TOOL_BASE_DEPS=false init_tool_tracking "n8n"
check_n8n_disk_space

if ! command -v git >/dev/null 2>&1 || ! command -v make >/dev/null 2>&1 ||
  ! command -v g++ >/dev/null 2>&1 || ! command -v python3 >/dev/null 2>&1; then
  run_apt_with_lock_wait update
  run_apt_with_lock_wait install -y git build-essential python3
fi

# 1. n8n aus GitHub klonen
if [ -d "$N8N_DIR" ]; then
  echo -e "${YELLOW}n8n Verzeichnis $N8N_DIR existiert bereits. Aktualisiere Repository...${NC}"
  cd "$N8N_DIR" || exit 1
  git pull --ff-only || exit 1
else
  echo -e "${BLUE}Klone n8n in $N8N_DIR...${NC}"
  sudo mkdir -p "$N8N_DIR"
  sudo chown -R "$USER:$USER" "$N8N_DIR"
  GIT_TERMINAL_PROMPT=0 git clone https://github.com/n8n-io/n8n.git "$N8N_DIR" || exit 1
  cd "$N8N_DIR" || exit 1
fi

# 2. Abhängigkeiten installieren mit pnpm
if command -v corepack >/dev/null 2>&1; then
  N8N_PNPM=(corepack pnpm)
elif command -v pnpm >/dev/null 2>&1; then
  N8N_PNPM=(pnpm)
else
  echo 'Fehler: pnpm/Corepack fehlt. Passenden Paketmanager zur aktiven Node-Version bereitstellen.' >&2
  exit 1
fi
expected_pnpm="$(node -p "require('./package.json').packageManager || ''")"
expected_pnpm="${expected_pnpm#pnpm@}"
expected_pnpm="${expected_pnpm%%+*}"
actual_pnpm="$("${N8N_PNPM[@]}" --version)" || exit 1
if [ -n "$expected_pnpm" ] && [ "$actual_pnpm" != "$expected_pnpm" ]; then
  echo "Fehler: Dieses n8n-Checkout verlangt pnpm ${expected_pnpm}; aktiv ist ${actual_pnpm}. Corepack oder passende pnpm-Version verwenden." >&2
  exit 1
fi
echo -e "${BLUE}Installiere Abhängigkeiten für n8n mit pnpm...${NC}"
if ! "${N8N_PNPM[@]}" install --frozen-lockfile --config.engine-strict=true; then
  echo -e "${RED}Fehler: pnpm install für n8n fehlgeschlagen.${NC}"
  exit 1
fi

# 3. n8n bauen
echo -e "${BLUE}Baue n8n mit pnpm...${NC}"
if ! "${N8N_PNPM[@]}" build; then
  echo -e "${RED}Fehler: pnpm build für n8n aus dem GitHub-Monorepo ist fehlgeschlagen.${NC}"
  echo -e "${YELLOW}Wenn im Log '@n8n/chat:build' und 'Terminated' steht, wurde der Build wahrscheinlich durch RAM-/Swap-/Speichermangel beendet.${NC}"
  echo -e "${YELLOW}Pruefe freien Speicher mit 'df -h', RAM/Swap mit 'free -h' und wiederhole danach die GitHub-Installation.${NC}"
  exit 1
fi

# 4. Konfiguration und Start (Platzhalter)
echo -e "${YELLOW}Hinweis: n8n Konfiguration und Start als Service müssen eventuell manuell angepasst werden.${NC}"
echo -e "${YELLOW}Standardmäßig startet n8n auf Port 5678.${NC}"

echo -e "${GREEN}n8n Installation abgeschlossen.${NC}"
mark_current_tool_installed
