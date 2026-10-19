#!/usr/bin/env bash
set -euo pipefail
AA_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
AA_URL=https://github.com/Finrandojin/alexandria-audiobook.git
AA_COMMIT=be6343d95d94db5f88973aa25575a390f3ce46aa

aa_paths() {
    local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path index=0
    local -a paths=() resolved=()
    [[ "$root" == /* && "$root" != / ]] || return 1
    case "$root/" in "$AA_ROOT/"*) echo 'Alexandria-Workspace nicht im Setup-Repo ablegen.' >&2; return 1 ;; esac
    AA_BASE="$root/tools/alexandria_audiobook"
    AA_SOURCE="$AA_BASE/source"
    AA_VENV="$AA_BASE/venv"
    AA_MARKER="$AA_BASE/source-ready"
    AA_LOGS="$root/install_logs"
    AA_PYTHON="${ALEXANDRIA_PYTHON_BIN:-python3}"
    paths=("$root" "$AA_BASE" "$AA_SOURCE" "$AA_SOURCE/.git" "$AA_MARKER" "$AA_VENV" "$AA_VENV/bin" "$AA_VENV/pyvenv.cfg" "$AA_LOGS" "$AA_BASE/operation.lock")
    mapfile -t resolved < <(realpath -m -- "${paths[@]}")
    [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
    for path in "${paths[@]}"; do
        [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || { echo 'Alexandria: Symlink/nicht normalisierter Pfad; Abbruch.' >&2; return 1; }
        index=$((index + 1))
    done
}

aa_source_ok() {
    [[ -d "$AA_SOURCE/.git" && ! -e "$AA_SOURCE/.env" && ! -L "$AA_SOURCE/.env" ]] &&
        [[ "$(git -C "$AA_SOURCE" rev-parse --show-toplevel)" == "$AA_SOURCE" ]] &&
        [[ "$(git -C "$AA_SOURCE" remote get-url origin)" == "$AA_URL" ]] &&
        [[ "$(git -C "$AA_SOURCE" rev-parse HEAD)" == "$AA_COMMIT" ]] &&
        [[ "$(git -C "$AA_SOURCE" config --bool core.sparseCheckout)" == true ]] &&
        [[ "$(git -C "$AA_SOURCE" sparse-checkout list)" == "$(aa_sparse_patterns)" ]] &&
        [[ -z "$(git -C "$AA_SOURCE" status --porcelain --untracked-files=all)" ]]
}

aa_inspect() {
    aa_source_ok || return 1
    "$AA_PYTHON" -I -B - "$AA_SOURCE" <<'PY'
import ast
from pathlib import Path
import sys
root = Path(sys.argv[1])
for name in ('app/app.py',):
    ast.parse((root / name).read_text(encoding='utf-8'), filename=name)
assert (root / 'app/requirements.txt').is_file()
assert (root / 'LICENSE').is_file()
assert not (root / '.env').exists()
print('Alexandria-Pin und Syntax geprueft; keine Imports oder Laufzeitinstallation.')
PY
}

aa_sparse_patterns() {
    # Allow source trees only; root .env, media, notebooks and weights are not checked out.
    cat <<'PATTERNS'
/README.md
/LICENSE
/app/
/default_prompts.txt
/review_prompts.txt
/persona_prompts.txt
/install.js
/start.js
/torch.js
!*.pt
!*.pth
!*.onnx
!*.bin
!*.safetensors
!*.ckpt
!*.wav
!*.mp3
!*.m4b
!.env
!.env.*
!config.json
PATTERNS
}

aa_sparse_checkout() {
    aa_sparse_patterns | git -C "$AA_SOURCE" sparse-checkout set --no-cone --stdin
}

aa_venv_ok() {
    [[ -x "$AA_VENV/bin/python" && -f "$AA_VENV/pyvenv.cfg" ]] || return 1
    "$AA_PYTHON" -I -B - "$AA_VENV/pyvenv.cfg" <<'PY' || return 1
from pathlib import Path
import sys
assert 'include-system-site-packages = false' in Path(sys.argv[1]).read_text()
PY
    "$AA_VENV/bin/python" -I -B -c 'import sys, ssl, ensurepip; assert (3,10) <= sys.version_info < (3,13); assert sys.prefix != sys.base_prefix'
}

aa_python_core_ok() {
    "$AA_PYTHON" -I -B -c 'import sys, ssl; assert (3,10) <= sys.version_info < (3,13)'
}

aa_python_venv_ok() {
    "$AA_PYTHON" -I -B -c 'import venv, ensurepip' >/dev/null 2>&1
}

aa_venv_package() {
    "$AA_PYTHON" -I -B - <<'PY'
from pathlib import Path
import sys
expected = Path('/usr/bin/python%d.%d' % sys.version_info[:2])
assert sys.prefix == sys.base_prefix, 'Keine Paket-Reparatur innerhalb einer venv'
assert Path(sys.executable).resolve() == expected.resolve(), 'Kein Ubuntu-Systeminterpreter'
assert (3, 10) <= sys.version_info < (3, 13)
print('python%d.%d-venv' % sys.version_info[:2])
PY
}

aa_install_venv_package() {
    # shellcheck source=../../lib/apt_lock_wait.sh
    source "$AA_ROOT/scripts/lib/apt_lock_wait.sh"
    run_apt_with_lock_wait update || return 1
    run_apt_with_lock_wait install -y --no-install-recommends "$1"
}

aa_prepare_python() {
    local package answer='' policy="${ALEXANDRIA_INSTALL_VENV_DEPS:-ask}"
    aa_python_core_ok || { echo 'Alexandria: Python 3.10-3.12 mit SSL erforderlich; ALEXANDRIA_PYTHON_BIN pruefen.' >&2; return 1; }
    aa_python_venv_ok && return 0
    echo 'Alexandria: Dem gewaehlten Python fehlt venv/ensurepip.'
    package="$(aa_venv_package)" || {
        echo 'Privates/fremdes Python: dessen venv/ensurepip separat reparieren oder ALEXANDRIA_PYTHON_BIN passend setzen; kein System-Python ersetzt.' >&2; return 1;
    }
    command -v apt-get >/dev/null && command -v sudo >/dev/null || {
        echo "Keine apt/sudo-Reparatur verfuegbar. $package separat einrichten." >&2; return 1;
    }
    echo "Notwendiges Systempaket: $package. Alexandria selbst bleibt aus GitHub, ohne Docker."
    case "$policy" in
        1) ;;
        ask)
            if [[ -t 0 ]]; then
                read -r -p "$package mit sudo installieren? [(j)a/(N)ein]: " answer || answer=''
            fi
            [[ "$answer" == j || "$answer" == J ]] || {
                echo 'Nicht installiert. Nach Zustimmung ALEXANDRIA_INSTALL_VENV_DEPS=1 mit --repair verwenden.' >&2; return 1;
            } ;;
        0) echo 'Installation von venv-Systempaketen deaktiviert.' >&2; return 1 ;;
        *) echo 'ALEXANDRIA_INSTALL_VENV_DEPS: nur ask, 0 oder 1 erlaubt.' >&2; return 2 ;;
    esac
    aa_install_venv_package "$package" || { echo "Installation von $package fehlgeschlagen; kein Clone/Build." >&2; return 1; }
    aa_python_venv_ok || { echo "venv/ensurepip fehlt weiterhin fuer $AA_PYTHON; kein Clone/Build." >&2; return 1; }
    echo 'venv/ensurepip verfuegbar; kein System-Python ersetzt.'
}

aa_fetch() {
    if [[ -e "$AA_SOURCE" ]]; then
        aa_source_ok || { echo 'Alexandria-Quelle fremd/unvollstaendig/veraendert oder voller Checkout; manuell sichern. Kein Reset/Loeschen.' >&2; return 1; }
    else
        git -c init.defaultBranch=main init "$AA_SOURCE"
        git -C "$AA_SOURCE" remote add origin "$AA_URL"
        aa_sparse_checkout
        GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$AA_SOURCE" fetch --filter=blob:none --depth 1 origin "$AA_COMMIT"
        GIT_LFS_SKIP_SMUDGE=1 GIT_TERMINAL_PROMPT=0 git -c credential.helper= -c core.hooksPath=/dev/null -C "$AA_SOURCE" checkout --detach FETCH_HEAD
    fi
    aa_inspect || return 1
    if [[ -e "$AA_VENV" ]]; then
        aa_venv_ok || { echo 'Alexandria-venv unvollstaendig/fremd; sichern und separat pruefen. Keine automatische Loeschung.' >&2; return 1; }
    else
        "$AA_PYTHON" -m venv "$AA_VENV" || {
            echo 'venv fehlgeschlagen; zum gewaehlten Python passendes venv-Paket separat einrichten, danach --repair.' >&2; return 1;
        }
        aa_venv_ok || return 1
    fi
    printf '%s\n' "$AA_COMMIT" > "$AA_MARKER"
    echo 'Alexandria-GitHub-Quellinstallation vorbereitet (nicht betriebsbereit). Private venv bereit; keine Runtime-Pakete, Modelle, Trainingsjobs oder Dienste installiert/gestartet.'
}

aa_deactivate() {
    rm -f -- "$AA_MARKER"
    echo 'Alexandria-Quellregistrierung deaktiviert; Quelle, eigene Daten/Modelle und Logs bleiben erhalten.'
}

alexandria_audiobook_main() (
    set -euo pipefail
    umask 077
    local mode="${1:-install}" program mount log
    aa_paths || return 1
    case "$mode" in
        --dry-run|--plan|plan|--help)
            echo "Alexandria GitHub: $AA_URL; Pin $AA_COMMIT; ohne Docker."
            echo 'Nur Quellinstallation via Sparse-Checkout + private venv, keine Konfiguration/Audios/Gewichte im Arbeitsbaum. KEINE betriebsbereite Hoerbuch-Laufzeit.'
            echo 'Reserve 2 GiB Disk, 4 GiB Windows-C: nur fuer Quellen/venv; Dry-Run ohne Download oder Import.'; return 0 ;;
        status|--status)
            if [[ -f "$AA_MARKER" && "$(<"$AA_MARKER")" == "$AA_COMMIT" ]] && aa_source_ok >/dev/null 2>&1 && aa_venv_ok >/dev/null 2>&1; then
                echo '{"source_ready":true,"runtime_ready":false,"scope":"github-source-venv"}'
            else echo '{"source_ready":false,"runtime_ready":false,"scope":"github-source-venv"}'; fi
            return 0 ;;
        doctor|check|--check)
            [[ -f "$AA_MARKER" && "$(<"$AA_MARKER")" == "$AA_COMMIT" ]] && aa_inspect || return 1
            aa_venv_ok || return 1
            echo 'Quellen/venv geprueft, Hoerbuch-Laufzeit NICHT eingerichtet; kein GUI-/Modelltest.'; return 0 ;;
        install|update|--repair|uninstall|--uninstall) ;;
        *) echo 'Alexandria: nur Quellverwaltung, kein App-/Hoerbuch-/Serverstart.' >&2; return 2 ;;
    esac
    [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || { echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2; return 1; }
    for program in git "$AA_PYTHON" flock; do command -v "$program" >/dev/null || { echo "Alexandria: $program fehlt; Basis separat einrichten." >&2; return 1; }; done
    if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
        mount="$AA_BASE"
        while [[ ! -d "$mount" ]]; do mount="${mount%/*}"; [[ -n "$mount" ]] || mount=/; done
        # shellcheck source=../../lib/resource_check.sh
        source "$AA_ROOT/scripts/lib/resource_check.sh"
        REQUIRE_WINDOWS_HOST_FREE_MB=4096 require_disk_mb 2048 "$mount"
    elif [[ ! -d "$AA_BASE" ]]; then echo 'Nicht eingerichtet; nichts deaktiviert.'; return 0; fi
    mkdir -p "$AA_BASE" "$AA_LOGS"
    exec 9>"$AA_BASE/operation.lock"
    flock -n 9 || { echo 'Andere Alexandria-Operation aktiv.' >&2; return 1; }
    log="$(mktemp "$AA_LOGS/alexandria_audiobook_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
    exec > >(tee -a "$log") 2>&1
    echo "Alexandria-Installer: 2026-10-19-venv-dependency-repair; Aktion: $mode; Pin: $AA_COMMIT"
    trap 'rc=$?; if ((rc != 0)); then echo "Alexandria-Fehler ($rc); Dateien erhalten. Log: $log. Nach Pruefung --repair verwenden."; fi' EXIT
    if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then aa_deactivate; return 0; fi
    aa_prepare_python || return 1
    df -Pk "$AA_BASE"
    aa_fetch
    df -Pk "$AA_BASE"
)
