#!/usr/bin/env bash
# Quellen: https://github.com/k3s-io/k3s und gepruefte Artefakt-Lockdatei.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
if (($# == 0)) || [[ $# == 1 && $1 == --interactive-plan ]]; then
  printf '%s\n' 'GitOps_Bootstrap: gefuehrter Offline-Plan, KEINE Installation.' \
    'Benoetigt: eigene gepruefte Artefakt-JSON mit echten Pins/Hashes und private IPv4-Adresse.' \
    'Die Beispiel-JSON ist noch nicht einsatzbereit. Keine Versionen/Hashes werden erfunden.' \
    'Apply braucht root, separaten Tunnel-Token und zwei ausdrueckliche Freigaben.' \
    'Unter WSL sind fuer Apply mindestens 12 GiB Windows-Host-Reserve erforderlich.' \
    'Anleitung: docs/GITOPS_SMALL_VPS.md. Enter bei einer Frage verschiebt die Planung.'
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
  printf 'Absoluter Pfad zur geprueften Artefakt-JSON [Enter: verschieben]: '
  if ! IFS= read -r -u 3 artifacts || [[ -z "$artifacts" ]]; then
    printf '\nPlanung verschoben; keine Aenderung.\n'
    exit 3
  fi
  printf 'Private IPv4-Adresse des Zielhosts [Enter: verschieben]: '
  if ! IFS= read -r -u 3 address || [[ -z "$address" ]]; then
    printf '\nPlanung verschoben; keine Aenderung.\n'
    exit 3
  fi
  exec 3<&-
  bash "$ROOT/scripts/bootstrap_gitops.sh" --plan --artifacts "$artifacts" --private-address "$address"
  printf '%s\n' 'Plan validiert, NICHT installiert. Kein Erfolgsmarker oder Dienststart.' \
    'Erst nach Host-/Firewall-/Token-Pruefung separat ausfuehren (NICHT automatisch):'
  printf 'sudo bash %q --apply --artifacts %q --private-address %q --confirm-new-host --confirm-private-firewall\n' \
    "$ROOT/scripts/bootstrap_gitops.sh" "$artifacts" "$address"
  exit 0
fi
exec bash "$ROOT/scripts/bootstrap_gitops.sh" "$@"
