#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
echo "Tailscale, Firewall und Tunnel werden aus Sicherheitsgruenden nicht automatisch entfernt."
mark_profile_removed "Home_Network_Security"
