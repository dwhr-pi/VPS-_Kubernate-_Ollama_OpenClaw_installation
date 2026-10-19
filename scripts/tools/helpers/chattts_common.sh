#!/usr/bin/env bash
set -euo pipefail
CT_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
CT_URL=https://github.com/2noise/ChatTTS.git
CT_COMMIT=77b89ee281cd479f5b1a787ada330dc975ca1f2a
CT_VERSION=0.0.0

ct_paths() {
    local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
    [[ "$root" == /* && "$root" != / ]] || return 1
    case "$root/" in "$CT_ROOT/"*) echo 'ChatTTS-Daten nicht im Setup-Repo ablegen.' >&2; return 1 ;; esac
    CT_BASE="$root/tools/chattts"
    CT_SOURCE="$CT_BASE/source"
    CT_VENV="$CT_BASE/venv"
    CT_MARKER="$CT_BASE/source-built"
    CT_LOGS="$root/install_logs"
    CT_PYTHON="${CHATTTS_PYTHON_BIN:-python3}"
    # Allow the normal venv Python symlink, not redirecting directories.
    local index=0
    local -a paths=("$root" "$CT_BASE" "$CT_SOURCE" "$CT_SOURCE/.git" "$CT_VENV" "$CT_VENV/bin" "$CT_VENV/pyvenv.cfg" "$CT_MARKER" "$CT_LOGS" "$CT_BASE/operation.lock") resolved=()
    mapfile -t resolved < <(realpath -m -- "${paths[@]}")
    [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
    for path in "${paths[@]}"; do
        [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
            echo 'ChatTTS: Symlink/nicht normalisierter Pfad; Abbruch.' >&2; return 1;
        }
        index=$((index + 1))
    done
}

ct_source_ok() {
    [[ -d "$CT_SOURCE/.git" ]] &&
        [[ "$(git -C "$CT_SOURCE" rev-parse --show-toplevel)" == "$CT_SOURCE" ]] &&
        [[ "$(git -C "$CT_SOURCE" remote get-url origin)" == "$CT_URL" ]] &&
        [[ "$(git -C "$CT_SOURCE" rev-parse HEAD)" == "$CT_COMMIT" ]] &&
        [[ -z "$(git -C "$CT_SOURCE" status --porcelain --untracked-files=all)" ]]
}

ct_metadata() {
    "$CT_VENV/bin/python" -I -B - "$CT_SOURCE" "$CT_VENV" <<'PY'
from importlib.metadata import distribution
import json
from pathlib import Path
import sys
from urllib.parse import unquote, urlparse
assert sys.prefix != sys.base_prefix
assert Path(sys.prefix).resolve() == Path(sys.argv[2]).resolve()
d = distribution("chattts")
assert d.version == "0.0.0"
origin = urlparse(json.loads(d.read_text("direct_url.json"))["url"])
assert origin.scheme == "file" and origin.netloc == ""
assert Path(unquote(origin.path)).resolve() == Path(sys.argv[1]).resolve()
print('chattts 0.0.0: Metadaten/Quellpfad geprueft, kein SDK-Import.')
PY
}

ct_probe() {
    local flavor
    [[ -f "$CT_MARKER" && -x "$CT_VENV/bin/python" ]] || return 1
    flavor="$(<"$CT_MARKER")"
    [[ "$flavor" == "$CT_COMMIT package" || "$flavor" == "$CT_COMMIT runtime" ]] || return 1
    ct_source_ok && ct_metadata || return 1
    if [[ "$flavor" == "$CT_COMMIT runtime" ]]; then
        ct_torch_constraints >/dev/null && "$CT_VENV/bin/python" -I -B -m pip --isolated check || return 1
    fi
}

ct_torch_constraints() {
    [[ -x "$CT_VENV/bin/python" ]] || {
        echo 'Zuerst Basispaket installieren, dann passende Torch/torchaudio-Wheels in genau dieser venv einrichten. Siehe docs/tools/chattts.md.' >&2; return 1;
    }
    "$CT_VENV/bin/python" -I -B - "$CT_VENV" <<'PY'
from importlib.metadata import version
from pathlib import Path
import re
import sys
assert sys.prefix != sys.base_prefix and Path(sys.prefix).resolve() == Path(sys.argv[1]).resolve()
torch = version('torch')
audio = version('torchaudio')
assert all(re.fullmatch(r'[0-9][A-Za-z0-9.+!-]{0,127}', v) for v in (torch, audio))
assert torch.split('+')[0] == audio.split('+')[0], 'Torch und torchaudio muessen zusammenpassen'
print('torch==' + torch)
print('torchaudio==' + audio)
PY
}

ct_runtime_preflight() {
    [[ "${INSTALL_HEAVY_TOOLS:-0}" == 1 ]] || {
        echo 'Runtime-Abhaengigkeiten brauchen INSTALL_HEAVY_TOOLS=1 und CHATTTS_INSTALL_RUNTIME=1.' >&2; return 2;
    }
    ct_torch_constraints >/dev/null || {
        echo 'Passende Torch-/torchaudio-Metadaten fehlen. Kein automatischer CUDA-/Treiber-/Torch-Umbau.' >&2; return 1;
    }
}

ct_preflight() {
    case "$(uname -m)" in x86_64|aarch64) ;; *) echo 'ChatTTS: automatischer Wheel-Pfad nur Linux x86_64/ARM64.' >&2; return 1 ;; esac
    "$CT_PYTHON" -I -B -c 'import sys; assert (3,10) <= sys.version_info < (3,13)' || {
        echo 'ChatTTS: vorhandenes Python 3.10-3.12 verwenden; Ubuntu-Python 3.12 passt.' >&2; return 1;
    }
    [[ ! -e "$CT_VENV" || -f "$CT_VENV/pyvenv.cfg" ]] || {
        echo 'Fremdes venv-Verzeichnis; nichts ueberschrieben.' >&2; return 1;
    }
    if [[ -e "$CT_VENV" ]]; then
        "$CT_PYTHON" -I -B - "$CT_VENV/pyvenv.cfg" <<'PY' || return 1
from pathlib import Path
import sys
assert 'include-system-site-packages = false' in Path(sys.argv[1]).read_text()
PY
    fi
}

ct_resources() {
    local mount="$CT_BASE" available
    while [[ ! -d "$mount" ]]; do mount="${mount%/*}"; [[ -n "$mount" ]] || mount=/; done
    # shellcheck source=../../lib/resource_check.sh
    source "$CT_ROOT/scripts/lib/resource_check.sh"
    if [[ "${CHATTTS_INSTALL_RUNTIME:-0}" == 1 ]]; then
        require_ram_mb 8192
        available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
        [[ "$available" =~ ^[0-9]+$ && "$available" -ge 4096 ]] || {
            echo 'Runtime: mindestens 4 GiB verfuegbaren RAM freimachen.' >&2; return 1;
        }
        REQUIRE_WINDOWS_HOST_FREE_MB=20480 require_disk_mb 20480 "$mount"
        return 0
    fi
    require_ram_mb 1024
    available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
    [[ "$available" =~ ^[0-9]+$ && "$available" -ge 512 ]] || {
        echo 'ChatTTS: mindestens 512 MiB aktuell verfuegbaren RAM freimachen; kein Swap-/WSL-Umbau.' >&2; return 1;
    }
    REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 2048 "$mount"
}

ct_python_core_ok() {
    "$CT_PYTHON" -I -B -c 'import sys, ssl; assert (3,10) <= sys.version_info < (3,13)'
}

ct_python_venv_ok() {
    "$CT_PYTHON" -I -B -c 'import venv, ensurepip' >/dev/null 2>&1
}

ct_venv_package() {
    "$CT_PYTHON" -I -B - <<'PY'
from pathlib import Path
import sys
expected = Path('/usr/bin/python%d.%d' % sys.version_info[:2])
assert sys.prefix == sys.base_prefix, 'Keine Paket-Reparatur innerhalb einer venv'
assert Path(sys.executable).resolve() == expected.resolve(), 'Kein Ubuntu-Systeminterpreter'
assert (3, 10) <= sys.version_info < (3, 13)
print('python%d.%d-venv' % sys.version_info[:2])
PY
}

ct_install_venv_package() {
    # shellcheck source=../../lib/apt_lock_wait.sh
    source "$CT_ROOT/scripts/lib/apt_lock_wait.sh"
    run_apt_with_lock_wait update || return 1
    run_apt_with_lock_wait install -y --no-install-recommends "$1"
}

ct_prepare_python() {
    local package answer='' policy="${CHATTTS_INSTALL_VENV_DEPS:-ask}"
    ct_python_core_ok || { echo 'ChatTTS: Python 3.10-3.12 mit SSL erforderlich; CHATTTS_PYTHON_BIN pruefen.' >&2; return 1; }
    ct_python_venv_ok && return 0
    echo 'ChatTTS: Dem gewaehlten Python fehlt venv/ensurepip.'
    package="$(ct_venv_package)" || {
        echo 'Privates/fremdes Python: dessen venv/ensurepip separat reparieren oder CHATTTS_PYTHON_BIN passend setzen; kein System-Python ersetzt.' >&2; return 1;
    }
    command -v apt-get >/dev/null && command -v sudo >/dev/null || {
        echo "Keine apt/sudo-Reparatur verfuegbar. $package separat einrichten." >&2; return 1;
    }
    echo "Notwendiges Systempaket: $package. ChatTTS selbst bleibt aus GitHub, ohne Docker."
    case "$policy" in
        1) ;;
        ask)
            if [[ -t 0 ]]; then
                read -r -p "$package mit sudo installieren? [(j)a/(N)ein]: " answer || answer=''
            fi
            [[ "$answer" == j || "$answer" == J ]] || {
                echo 'Nicht installiert. Nach Zustimmung CHATTTS_INSTALL_VENV_DEPS=1 mit --repair verwenden.' >&2; return 1;
            } ;;
        0) echo 'Installation von venv-Systempaketen deaktiviert.' >&2; return 1 ;;
        *) echo 'CHATTTS_INSTALL_VENV_DEPS: nur ask, 0 oder 1 erlaubt.' >&2; return 2 ;;
    esac
    ct_install_venv_package "$package" || { echo "Installation von $package fehlgeschlagen; kein Clone/Build." >&2; return 1; }
    ct_python_venv_ok || { echo "venv/ensurepip fehlt weiterhin fuer $CT_PYTHON; kein Clone/Build." >&2; return 1; }
    echo 'venv/ensurepip verfuegbar; kein System-Python ersetzt.'
}

ct_fetch() {
    if [[ -e "$CT_SOURCE" ]]; then
        ct_source_ok || { echo 'ChatTTS-Quelle fremd/unvollstaendig/veraendert; manuell sichern, kein Reset.' >&2; return 1; }
    else
        git -c init.defaultBranch=main init "$CT_SOURCE"
        git -C "$CT_SOURCE" remote add origin "$CT_URL"
        GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$CT_SOURCE" fetch --depth 1 origin "$CT_COMMIT"
        GIT_LFS_SKIP_SMUDGE=1 git -c core.hooksPath=/dev/null -C "$CT_SOURCE" checkout --detach FETCH_HEAD
    fi
    ct_source_ok || return 1
    [[ -f "$CT_SOURCE/setup.py" && -f "$CT_SOURCE/ChatTTS/__init__.py" && -f "$CT_SOURCE/requirements.txt" ]] || {
        echo 'Erwartetes ChatTTS-Paketlayout fehlt; kein anderer Installationspfad.' >&2; return 1;
    }
}

ct_install_package() (
    set -euo pipefail
    local flavor=package constraints=''
    trap 'if [[ -n "$constraints" ]]; then rm -f -- "$constraints"; fi' EXIT
    # setup.py otherwise accepts arbitrary inherited CHTTS_VER; the commit is authoritative.
    export CHTTS_VER="$CT_VERSION"
    rm -f -- "$CT_MARKER"
    "$CT_PYTHON" -I -B -m venv "$CT_VENV"
    if [[ "${CHATTTS_INSTALL_RUNTIME:-0}" == 1 ]]; then
        constraints="$(mktemp "$CT_BASE/torch_constraints_XXXXXX")"
        ct_torch_constraints > "$constraints"
        # Prevent pip from replacing the explicitly selected Torch/torchaudio builds.
        "$CT_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir \
            --use-pep517 --disable-pip-version-check --index-url https://pypi.org/simple \
            --constraint "$constraints" --only-binary=torch,torchaudio,numba,llvmlite,numpy "$CT_SOURCE"
        "$CT_VENV/bin/python" -I -B -m pip --isolated check
        flavor=runtime
    else
        "$CT_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir \
            --use-pep517 --disable-pip-version-check --index-url https://pypi.org/simple \
            --no-deps "$CT_SOURCE"
    fi
    ct_metadata
    ct_source_ok || return 1
    printf '%s %s\n' "$CT_COMMIT" "$flavor" > "$CT_MARKER"
    echo "ChatTTS aus GitHub installiert ($flavor). Keine Modelle/Referenzaudios/Trainingsjobs oder Dienste gestartet; Inferenz nicht getestet."
)

ct_deactivate() {
    rm -f -- "$CT_MARKER"
    echo 'ChatTTS-Setup-Marker deaktiviert; Quelle, venv, eigene Daten, Cache, Token und Logs bleiben erhalten.'
}

chattts_main() (
    set -euo pipefail
    umask 077
    unset HF_TOKEN HUGGING_FACE_HUB_TOKEN
    export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 HF_HUB_DISABLE_TELEMETRY=1
    local mode="${1:-install}" program log flavor=package dependencies=false
    ct_paths || return 1
    case "$mode" in
        --dry-run|--plan|plan|--help)
            echo "ChatTTS $CT_VERSION: GitHub $CT_URL; Commit $CT_COMMIT; private Basis-venv ohne Docker."
            echo 'Standard --no-deps: 1 GiB RAM/512 MiB verfuegbar, 2 GiB Disk/Windows-C:.'
            echo 'Optional Runtime: CHATTTS_INSTALL_RUNTIME=1 + INSTALL_HEAVY_TOOLS=1, vorinstalliertes Torch/torchaudio; 8 GiB RAM/4 GiB frei, 20 GiB Disk/Windows-C:. Keine Gewichte/Demo/Training.'
            echo 'Dry-Run ohne Download, Installation, API-/Token-/Uploadzugriff.'; return 0 ;;
        status|--status)
            if ct_probe >/dev/null 2>&1; then
                if [[ "$(<"$CT_MARKER")" == "$CT_COMMIT runtime" ]]; then dependencies=true; fi
                printf '{"installed":true,"runtime_dependencies":%s,"inference_tested":false,"models_checked":false}\n' "$dependencies"
            else echo '{"installed":false,"runtime_dependencies":false,"inference_tested":false,"models_checked":false}'; fi
            return 0 ;;
        doctor|check|--check)
            ct_probe || { echo 'ChatTTS fehlt/deaktiviert oder Quelle/Pakete inkonsistent; --repair verwenden.' >&2; return 1; }
            echo 'Pin/Paketmetadaten konsistent; package ohne Runtime-Abhaengigkeiten, runtime mit pip check. Kein ChatTTS/Torch-Import oder Inferenztest.'; return 0 ;;
        install|update|--repair|uninstall|--uninstall) ;;
        *) echo 'ChatTTS: nur Paketverwaltung, kein Modell-/Demo-/Trainingstart.' >&2; return 2 ;;
    esac
    [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || { echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2; return 1; }
    for program in git flock; do command -v "$program" >/dev/null || { echo "ChatTTS: $program fehlt; Basis separat einrichten." >&2; return 1; }; done
    if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
        command -v "$CT_PYTHON" >/dev/null || { echo 'ChatTTS: Python fehlt; Basis separat einrichten.' >&2; return 1; }
        [[ "${CHATTTS_INSTALL_RUNTIME:-0}" == 0 || "${CHATTTS_INSTALL_RUNTIME:-0}" == 1 ]] || return 2
        if [[ "${CHATTTS_INSTALL_RUNTIME:-0}" == 1 ]]; then
            flavor=runtime
            ct_runtime_preflight || return $?
        fi
        ct_preflight || return 1
        if [[ "$mode" == install && -f "$CT_MARKER" && "$(<"$CT_MARKER")" == "$CT_COMMIT $flavor" ]] && ct_probe >/dev/null 2>&1; then echo 'ChatTTS-Basispaket bereits konsistent; keine Installation.'; return 0; fi
        ct_resources || return 1
    elif [[ ! -d "$CT_BASE" ]]; then echo 'Nicht eingerichtet; nichts deaktiviert.'; return 0; fi
    mkdir -p "$CT_BASE" "$CT_LOGS"
    exec 9>"$CT_BASE/operation.lock"
    flock -n 9 || { echo 'Andere ChatTTS-Operation aktiv.' >&2; return 1; }
    log="$(mktemp "$CT_LOGS/chattts_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
    exec > >(tee -a "$log") 2>&1
    echo "ChatTTS-Installer: 2026-10-19-venv-dependency-repair; Aktion: $mode; Pin: $CT_COMMIT"
    trap 'rc=$?; if ((rc != 0)); then echo "ChatTTS-Fehler ($rc); Dateien erhalten. Log: $log. Nach Behebung --repair verwenden."; fi' EXIT
    if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then ct_deactivate; return 0; fi
    ct_prepare_python || return 1
    ct_fetch
    df -Pk "$CT_BASE"
    ct_install_package
    df -Pk "$CT_BASE"
)
