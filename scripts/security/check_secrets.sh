#!/usr/bin/env bash
set -euo pipefail

echo "Secret-Check"
if command -v gitleaks >/dev/null 2>&1; then
  gitleaks detect --no-git --redact
else
  echo "gitleaks nicht installiert, nutze einfache Musterpruefung."
  grep -RInE 'api[_-]?key|secret|token|PRIVATE KEY|password=' . \
    --exclude-dir=.git --exclude-dir=node_modules --exclude='*.md' || true
fi
