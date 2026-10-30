#!/usr/bin/env bash
# Quelle: https://github.com/traefik/traefik; geprueften nativen Source-Build uebernehmen.
set -euo pipefail
umask 077
ROOT="$(cd "${BASH_SOURCE[0]%/*}/.." && pwd)"
binary='' digest='' source_commit='' mode=plan start=0
die() {
  printf 'Lokaler Traefik abgebrochen: %s\n' "$*" >&2
  exit 1
}
while (($#)); do
  case "$1" in
    --binary | --sha256 | --source-commit)
      (($# >= 2)) || die 'Optionswert fehlt.'
      case "$1" in --binary) binary=$2 ;; --sha256) digest=$2 ;; --source-commit) source_commit=$2 ;; esac
      shift 2
      ;;
    --apply)
      mode=apply
      shift
      ;;
    --start)
      start=1
      shift
      ;;
    *) die '--binary ABS --sha256 SHA256 --source-commit VOLLER_SHA [--apply --start]' ;;
  esac
done
[[ "$binary" == /* && -f "$binary" && ! -L "$binary" && "$digest" =~ ^[a-f0-9]{64}$ && "$source_commit" =~ ^[a-f0-9]{40}$ ]] || die 'Regulaerer Source-Build, unabhaengig gepruefter Hash und Quellcommit erforderlich.'
printf '%s  %s\n' "$digest" "$binary" | sha256sum --status -c - || die 'Binaer-Hash falsch.'
[[ "$mode" == apply ]] || {
  printf 'Plan: nativer Build, Loopback 80/443, kein Dashboard/Docker/Dienststart.\n'
  exit 0
}
[[ "$EUID" == 0 && $(uname -s) == Linux ]] || die 'Apply nur als root unter Linux.'
state=/usr/local/libexec/openclaw-traefik
config=/etc/openclaw-traefik
for path in "$state" "$config" "$config/dynamic" "$config/tls" /etc/systemd/system/openclaw-traefik.service; do
  [[ ! -L "$path" ]] || die 'Symlink in einem verwalteten Pfad.'
done
if [[ ! -f "$state/source-commit" ]]; then
  [[ ! -e "$state" && ! -e "$config" && ! -e /etc/systemd/system/openclaw-traefik.service ]] || die 'Vorhandene Konfiguration nicht automatisch adoptieren.'
  if id traefik-local >/dev/null 2>&1; then die 'Vorhandenes fremdes Dienstkonto nicht uebernehmen.'; fi
  useradd --system --no-create-home --shell /usr/sbin/nologin traefik-local
  install -d -m 755 "$state"
  install -d -m 750 -g traefik-local "$config" "$config/dynamic" "$config/tls"
  install -m 555 "$binary" "$state/traefik"
  printf '%s\n' "$source_commit" >"$state/source-commit"
  install -m 640 -g traefik-local "$ROOT/config/traefik-local/traefik.yml" "$config/traefik.yml"
  install -m 640 -g traefik-local "$ROOT/config/traefik-local/dynamic/tls.yml" "$config/dynamic/tls.yml"
  install -m 644 "$ROOT/systemd/openclaw-traefik.service" /etc/systemd/system/openclaw-traefik.service
else
  [[ $(cat "$state/source-commit") == "$source_commit" ]] || die 'Anderer Quellstand: Upgrade separat planen.'
  printf '%s  %s\n' "$digest" "$state/traefik" | sha256sum --status -c - || die 'Vorhandener Build weicht ab; nichts ueberschreiben.'
fi
systemctl daemon-reload
if ((start)); then
  command -v openssl >/dev/null || die 'OpenSSL fuer Zertifikatspruefung erforderlich.'
  command -v ss >/dev/null || die 'ss fuer lokale Portkonfliktpruefung erforderlich.'
  for file in origin.crt origin.key; do
    [[ -f "$config/tls/$file" && ! -L "$config/tls/$file" ]] || die 'Zertifikat/Schluessel vor dem Start separat bereitstellen.'
    [[ $(stat -c %u "$config/tls/$file") == 0 && $(stat -c %a "$config/tls/$file") == 640 && $(stat -c %G "$config/tls/$file") == traefik-local ]] || die 'TLS-Dateien muessen root:traefik-local 0640 sein.'
  done
  # Kein TLS-Start mit abgelaufenem Zertifikat oder falschem privaten Schluessel.
  openssl x509 -in "$config/tls/origin.crt" -noout -checkend 86400 >/dev/null 2>&1 || die 'Zertifikat ungueltig oder weniger als einen Tag gueltig.'
  cert_public=$(openssl x509 -in "$config/tls/origin.crt" -pubkey -noout | openssl pkey -pubin -outform DER | sha256sum | cut -d ' ' -f1)
  key_public=$(openssl pkey -in "$config/tls/origin.key" -passin pass: -pubout -outform DER 2>/dev/null | sha256sum | cut -d ' ' -f1)
  [[ "$cert_public" == "$key_public" ]] || die 'Zertifikat und Schluessel passen nicht zusammen.'
  if ! systemctl is-active --quiet openclaw-traefik.service; then
    [[ -z $(ss -H -ltn '( sport = :80 or sport = :443 )') ]] || die 'Port 80 oder 443 bereits belegt; keinen fremden Ingress ersetzen.'
  fi
  systemctl enable --now openclaw-traefik.service
  systemctl is-active --quiet openclaw-traefik.service || die 'Start fehlgeschlagen; Ports/Zertifikate privat pruefen.'
else
  printf 'Nur vorbereitet. Zertifikate und Routes pruefen, danach bewusst --start.\n'
fi
