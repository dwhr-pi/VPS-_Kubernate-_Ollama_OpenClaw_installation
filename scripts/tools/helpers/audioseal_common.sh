#!/usr/bin/env bash
set -euo pipefail
AS_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
AS_URL=https://github.com/facebookresearch/audioseal.git
AS_COMMIT=e63a8a0e5cdf7bb797159c92ba15961557fe9bd2
AS_VERSION=0.2.0

as_paths() {
    local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
    [[ "$root" == /* && "$root" != / ]] || return 1
    case "$root/" in "$AS_ROOT/"*) echo 'AudioSeal-Workspace nicht im Setup-Repo ablegen.' >&2; return 1 ;; esac
    AS_BASE="$root/tools/audioseal"
    AS_SOURCE="$AS_BASE/source"
    AS_VENV="$AS_BASE/venv"
    AS_MARKER="$AS_BASE/source-built"
    AS_LOGS="$root/install_logs"
    AS_PYTHON="${AUDIOSEAL_PYTHON_BIN:-python3}"
    for path in "$root" "$AS_BASE" "$AS_SOURCE" "$AS_SOURCE/.git" "$AS_VENV" "$AS_VENV/bin" "$AS_VENV/bin/python" "$AS_MARKER" "$AS_LOGS" "$AS_BASE/operation.lock" "$AS_BASE/constraints.txt"; do
        # venv/bin/python normally is a symlink; validate its containing directory instead.
        [[ "$path" == "$AS_VENV/bin/python" ]] && continue
        [[ ! -L "$path" && "$(realpath -m -- "$path")" == "$path" ]] || {
            echo 'AudioSeal: Symlink/nicht normalisierter Pfad; Abbruch.' >&2; return 1;
        }
    done
}

as_source_ok() {
    [[ -d "$AS_SOURCE/.git" ]] &&
        [[ "$(git -C "$AS_SOURCE" rev-parse --show-toplevel)" == "$AS_SOURCE" ]] &&
        [[ "$(git -C "$AS_SOURCE" remote get-url origin)" == "$AS_URL" ]] &&
        [[ "$(git -C "$AS_SOURCE" rev-parse HEAD)" == "$AS_COMMIT" ]] &&
        [[ -z "$(git -C "$AS_SOURCE" status --porcelain --untracked-files=all)" ]]
}

as_metadata() {
    "$AS_VENV/bin/python" -I -B -c \
        'from importlib.metadata import version; assert version("audioseal") == "0.2.0"; assert version("torch") == "2.10.0+cpu"'
}

as_probe() {
    [[ -f "$AS_MARKER" && "$(<"$AS_MARKER")" == "$AS_COMMIT cpu" && -x "$AS_VENV/bin/python" ]] || return 1
    as_source_ok && as_metadata && "$AS_VENV/bin/python" -I -B -m pip --isolated check
}

as_preflight() {
    [[ "$(uname -m)" == x86_64 ]] || {
        echo 'AudioSeal: automatischer CPU-Paketpfad nur Linux x86_64; ARM/native Windows noch nicht getestet.' >&2; return 1;
    }
    "$AS_PYTHON" -I -B -c 'import sys; assert (3,10) <= sys.version_info < (3,14)' || {
        echo 'AudioSeal: vorhandenes Python 3.10-3.13 verwenden, Ubuntu-Python 3.12 passt.' >&2; return 1;
    }
    [[ ! -e "$AS_VENV" || -f "$AS_VENV/pyvenv.cfg" ]] || {
        echo 'Fremdes venv-Verzeichnis; nichts ueberschrieben.' >&2; return 1;
    }
}

as_resources() {
    local mount="$AS_BASE" available
    while [[ ! -d "$mount" ]]; do mount="${mount%/*}"; [[ -n "$mount" ]] || mount=/; done
    # shellcheck source=../../lib/resource_check.sh
    source "$AS_ROOT/scripts/lib/resource_check.sh"
    require_ram_mb 6144
    available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
    [[ "$available" =~ ^[0-9]+$ && "$available" -ge 4096 ]] || {
        echo 'AudioSeal: mindestens 4096 MiB aktuell verfuegbaren RAM freimachen; keine Swap-/WSL-Aenderung.' >&2; return 1;
    }
    REQUIRE_WINDOWS_HOST_FREE_MB=8192 require_disk_mb 8192 "$mount"
}

as_prepare_python() (
    # Reuse the narrowly scoped Debian/Ubuntu ensurepip repair, isolated from this helper.
    # shellcheck source=agent_framework_common.sh
    source "$AS_ROOT/scripts/tools/helpers/agent_framework_common.sh"
    AGENT_FRAMEWORK_AUTO_VENV="${AUDIOSEAL_AUTO_VENV:-1}" af_prepare_venv "$AS_PYTHON"
)

as_fetch() {
    if [[ -e "$AS_SOURCE" ]]; then
        as_source_ok || { echo 'AudioSeal-Quelle fremd/unvollstaendig/veraendert; manuell sichern, kein Reset.' >&2; return 1; }
    else
        git -c init.defaultBranch=main init "$AS_SOURCE"
        git -C "$AS_SOURCE" remote add origin "$AS_URL"
        GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$AS_SOURCE" fetch --depth 1 origin "$AS_COMMIT"
        git -c core.hooksPath=/dev/null -C "$AS_SOURCE" checkout --detach FETCH_HEAD
    fi
    as_source_ok || return 1
    [[ -f "$AS_SOURCE/pyproject.toml" && -f "$AS_SOURCE/src/audioseal/__init__.py" ]] || {
        echo 'AudioSeal-Paketlayout fehlt; kein Root-Fallback.' >&2; return 1;
    }
}

as_install_cpu() {
    rm -f -- "$AS_MARKER"
    "$AS_PYTHON" -I -B -m venv "$AS_VENV"
    printf '%s\n' 'torch==2.10.0+cpu' > "$AS_BASE/constraints.txt"
    "$AS_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir \
        --disable-pip-version-check --only-binary=:all: --index-url https://download.pytorch.org/whl/cpu 'torch==2.10.0+cpu'
    # Build the pinned GitHub checkout with Flit; PyPI only supplies dependencies/build tools.
    "$AS_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir \
        --disable-pip-version-check --index-url https://pypi.org/simple \
        -c "$AS_BASE/constraints.txt" "$AS_SOURCE"
    "$AS_VENV/bin/python" -I -B -m pip --isolated check
    as_metadata
    printf '%s\n' "$AS_COMMIT cpu" > "$AS_MARKER"
    echo 'AudioSeal aus GitHub in privater CPU-venv installiert. Kein Modell-/Audio-/Importtest, kein Dienst gestartet.'
}

as_deactivate() {
    rm -f -- "$AS_MARKER"
    echo 'AudioSeal-Setup-Marker deaktiviert; Quelle, venv, Modelle, Audios und Logs bleiben erhalten.'
}

audioseal_main() (
    set -euo pipefail
    umask 077
    local mode="${1:-install}" program log
    as_paths || return 1
    case "$mode" in
        --dry-run|--plan|plan|--help)
            echo "AudioSeal $AS_VERSION: GitHub $AS_URL; Commit $AS_COMMIT; private CPU-venv ohne Docker."
            echo 'Install/Repair laden PyTorch-CPU/Build-Abhaengigkeiten, keine Modelle/Audios. Reserve: 6 GiB gesamt, 4 GiB verfuegbar, 8 GiB Disk/Windows-C:.'
            echo 'Dry-Run ohne Download, Installation oder WSL-Aenderung.'; return 0 ;;
        status|--status)
            if as_probe >/dev/null 2>&1; then echo '{"installed":true,"scope":"github-cpu-package","models_checked":false,"authenticity_verdict":null}'
            else echo '{"installed":false,"scope":"github-cpu-package","models_checked":false,"authenticity_verdict":null}'; fi
            return 0 ;;
        doctor|check|--check)
            as_probe || { echo 'AudioSeal fehlt/deaktiviert oder Quelle/Pakete inkonsistent; --repair verwenden.' >&2; return 1; }
            echo 'Commit und Paketmetadaten konsistent. Kein AudioSeal-/torch-Import, Modell- oder Echtheitstest.'; return 0 ;;
        install|update|--repair|uninstall|--uninstall) ;;
        *) echo 'AudioSeal: nur Paketverwaltung; kein Wasserzeichen-/Audio-/Serverstart.' >&2; return 2 ;;
    esac
    [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || { echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2; return 1; }
    for program in git flock; do command -v "$program" >/dev/null || { echo "AudioSeal: $program fehlt; Basis separat einrichten." >&2; return 1; }; done
    if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
        command -v "$AS_PYTHON" >/dev/null || { echo 'AudioSeal: Python fehlt; Basis separat einrichten.' >&2; return 1; }
        as_preflight || return 1
        if [[ "$mode" == install ]] && as_probe >/dev/null 2>&1; then echo 'AudioSeal-CPU-Paket bereits konsistent; keine Installation.'; return 0; fi
        as_resources || return 1
    elif [[ ! -d "$AS_BASE" ]]; then echo 'Nicht eingerichtet; nichts deaktiviert.'; return 0; fi
    mkdir -p "$AS_BASE" "$AS_LOGS"
    exec 9>"$AS_BASE/operation.lock"
    flock -n 9 || { echo 'Andere AudioSeal-Operation aktiv.' >&2; return 1; }
    log="$(mktemp "$AS_LOGS/audioseal_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
    exec > >(tee -a "$log") 2>&1
    echo "AudioSeal-Installer: 2026-10-16-github-cpu-package; Aktion: $mode; Pin: $AS_COMMIT"
    trap 'rc=$?; if ((rc != 0)); then echo "AudioSeal-Fehler ($rc); Dateien erhalten. Log: $log. Nach Behebung --repair verwenden."; fi' EXIT
    if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then as_deactivate; return 0; fi
    as_prepare_python
    as_fetch
    df -Pk "$AS_BASE"
    as_install_cpu
    df -Pk "$AS_BASE"
)
