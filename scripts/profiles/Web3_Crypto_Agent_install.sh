#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
log_warn "Web3_Crypto_Agent läuft standardmäßig ohne Live-Trading und ohne Speicherung privater Schlüssel."
for s in web3_apis exchange_apis zenbot_api zenbot_trader risk_strategy_analyzer; do bash "$ROOT_DIR/scripts/tools/${s}_install.sh"; done
mark_profile_installed "Web3_Crypto_Agent"
