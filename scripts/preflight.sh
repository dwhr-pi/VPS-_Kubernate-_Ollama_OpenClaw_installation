#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Preflight Check"
echo "Repo: $ROOT_DIR"

echo "System:"
uname -a || true

echo "Speicher:"
df -h "$ROOT_DIR" || true
free -h || true

if grep -qi microsoft /proc/version 2>/dev/null; then
  echo "WSL2 erkannt oder wahrscheinlich."
fi

echo "Tools:"
for cmd in git bash curl node pnpm python3 docker podman; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf 'OK: %s -> %s\n' "$cmd" "$(command -v "$cmd")"
  else
    printf 'FEHLT: %s\n' "$cmd"
  fi
done

if [ -f "$ROOT_DIR/scripts/next_level_dry_run_check.sh" ]; then
  bash "$ROOT_DIR/scripts/next_level_dry_run_check.sh" || true
fi
