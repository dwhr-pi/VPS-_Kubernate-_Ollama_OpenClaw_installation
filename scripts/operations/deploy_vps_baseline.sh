#!/usr/bin/env bash
# Install/update existing k3s workloads only; never provision the host implicitly.
set -euo pipefail
umask 077
ROOT="$(cd -- "${BASH_SOURCE[0]%/*}/../.." && pwd)"
mode=check
overlay=
context=
confirmed=0
data_dir=/var/lib/rancher/k3s
runtime_unit=k3s
die() {
  printf 'VPS-Deployment abgebrochen: %s\n' "$*" >&2
  exit 1
}
while (($#)); do
  case "$1" in
    --check | --plan | --apply)
      mode=${1#--}
      shift
      ;;
    --overlay | --context | --data-dir | --runtime-unit)
      (($# >= 2)) || die 'Optionswert fehlt.'
      case "$1" in
        --overlay) overlay=$2 ;;
        --context) context=$2 ;;
        --data-dir) data_dir=$2 ;;
        --runtime-unit) runtime_unit=$2 ;;
      esac
      shift 2
      ;;
    --confirm-apply)
      confirmed=1
      shift
      ;;
    --help)
      printf '%s\n' 'deploy_vps_baseline.sh --check|--plan|--apply [--data-dir ABS] [--runtime-unit k3s|k3s-agent|containerd] [--overlay ABS] [--context NAME --confirm-apply]'
      exit 0
      ;;
    *) die 'Unbekannte Option.' ;;
  esac
done
if [[ "$mode" == apply ]]; then
  [[ "$confirmed" == 1 && -n "$context" && "$context" != -* ]] || die '--context und --confirm-apply ausdruecklich erforderlich.'
fi
[[ $(uname -s) == Linux ]] || die 'Nur lokaler Linux-VPS; kein Windows-/Remote-Hostcheck.'
case "$runtime_unit" in k3s | k3s-agent | containerd) ;; *) die 'Runtime-Unit nicht freigegeben.' ;; esac
command -v python3 >/dev/null || die 'Vorhandenes Python 3 erforderlich.'
python3 -I -B "$ROOT/scripts/quality/vps_host_preflight.py" --data-dir "$data_dir"
command -v systemctl >/dev/null || die 'systemctl erforderlich; Runtime separat pruefen.'
systemctl is-active --quiet "$runtime_unit" || die 'Gewaehlte Runtime-Unit ist nicht aktiv oder nicht pruefbar.'
printf 'Lokale Vorpruefung erfolgreich. Keine Installation oder Swap-Aenderung.\n'
[[ "$mode" != check ]] || exit 0
[[ "$overlay" == /* && -d "$overlay" && ! -L "$overlay" ]] || die 'Absolutes geprueftes Deployment-Overlay erforderlich.'
for tool in kubectl kubeconform; do command -v "$tool" >/dev/null || die "Werkzeug fehlt: $tool"; done
stage=$(mktemp -d)
cleanup() {
  rm -f -- "$stage/manifest.yaml"
  rmdir -- "$stage"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
kubectl kustomize "$overlay" >"$stage/manifest.yaml"
python3 -I -B "$ROOT/scripts/quality/production_preflight.py" <"$stage/manifest.yaml"
# Runtime manifests must not contain Secret payloads, even encrypted ones.
if grep -Eq '^[[:space:]]*kind:[[:space:]]+Secret[[:space:]]*$' "$stage/manifest.yaml"; then
  die 'Secrets separat ueber SOPS/Secret-Management verwalten, nicht im Runtime-Apply.'
fi
kubeconform -strict -summary "$stage/manifest.yaml"
[[ "$mode" == apply ]] || {
  printf 'Plan validiert; kein Clusterzugriff/Apply durch diesen Skriptpfad.\n'
  exit 0
}
kube=(kubectl --context "$context" --request-timeout=30s)
"${kube[@]}" get namespace llmops -o name >/dev/null
has_key=$("${kube[@]}" get secret litellm-runtime -n llmops -o 'go-template={{if index .data "master-key"}}present{{end}}')
[[ "$has_key" == present ]] || die 'Vorhandenes Secret braucht einen nichtleeren master-key.'
"${kube[@]}" apply --server-side --field-manager=llmops-baseline --dry-run=server --validate=strict -f "$stage/manifest.yaml"
"${kube[@]}" apply --server-side --field-manager=llmops-baseline --validate=strict -f "$stage/manifest.yaml"
kubectl --context "$context" --request-timeout=16m rollout status statefulset/ollama -n llmops --timeout=15m
kubectl --context "$context" --request-timeout=6m rollout status deployment/litellm -n llmops --timeout=5m
printf 'Workloads ausgerollt; Modell-Inferenz, Auth, Netzwerk und Restore separat abnehmen.\n'
