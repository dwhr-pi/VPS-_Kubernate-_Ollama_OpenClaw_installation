#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
plan="$(bash "$repo_dir/scripts/tools/airbyte_install.sh" --dry-run)"
[[ "$plan" == *'"recipe": null'* && "$plan" == *'abctl'* ]]
[[ "$plan" == *'blocked_reason'* ]]
echo "PASS: Airbyte native migration explicitly blocked; no kind/container setup."
