#!/bin/bash

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_profile_tracking "LLM_Builder"

echo -e "${BLUE}Starte Deinstallation des LLM_Builder-Profils...${NC}"

for tool_script in chromadb_uninstall.sh github_cli_uninstall.sh code_sandbox_uninstall.sh docker_uninstall.sh clawbake_uninstall.sh langflow_uninstall.sh flowise_uninstall.sh openclaw_uninstall.sh llama_cpp_uninstall.sh vllm_uninstall.sh weights_and_biases_uninstall.sh mlflow_uninstall.sh axolotl_uninstall.sh llama_cpp_toolchain_uninstall.sh llama_factory_uninstall.sh unsloth_uninstall.sh data_juicer_uninstall.sh ollama_uninstall.sh; do
    if [ -f "$INSTALL_DIR/scripts/tools/$tool_script" ]; then
        echo -e "${BLUE}Deinstalliere ${tool_script%.sh} als Teil des LLM_Builder-Profils...${NC}"
        bash "$INSTALL_DIR/scripts/tools/$tool_script"
    else
        echo -e "${YELLOW}${tool_script} nicht gefunden. Überspringe diesen Baustein.${NC}"
    fi
done

echo -e "${GREEN}LLM_Builder-Profil Deinstallation abgeschlossen.${NC}"
mark_current_profile_removed
