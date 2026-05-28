#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Secret-Scan (safe, read-only)"

if command -v gitleaks >/dev/null 2>&1; then
  gitleaks detect --source "$ROOT_DIR" --no-git
  exit $?
fi

if command -v trufflehog >/dev/null 2>&1; then
  trufflehog filesystem "$ROOT_DIR"
  exit $?
fi

echo "Hinweis: gitleaks/trufflehog nicht installiert. Fuehre einfachen Pattern-Scan aus."
if grep -RInE '(api[_-]?key|secret|token|password|private[_-]?key)\s*[:=]\s*[^<[:space:]]{12,}' \
  "$ROOT_DIR" \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=.venv \
  --exclude='*.md' |
  head -50; then
  echo "WARNUNG: moegliche Secrets gefunden. Bitte manuell pruefen."
  exit 1
fi

echo "OK: einfacher Secret-Scan ohne Treffer."
