#!/bin/bash
#
# Skript: KI_Forschung_install.sh
# Beschreibung: Dieses Skript installiert Tools und Konfigurationen, die speziell für die KI-Forschung und -Entwicklung nützlich sind.
# Es umfasst spezialisierte Bibliotheken, Frameworks und Tools für maschinelles Lernen, Deep Learning und Reinforcement Learning.
# Verwendung: Wird vom Haupt-Setup-Skript aufgerufen, wenn das KI-Forschung Profil ausgewählt wird.
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
init_profile_tracking "KI_Forschung"

echo -e "${BLUE}Starte Installation des KI-Forschung Profils...${NC}"

# Beispiel: Installation von OpenClaw RL (falls noch nicht geschehen)
if [ -f "$INSTALL_DIR/scripts/tools/openclaw_rl_install.sh" ]; then
    echo -e "${BLUE}Installiere OpenClaw RL als Teil des KI-Forschung Profils...${NC}"
    bash "$INSTALL_DIR/scripts/tools/openclaw_rl_install.sh"
else
    echo -e "${YELLOW}OpenClaw RL Installationsskript nicht gefunden. Überspringe OpenClaw RL Installation.${NC}"
fi

# Beispiel: Installation von Flowise (falls noch nicht geschehen)
if [ -f "$INSTALL_DIR/scripts/tools/flowise_install.sh" ]; then
    echo -e "${BLUE}Installiere Flowise als Teil des KI-Forschung Profils...${NC}"
    bash "$INSTALL_DIR/scripts/tools/flowise_install.sh"
else
    echo -e "${YELLOW}Flowise Installationsskript nicht gefunden. Überspringe Flowise Installation.${NC}"
fi

# Beispiel: Installation von LangFlow (falls noch nicht geschehen)
if [ -f "$INSTALL_DIR/scripts/tools/langflow_install.sh" ]; then
    echo -e "${BLUE}Installiere LangFlow als Teil des KI-Forschung Profils...${NC}"
    bash "$INSTALL_DIR/scripts/tools/langflow_install.sh"
else
    echo -e "${YELLOW}LangFlow Installationsskript nicht gefunden. Überspringe LangFlow Installation.${NC}"
fi

for tool_script in langchain_install.sh llamaindex_install.sh mlflow_install.sh whisper_install.sh chromadb_install.sh weaviate_install.sh crewai_install.sh autogpt_install.sh weights_and_biases_install.sh vllm_install.sh llama_cpp_install.sh stable_diffusion_webui_install.sh ray_install.sh envirollm_install.sh; do
    if [ -f "$INSTALL_DIR/scripts/tools/$tool_script" ]; then
        echo -e "${BLUE}Installiere ${tool_script%.sh} als Teil des KI-Forschung Profils...${NC}"
        bash "$INSTALL_DIR/scripts/tools/$tool_script"
    else
        echo -e "${YELLOW}${tool_script} nicht gefunden. Überspringe diesen Baustein.${NC}"
    fi
done

echo -e "${GREEN}KI-Forschung Profil Installation abgeschlossen.${NC}"
mark_current_profile_installed
