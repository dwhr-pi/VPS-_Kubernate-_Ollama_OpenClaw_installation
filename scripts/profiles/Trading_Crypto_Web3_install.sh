#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
log_warn "Trading_Crypto_Web3 wird standardmäßig im Paper-Trading- und Safe-Mode eingerichtet."
for s in zenbot_trader exchange_apis web3_apis; do
  bash "$ROOT_DIR/scripts/tools/${s}_install.sh"
done
mark_profile_installed "Trading_Crypto_Web3"
