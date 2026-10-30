#!/usr/bin/env bash
set -euo pipefail
case "${1:-uninstall}" in
  --dry-run | --plan) echo 'Plan: keine Profilinstallation vorhanden. Keine Repositories, Daten oder Modelle werden geloescht.' ;;
  *)
    echo 'Keine automatische Deinstallation des geplanten Profils.' >&2
    exit 2
    ;;
esac
