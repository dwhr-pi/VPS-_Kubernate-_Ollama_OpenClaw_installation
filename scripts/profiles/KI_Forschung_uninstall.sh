#!/bin/bash
#
# Skript: KI_Forschung_uninstall.sh
# Beschreibung: Dieses Skript deinstalliert Tools und Konfigurationen, die zum KI-Forschung Profil gehören.
# Es entfernt die entsprechenden Softwarepakete und Konfigurationsdateien.
# Verwendung: Wird vom Haupt-Setup-Skript aufgerufen, wenn das KI-Forschung Profil deinstalliert wird.
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
init_profile_tracking "KI_Forschung"

echo -e "${BLUE}Starte Deinstallation des KI-Forschung Profils...${NC}"

# Beispiel: Deinstallation von OpenClaw RL (falls installiert)
if [ -f "$INSTALL_DIR/scripts/tools/openclaw_rl_uninstall.sh" ]; then
    echo -e "${BLUE}Deinstalliere OpenClaw RL als Teil des KI-Forschung Profils...${NC}"
    bash "$INSTALL_DIR/scripts/tools/openclaw_rl_uninstall.sh"
else
    echo -e "${YELLOW}OpenClaw RL Deinstallationsskript nicht gefunden. Überspringe OpenClaw RL Deinstallation.${NC}"
fi

# Beispiel: Deinstallation von Flowise (falls installiert)
if [ -f "$INSTALL_DIR/scripts/tools/flowise_uninstall.sh" ]; then
    echo -e "${BLUE}Deinstalliere Flowise als Teil des KI-Forschung Profils...${NC}"
    bash "$INSTALL_DIR/scripts/tools/flowise_uninstall.sh"
else
    echo -e "${YELLOW}Flowise Deinstallationsskript nicht gefunden. Überspringe Flowise Deinstallation.${NC}"
fi

# Beispiel: Deinstallation von LangFlow (falls installiert)
if [ -f "$INSTALL_DIR/scripts/tools/langflow_uninstall.sh" ]; then
    echo -e "${BLUE}Deinstalliere LangFlow als Teil des KI-Forschung Profils...${NC}"
    bash "$INSTALL_DIR/scripts/tools/langflow_uninstall.sh"
else
    echo -e "${YELLOW}LangFlow Deinstallationsskript nicht gefunden. Überspringe LangFlow Deinstallation.${NC}"
fi

for tool_script in envirollm_uninstall.sh ray_uninstall.sh stable_diffusion_webui_uninstall.sh llama_cpp_uninstall.sh vllm_uninstall.sh weights_and_biases_uninstall.sh autogpt_uninstall.sh crewai_uninstall.sh weaviate_uninstall.sh chromadb_uninstall.sh whisper_uninstall.sh mlflow_uninstall.sh llamaindex_uninstall.sh langchain_uninstall.sh; do
    if [ -f "$INSTALL_DIR/scripts/tools/$tool_script" ]; then
        echo -e "${BLUE}Deinstalliere ${tool_script%.sh} als Teil des KI-Forschung Profils...${NC}"
        bash "$INSTALL_DIR/scripts/tools/$tool_script"
    else
        echo -e "${YELLOW}${tool_script} nicht gefunden. Überspringe diesen Baustein.${NC}"
    fi
done

echo -e "${GREEN}KI-Forschung Profil Deinstallation abgeschlossen.${NC}"
mark_current_profile_removed
