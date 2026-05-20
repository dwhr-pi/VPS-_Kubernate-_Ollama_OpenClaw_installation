#!/usr/bin/env bash
set -euo pipefail

START_TS="$(date +%s)"
ROBOTICS_HOME="${ROBOTICS_HOME:-$HOME/Ultimate_KI_Setup/robotics_control}"
LOG_DIR="$ROBOTICS_HOME/logs"
LOG_FILE="$LOG_DIR/robotik-anlagensteuerung-install.log"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starte Robotik & Anlagensteuerung Basisvorbereitung..."
echo "Home: $ROBOTICS_HOME"
echo "Sicherheitsmodus: read-only. Es werden keine Aktor-Schreibzugriffe eingerichtet."
df -h "$HOME" || true

create_tree() {
  mkdir -p \
    "$ROBOTICS_HOME/configs" \
    "$ROBOTICS_HOME/logs" \
    "$ROBOTICS_HOME/jsonl" \
    "$ROBOTICS_HOME/sqlite" \
    "$ROBOTICS_HOME/ros2_ws" \
    "$ROBOTICS_HOME/gazebo" \
    "$ROBOTICS_HOME/moveit" \
    "$ROBOTICS_HOME/dashboards" \
    "$ROBOTICS_HOME/node_red" \
    "$ROBOTICS_HOME/n8n" \
    "$ROBOTICS_HOME/plc" \
    "$ROBOTICS_HOME/modbus" \
    "$ROBOTICS_HOME/opcua" \
    "$ROBOTICS_HOME/mqtt" \
    "$ROBOTICS_HOME/reports" \
    "$ROBOTICS_HOME/safety"
}

install_basics() {
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y git curl ca-certificates python3 python3-venv python3-pip sqlite3 mosquitto-clients
  else
    echo "Kein apt-get gefunden. Bitte Python, SQLite und MQTT-Clients manuell installieren."
  fi
}

install_python_clients() {
  python3 -m venv "$ROBOTICS_HOME/venv"
  "$ROBOTICS_HOME/venv/bin/python" -m pip install --upgrade pip wheel setuptools
  "$ROBOTICS_HOME/venv/bin/pip" install paho-mqtt pymodbus asyncua opcua
}

write_safety_defaults() {
  cat > "$ROBOTICS_HOME/configs/command_whitelist.yml" <<'EOF'
# Standard: keine Schreibbefehle erlaubt.
# Erst nach Risikoanalyse, manueller Freigabe, Grenzwertpruefung und Not-Aus-Konzept erweitern.
allowed_commands: []
read_only: true
require_human_approval: true
EOF

  cat > "$ROBOTICS_HOME/README_Robotik_Anlagensteuerung.md" <<'EOF'
# Robotik & Anlagensteuerung

Dieses Verzeichnis ist read-only vorbereitet. KI darf Diagnosen und Simulationen planen,
aber keine gefaehrlichen Aktoren direkt steuern.

Groessere optionale Komponenten:

- ROS 2
- MoveIt 2
- Gazebo
- ros2_control
- OpenPLC
- FUXA
- Node-RED Dashboard
EOF
}

create_tree
install_basics || true
install_python_clients || true
write_safety_defaults

echo "Robotik & Anlagensteuerung vorbereitet."
echo "Keine ROS-/PLC-/HMI-Stacks wurden blind installiert; diese bleiben bewusste, systemnahe Folgeschritte."
df -h "$HOME" || true
echo "Dauer: $(($(date +%s) - START_TS)) Sekunden"
echo "Logdatei: $LOG_FILE"

