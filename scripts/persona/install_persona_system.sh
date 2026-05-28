#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

PERSONA_WORKSPACE_DIR="${USER_WORKSPACE_DIR}/persona_system"
PERSONA_SOURCE_DIR="$ROOT_DIR/personas"
PERSONA_PROMPT_SOURCE_DIR="$ROOT_DIR/prompts/persona"
PERSONA_MEMORY_SOURCE_DIR="$ROOT_DIR/memory"
PERSONA_DOC_SOURCE_DIR="$ROOT_DIR/docs/Persona"

PERSONA_INSTALL_MEMORY="${PERSONA_INSTALL_MEMORY:-true}"
PERSONA_INSTALL_TTS_HOOKS="${PERSONA_INSTALL_TTS_HOOKS:-false}"
PERSONA_INSTALL_STT_HOOKS="${PERSONA_INSTALL_STT_HOOKS:-false}"
PERSONA_INSTALL_IMAGE_VIDEO_HOOKS="${PERSONA_INSTALL_IMAGE_VIDEO_HOOKS:-false}"
PERSONA_INSTALL_PHONE_CONCEPT="${PERSONA_INSTALL_PHONE_CONCEPT:-true}"
PERSONA_INSTALL_SUNO_EXAMPLES="${PERSONA_INSTALL_SUNO_EXAMPLES:-false}"

ensure_user_workspace

ask_toggle() {
  local var_name="$1"
  local prompt="$2"
  local default_value="$3"
  local current_value="${!var_name:-$default_value}"
  local answer=""

  if [ -t 0 ]; then
    if [ "$current_value" = "true" ]; then
      read -r -p "$prompt [Y/n]: " answer || true
      case "${answer:-}" in
        n|N|no|NO) current_value="false" ;;
        *) current_value="true" ;;
      esac
    else
      read -r -p "$prompt [j/N]: " answer || true
      case "${answer:-}" in
        y|Y|yes|YES|j|J|ja|JA) current_value="true" ;;
        *) current_value="false" ;;
      esac
    fi
  fi

  printf -v "$var_name" '%s' "$current_value"
}

backup_then_copy_file() {
  local source_file="$1"
  local target_file="$2"
  mkdir -p "$(dirname "$target_file")"

  if [ -f "$target_file" ]; then
    local backup_file="${target_file}.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$target_file" "$backup_file"
    log_warn "Bestehende Datei gesichert: $backup_file"
  fi

  cp "$source_file" "$target_file"
}

copy_tree_with_backups() {
  local source_dir="$1"
  local target_dir="$2"
  local file=""

  mkdir -p "$target_dir"
  while IFS= read -r -d '' file; do
    local relative_path="${file#$source_dir/}"
    backup_then_copy_file "$file" "$target_dir/$relative_path"
  done < <(find "$source_dir" -type f -print0)
}

install_validation_tooling() {
  local apt_packages=()
  command -v jq >/dev/null 2>&1 || apt_packages+=(jq)
  command -v python3 >/dev/null 2>&1 || apt_packages+=(python3)
  python3 -c "import yaml" >/dev/null 2>&1 2>/dev/null || apt_packages+=(python3-yaml)

  if [ "${#apt_packages[@]}" -gt 0 ]; then
    log_info "Installiere Validierungswerkzeuge: ${apt_packages[*]}"
    sudo apt-get update
    sudo apt-get install -y "${apt_packages[@]}"
  fi
}

write_workspace_readme() {
  cat > "$PERSONA_WORKSPACE_DIR/README.md" <<EOF
# Persona System Workspace

Dieses Verzeichnis wurde aus dem Repository vorbereitet.

Auswahl:

- Persona System: aktiviert
- Persona Memory: $PERSONA_INSTALL_MEMORY
- Voice / TTS hooks: $PERSONA_INSTALL_TTS_HOOKS
- STT / speech recognition hooks: $PERSONA_INSTALL_STT_HOOKS
- Image/video prompt hooks: $PERSONA_INSTALL_IMAGE_VIDEO_HOOKS
- Telefonzentrale / Fritz!Fon concept docs: $PERSONA_INSTALL_PHONE_CONCEPT
- Suno/music/video memory examples: $PERSONA_INSTALL_SUNO_EXAMPLES

Wichtige Pfade:

- personas/
- prompts/persona/
- memory/
- docs/Persona/
- reports/persona-tests/
EOF
}

ask_toggle PERSONA_INSTALL_MEMORY "Persona Memory vorbereiten?" "true"
ask_toggle PERSONA_INSTALL_TTS_HOOKS "Voice / TTS hooks vorbereiten?" "false"
ask_toggle PERSONA_INSTALL_STT_HOOKS "STT / Speech Recognition hooks vorbereiten?" "false"
ask_toggle PERSONA_INSTALL_IMAGE_VIDEO_HOOKS "Image / Video Prompt hooks vorbereiten?" "false"
ask_toggle PERSONA_INSTALL_PHONE_CONCEPT "Telefonzentrale / Fritz!Fon Konzeptdoku kopieren?" "true"
ask_toggle PERSONA_INSTALL_SUNO_EXAMPLES "Suno / Music / Video Memory Beispiele vorbereiten?" "false"

install_validation_tooling

mkdir -p \
  "$PERSONA_WORKSPACE_DIR/personas" \
  "$PERSONA_WORKSPACE_DIR/prompts/persona" \
  "$PERSONA_WORKSPACE_DIR/docs/Persona" \
  "$PERSONA_WORKSPACE_DIR/reports/persona-tests"

copy_tree_with_backups "$PERSONA_SOURCE_DIR" "$PERSONA_WORKSPACE_DIR/personas"
copy_tree_with_backups "$PERSONA_PROMPT_SOURCE_DIR" "$PERSONA_WORKSPACE_DIR/prompts/persona"
copy_tree_with_backups "$PERSONA_DOC_SOURCE_DIR" "$PERSONA_WORKSPACE_DIR/docs/Persona"

if [ "$PERSONA_INSTALL_MEMORY" = "true" ]; then
  mkdir -p "$PERSONA_WORKSPACE_DIR/memory"
  copy_tree_with_backups "$PERSONA_MEMORY_SOURCE_DIR" "$PERSONA_WORKSPACE_DIR/memory"
fi

if [ "$PERSONA_INSTALL_TTS_HOOKS" = "true" ]; then
  mkdir -p "$PERSONA_WORKSPACE_DIR/hooks/tts"
  cat > "$PERSONA_WORKSPACE_DIR/hooks/tts/README.md" <<'EOF'
# TTS Hooks

Platzhalter fuer spaetere TTS-Anbindung, zum Beispiel Piper oder Coqui.
EOF
fi

if [ "$PERSONA_INSTALL_STT_HOOKS" = "true" ]; then
  mkdir -p "$PERSONA_WORKSPACE_DIR/hooks/stt"
  cat > "$PERSONA_WORKSPACE_DIR/hooks/stt/README.md" <<'EOF'
# STT Hooks

Platzhalter fuer spaetere Spracheingabe, zum Beispiel faster-whisper oder Vosk.
EOF
fi

if [ "$PERSONA_INSTALL_IMAGE_VIDEO_HOOKS" = "true" ]; then
  mkdir -p "$PERSONA_WORKSPACE_DIR/hooks/multimodal"
  cat > "$PERSONA_WORKSPACE_DIR/hooks/multimodal/README.md" <<'EOF'
# Multimodal Hooks

Platzhalter fuer Bild-, Video- und Szenenprompt-Workflows.
EOF
fi

if [ "$PERSONA_INSTALL_PHONE_CONCEPT" = "true" ]; then
  mkdir -p "$PERSONA_WORKSPACE_DIR/hooks/phone"
  cp "$ROOT_DIR/docs/Persona/phone_fritzfon_concept.md" "$PERSONA_WORKSPACE_DIR/hooks/phone/phone_fritzfon_concept.md"
fi

if [ "$PERSONA_INSTALL_SUNO_EXAMPLES" = "true" ]; then
  mkdir -p "$PERSONA_WORKSPACE_DIR/examples/suno"
  cat > "$PERSONA_WORKSPACE_DIR/examples/suno/README.md" <<'EOF'
# Suno / Music / Video Memory Examples

- Beispiel: nostalgischer EDM/K-Pop-Track
- Beispiel: Livestream-Intro aus gemeinsamer Erinnerung
- Beispiel: Musikvideo-Konzept aus Persona-Memory
EOF
fi

write_workspace_readme
log_success "Persona-System-Workspace vorbereitet unter: $PERSONA_WORKSPACE_DIR"
