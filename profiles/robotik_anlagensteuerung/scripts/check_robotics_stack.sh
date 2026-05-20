#!/usr/bin/env bash
set -euo pipefail

check() {
    if command -v "$1" >/dev/null 2>&1; then
        printf '[OK] %s: %s\n' "$1" "$(command -v "$1")"
    else
        printf '[HINWEIS] %s nicht gefunden\n' "$1"
    fi
}

echo "Robotik/Anlagensteuerung Diagnose"
echo "OS: $(uname -a)"
df -h "$HOME" | sed -n '1,2p'

check ros2
check gz
check gazebo
check rviz2
check mosquitto_pub
check mosquitto_sub
check node-red
check n8n
check curl

if command -v curl >/dev/null 2>&1 && curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "[OK] Ollama erreichbar"
else
    echo "[HINWEIS] Ollama nicht erreichbar oder nicht gestartet"
fi
