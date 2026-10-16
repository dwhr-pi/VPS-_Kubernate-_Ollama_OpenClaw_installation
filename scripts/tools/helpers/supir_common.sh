#!/usr/bin/env bash
set -euo pipefail
SUPIR_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
SUPIR_URL=https://github.com/Fanghua-Yu/SUPIR.git
SUPIR_COMMIT=bda91af2000042f8bedfec8897d92917e67c1d88

supir_paths() {
    local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
    [[ "$root" == /* && "$root" != / ]] || return 1
    case "$root/" in "$SUPIR_ROOT/"*) echo 'SUPIR-Workspace muss ausserhalb des Setup-Repos liegen.' >&2; return 1 ;; esac
    SUPIR_BASE="$root/tools/supir"
    SUPIR_SOURCE="$SUPIR_BASE/source"
    SUPIR_MARKER="$SUPIR_BASE/source-ready"
    SUPIR_LOGS="$root/install_logs"
    for path in "$root" "$SUPIR_BASE" "$SUPIR_SOURCE" "$SUPIR_SOURCE/.git" "$SUPIR_MARKER" "$SUPIR_LOGS" "$SUPIR_BASE/operation.lock"; do
        [[ ! -L "$path" && "$(realpath -m -- "$path")" == "$path" ]] || {
            echo 'SUPIR: Symlink/nicht normalisierter Pfad; Abbruch.' >&2; return 1;
        }
    done
}

supir_source_ok() {
    [[ -d "$SUPIR_SOURCE/.git" ]] &&
        [[ "$(git -C "$SUPIR_SOURCE" rev-parse --show-toplevel)" == "$SUPIR_SOURCE" ]] &&
        [[ "$(git -C "$SUPIR_SOURCE" remote get-url origin)" == "$SUPIR_URL" ]] &&
        [[ "$(git -C "$SUPIR_SOURCE" rev-parse HEAD)" == "$SUPIR_COMMIT" ]] &&
        [[ -z "$(git -C "$SUPIR_SOURCE" status --porcelain --untracked-files=all)" ]]
}

supir_inspect() {
    supir_source_ok || return 1
    python3 -I -B - "$SUPIR_SOURCE" <<'PY'
import ast
from pathlib import Path
import sys
root = Path(sys.argv[1])
for name in ('test.py', 'gradio_demo.py', 'CKPT_PTH.py'):
    ast.parse((root / name).read_text(encoding='utf-8'), filename=name)
assert (root / 'LICENSE').is_file()
assert (root / 'requirements.txt').is_file()
print('SUPIR-Pin und Syntax geprueft. Kein Import, pip, Gradio oder Modellzugriff.')
PY
}

supir_runtime_guard() {
    [[ "${SUPIR_INSTALL_RUNTIME:-0}" == 0 ]] || {
        echo 'SUPIR: automatische GPU-/Legacy-Paketinstallation nicht freigegeben.' >&2
        echo 'Upstream pinnt fastapi 0.95.1 (Pydantic <2) und gradio 4.16.0 (Pydantic >=2). Nicht zusammen loesbar.' >&2
        echo 'Nur GitHub-Quellinstallation unterstuetzt; SUPIR_INSTALL_RUNTIME entfernen. Details: docs/tools/supir.md.' >&2
        return 2
    }
}

supir_fetch_source() {
    if [[ -e "$SUPIR_SOURCE" ]]; then
        supir_source_ok || {
            echo 'SUPIR: fremde, unvollstaendige oder veraenderte Quelle. Manuell sichern; kein Reset/Ueberschreiben.' >&2; return 1;
        }
    else
        mkdir "$SUPIR_SOURCE"
        git -C "$SUPIR_SOURCE" init
        git -C "$SUPIR_SOURCE" remote add origin "$SUPIR_URL"
        GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$SUPIR_SOURCE" fetch --depth 1 origin "$SUPIR_COMMIT"
        git -c core.hooksPath=/dev/null -C "$SUPIR_SOURCE" checkout --detach FETCH_HEAD
    fi
    supir_inspect || return 1
    printf '%s\n' "$SUPIR_COMMIT" > "$SUPIR_MARKER"
    echo 'SUPIR-GitHub-Quellinstallation abgeschlossen. KEINE lauffertige GPU-/Modellumgebung.'
    echo 'Keine Python-Pakete, Checkpoints, Bilder, Cloud oder Dienste geladen/gestartet.'
}

supir_deactivate() {
    rm -f -- "$SUPIR_MARKER"
    echo 'SUPIR-Quellregistrierung deaktiviert. Quellcode, eigene Umgebungen, Modelle, Bilder und Logs bleiben erhalten.'
}

supir_main() (
    set -euo pipefail
    umask 077
    local mode="${1:-install}" program mount log
    supir_paths || return 1
    case "$mode" in
        --dry-run|--plan|plan|--help)
            echo "SUPIR GitHub: $SUPIR_URL; Commit: $SUPIR_COMMIT; kein Docker."
            echo 'Nur Quellcode. Upstream: eigener Lizenzvertrag mit kommerziellen Einschraenkungen; vor Nutzung lesen.'
            echo 'Legacy-Paketkonflikt: keine automatische GPU-Laufzeit. Keine Downloads im Dry-Run.'; return 0 ;;
        status|--status)
            if [[ -f "$SUPIR_MARKER" && "$(<"$SUPIR_MARKER")" == "$SUPIR_COMMIT" ]] && supir_source_ok >/dev/null 2>&1; then
                echo '{"source_ready":true,"runtime_ready":false,"models_checked":false,"scope":"github-source-only"}'
            else
                echo '{"source_ready":false,"runtime_ready":false,"models_checked":false,"scope":"github-source-only"}'
            fi
            return 0 ;;
        doctor|check|--check)
            [[ -f "$SUPIR_MARKER" && "$(<"$SUPIR_MARKER")" == "$SUPIR_COMMIT" ]] && supir_inspect || {
                echo 'SUPIR-Quellinstallation fehlt oder ist inkonsistent.' >&2; return 1;
            }
            echo 'Doctor prueft nur Quellen/Syntax. GPU-/Modelllaufzeit nicht eingerichtet; Lizenz/Paketkonflikte siehe Doku.'; return 0 ;;
        install|update|--repair|uninstall|--uninstall) ;;
        *) echo 'SUPIR: nur GitHub-Quellverwaltung; kein Rendering, Server oder automatischer Runtime-Build.' >&2; return 2 ;;
    esac
    if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then supir_runtime_guard || return $?; fi
    [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || { echo 'SUPIR als normaler Linux-Benutzer ohne sudo aufrufen.' >&2; return 1; }
    for program in git python3 flock; do
        command -v "$program" >/dev/null || { echo "SUPIR: Basiswerkzeug $program fehlt; separat einrichten." >&2; return 1; }
    done
    if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
        python3 -I -B -c 'import sys; assert sys.version_info >= (3,10)' || { echo 'Python 3.10+ fuer die reine Syntaxpruefung erforderlich.' >&2; return 1; }
        mount="$SUPIR_BASE"
        while [[ ! -d "$mount" ]]; do mount="${mount%/*}"; [[ -n "$mount" ]] || mount=/; done
        # shellcheck source=../../lib/resource_check.sh
        source "$SUPIR_ROOT/scripts/lib/resource_check.sh"
        REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 1024 "$mount"
    elif [[ ! -d "$SUPIR_BASE" ]]; then echo 'SUPIR nicht eingerichtet; nichts deaktiviert.'; return 0; fi
    mkdir -p "$SUPIR_BASE" "$SUPIR_LOGS"
    exec 9>"$SUPIR_BASE/operation.lock"
    flock -n 9 || { echo 'SUPIR: andere Operation aktiv.' >&2; return 1; }
    log="$(mktemp "$SUPIR_LOGS/supir_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
    exec > >(tee -a "$log") 2>&1
    echo "SUPIR-Installer: 2026-10-16-github-source-only; Aktion: $mode; Commit: $SUPIR_COMMIT"
    trap 'rc=$?; if ((rc != 0)); then echo "SUPIR-Fehler ($rc). Dateien erhalten. Log: $log; nach Behebung --repair verwenden."; fi' EXIT
    if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then supir_deactivate; return 0; fi
    echo 'Hinweis: SUPIR Software License Agreement vor Nutzung beachten; keine pauschale kommerzielle Freigabe.'
    supir_fetch_source
)
