#!/usr/bin/env bash
# Velero-1.18-Server/Node-Agent nur lokal rendern; gepruefte CLI und Image-Digests erforderlich.
set -euo pipefail
umask 077
mode=plan server= plugin=
die() {
  printf 'Velero-Vorbereitung abgebrochen: %s\n' "$*" >&2
  exit 1
}
while (($#)); do
  case "$1" in
    --render)
      mode=render
      shift
      ;;
    --server-image | --plugin-image)
      (($# >= 2)) || die 'Optionswert fehlt.'
      case "$1" in --server-image) server=$2 ;; --plugin-image) plugin=$2 ;; esac
      shift 2
      ;;
    --help | -h)
      printf '%s\n' '--render --server-image REGISTRY/velero@sha256:HASH --plugin-image REGISTRY/aws-plugin@sha256:HASH'
      exit 0
      ;;
    *) die 'Nur Plan oder --render erlaubt; kein automatisches Apply/Secret-Import.' ;;
  esac
done
[[ "$mode" == render ]] || {
  printf '%s\n' 'Nur Plan. Vorhandene Velero-1.18-CLI, passende Server-/S3-Plugin-Digests, CRD-/RBAC-/Node-Agent-Pruefung erforderlich.' \
    'Danach --render; StorageLocation/Schedule siehe k8s/platform/velero/. Kein Clusterzugriff oder Download.'
  exit 0
}
for image in "$server" "$plugin"; do
  [[ "$image" =~ ^[A-Za-z0-9][A-Za-z0-9./:_-]*@sha256:[a-f0-9]{64}$ && "${image##*@sha256:}" != "$(printf '%064d' 0)" ]] || die 'Gepruefte, nicht leere Image-Digests erforderlich.'
done
command -v velero >/dev/null || die 'Gepruefte Velero-CLI separat installieren; kein Download durch diesen Helfer.'
printf '%s\n' 'Nur YAML-Rendering. Vor Apply besonders Cluster-RBAC, Host-Volumes, Restore-Helper und amd64/arm64-Kompatibilitaet pruefen.' >&2
exec velero install --namespace velero --provider aws --image "$server" --plugins "$plugin" \
  --no-secret --no-default-backup-location --use-node-agent --use-volume-snapshots=false \
  --velero-pod-cpu-request 100m --velero-pod-mem-request 128Mi \
  --velero-pod-cpu-limit 1 --velero-pod-mem-limit 512Mi \
  --node-agent-pod-cpu-request 100m --node-agent-pod-mem-request 128Mi \
  --node-agent-pod-cpu-limit 1 --node-agent-pod-mem-limit 1Gi \
  --maintenance-job-cpu-request 100m --maintenance-job-mem-request 128Mi \
  --maintenance-job-cpu-limit 1 --maintenance-job-mem-limit 1Gi \
  --concurrent-backups 1 --dry-run -o yaml
