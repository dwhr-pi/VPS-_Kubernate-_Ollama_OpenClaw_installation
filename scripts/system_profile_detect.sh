#!/usr/bin/env bash
set -euo pipefail

is_wsl() {
  grep -qiE "microsoft|wsl" /proc/version 2>/dev/null || [ -n "${WSL_DISTRO_NAME:-}" ]
}

print_cmd_version() {
  local label="$1"
  local cmd="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '%-24s %s\n' "$label:" "$($cmd --version 2>/dev/null | head -n 1 || echo vorhanden)"
  else
    printf '%-24s %s\n' "$label:" "nicht gefunden"
  fi
}

mem_total_mb() {
  awk '/^MemTotal:/ {printf "%d", $2 / 1024}' /proc/meminfo 2>/dev/null || echo 0
}

swap_total_mb() {
  awk '/^SwapTotal:/ {printf "%d", $2 / 1024}' /proc/meminfo 2>/dev/null || echo 0
}

free_mb_for_path() {
  df -Pm "${1:-/}" 2>/dev/null | awk 'NR==2 {print $4}'
}

gpu_summary() {
  if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>/dev/null || true
    return 0
  fi
  if command -v lspci >/dev/null 2>&1; then
    lspci 2>/dev/null | grep -Ei 'vga|3d|display' || true
    return 0
  fi
  echo "keine GPU-Erkennung verfuegbar"
}

systemd_state() {
  if command -v systemctl >/dev/null 2>&1; then
    systemctl is-system-running 2>/dev/null || true
  else
    echo "systemctl nicht gefunden"
  fi
}

echo "OpenClaw Ultimate Setup - Systemprofil"
echo "======================================"
printf '%-24s %s\n' "Datum:" "$(date -Is 2>/dev/null || date)"
printf '%-24s %s\n' "Kernel:" "$(uname -srmo 2>/dev/null || uname -a)"
printf '%-24s %s\n' "Architektur:" "$(uname -m)"
if [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  printf '%-24s %s\n' "Distribution:" "${PRETTY_NAME:-unbekannt}"
fi
if is_wsl; then
  printf '%-24s %s\n' "WSL2:" "ja"
else
  printf '%-24s %s\n' "WSL2:" "nicht erkannt"
fi
printf '%-24s %s MB\n' "RAM gesamt:" "$(mem_total_mb)"
printf '%-24s %s MB\n' "Swap gesamt:" "$(swap_total_mb)"
printf '%-24s %s MB\n' "Freier Linux-Speicher:" "$(free_mb_for_path /)"
if [ -d /mnt/c ]; then
  printf '%-24s %s MB\n' "Freier Windows C:" "$(free_mb_for_path /mnt/c)"
fi
printf '%-24s %s\n' "systemd:" "$(systemd_state)"
print_cmd_version "Node.js" "node"
print_cmd_version "npm" "npm"
print_cmd_version "pnpm" "pnpm"
print_cmd_version "Docker" "docker"
print_cmd_version "Podman" "podman"
print_cmd_version "Git" "git"
echo
echo "GPU/Display:"
gpu_summary
echo
echo "Einordnung:"
if [ "$(mem_total_mb)" -lt 8192 ]; then
  echo "- Nur leichte Profile empfehlen: Core, Security-Checks, Doku, kleine RAG-Tests."
elif [ "$(mem_total_mb)" -lt 16384 ]; then
  echo "- Mittlere Profile moeglich; schwere Docker-/GPU-/Airbyte-Stacks nur einzeln und mit Speicherwache."
else
  echo "- Fortgeschrittene Profile moeglich; trotzdem GPU-, Kubernetes- und Airbyte-Stapel nicht automatisch installieren."
fi
if is_wsl; then
  echo "- WSL2 erkannt: Windows-Host-Speicher auf C: vor grossen Downloads immer mitpruefen."
fi
