#!/usr/bin/env bash
set -euo pipefail
MUSICGEN_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$MUSICGEN_SCRIPT_DIR/../lib/resource_check.sh"
# shellcheck disable=SC1091
source "$MUSICGEN_SCRIPT_DIR/helpers/simple_tool_common.sh"

musicgen_python_ok() {
  "$1" -c 'import sys; sys.exit(0 if (3,10) <= sys.version_info[:2] < (3,12) else 1)' >/dev/null 2>&1
}

musicgen_find_python() {
  local candidate
  if [[ -n "${MUSICGEN_PYTHON_BIN:-}" ]]; then
    if command -v "$MUSICGEN_PYTHON_BIN" >/dev/null && musicgen_python_ok "$MUSICGEN_PYTHON_BIN"; then
      command -v "$MUSICGEN_PYTHON_BIN"
      return 0
    fi
    echo 'Fehler: MUSICGEN_PYTHON_BIN muss auf Python 3.10/3.11 zeigen.' >&2
    return 1
  fi
  for candidate in python3.11 python3.10 python3 /opt/openclaw-python/python-3.11.*/bin/python3.11; do
    if command -v "$candidate" >/dev/null && musicgen_python_ok "$candidate"; then
      command -v "$candidate"
      return 0
    fi
  done
  echo 'Fehler: MusicGen Python 3.10/3.11 fehlt. MUSICGEN_PYTHON_BIN setzen; System-Python bleibt unveraendert.' >&2
  return 1
}

musicgen_check_budget() {
  local free_mb win_free_mb
  free_mb="$(snapshot_disk_mb /opt)" || return 1
  if ! [[ "$free_mb" =~ ^[0-9]+$ ]] || ((free_mb < 40960)); then
    echo 'Fehler: MusicGen Setup-Reserve: mindestens 40 GiB frei auf /opt.' >&2
    return 1
  fi
  win_free_mb="$(snapshot_windows_host_disk_mb 2>/dev/null || true)"
  if [[ -n "$win_free_mb" ]] && { ! [[ "$win_free_mb" =~ ^[0-9]+$ ]] || ((win_free_mb < 20480)); }; then
    echo "Fehler: MusicGen Windows-C:-Reserve: mindestens 20 GiB; gefunden $win_free_mb MB." >&2
    return 1
  fi
}

musicgen_prepare_venv() {
  local python_bin="$1" dir="$2" backup
  if [[ -L "$dir/venv" ]]; then
    echo 'Fehler: MusicGen venv ist ein Symlink.' >&2
    return 1
  fi
  if [[ -e "$dir/venv" ]]; then
    if [[ -x "$dir/venv/bin/python" ]] && musicgen_python_ok "$dir/venv/bin/python"; then return 0; fi
    backup="$(mktemp -d "$dir/venv-backup.XXXXXXXX")" || return 1
    mv -- "$dir/venv" "$backup/venv" || return 1
    echo "Alte MusicGen-Umgebung gesichert: $backup/venv"
  fi
  "$python_bin" -m venv "$dir/venv"
}

musicgen_install_packages() {
  local python_bin="$1"
  if ! "$python_bin" -m pip install 'pip==24.3.1' 'setuptools==69.5.1' 'wheel==0.45.1' ||
    ! "$python_bin" -m pip install --only-binary=torch 'torch==2.1.0' 'numpy<2' ||
    ! "$python_bin" -m pip install 'audiocraft @ git+https://github.com/facebookresearch/audiocraft.git@v1.3.0' 'numpy<2' ||
    ! "$python_bin" -m pip check ||
    ! "$python_bin" -c 'import av, torch, audiocraft; from audiocraft.models import MusicGen'; then
    echo 'Fehler: MusicGen/PyAV-Pakete oder Import fehlgeschlagen. Python, FFmpeg/pkg-config und Resolver-Log pruefen.' >&2
    return 1
  fi
}

musicgen_main() {
  local mode="${1:-install}" python_bin dir=/opt/musicgen
  case "$mode" in install | --check | --dry-run) ;; *)
    echo 'Aufruf: musicgen_install.sh [--check|--dry-run]' >&2
    return 2
    ;;
  esac
  echo 'MusicGen: experimentell; Python 3.10/3.11, GitHub AudioCraft v1.3.0, schwere PyTorch-Pakete. Keine Modell-Downloads.'
  musicgen_check_budget || return 1
  python_bin="$(musicgen_find_python)" || return 1
  if [[ "$mode" != install ]]; then
    echo "Vorpruefung bestanden: $python_bin. Kein Download, Build oder Dienststart."
    return 0
  fi
  confirm_heavy_install MusicGen || return 0
  AUTO_INSTALL_TOOL_BASE_DEPS=false begin_measurement tool_install_MusicGen 'MusicGen Python/FFmpeg Build'
  if [[ -L "$dir" ]]; then
    end_measurement failed
    return 1
  fi
  if ! ensure_base_apt_packages git build-essential pkg-config ffmpeg libavformat-dev libavcodec-dev libavdevice-dev libavutil-dev libavfilter-dev libswscale-dev libswresample-dev ||
    ! pkg-config --exists libavformat libavcodec libavdevice libavutil libavfilter libswscale libswresample ||
    ! sudo mkdir -p "$dir" || ! sudo chown "$(id -un):$(id -gn)" "$dir" ||
    ! musicgen_prepare_venv "$python_bin" "$dir" ||
    ! musicgen_install_packages "$dir/venv/bin/python"; then
    echo 'Fehler: MusicGen nicht fertig installiert. Log pruefen; alte Umgebung bleibt als Backup erhalten.' >&2
    end_measurement failed
    return 1
  fi
  mark_tool_installed MusicGen
  end_measurement success
  echo 'MusicGen-Pakete und Import-Test erfolgreich. Modell-/GPU-/Audiotest noch separat erforderlich.'
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then musicgen_main "$@"; fi
