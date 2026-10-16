#!/usr/bin/env bash
set -euo pipefail
QWEN_CODE_REPO_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
QWEN_CODE_SOURCE_URL=https://github.com/QwenLM/qwen-code.git
QWEN_CODE_SOURCE_COMMIT=c1a8218f38203e272e6e965778ed6a2795cfeed7

qwen_code_paths() {
    local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
    [[ "$root" == /* && "$root" != / ]] || return 1
    case "$root/" in "$QWEN_CODE_REPO_ROOT/"*) echo 'User-Daten muessen ausserhalb des Setup-Repos liegen.' >&2; return 1 ;; esac
    QWEN_CODE_BASE="$root/tools/qwen_code"
    QWEN_CODE_SOURCE_DIR="$QWEN_CODE_BASE/source"
    QWEN_CODE_MARKER="$QWEN_CODE_BASE/source-built"
    QWEN_CODE_LOG_DIR="$root/install_logs"
    local -a paths=("$root" "$QWEN_CODE_BASE" "$QWEN_CODE_SOURCE_DIR" "$QWEN_CODE_MARKER" "$QWEN_CODE_LOG_DIR" "$QWEN_CODE_BASE/operation.lock" "$QWEN_CODE_BASE/build-home") resolved=()
    local index=0
    mapfile -t resolved < <(realpath -m -- "${paths[@]}")
    [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
    for path in "${paths[@]}"; do
        [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
            echo 'Qwen Code: nicht normalisierter Pfad/Symlink; nichts veraendert.' >&2; return 1;
        }
        index=$((index + 1))
    done
}

qwen_code_runtime_check() {
    local program
    for program in node npm pnpm corepack git flock; do
        command -v "$program" >/dev/null || { echo "Qwen Code: $program fehlt; separat einrichten." >&2; return 1; }
    done
    node -e 'if(Number(process.versions.node.split(".")[0])!==22)process.exit(1)' || {
        echo 'Qwen Code: fuer diesen Buildpfad Node 22.x verwenden; System-Node wird nicht ersetzt.' >&2; return 1;
    }
    [[ "$(pnpm --version)" == 11.24.0 && "$(COREPACK_ENABLE_NETWORK=0 corepack pnpm --version)" == 11.24.0 ]] || {
        echo 'Qwen Code: pnpm 11.24.0 laut gepinntem packageManager erforderlich; kein globales Update.' >&2; return 1;
    }
}

qwen_code_require_user() {
    [[ "$EUID" != 0 ]] || { echo 'Qwen Code als normaler Benutzer bauen, nicht sudo/root.' >&2; return 1; }
}

qwen_code_resources() {
    # shellcheck disable=SC1091
    source "$QWEN_CODE_REPO_ROOT/scripts/lib/resource_check.sh"
    require_ram_mb 8192 || return 1
    REQUIRE_WINDOWS_HOST_FREE_MB=10240 require_disk_mb 10240 "$1"
}

qwen_code_lock() {
    mkdir -p "$QWEN_CODE_BASE" || return 1
    exec 9>"$QWEN_CODE_BASE/operation.lock"
    flock -n 9 || { echo 'Qwen Code: andere Build-/Deaktivierungsaktion laeuft.' >&2; return 1; }
}

qwen_code_verify_source() {
    local origin head changes
    [[ -d "$QWEN_CODE_SOURCE_DIR/.git" && ! -L "$QWEN_CODE_SOURCE_DIR/.git" ]] || {
        echo 'Qwen Code: unvollstaendiger Checkout; manuell sichern/pruefen, keine automatische Loeschung.' >&2; return 1;
    }
    origin="$(git -C "$QWEN_CODE_SOURCE_DIR" remote get-url origin)" || return 1
    head="$(git -C "$QWEN_CODE_SOURCE_DIR" rev-parse HEAD)" || return 1
    changes="$(git -C "$QWEN_CODE_SOURCE_DIR" status --porcelain --untracked-files=normal)" || return 1
    [[ "$origin" == "$QWEN_CODE_SOURCE_URL" && "$head" == "$QWEN_CODE_SOURCE_COMMIT" && -z "$changes" ]] || {
        echo 'Qwen Code: Quelle, Commit oder lokale Aenderungen abweichend. Kein Reset/Pull/Ueberschreiben.' >&2; return 1;
    }
}

qwen_code_is_built() {
    [[ -f "$QWEN_CODE_MARKER" && -f "$QWEN_CODE_SOURCE_DIR/dist/cli.js" &&
       -f "$QWEN_CODE_SOURCE_DIR/scripts/cli-entry.js" ]] &&
        grep -Fxq "$QWEN_CODE_SOURCE_COMMIT" "$QWEN_CODE_MARKER"
}

qwen_code_smoke() (
    cd "$QWEN_CODE_SOURCE_DIR" || exit 1
    [[ -f dist/cli.js && -f scripts/cli-entry.js ]] || exit 1
    node --check dist/cli.js && node --check scripts/cli-entry.js
)

qwen_code_build() (
    local mode="$1" mount="$QWEN_CODE_BASE" log before started
    while [[ ! -d "$mount" ]]; do mount="${mount%/*}"; [[ -n "$mount" ]] || mount=/; done
    qwen_code_resources "$mount" || return 1
    qwen_code_lock || return 1
    if [[ -e "$QWEN_CODE_SOURCE_DIR" ]]; then qwen_code_verify_source || return 1; fi
    if [[ "$mode" == install ]] && qwen_code_is_built; then
        qwen_code_smoke || return 1
        echo 'Qwen Code Source-Build bereits vorhanden; kein Agent gestartet.'; return 0
    fi
    mkdir -p "$QWEN_CODE_LOG_DIR" || return 1
    log="$QWEN_CODE_LOG_DIR/$(date +%Y%m%d_%H%M%S)_qwen_code_source_$$.log"
    before="$(df -Pk "$mount" | awk 'NR==2 {print $4}')"
    started="$SECONDS"
    exec > >(tee -a "$log") 2>&1
    trap 'rc=$?; printf "Qwen Code Build Exit=%s Dauer=%ss Disk-vorher-KiB=%s\n" "$rc" "$((SECONDS-started))" "$before"; df -Pk "$mount"; exit "$rc"' EXIT
    echo "Qwen Code GitHub-Source $QWEN_CODE_SOURCE_COMMIT; kein Docker, Login- oder Agentenstart."
    if [[ ! -e "$QWEN_CODE_SOURCE_DIR" ]]; then
        git init "$QWEN_CODE_SOURCE_DIR" || return 1
        git -C "$QWEN_CODE_SOURCE_DIR" remote add origin "$QWEN_CODE_SOURCE_URL" || return 1
        GIT_TERMINAL_PROMPT=0 git -C "$QWEN_CODE_SOURCE_DIR" fetch --depth 1 origin "$QWEN_CODE_SOURCE_COMMIT" || return 1
        git -C "$QWEN_CODE_SOURCE_DIR" -c advice.detachedHead=false checkout --detach "$QWEN_CODE_SOURCE_COMMIT" || return 1
    fi
    qwen_code_verify_source || return 1
    rm -f -- "$QWEN_CODE_MARKER" || return 1
    (
        cd "$QWEN_CODE_SOURCE_DIR" || exit 1
        [[ -f pnpm-lock.yaml && -f pnpm-workspace.yaml && -f package.json ]] || exit 1
        # Pinned dependency lifecycle scripts may run; never invoke the agent entry point.
        export BUILD_SANDBOX=0 QWEN_SANDBOX=false QWEN_SKIP_PREPARE=1 HUSKY=0
        export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 PUPPETEER_SKIP_DOWNLOAD=1 COREPACK_ENABLE_NETWORK=0
        export QWEN_HOME="$QWEN_CODE_BASE/build-home"
        pnpm install --frozen-lockfile && pnpm run build --cli-only && pnpm run bundle
    ) || { echo 'Qwen Code Build fehlgeschlagen. Privates Log, Node/pnpm und native Build-Werkzeuge pruefen.' >&2; return 1; }
    qwen_code_smoke || { echo 'Qwen Code: Build/Syntax-Test fehlgeschlagen.' >&2; return 1; }
    printf '%s\n' "$QWEN_CODE_SOURCE_COMMIT" > "$QWEN_CODE_MARKER" || return 1
    echo 'Qwen Code aus GitHub gebaut. Kein globales CLI, kein Dienst, keine Authentifizierung oder Modellabfrage.'
)

qwen_code_main() (
    umask 077
    local mode="${1:---dry-run}"
    case "$mode" in
        --dry-run|--plan|plan) mode=plan ;; --check|check|--status|status) mode=status ;;
        --repair|repair) mode=update ;; --uninstall) mode=uninstall ;;
        install|update|uninstall|doctor) ;;
        *) echo 'Qwen Code: nur Source-Build/Status/Doctor/Deaktivierung. Agentenstart und Login bleiben gesperrt.' >&2; return 2 ;;
    esac
    qwen_code_paths || return 1
    if [[ "$mode" == plan ]]; then
        echo "Qwen Code: GitHub $QWEN_CODE_SOURCE_COMMIT, pnpm 11.24.0, Node 22.x; ohne Docker."
        echo 'Planungsreserve: 8 GiB RAM/10 GiB Disk, WSL-Hostreserve 10 GiB. Kein Download/Start im Dry-Run.'; return 0
    fi
    if [[ "$mode" == status || "$mode" == doctor ]]; then
        qwen_code_is_built && qwen_code_verify_source || { echo 'Qwen Code: kein verifizierter Source-Build vorhanden.' >&2; return 1; }
        if [[ "$mode" == doctor ]]; then qwen_code_runtime_check && qwen_code_smoke || return 1; fi
        echo 'Qwen Code Source-Build vorhanden; Agent-/Login-Status wird nicht gelesen.'; return 0
    fi
    qwen_code_require_user || return 1
    if [[ "$mode" == uninstall ]]; then
        command -v git >/dev/null && command -v flock >/dev/null || return 1
        qwen_code_lock || return 1
        if [[ -e "$QWEN_CODE_SOURCE_DIR" ]]; then
            qwen_code_verify_source || return 1
            local disabled="$QWEN_CODE_BASE/source.disabled.$(date +%Y%m%d_%H%M%S).$$"
            [[ ! -e "$disabled" ]] || return 1
            mv -- "$QWEN_CODE_SOURCE_DIR" "$disabled" || return 1
        fi
        rm -f -- "$QWEN_CODE_MARKER" || return 1
        echo 'Build deaktiviert, Quellcode gesichert. Keine Prozesse, Logins oder Runtime-Daten angefasst.'; return 0
    fi
    qwen_code_runtime_check || return 1
    qwen_code_build "$mode"
)
