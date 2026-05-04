#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in esphome zigbee2mqtt mosquitto node_red home_assistant; do [ -f "$ROOT_DIR/scripts/tools/${s}_uninstall.sh" ] && bash "$ROOT_DIR/scripts/tools/${s}_uninstall.sh"; done
mark_profile_removed "Robotics_IoT_Edge_AI"
