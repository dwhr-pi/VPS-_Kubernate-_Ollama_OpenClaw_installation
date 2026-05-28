#!/usr/bin/env bash
set -euo pipefail

MODE="${1:---dry-run}"

run() {
  if [[ "$MODE" == "--apply" ]]; then
    "$@"
  else
    printf 'DRY-RUN:'
    printf ' %q' "$@"
    printf '\n'
  fi
}

case "$MODE" in
  --dry-run|--apply) ;;
  --help|-h)
    echo "Usage: sudo bash scripts/security/setup-crowdsec.sh [--dry-run|--apply]"
    exit 0
    ;;
  *)
    echo "Bitte --dry-run oder --apply verwenden." >&2
    exit 2
    ;;
esac

echo "CrowdSec Setup fuer Oracle VPS / Reverse Proxy"
echo "Hinweis: Bouncer je nach Proxy/Firewall separat auswaehlen."

run apt-get update
run apt-get install -y crowdsec
run cscli collections install crowdsecurity/sshd
run cscli collections install crowdsecurity/nginx
run cscli collections install crowdsecurity/traefik
run cscli collections install crowdsecurity/linux
run systemctl enable --now crowdsec
run cscli metrics
