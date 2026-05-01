#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_docker_tool "CrowdSec" "https://github.com/crowdsecurity/crowdsec.git" "/opt/crowdsec" $'services:\n  crowdsec:\n    image: crowdsecurity/crowdsec:latest\n    restart: unless-stopped\n    volumes:\n      - /var/log:/var/log:ro\n      - ./data:/var/lib/crowdsec/data'
