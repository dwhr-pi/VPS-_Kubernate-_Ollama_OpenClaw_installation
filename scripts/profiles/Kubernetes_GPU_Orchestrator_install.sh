#!/usr/bin/env bash
set -euo pipefail
bash "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/profile_pack_installer.sh" "Kubernetes_GPU_Orchestrator" "Kubernetes GPU Orchestrator" "k3s prometheus grafana node_exporter cadvisor"
