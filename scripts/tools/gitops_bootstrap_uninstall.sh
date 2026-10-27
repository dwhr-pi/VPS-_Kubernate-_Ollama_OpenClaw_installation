#!/usr/bin/env bash
# Infrastruktur und PVCs niemals durch pauschale Deinstallation entfernen.
set -euo pipefail
printf '%s\n' 'Keine automatische GitOps/K3s-Deinstallation. Restore, PVCs, Tunnel und Cluster zuerst separat inventarisieren; docs/GITOPS_SMALL_VPS.md.' >&2
exit 1
