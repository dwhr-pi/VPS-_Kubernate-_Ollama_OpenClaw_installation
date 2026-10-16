#!/usr/bin/env bash
set -euo pipefail
TGI_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
TGI_URL=https://github.com/huggingface/text-generation-inference.git
TGI_COMMIT=dfb3fbe78e0d1d69251bd33065591c61bafdfaa8
TGI_RELEASE=v3.3.7

tgi_paths() {
    local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path index=0
    local -a paths=() resolved=()
    [[ "$root" == /* && "$root" != / ]] || return 1
    case "$root/" in "$TGI_ROOT/"*) echo 'TGI-Daten ausserhalb des Setup-Repos ablegen.' >&2; return 1 ;; esac
    TGI_BASE="$root/tools/tgi"
    TGI_SOURCE="$TGI_BASE/source"
    TGI_TARGET="$TGI_BASE/build"
    TGI_BINARY="$TGI_TARGET/release/text-generation-launcher"
    TGI_MARKER="$TGI_BASE/source-ready"
    TGI_BUILD_MARKER="$TGI_BASE/launcher-built"
    TGI_LOGS="$root/install_logs"
    TGI_PYTHON="${TGI_PYTHON_BIN:-python3}"
    paths=("$root" "$TGI_BASE" "$TGI_SOURCE" "$TGI_SOURCE/.git" "$TGI_MARKER" "$TGI_BUILD_MARKER" "$TGI_TARGET" "$TGI_TARGET/release" "$TGI_BINARY" "$TGI_LOGS" "$TGI_BASE/operation.lock")
    mapfile -t resolved < <(realpath -m -- "${paths[@]}")
    [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
    for path in "${paths[@]}"; do
        [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || { echo 'TGI: Symlink/nicht normalisierter Pfad; Abbruch.' >&2; return 1; }
        index=$((index + 1))
    done
}

tgi_source_ok() {
    [[ -d "$TGI_SOURCE/.git" ]] &&
        [[ "$(git -C "$TGI_SOURCE" rev-parse --show-toplevel)" == "$TGI_SOURCE" ]] &&
        [[ "$(git -C "$TGI_SOURCE" remote get-url origin)" == "$TGI_URL" ]] &&
        [[ "$(git -C "$TGI_SOURCE" rev-parse HEAD)" == "$TGI_COMMIT" ]] &&
        [[ -z "$(git -C "$TGI_SOURCE" status --porcelain --untracked-files=all)" ]]
}

tgi_inspect() {
    tgi_source_ok || return 1
    "$TGI_PYTHON" -I -B - "$TGI_SOURCE" <<'PY'
import ast
from pathlib import Path
import sys
root = Path(sys.argv[1])
for name in ('Cargo.toml', 'Cargo.lock', 'launcher/Cargo.toml', 'server/pyproject.toml', 'LICENSE'):
    assert (root / name).is_file(), name
ast.parse((root / 'server/text_generation_server/cli.py').read_text(encoding='utf-8'))
print('TGI-Pin, Paketlayout und Python-Syntax geprueft. Kein Import/Modelltest.')
PY
}

tgi_fetch() {
    if [[ -e "$TGI_SOURCE" ]]; then
        tgi_source_ok || { echo 'TGI-Quelle fremd/unvollstaendig/veraendert; manuell sichern, kein Reset.' >&2; return 1; }
    else
        git -c init.defaultBranch=main init "$TGI_SOURCE"
        git -C "$TGI_SOURCE" remote add origin "$TGI_URL"
        GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$TGI_SOURCE" fetch --depth 1 origin "$TGI_COMMIT"
        GIT_LFS_SKIP_SMUDGE=1 git -c core.hooksPath=/dev/null -C "$TGI_SOURCE" checkout --detach FETCH_HEAD
    fi
    tgi_inspect || return 1
    printf '%s\n' "$TGI_COMMIT" > "$TGI_MARKER"
    echo 'TGI-GitHub-Quellen vorbereitet; kein betriebsbereiter Inferenzserver.'
}

tgi_launcher_ok() {
    local digest
    [[ -f "$TGI_BUILD_MARKER" && -x "$TGI_BINARY" ]] || return 1
    digest="$(sha256sum "$TGI_BINARY")"
    [[ "$(<"$TGI_BUILD_MARKER")" == "$TGI_COMMIT ${digest%% *}" ]]
}

tgi_launcher_preflight() {
    local program
    [[ "${INSTALL_HEAVY_TOOLS:-0}" == 1 ]] || { echo 'Nativer TGI-Build braucht zusaetzlich INSTALL_HEAVY_TOOLS=1.' >&2; return 1; }
    for program in cargo rustc cc pkg-config sha256sum; do
        command -v "$program" >/dev/null || { echo "TGI-Launcher: $program fehlt; Toolchain separat einrichten." >&2; return 1; }
    done
    pkg-config --exists openssl || { echo 'OpenSSL-Entwicklungspaket fehlt (Ubuntu: libssl-dev).' >&2; return 1; }
    "$TGI_PYTHON" -I -B -c 'import sys, sysconfig; from pathlib import Path; assert (3,10) <= sys.version_info < (3,13); assert (Path(sysconfig.get_path("include")) / "Python.h").is_file(); assert (Path(sysconfig.get_config_var("LIBDIR")) / sysconfig.get_config_var("LDLIBRARY")).is_file()' || {
        echo 'TGI/PyO3 braucht Python 3.10-3.12 samt Entwicklungsheadern und libpython; z.B. passendes python3-dev. Kein automatischer Python-Umbau.' >&2; return 1;
    }
}

tgi_build_launcher() (
    local digest
    rm -f -- "$TGI_BUILD_MARKER"
    cd "$TGI_SOURCE"
    export CARGO_TARGET_DIR="$TGI_TARGET" CARGO_BUILD_JOBS=1 PYO3_PYTHON="$TGI_PYTHON"
    cargo build --locked --release --jobs 1 -p text-generation-launcher
    [[ -x "$TGI_BINARY" ]] || return 1
    digest="$(sha256sum "$TGI_BINARY")"
    printf '%s %s\n' "$TGI_COMMIT" "${digest%% *}" > "$TGI_BUILD_MARKER"
    echo 'Nativer TGI-Launcher gebaut, NICHT gestartet. Router/Python-Shard/GPU-Laufzeit fehlen weiterhin.'
)

tgi_deactivate() {
    rm -f -- "$TGI_MARKER" "$TGI_BUILD_MARKER"
    echo 'TGI-Marker deaktiviert; Quellen, Binary, Caches, Modelle und Logs bleiben erhalten.'
}

tgi_main() (
    set -euo pipefail
    umask 077
    local mode="${1:-install}" build="${TGI_BUILD_LAUNCHER:-0}" program mount log available launcher=false
    tgi_paths || return 1
    case "$mode" in
        --dry-run|--plan|plan|--help)
            echo "TGI $TGI_RELEASE: GitHub $TGI_URL; Pin $TGI_COMMIT; ohne Docker. Maintenance Mode."
            echo "Standard Quellen, optional TGI_BUILD_LAUNCHER=$build und INSTALL_HEAVY_TOOLS=1. Kein kompletter Inferenzserver."
            echo 'Keine Downloads/Modelle/Server im Dry-Run. Quellen: 1 GiB Disk/2 GiB Windows-C:; Launcher: 6 GiB RAM/4 GiB verfuegbar, 10 GiB Disk/Windows-C:.'; return 0 ;;
        status|--status)
            if [[ -f "$TGI_MARKER" && "$(<"$TGI_MARKER")" == "$TGI_COMMIT" ]] && tgi_source_ok >/dev/null 2>&1; then
                if tgi_launcher_ok >/dev/null 2>&1; then launcher=true; fi
                printf '{"source_ready":true,"launcher_built":%s,"inference_ready":false}\n' "$launcher"
            else echo '{"source_ready":false,"launcher_built":false,"inference_ready":false}'; fi
            return 0 ;;
        doctor|check|--check)
            [[ -f "$TGI_MARKER" && "$(<"$TGI_MARKER")" == "$TGI_COMMIT" ]] && tgi_inspect || return 1
            if [[ -e "$TGI_BUILD_MARKER" ]]; then tgi_launcher_ok || return 1; fi
            echo 'Nur Quelle/Syntax und ggf. Binary-Hash konsistent. Keine Binary-Ausfuehrung, keine Inferenzbereitschaft.'; return 0 ;;
        install|update|--repair|uninstall|--uninstall) ;;
        *) echo 'TGI: nur Quell-/Launcher-Verwaltung; kein Serve-/Download-/Login-Start.' >&2; return 2 ;;
    esac
    [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || { echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2; return 1; }
    for program in git "$TGI_PYTHON" flock; do command -v "$program" >/dev/null || { echo "TGI: $program fehlt; Basis separat einrichten." >&2; return 1; }; done
    if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
        "$TGI_PYTHON" -I -B -c 'import sys; assert sys.version_info >= (3,10)' || { echo 'Python 3.10+ fuer die Quellpruefung erforderlich.' >&2; return 1; }
        [[ "$build" == 0 || "$build" == 1 ]] || { echo 'TGI_BUILD_LAUNCHER muss 0 oder 1 sein.' >&2; return 2; }
        if [[ "$build" == 1 ]]; then tgi_launcher_preflight || return 1; fi
        mount="$TGI_BASE"
        while [[ ! -d "$mount" ]]; do mount="${mount%/*}"; [[ -n "$mount" ]] || mount=/; done
        # shellcheck source=../../lib/resource_check.sh
        source "$TGI_ROOT/scripts/lib/resource_check.sh"
        if [[ "$build" == 1 ]]; then
            require_ram_mb 6144
            available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
            [[ "$available" =~ ^[0-9]+$ && "$available" -ge 4096 ]] || { echo 'TGI: mindestens 4096 MiB verfuegbaren RAM freimachen.' >&2; return 1; }
            REQUIRE_WINDOWS_HOST_FREE_MB=10240 require_disk_mb 10240 "$mount"
        else REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 1024 "$mount"; fi
    elif [[ ! -d "$TGI_BASE" ]]; then echo 'Nicht eingerichtet; nichts deaktiviert.'; return 0; fi
    mkdir -p "$TGI_BASE" "$TGI_LOGS"
    exec 9>"$TGI_BASE/operation.lock"
    flock -n 9 || { echo 'Andere TGI-Operation aktiv.' >&2; return 1; }
    log="$(mktemp "$TGI_LOGS/tgi_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
    exec > >(tee -a "$log") 2>&1
    echo "TGI-Installer: 2026-10-16-github-source-launcher; Aktion: $mode; Pin: $TGI_COMMIT"
    trap 'rc=$?; if ((rc != 0)); then echo "TGI-Fehler ($rc); Dateien erhalten. Log: $log. Nach Pruefung --repair verwenden."; fi' EXIT
    if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then tgi_deactivate; return 0; fi
    df -Pk "$TGI_BASE"
    tgi_fetch
    if [[ "$build" == 1 ]]; then
        if [[ "$mode" == install ]] && tgi_launcher_ok; then echo 'Launcher-Build bereits konsistent.'; else tgi_build_launcher; fi
    fi
    df -Pk "$TGI_BASE"
)
