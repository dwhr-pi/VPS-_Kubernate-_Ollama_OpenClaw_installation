#!/usr/bin/env bash
set -euo pipefail

MODE="${1:---dry-run}"
JAIL_FILE="/etc/fail2ban/jail.d/openclaw-hardening.local"

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
    echo "Usage: sudo bash scripts/security/setup-fail2ban.sh [--dry-run|--apply]"
    exit 0
    ;;
  *)
    echo "Bitte --dry-run oder --apply verwenden." >&2
    exit 2
    ;;
esac

echo "Fail2Ban Setup fuer SSH und Reverse Proxy Auth"
run apt-get update
run apt-get install -y fail2ban

if [[ "$MODE" == "--apply" ]]; then
  cat > "$JAIL_FILE" <<'EOF'
[sshd]
enabled = true
mode = aggressive
maxretry = 5
findtime = 10m
bantime = 1h

[nginx-http-auth]
enabled = true
maxretry = 5
findtime = 10m
bantime = 1h

[nginx-badbots]
enabled = true
maxretry = 2
findtime = 1h
bantime = 24h
EOF
fi

run systemctl enable --now fail2ban
run fail2ban-client status
