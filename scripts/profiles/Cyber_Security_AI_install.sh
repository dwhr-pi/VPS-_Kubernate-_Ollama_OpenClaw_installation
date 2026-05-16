#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in gitleaks semgrep trivy syft grype ufw crowdsec fail2ban; do [ -f "$ROOT_DIR/scripts/tools/${s}_install.sh" ] && bash "$ROOT_DIR/scripts/tools/${s}_install.sh"; done
mkdir -p "$HOME/.openclaw_ultimate_user_data/reports/security"
mark_profile_installed "Cyber_Security_AI"
