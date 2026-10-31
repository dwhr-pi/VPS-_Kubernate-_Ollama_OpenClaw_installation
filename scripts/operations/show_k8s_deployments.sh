#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

ARCHIVE="$REPO_ROOT/docs/legacy/K8S_DEPLOYMENTS_LEGACY.md"
if [[ ! -r "$ARCHIVE" ]]; then
  echo "Historische Kubernetes-Referenz fehlt: $ARCHIVE" >&2
  exit 1
fi

printf '%s\n' 'HISTORISCHE REFERENZ - kein ausfuehrbares Kubernetes-Manifest.'
printf '%s\n' 'Aktuelle Pfade: k8s/base, k8s/overlays/vps-cpu, k8s/overlays/production.'
printf '%s\n' 'Anleitung: docs/GITOPS_SMALL_VPS.md. Kein Apply und keine Clusteraenderung.'
cat -- "$ARCHIVE"
