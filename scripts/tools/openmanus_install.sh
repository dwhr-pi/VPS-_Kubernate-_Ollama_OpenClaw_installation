#!/bin/bash
# ==============================================================================
# OPENMANUS_INSTALL.SH - Installation von OpenManus
# ==============================================================================

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/lib/common.sh"
init_tool_tracking "OpenManus"

OPENMANUS_DIR="/opt/openmanus"
OPENMANUS_REPO_URL="$(get_custom_repo_url "OPENMANUS" "https://github.com/openmanus/openmanus.git")"
OPENMANUS_MIN_FREE_GB="${OPENMANUS_MIN_FREE_GB:-12}"
OPENMANUS_RECOMMENDED_FREE_GB="${OPENMANUS_RECOMMENDED_FREE_GB:-25}"
OPENMANUS_INSTALL_FLASH_ATTN="${OPENMANUS_INSTALL_FLASH_ATTN:-0}"
OPENMANUS_SKIP_TORCH="${OPENMANUS_SKIP_TORCH:-0}"

get_free_gb_for_path() {
    local path_to_check="${1:-/opt}"
    df -BG "$path_to_check" 2>/dev/null | awk 'NR==2 {gsub("G","",$4); print $4}'
}

print_openmanus_repair_hint() {
    cat <<'EOF'

OpenManus-Installationshinweis:
- Der haeufigste Fehler ist `flash-attn`: Dieses Paket braucht bereits installiertes Torch,
  passende CUDA-/Compiler-Umgebung und sehr viel RAM/Speicher.
- Deshalb wird `flash-attn` standardmaessig uebersprungen.
- Wenn du es bewusst bauen willst:
    OPENMANUS_INSTALL_FLASH_ATTN=1 bash scripts/tools/openmanus_install.sh
- Wenn Torch schon manuell installiert wurde:
    source /opt/openmanus/venv/bin/activate
    python -c "import torch; print(torch.__version__)"
EOF
}

echo -e "${BLUE}Starte Installation von OpenManus...${NC}"
FREE_GB_BEFORE="$(get_free_gb_for_path /opt)"
echo -e "${BLUE}Freier Speicher vor OpenManus: ${FREE_GB_BEFORE:-unbekannt} GB${NC}"
if [ -n "${FREE_GB_BEFORE:-}" ] && [ "$FREE_GB_BEFORE" -lt "$OPENMANUS_MIN_FREE_GB" ]; then
    echo -e "${RED}Zu wenig freier Speicher fuer OpenManus. Mindestens ${OPENMANUS_MIN_FREE_GB} GB, empfohlen ${OPENMANUS_RECOMMENDED_FREE_GB} GB.${NC}"
    exit 1
fi
if [ -n "${FREE_GB_BEFORE:-}" ] && [ "$FREE_GB_BEFORE" -lt "$OPENMANUS_RECOMMENDED_FREE_GB" ]; then
    echo -e "${YELLOW}Warnung: Nur ${FREE_GB_BEFORE} GB frei. Empfohlen sind ${OPENMANUS_RECOMMENDED_FREE_GB} GB, besonders wenn Torch/CUDA-Pakete installiert werden.${NC}"
fi

# 1. OpenManus aus GitHub klonen
if [ -d "$OPENMANUS_DIR" ]; then
    echo -e "${YELLOW}OpenManus Verzeichnis $OPENMANUS_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$OPENMANUS_DIR"
    git pull --ff-only
else
    echo -e "${BLUE}Klone OpenManus in $OPENMANUS_DIR...${NC}"
    sudo mkdir -p "$OPENMANUS_DIR"
    sudo chown -R $USER:$USER "$OPENMANUS_DIR"
    git clone "$OPENMANUS_REPO_URL" "$OPENMANUS_DIR"
    cd "$OPENMANUS_DIR"
fi

# 2. Python-Abhängigkeiten installieren
echo -e "${BLUE}Installiere Python-Abhängigkeiten für OpenManus...${NC}"
python3 -m venv venv
source venv/bin/activate
python -m pip install --upgrade pip setuptools wheel

if [ "$OPENMANUS_SKIP_TORCH" != "1" ]; then
    if python -c "import torch" >/dev/null 2>&1; then
        echo -e "${GREEN}Torch ist bereits in der OpenManus-venv vorhanden.${NC}"
    else
        echo -e "${BLUE}Installiere Torch vor den OpenManus-Abhaengigkeiten...${NC}"
        if ! python -m pip install torch; then
            echo -e "${RED}Torch konnte nicht installiert werden. OpenManus kann ohne Torch unvollstaendig sein.${NC}"
            print_openmanus_repair_hint
            exit 1
        fi
    fi
else
    echo -e "${YELLOW}OPENMANUS_SKIP_TORCH=1 gesetzt: Torch-Installation wird uebersprungen.${NC}"
fi

OPENMANUS_REQUIREMENTS_FILE="requirements.txt"
if grep -Eq '^[[:space:]]*flash-attn([=<>[:space:]]|$)' requirements.txt 2>/dev/null; then
    if [ "$OPENMANUS_INSTALL_FLASH_ATTN" = "1" ]; then
        echo -e "${YELLOW}flash-attn wird bewusst installiert. Das kann auf WSL/MiniPC scheitern, wenn CUDA/Compiler/Torch nicht passen.${NC}"
    else
        OPENMANUS_REQUIREMENTS_FILE="requirements.openmanus.safe.txt"
        grep -Ev '^[[:space:]]*flash-attn([=<>[:space:]]|$)' requirements.txt > "$OPENMANUS_REQUIREMENTS_FILE"
        echo -e "${YELLOW}flash-attn wurde aus der Standardinstallation herausgefiltert. Aktivieren mit OPENMANUS_INSTALL_FLASH_ATTN=1.${NC}"
    fi
fi

if ! python -m pip install -r "$OPENMANUS_REQUIREMENTS_FILE"; then
    echo -e "${RED}Python-Abhaengigkeiten fuer OpenManus konnten nicht vollstaendig installiert werden.${NC}"
    print_openmanus_repair_hint
    deactivate
    exit 1
fi
deactivate

# 3. Konfiguration (Platzhalter)
echo -e "${YELLOW}Hinweis: OpenManus Konfiguration muss eventuell manuell angepasst werden.${NC}"

echo -e "${GREEN}OpenManus Installation abgeschlossen.${NC}"
echo -e "${BLUE}Freier Speicher nach OpenManus: $(get_free_gb_for_path /opt) GB${NC}"
mark_current_tool_installed
