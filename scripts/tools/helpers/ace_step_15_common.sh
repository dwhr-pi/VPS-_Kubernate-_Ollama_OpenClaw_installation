#!/usr/bin/env bash
set -euo pipefail
AC_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
AC_URL=https://github.com/ace-step/ACE-Step-1.5.git
AC_COMMIT=dce621408bee8c31b4fcf4811682eb9359e1bc94
AC_VERSION=1.5.0

ac_paths() {
    local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
    [[ "$root" == /* && "$root" != / ]] || return 1
    case "$root/" in "$AC_ROOT/"*) echo 'ACE-Step 1.5-Daten nicht im Setup-Repo ablegen.' >&2; return 1 ;; esac
    AC_BASE="$root/tools/ace_step_15"
    AC_SOURCE="$AC_BASE/source"
    AC_VENV="$AC_BASE/venv"
    AC_MARKER="$AC_BASE/source-built"
    AC_LOGS="$root/install_logs"
    AC_PYTHON="${ACE_STEP_15_PYTHON_BIN:-python3}"
    # Allow the normal venv Python symlink, not redirecting directories.
    local index=0
    local -a paths=("$root" "$AC_BASE" "$AC_SOURCE" "$AC_SOURCE/.git" "$AC_VENV" "$AC_VENV/bin" "$AC_VENV/pyvenv.cfg" "$AC_MARKER" "$AC_LOGS" "$AC_BASE/operation.lock") resolved=()
    mapfile -t resolved < <(realpath -m -- "${paths[@]}")
    [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
    for path in "${paths[@]}"; do
        [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
            echo 'ACE-Step 1.5: Symlink/nicht normalisierter Pfad; Abbruch.' >&2; return 1;
        }
        index=$((index + 1))
    done
}

ac_source_ok() {
    [[ -d "$AC_SOURCE/.git" && ! -e "$AC_SOURCE/.env" && ! -L "$AC_SOURCE/.env" ]] &&
        [[ "$(git -C "$AC_SOURCE" rev-parse --show-toplevel)" -ef "$AC_SOURCE" ]] &&
        [[ "$(git -C "$AC_SOURCE" remote get-url origin)" == "$AC_URL" ]] &&
        [[ "$(git -C "$AC_SOURCE" rev-parse HEAD)" == "$AC_COMMIT" ]] &&
        [[ "$(git -C "$AC_SOURCE" config --bool core.sparseCheckout)" == true ]] &&
        [[ "$(git -C "$AC_SOURCE" sparse-checkout list)" == "$(ac_sparse_patterns)" ]] &&
        [[ -z "$(git -C "$AC_SOURCE" status --porcelain --untracked-files=all)" ]]
}

ac_metadata() {
    "$AC_VENV/bin/python" -I -B - "$AC_SOURCE" "$AC_VENV" <<'PY'
from importlib.metadata import distribution
import json
from pathlib import Path
import sys
from urllib.parse import unquote, urlparse
assert sys.prefix != sys.base_prefix
assert Path(sys.prefix).resolve() == Path(sys.argv[2]).resolve()
d = distribution("ace-step")
assert d.version == "1.5.0"
origin = urlparse(json.loads(d.read_text("direct_url.json"))["url"])
assert origin.scheme == "file" and origin.netloc == ""
assert Path(unquote(origin.path)).resolve() == Path(sys.argv[1]).resolve()
print('acestep 1.5.0 / ACE-Step 1.5: Metadaten/Quellpfad geprueft, kein SDK-Import.')
PY
}

ac_probe() {
    [[ -f "$AC_MARKER" && "$(<"$AC_MARKER")" == "$AC_COMMIT base" && -x "$AC_VENV/bin/python" ]] || return 1
    ac_source_ok && ac_metadata
}

ac_preflight() {
    case "$(uname -m)" in x86_64|aarch64) ;; *) echo 'ACE-Step 1.5: automatischer Wheel-Pfad nur Linux x86_64/ARM64.' >&2; return 1 ;; esac
    "$AC_PYTHON" -I -B -c 'import sys; assert (3,11) <= sys.version_info < (3,13)' || {
        echo 'ACE-Step 1.5: Python 3.11/3.12 verwenden; ACE_STEP_15_PYTHON_BIN setzen. Kein System-Python-Umbau.' >&2; return 1;
    }
    [[ ! -e "$AC_VENV" || -f "$AC_VENV/pyvenv.cfg" ]] || {
        echo 'Fremdes venv-Verzeichnis; nichts ueberschrieben.' >&2; return 1;
    }
    if [[ -e "$AC_VENV" ]]; then
        "$AC_PYTHON" -I -B - "$AC_VENV/pyvenv.cfg" <<'PY' || return 1
from pathlib import Path
import sys
assert 'include-system-site-packages = false' in Path(sys.argv[1]).read_text()
PY
    fi
}

ac_resources() {
    local mount="$AC_BASE" available
    while [[ ! -d "$mount" ]]; do mount="${mount%/*}"; [[ -n "$mount" ]] || mount=/; done
    # shellcheck source=../../lib/resource_check.sh
    source "$AC_ROOT/scripts/lib/resource_check.sh"
    require_ram_mb 1024 || return 1
    available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
    [[ "$available" =~ ^[0-9]+$ && "$available" -ge 512 ]] || {
        echo 'ACE-Step 1.5: mindestens 512 MiB aktuell verfuegbaren RAM freimachen; kein Swap-/WSL-Umbau.' >&2; return 1;
    }
    REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 2048 "$mount"
}

ac_python_core_ok() {
    "$AC_PYTHON" -I -B -c 'import sys, ssl; assert (3,11) <= sys.version_info < (3,13)'
}

ac_python_venv_ok() {
    "$AC_PYTHON" -I -B -c 'import venv, ensurepip' >/dev/null 2>&1
}

ac_venv_package() {
    "$AC_PYTHON" -I -B - <<'PY'
from pathlib import Path
import sys
expected = Path('/usr/bin/python%d.%d' % sys.version_info[:2])
assert sys.prefix == sys.base_prefix, 'Keine Paket-Reparatur innerhalb einer venv'
assert Path(sys.executable).resolve() == expected.resolve(), 'Kein Ubuntu-Systeminterpreter'
assert (3, 11) <= sys.version_info < (3, 13)
print('python%d.%d-venv' % sys.version_info[:2])
PY
}

ac_install_venv_package() {
    # shellcheck source=../../lib/apt_lock_wait.sh
    source "$AC_ROOT/scripts/lib/apt_lock_wait.sh"
    run_apt_with_lock_wait update || return 1
    run_apt_with_lock_wait install -y --no-install-recommends "$1"
}

ac_prepare_python() {
    local package answer='' policy="${ACE_STEP_15_INSTALL_VENV_DEPS:-ask}"
    ac_python_core_ok || { echo 'ACE-Step 1.5: Python 3.11/3.12 mit SSL erforderlich; ACE_STEP_15_PYTHON_BIN pruefen.' >&2; return 1; }
    ac_python_venv_ok && return 0
    echo 'ACE-Step 1.5: Dem gewaehlten Python fehlt venv/ensurepip.'
    package="$(ac_venv_package)" || {
        echo 'Privates/fremdes Python: dessen venv/ensurepip separat reparieren oder ACE_STEP_15_PYTHON_BIN passend setzen; kein System-Python ersetzt.' >&2; return 1;
    }
    command -v apt-get >/dev/null && command -v sudo >/dev/null || {
        echo "Keine apt/sudo-Reparatur verfuegbar. $package separat einrichten." >&2; return 1;
    }
    echo "Notwendiges Systempaket: $package. ACE-Step selbst bleibt aus GitHub, ohne Docker."
    case "$policy" in
        1) ;;
        ask)
            if [[ -t 0 ]]; then
                read -r -p "$package mit sudo installieren? [(j)a/(N)ein]: " answer || answer=''
            fi
            [[ "$answer" == j || "$answer" == J ]] || {
                echo 'Nicht installiert. Nach Zustimmung ACE_STEP_15_INSTALL_VENV_DEPS=1 mit --repair verwenden.' >&2; return 1;
            } ;;
        0) echo 'Installation von venv-Systempaketen deaktiviert.' >&2; return 1 ;;
        *) echo 'ACE_STEP_15_INSTALL_VENV_DEPS: nur ask, 0 oder 1 erlaubt.' >&2; return 2 ;;
    esac
    ac_install_venv_package "$package" || { echo "Installation von $package fehlgeschlagen; kein Clone/Build." >&2; return 1; }
    ac_python_venv_ok || { echo "venv/ensurepip fehlt weiterhin fuer $AC_PYTHON; kein Clone/Build." >&2; return 1; }
    echo 'venv/ensurepip verfuegbar; kein System-Python ersetzt.'
}

ac_sparse_patterns() {
    cat <<'PATTERNS'
/README.md
/.gitignore
/LICENSE
/pyproject.toml
/acestep/
/openrouter/
!*.pt
!*.pth
!*.onnx
!*.bin
!*.safetensors
!*.pkl
!*.npy
!*.npz
!*.mp4
!*.webm
!*.mov
!*.wav
!*.mp3
!*.flac
!*.png
!*.jpg
!*.jpeg
!*.gif
!*.webp
!*.ipynb
!*.ckpt
!*.zip
!*.tar.gz
!.env
!.env.*
PATTERNS
}

ac_sparse_checkout() {
    ac_sparse_patterns | git -C "$AC_SOURCE" sparse-checkout set --no-cone --stdin
}

ac_fetch() {
    if [[ -e "$AC_SOURCE" ]]; then
        ac_source_ok || { echo 'ACE-Step 1.5-Quelle fremd/unvollstaendig/veraendert; manuell sichern, kein Reset.' >&2; return 1; }
    else
        git -c init.defaultBranch=main init "$AC_SOURCE" || return 1
        git -C "$AC_SOURCE" remote add origin "$AC_URL" || return 1
        ac_sparse_checkout || return 1
        GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$AC_SOURCE" fetch --filter=blob:none --depth 1 origin "$AC_COMMIT" || return 1
        GIT_LFS_SKIP_SMUDGE=1 GIT_TERMINAL_PROMPT=0 git -c credential.helper= -c core.hooksPath=/dev/null -C "$AC_SOURCE" checkout --detach FETCH_HEAD || return 1
    fi
    ac_source_ok || return 1
    [[ -f "$AC_SOURCE/pyproject.toml" && -f "$AC_SOURCE/acestep/__init__.py" && -f "$AC_SOURCE/LICENSE" && -f "$AC_SOURCE/openrouter/__init__.py" && -f "$AC_SOURCE/acestep/ui/gradio/interfaces/audio_player_preferences.js" && -f "$AC_SOURCE/acestep/ui/gradio/interfaces/user_preferences.js" ]] || {
        echo 'Erwartetes ACE-Step 1.5-Paketlayout fehlt; kein anderer Installationspfad.' >&2; return 1;
    }
}

ac_install_package() {
    rm -f -- "$AC_MARKER"
    "$AC_PYTHON" -I -B -m venv "$AC_VENV" || return 1
    # Only the pinned local package is built. GPU runtime is not resolved here.
    "$AC_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir \
        --disable-pip-version-check --index-url https://pypi.org/simple \
        --no-deps "$AC_SOURCE" || return 1
    ac_metadata || return 1
    ac_source_ok || return 1
    printf '%s\n' "$AC_COMMIT base" > "$AC_MARKER"
    echo 'ACE-Step 1.5 aus GitHub in privater venv installiert. Nur Basispaket ohne Runtime-Abhaengigkeiten. Keine Checkpoints/Referenzaudios, CLI/WebUI oder Inferenz gestartet.'
}

ac_deactivate() {
    rm -f -- "$AC_MARKER"
    echo 'ACE-Step 1.5-Setup-Marker deaktiviert; Quelle, venv, eigene Daten, Cache, Token und Logs bleiben erhalten.'
}

ace_step_15_main() (
    set -euo pipefail
    umask 077
    unset HF_TOKEN HUGGING_FACE_HUB_TOKEN GEMINI_API_KEY GOOGLE_API_KEY WANDB_API_KEY OPENROUTER_API_KEY OPENAI_API_KEY
    export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 HF_HUB_DISABLE_TELEMETRY=1
    local mode="${1:-install}" program log
    ac_paths || return 1
    case "$mode" in
        --dry-run|--plan|plan|--help)
            echo "ACE-Step 1.5 $AC_VERSION: GitHub $AC_URL; Commit $AC_COMMIT; private Basis-venv ohne Docker."
            echo 'Reserve: 1 GiB gesamt, 512 MiB verfuegbar, 2 GiB Disk/Windows-C:. Nur Paket --no-deps, keine betriebsbereite Musik-Laufzeit.'
            echo 'Dry-Run ohne Download, Installation, API-/Token-/Uploadzugriff.'; return 0 ;;
        status|--status)
            if ac_probe >/dev/null 2>&1; then echo '{"installed":true,"scope":"github-base-package","runtime_dependencies":false,"models_checked":false,"inference_tested":false}'
            else echo '{"installed":false,"scope":"github-base-package","runtime_dependencies":false,"models_checked":false,"inference_tested":false}'; fi
            return 0 ;;
        doctor|check|--check)
            ac_probe || { echo 'ACE-Step 1.5 fehlt/deaktiviert oder Quelle/Pakete inkonsistent; --repair verwenden.' >&2; return 1; }
            echo 'Pin/Paketmetadaten konsistent, Runtime-Abhaengigkeiten fehlen absichtlich. Kein ACE-Step-/Torch-Import, CLI/WebUI oder Modelltest.'; return 0 ;;
        install|update|--repair|uninstall|--uninstall) ;;
        *) echo 'ACE-Step 1.5: nur Paketverwaltung, kein Modell-/Demo-/Trainingstart.' >&2; return 2 ;;
    esac
    if [[ "$mode" != uninstall && "$mode" != --uninstall && "${ACE_STEP_15_INSTALL_RUNTIME:-0}" != 0 ]]; then
        echo 'Automatische GPU-Runtime nicht freigegeben: ACE-Step-Tag v0.1.8 nutzt Torch 2.10.0+cu128 (Linux x86_64), cu130 (ARM64), uv-Indizes und lokales nano-vllm. Kein pip-PyPI-Ersatz; siehe docs/tools/ace-step-15.md.' >&2; return 2;
    fi
    [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || { echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2; return 1; }
    for program in git flock; do command -v "$program" >/dev/null || { echo "ACE-Step 1.5: $program fehlt; Basis separat einrichten." >&2; return 1; }; done
    if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
        command -v "$AC_PYTHON" >/dev/null || { echo 'ACE-Step 1.5: Python fehlt; Basis separat einrichten.' >&2; return 1; }
        ac_preflight || return 1
        if [[ "$mode" == install ]] && ac_probe >/dev/null 2>&1; then echo 'ACE-Step 1.5-Basispaket bereits konsistent; keine Installation.'; return 0; fi
        ac_resources || return 1
    elif [[ ! -d "$AC_BASE" ]]; then echo 'Nicht eingerichtet; nichts deaktiviert.'; return 0; fi
    mkdir -p "$AC_BASE" "$AC_LOGS"
    exec 9>"$AC_BASE/operation.lock"
    flock -n 9 || { echo 'Andere ACE-Step 1.5-Operation aktiv.' >&2; return 1; }
    log="$(mktemp "$AC_LOGS/ace_step_15_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
    exec > >(tee -a "$log") 2>&1
    echo "ACE-Step 1.5-Installer: 2026-10-19-venv-dependency-repair; Aktion: $mode; Pin: $AC_COMMIT"
    trap 'rc=$?; if ((rc != 0)); then echo "ACE-Step 1.5-Fehler ($rc); Dateien erhalten. Log: $log. Nach Behebung --repair verwenden."; fi' EXIT
    if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then ac_deactivate; return 0; fi
    ac_prepare_python || return 1
    ac_fetch || return 1
    df -Pk "$AC_BASE"
    ac_install_package || return 1
    df -Pk "$AC_BASE"
)
