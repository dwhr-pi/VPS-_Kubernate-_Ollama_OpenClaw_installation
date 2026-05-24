#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

print_resource_summary() {
  local path="${1:-/}"
  ensure_user_workspace
  log_info "Ressourcenübersicht für ${path}"
  echo "Freier Speicher (MB): $(snapshot_disk_mb "$path")"
  print_windows_host_disk_summary
  echo "RAM gesamt (MB): $(snapshot_ram_mb)"
  echo "CPU-Kerne: $(snapshot_cpu_cores)"
  echo "GPU/VRAM:"
  snapshot_gpu_summary
}

is_wsl_environment() {
  grep -qiE "microsoft|wsl" /proc/version 2>/dev/null || [ -n "${WSL_DISTRO_NAME:-}" ]
}

snapshot_windows_host_disk_mb() {
  if ! is_wsl_environment || [ ! -d /mnt/c ]; then
    return 1
  fi

  df -Pm /mnt/c 2>/dev/null | awk 'NR==2 {print $4}'
}

print_windows_host_disk_summary() {
  local windows_free_mb
  windows_free_mb="$(snapshot_windows_host_disk_mb 2>/dev/null || true)"
  if [ -n "$windows_free_mb" ]; then
    echo "Freier Windows-Host-Speicher C: (MB): ${windows_free_mb}"
  fi
}

check_windows_host_disk_watch() {
  local hard_min_mb="${REQUIRE_WINDOWS_HOST_FREE_MB:-}"
  local warn_min_mb="${WINDOWS_HOST_WARN_FREE_MB:-10240}"
  local windows_free_mb

  if [ "${CHECK_WINDOWS_HOST_FREE_SPACE:-true}" != "true" ]; then
    return 0
  fi

  windows_free_mb="$(snapshot_windows_host_disk_mb 2>/dev/null || true)"
  if [ -z "$windows_free_mb" ]; then
    return 0
  fi

  log_info "Freier Windows-Host-Speicher C: ${windows_free_mb} MB"

  if [ -n "$hard_min_mb" ] && [ "$windows_free_mb" -lt "$hard_min_mb" ]; then
    log_error "Zu wenig freier Windows-Host-Speicher. Erforderlich: ${hard_min_mb} MB, verfügbar: ${windows_free_mb} MB."
    log_error "Unter WSL können Linux-Downloads, Docker-Images und Build-Caches die Windows-Partition füllen."
    exit 1
  fi

  if [ "$windows_free_mb" -lt "$warn_min_mb" ]; then
    log_warn "Warnung: Windows-Host-Speicher C: ist niedrig (${windows_free_mb} MB frei)."
    log_warn "Unter WSL kann Linux mehr freien Speicher melden, obwohl die echte Windows-SSD fast voll ist."
  fi
}

require_disk_mb() {
  local min_mb="$1"
  local path="${2:-/}"
  local free_mb
  free_mb="$(snapshot_disk_mb "$path")"
  if [ "$free_mb" -lt "$min_mb" ]; then
    log_error "Zu wenig freier Speicher. Erforderlich: ${min_mb} MB, verfügbar: ${free_mb} MB."
    exit 1
  fi
  check_windows_host_disk_watch
}

require_ram_mb() {
  local min_mb="$1"
  local total_mb
  total_mb="$(snapshot_ram_mb)"
  if [ "$total_mb" -lt "$min_mb" ]; then
    log_error "Zu wenig RAM. Erforderlich: ${min_mb} MB, verfügbar: ${total_mb} MB."
    exit 1
  fi
}

warn_if_no_gpu() {
  if ! command -v nvidia-smi >/dev/null 2>&1 && ! command -v rocminfo >/dev/null 2>&1; then
    log_warn "Warnung: Keine GPU/VRAM-Erkennung verfügbar. GPU-lastige Profile können sehr langsam sein."
  fi
}

if [ "${1:-}" = "--summary" ]; then
  print_resource_summary "${2:-/}"
fi
