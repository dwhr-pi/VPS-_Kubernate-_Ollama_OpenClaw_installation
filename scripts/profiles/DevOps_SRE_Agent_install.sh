#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in docker k3s kubectl helm kustomize ansible opentofu renovate uptime_kuma healthchecks watchtower crowdsec ufw fail2ban; do bash "$ROOT_DIR/scripts/tools/${s}_install.sh"; done
mark_profile_installed "DevOps_SRE_Agent"
