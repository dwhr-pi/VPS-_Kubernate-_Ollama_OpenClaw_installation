#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in node_exporter cadvisor grafana_alloy uptime_kuma restic velero kubectx_kubens k9s flux_cli argocd_cli helm opentofu ansible; do
  [ -f "$ROOT_DIR/scripts/tools/${s}_uninstall.sh" ] && bash "$ROOT_DIR/scripts/tools/${s}_uninstall.sh"
done
mark_profile_removed "DevOps_SRE"
