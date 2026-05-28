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
echo "Modus: ${NEXT_LEVEL_FULL:-0} (NEXT_LEVEL_FULL=1 aktiviert langsame Vollchecks)"

for file in readme.md install.sh setup_ultimate.sh config/profiles.yml config/tools.yml config/ports.yml; do
  [ -e "$ROOT_DIR/$file" ] || err "Pflichtdatei fehlt: $file"
done

if find "$ROOT_DIR" -maxdepth 3 -type f \( -name ".env" -o -name "*.pem" -o -name "id_rsa" \) | grep -q .; then
  err "Moegliche Secret-/Key-Datei im Repo gefunden"
else
  echo "OK: keine offensichtlichen .env/pem/id_rsa Dateien auf maxdepth 3"
fi

if grep -RInm 20 -E '0\.0\.0\.0|--host[ =]0\.0\.0\.0' "$ROOT_DIR/config" "$ROOT_DIR/docs" "$ROOT_DIR/scripts" 2>/dev/null | grep -v '127.0.0.1'; then
  warn "Bitte pruefen: moegliche offene Bindings gefunden"
else
  echo "OK: keine offensichtlichen offenen Bindings in config/docs/scripts"
fi

if command -v bash >/dev/null 2>&1; then
  bash -n "$ROOT_DIR/install.sh" "$ROOT_DIR/setup_ultimate.sh" || err "bash -n fuer Hauptskripte fehlgeschlagen"
fi

if [ -f "$ROOT_DIR/scripts/check_profile_registry_sync.sh" ]; then
  if command -v timeout >/dev/null 2>&1; then
    timeout 60 bash "$ROOT_DIR/scripts/check_profile_registry_sync.sh" || warn "Registry-Sync meldet Hinweise oder Timeout"
  else
    warn "timeout nicht verfuegbar; Registry-Sync im schnellen Dry-Run uebersprungen"
  fi
else
  warn "Registry-Sync-Skript nicht ausfuehrbar oder fehlt"
fi

if [ -f "$ROOT_DIR/scripts/check_tool_lifecycle.sh" ]; then
  if command -v timeout >/dev/null 2>&1; then
    timeout 45 bash "$ROOT_DIR/scripts/check_tool_lifecycle.sh" || warn "Tool-Lifecycle-Audit meldet Hinweise oder Timeout"
  else
    warn "timeout nicht verfuegbar; Tool-Lifecycle-Audit im schnellen Dry-Run uebersprungen"
  fi
else
  warn "Tool-Lifecycle-Audit fehlt oder ist nicht ausfuehrbar"
fi

if [ "${NEXT_LEVEL_FULL:-0}" = "1" ] && command -v shellcheck >/dev/null 2>&1; then
  find "$ROOT_DIR/scripts" -name "*.sh" -print0 | xargs -0 shellcheck || err "shellcheck meldet Fehler"
elif [ "${NEXT_LEVEL_FULL:-0}" = "1" ]; then
  warn "shellcheck nicht installiert"
else
  warn "Shellcheck-Vollscan im schnellen Dry-Run uebersprungen. Fuer Vollscan: NEXT_LEVEL_FULL=1 bash scripts/next_level_dry_run_check.sh"
fi

if [ "$fail" -ne 0 ]; then
  echo "Dry-Run Check: FEHLER"
  exit 1
fi

echo "Dry-Run Check: OK mit moeglichen Warnungen"
