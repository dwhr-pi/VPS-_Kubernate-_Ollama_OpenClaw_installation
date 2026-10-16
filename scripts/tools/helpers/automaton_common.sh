#!/usr/bin/env bash
set -euo pipefail
AUTOMATON_REPO_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
AUTOMATON_SOURCE_URL=https://github.com/Conway-Research/automaton.git
AUTOMATON_SOURCE_COMMIT=d8f816881fd24b6f5e3d616e59edec387a447667

automaton_paths() {
    local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
    [[ "$root" == /* && "$root" != / ]] || return 1
    case "$root/" in "$AUTOMATON_REPO_ROOT/"*) echo 'User-Daten muessen ausserhalb des Setup-Repos liegen.' >&2; return 1 ;; esac
    AUTOMATON_BASE="$root/tools/automaton"
    AUTOMATON_SOURCE_DIR="$AUTOMATON_BASE/source"
    AUTOMATON_MARKER="$AUTOMATON_BASE/source-built"
    AUTOMATON_LOG_DIR="$root/install_logs"
    local -a paths=("$root" "$AUTOMATON_BASE" "$AUTOMATON_SOURCE_DIR" "$AUTOMATON_MARKER" "$AUTOMATON_LOG_DIR" "$AUTOMATON_BASE/operation.lock") resolved=()
    local index=0
    mapfile -t resolved < <(realpath -m -- "${paths[@]}")
    [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
    for path in "${paths[@]}"; do
        [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
            echo 'Automaton: nicht normalisierter Pfad/Symlink; nichts veraendert.' >&2; return 1;
        }
        index=$((index + 1))
    done
}

automaton_runtime_check() {
    local program
    for program in node pnpm git flock; do
        command -v "$program" >/dev/null || { echo "Automaton: $program fehlt; separat einrichten." >&2; return 1; }
    done
    node -e 'if(Number(process.versions.node.split(".")[0])!==22)process.exit(1)' || {
        echo 'Automaton: fuer diesen Buildpfad Node 22.x verwenden; System-Node wird nicht ersetzt.' >&2; return 1;
    }
    [[ "$(pnpm --version)" == 10.28.1 ]] || {
        echo 'Automaton: pnpm 10.28.1 laut gepinntem packageManager erforderlich; kein globales Update.' >&2; return 1;
    }
}

automaton_require_user() {
    [[ "$EUID" != 0 ]] || { echo 'Automaton als normaler Benutzer bauen, nicht sudo/root.' >&2; return 1; }
}

automaton_resources() {
    # shellcheck disable=SC1091
    source "$AUTOMATON_REPO_ROOT/scripts/lib/resource_check.sh"
    require_ram_mb 4096 || return 1
    REQUIRE_WINDOWS_HOST_FREE_MB=10240 require_disk_mb 10240 "$1"
}

automaton_lock() {
    mkdir -p "$AUTOMATON_BASE" || return 1
    exec 9>"$AUTOMATON_BASE/operation.lock"
    flock -n 9 || { echo 'Automaton: andere Build-/Deaktivierungsaktion laeuft.' >&2; return 1; }
}

automaton_verify_source() {
    local origin head changes
    [[ -d "$AUTOMATON_SOURCE_DIR/.git" && ! -L "$AUTOMATON_SOURCE_DIR/.git" ]] || {
        echo 'Automaton: unvollstaendiger Checkout; manuell sichern/pruefen, keine automatische Loeschung.' >&2; return 1;
    }
    origin="$(git -C "$AUTOMATON_SOURCE_DIR" remote get-url origin)" || return 1
    head="$(git -C "$AUTOMATON_SOURCE_DIR" rev-parse HEAD)" || return 1
    changes="$(git -C "$AUTOMATON_SOURCE_DIR" status --porcelain --untracked-files=normal)" || return 1
    [[ "$origin" == "$AUTOMATON_SOURCE_URL" && "$head" == "$AUTOMATON_SOURCE_COMMIT" && -z "$changes" ]] || {
        echo 'Automaton: Quelle, Commit oder lokale Aenderungen abweichend. Kein Reset/Pull/Ueberschreiben.' >&2; return 1;
    }
}

automaton_is_built() {
    [[ -f "$AUTOMATON_MARKER" && -f "$AUTOMATON_SOURCE_DIR/dist/index.js" &&
       -f "$AUTOMATON_SOURCE_DIR/packages/cli/dist/index.js" ]] &&
        grep -Fxq "$AUTOMATON_SOURCE_COMMIT" "$AUTOMATON_MARKER"
}

automaton_smoke() (
    cd "$AUTOMATON_SOURCE_DIR" || exit 1
    [[ -f dist/index.js && -f packages/cli/dist/index.js ]] || exit 1
    node --check dist/index.js && node --check packages/cli/dist/index.js &&
        node -e 'const DB=require("better-sqlite3");const db=new DB(":memory:");db.close()'
)

automaton_build() (
    local mode="$1" mount="$AUTOMATON_BASE" log before started
    while [[ ! -d "$mount" ]]; do mount="${mount%/*}"; [[ -n "$mount" ]] || mount=/; done
    automaton_resources "$mount" || return 1
    automaton_lock || return 1
    if [[ -e "$AUTOMATON_SOURCE_DIR" ]]; then automaton_verify_source || return 1; fi
    if [[ "$mode" == install ]] && automaton_is_built; then
        automaton_smoke || return 1
        echo 'Automaton Source-Build bereits vorhanden; kein Agent gestartet.'; return 0
    fi
    mkdir -p "$AUTOMATON_LOG_DIR" || return 1
    log="$AUTOMATON_LOG_DIR/$(date +%Y%m%d_%H%M%S)_automaton_source_$$.log"
    before="$(df -Pk "$mount" | awk 'NR==2 {print $4}')"
    started="$SECONDS"
    exec > >(tee -a "$log") 2>&1
    trap 'rc=$?; printf "Automaton Build Exit=%s Dauer=%ss Disk-vorher-KiB=%s\n" "$rc" "$((SECONDS-started))" "$before"; df -Pk "$mount"; exit "$rc"' EXIT
    echo "Automaton GitHub-Source $AUTOMATON_SOURCE_COMMIT; kein Docker, Wallet- oder Agentenstart."
    if [[ ! -e "$AUTOMATON_SOURCE_DIR" ]]; then
        git init "$AUTOMATON_SOURCE_DIR" || return 1
        git -C "$AUTOMATON_SOURCE_DIR" remote add origin "$AUTOMATON_SOURCE_URL" || return 1
        GIT_TERMINAL_PROMPT=0 git -C "$AUTOMATON_SOURCE_DIR" fetch --depth 1 origin "$AUTOMATON_SOURCE_COMMIT" || return 1
        git -C "$AUTOMATON_SOURCE_DIR" -c advice.detachedHead=false checkout --detach "$AUTOMATON_SOURCE_COMMIT" || return 1
    fi
    automaton_verify_source || return 1
    rm -f -- "$AUTOMATON_MARKER" || return 1
    (
        cd "$AUTOMATON_SOURCE_DIR" || exit 1
        [[ -f pnpm-lock.yaml && -f pnpm-workspace.yaml && -f package.json ]] || exit 1
        # Only dependency-native build scripts run; never invoke the agent entry point.
        pnpm install --frozen-lockfile && pnpm run build
    ) || { echo 'Automaton Build fehlgeschlagen. Privates Log, Node/pnpm und native Build-Werkzeuge pruefen.' >&2; return 1; }
    automaton_smoke || { echo 'Automaton: Build/SQLite-Smoke-Test fehlgeschlagen.' >&2; return 1; }
    printf '%s\n' "$AUTOMATON_SOURCE_COMMIT" > "$AUTOMATON_MARKER" || return 1
    echo 'Automaton aus GitHub gebaut. Kein globales CLI, kein Dienst, keine Wallet, keine Zahlungen.'
)

automaton_main() (
    umask 077
    local mode="${1:---dry-run}"
    case "$mode" in
        --dry-run|--plan|plan) mode=plan ;; --check|check|--status|status) mode=status ;;
        --repair|repair) mode=update ;; --uninstall) mode=uninstall ;;
        install|update|uninstall|doctor) ;;
        *) echo 'Automaton: nur Source-Build/Status/Doctor/Deaktivierung. Start, Init und Provisionierung bleiben gesperrt.' >&2; return 2 ;;
    esac
    automaton_paths || return 1
    if [[ "$mode" == plan ]]; then
        echo "Automaton: GitHub $AUTOMATON_SOURCE_COMMIT, pnpm 10.28.1, Node 22.x; ohne Docker."
        echo 'Planungsreserve: 4 GiB RAM/10 GiB Disk, WSL-Hostreserve 10 GiB. Kein Download/Start im Dry-Run.'; return 0
    fi
    if [[ "$mode" == status || "$mode" == doctor ]]; then
        automaton_is_built && automaton_verify_source || { echo 'Automaton: kein verifizierter Source-Build vorhanden.' >&2; return 1; }
        if [[ "$mode" == doctor ]]; then automaton_runtime_check && automaton_smoke || return 1; fi
        echo 'Automaton Source-Build vorhanden; Agent-/Wallet-Status wird nicht gelesen.'; return 0
    fi
    automaton_require_user || return 1
    if [[ "$mode" == uninstall ]]; then
        command -v git >/dev/null && command -v flock >/dev/null || return 1
        automaton_lock || return 1
        if [[ -e "$AUTOMATON_SOURCE_DIR" ]]; then
            automaton_verify_source || return 1
            local disabled="$AUTOMATON_BASE/source.disabled.$(date +%Y%m%d_%H%M%S).$$"
            [[ ! -e "$disabled" ]] || return 1
            mv -- "$AUTOMATON_SOURCE_DIR" "$disabled" || return 1
        fi
        rm -f -- "$AUTOMATON_MARKER" || return 1
        echo 'Build deaktiviert, Quellcode gesichert. Keine Prozesse, Wallets oder Runtime-Daten angefasst.'; return 0
    fi
    automaton_runtime_check || return 1
    automaton_build "$mode"
)
