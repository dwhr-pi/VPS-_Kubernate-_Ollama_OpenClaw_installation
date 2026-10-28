#!/usr/bin/env bash
# Quellen: https://github.com/k3s-io/k3s und gepruefte Artefakt-Lockdatei.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"

gitops_read_plan_value() {
  local value
  printf '%s' "$1"
  if ! IFS= read -r -u 3 value; then
    return 3
  fi
  # Normalize clipboard whitespace, including Windows CRLF, not inner spaces.
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  [[ -n "$value" ]] || return 3
  REPLY="$value"
}

if (($# == 0)) || [[ $# == 1 && $1 == --interactive-plan ]]; then
  printf '%s\n' 'GitOps_Bootstrap: gefuehrter Offline-Plan, KEINE Installation.' \
    'Benoetigt: eigene gepruefte Artefakt-JSON mit echten Pins/Hashes und private IPv4-Adresse.' \
    'Die Beispiel-JSON ist noch nicht einsatzbereit. Keine Versionen/Hashes werden erfunden.' \
    'Apply braucht root, separaten Tunnel-Token und zwei ausdrueckliche Freigaben.' \
    'Unter WSL sind fuer Apply mindestens 12 GiB Windows-Host-Reserve erforderlich.' \
    'Anleitung: docs/GITOPS_SMALL_VPS.md. Nur Enter druecken, um die Planung zu verschieben.' \
    'Keine Installation gestartet. Die protokollierte Dauer umfasst auch Wartezeit auf Ihre Eingabe.'
  # Protokollierung darf stdin umleiten; interaktive Eingaben bleiben am Terminal.
  if [[ -t 0 ]]; then
    exec 3<&0
  elif { true </dev/tty; } 2>/dev/null; then
    exec 3</dev/tty
  else
    printf '%s\n' 'Planung verschoben: kein interaktives Terminal. Kein Fehler und keine Installation.' \
      'Mit vorbereiteten Werten: bash scripts/bootstrap_gitops.sh --plan --artifacts /privat/artifacts.json --private-address 10.7.0.2'
    exit 3
  fi
  if ! gitops_read_plan_value 'Absoluter Pfad zur geprueften Artefakt-JSON [Enter: verschieben]: '; then
    printf '\nPlanung verschoben; keine Aenderung.\n'
    exit 3
  fi
  artifacts="$REPLY"
  if [[ "$artifacts" != /* || ! -f "$artifacts" || -L "$artifacts" ]]; then
    printf '\nPlanung nicht gestartet: eine vorhandene absolute JSON-Artefaktdatei ohne Symlink angeben.\n' >&2
    printf 'Keine Adresse abgefragt und keine Installation gestartet. Anleitung: docs/GITOPS_SMALL_VPS.md.\n' >&2
    exit 1
  fi
  if ! gitops_read_plan_value 'Private IPv4-Adresse des Zielhosts [Enter: verschieben]: '; then
    printf '\nPlanung verschoben; keine Aenderung.\n'
    exit 3
  fi
  address="$REPLY"
  exec 3<&-
  bash "$ROOT/scripts/bootstrap_gitops.sh" --plan --artifacts "$artifacts" --private-address "$address"
  printf '%s\n' 'Plan validiert, NICHT installiert. Kein Erfolgsmarker oder Dienststart.' \
    'Erst nach Host-/Firewall-/Token-Pruefung separat ausfuehren (NICHT automatisch):'
  printf 'sudo bash %q --apply --artifacts %q --private-address %q --confirm-new-host --confirm-private-firewall\n' \
    "$ROOT/scripts/bootstrap_gitops.sh" "$artifacts" "$address"
  exit 0
fi
exec bash "$ROOT/scripts/bootstrap_gitops.sh" "$@"
