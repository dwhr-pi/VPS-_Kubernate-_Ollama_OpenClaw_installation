#!/usr/bin/env bash
set -euo pipefail
SN_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
SN_URL=https://github.com/vladmandic/sdnext.git
SN_COMMIT=b7dcb0ce870181a40d1246fde1febbff5593a750

sn_paths() {
    local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path index=0
    local -a paths=() resolved=()
    [[ "$root" == /* && "$root" != / ]] || return 1
    case "$root/" in "$SN_ROOT/"*) echo 'SD.Next-Workspace nicht im Setup-Repo ablegen.' >&2; return 1 ;; esac
    SN_BASE="$root/tools/sdnext"
    SN_SOURCE="$SN_BASE/source"
    SN_VENV="$SN_BASE/venv"
    SN_MARKER="$SN_BASE/source-ready"
    SN_LOGS="$root/install_logs"
    SN_PYTHON="${SDNEXT_PYTHON_BIN:-python3}"
    paths=("$root" "$SN_BASE" "$SN_SOURCE" "$SN_SOURCE/.git" "$SN_MARKER" "$SN_VENV" "$SN_LOGS" "$SN_BASE/operation.lock")
    mapfile -t resolved < <(realpath -m -- "${paths[@]}")
    [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
    for path in "${paths[@]}"; do
        [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || { echo 'SD.Next: Symlink/nicht normalisierter Pfad; Abbruch.' >&2; return 1; }
        index=$((index + 1))
    done
}

sn_source_ok() {
    [[ -d "$SN_SOURCE/.git" ]] &&
        [[ "$(git -C "$SN_SOURCE" rev-parse --show-toplevel)" == "$SN_SOURCE" ]] &&
        [[ "$(git -C "$SN_SOURCE" remote get-url origin)" == "$SN_URL" ]] &&
        [[ "$(git -C "$SN_SOURCE" rev-parse HEAD)" == "$SN_COMMIT" ]] &&
        [[ -z "$(git -C "$SN_SOURCE" status --porcelain --untracked-files=all)" ]]
}

sn_inspect() {
    sn_source_ok || return 1
    "$SN_PYTHON" -I -B - "$SN_SOURCE" <<'PY'
import ast
from pathlib import Path
import sys
root = Path(sys.argv[1])
for name in ('launch.py', 'installer.py', 'modules/cmd_args.py'):
    ast.parse((root / name).read_text(encoding='utf-8'), filename=name)
assert (root / 'requirements.txt').is_file()
assert (root / 'LICENSE.txt').is_file()
assert (root / 'webui.sh').is_file()
assert (root / 'constraints.txt').is_file()
assert not (root / '.env').exists()
print('SD.Next-Pin und Syntax geprueft; keine Imports oder Laufzeitinstallation.')
PY
}

sn_venv_ok() {
    [[ -x "$SN_VENV/bin/python" && -f "$SN_VENV/pyvenv.cfg" ]] || return 1
    "$SN_PYTHON" -I -B - "$SN_VENV/pyvenv.cfg" <<'PY'
from pathlib import Path
import sys
assert 'include-system-site-packages = false' in Path(sys.argv[1]).read_text()
PY
    [[ $? -eq 0 ]] || return 1
    "$SN_VENV/bin/python" -I -B -c 'import sys, ssl, ensurepip; assert (3,10) <= sys.version_info < (3,14); assert sys.prefix != sys.base_prefix'
}

sn_fetch() {
    if [[ -e "$SN_SOURCE" ]]; then
        sn_source_ok || { echo 'SD.Next-Quelle fremd/unvollstaendig/veraendert; manuell sichern. Kein Reset/Loeschen.' >&2; return 1; }
    else
        git -c init.defaultBranch=main init "$SN_SOURCE"
        git -C "$SN_SOURCE" remote add origin "$SN_URL"
        GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$SN_SOURCE" fetch --depth 1 origin "$SN_COMMIT"
        GIT_LFS_SKIP_SMUDGE=1 GIT_TERMINAL_PROMPT=0 git -c credential.helper= -c core.hooksPath=/dev/null -C "$SN_SOURCE" checkout --detach FETCH_HEAD
    fi
    sn_inspect || return 1
    if [[ -e "$SN_VENV" ]]; then
        sn_venv_ok || { echo 'SD.Next-venv unvollstaendig/inkompatibel; sichern und separat umbenennen. Keine automatische Loeschung.' >&2; return 1; }
    else
        "$SN_PYTHON" -m venv "$SN_VENV" || {
            echo 'venv fehlgeschlagen. Zum gewaehlten Python passendes Ubuntu-venv-Paket einrichten, dann --repair. Kein System-Python ersetzt.' >&2; return 1;
        }
        sn_venv_ok || return 1
    fi
    printf '%s\n' "$SN_COMMIT" > "$SN_MARKER"
    echo 'SD.Next-GitHub-Quellinstallation vorbereitet (nicht betriebsbereit). Eigene venv bereit; keine Laufzeitpakete, Modelle oder Dienste installiert/gestartet.'
}

sn_deactivate() {
    rm -f -- "$SN_MARKER"
    echo 'SD.Next-Quellregistrierung deaktiviert; Quelle, eigene Daten/Modelle und Logs bleiben erhalten.'
}

sdnext_main() (
    set -euo pipefail
    umask 077
    local mode="${1:-install}" program mount log
    sn_paths || return 1
    case "$mode" in
        --dry-run|--plan|plan|--help)
            echo "SD.Next GitHub: $SN_URL; Pin $SN_COMMIT; ohne Docker."
            echo 'GitHub-Checkout ohne Submodule + isolierte venv. KEINE betriebsbereite Inferenzlaufzeit.'
            echo 'Reserve 2 GiB Disk, 4 GiB Windows-C:; Dry-Run ohne Download oder Import.'; return 0 ;;
        status|--status)
            if [[ -f "$SN_MARKER" && "$(<"$SN_MARKER")" == "$SN_COMMIT" ]] && sn_source_ok >/dev/null 2>&1 && sn_venv_ok >/dev/null 2>&1; then
                echo '{"source_ready":true,"runtime_ready":false,"scope":"github-source-venv"}'
            else echo '{"source_ready":false,"runtime_ready":false,"scope":"github-source-venv"}'; fi
            return 0 ;;
        doctor|check|--check)
            [[ -f "$SN_MARKER" && "$(<"$SN_MARKER")" == "$SN_COMMIT" ]] && sn_inspect || return 1
            sn_venv_ok || return 1
            echo 'Quellen und venv geprueft; Inferenzlaufzeit NICHT eingerichtet; kein GUI-/Modelltest.'; return 0 ;;
        install|update|--repair|uninstall|--uninstall) ;;
        *) echo 'SD.Next: nur Quellverwaltung, kein App-/Inferenz-/Serverstart.' >&2; return 2 ;;
    esac
    [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || { echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2; return 1; }
    for program in git "$SN_PYTHON" flock; do command -v "$program" >/dev/null || { echo "SD.Next: $program fehlt; Basis separat einrichten." >&2; return 1; }; done
    if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
        "$SN_PYTHON" -I -B -c 'import sys, ssl, ensurepip, venv; assert (3,10) <= sys.version_info < (3,14)' || {
            echo 'SD.Next braucht Python 3.10-3.13 samt venv/ensurepip. SDNEXT_PYTHON_BIN setzen; System-Python bleibt unveraendert.' >&2; return 1;
        }
        mount="$SN_BASE"
        while [[ ! -d "$mount" ]]; do mount="${mount%/*}"; [[ -n "$mount" ]] || mount=/; done
        # shellcheck source=../../lib/resource_check.sh
        source "$SN_ROOT/scripts/lib/resource_check.sh"
        REQUIRE_WINDOWS_HOST_FREE_MB=4096 require_disk_mb 2048 "$mount"
    elif [[ ! -d "$SN_BASE" ]]; then echo 'Nicht eingerichtet; nichts deaktiviert.'; return 0; fi
    mkdir -p "$SN_BASE" "$SN_LOGS"
    exec 9>"$SN_BASE/operation.lock"
    flock -n 9 || { echo 'Andere SD.Next-Operation aktiv.' >&2; return 1; }
    log="$(mktemp "$SN_LOGS/sdnext_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
    exec > >(tee -a "$log") 2>&1
    echo "SD.Next-Installer: 2026-10-16-github-source-venv; Aktion: $mode; Pin: $SN_COMMIT"
    trap 'rc=$?; if ((rc != 0)); then echo "SD.Next-Fehler ($rc); Dateien erhalten. Log: $log. Nach Pruefung --repair verwenden."; fi' EXIT
    if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then sn_deactivate; return 0; fi
    df -Pk "$SN_BASE"
    sn_fetch
    df -Pk "$SN_BASE"
)
