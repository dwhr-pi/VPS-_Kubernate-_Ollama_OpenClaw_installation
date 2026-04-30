#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

TARGET_DIR="${1:-$REPO_ROOT}"

log_info "Starte Security-Scans für: $TARGET_DIR"

if command -v gitleaks >/dev/null 2>&1; then
  append_log security_scan_gitleaks gitleaks detect --no-git --source "$TARGET_DIR" || true
else
  log_warn "Gitleaks ist nicht installiert."
fi

if command -v trivy >/dev/null 2>&1; then
  append_log security_scan_trivy trivy fs "$TARGET_DIR" || true
else
  log_warn "Trivy ist nicht installiert."
fi

if command -v semgrep >/dev/null 2>&1; then
  append_log security_scan_semgrep semgrep scan --config auto "$TARGET_DIR" || true
else
  log_warn "Semgrep ist nicht installiert."
fi

if command -v syft >/dev/null 2>&1; then
  append_log security_scan_syft syft "$TARGET_DIR" || true
else
  log_warn "Syft ist nicht installiert."
fi

if command -v grype >/dev/null 2>&1; then
  append_log security_scan_grype grype dir:"$TARGET_DIR" || true
else
  log_warn "Grype ist nicht installiert."
fi

log_success "Security-Scan abgeschlossen. Siehe Logs unter $USER_LOG_DIR"
