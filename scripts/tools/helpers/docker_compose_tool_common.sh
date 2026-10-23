#!/bin/bash
# Gemeinsame Hilfsfunktionen für docker-compose-basierte Tool-Stacks

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'
DOCKER_COMPOSE_TOOL_HELPER_REVISION="2026-10-23-preserve-data-owned-paths"
DOCKER_COMPOSE_TOOL_CALL_ARGS=("$@")

HELPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$HELPER_DIR/../../helpers/status_tracking.sh"

compose_tool_validate_path() {
    local root="${COMPOSE_TOOL_ROOT:-/opt}" canonical_root canonical_tool file owner permissions
    [[ "${TOOL_SLUG:-}" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ && "${TOOL_KEY:-}" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]] || {
        echo 'Ungueltige Tool-Kennung; keine Aktion.' >&2; return 1;
    }
    [[ "$root" == /* && "$root" != / && -d "$root" && ! -L "$root" ]] || return 1
    canonical_root=$(realpath -e -- "$root") || return 1
    [[ "$canonical_root" == "$root" && "$root" != "$HOME" ]] || return 1
    TOOL_DIR="${TOOL_DIR:-$root/$TOOL_SLUG}"
    canonical_tool=$(realpath -m -- "$TOOL_DIR") || return 1
    [[ "$TOOL_DIR" == "$root/$TOOL_SLUG" && "$canonical_tool" == "$TOOL_DIR" && ! -L "$TOOL_DIR" ]] || {
        echo 'Tool-Pfad ist kein eindeutiges verwaltetes Ziel; keine Aktion.' >&2; return 1;
    }
    for file in "$root" "$TOOL_DIR" "$TOOL_DIR/docker-compose.yml" "$TOOL_DIR/.openclaw-compose-owner"; do
        [[ -e "$file" ]] || continue
        owner=$(stat -c %u -- "$file") || return 1
        permissions=$(stat -c %a -- "$file") || return 1
        [[ "$owner" == "$EUID" || "$owner" == 0 ]] || return 1
        (( (8#$permissions & 0022) == 0 )) || { echo 'Verwalteter Pfad ist fremd beschreibbar; keine Aktion.' >&2; return 1; }
    done
    for file in docker-compose.yml .env .openclaw-compose-owner; do
        [[ ! -L "$TOOL_DIR/$file" ]] || { echo 'Verknuepfte Konfigurationsdatei wird nicht bearbeitet.' >&2; return 1; }
    done
}

compose_tool_owner_matches() {
    local marker="$TOOL_DIR/.openclaw-compose-owner" owner
    [[ -f "$marker" && ! -L "$marker" ]] || return 1
    owner=$(stat -c %u -- "$marker") || return 1
    [[ "$owner" == "$EUID" || "$owner" == 0 ]] || return 1
    cmp -s "$marker" <(printf 'openclaw-compose-v1\n%s\n%s\n%s\n' "$TOOL_KEY" "$TOOL_SLUG" "$TOOL_DIR")
}

compose_tool_write_owner() {
    local marker="$TOOL_DIR/.openclaw-compose-owner" staged
    if [[ -e "$marker" ]]; then compose_tool_owner_matches; return $?; fi
    staged=$(mktemp "$TOOL_DIR/.owner.XXXXXXXX") || return 1
    chmod 600 "$staged" || return 1
    printf 'openclaw-compose-v1\n%s\n%s\n%s\n' "$TOOL_KEY" "$TOOL_SLUG" "$TOOL_DIR" > "$staged" || return 1
    mv -- "$staged" "$marker"
}

ensure_docker_compose() {
    echo -e "${YELLOW}Docker-Compose-Helper-Revision:${NC} ${DOCKER_COMPOSE_TOOL_HELPER_REVISION}"

    if command -v docker >/dev/null 2>&1 && { docker compose version >/dev/null 2>&1 || sudo docker compose version >/dev/null 2>&1; }; then
        return 0
    fi

    echo -e "${YELLOW}Docker oder Docker Compose nicht gefunden. Installiere Docker Engine...${NC}"
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker "$USER" || true

    if ! command -v docker >/dev/null 2>&1 || ! { docker compose version >/dev/null 2>&1 || sudo docker compose version >/dev/null 2>&1; }; then
        echo -e "${RED}Fehler: Docker Compose konnte nicht bereitgestellt werden.${NC}"
        exit 1
    fi
}

run_docker_compose_tool() {
    if docker compose version >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
        docker compose "$@"
        return $?
    fi

    if sudo docker compose version >/dev/null 2>&1 && sudo docker info >/dev/null 2>&1; then
        echo -e "${YELLOW}Docker-Daemon ist fuer den aktuellen User nicht direkt nutzbar. Verwende sudo docker compose.${NC}"
        echo -e "${YELLOW}Hinweis:${NC} Nach 'sudo usermod -aG docker $USER' ist meist eine neue Shell/WSL-Sitzung noetig, bis Docker ohne sudo funktioniert."
        sudo docker compose "$@"
        return $?
    fi

    echo -e "${RED}Fehler: Docker-Daemon ist nicht erreichbar oder die Berechtigung auf /var/run/docker.sock fehlt.${NC}"
    echo -e "${YELLOW}Reparaturhinweis:${NC} Docker starten, User-Gruppe pruefen oder den Installer erneut aus einer neuen Shell starten."
    return 1
}

install_docker_compose_tool() {
    : "${TOOL_NAME:?TOOL_NAME ist erforderlich}"
    : "${TOOL_KEY:?TOOL_KEY ist erforderlich}"
    : "${TOOL_SLUG:?TOOL_SLUG ist erforderlich}"
    : "${COMPOSE_YAML:?COMPOSE_YAML ist erforderlich}"

    compose_tool_validate_path || return 1
    local -a action_args=("$@")
    ((${#action_args[@]})) || action_args=("${DOCKER_COMPOSE_TOOL_CALL_ARGS[@]}")
    if [[ ${#action_args[@]} == 1 && "${action_args[0]}" == --dry-run ]]; then
        echo 'Dry-run: verwalteter Compose-Pfad geprueft; keine Datei-/Docker-/Statusaenderung.'
        return 0
    fi
    [[ ${#action_args[@]} == 0 || (${#action_args[@]} == 1 && "${action_args[0]}" == --apply) ]] || return 2
    if [[ -e "$TOOL_DIR/.openclaw-compose-owner" ]]; then compose_tool_owner_matches || return 1; fi
    # Never replace a user-customized configuration or a symlink target.
    if [[ -e "$TOOL_DIR/docker-compose.yml" ]] && ! cmp -s "$TOOL_DIR/docker-compose.yml" <(printf '%s\n' "$COMPOSE_YAML"); then
        echo 'Vorhandene Compose-Konfiguration weicht ab; keine automatische Ueberschreibung.' >&2
        return 1
    fi
    init_tool_tracking "$TOOL_KEY" || return $?
    ensure_docker_compose || return 1

    echo -e "${BLUE}Starte Installation von ${TOOL_NAME}...${NC}"
    sudo mkdir -p "$TOOL_DIR"
    sudo chown "$USER:$USER" "$TOOL_DIR"

    cat > "$TOOL_DIR/docker-compose.yml" <<EOF
${COMPOSE_YAML}
EOF

    if [[ -n "${TOOL_ENV_FILE_CONTENT:-}" && ! -e "$TOOL_DIR/.env" ]]; then
        (umask 077; cat > "$TOOL_DIR/.env" <<EOF
${TOOL_ENV_FILE_CONTENT}
EOF
        ) || return 1
    fi

    compose_tool_write_owner || return 1
    run_docker_compose_tool -f "$TOOL_DIR/docker-compose.yml" up -d || return $?

    if [ -n "${TOOL_PROMPT_EXAMPLE:-}" ]; then
        cat > "$TOOL_DIR/PROMPT_EXAMPLES.md" <<EOF
# Beispielprompts für ${TOOL_NAME}

${TOOL_PROMPT_EXAMPLE}
EOF
    fi

    mark_current_tool_installed || return $?
    echo -e "${GREEN}${TOOL_NAME} wurde erfolgreich installiert.${NC}"
}

uninstall_docker_compose_tool() {
    : "${TOOL_NAME:?TOOL_NAME ist erforderlich}"
    : "${TOOL_KEY:?TOOL_KEY ist erforderlich}"
    : "${TOOL_SLUG:?TOOL_SLUG ist erforderlich}"

    compose_tool_validate_path || return 1
    local dry_run=0 adopt_legacy=0 argument
    local -a action_args=("$@")
    ((${#action_args[@]})) || action_args=("${DOCKER_COMPOSE_TOOL_CALL_ARGS[@]}")
    for argument in "${action_args[@]}"; do
        case "$argument" in
            --dry-run) dry_run=1 ;;
            --apply) ;;
            --adopt-legacy) adopt_legacy=1 ;;
            *) echo 'Nur --dry-run, --apply und --adopt-legacy erlaubt; kein Purge.' >&2; return 2 ;;
        esac
    done
    if [[ -e "$TOOL_DIR/.openclaw-compose-owner" ]]; then
        compose_tool_owner_matches || { echo 'Besitzmarkierung passt nicht; keine Aktion.' >&2; return 1; }
    elif [[ -d "$TOOL_DIR" && "$adopt_legacy" != 1 ]]; then
        echo 'Altinstallation ohne Besitzmarkierung: Pfad/Compose-Datei pruefen, danach explizit --adopt-legacy verwenden.' >&2
        return 1
    fi
    if ((dry_run)); then
        echo 'Dry-run: Compose-Stop/Containerentfernung geplant; Dateien und Volumes bleiben erhalten. Kein Docker-/Statusaufruf.'
        return 0
    fi
    if [[ -d "$TOOL_DIR" ]]; then
        [[ -f "$TOOL_DIR/docker-compose.yml" ]] || { echo 'Compose-Datei fehlt; kein Erfolgstatus.' >&2; return 1; }
        command -v docker >/dev/null 2>&1 || { echo 'Docker fehlt; keine Deinstallation behauptet.' >&2; return 1; }
        run_docker_compose_tool -f "$TOOL_DIR/docker-compose.yml" down || return $?
    fi
    init_tool_tracking "$TOOL_KEY" || return $?
    mark_current_tool_removed || return $?
    echo -e "${GREEN}${TOOL_NAME}: Container entfernt oder bereits abwesend. Dateien und Volumes bleiben erhalten.${NC}"
}
