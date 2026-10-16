#!/usr/bin/env bash
set -euo pipefail
WAN21_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
WAN21_URL=https://github.com/Wan-Video/Wan2.1.git
WAN21_COMMIT=9737cba9c1c3c4d04b33fcad41c111989865d315

wan21_paths() {
    local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
    [[ "$root" == /* && "$root" != / ]] || return 1
    case "$root/" in "$WAN21_ROOT/"*) echo 'Wan21: Workspace nicht im Setup-Repo ablegen.' >&2; return 1 ;; esac
    WAN21_BASE="$root/tools/wan21"
    WAN21_SOURCE="$WAN21_BASE/source"
    WAN21_VENV="$WAN21_BASE/venv"
    WAN21_MARKER="$WAN21_BASE/source-ready"
    WAN21_RUNTIME_MARKER="$WAN21_BASE/runtime-ready"
    WAN21_LOGS="$root/install_logs"
    for path in "$root" "$WAN21_BASE" "$WAN21_SOURCE" "$WAN21_SOURCE/.git" "$WAN21_VENV" "$WAN21_MARKER" "$WAN21_RUNTIME_MARKER" "$WAN21_LOGS" "$WAN21_BASE/operation.lock" "$WAN21_BASE/runtime-constraints.txt"; do
        [[ ! -L "$path" && "$(realpath -m -- "$path")" == "$path" ]] || {
            echo 'Wan21: Symlink/nicht normalisierter Pfad; nichts veraendert.' >&2; return 1;
        }
    done
}

wan21_source_ok() {
    [[ -d "$WAN21_SOURCE/.git" ]] &&
        [[ "$(git -C "$WAN21_SOURCE" rev-parse --show-toplevel)" == "$WAN21_SOURCE" ]] &&
        [[ "$(git -C "$WAN21_SOURCE" remote get-url origin)" == "$WAN21_URL" ]] &&
        [[ "$(git -C "$WAN21_SOURCE" rev-parse HEAD)" == "$WAN21_COMMIT" ]] &&
        [[ -z "$(git -C "$WAN21_SOURCE" status --porcelain --untracked-files=all)" ]]
}

wan21_source_check() {
    wan21_source_ok || return 1
    "$WAN21_PYTHON" -I -B - "$WAN21_SOURCE" <<'PY'
import ast
from pathlib import Path
import sys
root = Path(sys.argv[1])
for name in ('generate.py', 'wan/modules/model.py', 'wan/modules/attention.py'):
    ast.parse((root / name).read_text(encoding='utf-8'), filename=name)
assert (root / 'requirements.txt').is_file()
print('Wan2.1-Quellstand und Syntax geprueft; keine Imports/Modelle ausgefuehrt.')
PY
}

wan21_runtime_preflight() {
    [[ "${INSTALL_HEAVY_TOOLS:-0}" == 1 ]] || {
        echo 'Wan21: GPU-Laufzeit braucht zusaetzlich INSTALL_HEAVY_TOOLS=1.' >&2; return 1;
    }
    "$WAN21_PYTHON" -I -B -c 'import sys, venv; assert (3,10) <= sys.version_info < (3,13)' || {
        echo 'Wan21-Laufzeit: Python 3.10-3.12 mit venv erforderlich; Ubuntu 24.04/Python 3.12 passt.' >&2; return 1;
    }
    [[ "$(uname -m)" == x86_64 ]] || { echo 'Automatischer CUDA-Laufzeitpfad ist auf Linux x86_64 begrenzt; ARM nur Quellcode.' >&2; return 1; }
    command -v nvidia-smi >/dev/null && nvidia-smi >/dev/null 2>&1 || {
        echo 'Wan21: nutzbare NVIDIA-GPU/Treiber fehlen; keine Treiberinstallation.' >&2; return 1;
    }
    command -v nvcc >/dev/null && nvcc --version | grep -q 'release 12.8' || {
        echo 'Wan21: CUDA Toolkit 12.8/nvcc fuer Flash-Attention-Build erforderlich; separat einrichten.' >&2; return 1;
    }
    command -v c++ >/dev/null && command -v tar >/dev/null || { echo 'Wan21: C++-Compiler oder tar fehlt; separat einrichten.' >&2; return 1; }
    [[ "${WAN21_BUILD_JOBS:-2}" =~ ^[1-4]$ ]] || { echo 'WAN21_BUILD_JOBS muss 1 bis 4 sein.' >&2; return 1; }
}

wan21_fetch_source() {
    if [[ -e "$WAN21_SOURCE" ]]; then
        wan21_source_ok || {
            echo 'Wan21: fremder/unvollstaendiger/veraenderter Checkout; manuell sichern. Kein Reset oder Loeschen.' >&2; return 1;
        }
    else
        mkdir "$WAN21_SOURCE"
        git -C "$WAN21_SOURCE" init
        git -C "$WAN21_SOURCE" remote add origin "$WAN21_URL"
        GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$WAN21_SOURCE" fetch --depth 1 origin "$WAN21_COMMIT"
        git -c core.hooksPath=/dev/null -C "$WAN21_SOURCE" checkout --detach FETCH_HEAD
    fi
    wan21_source_check || return 1
    printf '%s\n' "$WAN21_COMMIT" > "$WAN21_MARKER"
    echo 'Wan2.1 aus GitHub installiert (Quellcode). Kein Docker, Modelle, Server oder Rendering.'
}

wan21_runtime_check() {
    [[ -f "$WAN21_RUNTIME_MARKER" && "$(<"$WAN21_RUNTIME_MARKER")" == "$WAN21_COMMIT" && -x "$WAN21_VENV/bin/python" ]] || return 1
    "$WAN21_VENV/bin/python" -I -B -m pip --isolated check || return 1
    # Metadata only. No torch/CUDA/model import in status/doctor.
    "$WAN21_VENV/bin/python" -I -B -c \
        'from importlib.metadata import version; assert version("torch").split("+")[0] == "2.10.0"; assert version("torchvision").split("+")[0] == "0.25.0"; assert version("wan") == "2.1.0"; version("flash-attn")'
}

wan21_install_runtime() {
    local constraints="$WAN21_BASE/runtime-constraints.txt" build_source
    [[ ! -e "$WAN21_VENV" || -f "$WAN21_VENV/pyvenv.cfg" ]] || {
        echo 'Wan21: venv-Ziel ist fremd; nichts ueberschrieben.' >&2; return 1;
    }
    rm -f -- "$WAN21_RUNTIME_MARKER"
    build_source="$(mktemp -d "$WAN21_BASE/runtime-build.XXXXXX")"
    # Build outside the managed checkout: setuptools writes build/egg-info.
    git -C "$WAN21_SOURCE" archive "$WAN21_COMMIT" | tar -x -C "$build_source"
    echo "Paket-Buildkopie fuer Diagnose: $build_source"
    "$WAN21_PYTHON" -I -B -m venv "$WAN21_VENV"
    printf '%s\n' 'torch==2.10.0' 'torchvision==0.25.0' 'numpy==1.26.4' 'transformers<5' > "$constraints"
    export PIP_CONSTRAINT="$constraints" MAX_JOBS="${WAN21_BUILD_JOBS:-2}"
    export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 HF_HUB_DISABLE_TELEMETRY=1
    "$WAN21_VENV/bin/python" -I -B -m pip --isolated install --index-url https://pypi.org/simple \
        --no-cache-dir --disable-pip-version-check 'setuptools>=61' wheel packaging ninja
    "$WAN21_VENV/bin/python" -I -B -m pip --isolated install --index-url https://download.pytorch.org/whl/cu128 \
        --no-cache-dir --only-binary=:all: torch==2.10.0 torchvision==0.25.0
    "$WAN21_VENV/bin/python" -I -B -m pip --isolated install --index-url https://pypi.org/simple \
        --no-cache-dir --no-build-isolation -c "$constraints" flash-attn
    "$WAN21_VENV/bin/python" -I -B -m pip --isolated install --index-url https://pypi.org/simple \
        --no-cache-dir -c "$constraints" -r "$WAN21_SOURCE/requirements.txt" "$build_source"
    "$WAN21_VENV/bin/python" -I -B -m pip --isolated check
    "$WAN21_VENV/bin/python" -I -B -c \
        'from importlib.metadata import version; assert version("torch").split("+")[0] == "2.10.0"; assert version("torchvision").split("+")[0] == "0.25.0"; assert version("wan") == "2.1.0"; version("flash-attn")'
    printf '%s\n' "$WAN21_COMMIT" > "$WAN21_RUNTIME_MARKER"
    echo 'GPU-Pakete installiert; CUDA-/Flash-Attention-Funktion und Modellinferenz NICHT getestet.'
}

wan21_main() (
    set -euo pipefail
    umask 077
    local mode="${1:-install}" mount program log
    wan21_paths || return 1
    case "$mode" in
        --dry-run|--plan|plan|--help)
            echo "Wan21 GitHub: $WAN21_URL; Commit: $WAN21_COMMIT; kein Docker."
            echo "Standard: nur Quellcode. WAN21_INSTALL_RUNTIME=${WAN21_INSTALL_RUNTIME:-0}; schwere Pakete nur mit INSTALL_HEAVY_TOOLS=1."
            echo 'Keine Modelle/Cloud/Dienste. Kein Download im Dry-Run.'; return 0 ;;
        install|update|--repair|status|--status|doctor|check|--check|uninstall|--uninstall) ;;
        *) echo 'Wan21: nur Source-/Paketverwaltung, kein automatischer Generierungs-/Serverstart.' >&2; return 2 ;;
    esac
    WAN21_PYTHON="${WAN21_PYTHON_BIN:-python3}"
    for program in git "$WAN21_PYTHON"; do
        command -v "$program" >/dev/null || { echo "Wan21: $program fehlt; Basiswerkzeug separat einrichten." >&2; return 1; }
    done
    case "$mode" in
        status|--status)
            if [[ -f "$WAN21_MARKER" && "$(<"$WAN21_MARKER")" == "$WAN21_COMMIT" ]] && wan21_source_check >/dev/null 2>&1; then
                echo '{"source_ready":true,"models_ready":"not_checked","inference_tested":false}'
            else
                echo '{"source_ready":false,"models_ready":"not_checked","inference_tested":false}'
            fi
            return 0 ;;
        doctor|check|--check)
            [[ -f "$WAN21_MARKER" && "$(<"$WAN21_MARKER")" == "$WAN21_COMMIT" ]] && wan21_source_check || return 1
            if [[ -e "$WAN21_RUNTIME_MARKER" ]]; then wan21_runtime_check || return 1; else echo 'GPU-Pakete nicht eingerichtet; Quellcode allein ist keine fertige Videolaufzeit.'; fi
            return 0 ;;
    esac
    [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || { echo 'Wan21 auf Linux als normaler Benutzer ohne sudo aufrufen.' >&2; return 1; }
    command -v flock >/dev/null || { echo 'Wan21: flock fehlt (util-linux).' >&2; return 1; }
    if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
        [[ "${WAN21_INSTALL_RUNTIME:-0}" == 0 || "${WAN21_INSTALL_RUNTIME:-0}" == 1 ]] || return 2
        [[ "${WAN21_INSTALL_RUNTIME:-0}" == 0 ]] || wan21_runtime_preflight || return 1
        mount="$WAN21_BASE"
        while [[ ! -d "$mount" ]]; do mount="${mount%/*}"; [[ -n "$mount" ]] || mount=/; done
        # shellcheck source=../../lib/resource_check.sh
        source "$WAN21_ROOT/scripts/lib/resource_check.sh"
        if [[ "${WAN21_INSTALL_RUNTIME:-0}" == 1 ]]; then
            require_ram_mb 16384
            REQUIRE_WINDOWS_HOST_FREE_MB=32768 require_disk_mb 32768 "$mount"
        else
            REQUIRE_WINDOWS_HOST_FREE_MB=1024 require_disk_mb 512 "$mount"
        fi
    elif [[ ! -d "$WAN21_BASE" ]]; then echo 'Wan21 nicht eingerichtet; nichts deaktiviert.'; return 0; fi
    mkdir -p "$WAN21_BASE" "$WAN21_LOGS"
    exec 9>"$WAN21_BASE/operation.lock"
    flock -n 9 || { echo 'Wan21: andere Operation aktiv.' >&2; return 1; }
    log="$(mktemp "$WAN21_LOGS/wan21_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
    exec > >(tee -a "$log") 2>&1
    echo "Wan21-Installer: 2026-10-16-github-source; Aktion: $mode; Commit: $WAN21_COMMIT"
    trap 'rc=$?; if ((rc != 0)); then echo "Wan21-Fehler ($rc). Dateien erhalten. Log: $log; nach Behebung --repair verwenden."; fi' EXIT
    if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
        rm -f -- "$WAN21_MARKER" "$WAN21_RUNTIME_MARKER"
        echo 'Setup-Markierungen deaktiviert; Quelle, venv, Modelle, Exporte und Logs bleiben erhalten.'; return 0
    fi
    wan21_fetch_source
    if [[ "${WAN21_INSTALL_RUNTIME:-0}" == 1 ]]; then
        if [[ "$mode" == install ]] && wan21_runtime_check >/dev/null 2>&1; then
            echo 'Paketinstallation bereits konsistent; kein erneuter Build.'
        else wan21_install_runtime; fi
    else echo 'GPU-Laufzeit bewusst ausgelassen. Siehe docs/tools/wan21.md.'; fi
)
