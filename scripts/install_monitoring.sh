#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "Monitoring-Basis: Uptime Kuma, Prometheus/Grafana/Loki optional."
bash "$ROOT_DIR/scripts/tools/uptime_kuma_install.sh" "$@"
