#!/usr/bin/env bash
set -euo pipefail
FREELLMAPI_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
# shellcheck disable=SC1091
source "$FREELLMAPI_REPO_ROOT/scripts/lib/resource_check.sh"
# shellcheck disable=SC1091
source "$FREELLMAPI_REPO_ROOT/scripts/tools/helpers/docker_compose_tool_common.sh"

freellmapi_paths() {
    local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}"
    if [[ "$root" != /* || -L "$root" ]] || [[ "$(realpath -m -- "$root")" != "$root" ]]; then
        echo 'Fehler: User-Workspace muss absolut und ohne Symlinks sein.' >&2; return 1
    fi
    case "$root/" in "$FREELLMAPI_REPO_ROOT/"*) echo 'Fehler: Runtime-Daten duerfen nicht im Repo liegen.' >&2; return 1 ;; esac
    export FREELLMAPI_ENV_FILE="$root/env/freellmapi/.env"
    export FREELLMAPI_DATA_DIR="$root/tools/freellmapi/data"
    FREELLMAPI_COMPOSE_FILE="$root/tools/freellmapi/compose.yml"
    export FREELLMAPI_HOST_PORT="${FREELLMAPI_HOST_PORT:-3011}"
    if ! [[ "$FREELLMAPI_HOST_PORT" =~ ^[1-9][0-9]{0,4}$ ]] || ((10#$FREELLMAPI_HOST_PORT > 65535)); then
        echo 'Fehler: FREELLMAPI_HOST_PORT ungueltig.' >&2; return 2
    fi
    local path
    for path in "$FREELLMAPI_ENV_FILE" "$FREELLMAPI_DATA_DIR" "$FREELLMAPI_COMPOSE_FILE"; do
        if [[ -L "$path" || "$(realpath -m -- "$path")" != "$path" ]]; then
            echo 'Fehler: Symlink im FreeLLMAPI-Datenpfad. Manuell pruefen.' >&2; return 1
        fi
    done
}

freellmapi_validate_env() {
    python3 - "$FREELLMAPI_ENV_FILE" <<'PY'
from pathlib import Path
import re
import sys
path = Path(sys.argv[1])
if not path.is_file():
    raise SystemExit('Fehler: FreeLLMAPI ENV fehlt. config/freellmapi.env.example und ENV-Tresor verwenden.')
values = []
for line in path.read_text(encoding='utf-8-sig').splitlines():
    match = re.fullmatch(r'\s*ENCRYPTION_KEY\s*=\s*(.*?)\s*', line)
    if match:
        values.append(match[1].strip("'\""))
if len(values) != 1 or not re.fullmatch(r'[0-9a-fA-F]{64}', values[0]):
    raise SystemExit('Fehler: ENCRYPTION_KEY muss genau einmal als 64 Hex-Zeichen gesetzt sein. Kein Wert ausgegeben.')
if path.stat().st_mode & 0o077:
    raise SystemExit('Fehler: ENV-Datei muss Dateirechte 0600 haben.')
PY
}

freellmapi_compose() {
    run_docker_compose_tool --project-name ultimate-freellmapi --env-file "$FREELLMAPI_ENV_FILE" -f "$FREELLMAPI_COMPOSE_FILE" "$@"
}

freellmapi_main() {
    umask 077
    local mode="${1:---dry-run}"
    case "$mode" in install|update|uninstall|--dry-run|--check|status|doctor) ;; *) echo 'FreeLLMAPI: install/update/uninstall/--dry-run/--check/status/doctor' >&2; return 2 ;; esac
    freellmapi_paths || return 1
    if [[ "$mode" == --dry-run ]]; then
        echo "FreeLLMAPI experimental: GitHub/GHCR v0.14.2, 127.0.0.1:$FREELLMAPI_HOST_PORT -> 3001."
        echo 'Plan: User-ENV/Daten, vorhandenes Docker, explizites Opt-in vor Pull/Start. Kein curl|bash, Watchtower, Socket-Mount oder Client-Umbau.'
        return 0
    fi
    if [[ "$mode" == --check || "$mode" == status || "$mode" == doctor ]]; then
        echo 'Lokaler /api/ping-Test; kein Modellaufruf oder Provider-Test.'
        curl -fsS --connect-timeout 3 --max-time 10 -o /dev/null "http://127.0.0.1:$FREELLMAPI_HOST_PORT/api/ping" || return 1
        echo 'HTTP-Ping erfolgreich. Das beweist keine Modell-/Fallback-/Auth-Funktion.'
        return 0
    fi
    if [[ "${FREELLMAPI_ENABLE_DOCKER:-0}" != 1 ]]; then
        echo 'Kein Start/Update/Stop ohne FREELLMAPI_ENABLE_DOCKER=1. Router kann externe Katalog-/Provider-Verbindungen aufbauen; erst Doku lesen.' >&2
        return 2
    fi
    command -v docker >/dev/null && command -v python3 >/dev/null && command -v curl >/dev/null || { echo 'Fehler: Docker/Python/curl fehlen; keine automatische Engine-Installation.' >&2; return 1; }
    if [[ "$mode" == uninstall ]]; then
        [[ -f "$FREELLMAPI_COMPOSE_FILE" ]] || { echo 'Kein Stack vorhanden; Daten bleiben erhalten.'; return 0; }
        freellmapi_compose down || return 1
        AUTO_INSTALL_TOOL_BASE_DEPS=false init_tool_tracking FreeLLMAPI
        mark_current_tool_removed
        echo 'Container/Netz entfernt. ENV, Datenbank und Verschluesselungskey bleiben erhalten.'
        return 0
    fi
    freellmapi_validate_env || return 1
    require_ram_mb 512 || return 1
    REQUIRE_WINDOWS_HOST_FREE_MB=10240 require_disk_mb 2048 / || return 1
    # Check daemon access before creating runtime files. No service/group changes.
    run_docker_compose_tool version >/dev/null || return 1
    local directory
    directory="$(dirname "$FREELLMAPI_COMPOSE_FILE")"
    mkdir -p "$directory" "$FREELLMAPI_DATA_DIR" || return 1
    if [[ -f "$FREELLMAPI_COMPOSE_FILE" ]]; then
        cmp -s "$FREELLMAPI_REPO_ROOT/stacks/freellmapi/compose.yml" "$FREELLMAPI_COMPOSE_FILE" || {
            echo 'Fehler: Vorhandene Compose-Datei weicht ab. Sichern/pruefen; kein automatisches Ueberschreiben.' >&2; return 1;
        }
    else
        cp "$FREELLMAPI_REPO_ROOT/stacks/freellmapi/compose.yml" "$FREELLMAPI_COMPOSE_FILE" || return 1
    fi
    AUTO_INSTALL_TOOL_BASE_DEPS=false init_tool_tracking FreeLLMAPI
    freellmapi_compose config --quiet || return 1
    freellmapi_compose --parallel 1 pull || return 1
    freellmapi_compose up -d --pull never || return 1
    local attempt
    for attempt in 1 2 3 4 5 6; do
        if curl -fsS --max-time 5 -o /dev/null "http://127.0.0.1:$FREELLMAPI_HOST_PORT/api/ping"; then
            mark_current_tool_installed
            echo "FreeLLMAPI erreichbar auf http://127.0.0.1:$FREELLMAPI_HOST_PORT. Noch keine Client-/Modellkonfiguration vorgenommen."
            return 0
        fi
        sleep 5
    done
    echo 'Fehler: Kein HTTP-Ping nach Start. Container kann noch laufen; Logs lokal pruefen. Kein Installiert-Status gesetzt.' >&2
    return 1
}
