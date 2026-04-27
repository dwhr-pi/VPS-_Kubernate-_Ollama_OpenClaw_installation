#!/bin/bash
#
# Skript: huge_facing_install.sh
# Beschreibung: Dieses Skript integriert Hugging Face Modelle in das Setup.
# Es bietet Anleitungen zur Nutzung von Hugging Face Modellen mit Ollama (lokal) oder über die Hugging Face Inference API (online).
# Es installiert keine direkte Software, sondern konfiguriert die Umgebung für die Nutzung von Hugging Face.
# Verwendung: Wird vom Haupt-Setup-Skript aufgerufen, wenn 'Huge Facing' über das Tool-Management ausgewählt wird.
#

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "Huge_Facing"

echo -e "${BLUE}Starte Integration von Hugging Face (Huge Facing) Modellen...${NC}"

echo -e "${YELLOW}Hugging Face ist eine Plattform für KI-Modelle, keine einzelne Software, die installiert wird.${NC}"
echo -e "${YELLOW}Die Integration erfolgt auf zwei Hauptwegen:${NC}"

echo -e "\n${BLUE}1. Hugging Face Modelle lokal mit Ollama nutzen:${NC}"
echo -e "   Du kannst viele Modelle von Hugging Face, die im GGUF-Format vorliegen, direkt mit Ollama herunterladen und lokal ausführen."
echo -e "   Beispiel: ${GREEN}ollama pull <modellname> ${NC} (z.B. ${GREEN}ollama pull llama2${NC})
   Eine Liste verfügbarer Modelle findest du auf der Ollama-Website oder im Ollama Modell-Manager (Option 2 im Hauptmenü)."

echo -e "\n${BLUE}2. Hugging Face Inference API für Online-Modelle nutzen:${NC}"
echo -e "   Für den Zugriff auf eine breite Palette von Modellen, die auf Hugging Face gehostet werden, kannst du die Inference API verwenden."
echo -e "   Dafür benötigst du einen Hugging Face API Token. Details zur Beschaffung und Konfiguration findest du in der ${GREEN}API_KEY_GUIDE.md${NC} (Abschnitt 1.6)."
echo -e "   Tools wie OpenClaw können so konfiguriert werden, dass sie diese API nutzen."

echo -e "\n${YELLOW}Bitte beachte, dass die tatsächliche Nutzung der Modelle eine separate Konfiguration in den jeweiligen Tools erfordert.${NC}"
echo -e "${GREEN}Hugging Face Integration abgeschlossen. Bitte konsultiere die Dokumentation für weitere Schritte.${NC}"
mark_current_tool_installed

