#!/usr/bin/env bash
set -euo pipefail

echo "Container-Check"
if command -v trivy >/dev/null 2>&1; then
  trivy fs --scanners vuln,secret,misconfig .
else
  echo "trivy nicht installiert. Empfehlung: Tool 'trivy' ueber Setup optional installieren."
fi
