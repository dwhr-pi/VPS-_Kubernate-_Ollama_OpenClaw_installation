#!/bin/bash

set -euo pipefail

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

USER_WORKSPACE_DIR="${HOME}/.openclaw_ultimate_user_data"
LLM_PROJECTS_DIR="$USER_WORKSPACE_DIR/llm_builder_projects"

mkdir -p "$LLM_PROJECTS_DIR"

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

dialog --clear --backtitle "OpenClaw & AI Infrastructure - Ultimate Setup" \
--title "LLM-Builder Projekt-Assistent" --inputbox \
"Name des neuen LLM-Projekts:" 10 80 "mein-lokales-llm" 2> /tmp/llm_builder_project_name

[ $? -eq 0 ] || exit 0

PROJECT_NAME="$(tr -d '\r' < /tmp/llm_builder_project_name)"
PROJECT_DIR="$LLM_PROJECTS_DIR/$PROJECT_NAME"

mkdir -p \
    "$PROJECT_DIR/datasets/raw" \
    "$PROJECT_DIR/datasets/cleaned" \
    "$PROJECT_DIR/datasets/splits" \
    "$PROJECT_DIR/configs" \
    "$PROJECT_DIR/adapters" \
    "$PROJECT_DIR/exports" \
    "$PROJECT_DIR/quantized" \
    "$PROJECT_DIR/modelfiles" \
    "$PROJECT_DIR/evals" \
    "$PROJECT_DIR/logs" \
    "$PROJECT_DIR/scripts"

cat > "$PROJECT_DIR/README.md" <<EOF
# LLM-Builder Projekt: $PROJECT_NAME

Dieses Projekt wurde durch das Ultimate Setup erzeugt.
Es liegt bewusst außerhalb des Git-Repositories im Benutzer-Workspace.

## Struktur

- \`datasets/raw\`: Rohdaten
- \`datasets/cleaned\`: bereinigte Daten
- \`datasets/splits\`: Train/Valid/Test-Splits
- \`configs\`: Trainings- und Evaluationskonfigurationen
- \`adapters\`: LoRA/QLoRA-Adapter
- \`exports\`: Exportierte Modelle vor GGUF/Quantisierung
- \`quantized\`: Quantisierte GGUF-Modelle
- \`modelfiles\`: Ollama-Modelfiles
- \`evals\`: Evaluationsartefakte
- \`logs\`: Logdateien und Messwerte
- \`scripts\`: Projektspezifische Hilfsskripte
EOF

cat > "$PROJECT_DIR/configs/training.env.example" <<'EOF'
BASE_MODEL=qwen2.5:7b
DATASET_FORMAT=chatml
TRAINING_FRAMEWORK=unsloth
LORA_R=16
LORA_ALPHA=32
LORA_DROPOUT=0.05
LEARNING_RATE=2e-4
EPOCHS=3
BATCH_SIZE=2
GRADIENT_ACCUMULATION=8
MAX_SEQ_LENGTH=4096
EOF

cat > "$PROJECT_DIR/configs/modelfile.example" <<'EOF'
FROM ./quantized/mein-modell-q4_k_m.gguf

PARAMETER temperature 0.2
PARAMETER num_ctx 8192

SYSTEM """Du bist ein hilfreicher lokaler Assistent."""
EOF

cat > "$PROJECT_DIR/scripts/workflow_notes.md" <<'EOF'
# Workflow-Hinweise

1. Basisdaten nach `datasets/raw/` legen
2. Mit Data_Juicer nach `datasets/cleaned/` bereinigen
3. Splits unter `datasets/splits/` erzeugen
4. Training mit Unsloth, LLaMA_Factory oder Axolotl durchführen
5. Adapter nach `adapters/` schreiben
6. Merge oder Export nach `exports/`
7. GGUF/Quantisierung nach `quantized/`
8. Ollama-Modelfile nach `modelfiles/`
9. Test- und Eval-Ergebnisse nach `evals/`
EOF

clear
echo
echo -e "${GREEN}Die LLM-Builder-Projektstruktur wurde erzeugt:${NC} $PROJECT_DIR"
echo
echo -e "${YELLOW}Empfohlene nächsten Schritte:${NC}"
echo "1. Datensätze nach $PROJECT_DIR/datasets/raw kopieren"
echo "2. training.env.example anpassen"
echo "3. einen Modelfile unter $PROJECT_DIR/modelfiles anlegen oder den Ollama-Modelfile-Assistenten nutzen"
echo
read -r -p "Drücken Sie Enter..."
