#!/bin/bash
# ==============================================================================
# KIMI2_INSTALL.SH - Installiert Kimi 2 (Moonshot AI) von GitHub
# ==============================================================================

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
init_tool_tracking "Kimi2"

KIMI2_DIR="/opt/kimi2"
KIMI2_CREATE_VENV="${KIMI2_CREATE_VENV:-1}"
KIMI2_REPOS=(
    "${KIMI2_REPO:-}"
    "https://github.com/MoonshotAI/Kimi-K2.5.git"
    "https://github.com/dwhr-pi/AI-Kimi-K2.5.git"
)

echo -e "${BLUE}Starte Installation von Kimi 2...${NC}"

KIMI2_REPO=""
for repo in "${KIMI2_REPOS[@]}"; do
    [ -z "$repo" ] && continue
    if git ls-remote "$repo" HEAD >/dev/null 2>&1; then
        KIMI2_REPO="$repo"
        break
    fi
done

if [ -z "$KIMI2_REPO" ]; then
    echo -e "${RED}Fehler: Kein erreichbares Kimi Repository gefunden.${NC}"
    echo -e "${YELLOW}Geprüft wurden MoonshotAI/Kimi-K2.5 und dwhr-pi/AI-Kimi-K2.5.${NC}"
    echo -e "${YELLOW}Setzen Sie bei Bedarf KIMI2_REPO auf die korrekte Git-URL und starten Sie das Skript erneut.${NC}"
    exit 1
fi

# Abhängigkeiten installieren
echo -e "${BLUE}Installiere System-Abhängigkeiten für Kimi 2...${NC}"
sudo apt-get update
sudo apt-get install -y git python3 python3-pip python3-venv

# Kimi 2 Repository klonen oder aktualisieren
if [ -d "$KIMI2_DIR/.git" ]; then
    echo -e "${YELLOW}Kimi 2 Repository existiert bereits unter ${KIMI2_DIR}. Aktualisiere Repository...${NC}"
    if ! git -C "$KIMI2_DIR" pull --ff-only; then
        echo -e "${YELLOW}Hinweis: Git-Update war nicht möglich. Die vorhandene lokale Kopie bleibt erhalten.${NC}"
    fi
elif [ -d "$KIMI2_DIR" ] && [ "$(find "$KIMI2_DIR" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l)" -gt 0 ]; then
    echo -e "${RED}Fehler: ${KIMI2_DIR} existiert, ist aber kein Git-Repository und nicht leer.${NC}"
    echo -e "${YELLOW}Bitte Verzeichnis prüfen oder Kimi2 erst deinstallieren.${NC}"
    exit 1
else
    echo -e "${BLUE}Klone Kimi 2 Repository von ${KIMI2_REPO}...${NC}"
    sudo mkdir -p "$(dirname "$KIMI2_DIR")"
    sudo chown -R "$USER:$USER" "$(dirname "$KIMI2_DIR")"
    git clone "$KIMI2_REPO" "$KIMI2_DIR"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Fehler beim Klonen des Kimi 2 Repositories.${NC}"
        exit 1
    fi
fi

sudo chown -R "$USER:$USER" "$KIMI2_DIR"

# Optionale Python-Umgebung nur dann befüllen, wenn das Repo wirklich Python-Metadaten enthält.
if [ "$KIMI2_CREATE_VENV" = "1" ]; then
    if [ -d "$KIMI2_DIR/venv" ] && [ ! -f "$KIMI2_DIR/venv/bin/activate" ]; then
        echo -e "${YELLOW}Unvollständige Kimi-venv gefunden. Entferne defekte venv und erstelle sie neu.${NC}"
        rm -rf "$KIMI2_DIR/venv"
    fi

    if [ ! -d "$KIMI2_DIR/venv" ]; then
        echo -e "${BLUE}Erstelle virtuelle Umgebung für optionale Kimi 2 Hilfswerkzeuge...${NC}"
        python3 -m venv "$KIMI2_DIR/venv"
    fi

    # shellcheck disable=SC1091
    source "$KIMI2_DIR/venv/bin/activate"
    python -m pip install --upgrade pip setuptools wheel

    if [ -f "$KIMI2_DIR/requirements.txt" ]; then
        echo -e "${BLUE}Installiere Python-Abhängigkeiten aus requirements.txt...${NC}"
        python -m pip install --no-cache-dir -r "$KIMI2_DIR/requirements.txt"
    elif [ -f "$KIMI2_DIR/pyproject.toml" ] || [ -f "$KIMI2_DIR/setup.py" ]; then
        echo -e "${BLUE}Installiere Kimi 2 Python-Projekt im editable Modus...${NC}"
        python -m pip install --no-cache-dir -e "$KIMI2_DIR"
    else
        echo -e "${YELLOW}Hinweis: Das Kimi 2 Repository enthält aktuell keine requirements.txt, pyproject.toml oder setup.py.${NC}"
        echo -e "${YELLOW}Es wird als lokale GitHub-Referenz/Dokumentationsbasis installiert; keine Python-Abhängigkeiten werden erzwungen.${NC}"
    fi

    deactivate
fi

cat > "$KIMI2_DIR/INSTALLATION_NOTES.md" <<'EOF'
# Kimi 2 Installation im Ultimate KI Setup

Dieses Verzeichnis enthält die aus GitHub geklonte Kimi-Quelle/Referenz.

Hinweise:
- Wenn Upstream keine `requirements.txt`, `pyproject.toml` oder `setup.py` enthält, installiert das Setup keine Python-Abhängigkeiten.
- In diesem Fall ist Kimi 2 hier als lokale Referenz, Dokumentationsbasis und Konfigurationsanker für Ollama/OpenClaw-Workflows eingebunden.
- Modellgewichte, API-Zugänge oder weitere Deployment-Schritte müssen gemäß Upstream-Dokumentation bewusst ergänzt werden.
EOF

echo -e "${GREEN}Kimi 2 erfolgreich installiert unter ${KIMI2_DIR}.${NC}"
echo -e "${YELLOW}Falls du Kimi über eine API nutzt, speichere API-Keys nur im Benutzer-Workspace oder in Umgebungsvariablen, niemals im Repo.${NC}"
mark_current_tool_installed
