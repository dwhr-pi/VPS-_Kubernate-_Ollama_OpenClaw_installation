#!/bin/bash
# ==============================================================================
# AUTO_UPDATE_HARD.SH - Erzwingt den Abgleich des Setup-Repositories mit origin/main
# Achtung: Verwirft lokale Änderungen im Setup-Verzeichnis.
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

echo -e "${YELLOW}Harter Setup-Abgleich startet...${NC}"
echo -e "${YELLOW}Lokale Änderungen im Setup-Verzeichnis werden verworfen.${NC}"

if ! command -v git >/dev/null 2>&1; then
    echo -e "${RED}Fehler: git ist nicht installiert.${NC}"
    exit 1
fi

if ! git -C "$INSTALL_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "${RED}Fehler: $INSTALL_DIR ist kein Git-Repository.${NC}"
    exit 1
fi

git -C "$INSTALL_DIR" fetch origin --prune

if ! git -C "$INSTALL_DIR" show-ref --verify --quiet refs/remotes/origin/main; then
    echo -e "${RED}Fehler: Remote-Branch origin/main wurde nicht gefunden.${NC}"
    exit 1
fi

if git -C "$INSTALL_DIR" symbolic-ref --quiet HEAD >/dev/null 2>&1; then
    CURRENT_BRANCH="$(git -C "$INSTALL_DIR" rev-parse --abbrev-ref HEAD)"
    if [ "$CURRENT_BRANCH" != "main" ]; then
        git -C "$INSTALL_DIR" checkout main 2>/dev/null || git -C "$INSTALL_DIR" checkout -b main --track origin/main
    fi
else
    git -C "$INSTALL_DIR" checkout -B main origin/main
fi

git -C "$INSTALL_DIR" reset --hard origin/main

echo -e "${GREEN}Das Setup wurde hart auf origin/main zurückgesetzt.${NC}"
echo -e "${YELLOW}Starte danach das Menü neu, damit der aktuelle Stand sicher geladen wird.${NC}"
