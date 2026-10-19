#!/usr/bin/env bash
# Hardware access is intentionally absent; installs the Python foundation only.
HIL_URL=https://github.com/cs01/pygdbmi.git
HIL_COMMIT=52a17f1d8651e941b8551a44a03d181d605e1e56

hil_paths() {
    local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
    [[ "$root" == /* && "$root" != / ]] || return 1
    case "$root/" in "$HIL_REPO_ROOT/"*) echo 'HIL-Daten nicht im Setup-Repo ablegen.' >&2; return 1 ;; esac
    HIL_BASE="$root/tools/embedded_debug_hil"
    HIL_SOURCE="$HIL_BASE/source"
    HIL_VENV="$HIL_BASE/venv"
    HIL_MARKER="$HIL_BASE/source-built"
    HIL_LOGS="$root/install_logs"
    HIL_PYTHON="${EMBEDDED_DEBUG_HIL_PYTHON_BIN:-python3}"
    for path in "$root" "$HIL_BASE" "$HIL_SOURCE" "$HIL_SOURCE/.git" "$HIL_VENV" "$HIL_VENV/bin" "$HIL_VENV/pyvenv.cfg" "$HIL_MARKER" "$HIL_LOGS" "$HIL_BASE/operation.lock"; do
        [[ ! -L "$path" && "$(realpath -m -- "$path")" == "$path" ]] || {
            echo 'HIL: Symlink/nicht normalisierter Pfad; Abbruch.' >&2; return 1;
        }
    done
}

hil_source_ok() {
    [[ -d "$HIL_SOURCE/.git" ]] &&
        [[ "$(git -C "$HIL_SOURCE" rev-parse --show-toplevel)" == "$HIL_SOURCE" ]] &&
        [[ "$(git -C "$HIL_SOURCE" remote get-url origin)" == "$HIL_URL" ]] &&
        [[ "$(git -C "$HIL_SOURCE" rev-parse HEAD)" == "$HIL_COMMIT" ]] &&
        [[ -z "$(git -C "$HIL_SOURCE" status --porcelain --untracked-files=all)" ]]
}

hil_metadata() {
    "$HIL_VENV/bin/python" -I -B - "$HIL_SOURCE" "$HIL_VENV" <<'PY'
from importlib.metadata import distribution
import json
from pathlib import Path
import sys
from urllib.parse import unquote, urlparse
assert sys.prefix != sys.base_prefix
assert Path(sys.prefix).resolve() == Path(sys.argv[2]).resolve()
d = distribution('pygdbmi')
assert d.version == '0.11.0.0'
origin = urlparse(json.loads(d.read_text('direct_url.json'))['url'])
assert origin.scheme == 'file' and not origin.netloc
assert Path(unquote(origin.path)).resolve() == Path(sys.argv[1]).resolve()
print('pygdbmi-Metadaten/Quellpfad geprueft; kein Import oder GDB-Prozess.')
PY
}

hil_probe() {
    [[ -f "$HIL_MARKER" && "$(<"$HIL_MARKER")" == "$HIL_COMMIT base" && -x "$HIL_VENV/bin/python" ]] &&
        hil_source_ok && hil_metadata
}

hil_resources() {
    local mount="$HIL_BASE"
    while [[ ! -d "$mount" ]]; do mount="${mount%/*}"; [[ -n "$mount" ]] || mount=/; done
    source "$HIL_REPO_ROOT/scripts/lib/resource_check.sh"
    require_ram_mb 512 || return 1
    REQUIRE_WINDOWS_HOST_FREE_MB=1024 require_disk_mb 512 "$mount"
}

hil_preflight() {
    "$HIL_PYTHON" -I -B -c 'import sys, ssl; assert (3,10) <= sys.version_info < (3,13)' || {
        echo 'Python 3.10-3.12 mit SSL erforderlich; EMBEDDED_DEBUG_HIL_PYTHON_BIN setzen.' >&2; return 1;
    }
    if [[ -e "$HIL_VENV" ]]; then
        [[ -f "$HIL_VENV/pyvenv.cfg" ]] || { echo 'Fremde venv bleibt erhalten.' >&2; return 1; }
        "$HIL_PYTHON" -I -B - "$HIL_VENV/pyvenv.cfg" <<'PY' || return 1
from pathlib import Path
import sys
assert 'include-system-site-packages = false' in Path(sys.argv[1]).read_text()
PY
    fi
}

hil_python_venv_ok() {
    "$HIL_PYTHON" -I -B -c 'import venv, ensurepip' >/dev/null 2>&1
}

hil_venv_package() {
    "$HIL_PYTHON" -I -B - <<'PY'
from pathlib import Path
import sys
expected = Path('/usr/bin/python%d.%d' % sys.version_info[:2])
assert sys.prefix == sys.base_prefix, 'Keine Paket-Reparatur innerhalb einer venv'
assert Path(sys.executable).resolve() == expected.resolve(), 'Kein Ubuntu-Systeminterpreter'
assert (3, 10) <= sys.version_info < (3, 13)
print('python%d.%d-venv' % sys.version_info[:2])
PY
}

hil_install_venv_package() {
    # shellcheck source=../../lib/apt_lock_wait.sh
    source "$HIL_REPO_ROOT/scripts/lib/apt_lock_wait.sh"
    run_apt_with_lock_wait update || return 1
    run_apt_with_lock_wait install -y --no-install-recommends "$1"
}

hil_prepare_python() {
    local package answer='' policy="${EMBEDDED_DEBUG_HIL_INSTALL_VENV_DEPS:-ask}"
    "$HIL_PYTHON" -I -B -c 'import sys, ssl; assert (3,10) <= sys.version_info < (3,13)' || {
        echo 'HIL: Python 3.10-3.12 mit SSL erforderlich; EMBEDDED_DEBUG_HIL_PYTHON_BIN pruefen.' >&2; return 1;
    }
    hil_python_venv_ok && return 0
    echo 'HIL: Dem gewaehlten Python fehlt venv/ensurepip.'
    package="$(hil_venv_package)" || {
        echo 'Privates/fremdes Python: dessen venv/ensurepip separat reparieren oder EMBEDDED_DEBUG_HIL_PYTHON_BIN passend setzen; kein System-Python ersetzt.' >&2; return 1;
    }
    command -v apt-get >/dev/null && command -v sudo >/dev/null || {
        echo "Keine apt/sudo-Reparatur verfuegbar. $package separat einrichten." >&2; return 1;
    }
    echo "Notwendiges Systempaket: $package. pygdbmi selbst bleibt aus GitHub, ohne Docker."
    case "$policy" in
        1) ;;
        ask)
            if [[ -t 0 ]]; then
                read -r -p "$package mit sudo installieren? [(j)a/(N)ein]: " answer || answer=''
            fi
            [[ "$answer" == j || "$answer" == J ]] || {
                echo 'Nicht installiert. Nach Zustimmung EMBEDDED_DEBUG_HIL_INSTALL_VENV_DEPS=1 mit --repair verwenden.' >&2; return 1;
            } ;;
        0) echo 'Installation von venv-Systempaketen deaktiviert.' >&2; return 1 ;;
        *) echo 'EMBEDDED_DEBUG_HIL_INSTALL_VENV_DEPS: nur ask, 0 oder 1 erlaubt.' >&2; return 2 ;;
    esac
    hil_install_venv_package "$package" || { echo "Installation von $package fehlgeschlagen; kein Clone/Build." >&2; return 1; }
    hil_python_venv_ok || { echo "venv/ensurepip fehlt weiterhin fuer $HIL_PYTHON; kein Clone/Build." >&2; return 1; }
    echo 'venv/ensurepip verfuegbar; kein System-Python ersetzt.'
}

hil_fetch() {
    if [[ -e "$HIL_SOURCE" ]]; then
        hil_source_ok || { echo 'HIL-Quelle fremd/unvollstaendig/veraendert; kein Reset oder Loeschen.' >&2; return 1; }
    else
        git -c init.defaultBranch=main init "$HIL_SOURCE" || return $?
        git -C "$HIL_SOURCE" remote add origin "$HIL_URL" || return $?
        GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$HIL_SOURCE" fetch --depth 1 origin "$HIL_COMMIT" || return $?
        GIT_LFS_SKIP_SMUDGE=1 git -c core.hooksPath=/dev/null -C "$HIL_SOURCE" checkout --detach FETCH_HEAD || return $?
    fi
    hil_source_ok || return 1
    [[ -f "$HIL_SOURCE/setup.py" && -f "$HIL_SOURCE/pygdbmi/gdbmiparser.py" && -f "$HIL_SOURCE/LICENSE" ]]
}

hil_install_package() {
    rm -f -- "$HIL_MARKER" || return 1
    "$HIL_PYTHON" -I -B -m venv "$HIL_VENV" || return $?
    "$HIL_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir --use-pep517 \
        --disable-pip-version-check --index-url https://pypi.org/simple --no-deps "$HIL_SOURCE" || return $?
    hil_metadata && hil_source_ok || return 1
    printf '%s\n' "$HIL_COMMIT base" > "$HIL_MARKER"
}

hil_deactivate() {
    rm -f -- "$HIL_MARKER" || return 1
    source "$HIL_REPO_ROOT/scripts/helpers/native_tool_status.sh"
    native_tool_sync_status Embedded_Debug_HIL "${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" || return 1
    echo 'HIL-Basisregistrierung deaktiviert; Quellen, venv, Snapshots und Logs bleiben erhalten.'
}

hil_main() (
    set -euo pipefail
    umask 077
    local mode="${1:---dry-run}" program log
    hil_paths || return 1
    case "$mode" in
        --dry-run|--plan|plan|--help)
            echo "HIL-Basis: pygdbmi 0.11.0.0 aus $HIL_URL; Pin $HIL_COMMIT; ohne Docker."
            echo 'Nur private Python-Bibliothek; kein GDB/OpenOCD/USB/MCP/Port/Reset/Flash. Live-Adapter planned.'
            echo 'Reserve: 512 MiB RAM/Disk, WSL-Host 1024 MiB. Kein Download im Dry-Run.'; return 0 ;;
        status|--status)
            if hil_probe >/dev/null 2>&1; then echo '{"installed":true,"scope":"pygdbmi-base","hardware_ready":false}'
            else echo '{"installed":false,"scope":"pygdbmi-base","hardware_ready":false}'; fi
            return 0 ;;
        check|--check|doctor)
            hil_probe || return 1
            echo 'Basis konsistent; kein Hardware-Stack getestet oder gestartet.'; return 0 ;;
        install|update|--repair|repair|uninstall|--uninstall) ;;
        *) echo 'Nur Basis-Paketverwaltung; Hardware-/Serveraktionen nicht implementiert.' >&2; return 2 ;;
    esac
    [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || { echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2; return 1; }
    if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
        [[ -d "$HIL_BASE" ]] || { hil_deactivate; return $?; }
    else
        for program in git "$HIL_PYTHON" flock; do
            command -v "$program" >/dev/null || { echo "HIL: $program fehlt; Basiswerkzeug separat einrichten." >&2; return 1; }
        done
        hil_preflight && hil_resources || return 1
    fi
    command -v flock >/dev/null || return 1
    mkdir -p "$HIL_BASE" "$HIL_LOGS" || return 1
    exec 9>"$HIL_BASE/operation.lock"
    flock -n 9 || { echo 'Andere HIL-Operation aktiv.' >&2; return 1; }
    log="$(mktemp "$HIL_LOGS/embedded_debug_hil_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")" || return 1
    exec > >(tee -a "$log") 2>&1
    echo "HIL-Installer: 2026-10-19-venv-dependency-repair; Aktion $mode; Pin $HIL_COMMIT"
    if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then hil_deactivate; return $?; fi
    if [[ "$mode" == install ]] && hil_probe >/dev/null 2>&1; then echo 'Basis bereits konsistent; kein Neubau.'; return 0; fi
    hil_prepare_python || { echo "HIL-Python-Vorbereitung fehlgeschlagen; kein Clone/Build. Log: $log" >&2; return 1; }
    df -Pk "$HIL_BASE"
    hil_fetch || return $?
    hil_install_package || { echo "HIL-Installation fehlgeschlagen; Dateien erhalten. Nach Pruefung --repair. Log: $log" >&2; return 1; }
    source "$HIL_REPO_ROOT/scripts/helpers/native_tool_status.sh"
    native_tool_sync_status Embedded_Debug_HIL "${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" || return 1
    df -Pk "$HIL_BASE"
    echo 'GitHub-Basisbibliothek eingerichtet; keine GDB-/Hardwareverbindung. Offline-Berichte weiter direkt im Setup-Repo nutzbar.'
)
