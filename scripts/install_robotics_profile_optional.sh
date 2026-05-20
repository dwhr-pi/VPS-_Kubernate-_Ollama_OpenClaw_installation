#!/usr/bin/env bash
set -euo pipefail

echo "Robotertechnik & Anlagensteuerung - optionale Diagnose"
echo "Dieses Skript installiert ROS 2, Gazebo oder MoveIt 2 nicht ungefragt."
echo
echo "System:"
uname -a
echo
echo "Ubuntu/Distribution:"
lsb_release -a 2>/dev/null || cat /etc/os-release 2>/dev/null || true
echo
echo "WSL:"
grep -qi microsoft /proc/version 2>/dev/null && echo "WSL erkannt" || echo "Kein WSL-Hinweis erkannt"
echo
echo "Architektur:"
uname -m
echo
echo "Speicherplatz:"
df -h "$HOME" | sed -n '1,2p'
echo
echo "Vorhandene Programme:"
for cmd in ros2 gz gazebo rviz2 mosquitto_pub mosquitto_sub node-red n8n docker; do
    if command -v "$cmd" >/dev/null 2>&1; then
        printf '  [OK] %s -> %s\n' "$cmd" "$(command -v "$cmd")"
    else
        printf '  [--] %s nicht gefunden\n' "$cmd"
    fi
done
echo
echo "Empfehlung: ROS 2 nur nach offizieller Anleitung und passend zur Ubuntu-Version installieren."
echo "Standard bleibt Dokumentation/Diagnose. Keine riskante Real-Hardware-Installation ohne Nachfrage."
