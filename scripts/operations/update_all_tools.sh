#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

ensure_user_workspace

if [ ! -s "$TOOL_STATUS_FILE" ]; then
  log_warn "Keine installierten Tools in $TOOL_STATUS_FILE vermerkt."
  exit 0
fi

while IFS= read -r tool_name; do
  [ -z "$tool_name" ] && continue
  slug="$(echo "$tool_name" | tr '[:upper:]' '[:lower:]')"
  script_path="${REPO_ROOT}/scripts/tools/${slug}_install.sh"
  if [ -x "$script_path" ] || [ -f "$script_path" ]; then
    log_info "Aktualisiere Tool über Re-Install: $tool_name"
    bash "$script_path" || log_warn "Update für $tool_name fehlgeschlagen."
  else
    log_warn "Kein Install-Skript gefunden für $tool_name ($script_path)"
  fi
done < "$TOOL_STATUS_FILE"

log_success "Update aller vermerkten Tools abgeschlossen."
