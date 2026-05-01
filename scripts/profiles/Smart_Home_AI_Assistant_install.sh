#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in node_red mosquitto zigbee2mqtt esphome; do bash "$ROOT_DIR/scripts/tools/${s}_install.sh"; done
mark_profile_installed "Smart_Home_AI_Assistant"
