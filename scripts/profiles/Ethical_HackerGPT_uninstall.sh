#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

PROFILE_KEY="Ethical_HackerGPT"
PROFILE_WORKSPACE_DIR="${USER_WORKSPACE_DIR}/ethical_hackergpt"

ensure_user_workspace

run_tool_script_if_present() {
  local script_name="$1"
  if [ -f "$ROOT_DIR/scripts/tools/$script_name" ]; then
    log_info "Deinstalliere $script_name ..."
    bash "$ROOT_DIR/scripts/tools/$script_name"
  else
    log_warn "$script_name nicht gefunden. Ueberspringe diesen Baustein."
  fi
}

log_info "Deinstalliere Ethical_HackerGPT-Profil."
run_tool_script_if_present "grype_uninstall.sh"
run_tool_script_if_present "syft_uninstall.sh"
run_tool_script_if_present "trivy_uninstall.sh"
run_tool_script_if_present "semgrep_uninstall.sh"
run_tool_script_if_present "gitleaks_uninstall.sh"
run_tool_script_if_present "nmap_uninstall.sh"

rm -f "$PROFILE_WORKSPACE_DIR/ethical_hackergpt.env"
mark_profile_removed "$PROFILE_KEY"
log_warn "Gemeinsame Basiswerkzeuge wie curl, git, jq, openssl, ufw, fail2ban oder lynis werden absichtlich nicht automatisch entfernt."
log_success "Ethical_HackerGPT-Profil wurde aus dem Setup-Status entfernt."
