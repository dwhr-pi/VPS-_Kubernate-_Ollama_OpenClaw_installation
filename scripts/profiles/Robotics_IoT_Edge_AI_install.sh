#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in home_assistant node_red mosquitto zigbee2mqtt esphome; do [ -f "$ROOT_DIR/scripts/tools/${s}_install.sh" ] && bash "$ROOT_DIR/scripts/tools/${s}_install.sh"; done
mark_profile_installed "Robotics_IoT_Edge_AI"
