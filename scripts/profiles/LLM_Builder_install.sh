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

echo -e "${BLUE}Starte Installation des LLM_Builder-Profils...${NC}"

for tool_script in ollama_install.sh data_juicer_install.sh unsloth_install.sh llama_factory_install.sh llama_cpp_toolchain_install.sh axolotl_install.sh mlflow_install.sh weights_and_biases_install.sh vllm_install.sh llama_cpp_install.sh openclaw_install.sh flowise_install.sh langflow_install.sh clawbake_install.sh docker_install.sh code_sandbox_install.sh github_cli_install.sh chromadb_install.sh; do
    if [ -f "$INSTALL_DIR/scripts/tools/$tool_script" ]; then
        echo -e "${BLUE}Installiere ${tool_script%.sh} als Teil des LLM_Builder-Profils...${NC}"
        bash "$INSTALL_DIR/scripts/tools/$tool_script"
    else
        echo -e "${YELLOW}${tool_script} nicht gefunden. Überspringe diesen Baustein.${NC}"
    fi
done

echo -e "${GREEN}LLM_Builder-Profil Installation abgeschlossen.${NC}"
mark_current_profile_installed
