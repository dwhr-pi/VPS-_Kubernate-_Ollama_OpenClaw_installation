#!/bin/bash
#
# Skript: Media_Musik_install.sh
# Beschreibung: Dieses Skript installiert Tools und Konfigurationen, die speziell für die Bearbeitung von Medien (Audio/Video) und Musikproduktion nützlich sind.
# Es umfasst Audio-Workstations, Video-Editoren und KI-Tools zur Mediengenerierung oder -analyse.
# Verwendung: Wird vom Haupt-Setup-Skript aufgerufen, wenn das Media & Musik Profil ausgewählt wird.
#

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

echo -e "${BLUE}Starte Installation des Media & Musik Profils...${NC}"

# Beispiel: Installation von Clawbake (falls noch nicht geschehen)
# Clawbake ist ein Tool zur Automatisierung von Builds und Deployments, das auch für Medienprojekte nützlich sein kann.
if [ -f "$INSTALL_DIR/scripts/tools/clawbake_install.sh" ]; then
    echo -e "${BLUE}Installiere Clawbake als Teil des Media & Musik Profils...${NC}"
    "$INSTALL_DIR/scripts/tools/clawbake_install.sh"
else
    echo -e "${YELLOW}Clawbake Installationsskript nicht gefunden. Überspringe Clawbake Installation.${NC}"
fi

# FFmpeg für Audio-/Video-Verarbeitung
if [ -f "$INSTALL_DIR/scripts/tools/ffmpeg_install.sh" ]; then
    echo -e "${BLUE}Installiere FFmpeg als Teil des Media & Musik Profils...${NC}"
    "$INSTALL_DIR/scripts/tools/ffmpeg_install.sh"
else
    echo -e "${YELLOW}FFmpeg Installationsskript nicht gefunden. Überspringe FFmpeg Installation.${NC}"
fi

for tool_script in librosa_install.sh pydub_install.sh demucs_install.sh whisper_install.sh; do
    if [ -f "$INSTALL_DIR/scripts/tools/$tool_script" ]; then
        echo -e "${BLUE}Installiere ${tool_script%.sh} als Teil des Media & Musik Profils...${NC}"
        "$INSTALL_DIR/scripts/tools/$tool_script"
    else
        echo -e "${YELLOW}${tool_script} nicht gefunden. Überspringe diesen Baustein.${NC}"
    fi
done

echo -e "${GREEN}Media & Musik Profil Installation abgeschlossen.${NC}"
