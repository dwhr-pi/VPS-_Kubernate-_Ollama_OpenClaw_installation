#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
plan="$(bash "$repo_dir/scripts/tools/node_exporter_install.sh" --dry-run)"
[[ "$plan" == *'"kind": "go"'* && "$plan" == *'prometheus/node_exporter'* ]]
[[ "$plan" == *'"disk_mb": 4096'* ]]
echo "PASS: native Go plan; no root mount, mount propagation or exporter start."
