#!/bin/bash

set -euo pipefail

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
USER_WORKSPACE_DIR="${HOME}/.openclaw_ultimate_user_data"
USER_MODELFILE_DIR="$USER_WORKSPACE_DIR/modelfiles"

mkdir -p "$USER_MODELFILE_DIR"

prompt_input() {
    local title="$1"
    local message="$2"
    local default_value="${3:-}"
    local target_file="$4"

    dialog --clear --backtitle "OpenClaw & AI Infrastructure - Ultimate Setup" \
    --title "$title" --inputbox "$message" 11 90 "$default_value" 2> "$target_file"
}

if ! command -v dialog >/dev/null 2>&1; then
    echo -e "${RED}Fehler: dialog ist nicht installiert.${NC}"
    exit 1
fi

prompt_input "Modelfile-Assistent" "Name des neuen Ollama-Modells:" "mein-llm" /tmp/modelfile_name
[ $? -eq 0 ] || exit 0
MODEL_NAME="$(cat /tmp/modelfile_name)"

prompt_input "Modelfile-Assistent" "Pfad zur GGUF-Datei oder Name des Basismodells für FROM:" "./mein-modell.gguf" /tmp/modelfile_from
[ $? -eq 0 ] || exit 0
MODEL_FROM="$(cat /tmp/modelfile_from)"

prompt_input "Modelfile-Assistent" "Systemprompt für das Modell:" "Du bist ein hilfreicher lokaler Assistent." /tmp/modelfile_system
[ $? -eq 0 ] || exit 0
MODEL_SYSTEM="$(cat /tmp/modelfile_system)"

prompt_input "Modelfile-Assistent" "Temperatur (z. B. 0.2):" "0.2" /tmp/modelfile_temperature
[ $? -eq 0 ] || exit 0
MODEL_TEMPERATURE="$(cat /tmp/modelfile_temperature)"

prompt_input "Modelfile-Assistent" "Context-Länge NUM_CTX (z. B. 8192):" "8192" /tmp/modelfile_ctx
[ $? -eq 0 ] || exit 0
MODEL_CTX="$(cat /tmp/modelfile_ctx)"

TARGET_FILE="$USER_MODELFILE_DIR/${MODEL_NAME}.Modelfile"

cat > "$TARGET_FILE" <<EOF
# Modelfile erzeugt durch das Ultimate Setup
# Dieser Modelfile liegt bewusst im Benutzer-Workspace und nicht im Git-Repository.

FROM ${MODEL_FROM}

PARAMETER temperature ${MODEL_TEMPERATURE}
PARAMETER num_ctx ${MODEL_CTX}

SYSTEM \"\"\"${MODEL_SYSTEM}\"\"\"

TEMPLATE \"\"\"{{ if .System }}<|system|>
{{ .System }}
{{ end }}{{ if .Prompt }}<|user|>
{{ .Prompt }}
{{ end }}<|assistant|>
\"\"\"
EOF

clear
echo
echo -e "${GREEN}Der Modelfile wurde erzeugt:${NC} $TARGET_FILE"
echo
echo -e "${YELLOW}Nächste Schritte:${NC}"
echo "1. Prüfe oder bearbeite die Datei bei Bedarf."
echo "2. Erzeuge das Modell mit:"
echo "   ollama create ${MODEL_NAME} -f \"$TARGET_FILE\""
echo "3. Starte das Modell mit:"
echo "   ollama run ${MODEL_NAME}"
echo
echo -e "${YELLOW}Hinweis:${NC} Modelle selbst kommen in der Regel aus Ollama oder als GGUF-Datei. Die Modelfile-Vorlage bleibt lokal in deinem Benutzer-Workspace."
echo
read -r -p "Drücken Sie Enter..."
