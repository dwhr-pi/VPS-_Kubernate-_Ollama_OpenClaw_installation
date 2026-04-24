#!/bin/bash
# ==============================================================================
# INSTALL.SH - GitHub-basierter One-Liner Installer (mit Privat-Repo Support)
# Dieses Skript klont das Repository und startet das Haupt-Setup-Skript.
# ==============================================================================

REPO_URL="https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation.git" # BITTE AN IHR REPOSITORY ANPASSEN!
INSTALL_DIR="~/openclaw_ultimate_setup"

GREEN=\033[032m
BLUE=\033[034m
RED=\033[031m
YELLOW=\033[133m
NC=\033[0m

echo -e "${BLUE}Starte die OpenClaw Ultimate Setup Installation...${NC}"

# Prüfen, ob Git installiert ist
if ! command -v git >/dev/null 2>&1; then
    echo -e "${YELLOW}Git ist nicht installiert. Installiere Git...${NC}"
    sudo apt update
    sudo apt install -y git
    if ! command -v git >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Git konnte nicht installiert werden. Bitte manuell installieren.${NC}"
        exit 1
    fi
fi

# Abfrage für privates Repository
read -p "Ist Ihr GitHub-Repository privat? (j/N): " IS_PRIVATE_REPO
IS_PRIVATE_REPO=${IS_PRIVATE_REPO:-N}

GIT_AUTH_URL="$REPO_URL"
if [[ "$IS_PRIVATE_REPO" =~ ^[jJ]$ ]]; then
    echo -e "${YELLOW}Für private Repositories benötigen Sie ein GitHub Personal Access Token (PAT).${NC}"
    echo -e "${YELLOW}Anleitung zur Erstellung: docs/PRIVATE_REPO_GUIDE.md im geklonten Repo.${NC}"
    read -s -p "Bitte geben Sie Ihr GitHub Personal Access Token ein: " GITHUB_PAT
    echo
    if [ -z "$GITHUB_PAT" ]; then
        echo -e "${RED}Fehler: Kein GitHub Personal Access Token eingegeben. Installation abgebrochen.${NC}"
        exit 1
    fi
    # URL für Authentifizierung anpassen
    REPO_HOST=$(echo $REPO_URL | sed -e 's/^https:\/\///' -e 's/\.git$//')
    GIT_AUTH_URL="https://${GITHUB_PAT}@${REPO_HOST}.git"
fi

# Repository klonen
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Installationsverzeichnis $INSTALL_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$INSTALL_DIR"
    git pull
else
    echo -e "${BLUE}Klone Repository in $INSTALL_DIR...${NC}"
    git clone "$GIT_AUTH_URL" "$INSTALL_DIR"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Fehler: Repository konnte nicht geklont werden. Prüfen Sie die URL, Ihr Token und Ihre Internetverbindung.${NC}"
        exit 1
    fi
    cd "$INSTALL_DIR"
fi

# Haupt-Setup-Skript ausführen
chmod +x setup_ultimate_v11.sh
./setup_ultimate_v11.sh

echo -e "${GREEN}Installation abgeschlossen. Bitte folgen Sie den Anweisungen im Menü.${NC}"
