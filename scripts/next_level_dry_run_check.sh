#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail=0
warn() {
  echo "WARNUNG: $*"
}
err() {
  echo "FEHLER: $*"
  fail=1
}

echo "Next-Level Dry-Run Check"
echo "Repo: $ROOT_DIR"

for file in readme.md install.sh setup_ultimate.sh config/profiles.yml config/tools.yml config/ports.yml; do
  [ -e "$ROOT_DIR/$file" ] || err "Pflichtdatei fehlt: $file"
done

if find "$ROOT_DIR" -maxdepth 3 -type f \( -name ".env" -o -name "*.pem" -o -name "id_rsa" \) | grep -q .; then
  err "Moegliche Secret-/Key-Datei im Repo gefunden"
else
  echo "OK: keine offensichtlichen .env/pem/id_rsa Dateien auf maxdepth 3"
fi

if grep -RInE '0\.0\.0\.0|--host[ =]0\.0\.0\.0' "$ROOT_DIR/config" "$ROOT_DIR/docs" "$ROOT_DIR/scripts" 2>/dev/null | grep -v '127.0.0.1' | head -20; then
  warn "Bitte pruefen: moegliche offene Bindings gefunden"
else
  echo "OK: keine offensichtlichen offenen Bindings in config/docs/scripts"
fi

if command -v bash >/dev/null 2>&1; then
  bash -n "$ROOT_DIR/install.sh" "$ROOT_DIR/setup_ultimate.sh" || err "bash -n fuer Hauptskripte fehlgeschlagen"
fi

if [ -x "$ROOT_DIR/scripts/check_profile_registry_sync.sh" ]; then
  bash "$ROOT_DIR/scripts/check_profile_registry_sync.sh" || warn "Registry-Sync meldet Hinweise"
else
  warn "Registry-Sync-Skript nicht ausfuehrbar oder fehlt"
fi

if command -v shellcheck >/dev/null 2>&1; then
  find "$ROOT_DIR/scripts" -name "*.sh" -print0 | xargs -0 shellcheck || err "shellcheck meldet Fehler"
else
  warn "shellcheck nicht installiert"
fi

if [ "$fail" -ne 0 ]; then
  echo "Dry-Run Check: FEHLER"
  exit 1
fi

echo "Dry-Run Check: OK mit moeglichen Warnungen"
