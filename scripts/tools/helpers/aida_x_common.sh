#!/usr/bin/env bash
set -euo pipefail
AX_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
AX_URL=https://github.com/AidaDSP/AIDA-X.git
AX_COMMIT=1027cdd1756505fd2ab1a4adb91a394a3af9df57
AX_VERSION=1.1.0

ax_modules() {
    # Gitlinks resolved from the pinned 1.1.0 source; no submodule --remote.
    cat <<'PINS'
modules/FFTConvolver https://github.com/falkTX/FFTConvolver.git a6111d70c117041ff47608cf387280e9409f2b03
modules/dpf https://github.com/DISTRHO/DPF.git 1504e7d327bfe0eac6a889cecd199c963d35532f
modules/dpf-widgets https://github.com/DISTRHO/DPF-Widgets.git 73e9aa67b92430db863d7d7b292b66cd7d2c8190
modules/dr_libs https://github.com/mackron/dr_libs.git 4b3d07849537ce0b71b22180c0b1335eacc6e9be
modules/r8brain https://github.com/avaneev/r8brain-free-src.git 8ce873a7e797c9dc39d5c2603eb4a900d71385cb
modules/rtneural https://github.com/jatinchowdhury18/RTNeural.git 0169432522392ed2c747511a3b65c603700189af
modules/dpf/dgl/src/pugl-upstream https://github.com/DISTRHO/pugl.git 21cb3c8b480f4c97f888e3d08630ded9c8bf04a2
modules/rtneural/modules/xsimd https://github.com/xtensor-stack/xsimd.git e12bf0a928bd6668ff701db55803a9e316cb386c
PINS
}

ax_paths() {
    local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
    [[ "$root" == /* && "$root" != / ]] || return 1
    case "$root/" in "$AX_ROOT/"*) echo 'AIDA-X: User-Daten nicht im Setup-Repo.' >&2; return 1 ;; esac
    AX_BASE="$root/tools/aida_x"
    AX_SOURCE="$AX_BASE/source"
    AX_BUILD="$AX_BASE/build"
    AX_BINARY="$AX_BUILD/bin/AIDA-X"
    AX_MARKER="$AX_BASE/source-ready"
    AX_NATIVE="$AX_BASE/native.json"
    AX_LOGS="$root/install_logs"
    local -a paths=("$root" "$AX_BASE" "$AX_SOURCE" "$AX_SOURCE/.git" "$AX_BUILD" "$AX_BUILD/bin" "$AX_BINARY" "$AX_MARKER" "$AX_NATIVE" "$AX_LOGS" "$AX_BASE/operation.lock") resolved=()
    local index=0
    mapfile -t resolved < <(realpath -m -- "${paths[@]}")
    [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
    for path in "${paths[@]}"; do
        [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || { echo 'AIDA-X: Symlink/nicht normalisierter Pfad.' >&2; return 1; }
        index=$((index + 1))
    done
}

ax_repo_ok() {
    local path="$1" url="$2" commit="$3" top state
    top="$(git -C "$path" rev-parse --show-toplevel)" || return 1
    [[ -n "$top" ]] || return 1
    state="$(git -C "$path" status --porcelain --untracked-files=all --ignore-submodules=none)" || return 1
    [[ -d "$path/.git" && ! -L "$path/.git" ]] &&
        [[ "$top" -ef "$path" ]] &&
        [[ "$(git -C "$path" remote get-url origin)" == "$url" ]] &&
        [[ "$(git -C "$path" rev-parse HEAD)" == "$commit" ]] &&
        [[ -z "$state" ]]
}

ax_checkout() {
    local path="$1" url="$2" commit="$3"
    [[ ! -L "$path" && "$(realpath -m -- "$path")" == "$path" ]] || return 1
    if [[ -e "$path" && ! -d "$path/.git" ]]; then
        [[ -d "$path" && -z "$(find "$path" -mindepth 1 -maxdepth 1 -print -quit)" ]] || {
            echo 'AIDA-X: Fremder/unvollstaendiger Quellordner; nichts geloescht.' >&2; return 1;
        }
    fi
    if [[ -d "$path/.git" ]]; then
        ax_repo_ok "$path" "$url" "$commit" || { echo 'AIDA-X: Quelle geaendert/fremd; manuell sichern, kein Reset.' >&2; return 1; }
    else
        git -c init.defaultBranch=main init "$path" || return 1
        git -C "$path" remote add origin "$url" || return 1
        GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$path" fetch --depth 1 origin "$commit" || return 1
        GIT_LFS_SKIP_SMUDGE=1 GIT_TERMINAL_PROMPT=0 git -c credential.helper= -c core.hooksPath=/dev/null -C "$path" checkout --detach FETCH_HEAD || return 1
    fi
    ax_repo_ok "$path" "$url" "$commit"
}

ax_source_ok() {
    local rel url commit path
    ax_repo_ok "$AX_SOURCE" "$AX_URL" "$AX_COMMIT" || return 1
    while read -r rel url commit; do
        path="$AX_SOURCE/$rel"
        [[ ! -L "$path" && "$(realpath -m -- "$path")" == "$path" ]] || return 1
        ax_repo_ok "$path" "$url" "$commit" || return 1
    done < <(ax_modules)
    [[ -f "$AX_SOURCE/CMakeLists.txt" && -f "$AX_SOURCE/src/aidadsp-plugin.cpp" && -f "$AX_SOURCE/LICENSE" ]]
}

ax_fetch() {
    local rel url commit
    ax_checkout "$AX_SOURCE" "$AX_URL" "$AX_COMMIT" || return 1
    while read -r rel url commit; do
        ax_checkout "$AX_SOURCE/$rel" "$url" "$commit" || return 1
    done < <(ax_modules)
    ax_source_ok || return 1
    printf '%s\n' "$AX_COMMIT" > "$AX_MARKER"
}

ax_native_record() {
    python3 -I -B - "$AX_BINARY" "$AX_NATIVE" "$AX_COMMIT" "${1:-check}" <<'PY'
import hashlib
import json
import platform
from pathlib import Path
import sys
binary, marker = Path(sys.argv[1]), Path(sys.argv[2])
assert binary.is_file() and not binary.is_symlink()
with binary.open('rb') as stream:
    header = stream.read(32)
    assert len(header) == 32 and header[:6] == bytes([127, 69, 76, 70, 2, 1])
    machine = {'x86_64': 62, 'amd64': 62, 'aarch64': 183, 'arm64': 183}[platform.machine().lower()]
    assert int.from_bytes(header[18:20], 'little') == machine
    stream.seek(0)
    checksum = hashlib.file_digest(stream, 'sha256').hexdigest() if hasattr(hashlib, 'file_digest') else None
if checksum is None:
    checksum = hashlib.sha256(binary.read_bytes()).hexdigest()
record = {'commit': sys.argv[3], 'sha256': checksum}
if sys.argv[4] == 'write':
    marker.write_text(json.dumps(record) + '\n', encoding='utf-8')
else:
    assert json.loads(marker.read_text(encoding='utf-8')) == record
PY
}

ax_build_preflight() {
    local tool
    for tool in cmake make cc c++ pkg-config; do
        command -v "$tool" >/dev/null || { echo "AIDA-X Build: $tool fehlt; Build-Werkzeuge separat einrichten." >&2; return 1; }
    done
    pkg-config --exists x11 xcursor xrandr xinerama gl alsa jack || {
        echo 'AIDA-X Build: X11/OpenGL/ALSA/JACK-Entwicklungsbibliotheken fehlen. Siehe docs/tools/aida-x.md.' >&2; return 1;
    }
    AX_JOBS="${AIDA_X_BUILD_JOBS:-1}"
    [[ "$AX_JOBS" =~ ^[12]$ ]] || { echo 'AIDA_X_BUILD_JOBS muss 1 oder 2 sein.' >&2; return 1; }
    if [[ -e "$AX_BUILD" && ( ! -f "$AX_BUILD/.aida-x-build" || -L "$AX_BUILD/.aida-x-build" ) ]]; then
        echo 'AIDA-X: Fremder Build-Ordner; nichts ueberschrieben.' >&2; return 1
    fi
    if [[ -f "$AX_BUILD/.aida-x-build" && "$(<"$AX_BUILD/.aida-x-build")" != "$AX_COMMIT" ]]; then
        echo 'AIDA-X: Build-Ordner gehoert zu anderem Pin; nichts ueberschrieben.' >&2; return 1
    fi
}

ax_build_native() {
    rm -f -- "$AX_NATIVE"
    mkdir -p "$AX_BUILD"
    [[ ! -L "$AX_BUILD/.aida-x-build" && ! -L "$AX_BUILD/CMakeCache.txt" ]] || return 1
    printf '%s\n' "$AX_COMMIT" > "$AX_BUILD/.aida-x-build"
    cmake -S "$AX_SOURCE" -B "$AX_BUILD" -DCMAKE_BUILD_TYPE=Release \
        -DJUCE_EXTRA=OFF -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
        -DBUILD_TESTS=OFF -DBUILD_BENCH=OFF -DBUILD_EXAMPLES=OFF || return 1
    cmake --build "$AX_BUILD" --target AIDA-X-Standalone-jack --parallel "$AX_JOBS" || return 1
    ax_source_ok || return 1
    ax_native_record write
    echo "AIDA-X-Standalone gebaut: $AX_BINARY; nicht gestartet, kein Audiotest."
}

aida_x_main() (
    set -euo pipefail
    umask 077
    local mode="${1:-install}" tool mount log native=false reserve=1024
    ax_paths || return 1
    case "$mode" in
        --dry-run|--plan|plan|--help)
            echo "AIDA-X 1.1.0: GitHub $AX_URL; Pin $AX_COMMIT; ohne Docker."
            echo 'Standard: Quelle plus 8 gepinnte GitHub-Unterprojekte. AIDA_X_BUILD=1: optional Standalone, max. 1 Job (einstellbar 1-2).'
            echo 'Quelle: 1 GiB freie Disk, WSL C: 2 GiB; Build: 4 GiB RAM/Disk/WSL C:. Kein Audio-/Dienststart.'; return 0 ;;
        status|--status|doctor|check|--check)
            if [[ -f "$AX_MARKER" && "$(<"$AX_MARKER")" == "$AX_COMMIT" ]] && ax_source_ok >/dev/null 2>&1; then
                if ax_native_record check >/dev/null 2>&1; then native=true; fi
                echo "{\"source_ready\":true,\"native_built\":$native,\"audio_tested\":false}"
                return 0
            fi
            echo '{"source_ready":false,"native_built":false,"audio_tested":false}'
            [[ "$mode" == status || "$mode" == --status ]]; return $? ;;
        install|update|--repair|uninstall|--uninstall) ;;
        *) echo 'AIDA-X: nur Quellen/Build verwalten, kein Start/Training.' >&2; return 2 ;;
    esac
    [[ "${AIDA_X_BUILD:-0}" =~ ^[01]$ ]] || { echo 'AIDA_X_BUILD muss 0 oder 1 sein.' >&2; return 2; }
    [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || { echo 'Normalen Linux-Benutzer ohne sudo verwenden.' >&2; return 1; }
    for tool in git python3 flock; do command -v "$tool" >/dev/null || { echo "AIDA-X: $tool fehlt; separat einrichten." >&2; return 1; }; done
    if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
        case "$(uname -m)" in x86_64|aarch64) ;; *) echo 'AIDA-X: automatischer Linux-Pfad nur x86_64/ARM64.' >&2; return 1 ;; esac
        python3 -I -B -c 'import sys; assert sys.version_info >= (3,10)'
        mount="$AX_BASE"
        while [[ ! -d "$mount" ]]; do mount="${mount%/*}"; [[ -n "$mount" ]] || mount=/; done
        source "$AX_ROOT/scripts/lib/resource_check.sh"
        if [[ "${AIDA_X_BUILD:-0}" == 1 ]]; then
            ax_build_preflight || return 1
            require_ram_mb 4096 || return 1
            [[ "$(awk '/^MemAvailable:/ {print int($2/1024)}' /proc/meminfo)" -ge 2048 ]] || { echo 'AIDA-X Build: mindestens 2 GiB aktuell freien RAM schaffen.' >&2; return 1; }
            reserve=4096
        fi
        REQUIRE_WINDOWS_HOST_FREE_MB=$((reserve == 1024 ? 2048 : reserve)) require_disk_mb "$reserve" "$mount"
    elif [[ ! -d "$AX_BASE" ]]; then echo 'Nicht eingerichtet; nichts deaktiviert.'; return 0; fi
    mkdir -p "$AX_BASE" "$AX_LOGS"
    exec 9>"$AX_BASE/operation.lock"
    flock -n 9 || { echo 'Andere AIDA-X-Operation aktiv.' >&2; return 1; }
    log="$(mktemp "$AX_LOGS/aida_x_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
    exec > >(tee -a "$log") 2>&1
    echo "AIDA-X Installer: 2026-10-18-github-native; Aktion: $mode; Pin: $AX_COMMIT"
    trap 'rc=$?; if ((rc)); then echo "AIDA-X Fehler ($rc); Quellen/Daten erhalten. Log: $log; nach Pruefung --repair."; fi' EXIT
    if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
        rm -f -- "$AX_MARKER" "$AX_NATIVE"
        echo 'Quell-/Buildregistrierung deaktiviert; Quellen, Binaerdateien, Modelle/IR und Logs bleiben erhalten.'; return 0
    fi
    df -Pk "$AX_BASE"
    ax_fetch
    if [[ "${AIDA_X_BUILD:-0}" == 1 ]]; then ax_build_native; fi
    df -Pk "$AX_BASE"
    echo 'AIDA-X GitHub-Installation vorbereitet. Build-Status separat pruefen; kein Audio-/Plugin-/Mikrofonstart.'
)
