#!/usr/bin/env bash
set -euo pipefail
FREELLMAPI_REPO_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
FREELLMAPI_SOURCE_URL=https://github.com/tashfeenahmed/freellmapi.git
FREELLMAPI_SOURCE_TAG=v0.14.2
FREELLMAPI_SOURCE_COMMIT=57c0669233bbe0c70a0f9f9927613192be948773

freellmapi_paths() {
    local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}"
    if [[ "$root" != /* || -L "$root" ]]; then
        echo 'Fehler: User-Workspace muss absolut und ohne Symlinks sein.' >&2; return 1
    fi
    case "$root/" in "$FREELLMAPI_REPO_ROOT/"*) echo 'Fehler: Runtime-Daten duerfen nicht im Repo liegen.' >&2; return 1 ;; esac
    FREELLMAPI_BASE="$root/tools/freellmapi"
    FREELLMAPI_SOURCE_DIR="$FREELLMAPI_BASE/source"
    FREELLMAPI_DATA_DIR="$FREELLMAPI_BASE/native-data"
    FREELLMAPI_ENV_FILE="$root/env/freellmapi/.env"
    FREELLMAPI_LOG_DIR="$root/install_logs"
    FREELLMAPI_MARKER="$FREELLMAPI_BASE/source-built"
    FREELLMAPI_HOST_PORT="${FREELLMAPI_HOST_PORT:-3011}"
    if ! [[ "$FREELLMAPI_HOST_PORT" =~ ^[1-9][0-9]{0,4}$ ]] || ((10#$FREELLMAPI_HOST_PORT > 65535)); then
        echo 'Fehler: FREELLMAPI_HOST_PORT ungueltig.' >&2; return 2
    fi
    local path index=0
    local -a paths=("$root" "$FREELLMAPI_SOURCE_DIR" "$FREELLMAPI_DATA_DIR" "$FREELLMAPI_ENV_FILE" "$FREELLMAPI_LOG_DIR" "$FREELLMAPI_MARKER" "$FREELLMAPI_BASE/operation.lock") resolved=()
    mapfile -t resolved < <(realpath -m -- "${paths[@]}")
    [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
    for path in "${paths[@]}"; do
        if [[ -L "$path" || "${resolved[$index]}" != "$path" ]]; then
            echo 'Fehler: Symlink im FreeLLMAPI-Pfad. Manuell pruefen.' >&2; return 1
        fi
        index=$((index + 1))
    done
}

freellmapi_resources() {
    # Load shared resource checks only for an explicitly selected build.
    # shellcheck disable=SC1091
    source "$FREELLMAPI_REPO_ROOT/scripts/lib/resource_check.sh"
    require_ram_mb 2048 || return 1
    REQUIRE_WINDOWS_HOST_FREE_MB=10240 require_disk_mb 4096 "$1"
}

freellmapi_validate_env() {
    python3 "$FREELLMAPI_REPO_ROOT/scripts/tools/freellmapi_run.py" --check-env --env-file "$FREELLMAPI_ENV_FILE"
}

freellmapi_require_user() {
    [[ "$EUID" != 0 ]] || { echo 'Fehler: als normaler Benutzer, nicht sudo/root ausfuehren.' >&2; return 1; }
}

freellmapi_require_runtime() {
    local command npm_version
    for command in node npm python3 git flock; do
        command -v "$command" >/dev/null || { echo "Fehler: $command fehlt; bewusst separat einrichten, keine Systeminstallation." >&2; return 1; }
    done
    node -e 'const [a,b]=process.versions.node.split(".").map(Number); if (!((a===22 && b>=22)||a===24)) process.exit(1)' || {
        echo 'Fehler: vorhandenes Node 22.22+ (22.x) oder 24.x erforderlich. System-Node bleibt unveraendert.' >&2; return 1;
    }
    npm_version="$(npm --version)" || return 1
    [[ "$npm_version" =~ ^([0-9]+)\. ]] && ((BASH_REMATCH[1] >= 10)) || {
        echo 'Fehler: npm >=10 erforderlich.' >&2; return 1;
    }
}

freellmapi_port_free() {
    python3 - "$FREELLMAPI_HOST_PORT" <<'PY'
import socket
import sys
try:
    with socket.socket() as server:
        server.bind(('127.0.0.1', int(sys.argv[1])))
except OSError:
    raise SystemExit('Fehler: lokaler Port belegt/nicht nutzbar. Dienst bewusst stoppen; kein automatisches Kill.')
PY
}

freellmapi_lock() {
    mkdir -p "$FREELLMAPI_BASE" || return 1
    exec 9>"$FREELLMAPI_BASE/operation.lock"
    flock -n 9 || { echo 'Fehler: FreeLLMAPI-Build/Start laeuft bereits.' >&2; return 1; }
}

freellmapi_is_built() {
    [[ -f "$FREELLMAPI_MARKER" && -f "$FREELLMAPI_SOURCE_DIR/server/dist/index.js" && -f "$FREELLMAPI_SOURCE_DIR/client/dist/index.html" ]] &&
        grep -Fxq "$FREELLMAPI_SOURCE_COMMIT" "$FREELLMAPI_MARKER"
}

freellmapi_verify_source() {
    [[ -d "$FREELLMAPI_SOURCE_DIR/.git" && ! -L "$FREELLMAPI_SOURCE_DIR/.git" ]] || {
        echo 'Fehler: Source-Ziel ist kein regulaerer Git-Checkout; nichts geloescht.' >&2; return 1;
    }
    [[ "$(git -C "$FREELLMAPI_SOURCE_DIR" remote get-url origin)" == "$FREELLMAPI_SOURCE_URL" &&
       "$(git -C "$FREELLMAPI_SOURCE_DIR" rev-parse HEAD)" == "$FREELLMAPI_SOURCE_COMMIT" ]] || {
        echo 'Fehler: Quelle/Commit weicht vom gepinnten GitHub-Stand ab; kein Reset/Checkout.' >&2; return 1;
    }
    [[ -z "$(git -C "$FREELLMAPI_SOURCE_DIR" status --porcelain --untracked-files=normal)" ]] || {
        echo 'Fehler: lokale Source-Aenderungen sichern/pruefen; kein Ueberschreiben.' >&2; return 1;
    }
}

freellmapi_smoke() {
    [[ -f "$FREELLMAPI_SOURCE_DIR/server/dist/index.js" && -f "$FREELLMAPI_SOURCE_DIR/client/dist/index.html" ]] || return 1
    (
        cd "$FREELLMAPI_SOURCE_DIR" || exit 1
        node --check server/dist/index.js &&
            node -e 'const r=require("node:module").createRequire(process.cwd()+"/server/package.json");const DB=r("better-sqlite3");const db=new DB(":memory:");db.close()'
    )
}

freellmapi_build() (
    local mode="$1" before started log mount="$FREELLMAPI_BASE"
    while [[ ! -d "$mount" ]]; do mount="$(dirname "$mount")"; done
    freellmapi_resources "$mount" || return 1
    freellmapi_lock && freellmapi_port_free || return 1
    if [[ -e "$FREELLMAPI_SOURCE_DIR" ]]; then freellmapi_verify_source || return 1; fi
    if [[ "$mode" == install ]] && freellmapi_is_built; then
        freellmapi_smoke || return 1
        echo 'Source-Build bereits vorhanden und lokaler Smoke-Test erfolgreich; kein Serverstart.'
        return 0
    fi
    mkdir -p "$FREELLMAPI_LOG_DIR" || return 1
    log="$FREELLMAPI_LOG_DIR/$(date +%Y%m%d_%H%M%S)_freellmapi_source_$$.log"
    started="$SECONDS"
    before="$(df -Pk "$mount" | awk 'NR==2 {print $4}')"
    exec > >(tee -a "$log") 2>&1
    trap 'rc=$?; printf "Build Exit=%s Dauer=%ss Disk-vorher-KiB=%s\n" "$rc" "$((SECONDS-started))" "$before"; df -Pk "$mount"; exit "$rc"' EXIT
    echo "FreeLLMAPI GitHub-Source $FREELLMAPI_SOURCE_TAG ($FREELLMAPI_SOURCE_COMMIT), ohne Container."
    if [[ ! -e "$FREELLMAPI_SOURCE_DIR" ]]; then
        GIT_TERMINAL_PROMPT=0 git -c advice.detachedHead=false clone --depth 1 --branch "$FREELLMAPI_SOURCE_TAG" "$FREELLMAPI_SOURCE_URL" "$FREELLMAPI_SOURCE_DIR" || return 1
    fi
    freellmapi_verify_source || return 1
    (
        cd "$FREELLMAPI_SOURCE_DIR" || exit 1
        [[ -f package-lock.json && -f server/package.json && -f client/package.json ]] || exit 1
        # Lifecycle scripts may compile native addons; the private runtime ENV is not loaded here.
        rm -f -- "$FREELLMAPI_MARKER" || exit 1
        npm ci --include=dev --no-audit --no-fund && npm run build
    ) || { echo 'Fehler: npm-Abhaengigkeiten/Build fehlgeschlagen. Node/npm, Build-Werkzeuge und privaten Buildlog pruefen; keine Daten geloescht.' >&2; return 1; }
    freellmapi_smoke || { echo 'Fehler: Server/UI oder native SQLite-Abhaengigkeit nicht nutzbar.' >&2; return 1; }
    printf '%s\n' "$FREELLMAPI_SOURCE_COMMIT" > "$FREELLMAPI_MARKER" || return 1
    echo 'Source-Build fertig, kein Server gestartet. Private ENV vorbereiten; dann bewusst freellmapi_start.sh verwenden.'
)

freellmapi_main() (
    umask 077
    local mode="${1:---dry-run}"
    case "$mode" in
        --status|--check) mode=status ;; --repair) mode=update ;;
        install|update|uninstall|--dry-run|status|doctor|start|--health) ;;
        *) echo 'FreeLLMAPI: install/update/uninstall/--dry-run/--check/status/doctor/start/--health' >&2; return 2 ;;
    esac
    freellmapi_paths || return 1
    if [[ "$mode" == --dry-run ]]; then
        echo "FreeLLMAPI GitHub-Source $FREELLMAPI_SOURCE_TAG: npm ci/build, ohne Docker; spaeter 127.0.0.1:$FREELLMAPI_HOST_PORT."
        echo 'Build: Node 22.22+/24, npm >=10, 2 GiB RAM/4 GiB Disk Planungsreserve. Kein Download/Start im Dry-Run.'
        return 0
    fi
    if [[ "$mode" == status || "$mode" == doctor ]]; then
        freellmapi_is_built || { echo 'Kein vollstaendiger Source-Build; kein Laufzeitstatus zugesagt.' >&2; return 1; }
        echo 'Source-Build vorhanden; Serverstart und Providerzugang sind separat.'
        if [[ "$mode" == doctor ]]; then freellmapi_require_runtime && freellmapi_validate_env || return 1; fi
        return 0
    fi
    if [[ "$mode" == --health ]]; then
        curl -fsS --connect-timeout 3 --max-time 10 -o /dev/null "http://127.0.0.1:$FREELLMAPI_HOST_PORT/api/ping" || return 1
        echo 'HTTP-Ping erfolgreich; kein Auth-/Provider-/Fallback-Nachweis.'
        return 0
    fi
    freellmapi_require_user || return 1
    if [[ "$mode" != uninstall ]]; then freellmapi_require_runtime || return 1; fi
    if [[ "$mode" == install || "$mode" == update ]]; then freellmapi_build "$mode"; return $?; fi
    if [[ "$mode" == uninstall ]]; then
        command -v git >/dev/null && command -v flock >/dev/null && command -v python3 >/dev/null || {
            echo 'Fehler: Git/flock/Python fuer sichere Deaktivierung erforderlich.' >&2; return 1;
        }
        freellmapi_lock && freellmapi_port_free || return 1
        if [[ -e "$FREELLMAPI_SOURCE_DIR" ]]; then
            freellmapi_verify_source || return 1
            local disabled="$FREELLMAPI_BASE/source.disabled.$(date +%Y%m%d_%H%M%S).$$"
            [[ ! -e "$disabled" ]] || return 1
            mv -- "$FREELLMAPI_SOURCE_DIR" "$disabled" || return 1
        fi
        rm -f -- "$FREELLMAPI_MARKER" || return 1
        echo 'Source-Installation deaktiviert. Code, ENV, native-data und alte Containerdaten bleiben erhalten; keine Prozesse beendet.'
        return 0
    fi
    [[ "${FREELLMAPI_ENABLE_NETWORK:-0}" == 1 ]] || {
        echo 'Start braucht FREELLMAPI_ENABLE_NETWORK=1: externe Katalog-/Providerkontakte moeglich. Installation selbst braucht kein Start-Opt-in.' >&2; return 2;
    }
    freellmapi_is_built && freellmapi_verify_source && freellmapi_validate_env || return 1
    freellmapi_lock && freellmapi_port_free || return 1
    echo "Starte im Vordergrund auf 127.0.0.1:$FREELLMAPI_HOST_PORT; Stop mit Ctrl+C. Startcodes/Logs nicht veroeffentlichen."
    python3 "$FREELLMAPI_REPO_ROOT/scripts/tools/freellmapi_run.py" --env-file "$FREELLMAPI_ENV_FILE" --source-dir "$FREELLMAPI_SOURCE_DIR" --data-dir "$FREELLMAPI_DATA_DIR" --port "$FREELLMAPI_HOST_PORT" --node "$(command -v node)"
)
