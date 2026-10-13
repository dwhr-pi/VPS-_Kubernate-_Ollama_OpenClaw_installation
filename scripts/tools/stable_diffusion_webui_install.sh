#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
TOOL_DIR="/opt/stable-diffusion-webui"
REPO_URL="${STABLE_DIFFUSION_WEBUI_REPO_URL:-https://github.com/AUTOMATIC1111/stable-diffusion-webui.git}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
# shellcheck source=helpers/simple_tool_common.sh
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

sd_webui_python_ok() {
    "$1" -c 'import sys; sys.exit(0 if (3,10) <= sys.version_info[:2] < (3,12) else 1)' >/dev/null 2>&1
}

sd_webui_find_python() {
    local candidate
    if [ -n "${SD_WEBUI_PYTHON_BIN:-}" ]; then
        if command -v "$SD_WEBUI_PYTHON_BIN" >/dev/null 2>&1 && sd_webui_python_ok "$SD_WEBUI_PYTHON_BIN"; then
            command -v "$SD_WEBUI_PYTHON_BIN"; return 0
        fi
        log_error 'SD_WEBUI_PYTHON_BIN muss auf Python 3.10/3.11 zeigen.' >&2
        return 1
    fi
    for candidate in python3.10 python3.11 python3 /opt/openclaw-python/python-3.11.*/bin/python3.11; do
        if command -v "$candidate" >/dev/null 2>&1 && sd_webui_python_ok "$candidate"; then
            command -v "$candidate"; return 0
        fi
    done
    log_error 'Kein Python 3.10/3.11 gefunden. Python 3.12 wird vor Installation abgelehnt; SD_WEBUI_PYTHON_BIN auf kompatibles Python setzen.' >&2
    return 1
}

sd_webui_prepare_venv() {
    local python_bin="$1" backup_dir
    if [ -L "$TOOL_DIR/venv" ]; then
        log_error 'venv ist ein Symlink; Umgebung vor Neuaufbau manuell pruefen.'
        return 1
    fi
    if [ -e "$TOOL_DIR/venv" ]; then
        if [ -x "$TOOL_DIR/venv/bin/python" ] && sd_webui_python_ok "$TOOL_DIR/venv/bin/python"; then
            return 0
        fi
        backup_dir="$(mktemp -d "$TOOL_DIR/venv-backup.XXXXXXXX")" || return 1
        mv -- "$TOOL_DIR/venv" "$backup_dir/venv" || return 1
        log_info "Inkompatible/abgebrochene venv gesichert: $backup_dir/venv"
    fi
    "$python_bin" -m venv "$TOOL_DIR/venv"
}

sd_webui_main() {
    local mode="${1:-install}" python_bin
    case "$mode" in install|--check|--dry-run) ;; *) log_error "Unbekannte Option: $mode"; return 2 ;; esac
    python_bin="$(sd_webui_find_python)" || return 1
    log_info "Stable Diffusion WebUI Python: $python_bin"
    if [ "$mode" != install ]; then
        log_info 'Plan: kompatible venv, Upstream launch.py --exit; keine WebUI starten.'
        return 0
    fi
    AUTO_INSTALL_TOOL_BASE_DEPS=false begin_measurement tool_install_Stable_Diffusion_WebUI 'Stable Diffusion WebUI vorbereiten'
    if ! require_disk_mb 40960 /opt || ! ensure_base_apt_packages git ca-certificates build-essential libgl1 libglib2.0-0 ||
       ! sudo mkdir -p "$TOOL_DIR" || ! sudo chown "$USER:$USER" "$TOOL_DIR" ||
       ! clone_or_update_git_target Stable_Diffusion_WebUI "$REPO_URL" "$TOOL_DIR" ||
       ! sd_webui_prepare_venv "$python_bin"; then
        end_measurement failed; return 1
    fi
    if [ ! -f "$TOOL_DIR/launch.py" ]; then
        log_error 'launch.py fehlt. Upstream-Layout pruefen.'
        end_measurement failed; return 1
    fi
    if ! (cd "$TOOL_DIR" && venv/bin/python launch.py --exit --skip-torch-cuda-test --no-download-sd-model --disable-all-extensions) ||
       ! "$TOOL_DIR/venv/bin/python" -c 'import torch, torchvision, PIL, tokenizers'; then
        log_error 'WebUI-Vorbereitung fehlgeschlagen; kein Erfolgsstatus. Python-, Wheel- und Downloadfehler im Log pruefen.'
        end_measurement failed; return 1
    fi
    mark_tool_installed Stable_Diffusion_WebUI
    end_measurement success
    log_info "WebUI vorbereitet. Manueller Start: cd $TOOL_DIR && venv/bin/python launch.py --server-name 127.0.0.1 --no-download-sd-model"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    sd_webui_main "$@"
fi
