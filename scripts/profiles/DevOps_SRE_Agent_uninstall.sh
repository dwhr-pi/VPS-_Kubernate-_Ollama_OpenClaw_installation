#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in cloudflared tailscale fail2ban ufw crowdsec watchtower healthchecks uptime_kuma renovate opentofu ansible kustomize helm kubectl k3s docker; do bash "$ROOT_DIR/scripts/tools/${s}_uninstall.sh" || true; done
mark_profile_removed "DevOps_SRE_Agent"
