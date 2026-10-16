#!/usr/bin/env bash
set -euo pipefail
AF_REPO_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
AF_URL=https://github.com/microsoft/agent-framework.git
AF_COMMIT=17b1a14bd5b4c774c18d5b827b4f5b97bed3cbee
AF_VERSION=1.22.0

af_paths() {
    local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
    [[ "$root" == /* && "$root" != / ]] || return 1
    case "$root/" in "$AF_REPO_ROOT/"*) echo 'User-Daten nicht im Setup-Repo ablegen.' >&2; return 1 ;; esac
    AF_BASE="$root/tools/agent_framework"
    AF_SOURCE="$AF_BASE/source"
    AF_VENV="$AF_BASE/venv"
    AF_MARKER="$AF_BASE/source-built"
    AF_LOGS="$root/install_logs"
    for path in "$root" "$AF_BASE" "$AF_SOURCE" "$AF_SOURCE/.git" "$AF_VENV" "$AF_MARKER" "$AF_LOGS" "$AF_BASE/operation.lock"; do
        [[ ! -L "$path" && "$(realpath -m -- "$path")" == "$path" ]] || {
            echo 'Agent Framework: Symlink/nicht normalisierter Pfad; Abbruch.' >&2; return 1;
        }
    done
}

af_python() {
    local candidate
    for candidate in "${AGENT_FRAMEWORK_PYTHON_BIN:-python3}"; do
        command -v "$candidate" >/dev/null && "$candidate" -I -c \
            'import sys; assert (3, 10) <= sys.version_info < (3, 16)' && {
            command -v "$candidate"; return 0;
        }
    done
    echo 'Python 3.10-3.15 mit venv erforderlich; Ubuntu 24.04 Python 3.12 passt.' >&2
    echo 'Basis ggf. separat einrichten: sudo apt-get install python3 python3-venv git util-linux' >&2
    return 1
}

af_venv_ready() {
    "$1" -I -c 'import venv, ensurepip; ensurepip.version()' >/dev/null 2>&1
}

af_venv_package() (
    local info version executable ID='' ID_LIKE=''
    [[ -r /etc/os-release ]] || return 1
    # shellcheck source=/dev/null
    source /etc/os-release
    case " $ID $ID_LIKE " in
        *' ubuntu '*|*' debian '*) ;;
        *) return 1 ;;
    esac
    command -v apt-get >/dev/null && command -v dpkg-query >/dev/null || return 1
    info="$("$1" -I -c 'import os, sys; assert sys.prefix == sys.base_prefix; print("%d.%d" % sys.version_info[:2]); print(os.path.realpath(sys.executable))')" || return 1
    version="${info%%$'\n'*}"
    executable="${info#*$'\n'}"
    [[ "$version" =~ ^3\.(10|11|12|13|14|15)$ && "$executable" == "/usr/bin/python$version" ]] || return 1
    dpkg-query -S "$executable" >/dev/null 2>&1 || return 1
    printf 'python%s-venv\n' "$version"
)

af_prepare_venv() {
    local python="$1" package
    af_venv_ready "$python" && return 0
    if [[ "${AGENT_FRAMEWORK_AUTO_VENV:-1}" != 1 ]]; then
        echo 'venv/ensurepip fehlt. Automatische Paket-Reparatur ist deaktiviert (AGENT_FRAMEWORK_AUTO_VENV).' >&2
        return 1
    fi
    package="$(af_venv_package "$python")" || {
        echo 'venv/ensurepip fehlt. Automatische Reparatur nur fuer paketverwaltetes Debian-/Ubuntu-Python unter /usr/bin; eigenes Python separat reparieren.' >&2
        return 1
    }
    echo "Fehlende Python-Basisabhaengigkeit: $package. Installiere gezielt via apt; Framework bleibt GitHub-Quelle."
    command -v sudo >/dev/null && sudo -v || {
        echo 'sudo-Freigabe fehlgeschlagen. Benutzerpasswort/CapsLock pruefen; keine Installation ausgefuehrt.' >&2
        return 1
    }
    # shellcheck source=../../lib/apt_lock_wait.sh
    source "$AF_REPO_ROOT/scripts/lib/apt_lock_wait.sh"
    run_apt_with_lock_wait update || return 1
    run_apt_with_lock_wait install -y --no-install-recommends "$package" || return 1
    af_venv_ready "$python" || {
        echo 'venv/ensurepip ist weiterhin nicht verfuegbar; Abbruch vor GitHub-Download/Build.' >&2
        return 1
    }
}

af_source_ok() {
    [[ -d "$AF_SOURCE/.git" ]] &&
        [[ "$(git -C "$AF_SOURCE" rev-parse --show-toplevel)" == "$AF_SOURCE" ]] &&
        [[ "$(git -C "$AF_SOURCE" remote get-url origin)" == "$AF_URL" ]] &&
        [[ "$(git -C "$AF_SOURCE" rev-parse HEAD)" == "$AF_COMMIT" ]] &&
        [[ -z "$(git -C "$AF_SOURCE" status --porcelain --untracked-files=all)" ]]
}

af_probe() {
    [[ -f "$AF_MARKER" && "$(<"$AF_MARKER")" == "$AF_COMMIT" && -x "$AF_VENV/bin/python" ]] || return 1
    af_source_ok || return 1
    # Metadata only: never import upstream agent/provider code during Doctor.
    "$AF_VENV/bin/python" -I -c \
        'from importlib.metadata import version; assert version("agent-framework-core") == "1.22.0"' &&
        "$AF_VENV/bin/python" -I -m pip --isolated check
}

af_install_source() {
    local python="$1"
    if [[ -e "$AF_SOURCE" ]]; then
        af_source_ok || {
            echo 'Quellordner fremd, veraendert oder anderer Pin. Nichts ueberschrieben.' >&2
            echo 'Ordner manuell sichern/umbenennen, dann erneut installieren.' >&2; return 1;
        }
    else
        mkdir "$AF_SOURCE"
        git -C "$AF_SOURCE" init
        git -C "$AF_SOURCE" remote add origin "$AF_URL"
        GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$AF_SOURCE" fetch --depth 1 origin "$AF_COMMIT"
        git -c core.hooksPath=/dev/null -C "$AF_SOURCE" checkout --detach FETCH_HEAD
        af_source_ok || return 1
    fi
    [[ -f "$AF_SOURCE/python/packages/core/pyproject.toml" ]] || {
        echo 'Gepinntes Python-Core-Paket fehlt; kein Root-/Monorepo-pip-Install.' >&2; return 1;
    }
    if [[ -e "$AF_VENV" && ! -f "$AF_VENV/pyvenv.cfg" ]]; then
        echo 'Vorhandener venv-Ordner ist keine virtuelle Umgebung; nichts ueberschrieben.' >&2; return 1
    fi
    rm -f -- "$AF_MARKER"
    "$python" -I -m venv "$AF_VENV" || {
        echo 'venv fehlgeschlagen. Quelle und Umgebung bleiben erhalten; Log pruefen und --repair erneut aufrufen. Kein System-Python ersetzen.' >&2; return 1;
    }
    # GitHub provides the SDK source; PyPI supplies build/runtime dependencies.
    "$AF_VENV/bin/python" -I -m pip --isolated install --index-url https://pypi.org/simple \
        --disable-pip-version-check --no-cache-dir "$AF_SOURCE/python/packages/core"
    "$AF_VENV/bin/python" -I -m pip --isolated check
    "$AF_VENV/bin/python" -I -c \
        'from importlib.metadata import version; assert version("agent-framework-core") == "1.22.0"'
    printf '%s\n' "$AF_COMMIT" > "$AF_MARKER"
    echo 'Python-Core aus GitHub installiert. Kein Agent, Provider, Docker oder Dienst gestartet.'
}

agent_framework_main() (
    set -euo pipefail
    umask 077
    local action="${1:-install}" python program log
    af_paths || return 1
    case "$action" in
        --dry-run|--plan|plan|--help)
            printf '%s\n' '{"tool":"Microsoft_Agent_Framework","status":"experimental","installed":false,"scope":"github-python-core","docker":false,"agent_start":false}'
            return 0 ;;
        status|--status)
            if af_probe >/dev/null 2>&1; then
                printf '%s\n' '{"installed":true,"scope":"github-python-core"}'
            else
                printf '%s\n' '{"installed":false,"scope":"github-python-core"}'
            fi
            return 0 ;;
        doctor|check|--check)
            af_probe || { echo 'Agent Framework fehlt/ist deaktiviert oder SDK/Quelle inkonsistent. Explizit installieren/--repair verwenden.' >&2; return 1; }
            echo 'SDK-Metadaten und Abhaengigkeiten konsistent; kein Modell-/Agententest.'
            return 0 ;;
        install|update|--repair|uninstall|--uninstall) ;;
        *) echo 'Erlaubt: install, update, --repair, uninstall, --dry-run, status, doctor.' >&2; return 2 ;;
    esac
    [[ "$(uname -s)" == Linux ]] || { echo 'Installation nur auf Linux/WSL durch den Benutzer; hier keine Systemaenderung.' >&2; return 1; }
    [[ "$EUID" != 0 ]] || { echo 'Ohne sudo als normaler Benutzer aufrufen.' >&2; return 1; }
    for program in git flock; do
        command -v "$program" >/dev/null || { echo "$program fehlt; Basis separat einrichten." >&2; return 1; }
    done
    if [[ "$action" != uninstall && "$action" != --uninstall ]]; then
        python="$(af_python)" || return 1
        # shellcheck source=../../lib/resource_check.sh
        source "$AF_REPO_ROOT/scripts/lib/resource_check.sh"
        require_ram_mb 2048
        local mount="$AF_BASE"
        while [[ ! -d "$mount" ]]; do
            mount="${mount%/*}"
            [[ -n "$mount" ]] || mount=/
        done
        REQUIRE_WINDOWS_HOST_FREE_MB=10240 require_disk_mb 2048 "$mount"
    fi
    mkdir -p "$AF_BASE" "$AF_LOGS"
    exec 9>"$AF_BASE/operation.lock"
    flock -n 9 || { echo 'Agent Framework: andere Operation aktiv.' >&2; return 1; }
    log="$(mktemp "$AF_LOGS/agent_framework_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
    exec > >(tee -a "$log") 2>&1
    echo "Agent-Framework-Installer: 2026-10-16-github-python-core-venv-repair; Aktion: $action"
    echo "Quelle: $AF_URL; Commit: $AF_COMMIT; Version: $AF_VERSION"
    trap 'rc=$?; if ((rc != 0)); then echo "Fehler ($rc). Quelle/Daten erhalten; Log: $log. Nach Behebung --repair aufrufen."; fi' EXIT
    if [[ "$action" == uninstall || "$action" == --uninstall ]]; then
        rm -f -- "$AF_MARKER"
        echo 'Setup-Registrierung deaktiviert. Quelle, venv und eigene Projekte bleiben erhalten; keine Dienste geloescht.'
        return 0
    fi
    if [[ "$action" == install ]] && af_probe >/dev/null 2>&1; then
        echo 'Gepinnte Installation bereits konsistent; nichts erneut installiert.'; return 0
    fi
    af_prepare_venv "$python" || return 1
    echo 'Update baut denselben geprueften Pin; kein automatisches latest/main-Upgrade.'
    af_install_source "$python"
)
