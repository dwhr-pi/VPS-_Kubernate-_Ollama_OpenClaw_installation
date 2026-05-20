#!/usr/bin/env bash
set -euo pipefail

MQTT_HOST="${MQTT_HOST:-127.0.0.1}"
MQTT_PORT="${MQTT_PORT:-1883}"
TOPIC="${TOPIC:-sensor/anlage/test}"

if ! command -v mosquitto_pub >/dev/null 2>&1; then
    echo "mosquitto_pub fehlt. Installiere mosquitto-clients oder nutze Node-RED/n8n."
    exit 0
fi

mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -t "$TOPIC" -m '{"status":"test","temperature":24.2}'
echo "Testnachricht gesendet an mqtt://$MQTT_HOST:$MQTT_PORT/$TOPIC"
