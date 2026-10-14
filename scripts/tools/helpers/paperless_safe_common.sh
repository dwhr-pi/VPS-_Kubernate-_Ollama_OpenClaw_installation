#!/usr/bin/env bash
set -euo pipefail
PAPERLESS_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$PAPERLESS_REPO_ROOT/scripts/lib/resource_check.sh"
source "$PAPERLESS_REPO_ROOT/scripts/tools/helpers/docker_compose_tool_common.sh"

paperless_validate_env() {
    python3 - "$PAPERLESS_PRIVATE_ENV" "$PAPERLESS_REPO_ROOT" <<'PY'
from pathlib import Path
import re
import sys
path = Path(sys.argv[1])
if not path.is_file() or path.resolve() != path or path.is_relative_to(Path(sys.argv[2]).resolve()):
    raise SystemExit('ENV fehlt/liegt im Repo/enthaelt Symlinks. Private User-ENV erforderlich.')
if path.stat().st_mode & 0o077:
    raise SystemExit('ENV muss Dateirechte 0600 haben.')
values = {}
for line in path.read_text().splitlines():
    if not line.strip() or line.lstrip().startswith('#'):
        continue
    key, sep, value = line.partition('=')
    if not sep or key.strip() in values:
        raise SystemExit('Ungueltige/doppelte ENV-Felder; keine Werte ausgegeben.')
    values[key.strip()] = value.strip().strip("'\"")
if any(not re.fullmatch(r'[0-9a-fA-F]{64}', values.get(key, ''))
       for key in ('PAPERLESS_DBPASS', 'PAPERLESS_SECRET_KEY')):
    raise SystemExit('DBPASS und SECRET_KEY brauchen je 64 Hex-Zeichen. Keine Werte ausgegeben.')
if not re.fullmatch(r'ghcr.io/paperless-ngx/paperless-ngx:[0-9]+\.[0-9]+\.[0-9]+', values.get('PAPERLESS_IMAGE', '')):
    raise SystemExit('Gepruefte numerische Paperless-Version erforderlich; kein latest/Platzhalter.')
PY
}

paperless_compose() {
    (
        # The validated private ENV must win over unrelated exported shell values.
        unset PAPERLESS_DBPASS PAPERLESS_SECRET_KEY PAPERLESS_IMAGE
        run_docker_compose_tool --project-name ultimate-paperless --env-file "$PAPERLESS_PRIVATE_ENV" -f "$PAPERLESS_STACK/compose.yml" "$@"
    )
}

paperless_main() {
    umask 077
    local mode="${1:---dry-run}" root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}"
    case "$mode" in
        --dry-run|--plan)
            echo 'Paperless: Opt-in/Docker separat, private ENV, localhost 8010, 2 GiB RAM/10 GiB Disk Planungsreserve. Keine Legacy-Migration oder Admin-Erzeugung.'
            return 0 ;;
        install|update|uninstall|check|doctor|status) ;;
        *) echo 'Erlaubt: --dry-run, install, update, uninstall, check, status, doctor.' >&2; return 2 ;;
    esac
    if [[ "$mode" == check || "$mode" == doctor || "$mode" == status ]]; then
        echo 'Nur lokaler HTTP-Test; kein Berechtigungs-/Compliance-Nachweis.'
        curl -fsS --max-time 5 -o /dev/null http://127.0.0.1:8010/ || return 1
        return 0
    fi
    [[ "${PAPERLESS_ENABLE_DOCKER:-0}" == 1 ]] || { echo 'Start/Update/Stop nur mit PAPERLESS_ENABLE_DOCKER=1.' >&2; return 2; }
    if [[ -e /opt/paperless_ngx ]]; then
        echo 'Legacy-Installation /opt/paperless_ngx erkannt. Erst Backup/Migration planen; kein paralleler Stack und kein Ueberschreiben/Loeschen.' >&2; return 1
    fi
    [[ "$root" == /* && "$(realpath -m -- "$root")" == "$root" ]] || return 1
    case "$root/" in "$PAPERLESS_REPO_ROOT/"*) echo 'Runtime nicht im Repo erlaubt.' >&2; return 1 ;; esac
    PAPERLESS_STACK="$root/tools/paperless_ngx"
    PAPERLESS_PRIVATE_ENV="$root/env/paperless_ngx/.env"
    local candidate
    for candidate in "$PAPERLESS_STACK" "$PAPERLESS_STACK/compose.yml" "$PAPERLESS_PRIVATE_ENV"; do
        [[ ! -L "$candidate" && "$(realpath -m -- "$candidate")" == "$candidate" ]] || return 1
    done
    command -v docker >/dev/null && command -v python3 >/dev/null && command -v curl >/dev/null || return 1
    if [[ "$mode" == uninstall ]]; then
        [[ -f "$PAPERLESS_STACK/compose.yml" ]] || { echo 'Kein neuer Stack vorhanden; keine Daten entfernt.'; return 0; }
        paperless_compose down || return 1
        AUTO_INSTALL_TOOL_BASE_DEPS=false init_tool_tracking Paperless_NGX
        mark_current_tool_removed
        echo 'Container gestoppt/entfernt; ENV, DB und Dokumente bleiben erhalten.'
        return 0
    fi
    paperless_validate_env || return 1
    require_ram_mb 2048
    local budget_path="$root"
    while [[ ! -d "$budget_path" ]]; do budget_path="$(dirname "$budget_path")"; done
    REQUIRE_WINDOWS_HOST_FREE_MB=20480 require_disk_mb 10240 "$budget_path"
    run_docker_compose_tool version >/dev/null || return 1
    mkdir -p "$PAPERLESS_STACK" || return 1
    if [[ -f "$PAPERLESS_STACK/compose.yml" ]]; then
        cmp -s "$PAPERLESS_REPO_ROOT/stacks/paperless_ngx/compose.yml" "$PAPERLESS_STACK/compose.yml" || {
            echo 'Compose weicht ab: erst Backup/Diff/Migration, kein Ueberschreiben.' >&2; return 1;
        }
    else
        cp "$PAPERLESS_REPO_ROOT/stacks/paperless_ngx/compose.yml" "$PAPERLESS_STACK/compose.yml" || return 1
    fi
    AUTO_INSTALL_TOOL_BASE_DEPS=false init_tool_tracking Paperless_NGX
    paperless_compose config --quiet || return 1
    paperless_compose --parallel 1 pull || return 1
    paperless_compose up -d --pull never || return 1
    echo 'Stack gestartet, noch kein Berechtigungs-/Funktionstest. Admin manuell einrichten; Status erst nach HTTP-Test.'
    local attempt
    for attempt in 1 2 3 4 5 6; do
        if curl -fsS --max-time 5 -o /dev/null http://127.0.0.1:8010/; then
            mark_current_tool_installed; return 0
        fi
        sleep 5
    done
    echo 'HTTP-Test fehlgeschlagen. Stack kann noch laufen; Logs lokal pruefen, kein Installiert-Status gesetzt.' >&2
    return 1
}
