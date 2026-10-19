#!/usr/bin/env bash
set -euo pipefail
MO_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
MO_URL=https://github.com/kyutai-labs/moshi.git
MO_COMMIT=e6a55d2722a65870ef52a6c9f6ecfc0e90f38362
MO_VERSION=0.2.13

mo_paths() {
    local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
    [[ "$root" == /* && "$root" != / ]] || return 1
    case "$root/" in "$MO_ROOT/"*) echo 'Moshi-Daten nicht im Setup-Repo ablegen.' >&2; return 1 ;; esac
    MO_BASE="$root/tools/moshi"
    MO_SOURCE="$MO_BASE/source"
    MO_PACKAGE="$MO_SOURCE/moshi"
    MO_VENV="$MO_BASE/venv"
    MO_MARKER="$MO_BASE/source-built"
    MO_LOGS="$root/install_logs"
    MO_PYTHON="${MOSHI_PYTHON_BIN:-python3}"
    # Allow the normal venv Python symlink, not redirecting directories.
    local index=0
    local -a paths=("$root" "$MO_BASE" "$MO_SOURCE" "$MO_SOURCE/.git" "$MO_PACKAGE" "$MO_VENV" "$MO_VENV/bin" "$MO_VENV/pyvenv.cfg" "$MO_MARKER" "$MO_LOGS" "$MO_BASE/operation.lock") resolved=()
    mapfile -t resolved < <(realpath -m -- "${paths[@]}")
    [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
    for path in "${paths[@]}"; do
        [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
            echo 'Moshi: Symlink/nicht normalisierter Pfad; Abbruch.' >&2; return 1;
        }
        index=$((index + 1))
    done
}

mo_source_ok() {
    [[ -d "$MO_SOURCE/.git" ]] &&
        [[ "$(git -C "$MO_SOURCE" rev-parse --show-toplevel)" == "$MO_SOURCE" ]] &&
        [[ "$(git -C "$MO_SOURCE" remote get-url origin)" == "$MO_URL" ]] &&
        [[ "$(git -C "$MO_SOURCE" rev-parse HEAD)" == "$MO_COMMIT" ]] &&
        [[ -z "$(git -C "$MO_SOURCE" status --porcelain --untracked-files=all)" ]]
}

mo_metadata() {
    "$MO_VENV/bin/python" -I -B - "$MO_PACKAGE" "$MO_VENV" <<'PY'
from importlib.metadata import distribution
import json
from pathlib import Path
import sys
from urllib.parse import unquote, urlparse
assert sys.prefix != sys.base_prefix
assert Path(sys.prefix).resolve() == Path(sys.argv[2]).resolve()
d = distribution("moshi")
assert d.version == "0.2.13"
origin = urlparse(json.loads(d.read_text("direct_url.json"))["url"])
assert origin.scheme == "file" and origin.netloc == ""
assert Path(unquote(origin.path)).resolve() == Path(sys.argv[1]).resolve()
print('moshi 0.2.13: Metadaten/Quellpfad geprueft, kein SDK-Import.')
PY
}

mo_probe() {
    [[ -f "$MO_MARKER" && "$(<"$MO_MARKER")" == "$MO_COMMIT base" && -x "$MO_VENV/bin/python" ]] || return 1
    mo_source_ok && mo_metadata
}

mo_preflight() {
    case "$(uname -m)" in x86_64|aarch64) ;; *) echo 'Moshi: automatischer Wheel-Pfad nur Linux x86_64/ARM64.' >&2; return 1 ;; esac
    "$MO_PYTHON" -I -B -c 'import sys; assert (3,10) <= sys.version_info < (3,13)' || {
        echo 'Moshi: vorhandenes Python 3.10-3.12 verwenden; Ubuntu-Python 3.12 passt.' >&2; return 1;
    }
    [[ ! -e "$MO_VENV" || -f "$MO_VENV/pyvenv.cfg" ]] || {
        echo 'Fremdes venv-Verzeichnis; nichts ueberschrieben.' >&2; return 1;
    }
    if [[ -e "$MO_VENV" ]]; then
        "$MO_PYTHON" -I -B - "$MO_VENV/pyvenv.cfg" <<'PY' || return 1
from pathlib import Path
import sys
assert 'include-system-site-packages = false' in Path(sys.argv[1]).read_text()
PY
    fi
}

mo_resources() {
    local mount="$MO_BASE" available
    while [[ ! -d "$mount" ]]; do mount="${mount%/*}"; [[ -n "$mount" ]] || mount=/; done
    # shellcheck source=../../lib/resource_check.sh
    source "$MO_ROOT/scripts/lib/resource_check.sh"
    require_ram_mb 1024 || return 1
    available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
    [[ "$available" =~ ^[0-9]+$ && "$available" -ge 512 ]] || {
        echo 'Moshi: mindestens 512 MiB aktuell verfuegbaren RAM freimachen; kein Swap-/WSL-Umbau.' >&2; return 1;
    }
    REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 2048 "$mount"
}

mo_python_core_ok() {
    "$MO_PYTHON" -I -B -c 'import sys, ssl; assert (3,10) <= sys.version_info < (3,13)'
}

mo_python_venv_ok() {
    "$MO_PYTHON" -I -B -c 'import venv, ensurepip' >/dev/null 2>&1
}

mo_venv_package() {
    "$MO_PYTHON" -I -B - <<'PY'
from pathlib import Path
import sys
expected = Path('/usr/bin/python%d.%d' % sys.version_info[:2])
assert sys.prefix == sys.base_prefix, 'Keine Paket-Reparatur innerhalb einer venv'
assert Path(sys.executable).resolve() == expected.resolve(), 'Kein Ubuntu-Systeminterpreter'
assert (3, 10) <= sys.version_info < (3, 13)
print('python%d.%d-venv' % sys.version_info[:2])
PY
}

mo_install_venv_package() {
    # shellcheck source=../../lib/apt_lock_wait.sh
    source "$MO_ROOT/scripts/lib/apt_lock_wait.sh"
    run_apt_with_lock_wait update || return 1
    run_apt_with_lock_wait install -y --no-install-recommends "$1"
}

mo_prepare_python() {
    local package answer='' policy="${MOSHI_INSTALL_VENV_DEPS:-ask}"
    mo_python_core_ok || { echo 'Moshi: Python 3.10-3.12 mit SSL erforderlich; MOSHI_PYTHON_BIN pruefen.' >&2; return 1; }
    mo_python_venv_ok && return 0
    echo 'Moshi: Dem gewaehlten Python fehlt venv/ensurepip.'
    package="$(mo_venv_package)" || {
        echo 'Privates/fremdes Python: dessen venv/ensurepip separat reparieren oder MOSHI_PYTHON_BIN passend setzen; kein System-Python ersetzt.' >&2; return 1;
    }
    command -v apt-get >/dev/null && command -v sudo >/dev/null || {
        echo "Keine apt/sudo-Reparatur verfuegbar. $package separat einrichten." >&2; return 1;
    }
    echo "Notwendiges Systempaket: $package. Moshi selbst bleibt aus GitHub, ohne Docker."
    case "$policy" in
        1) ;;
        ask)
            if [[ -t 0 ]]; then
                read -r -p "$package mit sudo installieren? [(j)a/(N)ein]: " answer || answer=''
            fi
            [[ "$answer" == j || "$answer" == J ]] || {
                echo 'Nicht installiert. Nach Zustimmung MOSHI_INSTALL_VENV_DEPS=1 mit --repair verwenden.' >&2; return 1;
            } ;;
        0) echo 'Installation von venv-Systempaketen deaktiviert.' >&2; return 1 ;;
        *) echo 'MOSHI_INSTALL_VENV_DEPS: nur ask, 0 oder 1 erlaubt.' >&2; return 2 ;;
    esac
    mo_install_venv_package "$package" || { echo "Installation von $package fehlgeschlagen; kein Clone/Build." >&2; return 1; }
    mo_python_venv_ok || { echo "venv/ensurepip fehlt weiterhin fuer $MO_PYTHON; kein Clone/Build." >&2; return 1; }
    echo 'venv/ensurepip verfuegbar; kein System-Python ersetzt.'
}

mo_fetch() {
    if [[ -e "$MO_SOURCE" ]]; then
        mo_source_ok || { echo 'Moshi-Quelle fremd/unvollstaendig/veraendert; manuell sichern, kein Reset.' >&2; return 1; }
    else
        git -c init.defaultBranch=main init "$MO_SOURCE"
        git -C "$MO_SOURCE" remote add origin "$MO_URL"
        GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$MO_SOURCE" fetch --depth 1 origin "$MO_COMMIT"
        GIT_LFS_SKIP_SMUDGE=1 git -c core.hooksPath=/dev/null -C "$MO_SOURCE" checkout --detach FETCH_HEAD
    fi
    mo_source_ok || return 1
    [[ -f "$MO_PACKAGE/pyproject.toml" && -f "$MO_PACKAGE/moshi/__init__.py" && -f "$MO_SOURCE/LICENSE-MIT" ]] || {
        echo 'Erwartetes Moshi-Paketlayout fehlt; kein anderer Installationspfad.' >&2; return 1;
    }
}

mo_install_package() {
    rm -f -- "$MO_MARKER"
    "$MO_PYTHON" -I -B -m venv "$MO_VENV"
    # Only the pinned local package is built. GPU runtime is not resolved here.
    "$MO_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir \
        --use-pep517 --disable-pip-version-check --index-url https://pypi.org/simple \
        --no-deps "$MO_PACKAGE"
    mo_metadata
    mo_source_ok || return 1
    printf '%s\n' "$MO_COMMIT base" > "$MO_MARKER"
    echo 'Moshi aus GitHub in privater venv installiert. Nur Basispaket ohne Runtime-Abhaengigkeiten. Keine Checkpoints/Referenzaudios, CLI/WebUI oder Inferenz gestartet.'
}

mo_deactivate() {
    rm -f -- "$MO_MARKER"
    echo 'Moshi-Setup-Marker deaktiviert; Quelle, venv, eigene Daten, Cache, Token und Logs bleiben erhalten.'
}

moshi_main() (
    set -euo pipefail
    umask 077
    unset HF_TOKEN HUGGING_FACE_HUB_TOKEN
    export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 HF_HUB_DISABLE_TELEMETRY=1
    local mode="${1:-install}" program log
    mo_paths || return 1
    case "$mode" in
        --dry-run|--plan|plan|--help)
            echo "Moshi $MO_VERSION: GitHub $MO_URL; Commit $MO_COMMIT; private Basis-venv ohne Docker."
            echo 'Reserve: 1 GiB gesamt, 512 MiB verfuegbar, 2 GiB Disk/Windows-C:. Nur Paket --no-deps, keine betriebsbereite Audio-Laufzeit.'
            echo 'Dry-Run ohne Download, Installation, API-/Token-/Uploadzugriff.'; return 0 ;;
        status|--status)
            if mo_probe >/dev/null 2>&1; then echo '{"installed":true,"scope":"github-base-package","runtime_dependencies":false,"models_checked":false,"inference_tested":false}'
            else echo '{"installed":false,"scope":"github-base-package","runtime_dependencies":false,"models_checked":false,"inference_tested":false}'; fi
            return 0 ;;
        doctor|check|--check)
            mo_probe || { echo 'Moshi fehlt/deaktiviert oder Quelle/Pakete inkonsistent; --repair verwenden.' >&2; return 1; }
            echo 'Pin/Paketmetadaten konsistent, Runtime-Abhaengigkeiten fehlen absichtlich. Kein Moshi-/Torch-Import, CLI/WebUI oder Modelltest.'; return 0 ;;
        install|update|--repair|uninstall|--uninstall) ;;
        *) echo 'Moshi: nur Paketverwaltung, kein Modell-/Demo-/Trainingstart.' >&2; return 2 ;;
    esac
    if [[ "$mode" != uninstall && "$mode" != --uninstall && "${MOSHI_INSTALL_RUNTIME:-0}" != 0 ]]; then
        echo 'Automatische GPU-Runtime nicht freigegeben: Moshi braucht passende Torch-/bitsandbytes-/Audio-Pakete; GPU und PortAudio separat testen. Siehe docs/tools/moshi.md.' >&2; return 2;
    fi
    [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || { echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2; return 1; }
    for program in git flock; do command -v "$program" >/dev/null || { echo "Moshi: $program fehlt; Basis separat einrichten." >&2; return 1; }; done
    if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
        command -v "$MO_PYTHON" >/dev/null || { echo 'Moshi: Python fehlt; Basis separat einrichten.' >&2; return 1; }
        mo_preflight || return 1
        if [[ "$mode" == install ]] && mo_probe >/dev/null 2>&1; then echo 'Moshi-Basispaket bereits konsistent; keine Installation.'; return 0; fi
        mo_resources || return 1
    elif [[ ! -d "$MO_BASE" ]]; then echo 'Nicht eingerichtet; nichts deaktiviert.'; return 0; fi
    mkdir -p "$MO_BASE" "$MO_LOGS"
    exec 9>"$MO_BASE/operation.lock"
    flock -n 9 || { echo 'Andere Moshi-Operation aktiv.' >&2; return 1; }
    log="$(mktemp "$MO_LOGS/moshi_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
    exec > >(tee -a "$log") 2>&1
    echo "Moshi-Installer: 2026-10-19-venv-dependency-repair; Aktion: $mode; Pin: $MO_COMMIT"
    trap 'rc=$?; if ((rc != 0)); then echo "Moshi-Fehler ($rc); Dateien erhalten. Log: $log. Nach Behebung --repair verwenden."; fi' EXIT
    if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then mo_deactivate; return 0; fi
    mo_prepare_python || return 1
    mo_fetch
    df -Pk "$MO_BASE"
    mo_install_package
    df -Pk "$MO_BASE"
)
