#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

forge_python_ok() {
  "$1" -c 'import sys; sys.exit(0 if (3,10) <= sys.version_info[:2] < (3,12) else 1)' >/dev/null 2>&1
}

forge_find_python() {
  local candidate
  if [ -n "${FORGE_PYTHON_BIN:-}" ]; then
    if command -v "$FORGE_PYTHON_BIN" >/dev/null 2>&1 && forge_python_ok "$FORGE_PYTHON_BIN"; then
      command -v "$FORGE_PYTHON_BIN"; return 0
    fi
    log_error 'FORGE_PYTHON_BIN ist nicht nutzbar oder nicht Python 3.10/3.11.' >&2
    return 1
  fi
  for candidate in python3.10 python3.11 python3 /opt/openclaw-python/python-3.11.*/bin/python3.11; do
    if command -v "$candidate" >/dev/null 2>&1 && forge_python_ok "$candidate"; then
      command -v "$candidate"; return 0
    fi
  done
  log_error 'Forge benoetigt Python 3.10/3.11. FORGE_PYTHON_BIN auf einen kompatiblen Interpreter setzen; System-Python bleibt unveraendert.' >&2
  return 1
}

forge_main() {
  local mode="${1:-install}" python_bin dir=/opt/stable_diffusion_webui_forge
  case "$mode" in
    install|--check|--dry-run) ;;
    *) log_error "Unbekannte Option: $mode"; return 2 ;;
  esac
  python_bin="$(forge_find_python)" || return 1
  log_info "Forge-Python: $python_bin"
  if [ "$mode" != install ]; then
    log_info 'Plan: GitHub-Clone, separate venv, launch.py --exit; kein pip install -e auf dem Repo-Root.'
    return 0
  fi
  AUTO_INSTALL_TOOL_BASE_DEPS=false begin_measurement tool_install_Stable_Diffusion_WebUI_Forge 'Forge Upstream-Vorbereitung'
  if ! require_disk_mb 40960 /opt || ! ensure_base_apt_packages git ca-certificates libgl1 libglib2.0-0 build-essential; then
    end_measurement failed; return 1
  fi
  if ! sudo mkdir -p "$dir" || ! sudo chown "$USER:$USER" "$dir" ||
     ! clone_or_update_git_target Stable_Diffusion_WebUI_Forge https://github.com/lllyasviel/stable-diffusion-webui-forge.git "$dir"; then
    end_measurement failed; return 1
  fi
  # Preserve the old .venv from the failed generic installer.
  if [ -e "$dir/venv" ]; then
    if [ ! -x "$dir/venv/bin/python" ] || ! forge_python_ok "$dir/venv/bin/python"; then
      log_error 'Vorhandene Forge-venv ist inkompatibel. Vor manuellem Neuaufbau sichern; keine automatische Loeschung.'
      end_measurement failed; return 1
    fi
  elif ! "$python_bin" -m venv "$dir/venv"; then
    log_error 'venv-Erstellung fehlgeschlagen. venv/ensurepip fuer den gewaehlten Interpreter pruefen.'
    end_measurement failed; return 1
  fi
  if [ ! -f "$dir/launch.py" ]; then
    log_error 'Forge launch.py fehlt; Upstream-Layout pruefen.'
    end_measurement failed; return 1
  fi
  if ! (cd "$dir" && "$dir/venv/bin/python" launch.py --exit --skip-torch-cuda-test --no-download-sd-model --disable-all-extensions); then
    log_error 'Forge-Vorbereitung fehlgeschlagen. Python/PyTorch, Speicherplatz und Download-Log pruefen.'
    end_measurement failed; return 1
  fi
  if ! "$dir/venv/bin/python" -c 'import torch, torchvision, gradio'; then
    log_error 'Forge-Abhaengigkeits-Smoke-Test fehlgeschlagen.'
    end_measurement failed; return 1
  fi
  mark_tool_installed Stable_Diffusion_WebUI_Forge
  end_measurement success
  log_info "Forge vorbereitet. Manueller Start: cd $dir && venv/bin/python launch.py --server-name 127.0.0.1 --no-download-sd-model"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  forge_main "$@"
fi
