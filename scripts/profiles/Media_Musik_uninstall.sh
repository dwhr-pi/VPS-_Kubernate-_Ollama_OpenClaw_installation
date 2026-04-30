#!/bin/bash
#
# Skript: Media_Musik_uninstall.sh
# Beschreibung: Dieses Skript deinstalliert Tools und Konfigurationen, die zum Media & Musik Profil gehören.
# Es entfernt die entsprechenden Softwarepakete und Konfigurationsdateien.
# Verwendung: Wird vom Haupt-Setup-Skript aufgerufen, wenn das Media & Musik Profil deinstalliert wird.
#

# Farben
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_profile_tracking "Media_Musik"

echo -e "${BLUE}Starte Deinstallation des Media & Musik Profils...${NC}"

# Beispiel: Deinstallation von Clawbake (falls installiert)
if [ -f "$INSTALL_DIR/scripts/tools/clawbake_uninstall.sh" ]; then
    echo -e "${BLUE}Deinstalliere Clawbake als Teil des Media & Musik Profils...${NC}"
    bash "$INSTALL_DIR/scripts/tools/clawbake_uninstall.sh"
else
    echo -e "${YELLOW}Clawbake Deinstallationsskript nicht gefunden. Überspringe Clawbake Deinstallation.${NC}"
fi

# FFmpeg deinstallieren
if [ -f "$INSTALL_DIR/scripts/tools/ffmpeg_uninstall.sh" ]; then
    echo -e "${BLUE}Deinstalliere FFmpeg als Teil des Media & Musik Profils...${NC}"
    bash "$INSTALL_DIR/scripts/tools/ffmpeg_uninstall.sh"
else
    echo -e "${YELLOW}FFmpeg Deinstallationsskript nicht gefunden. Überspringe FFmpeg Deinstallation.${NC}"
fi

for tool_script in emotion_tagging_uninstall.sh tiktok_score_uninstall.sh bpm_analyzer_uninstall.sh hook_detection_uninstall.sh music2p_pipeline_uninstall.sh controlnet_uninstall.sh stable_diffusion_webui_uninstall.sh riffusion_uninstall.sh musicgen_uninstall.sh udio_api_uninstall.sh suno_api_uninstall.sh whisper_uninstall.sh demucs_uninstall.sh pydub_uninstall.sh librosa_uninstall.sh; do
    if [ -f "$INSTALL_DIR/scripts/tools/$tool_script" ]; then
        echo -e "${BLUE}Deinstalliere ${tool_script%.sh} als Teil des Media & Musik Profils...${NC}"
        bash "$INSTALL_DIR/scripts/tools/$tool_script"
    else
        echo -e "${YELLOW}${tool_script} nicht gefunden. Überspringe diesen Baustein.${NC}"
    fi
done

echo -e "${GREEN}Media & Musik Profil Deinstallation abgeschlossen.${NC}"
mark_current_profile_removed
