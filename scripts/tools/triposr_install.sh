#!/usr/bin/env bash
set -euo pipefail

START_TS="$(date +%s)"
INSTALL_ROOT="${TRIPOSR_INSTALL_ROOT:-/opt/triposr}"
REPO_URL="${TRIPOSR_REPO:-https://github.com/VAST-AI-Research/TripoSR}"
LOG_FILE="${HOME}/.openclaw_ultimate_user_data/install_logs/triposr_manual.log"

mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starte TripoSR Vorbereitung..."
df -h "$HOME" || true

if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y git python3 python3-venv python3-pip ffmpeg
fi

if [ -d "$INSTALL_ROOT/.git" ]; then
  git -C "$INSTALL_ROOT" pull --ff-only
else
  sudo mkdir -p "$(dirname "$INSTALL_ROOT")"
  sudo chown "$USER":"$USER" "$(dirname "$INSTALL_ROOT")"
  git clone "$REPO_URL" "$INSTALL_ROOT"
fi

python3 -m venv "$INSTALL_ROOT/venv"
"$INSTALL_ROOT/venv/bin/python" -m pip install --upgrade pip wheel setuptools

if [ "${AI3D_INSTALL_PY_DEPS:-0}" = "1" ] && [ -f "$INSTALL_ROOT/requirements.txt" ]; then
  "$INSTALL_ROOT/venv/bin/pip" install -r "$INSTALL_ROOT/requirements.txt"
else
  echo "Python-Abhaengigkeiten wurden nicht automatisch installiert."
  echo "Setze AI3D_INSTALL_PY_DEPS=1, wenn du TripoSR requirements bewusst installieren willst."
fi

echo "Keine TripoSR-Modelle automatisch geladen."
echo "Repo: $INSTALL_ROOT"
echo "Log: $LOG_FILE"
echo "Dauer: $(($(date +%s) - START_TS)) Sekunden"

