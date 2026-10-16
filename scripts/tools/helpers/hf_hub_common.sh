#!/usr/bin/env bash
set -euo pipefail
HFH_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
HFH_URL=https://github.com/huggingface/huggingface_hub.git
HFH_COMMIT=acfdf30d99441317270cca6e9362dd7f9ff47c55
HFH_VERSION=2.2.0

hfh_paths() {
    local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
    [[ "$root" == /* && "$root" != / ]] || return 1
    case "$root/" in "$HFH_ROOT/"*) echo 'HF-Hub-Daten nicht im Setup-Repo ablegen.' >&2; return 1 ;; esac
    HFH_BASE="$root/tools/hf_hub"
    HFH_SOURCE="$HFH_BASE/source"
    HFH_VENV="$HFH_BASE/venv"
    HFH_MARKER="$HFH_BASE/source-built"
    HFH_LOGS="$root/install_logs"
    HFH_PYTHON="${HF_HUB_PYTHON_BIN:-python3}"
    # Standard venv Python symlinks are allowed, not redirecting directories.
    for path in "$root" "$HFH_BASE" "$HFH_SOURCE" "$HFH_SOURCE/.git" "$HFH_VENV" "$HFH_VENV/bin" "$HFH_VENV/bin/hf" "$HFH_MARKER" "$HFH_LOGS" "$HFH_BASE/operation.lock"; do
        [[ ! -L "$path" && "$(realpath -m -- "$path")" == "$path" ]] || {
            echo 'HF Hub: Symlink/nicht normalisierter Pfad; Abbruch.' >&2; return 1;
        }
    done
}

hfh_source_ok() {
    [[ -d "$HFH_SOURCE/.git" ]] &&
        [[ "$(git -C "$HFH_SOURCE" rev-parse --show-toplevel)" == "$HFH_SOURCE" ]] &&
        [[ "$(git -C "$HFH_SOURCE" remote get-url origin)" == "$HFH_URL" ]] &&
        [[ "$(git -C "$HFH_SOURCE" rev-parse HEAD)" == "$HFH_COMMIT" ]] &&
        [[ -z "$(git -C "$HFH_SOURCE" status --porcelain --untracked-files=all)" ]]
}

hfh_metadata() {
    [[ -x "$HFH_VENV/bin/hf" ]] || return 1
    "$HFH_VENV/bin/python" -I -B -c \
        'from importlib.metadata import distribution; d = distribution("huggingface-hub"); assert d.version == "2.2.0"; assert any(e.group == "console_scripts" and e.name == "hf" and e.value == "huggingface_hub.cli.hf:main" for e in d.entry_points)'
}

hfh_probe() {
    [[ -f "$HFH_MARKER" && "$(<"$HFH_MARKER")" == "$HFH_COMMIT base" && -x "$HFH_VENV/bin/python" ]] || return 1
    hfh_source_ok && hfh_metadata && "$HFH_VENV/bin/python" -I -B -m pip --isolated check
}

hfh_preflight() {
    case "$(uname -m)" in x86_64|aarch64) ;; *) echo 'HF Hub: automatischer Wheel-Pfad nur Linux x86_64/ARM64.' >&2; return 1 ;; esac
    "$HFH_PYTHON" -I -B -c 'import sys; assert (3,10) <= sys.version_info < (3,14)' || {
        echo 'HF Hub: vorhandenes Python 3.10-3.13 verwenden; Ubuntu-Python 3.12 passt.' >&2; return 1;
    }
    [[ ! -e "$HFH_VENV" || -f "$HFH_VENV/pyvenv.cfg" ]] || {
        echo 'Fremdes venv-Verzeichnis; nichts ueberschrieben.' >&2; return 1;
    }
}

hfh_resources() {
    local mount="$HFH_BASE" available
    while [[ ! -d "$mount" ]]; do mount="${mount%/*}"; [[ -n "$mount" ]] || mount=/; done
    # shellcheck source=../../lib/resource_check.sh
    source "$HFH_ROOT/scripts/lib/resource_check.sh"
    require_ram_mb 1024
    available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
    [[ "$available" =~ ^[0-9]+$ && "$available" -ge 512 ]] || {
        echo 'HF Hub: mindestens 512 MiB aktuell verfuegbaren RAM freimachen; kein Swap-/WSL-Umbau.' >&2; return 1;
    }
    REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 2048 "$mount"
}

hfh_prepare_python() (
    # Reuse existing narrowly scoped Ubuntu/Debian ensurepip repair in isolation.
    # shellcheck source=agent_framework_common.sh
    source "$HFH_ROOT/scripts/tools/helpers/agent_framework_common.sh"
    AGENT_FRAMEWORK_AUTO_VENV="${HF_HUB_AUTO_VENV:-1}" af_prepare_venv "$HFH_PYTHON"
)

hfh_fetch() {
    if [[ -e "$HFH_SOURCE" ]]; then
        hfh_source_ok || { echo 'HF-Hub-Quelle fremd/unvollstaendig/veraendert; manuell sichern, kein Reset.' >&2; return 1; }
    else
        git -c init.defaultBranch=main init "$HFH_SOURCE"
        git -C "$HFH_SOURCE" remote add origin "$HFH_URL"
        GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$HFH_SOURCE" fetch --depth 1 origin "$HFH_COMMIT"
        git -c core.hooksPath=/dev/null -C "$HFH_SOURCE" checkout --detach FETCH_HEAD
    fi
    hfh_source_ok || return 1
    [[ -f "$HFH_SOURCE/setup.py" && -f "$HFH_SOURCE/src/huggingface_hub/__init__.py" ]] || {
        echo 'Erwartetes HF-Hub-Paketlayout fehlt; kein anderer Installationspfad.' >&2; return 1;
    }
}

hfh_install_package() {
    rm -f -- "$HFH_MARKER"
    "$HFH_PYTHON" -I -B -m venv "$HFH_VENV"
    # GitHub supplies the Hub client; PyPI supplies dependencies. No Rust build for hf-xet.
    "$HFH_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir \
        --disable-pip-version-check --index-url https://pypi.org/simple \
        --only-binary=hf-xet "$HFH_SOURCE"
    "$HFH_VENV/bin/python" -I -B -m pip --isolated check
    hfh_metadata
    hfh_source_ok || return 1
    printf '%s\n' "$HFH_COMMIT base" > "$HFH_MARKER"
    echo "CLI (nur manuell nutzen): $HFH_VENV/bin/hf"
    echo 'HF Hub aus GitHub in privater venv installiert. Keine Datensaetze, Modelle, Decoder oder Trainingsjobs gestartet.'
}

hfh_deactivate() {
    rm -f -- "$HFH_MARKER"
    echo 'HF-Hub-Setup-Marker deaktiviert; Quelle, venv, Datensaetze, Cache, Token und Logs bleiben erhalten.'
}

hf_hub_main() (
    set -euo pipefail
    umask 077
    local mode="${1:-install}" program log
    hfh_paths || return 1
    case "$mode" in
        --dry-run|--plan|plan|--help)
            echo "HF Hub $HFH_VERSION: GitHub $HFH_URL; Commit $HFH_COMMIT; private Basis-venv ohne Docker."
            echo 'Reserve: 1 GiB gesamt, 512 MiB verfuegbar, 2 GiB Disk/Windows-C:. Keine Decoder-/Training-Extras.'
            echo 'Dry-Run ohne Download, Installation, Datensatz-/Token-/Trainingszugriff.'; return 0 ;;
        status|--status)
            if hfh_probe >/dev/null 2>&1; then echo '{"installed":true,"scope":"github-base-package","datasets_checked":false,"training_enabled":false}'
            else echo '{"installed":false,"scope":"github-base-package","datasets_checked":false,"training_enabled":false}'; fi
            return 0 ;;
        doctor|check|--check)
            hfh_probe || { echo 'HF Hub fehlt/deaktiviert oder Quelle/Pakete inkonsistent; --repair verwenden.' >&2; return 1; }
            echo 'Commit und Paketmetadaten konsistent. Kein Hub-Import, CLI-Start, Login, Datei-/Tokenzugriff oder Trainingstest.'; return 0 ;;
        install|update|--repair|uninstall|--uninstall) ;;
        *) echo 'HF Hub: nur Paketverwaltung, kein Download-/Login-/Trainingstart.' >&2; return 2 ;;
    esac
    [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || { echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2; return 1; }
    for program in git flock; do command -v "$program" >/dev/null || { echo "HF Hub: $program fehlt; Basis separat einrichten." >&2; return 1; }; done
    if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
        command -v "$HFH_PYTHON" >/dev/null || { echo 'HF Hub: Python fehlt; Basis separat einrichten.' >&2; return 1; }
        hfh_preflight || return 1
        if [[ "$mode" == install ]] && hfh_probe >/dev/null 2>&1; then echo 'HF-Hub-Basispaket bereits konsistent; keine Installation.'; return 0; fi
        hfh_resources || return 1
    elif [[ ! -d "$HFH_BASE" ]]; then echo 'Nicht eingerichtet; nichts deaktiviert.'; return 0; fi
    mkdir -p "$HFH_BASE" "$HFH_LOGS"
    exec 9>"$HFH_BASE/operation.lock"
    flock -n 9 || { echo 'Andere HF-Hub-Operation aktiv.' >&2; return 1; }
    log="$(mktemp "$HFH_LOGS/hf_hub_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
    exec > >(tee -a "$log") 2>&1
    echo "HF-Hub-Installer: 2026-10-16-github-base-package; Aktion: $mode; Pin: $HFH_COMMIT"
    trap 'rc=$?; if ((rc != 0)); then echo "HF-Hub-Fehler ($rc); Dateien erhalten. Log: $log. Nach Behebung --repair verwenden."; fi' EXIT
    if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then hfh_deactivate; return 0; fi
    hfh_prepare_python
    hfh_fetch
    df -Pk "$HFH_BASE"
    hfh_install_package
    df -Pk "$HFH_BASE"
)
