#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
source "$ROOT_DIR/scripts/tools/helpers/simple_tool_common.sh"
source "$ROOT_DIR/scripts/lib/isolated_cpython.sh"

rife_python_ok() {
  "$1" -c 'import sys; sys.exit(0 if (3,10) <= sys.version_info[:2] < (3,12) else 1)' >/dev/null 2>&1
}

rife_find_python() {
  local candidate
  if [ -n "${RIFE_PYTHON_BIN:-}" ]; then
    if command -v "$RIFE_PYTHON_BIN" >/dev/null 2>&1 && rife_python_ok "$RIFE_PYTHON_BIN"; then
      command -v "$RIFE_PYTHON_BIN"
      return 0
    fi
    log_error 'RIFE_PYTHON_BIN muss auf Python 3.10/3.11 zeigen.' >&2
    return 1
  fi
  for candidate in python3.11 python3.10 python3 /opt/openclaw-python/python-3.11.*/bin/python3.11; do
    if command -v "$candidate" >/dev/null 2>&1 && rife_python_ok "$candidate"; then
      command -v "$candidate"
      return 0
    fi
  done
  log_error 'RIFE: Python 3.10/3.11 fehlt. Python 3.12 ist fuer die NumPy-Vorgabe ungeeignet; RIFE_PYTHON_BIN setzen.' >&2
  return 1
}

rife_prepare_venv() {
  local python_bin="$1" dir="$2" backup
  if [ -L "$dir/.venv" ]; then
    log_error '.venv ist ein Symlink; manuell pruefen.'
    return 1
  fi
  if [ -e "$dir/.venv" ]; then
    if [ -x "$dir/.venv/bin/python" ] && rife_python_ok "$dir/.venv/bin/python"; then return 0; fi
    backup="$(mktemp -d "$dir/venv-backup.XXXXXXXX")" || return 1
    mv -- "$dir/.venv" "$backup/.venv" || return 1
    log_info "Alte RIFE-Umgebung gesichert: $backup/.venv"
  fi
  "$python_bin" -m venv "$dir/.venv"
}

rife_main() {
  local mode="${1:-install}" python_bin dir=/opt/rife
  local torch_index="${RIFE_TORCH_INDEX_URL:-https://download.pytorch.org/whl/cpu}"
  case "$mode" in install | --check | --dry-run) ;; *)
    log_error "Unbekannte Option: $mode"
    return 2
    ;;
  esac
  python_bin=""
  if ! python_bin="$(rife_find_python)"; then
    # An explicitly requested interpreter must never be silently replaced.
    [ -z "${RIFE_PYTHON_BIN:-}" ] || return 1
    if [ "$mode" = --check ]; then return 1; fi
    if [ "$mode" = --dry-run ]; then
      log_info 'Plan: Nach Heavy-Opt-in/Speicherpruefung CPython 3.11.17 aus GitHub isoliert bauen; kein Build im Dry-Run.'
      return 0
    fi
  fi
  log_info "RIFE-Python: $python_bin; PyTorch-Quelle: $torch_index"
  if [ "$mode" != install ]; then
    log_info 'Plan: GitHub-Quelle, kompatible .venv, NumPy nur als Wheel; keine Modell-Downloads.'
    return 0
  fi
  confirm_heavy_install RIFE || return 0
  AUTO_INSTALL_TOOL_BASE_DEPS=false begin_measurement tool_install_RIFE 'RIFE mit kompatiblem Python'
  if ! REQUIRE_WINDOWS_HOST_FREE_MB=20480 require_disk_mb 40960 /opt; then
    end_measurement failed
    return 1
  fi
  if [ -z "$python_bin" ]; then
    if ! python_bin="$(build_isolated_cpython311)" || ! rife_python_ok "$python_bin"; then
      log_error 'RIFE: Isoliertes Python konnte nicht bereitgestellt werden.'
      end_measurement failed
      return 1
    fi
  fi
  if ! ensure_base_apt_packages git ca-certificates libgl1 libglib2.0-0 ||
    ! sudo mkdir -p "$dir" || ! sudo chown "$USER:$USER" "$dir" ||
    ! clone_or_update_git_target RIFE https://github.com/hzwer/ECCV2022-RIFE.git "$dir" ||
    ! rife_prepare_venv "$python_bin" "$dir"; then
    end_measurement failed
    return 1
  fi
  if [ ! -f "$dir/requirements.txt" ]; then
    log_error 'RIFE requirements.txt fehlt; Upstream-Layout pruefen.'
    end_measurement failed
    return 1
  fi
  if ! "$dir/.venv/bin/python" -m pip install torch torchvision --index-url "$torch_index" ||
    ! "$dir/.venv/bin/python" -m pip install --only-binary=numpy -r "$dir/requirements.txt" ||
    ! "$dir/.venv/bin/python" -c 'import numpy, cv2, torch, torchvision; assert (1,16,0) <= tuple(map(int, numpy.__version__.split("."))) <= (1,23,5)'; then
    log_error 'RIFE-Abhaengigkeiten fehlgeschlagen. Kein automatischer NumPy-Source-Build; Python/Wheel-Angebot/Resolver-Log pruefen.'
    end_measurement failed
    return 1
  fi
  mark_tool_installed RIFE
  end_measurement success
  log_info 'RIFE vorbereitet; Modellgewichte separat bereitstellen. GPU-/Interpolationstest steht noch aus.'
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  rife_main "$@"
fi
