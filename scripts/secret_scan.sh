#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Secret-Scan (safe, read-only)"

if command -v gitleaks >/dev/null 2>&1; then
  gitleaks detect --source "$ROOT_DIR" --no-git --redact
  exit $?
fi

if command -v trufflehog >/dev/null 2>&1; then
  # Detection only: never validate possible credentials against external services.
  trufflehog filesystem "$ROOT_DIR" --no-verification --no-update --fail >/dev/null 2>&1
  exit $?
fi

echo "Hinweis: gitleaks/trufflehog nicht installiert. Fuehre einfachen Pattern-Scan aus."
if grep -rlE '(api[_-]?key|secret|token|password|private[_-]?key)\s*[:=]\s*[^<[:space:]]{12,}' \
  "$ROOT_DIR" \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=.venv \
  --exclude-dir=.codex-build \
  --exclude-dir=backups \
  --exclude='*.md' >/dev/null; then
  echo "WARNUNG: moegliche Secrets gefunden. Bitte manuell pruefen."
  exit 1
else
  result=$?
  if [[ "$result" -ne 1 ]]; then
    echo "FEHLER: Pattern-Scan unvollstaendig; kein sauberer Scan nachgewiesen." >&2
    exit 2
  fi
fi

echo "OK: einfacher Secret-Scan ohne Treffer."
