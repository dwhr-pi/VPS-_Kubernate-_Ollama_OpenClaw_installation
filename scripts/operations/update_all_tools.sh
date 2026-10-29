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

failed=0
while IFS= read -r tool_name || [ -n "$tool_name" ]; do
  tool_name="${tool_name%$'\r'}"
  [ -z "$tool_name" ] && continue
  if script_path="$(python3 -I -B "$REPO_ROOT/scripts/lib/tool_dispatch.py" "$tool_name" --action update)"; then
    log_info "Aktualisiere Tool ueber registriertes Update-Skript."
    if ! bash "$script_path"; then
      log_warn "Registriertes Tool-Update fehlgeschlagen."
      failed=1
    fi
  else
    log_warn "Kein freigegebener Update-Pfad; kein automatischer Re-Install."
    failed=1
  fi
done < "$TOOL_STATUS_FILE"

if [ "$failed" -ne 0 ]; then
  log_warn "Updates unvollstaendig; Hinweise pruefen. Keine fehlenden Updater durch Installer ersetzt."
  exit 1
fi
log_success "Alle registrierten Updates erfolgreich abgeschlossen."
