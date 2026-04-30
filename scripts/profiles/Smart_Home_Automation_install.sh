#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in node_red mosquitto; do
  bash "$ROOT_DIR/scripts/tools/${s}_install.sh"
done
log_warn "Home Assistant und Alexa-/Tunnel-Integration benötigen zusätzliche lokale Konfiguration."
mark_profile_installed "Smart_Home_Automation"
