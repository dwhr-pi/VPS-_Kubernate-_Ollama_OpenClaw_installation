#!/usr/bin/env bash
# Offline-Verschluesselung: kein Klartextfile, kein API-Aufruf und kein Apply.
set -euo pipefail
set +x
umask 077
cert='' cert_sha='' output='' namespace=ai-agents name=openclaw-api key=OPENCLAW_API_KEY
die() {
  printf 'Sealing abgebrochen: %s\n' "$*" >&2
  exit 1
}
while (($#)); do
  case "$1" in
    --cert | --cert-sha256 | --output | --namespace | --name | --key)
      (($# >= 2)) || die 'Optionswert fehlt.'
      case "$1" in
        --cert) cert=$2 ;; --cert-sha256) cert_sha=$2 ;; --output) output=$2 ;;
        --namespace) namespace=$2 ;; --name) name=$2 ;; --key) key=$2 ;;
      esac
      shift 2
      ;;
    *) die 'Erforderlich: --cert ABS --cert-sha256 SHA256 --output ABS; optional --namespace --name --key.' ;;
  esac
done
[[ "$cert" == /* && -f "$cert" && ! -L "$cert" ]] || die 'Absolutes regulaeres Controller-Zertifikat erforderlich.'
[[ "$cert_sha" =~ ^[a-f0-9]{64}$ ]] || die 'Separat verifizierter Zertifikat-Dateihash erforderlich.'
[[ $(sha256sum -- "$cert" | cut -d ' ' -f1) == "$cert_sha" ]] || die 'Controller-Zertifikat stimmt nicht mit dem Vertrauensanker ueberein.'
[[ "$output" == /* && ! -e "$output" && ! -L "$output" && -d "${output%/*}" ]] || die 'Neuer absoluter Ausgabepfad in vorhandenem Verzeichnis erforderlich.'
[[ "$namespace" =~ ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$ && ${#namespace} -le 63 ]] || die 'Namespace ungueltig.'
[[ "$name" =~ ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$ && ${#name} -le 63 ]] || die 'Secret-Name ungueltig.'
[[ "$key" =~ ^[A-Za-z0-9_.-]+$ ]] || die 'Secret-Feldname ungueltig.'
for tool in kubeseal python3; do command -v "$tool" >/dev/null || die "Werkzeug fehlt: $tool"; done
[[ -t 0 ]] || die 'Secret nur interaktiv verdeckt eingeben; kein Key in CLI-Argumenten.'
secret='' stage=''
cleanup() {
  unset secret
  [[ -z "$stage" ]] || rm -f -- "$stage"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
read -r -s -p 'Secret eingeben (keine Anzeige): ' secret
printf '\n' >&2
[[ -n "$secret" ]] || die 'Leeres Secret nicht erlaubt.'
stage=$(mktemp "${output%/*}/.sealed.XXXXXXXX")
# Nur stdin enthaelt Klartext; Namespace/Name werden kryptographisch gebunden.
printf '%s' "$secret" | python3 -I -B -c '
import base64, json, sys
print(json.dumps({"apiVersion":"v1", "kind":"Secret", "metadata":{
    "namespace":sys.argv[1], "name":sys.argv[2]}, "type":"Opaque", "data":{
    sys.argv[3]:base64.b64encode(sys.stdin.buffer.read()).decode("ascii")}}))
' "$namespace" "$name" "$key" | kubeseal --cert "$cert" --scope strict --format yaml >"$stage"
unset secret
[[ -s "$stage" ]] || die 'Keine verschluesselte Ausgabe erhalten.'
# Hardlink verhindert Ueberschreiben auch bei konkurrierendem Dateianlegen.
ln -- "$stage" "$output"
printf 'Verschluesseltes Manifest erstellt; kein Clusterzugriff oder Apply.\n'
