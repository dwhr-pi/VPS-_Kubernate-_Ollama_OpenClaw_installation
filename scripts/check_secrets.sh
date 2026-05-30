#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

echo "Secret-Check: pruefe auf riskante Dateien und Muster, ohne Werte auszugeben."

warn=0
tmp_files="$(mktemp)"
tmp_patterns="$(mktemp)"
trap 'rm -f "$tmp_files" "$tmp_patterns"' EXIT

find "$ROOT_DIR" -path "$ROOT_DIR/.git" -prune -o \
  -path "*/node_modules/*" -prune -o \
  -path "*/venv/*" -prune -o \
  -path "*/.venv/*" -prune -o \
  \( -name ".env" -o -name "*.pem" -o -name "*.key" -o -path "*/secrets/*" \) -print > "$tmp_files" 2>/dev/null || true

if [[ -s "$tmp_files" ]]; then
  echo "WARN: Potenziell sensible Dateien im Repository gefunden. Bitte nur .env.example, Platzhalter oder externe User-Daten nutzen."
  sed "s#^$ROOT_DIR/##" "$tmp_files"
  warn=1
fi

if command -v rg >/dev/null 2>&1; then
  if command -v timeout >/dev/null 2>&1; then
    timeout 30 rg -l --hidden --no-messages \
      --glob '!.git/**' --glob '!node_modules/**' --glob '!**/venv/**' --glob '!**/.venv/**' \
      --glob '!*.log' --glob '!*.png' --glob '!*.jpg' --glob '!*.jpeg' --glob '!*.webp' --glob '!*.zip' --glob '!*.tar' --glob '!*.gz' \
      '(OPENAI_API_KEY|ANTHROPIC_API_KEY|GEMINI_API_KEY|AWS_SECRET_ACCESS_KEY|PRIVATE KEY|password *= *[^_ <>{}]|token *= *[^_ <>{}])' "$ROOT_DIR" > "$tmp_patterns" 2>/dev/null || true
  else
    rg -l --hidden --no-messages \
      --glob '!.git/**' --glob '!node_modules/**' --glob '!**/venv/**' --glob '!**/.venv/**' \
      --glob '!*.log' --glob '!*.png' --glob '!*.jpg' --glob '!*.jpeg' --glob '!*.webp' --glob '!*.zip' --glob '!*.tar' --glob '!*.gz' \
      '(OPENAI_API_KEY|ANTHROPIC_API_KEY|GEMINI_API_KEY|AWS_SECRET_ACCESS_KEY|PRIVATE KEY|password *= *[^_ <>{}]|token *= *[^_ <>{}])' "$ROOT_DIR" > "$tmp_patterns" 2>/dev/null || true
  fi
  if [[ -s "$tmp_patterns" ]]; then
    echo "WARN: Dateien mit potenziellen Secret-Mustern gefunden. Werte werden absichtlich nicht angezeigt:"
    sed "s#^$ROOT_DIR/##" "$tmp_patterns"
    warn=1
  fi
else
  echo "INFO: rg nicht gefunden; einfacher Datei-Check wurde ausgefuehrt, Muster-Scan uebersprungen."
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Dry-run: keine Aenderungen vorgenommen."
fi

if [[ "$warn" -eq 1 ]]; then
  echo "Secret-Check abgeschlossen mit Warnungen."
else
  echo "Secret-Check abgeschlossen: keine offensichtlichen Secrets gefunden."
fi
