#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
eval "$(sed -n '/^check_n8n_node_version() {/,/^free_gb_for_path() {/p' "$repo_dir/scripts/tools/n8n_install.sh" | sed '$d')"
node() { printf '%s\n' "$test_version"; }
for test_version in v18.19.1 v20.15.0 v22.21.9 invalid; do
  if check_n8n_node_version >/dev/null 2>&1; then
    echo "FAIL: accepted $test_version"
    exit 1
  fi
done
for test_version in v22.22.0 v22.22.1 v24.0.0; do
  check_n8n_node_version
done
echo 'PASS: n8n Node minimum and invalid-version cases checked.'
