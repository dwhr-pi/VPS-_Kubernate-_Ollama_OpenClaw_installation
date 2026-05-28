#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Security-Scan (safe, read-only)"

bash "$ROOT_DIR/scripts/secret_scan.sh" || true

if command -v trivy >/dev/null 2>&1; then
  trivy fs --scanners vuln,secret,misconfig "$ROOT_DIR"
else
  echo "Hinweis: trivy nicht installiert. Container-/Dependency-Scan uebersprungen."
fi

if [ -f "$ROOT_DIR/scripts/check_ports.sh" ]; then
  bash "$ROOT_DIR/scripts/check_ports.sh" || true
fi

echo "Security-Scan abgeschlossen."
