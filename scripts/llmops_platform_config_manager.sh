#!/bin/bash
# ==============================================================================
# LLMOPS_PLATFORM_CONFIG_MANAGER.SH - Verwaltet die LLMOps-Stack-.env
# Analog zum OpenClaw-Konfigurations-Manager, aber fuer stacks/llmops-platform.
# ==============================================================================

umask 077
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
USER_WORKSPACE_DIR="${USER_WORKSPACE_DIR:-${HOME}/.openclaw_ultimate_user_data}"
LLMOPS_TEMPLATE_DIR="$USER_WORKSPACE_DIR/llmops-platform"
LLMOPS_STACK_DIR="$LLMOPS_TEMPLATE_DIR"
LLMOPS_TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/llmops-config.XXXXXXXX")" || exit 1
LLMOPS_CHOICE_FILE="$LLMOPS_TEMP_DIR/choice"

ensure_user_workspace() {
  python3 -I -B "$INSTALL_DIR/scripts/security/private_env.py" prepare \
    --workspace "$USER_WORKSPACE_DIR" --repo "$INSTALL_DIR" \
    --source "$INSTALL_DIR/scripts/config_templates/llmops-platform/.env.template"
}

cleanup_temp_files() {
  rm -f "$LLMOPS_CHOICE_FILE"
  rmdir -- "$LLMOPS_TEMP_DIR" 2>/dev/null || true
}

pause_screen() {
  read -r -p "Druecken Sie Enter..."
}

edit_file() {
  local file_path="$1"

  if [ ! -f "$file_path" ]; then
    echo -e "${RED}Fehler: Datei nicht gefunden: ${file_path}${NC}"
    pause_screen
    return 1
  fi

  echo -e "${BLUE}Oeffne Datei zum Bearbeiten: ${file_path}${NC}"
  echo -e "${YELLOW}Hinweis: Diese Vorlage ist fuer LiteLLM, Ollama, Open WebUI und OpenClaw-nahe Nutzung abgestimmt.${NC}"
  if command -v nano >/dev/null 2>&1; then
    nano "$file_path"
  elif command -v vi >/dev/null 2>&1; then
    vi "$file_path"
  else
    echo -e "${RED}Kein geeigneter Texteditor (nano oder vi) gefunden. Bitte bearbeiten Sie die Datei manuell: ${file_path}${NC}"
    pause_screen
  fi
}

apply_env() {
  local template_file="$LLMOPS_TEMPLATE_DIR/.env.template"
  local target_file="$LLMOPS_STACK_DIR/.env"

  if [ ! -f "$template_file" ]; then
    echo -e "${RED}Fehler: Vorlagendatei ${template_file} nicht gefunden.${NC}"
    return 1
  fi

  if [ ! -d "$LLMOPS_STACK_DIR" ]; then
    echo -e "${RED}Fehler: Stack-Verzeichnis ${LLMOPS_STACK_DIR} nicht gefunden.${NC}"
    return 1
  fi

  if [ -L "$template_file" ] || [ -L "$target_file" ] || [ -L "$LLMOPS_STACK_DIR" ]; then
    echo -e "${RED}Verlinkte Konfigurationspfade sind nicht erlaubt.${NC}"
    return 1
  fi
  local -a replacement=()
  if [[ -e "$target_file" ]]; then
    local answer
    read -r -p 'Vorhandene private ENV bewusst ersetzen? [j/N] ' answer || return 1
    case "$answer" in j | ja | y | yes) replacement=(--replace) ;; *) return 1 ;; esac
  fi
  python3 -I -B "$INSTALL_DIR/scripts/security/private_env.py" apply \
    --workspace "$USER_WORKSPACE_DIR" --repo "$INSTALL_DIR" \
    --source "$template_file" "${replacement[@]}" || return 1
  echo -e "${GREEN}LLMOps-Stack-.env erfolgreich nach ${target_file} angewendet.${NC}"
  echo -e "${YELLOW}Private Konfiguration, kein automatischer Dienststart. Alte Repo-.env bleibt unveraendert; kein Docker-Installationsweg.${NC}"
}

show_menu() {
  rm -f "$LLMOPS_CHOICE_FILE"
  dialog --clear --backtitle "LLMOps Plattform Konfigurations-Manager" \
    --title "LLMOps Stack .env" --menu "Waehlen Sie eine Option:" 15 70 5 \
    "1" "Bearbeite .env Vorlage" \
    "2" "Wende .env Vorlage auf den Stack an" \
    "3" "Zurueck" 2>"$LLMOPS_CHOICE_FILE"
}

trap cleanup_temp_files EXIT

while true; do
  ensure_user_workspace || break
  if ! show_menu || [ ! -f "$LLMOPS_CHOICE_FILE" ]; then
    break
  fi

  CHOICE="$(tr -d '\r' <"$LLMOPS_CHOICE_FILE")"

  case "$CHOICE" in
    1)
      edit_file "$LLMOPS_TEMPLATE_DIR/.env.template"
      ;;
    2)
      apply_env
      pause_screen
      ;;
    3)
      break
      ;;
    *)
      echo -e "${RED}Ungueltige Auswahl. Bitte versuchen Sie es erneut.${NC}"
      sleep 2
      ;;
  esac
done
