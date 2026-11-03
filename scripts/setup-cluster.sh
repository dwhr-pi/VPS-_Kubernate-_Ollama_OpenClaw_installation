#!/usr/bin/env bash
# Safe entrypoint: no implicit host provisioning, Docker, downloads or service start.
set -Eeuo pipefail
umask 077
ROOT="$(cd -P "${BASH_SOURCE[0]%/*}/.." && pwd)"
action=${1:---plan}
(($# == 0)) || shift
die() {
  printf 'Cluster-Setup abgelehnt: %s\n' "$*" >&2
  exit 2
}
for arg in "$@"; do
  case "$arg" in
    --plan | --check | --validate | --apply | --render | --bootstrap-plan | --provision)
      die 'Widerspruechliche Aktionsoptionen; keine Aktion gestartet.'
      ;;
  esac
done
case "$action" in
  --help | -h)
    printf '%s\n' 'setup-cluster.sh [--plan|--render base|vps-cpu|gpu|production|private-ingress|vps-cpu-local-storage]' \
      '--check [Hostoptionen] | --validate [--overlay ABS] | --apply --overlay ABS --context NAME --confirm-apply' \
      '--bootstrap-plan --artifacts ABS --private-address IP: nur bestehenden Artefaktvertrag pruefen.' \
      'Keine automatische Neuinstallation. Details: docs/GITOPS_DEPLOYMENT_PATH.md.'
    ;;
  --plan)
    (($# == 0)) || die 'Plan akzeptiert keine impliziten Installationsoptionen.'
    printf '%s\n' 'Nur Plan: kein Download, Host-/Clusterzugriff oder Apply.' \
      '1. Git-basierte Host-/K3s-Buildvertraege separat abnehmen.' \
      '2. Private Konfiguration, Image-/Modell-Pins und Secrets bereitstellen.' \
      '3. --render, danach --validate; Apply nur mit Kontext und --confirm-apply.'
    ;;
  --render)
    (($# == 1)) || die 'Genau einen lokalen Overlay-Namen angeben.'
    case "$1" in
      base) path="$ROOT/deploy/kustomize/base" ;;
      vps-cpu | gpu | production | private-ingress | vps-cpu-local-storage)
        path="$ROOT/deploy/kustomize/overlays/$1"
        ;;
      *) die 'Overlay nicht freigegeben.' ;;
    esac
    command -v "${KUSTOMIZE_BIN:-kustomize}" >/dev/null || die 'Geprueftes Kustomize fehlt; keine Nachinstallation.'
    exec "${KUSTOMIZE_BIN:-kustomize}" build "$path"
    ;;
  --check) exec bash "$ROOT/scripts/operations/deploy_vps_baseline.sh" --check "$@" ;;
  --validate) exec bash "$ROOT/scripts/operations/deploy_vps_baseline.sh" --plan "$@" ;;
  --apply) exec bash "$ROOT/scripts/operations/deploy_vps_baseline.sh" --apply "$@" ;;
  --bootstrap-plan) exec bash "$ROOT/scripts/bootstrap_gitops.sh" --plan "$@" ;;
  --provision)
    die 'Source-only-Regel: kein freigegebener frischer K3s-Source-Build hier. Kein Release-/Docker-Fallback. Siehe docs/GITOPS_DEPLOYMENT_PATH.md.'
    ;;
  *) die 'Unbekannte Aktion; --help zeigt sichere Optionen.' ;;
esac
