#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/scripts/lib/isolated_cpython.sh"
for value in 0 65 -1 invalid; do
  if CPYTHON_BUILD_JOBS="$value" build_isolated_cpython311 >/dev/null 2>&1; then exit 1; fi
done
# Reject an unsafe resolved prefix before filesystem/sudo/build operations.
realpath() { echo /unsafe/elsewhere; }
sudo() {
  echo 'FAIL: sudo reached' >&2
  return 99
}
if CPYTHON_BUILD_JOBS=2 build_isolated_cpython311 >/dev/null 2>&1; then exit 1; fi
echo 'PASS: invalid build parallelism and unsafe interpreter prefix rejected without installation.'
