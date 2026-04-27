#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_profile_tracking "Content_Automation"

echo -e "${BLUE}Starte Installation des Content_Automation-Profils...${NC}"

for tool_script in ffmpeg_install.sh whisper_install.sh playwright_install.sh n8n_install.sh activepieces_install.sh piper_install.sh coqui_tts_install.sh yt_dlp_install.sh stable_diffusion_webui_install.sh trend_monitor_install.sh thumbnail_pipeline_install.sh upload_automation_install.sh; do
    if [ -f "$INSTALL_DIR/scripts/tools/$tool_script" ]; then
        echo -e "${BLUE}Installiere ${tool_script%.sh} als Teil des Content_Automation-Profils...${NC}"
        bash "$INSTALL_DIR/scripts/tools/$tool_script"
    else
        echo -e "${YELLOW}${tool_script} nicht gefunden. Überspringe diesen Baustein.${NC}"
    fi
done

echo -e "${GREEN}Content_Automation-Profil Installation abgeschlossen.${NC}"
mark_current_profile_installed
