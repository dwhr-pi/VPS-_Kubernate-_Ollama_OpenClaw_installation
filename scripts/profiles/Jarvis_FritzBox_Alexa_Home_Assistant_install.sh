#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

PROFILE_DIR="$HOME/.openclaw_ultimate_user_data/profiles/jarvis-fritzbox-alexa-homeassistant"

echo "Installiere Profil: Jarvis FritzBox Alexa Home Assistant"
echo "Hinweis: Dieses Profil ist experimental/advanced und installiert keine Alexa-Cloud- oder SIP-Secrets."

for s in home_assistant mosquitto node_red ollama openclaw piper faster_whisper; do
  if [ -f "$ROOT_DIR/scripts/tools/${s}_install.sh" ]; then
    bash "$ROOT_DIR/scripts/tools/${s}_install.sh"
  else
    echo "Hinweis: Tool-Skript fehlt oder ist optional: ${s}_install.sh"
  fi
done

mkdir -p \
  "$PROFILE_DIR/configs" \
  "$PROFILE_DIR/prompts" \
  "$PROFILE_DIR/automations" \
  "$PROFILE_DIR/node-red" \
  "$PROFILE_DIR/home-assistant" \
  "$PROFILE_DIR/mqtt" \
  "$PROFILE_DIR/voice" \
  "$PROFILE_DIR/telephony" \
  "$PROFILE_DIR/logs" \
  "$PROFILE_DIR/docs"

ENV_TEMPLATE="$PROFILE_DIR/configs/.env.template"
if [ -f "$ENV_TEMPLATE" ]; then
  cp "$ENV_TEMPLATE" "$ENV_TEMPLATE.bak.$(date +%Y%m%d_%H%M%S)"
fi

cat > "$ENV_TEMPLATE" <<'EOF'
PROFILE_NAME=Jarvis_FritzBox_Alexa_Home_Assistant
JARVIS_ENABLED=false
JARVIS_MODE=local_only
JARVIS_BRAIN_PROVIDER=ollama
DEFAULT_LLM_MODEL=llama3.2

HOME_ASSISTANT_URL=http://127.0.0.1:8123
MQTT_HOST=127.0.0.1
MQTT_PORT=1883

FRITZBOX_HOST=fritz.box
ENABLE_FRITZBOX_CALL_MONITOR=false
ENABLE_FRITZBOX_TR064=false
ENABLE_ALEXA_BRIDGE=false
ENABLE_SIP_ASTERISK=false

ENABLE_STT=true
ENABLE_TTS=true
DEFAULT_STT_ENGINE=faster_whisper
DEFAULT_TTS_ENGINE=piper

ENABLE_CALL_RECORDING=false
ENABLE_CALL_TRANSCRIPTION=false
REQUIRE_CONFIRMATION_FOR_ACTIONS=true
JARVIS_ACTION_ALLOWLIST=notify,create_note,create_task,read_status

MEMORY_BACKEND=local
DATA_RETENTION_DAYS=7
LOG_LEVEL=info
EOF

cat > "$PROFILE_DIR/docs/README.md" <<'EOF'
# Jarvis FritzBox Alexa Home Assistant

Dieses Profil ist ein sicherer Startpunkt fuer Fritz!Box-, Home-Assistant-, Voice- und Jarvis-Brain-Experimente.

- Secrets gehoeren nicht in dieses Verzeichnis, sondern in geschuetzte lokale Dateien.
- Alexa-Bridge und SIP/Asterisk sind bewusst nicht automatisch aktiv.
- Anrufaufzeichnung ist standardmaessig deaktiviert.
- Aktionen ausserhalb von Notiz, Benachrichtigung, Status und Aufgabe brauchen eine explizite Freigabe.
EOF

mark_profile_installed "Jarvis_FritzBox_Alexa_Home_Assistant"
echo "Profil vorbereitet unter: $PROFILE_DIR"
