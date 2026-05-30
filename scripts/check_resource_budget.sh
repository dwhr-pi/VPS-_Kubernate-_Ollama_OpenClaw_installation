#!/usr/bin/env bash
set -euo pipefail

MIN_RAM_MB="${MIN_RAM_MB:-4096}"
MIN_DISK_MB="${MIN_DISK_MB:-20480}"
MIN_SWAP_MB="${MIN_SWAP_MB:-1024}"
TARGET_PATH="${TARGET_PATH:-/}"

echo "Resource-Budget-Check"

mem_mb="$(awk '/MemAvailable:/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)"
swap_mb="$(awk '/SwapFree:/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)"
disk_mb="$(df -Pm "$TARGET_PATH" 2>/dev/null | awk 'NR==2 {print $4}' || echo 0)"

echo "RAM verfuegbar: ${mem_mb} MB"
echo "Swap frei: ${swap_mb} MB"
echo "Disk frei (${TARGET_PATH}): ${disk_mb} MB"

if grep -qi microsoft /proc/version 2>/dev/null && [[ -d /mnt/c ]]; then
  win_mb="$(df -Pm /mnt/c 2>/dev/null | awk 'NR==2 {print $4}' || echo 0)"
  echo "WSL erkannt. Windows-C:-frei: ${win_mb} MB"
  if [[ "$win_mb" -lt 20480 ]]; then
    echo "WARN: Windows-C: hat weniger als 20 GB frei. WSL-VHDX-Wachstum kann Installationen abbrechen."
  fi
fi

rc=0
if [[ "$mem_mb" -lt "$MIN_RAM_MB" ]]; then
  echo "WARN: Low-RAM erkannt. Empfohlen mindestens ${MIN_RAM_MB} MB."
  rc=1
fi
if [[ "$disk_mb" -lt "$MIN_DISK_MB" ]]; then
  echo "WARN: Low-Disk erkannt. Empfohlen mindestens ${MIN_DISK_MB} MB."
  rc=1
fi
if [[ "$swap_mb" -lt "$MIN_SWAP_MB" ]]; then
  echo "WARN: Wenig Swap frei. Empfohlen mindestens ${MIN_SWAP_MB} MB."
fi

exit "$rc"

