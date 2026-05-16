#!/bin/bash
# ==============================================================================
# AUTHELIA_INSTALL.SH - Vorlagen fuer optionale Authelia/Auth-Schicht
# ==============================================================================

set -euo pipefail

GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "Authelia"

USER_WORKSPACE_DIR="${USER_WORKSPACE_DIR:-$HOME/.openclaw_ultimate_user_data}"
AUTH_DIR="$USER_WORKSPACE_DIR/auth/authelia"

echo -e "${BLUE}Bereite Authelia-Vorlagen vor...${NC}"
echo -e "${YELLOW}Hinweis: Es werden keine Secrets erzeugt und kein produktiver Dienst gestartet.${NC}"

mkdir -p "$AUTH_DIR"
chmod 700 "$USER_WORKSPACE_DIR/auth" "$AUTH_DIR" 2>/dev/null || true

cat > "$AUTH_DIR/configuration.example.yml" <<'EOF'
# Authelia Beispielkonfiguration - keine echten Secrets ins Repo
server:
  address: tcp://127.0.0.1:9091/

log:
  level: info

totp:
  issuer: openclaw.local

authentication_backend:
  file:
    path: /config/users_database.yml

access_control:
  default_policy: deny
  rules:
    - domain: "*.example.local"
      policy: two_factor

session:
  name: authelia_session
  secret: change-me-outside-repo

storage:
  encryption_key: change-me-outside-repo
  local:
    path: /config/db.sqlite3

notifier:
  filesystem:
    filename: /config/notification.txt
EOF

cat > "$AUTH_DIR/docker-compose.example.yml" <<'EOF'
services:
  authelia:
    image: authelia/authelia:latest
    ports:
      - "127.0.0.1:9091:9091"
    volumes:
      - ./configuration.yml:/config/configuration.yml:ro
      - ./users_database.yml:/config/users_database.yml
      - ./data:/config
EOF

cat > "$AUTH_DIR/README.md" <<'EOF'
# Authelia im OpenClaw Setup

Authelia ist eine optionale schlanke Auth-/SSO-/MFA-Schicht vor Webdiensten.

Diese Vorlage startet bewusst nichts automatisch. Vor produktiver Nutzung:

1. `configuration.example.yml` nach `configuration.yml` kopieren.
2. `session.secret` und `storage.encryption_key` lokal stark setzen.
3. Benutzerdatei `users_database.yml` lokal erzeugen.
4. Reverse Proxy wie Caddy, Traefik oder Nginx davor setzen.
5. Keine Secrets ins Repository schreiben.

Authelia eignet sich gut fuer MiniPC, Homelab und VPS, wenn mehrere Web-UIs geschuetzt werden sollen.
EOF

mark_current_tool_installed
echo -e "${GREEN}Authelia-Vorlagen vorbereitet:${NC} $AUTH_DIR"
