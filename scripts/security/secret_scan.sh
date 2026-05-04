#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
echo "Secret Scan"
echo "==========="

if command -v gitleaks >/dev/null 2>&1; then
  echo "[INFO] Starte Gitleaks..."
  (cd "$ROOT_DIR" && gitleaks detect --no-git --source .) || true
else
  echo "[WARN] gitleaks nicht installiert."
fi

if command -v trufflehog >/dev/null 2>&1; then
  echo "[INFO] Starte TruffleHog..."
  (cd "$ROOT_DIR" && trufflehog filesystem . --no-update) || true
else
  echo "[WARN] trufflehog nicht installiert."
fi

echo
echo "Manuelle Kurzprüfung:"
echo "- Keine .env mit echten Secrets committen"
echo "- Produktions-.env nur ausserhalb des Repos im Benutzer-Workspace halten"
echo "- Keine Wallet-Seed oder Private Keys im Repo speichern"
echo "- Keine GitHub PATs, API-Keys oder Cloudflare-Tokens ablegen"
