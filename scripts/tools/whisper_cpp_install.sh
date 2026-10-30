#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

install_whisper_cpp() {
  local tool_dir="/opt/whisper_cpp"
  local jobs="${WHISPER_CPP_BUILD_JOBS:-2}"
  if ! [[ "$jobs" =~ ^[1-9][0-9]{0,2}$ ]]; then
    log_error "WHISPER_CPP_BUILD_JOBS muss eine positive ganze Zahl (1-999) sein."
    return 2
  fi

  begin_measurement "tool_install_Whisper_CPP" "Whisper.cpp CPU-Build aus GitHub"
  if ! ensure_user_workspace || ! require_disk_mb 2048 /opt; then
    end_measurement "failed"
    return 1
  fi
  log_info "Whisper.cpp: CMake-CPU-Build mit ${jobs} parallelen Jobs; keine Modell-Downloads."
  if ! ensure_base_apt_packages git build-essential cmake; then
    end_measurement "failed"
    return 1
  fi
  if ! sudo mkdir -p "$tool_dir" || ! sudo chown "$USER:$USER" "$tool_dir"; then
    end_measurement "failed"
    return 1
  fi
  if ! clone_or_update_git_target "Whisper_CPP" "https://github.com/ggml-org/whisper.cpp.git" "$tool_dir"; then
    end_measurement "failed"
    return 1
  fi
  if ! cmake -S "$tool_dir" -B "$tool_dir/build" -DCMAKE_BUILD_TYPE=Release -DGGML_CUDA=OFF ||
    ! cmake --build "$tool_dir/build" --config Release --parallel "$jobs"; then
    log_error "Whisper.cpp-Build fehlgeschlagen. CMake/Compiler und RAM pruefen; ggf. WHISPER_CPP_BUILD_JOBS=1 setzen."
    end_measurement "failed"
    return 1
  fi
  if ! "$tool_dir/build/bin/whisper-cli" --help >/dev/null 2>&1; then
    log_error "Whisper.cpp Smoke-Test fehlgeschlagen: build/bin/whisper-cli --help"
    end_measurement "failed"
    return 1
  fi
  mark_tool_installed "Whisper_CPP"
  log_success "Whisper.cpp installiert: ${tool_dir}/build/bin/whisper-cli"
  end_measurement "success"
}

install_whisper_cpp
