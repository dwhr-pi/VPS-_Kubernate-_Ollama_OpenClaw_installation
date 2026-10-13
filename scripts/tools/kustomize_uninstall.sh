#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
case "${1:-uninstall}" in
  --dry-run) echo 'Entfernt nur /usr/local/bin/kustomize; keine Manifeste oder kubeconfig.' ;;
  uninstall)
    AUTO_INSTALL_TOOL_BASE_DEPS=false begin_measurement tool_uninstall_Kustomize 'Kustomize Binary entfernen'
    if ! sudo rm -f -- /usr/local/bin/kustomize; then end_measurement failed; exit 1; fi
    mark_tool_removed Kustomize
    end_measurement success ;;
  *) echo 'Aufruf: kustomize_uninstall.sh [--dry-run]' >&2; exit 2 ;;
esac
