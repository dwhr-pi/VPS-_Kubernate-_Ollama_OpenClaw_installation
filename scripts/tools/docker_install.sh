#!/usr/bin/env bash
set -Eeuo pipefail
printf '%s\n' 'Installationsrichtlinie: Git-Quellbuilds bleiben erlaubt; keine Docker-Installation und kein Docker-Fallback. Bestehende Daten bleiben unveraendert. Siehe docs/INSTALLATION_POLICY.md.' >&2
exit 1
