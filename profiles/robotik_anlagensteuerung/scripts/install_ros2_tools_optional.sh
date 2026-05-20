#!/usr/bin/env bash
set -euo pipefail

echo "Dieses Skript installiert ROS 2 nicht automatisch."
echo "Es prueft nur Umgebung und verweist auf die offizielle ROS-2-Dokumentation."
echo
echo "Ubuntu-Version:"
lsb_release -a 2>/dev/null || true
echo
echo "WSL-Erkennung:"
grep -qi microsoft /proc/version 2>/dev/null && echo "WSL erkannt" || echo "Kein WSL-Hinweis erkannt"
echo
echo "Freier Speicher:"
df -h "$HOME" | sed -n '1,2p'
echo
echo "Naechster Schritt: offizielle ROS-2-Installationsanleitung passend zur Ubuntu-Version pruefen."
