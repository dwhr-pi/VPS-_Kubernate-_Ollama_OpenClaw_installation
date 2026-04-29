#!/bin/bash
# ==============================================================================
# AUTO_UPDATE.SH - System- und pnpm-Update
# Dieses Skript aktualisiert das Betriebssystem und stellt sicher, dass pnpm
# auf der neuesten Version ist. Zusaetzlich wird das Setup-Repository
# aktualisiert, falls das Skript innerhalb eines Git-Klons laeuft.
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

echo -e "${BLUE}Starte Setup-, System- und pnpm-Update...${NC}"

# 1. Setup-Repository aktualisieren
echo -e "${GREEN}1/3: Aktualisiere das Setup-Repository...${NC}"
if command -v git >/dev/null 2>&1 && git -C "$INSTALL_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if git -C "$INSTALL_DIR" diff --quiet && git -C "$INSTALL_DIR" diff --cached --quiet; then
        git -C "$INSTALL_DIR" fetch --all --prune
        if git -C "$INSTALL_DIR" show-ref --verify --quiet refs/remotes/origin/main; then
            if git -C "$INSTALL_DIR" symbolic-ref --quiet HEAD >/dev/null 2>&1; then
                CURRENT_BRANCH="$(git -C "$INSTALL_DIR" rev-parse --abbrev-ref HEAD)"
                if [ "$CURRENT_BRANCH" != "main" ]; then
                    git -C "$INSTALL_DIR" checkout main 2>/dev/null || git -C "$INSTALL_DIR" checkout -b main --track origin/main
                fi
            else
                git -C "$INSTALL_DIR" checkout -B main origin/main
            fi
            git -C "$INSTALL_DIR" pull --ff-only origin main
            echo -e "${GREEN}Setup-Repository wurde aktualisiert.${NC}"
        else
            echo -e "${RED}Fehler: Remote-Branch origin/main wurde nicht gefunden.${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}Hinweis: Lokale Aenderungen im Setup erkannt. Repository-Update wurde uebersprungen, damit nichts ueberschrieben wird.${NC}"
        echo -e "${YELLOW}Bitte committen, sichern oder verwerfen Sie lokale Aenderungen und fuehren Sie das Update danach erneut aus.${NC}"
    fi
else
    echo -e "${YELLOW}Hinweis: Kein Git-Repository im Setup-Verzeichnis erkannt. Ueberspringe Repo-Update.${NC}"
fi

# 2. System aktualisieren
echo -e "${GREEN}2/3: Führe System-Updates durch...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y

# 3. pnpm aktualisieren
echo -e "${GREEN}3/3: Aktualisiere pnpm...${NC}"
if command -v pnpm >/dev/null 2>&1; then
    sudo pnpm add -g pnpm@latest
    echo -e "${GREEN}pnpm auf die neueste Version aktualisiert.${NC}"
else
    echo -e "${YELLOW}pnpm ist nicht installiert. Installiere pnpm...${NC}"
    sudo npm install -g pnpm
    if ! command -v pnpm >/dev/null 2>&1; then
        echo -e "${RED}Fehler: pnpm konnte nicht installiert werden. Bitte manuell prüfen.${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}Setup-, System- und pnpm-Update abgeschlossen.${NC}"
echo -e "${YELLOW}Falls sich das Setup selbst geaendert hat, starten Sie das Menue danach neu.${NC}"
