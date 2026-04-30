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
  echo "RAM gesamt (MB): $(snapshot_ram_mb)"
  echo "CPU-Kerne: $(snapshot_cpu_cores)"
  echo "GPU/VRAM:"
  snapshot_gpu_summary
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
