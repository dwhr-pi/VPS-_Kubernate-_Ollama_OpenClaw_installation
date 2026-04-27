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

echo -e "${BLUE}Starte Deinstallation des Content_Automation-Profils...${NC}"

for tool_script in upload_automation_uninstall.sh thumbnail_pipeline_uninstall.sh trend_monitor_uninstall.sh stable_diffusion_webui_uninstall.sh yt_dlp_uninstall.sh coqui_tts_uninstall.sh piper_uninstall.sh activepieces_uninstall.sh n8n_uninstall.sh playwright_uninstall.sh whisper_uninstall.sh ffmpeg_uninstall.sh; do
    if [ -f "$INSTALL_DIR/scripts/tools/$tool_script" ]; then
        echo -e "${BLUE}Deinstalliere ${tool_script%.sh} als Teil des Content_Automation-Profils...${NC}"
        bash "$INSTALL_DIR/scripts/tools/$tool_script"
    else
        echo -e "${YELLOW}${tool_script} nicht gefunden. Überspringe diesen Baustein.${NC}"
    fi
done

echo -e "${GREEN}Content_Automation-Profil Deinstallation abgeschlossen.${NC}"
mark_current_profile_removed
