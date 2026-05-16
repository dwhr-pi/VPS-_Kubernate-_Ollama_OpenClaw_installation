#!/bin/bash
# ==============================================================================
# AUTHENTIK_INSTALL.SH - Vorlagen fuer optionale Authentik/OIDC-Schicht
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
init_tool_tracking "Authentik"

USER_WORKSPACE_DIR="${USER_WORKSPACE_DIR:-$HOME/.openclaw_ultimate_user_data}"
AUTH_DIR="$USER_WORKSPACE_DIR/auth/authentik"

echo -e "${BLUE}Bereite Authentik-Vorlagen vor...${NC}"
echo -e "${YELLOW}Hinweis: Es werden keine Secrets erzeugt und kein produktiver Dienst gestartet.${NC}"

mkdir -p "$AUTH_DIR"
chmod 700 "$USER_WORKSPACE_DIR/auth" "$AUTH_DIR" 2>/dev/null || true

cat > "$AUTH_DIR/.env.template" <<'EOF'
# Authentik lokale Vorlage - keine echten Secrets ins Repo
AUTHENTIK_DOMAIN=auth.example.local
AUTHENTIK_PORT_HTTP=9010
AUTHENTIK_PORT_HTTPS=9444
AUTHENTIK_POSTGRES_DB=authentik
AUTHENTIK_POSTGRES_USER=authentik
AUTHENTIK_POSTGRES_PASSWORD=change-me-outside-repo
AUTHENTIK_SECRET_KEY=change-me-outside-repo
AUTHENTIK_BOOTSTRAP_EMAIL=admin@example.local
AUTHENTIK_BOOTSTRAP_PASSWORD=change-me-outside-repo
EOF

cat > "$AUTH_DIR/docker-compose.example.yml" <<'EOF'
# Beispielvorlage. Vor produktiver Nutzung Secrets, Volumes, TLS und Reverse Proxy pruefen.
services:
  authentik-server:
    image: ghcr.io/goauthentik/server:latest
    command: server
    env_file: .env
    ports:
      - "127.0.0.1:${AUTHENTIK_PORT_HTTP:-9000}:9000"
      - "127.0.0.1:${AUTHENTIK_PORT_HTTPS:-9443}:9443"
  authentik-worker:
    image: ghcr.io/goauthentik/server:latest
    command: worker
    env_file: .env
  authentik-postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: "${AUTHENTIK_POSTGRES_DB:-authentik}"
      POSTGRES_USER: "${AUTHENTIK_POSTGRES_USER:-authentik}"
      POSTGRES_PASSWORD: "${AUTHENTIK_POSTGRES_PASSWORD:-change-me}"
    volumes:
      - authentik_postgres:/var/lib/postgresql/data
volumes:
  authentik_postgres:
EOF

cat > "$AUTH_DIR/README.md" <<'EOF'
# Authentik im OpenClaw Setup

Authentik ist eine optionale Identity-Provider-/SSO-Schicht fuer Webdienste.

Diese Vorlage startet bewusst nichts automatisch. Vor produktiver Nutzung:

1. `.env.template` nach `.env` kopieren.
2. Starke lokale Secrets setzen.
3. Reverse Proxy/TLS festlegen.
4. OIDC-App fuer Zielsysteme wie Clawbake, Grafana oder Dashboards anlegen.
5. Keine Secrets ins Repository schreiben.

Authentik eignet sich eher fuer VPS, K3s und Homelab-Setups mit mehreren Diensten.
EOF

mark_current_tool_installed
echo -e "${GREEN}Authentik-Vorlagen vorbereitet:${NC} $AUTH_DIR"
