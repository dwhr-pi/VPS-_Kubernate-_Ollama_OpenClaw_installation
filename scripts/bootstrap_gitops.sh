#!/usr/bin/env bash
# Infrastruktur-Bootstrap nur nach ausdruecklicher Freigabe; kein Workload-Apply.
set -euo pipefail
umask 077
ROOT="$(cd "${BASH_SOURCE[0]%/*}/.." && pwd)"
PYTHON_BIN=${GITOPS_PYTHON_BIN:-python3}
mode=plan lock='' address='' confirmed=0 firewall_confirmed=0
die() {
  printf 'GitOps-Bootstrap abgebrochen: %s\n' "$*" >&2
  exit 1
}
while (($#)); do
  case "$1" in
    --plan | --apply)
      mode=${1#--}
      shift
      ;;
    --artifacts | --private-address)
      (($# >= 2)) || die 'Optionswert fehlt.'
      case "$1" in --artifacts) lock=$2 ;; --private-address) address=$2 ;; esac
      shift 2
      ;;
    --confirm-new-host)
      confirmed=1
      shift
      ;;
    --confirm-private-firewall)
      firewall_confirmed=1
      shift
      ;;
    *) die '--plan|--apply --artifacts ABS --private-address IP [--confirm-new-host --confirm-private-firewall]' ;;
  esac
done
[[ "$lock" == /* && -f "$lock" && ! -L "$lock" ]] || die 'Absolute gepruefte JSON-Artefaktdatei erforderlich.'
command -v "$PYTHON_BIN" >/dev/null || die 'Vorhandenes Python 3 erforderlich.'
case "$(uname -m)" in x86_64 | amd64) arch=linux-amd64 ;; aarch64 | arm64) arch=linux-arm64 ;; *) die 'Nur x86_64/arm64.' ;; esac
"$PYTHON_BIN" -I -B "$ROOT/scripts/lib/gitops_artifacts.py" "$lock" --arch "$arch" --private-address "$address" || exit 1
[[ "$mode" == apply ]] || {
  printf 'Nur Plan: kein Netz, sudo, Clusterzugriff oder Dienststart.\n'
  exit 0
}
[[ "$confirmed" == 1 && "$firewall_confirmed" == 1 && "$EUID" == 0 && $(uname -s) == Linux ]] || die 'Apply nur als root unter Linux mit --confirm-new-host und --confirm-private-firewall.'
for tool in curl sha256sum install cmp stat systemctl flock ip awk grep ps df cat; do command -v "$tool" >/dev/null || die "Werkzeug fehlt: $tool"; done
[[ $(ps -p 1 -o comm=) == systemd ]] || die 'systemd als PID 1 erforderlich; WSL vorher bewusst konfigurieren.'
[[ $(stat -c %u -- "$lock") == 0 ]] || die 'Apply-Lockdatei muss root gehoeren.'
permissions=$(stat -c %a -- "$lock")
(((8#$permissions & 8#022) == 0)) || die 'Artefaktdatei darf nicht gruppen-/weltbeschreibbar sein.'
# Auch Verzeichnis-Austausch durch einen fremden Besitzer ausschliessen.
"$PYTHON_BIN" -I -B -c 'import pathlib,sys; p=pathlib.Path(sys.argv[1]).resolve(); assert all(x.stat().st_uid==0 and not x.stat().st_mode & 0o022 for x in [p,*p.parents]), "root-eigener, nicht fremdbeschreibbarer Lockpfad erforderlich"' "$lock"
interface=$(ip -4 -o addr show | awk -v wanted="$address" '{split($4,a,"/"); if(a[1]==wanted) print $2}')
[[ "$interface" =~ ^[A-Za-z0-9_.:-]+$ ]] || die 'Private Adresse muss genau einer vorhandenen Schnittstelle zugeordnet sein.'
ram_kib=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
available_kib=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
((ram_kib >= 4194304 && available_kib >= 2097152)) || die 'Planungsreserve: 4 GiB RAM gesamt und 2 GiB verfuegbar fuer K3s/Argo Core erforderlich.'
free_kib=$(df -Pk /var/lib | awk 'NR==2 {print $4}')
((free_kib >= 12582912)) || die 'Mindestens 12 GiB Linux-Diskreserve; Modellgewichte kommen separat hinzu.'
if grep -qi microsoft /proc/sys/kernel/osrelease; then
  # Freie virtuelle Linux-Kapazitaet allein schuetzt den Windows-Host nicht.
  source "$ROOT/scripts/lib/resource_check.sh"
  windows_mb=$(snapshot_windows_host_disk_mb 2>/dev/null || true)
  [[ "$windows_mb" =~ ^[0-9]+$ && "$windows_mb" -ge 12288 ]] || die 'WSL: Windows-Host-Reserve nicht verifiziert oder unter 12 GiB. VHDX-Laufwerk separat pruefen.'
fi
token=/etc/openclaw-gitops/cloudflared.token
[[ -d /etc/openclaw-gitops && ! -L /etc/openclaw-gitops && $(stat -c %u /etc/openclaw-gitops) == 0 && $(stat -c %a /etc/openclaw-gitops) == 700 ]] || die 'Token-Verzeichnis muss root:0700 sein.'
[[ -f "$token" && ! -L "$token" && -s "$token" ]] || die 'Tunnel-Token muss vorab privat in /etc/openclaw-gitops/cloudflared.token liegen.'
[[ $(stat -c %u -- "$token") == 0 && $(stat -c %a -- "$token") == 600 ]] || die 'Tunnel-Token muss root:0600 sein; Inhalt wird nicht ausgegeben.'
state=/var/lib/openclaw-gitops-bootstrap
[[ ! -L "$state" ]] || die 'Bootstrap-Ziel darf kein Symlink sein.'
if [[ -e "$state" ]]; then
  [[ -d "$state" && $(stat -c %u -- "$state") == 0 && $(stat -c %a -- "$state") == 700 ]] || die 'Vorhandenes Bootstrap-Verzeichnis muss root:0700 sein.'
fi
install -d -m 700 "$state"
for path in "$state/runner.lock" "$state/owned-artifacts.json" "$state/private-address"; do
  [[ ! -L "$path" ]] || die 'Verwaltete Statusdateien duerfen keine Symlinks sein.'
done
exec 9>"$state/runner.lock"
flock -n 9 || die 'Bootstrap bereits aktiv.'
if [[ -f "$state/owned-artifacts.json" ]]; then
  cmp -s -- "$lock" "$state/owned-artifacts.json" || die 'Andere Artefakte: Update/Migration separat planen, nichts ueberschreiben.'
  [[ $(cat "$state/private-address") == "$address" ]] || die 'Andere private Adresse: Migration erforderlich.'
else
  ! command -v k3s >/dev/null || die 'K3s bereits im PATH; kein implizites Adoptieren.'
  ! command -v cloudflared >/dev/null || die 'Cloudflared bereits im PATH; kein implizites Adoptieren.'
  for path in /usr/local/bin/k3s /usr/local/bin/cloudflared /etc/rancher/k3s /var/lib/rancher/k3s /etc/systemd/system/k3s.service /etc/systemd/system/cloudflared.service /etc/systemd/system/openclaw-cloudflared.service /usr/local/share/openclaw-gitops; do
    [[ ! -e "$path" && ! -L "$path" ]] || die 'Vorhandene/fremde Installation: kein automatisches Adoptieren oder Ueberschreiben.'
  done
  install -m 600 "$lock" "$state/owned-artifacts.json"
  printf '%s\n' "$address" >"$state/private-address"
fi
stage=$(mktemp -d "$state/stage.XXXXXXXX")
cleanup() {
  rm -f -- "$stage/lines" "$stage/payload" "$stage/argocd.pinned.yaml"
  rmdir -- "$stage"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
"$PYTHON_BIN" -I -B "$ROOT/scripts/lib/gitops_artifacts.py" "$lock" --arch "$arch" --private-address "$address" --lines >"$stage/lines"
mapfile -t items <"$stage/lines"
((${#items[@]} == 12)) || die 'Ungueltige Artefaktliste.'
# Alle Downloads pruefen, bevor irgendein Dienst installiert wird.
for ((i = 0; i < 12; i += 3)); do
  name=${items[i]} url=${items[i + 1]} hash=${items[i + 2]}
  [[ ! -L "$state/$name" ]] || die 'Artefaktcache darf keine Symlinks enthalten.'
  if [[ -f "$state/$name" ]] && printf '%s  %s\n' "$hash" "$state/$name" | sha256sum --status -c -; then continue; fi
  curl -q --fail --silent --show-error --location --proto '=https' --proto-redir '=https' --connect-timeout 15 --max-time 300 --retry 2 --output "$stage/payload" "$url"
  printf '%s  %s\n' "$hash" "$stage/payload" | sha256sum --status -c - || die 'SHA256-Abweichung; nichts ausgefuehrt.'
  install -m 600 "$stage/payload" "$state/$name"
done
# Auch alle Container/Init-Container des Vendor-Manifests auf freigegebene Digests pinnen.
"$PYTHON_BIN" -I -B "$ROOT/scripts/lib/gitops_artifacts.py" "$lock" --arch "$arch" --private-address "$address" \
  --pin-argocd "$state/argocd" --output "$stage/argocd.pinned.yaml"
for name in k3s cloudflared; do
  [[ ! -L /usr/local/bin/$name ]] || die 'Vorhandene Binaerdatei ist ein Symlink; manuell pruefen.'
  if [[ -e /usr/local/bin/$name ]]; then
    cmp -s -- "$state/$name" "/usr/local/bin/$name" || die 'Vorhandene Binaerdatei weicht ab; kein Ueberschreiben.'
  else
    install -m 755 "$state/$name" "/usr/local/bin/$name"
  fi
done
if ! systemctl is-active --quiet k3s; then
  # Gepruefter GitHub-Installer ohne weiteren Binary-Download. Traefik bleibt aktiv.
  env -i PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin HOME=/root \
    INSTALL_K3S_SKIP_DOWNLOAD=true INSTALL_K3S_SYMLINK=skip INSTALL_K3S_SKIP_SELINUX_RPM=true \
    bash "$state/k3s_installer" server --bind-address "$address" --advertise-address "$address" \
    --node-ip "$address" --flannel-iface "$interface" --disable servicelb --write-kubeconfig-mode 600 \
    --kubelet-arg 'system-reserved=cpu=200m,memory=512Mi,ephemeral-storage=1Gi' \
    --kubelet-arg 'kube-reserved=cpu=200m,memory=512Mi,ephemeral-storage=1Gi'
fi
kube=(/usr/local/bin/k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml --request-timeout=30s)
api_ready=0
for ((attempt = 0; attempt < 30; attempt++)); do
  if "${kube[@]}" get --raw /readyz >/dev/null 2>&1; then
    api_ready=1
    break
  fi
  sleep 2
done
[[ "$api_ready" == 1 ]] || die 'K3s-API noch nicht bereit; Logs privat pruefen, gleicher Bootstrap ist wiederholbar.'
"${kube[@]}" --request-timeout=200s wait --for=condition=Ready nodes --all --timeout=180s
# Argo Core spart UI-/SSO-Komponenten. Kein externer Argo-Service/Ingress.
"${kube[@]}" create namespace argocd --dry-run=client -o yaml | "${kube[@]}" apply -f -
"${kube[@]}" apply -n argocd -f "$ROOT/k8s/gitops/platform/argocd-budget.yaml"
"${kube[@]}" apply --server-side --field-manager=openclaw-gitops-bootstrap -n argocd -f "$stage/argocd.pinned.yaml"
"${kube[@]}" --request-timeout=200s rollout status deployment/argocd-repo-server -n argocd --timeout=180s
"${kube[@]}" --request-timeout=200s rollout status statefulset/argocd-application-controller -n argocd --timeout=180s
[[ ! -L /etc/systemd/system/openclaw-cloudflared.service ]] || die 'Tunnel-Unit darf kein Symlink sein.'
if [[ -e /etc/systemd/system/openclaw-cloudflared.service ]]; then
  cmp -s -- "$ROOT/systemd/openclaw-cloudflared.service" /etc/systemd/system/openclaw-cloudflared.service || die 'Tunnel-Unit lokal geaendert; kein automatisches Ueberschreiben.'
fi
install -m 644 "$ROOT/systemd/openclaw-cloudflared.service" /etc/systemd/system/openclaw-cloudflared.service
systemctl daemon-reload
systemctl enable --now openclaw-cloudflared.service
systemctl is-active --quiet openclaw-cloudflared.service || die 'Tunnel-Daemon nicht aktiv; keine Tokenausgabe.'
[[ ! -L /usr/local/share/openclaw-gitops ]] || die 'Statusverzeichnis darf kein Symlink sein.'
install -d -m 755 /usr/local/share/openclaw-gitops
printf '{"scope":"bootstrap-infrastructure-only","applications_deployed":false}\n' >"$stage/payload"
install -m 644 "$stage/payload" /usr/local/share/openclaw-gitops/bootstrap-ready.json
printf 'Bootstrap fertig. Traefik und Local Path bleiben erhalten.\n'
printf 'Weitere Installationen (Ollama, OpenClaw, n8n, RAG) nur nach Review ueber ArgoCD App-of-Apps.\n'
printf 'Kein App-of-Apps-Apply ausgefuehrt. Anleitung: docs/GITOPS_SMALL_VPS.md\n'
