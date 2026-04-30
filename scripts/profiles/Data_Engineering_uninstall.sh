#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in dbt airbyte duckdb metabase minio redis postgres; do
  bash "$ROOT_DIR/scripts/tools/${s}_uninstall.sh" || true
done
mark_profile_removed "Data_Engineering"
