#!/usr/bin/env bash
set -euo pipefail

TOOL_NAME="AI-ContentMultiplier"
PROJECT_DIR="${AI_CONTENT_MULTIPLIER_PROJECT_DIR:-/mnt/c/Users/danie/Documents/GitHub/content-multiplier}"
USER_DIR="${AI_CONTENT_MULTIPLIER_USER_DIR:-$HOME/.openclaw_ultimate_user_data/content-multiplier}"
GIT_URL="${AI_CONTENT_MULTIPLIER_GIT_URL:-https://github.com/dwhr-pi/content-multiplier.git}"

if [[ "$PROJECT_DIR" == /mnt/c/* && ! -e "$PROJECT_DIR" && -e "/c/${PROJECT_DIR#/mnt/c/}" ]]; then
  PROJECT_DIR="/c/${PROJECT_DIR#/mnt/c/}"
fi

usage() {
  cat <<'EOF'
AI-ContentMultiplier Workflow-Setup

Usage:
  bash scripts/tools/ai_content_multiplier_install.sh [--dry-run|--status|--update|--help]

Dieses Tool ist ein Workflow und installiert standardmaessig keine schweren
Abhaengigkeiten. Es bereitet lokale Konfigurations- und Ausgabeordner vor.
Wenn der Projektordner fehlt, kann er aus der GitHub-Quelle geklont werden.
EOF
}

status() {
  echo "$TOOL_NAME Status"
  echo "Projektordner: $PROJECT_DIR"
  echo "User-Daten:    $USER_DIR"
  echo "Git-Quelle:    $GIT_URL"
  [[ -d "$PROJECT_DIR" ]] && echo "Projektordner: vorhanden" || echo "Projektordner: fehlt"
  [[ -f "$PROJECT_DIR/README.md" ]] && echo "Doku: vorhanden" || echo "Doku: fehlt"
  [[ -d "$USER_DIR" ]] && echo "User-Ordner: vorhanden" || echo "User-Ordner: fehlt"
  [[ -f "$USER_DIR/.env" ]] && echo "Lokale .env: vorhanden" || echo "Lokale .env: fehlt"
  if [[ -d "$PROJECT_DIR/.git" ]]; then
    git -C "$PROJECT_DIR" remote -v 2>/dev/null || true
  fi
}

dry_run() {
  echo "Dry-run fuer $TOOL_NAME"
  if [[ ! -d "$PROJECT_DIR" ]]; then
    echo "Wuerde GitHub-Quelle klonen: $GIT_URL -> $PROJECT_DIR"
  else
    echo "Projektordner existiert bereits und wuerde nicht ueberschrieben: $PROJECT_DIR"
  fi
  echo "Wuerde User-Ordner anlegen: $USER_DIR"
  echo "Wuerde Ausgabeordner anlegen: $USER_DIR/output"
  echo "Wuerde .env.example nach $USER_DIR/.env kopieren, falls noch keine .env existiert."
  echo "Keine Cloud-Keys, keine Auto-Publishing-Funktion und keine schweren Abhaengigkeiten werden installiert."
}

ensure_project_dir() {
  if [[ -d "$PROJECT_DIR" ]]; then
    return 0
  fi
  if ! command -v git >/dev/null 2>&1; then
    echo "Git wurde nicht gefunden. Bitte Git installieren oder Projektordner manuell bereitstellen: $PROJECT_DIR" >&2
    exit 1
  fi
  echo "Projektordner fehlt. Klone AI-ContentMultiplier aus GitHub:"
  echo "  $GIT_URL -> $PROJECT_DIR"
  mkdir -p "$(dirname "$PROJECT_DIR")"
  git clone "$GIT_URL" "$PROJECT_DIR"
}

update_project_dir() {
  ensure_project_dir
  if [[ ! -d "$PROJECT_DIR/.git" ]]; then
    echo "Projektordner ist kein Git-Repository, Update wird uebersprungen: $PROJECT_DIR"
    return 0
  fi
  echo "Aktualisiere AI-ContentMultiplier per fast-forward..."
  git -C "$PROJECT_DIR" fetch --all --prune
  git -C "$PROJECT_DIR" pull --ff-only
}

install_workflow() {
  echo "Starte $TOOL_NAME Workflow-Setup..."
  ensure_project_dir
  mkdir -p "$USER_DIR/output"

  if [[ -f "$PROJECT_DIR/.env.example" && ! -f "$USER_DIR/.env" ]]; then
    cp "$PROJECT_DIR/.env.example" "$USER_DIR/.env"
    chmod 600 "$USER_DIR/.env" 2>/dev/null || true
    echo "Lokale Konfiguration erstellt: $USER_DIR/.env"
  elif [[ -f "$USER_DIR/.env" ]]; then
    echo "Lokale Konfiguration existiert bereits: $USER_DIR/.env"
  else
    echo "Hinweis: .env.example im Projektordner wurde nicht gefunden."
  fi

  cat > "$USER_DIR/README.local.md" <<EOF
# AI-ContentMultiplier lokale Arbeitsdaten

Dieser Ordner enthaelt lokale Konfiguration und Ergebnisse.

- Projekt-Doku: $PROJECT_DIR
- Ausgaben: $USER_DIR/output
- Konfiguration: $USER_DIR/.env

Keine API-Keys ins Repository schreiben.
EOF

  echo "$TOOL_NAME wurde als Workflow vorbereitet."
  echo "Naechster Schritt: OpenClaw-Profil aus $PROJECT_DIR/openclaw/ai-content-multiplier.agent.json pruefen."
}

case "${1:-}" in
  --help|-h)
    usage
    ;;
  --status)
    status
    ;;
  --dry-run|--plan)
    dry_run
    ;;
  --update)
    update_project_dir
    install_workflow
    ;;
  "")
    install_workflow
    ;;
  *)
    echo "Unbekannte Option: $1" >&2
    usage >&2
    exit 2
    ;;
esac
