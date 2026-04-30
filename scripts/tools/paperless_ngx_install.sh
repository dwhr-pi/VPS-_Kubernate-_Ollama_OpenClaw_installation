#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_docker_tool "Paperless_NGX" "https://github.com/paperless-ngx/paperless-ngx.git" "/opt/paperless_ngx" $'services:\n  redis:\n    image: redis:7\n    restart: unless-stopped\n  db:\n    image: postgres:16\n    restart: unless-stopped\n    environment:\n      POSTGRES_DB: paperless\n      POSTGRES_USER: paperless\n      POSTGRES_PASSWORD: paperless\n  webserver:\n    image: ghcr.io/paperless-ngx/paperless-ngx:latest\n    restart: unless-stopped\n    depends_on:\n      - db\n      - redis\n    ports:\n      - "8010:8000"\n    environment:\n      PAPERLESS_REDIS: redis://redis:6379\n      PAPERLESS_DBHOST: db\n      PAPERLESS_DBUSER: paperless\n      PAPERLESS_DBPASS: paperless\n      PAPERLESS_DBNAME: paperless\n    volumes:\n      - ./data:/usr/src/paperless/data\n      - ./media:/usr/src/paperless/media'
