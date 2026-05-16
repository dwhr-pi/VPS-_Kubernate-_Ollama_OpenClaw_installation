#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

PROFILE_DIR="$HOME/.openclaw_ultimate_user_data/profiles/jarvis-fritzbox-alexa-homeassistant"

echo "Deinstalliere Profilstatus: Jarvis FritzBox Alexa Home Assistant"
echo "Hinweis: Geteilte Dienste wie Home Assistant, MQTT, Node-RED, Ollama und OpenClaw werden nicht automatisch entfernt."

if [ -d "$PROFILE_DIR" ]; then
  echo "Lokale Profilkonfiguration bleibt erhalten: $PROFILE_DIR"
  echo "Loesche sie nur manuell, wenn keine Telefonie-/Smart-Home-Notizen mehr benoetigt werden."
fi

mark_profile_removed "Jarvis_FritzBox_Alexa_Home_Assistant"
