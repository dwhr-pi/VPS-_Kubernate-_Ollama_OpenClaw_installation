#!/usr/bin/env bash
set -euo pipefail
JD_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
JD_URL=https://github.com/justdubit/just-dub-it.git
JD_COMMIT=fa4d8f8911036ba79a62f97e7e62581e39441d56
JD_VERSION=0.1.0

jd_paths() {
    local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
    [[ "$root" == /* && "$root" != / ]] || return 1
    case "$root/" in "$JD_ROOT/"*) echo 'Just Dub It-Daten nicht im Setup-Repo ablegen.' >&2; return 1 ;; esac
    JD_BASE="$root/tools/just_dub_it"
    JD_SOURCE="$JD_BASE/source"
    JD_VENV="$JD_BASE/venv"
    JD_MARKER="$JD_BASE/source-built"
    JD_LOGS="$root/install_logs"
    JD_PYTHON="${JUST_DUB_IT_PYTHON_BIN:-python3}"
    # Allow the normal venv Python symlink, not redirecting directories.
    local index=0
    local -a paths=("$root" "$JD_BASE" "$JD_SOURCE" "$JD_SOURCE/.git" "$JD_SOURCE/packages" "$JD_SOURCE/packages/ltx-core" "$JD_SOURCE/packages/ltx-pipelines" "$JD_VENV" "$JD_VENV/bin" "$JD_VENV/pyvenv.cfg" "$JD_MARKER" "$JD_LOGS" "$JD_BASE/operation.lock") resolved=()
    mapfile -t resolved < <(realpath -m -- "${paths[@]}")
    [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
    for path in "${paths[@]}"; do
        [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
            echo 'Just Dub It: Symlink/nicht normalisierter Pfad; Abbruch.' >&2; return 1;
        }
        index=$((index + 1))
    done
}

jd_source_ok() {
    [[ -d "$JD_SOURCE/.git" ]] &&
        [[ "$(git -C "$JD_SOURCE" rev-parse --show-toplevel)" == "$JD_SOURCE" ]] &&
        [[ "$(git -C "$JD_SOURCE" remote get-url origin)" == "$JD_URL" ]] &&
        [[ "$(git -C "$JD_SOURCE" rev-parse HEAD)" == "$JD_COMMIT" ]] &&
        [[ -z "$(git -C "$JD_SOURCE" status --porcelain --untracked-files=all)" ]]
}

jd_metadata() {
    "$JD_VENV/bin/python" -I -B - "$JD_SOURCE" "$JD_VENV" <<'PY'
from importlib.metadata import distribution
import json
from pathlib import Path
import sys
from urllib.parse import unquote, urlparse
assert sys.prefix != sys.base_prefix
assert Path(sys.prefix).resolve() == Path(sys.argv[2]).resolve()
for name in ("ltx-core", "ltx-pipelines"):
    d = distribution(name)
    assert d.version == "0.1.0"
    origin = urlparse(json.loads(d.read_text("direct_url.json"))["url"])
    assert origin.scheme == "file" and origin.netloc == ""
    assert Path(unquote(origin.path)).resolve() == (Path(sys.argv[1]) / "packages" / name).resolve()
print('ltx-core/ltx-pipelines 0.1.0: Metadaten/Quellpfade geprueft, kein SDK-Import.')
PY
}

jd_probe() {
    [[ -f "$JD_MARKER" && "$(<"$JD_MARKER")" == "$JD_COMMIT base" && -x "$JD_VENV/bin/python" ]] || return 1
    jd_source_ok && jd_metadata
}

jd_preflight() {
    case "$(uname -m)" in x86_64|aarch64) ;; *) echo 'Just Dub It: automatischer Wheel-Pfad nur Linux x86_64/ARM64.' >&2; return 1 ;; esac
    "$JD_PYTHON" -I -B -c 'import sys; assert (3,12) <= sys.version_info < (3,13)' || {
        echo 'Just Dub It: Python 3.12 erforderlich; beide gepinnten LTX-Pakete verlangen mindestens Python 3.12. JUST_DUB_IT_PYTHON_BIN setzen.' >&2; return 1;
    }
    [[ ! -e "$JD_VENV" || -f "$JD_VENV/pyvenv.cfg" ]] || {
        echo 'Fremdes venv-Verzeichnis; nichts ueberschrieben.' >&2; return 1;
    }
    if [[ -e "$JD_VENV" ]]; then
        "$JD_PYTHON" -I -B - "$JD_VENV/pyvenv.cfg" <<'PY' || return 1
from pathlib import Path
import sys
assert 'include-system-site-packages = false' in Path(sys.argv[1]).read_text()
PY
    fi
}

jd_resources() {
    local mount="$JD_BASE" available
    while [[ ! -d "$mount" ]]; do mount="${mount%/*}"; [[ -n "$mount" ]] || mount=/; done
    # shellcheck source=../../lib/resource_check.sh
    source "$JD_ROOT/scripts/lib/resource_check.sh"
    require_ram_mb 1024 || return 1
    available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
    [[ "$available" =~ ^[0-9]+$ && "$available" -ge 512 ]] || {
        echo 'Just Dub It: mindestens 512 MiB aktuell verfuegbaren RAM freimachen; kein Swap-/WSL-Umbau.' >&2; return 1;
    }
    REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 2048 "$mount"
}

jd_prepare_python() {
    "$JD_PYTHON" -I -B -c 'import venv, ensurepip, ssl' || {
        echo 'venv/ensurepip/SSL fehlt. Zum ausgewaehlten Python passendes venv-Paket separat einrichten, dann --repair; kein System-Python ersetzt.' >&2; return 1;
    }
}

jd_fetch() {
    if [[ -e "$JD_SOURCE" ]]; then
        jd_source_ok || { echo 'Just Dub It-Quelle fremd/unvollstaendig/veraendert; manuell sichern, kein Reset.' >&2; return 1; }
    else
        git -c init.defaultBranch=main init "$JD_SOURCE"
        git -C "$JD_SOURCE" remote add origin "$JD_URL"
        GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$JD_SOURCE" fetch --depth 1 origin "$JD_COMMIT"
        GIT_LFS_SKIP_SMUDGE=1 git -c core.hooksPath=/dev/null -C "$JD_SOURCE" checkout --detach FETCH_HEAD
    fi
    jd_source_ok || return 1
    [[ -f "$JD_SOURCE/packages/ltx-core/pyproject.toml" && -f "$JD_SOURCE/packages/ltx-pipelines/pyproject.toml" && -f "$JD_SOURCE/LICENSE" ]] || {
        echo 'Erwartetes Just Dub It-Paketlayout fehlt; kein anderer Installationspfad.' >&2; return 1;
    }
}

jd_install_package() {
    rm -f -- "$JD_MARKER"
    "$JD_PYTHON" -I -B -m venv "$JD_VENV"
    # Only the pinned local package is built. GPU runtime is not resolved here.
    "$JD_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir \
        --use-pep517 --disable-pip-version-check --index-url https://pypi.org/simple \
        --no-deps "$JD_SOURCE/packages/ltx-core" "$JD_SOURCE/packages/ltx-pipelines"
    jd_metadata
    jd_source_ok || return 1
    printf '%s\n' "$JD_COMMIT base" > "$JD_MARKER"
    echo 'Just Dub It aus GitHub in privater venv installiert. Nur Basispaket ohne Runtime-Abhaengigkeiten. Keine Checkpoints/Referenzaudios, CLI/WebUI oder Inferenz gestartet.'
}

jd_deactivate() {
    rm -f -- "$JD_MARKER"
    echo 'Just Dub It-Setup-Marker deaktiviert; Quelle, venv, eigene Daten, Cache, Token und Logs bleiben erhalten.'
}

just_dub_it_main() (
    set -euo pipefail
    umask 077
    unset HF_TOKEN HUGGING_FACE_HUB_TOKEN
    export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 HF_HUB_DISABLE_TELEMETRY=1
    local mode="${1:-install}" program log
    jd_paths || return 1
    case "$mode" in
        --dry-run|--plan|plan|--help)
            echo 'Hinweis: urspruengliches Repository archiviert; kein automatischer Wechsel zu LTX-2.3.'
            echo "Just Dub It $JD_VERSION: GitHub $JD_URL; Commit $JD_COMMIT; private Basis-venv ohne Docker."
            echo 'Reserve: 1 GiB gesamt, 512 MiB verfuegbar, 2 GiB Disk/Windows-C:. Nur Paket --no-deps, keine betriebsbereite Audio-Laufzeit.'
            echo 'Dry-Run ohne Download, Installation, API-/Token-/Uploadzugriff.'; return 0 ;;
        status|--status)
            if jd_probe >/dev/null 2>&1; then echo '{"installed":true,"scope":"github-base-package","runtime_dependencies":false,"models_checked":false,"inference_tested":false}'
            else echo '{"installed":false,"scope":"github-base-package","runtime_dependencies":false,"models_checked":false,"inference_tested":false}'; fi
            return 0 ;;
        doctor|check|--check)
            jd_probe || { echo 'Just Dub It fehlt/deaktiviert oder Quelle/Pakete inkonsistent; --repair verwenden.' >&2; return 1; }
            echo 'Pin/Paketmetadaten konsistent, Runtime-Abhaengigkeiten fehlen absichtlich. Kein LTX-/Torch-Import, CLI/WebUI oder Modelltest.'; return 0 ;;
        install|update|--repair|uninstall|--uninstall) ;;
        *) echo 'Just Dub It: nur Paketverwaltung, kein Modell-/Demo-/Trainingstart.' >&2; return 2 ;;
    esac
    if [[ "$mode" != uninstall && "$mode" != --uninstall && "${JUST_DUB_IT_INSTALL_RUNTIME:-0}" != 0 ]]; then
        echo 'Automatische GPU-Runtime nicht freigegeben: Archivierte LTX-2-Pipeline braucht separat gepruefte Torch-/CUDA-Pakete, Modelle und Lizenzen. Siehe docs/tools/just-dub-it.md.' >&2; return 2;
    fi
    if [[ "$mode" != uninstall && "$mode" != --uninstall && "${JUST_DUB_IT_ACCEPT_LICENSE:-0}" != 1 ]]; then
        echo 'Archivierte Quelle unter LTX-2 Community License. Erst docs/tools/just-dub-it.md und Upstream-Lizenz pruefen; danach JUST_DUB_IT_ACCEPT_LICENSE=1 setzen.' >&2; return 2;
    fi
    [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || { echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2; return 1; }
    for program in git flock; do command -v "$program" >/dev/null || { echo "Just Dub It: $program fehlt; Basis separat einrichten." >&2; return 1; }; done
    if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
        command -v "$JD_PYTHON" >/dev/null || { echo 'Just Dub It: Python fehlt; Basis separat einrichten.' >&2; return 1; }
        jd_preflight || return 1
        if [[ "$mode" == install ]] && jd_probe >/dev/null 2>&1; then echo 'Just Dub It-Basispaket bereits konsistent; keine Installation.'; return 0; fi
        jd_resources || return 1
    elif [[ ! -d "$JD_BASE" ]]; then echo 'Nicht eingerichtet; nichts deaktiviert.'; return 0; fi
    mkdir -p "$JD_BASE" "$JD_LOGS"
    exec 9>"$JD_BASE/operation.lock"
    flock -n 9 || { echo 'Andere Just Dub It-Operation aktiv.' >&2; return 1; }
    log="$(mktemp "$JD_LOGS/just_dub_it_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
    exec > >(tee -a "$log") 2>&1
    echo "Just Dub It-Installer: 2026-10-18-github-base-package; Aktion: $mode; Pin: $JD_COMMIT"
    trap 'rc=$?; if ((rc != 0)); then echo "Just Dub It-Fehler ($rc); Dateien erhalten. Log: $log. Nach Behebung --repair verwenden."; fi' EXIT
    if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then jd_deactivate; return 0; fi
    jd_prepare_python
    jd_fetch
    df -Pk "$JD_BASE"
    jd_install_package
    df -Pk "$JD_BASE"
)
