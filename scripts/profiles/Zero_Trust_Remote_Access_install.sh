#!/usr/bin/env bash
set -euo pipefail
bash "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/profile_pack_installer.sh" "Zero_Trust_Remote_Access" "Zero Trust Remote Access" "tailscale cloudflared ufw crowdsec fail2ban"
