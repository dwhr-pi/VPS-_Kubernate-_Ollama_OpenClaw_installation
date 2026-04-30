#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_docker_tool "Stirling_PDF" "https://github.com/Stirling-Tools/Stirling-PDF.git" "/opt/stirling_pdf" $'services:\n  stirling-pdf:\n    image: frooodle/s-pdf:latest\n    ports:\n      - "8081:8080"\n    restart: unless-stopped\n    volumes:\n      - ./data:/usr/share/tessdata'
