#!/bin/bash

set -euo pipefail

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

if ! command -v dialog >/dev/null 2>&1; then
    echo -e "${RED}Fehler: dialog ist nicht installiert.${NC}"
    exit 1
fi

dialog() {
    local arg
    local has_cancel_label=0

    for arg in "$@"; do
        if [ "$arg" = "--cancel-label" ]; then
            has_cancel_label=1
            break
        fi
    done

    if [ "$has_cancel_label" -eq 1 ]; then
        command dialog "$@"
    else
        command dialog --cancel-label "Zurueck" "$@"
    fi
}

if ! command -v ollama >/dev/null 2>&1; then
    echo -e "${RED}Fehler: Ollama ist nicht installiert.${NC}"
    exit 1
fi

declare -A MODEL_DESC
declare -A MODEL_SIZE
declare -A MODEL_RAM

MODEL_KEYS=(
  "llama3.2:3b"
  "qwen2.5:7b"
  "mistral:7b"
  "gemma3:4b"
  "phi4:14b"
  "deepseek-r1:8b"
  "mixtral:8x7b"
  "qwen2.5-coder:7b"
  "qwen3-coder:30b"
  "mixtral:8x22b"
  "devstral:24b"
  "mistral-small:24b"
  "mistral-nemo:12b"
  "codestral:22b"
)

MODEL_DESC["llama3.2:3b"]="Kleines Allround-Modell für lokale Chats, Tests und leichte Agentenflows."
MODEL_DESC["qwen2.5:7b"]="Starkes allgemeines Instruct-Modell für lokale Assistenten und RAG."
MODEL_DESC["mistral:7b"]="EU-naher Allrounder aus dem Mistral-Umfeld für generelle Aufgaben."
MODEL_DESC["gemma3:4b"]="Kompaktes Modell für sparsame lokale Nutzung und UI-Tests."
MODEL_DESC["phi4:14b"]="Stärkeres Microsoft-Modell für reasoning-lastige lokale Workloads."
MODEL_DESC["deepseek-r1:8b"]="Kompakter Reasoning-Ableger für Analyse, Planen und schrittweises Denken."
MODEL_DESC["mixtral:8x7b"]="Starker Mistral-MoE-Hauptagent fuer allgemeine Aufgaben, RAG und Multi-Agent-Workflows."
MODEL_DESC["qwen2.5-coder:7b"]="Leichtes Coding-Modell für lokalen Codex-Nachbau und Editieraufgaben."
MODEL_DESC["qwen3-coder:30b"]="Großes agentisches Coding-Modell mit langem Kontext für Repository-Arbeit."
MODEL_DESC["mixtral:8x22b"]="High-End-Mistral-MoE fuer grosse Server, grosse Kontexte und starke Hauptagenten."
MODEL_DESC["devstral:24b"]="Agentisches Software-Engineering-Modell für Multi-File-Edits und Tool-Nutzung."
MODEL_DESC["mistral-small:24b"]="EU-LLM von Mistral für stärkere allgemeine Inferenz und produktive Aufgaben."
MODEL_DESC["mistral-nemo:12b"]="EU-LLM von Mistral mit guter Balance aus Qualität und Hardwarebedarf."
MODEL_DESC["codestral:22b"]="EU-Coding-Modell von Mistral für Programmierung und Refactoring."

MODEL_SIZE["llama3.2:3b"]="ca. 2.0 GB"
MODEL_SIZE["qwen2.5:7b"]="ca. 4.7 GB"
MODEL_SIZE["mistral:7b"]="ca. 4.1 GB"
MODEL_SIZE["gemma3:4b"]="ca. 3.3 GB"
MODEL_SIZE["phi4:14b"]="ca. 9.1 GB"
MODEL_SIZE["deepseek-r1:8b"]="ca. 5.2 GB"
MODEL_SIZE["mixtral:8x7b"]="ca. 26 GB"
MODEL_SIZE["qwen2.5-coder:7b"]="ca. 4.7 GB"
MODEL_SIZE["qwen3-coder:30b"]="ca. 19 GB"
MODEL_SIZE["mixtral:8x22b"]="ca. 80 GB"
MODEL_SIZE["devstral:24b"]="ca. 14 GB"
MODEL_SIZE["mistral-small:24b"]="ca. 14 GB"
MODEL_SIZE["mistral-nemo:12b"]="ca. 7.1 GB"
MODEL_SIZE["codestral:22b"]="ca. 13 GB"

MODEL_RAM["llama3.2:3b"]="empf. ab 8 GB RAM"
MODEL_RAM["qwen2.5:7b"]="empf. ab 12 GB RAM"
MODEL_RAM["mistral:7b"]="empf. ab 12 GB RAM"
MODEL_RAM["gemma3:4b"]="empf. ab 8 GB RAM"
MODEL_RAM["phi4:14b"]="empf. ab 20 GB RAM"
MODEL_RAM["deepseek-r1:8b"]="empf. ab 12 GB RAM"
MODEL_RAM["mixtral:8x7b"]="empf. ab 48 GB RAM"
MODEL_RAM["qwen2.5-coder:7b"]="empf. ab 12 GB RAM"
MODEL_RAM["qwen3-coder:30b"]="empf. ab 32 GB RAM"
MODEL_RAM["mixtral:8x22b"]="empf. ab 96-128 GB RAM"
MODEL_RAM["devstral:24b"]="empf. ab 32 GB RAM"
MODEL_RAM["mistral-small:24b"]="empf. ab 32 GB RAM"
MODEL_RAM["mistral-nemo:12b"]="empf. ab 16 GB RAM"
MODEL_RAM["codestral:22b"]="empf. ab 28-32 GB RAM"

declare -A INSTALLED
while IFS= read -r line; do
    model_name="$(printf '%s' "$line" | awk '{print $1}')"
    [ -n "$model_name" ] && INSTALLED["$model_name"]=1
done < <(ollama list 2>/dev/null | tail -n +2 || true)

options=()
for model in "${MODEL_KEYS[@]}"; do
    state="off"
    if [ "${INSTALLED[$model]:-}" = "1" ]; then
        state="on"
    fi
    options+=("$model" "${MODEL_SIZE[$model]} | ${MODEL_RAM[$model]} | ${MODEL_DESC[$model]}" "$state")
done

dialog --clear --backtitle "OpenClaw & AI Infrastructure - Ultimate Setup" \
--title "Ollama Modellkatalog" --checklist \
"Modelle auswählen: markiert = installiert, unmarkiert = entfernt." 26 120 14 \
"${options[@]}" 2> /tmp/ollama_catalog_selection

[ $? -eq 0 ] || exit 0

mapfile -t SELECTED_MODELS < <(tr ' ' '\n' < /tmp/ollama_catalog_selection | tr -d '"' | sed '/^$/d')

contains_selected() {
    local needle="$1"
    shift
    local item
    for item in "$@"; do
        [ "$item" = "$needle" ] && return 0
    done
    return 1
}

clear
echo
echo -e "${YELLOW}Bearbeite ausgewählte Ollama-Modelle...${NC}"
echo

for model in "${MODEL_KEYS[@]}"; do
    if contains_selected "$model" "${SELECTED_MODELS[@]}"; then
        if [ "${INSTALLED[$model]:-}" != "1" ]; then
            echo -e "${BLUE}Installiere Modell: ${model}${NC}"
            ollama pull "$model"
        fi
    else
        if [ "${INSTALLED[$model]:-}" = "1" ]; then
            echo -e "${BLUE}Entferne Modell: ${model}${NC}"
            ollama rm "$model" || true
        fi
    fi
done

echo
echo -e "${GREEN}Der Ollama-Modellkatalog wurde abgearbeitet.${NC}"
echo
read -r -p "Drücken Sie Enter..."
