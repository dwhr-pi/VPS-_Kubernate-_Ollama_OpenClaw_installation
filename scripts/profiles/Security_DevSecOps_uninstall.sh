#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in fail2ban syft grype semgrep gitleaks trivy; do
  bash "$ROOT_DIR/scripts/tools/${s}_uninstall.sh" || true
done
mark_profile_removed "Security_DevSecOps"
