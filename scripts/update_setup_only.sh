#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

echo -e "${BLUE}Starte reines Setup-Update...${NC}"

if ! command -v git >/dev/null 2>&1; then
    echo -e "${RED}Fehler: git ist nicht installiert.${NC}"
    exit 1
fi

if ! git -C "$INSTALL_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "${RED}Fehler: $INSTALL_DIR ist kein Git-Repository.${NC}"
    exit 1
fi

REPO_STATUS="$(git -C "$INSTALL_DIR" status --porcelain)"
if [ -n "$REPO_STATUS" ]; then
    echo -e "${YELLOW}Hinweis: Lokale Aenderungen oder Zusatzdateien im Setup erkannt. Das Repo-Update wird bewusst uebersprungen.${NC}"
    echo -e "${YELLOW}Bitte committen, sichern oder entfernen Sie die lokalen Aenderungen und fuehren Sie das Setup-Update danach erneut aus.${NC}"
    echo
    echo -e "${YELLOW}Git-Status im Setup-Verzeichnis:${NC}"
    printf '%s\n' "$REPO_STATUS"
    exit 0
fi

echo -e "${GREEN}Pruefe Remote-Stand...${NC}"
git -C "$INSTALL_DIR" fetch origin --prune

if ! git -C "$INSTALL_DIR" show-ref --verify --quiet refs/remotes/origin/main; then
    echo -e "${RED}Fehler: Remote-Branch origin/main wurde nicht gefunden.${NC}"
    exit 1
fi

CURRENT_BRANCH="$(git -C "$INSTALL_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo -e "${YELLOW}Aktueller Branch ist ${CURRENT_BRANCH}. Wechsle fuer das Setup-Update auf main.${NC}"
    git -C "$INSTALL_DIR" checkout main 2>/dev/null || git -C "$INSTALL_DIR" checkout -b main --track origin/main
fi

LOCAL_SHA="$(git -C "$INSTALL_DIR" rev-parse HEAD)"
REMOTE_SHA="$(git -C "$INSTALL_DIR" rev-parse origin/main)"

if [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
    echo -e "${GREEN}Das Setup ist bereits aktuell.${NC}"
    exit 0
fi

echo -e "${GREEN}Aktualisiere das Setup-Repository...${NC}"
git -C "$INSTALL_DIR" pull --ff-only origin main

echo -e "${GREEN}Setup-Update abgeschlossen.${NC}"
echo -e "${YELLOW}Falls sich das Setup selbst geaendert hat, starten Sie das Menue danach neu.${NC}"
