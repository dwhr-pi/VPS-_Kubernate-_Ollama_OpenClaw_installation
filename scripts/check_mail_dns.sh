#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${1:-${MAIL_DOMAIN:-example.tld}}"

echo "Mail-DNS-Check fuer: $DOMAIN"

if [[ "$DOMAIN" == "example.tld" ]]; then
  echo "INFO: Platzhalter-Domain. Fuer echten Check Domain als Argument uebergeben."
fi

if ! command -v dig >/dev/null 2>&1; then
  echo "WARN: dig fehlt. Installiere dnsutils fuer echte DNS-Checks."
  exit 1
fi

dig MX "$DOMAIN" +short || true
dig TXT "$DOMAIN" +short || true
dig TXT "_dmarc.$DOMAIN" +short || true
dig A "mail.$DOMAIN" +short || true
dig AAAA "mail.$DOMAIN" +short || true

echo "Hinweis: PTR/rDNS muss beim VPS-/IP-Provider geprueft werden."

