#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -f "$REPO_ROOT/scripts/k8s_deployments.yaml" ]; then
  cat "$REPO_ROOT/scripts/k8s_deployments.yaml"
else
  echo "Keine scripts/k8s_deployments.yaml gefunden."
fi
