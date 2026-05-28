#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$ROOT_DIR/logs"
LOG_FILE="$LOG_DIR/openhiggsstack-install.log"
START_TS="$(date +%s)"

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOG_FILE"
}

fail() {
  log "FEHLER: $*"
  log "Letztes Protokoll: $LOG_FILE"
  exit 1
}

run() {
  log "+ $*"
  "$@" 2>&1 | tee -a "$LOG_FILE"
}

detect_os() {
  if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "wsl2"
  elif [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "${ID:-linux}"
  else
    echo "unknown"
  fi
}

free_kb() {
  df -Pk "${OPENHIGGSSTACK_HOME:-$HOME/ai-stack}" 2>/dev/null | awk 'NR==2 {print $4}'
}

install_package_if_possible() {
  local pkg="$1"
  if command -v "$pkg" >/dev/null 2>&1; then
    log "$pkg ist bereits vorhanden."
    return 0
  fi

  if command -v apt-get >/dev/null 2>&1; then
    log "Installiere Paket: $pkg"
    run sudo apt-get update
    run sudo apt-get install -y "$pkg"
  else
    log "Kein apt-get gefunden. Bitte $pkg manuell installieren."
  fi
}

confirm() {
  local prompt="$1"
  local answer
  read -r -p "$prompt [j/N] " answer
  case "$answer" in
    y|Y|yes|YES|j|J|ja|JA) return 0 ;;
    *) return 1 ;;
  esac
}

OPENHIGGSSTACK_HOME="${OPENHIGGSSTACK_HOME:-$HOME/ai-stack}"
COMFYUI_DIR="$OPENHIGGSSTACK_HOME/comfyui"
USER_ENV_DIR="$HOME/.openclaw_ultimate_user_data/openhiggsstack"

log "Starte OpenHiggsStack Installation."
log "OS-Erkennung: $(detect_os)"
log "Zielordner: $OPENHIGGSSTACK_HOME"
log "Freier Speicher vorher: $(( $(free_kb 2>/dev/null || echo 0) / 1024 )) MB"

command -v git >/dev/null 2>&1 || install_package_if_possible git
command -v python3 >/dev/null 2>&1 || install_package_if_possible python3
command -v ffmpeg >/dev/null 2>&1 || install_package_if_possible ffmpeg
python3 -m venv --help >/dev/null 2>&1 || install_package_if_possible python3-venv

command -v git >/dev/null 2>&1 || fail "git fehlt."
command -v python3 >/dev/null 2>&1 || fail "python3 fehlt."
command -v ffmpeg >/dev/null 2>&1 || log "Warnung: ffmpeg ist nicht im PATH. Postprocessing funktioniert erst nach Installation."

mkdir -p \
  "$OPENHIGGSSTACK_HOME/models/image" \
  "$OPENHIGGSSTACK_HOME/models/video" \
  "$OPENHIGGSSTACK_HOME/models/vae" \
  "$OPENHIGGSSTACK_HOME/models/loras" \
  "$OPENHIGGSSTACK_HOME/outputs/video" \
  "$OPENHIGGSSTACK_HOME/outputs/image" \
  "$OPENHIGGSSTACK_HOME/outputs/audio" \
  "$OPENHIGGSSTACK_HOME/workflows/comfyui" \
  "$OPENHIGGSSTACK_HOME/workflows/n8n" \
  "$OPENHIGGSSTACK_HOME/prompts" \
  "$OPENHIGGSSTACK_HOME/logs" \
  "$HOME/.openclaw/agents/video-director" \
  "$USER_ENV_DIR"

if [ ! -f "$USER_ENV_DIR/.env" ]; then
  cp "$ROOT_DIR/.env.openhiggsstack.example" "$USER_ENV_DIR/.env"
  log "Beispielkonfiguration kopiert nach: $USER_ENV_DIR/.env"
else
  log "Bestehende Konfiguration bleibt erhalten: $USER_ENV_DIR/.env"
fi

if [ -d "$COMFYUI_DIR/.git" ]; then
  log "ComfyUI existiert bereits. Aktualisierung wird nicht automatisch erzwungen."
elif confirm "ComfyUI nach $COMFYUI_DIR klonen?"; then
  run git clone https://github.com/comfy-org/ComfyUI.git "$COMFYUI_DIR"
  (
    cd "$COMFYUI_DIR"
    run python3 -m venv venv
    # shellcheck disable=SC1091
    source venv/bin/activate
    run pip install --upgrade pip
    run pip install -r requirements.txt
  )
else
  log "ComfyUI-Klon uebersprungen."
fi

if confirm "Grosse Wan2.x-/Flux-/Video-Modelle jetzt automatisch herunterladen?"; then
  log "Automatischer Modelldownload ist in diesem Setup bewusst deaktiviert."
  log "Bitte lade Modelle manuell passend zu VRAM, Lizenz und Workflow herunter."
else
  log "Keine grossen Modelle heruntergeladen."
fi

END_TS="$(date +%s)"
log "Freier Speicher nachher: $(( $(free_kb 2>/dev/null || echo 0) / 1024 )) MB"
log "Installationsdauer: $((END_TS - START_TS)) Sekunden"
log "OpenHiggsStack Vorbereitung abgeschlossen."
log "Naechster Schritt: ComfyUI starten und Wan2.x-Workflow manuell importieren."
