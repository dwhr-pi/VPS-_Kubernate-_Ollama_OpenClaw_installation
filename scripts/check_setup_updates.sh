#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

echo -e "${BLUE}Pruefe auf Setup-Updates...${NC}"

print_colored_git_status() {
    local line
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        case "$line" in
            "?? "*)
                echo -e "${BLUE}${line}${NC}"
                ;;
            *"M "*|*" M"*)
                echo -e "${YELLOW}${line}${NC}"
                ;;
            "A "*|" A "*)
                echo -e "${GREEN}${line}${NC}"
                ;;
            *)
                echo -e "${YELLOW}${line}${NC}"
                ;;
        esac
    done
}

print_local_change_diagnostics() {
    local status_output="$1"
    local tracked_count untracked_count content_count mode_count
    tracked_count="$(printf '%s\n' "$status_output" | grep -vc '^?? ' || true)"
    untracked_count="$(printf '%s\n' "$status_output" | grep -c '^?? ' || true)"
    content_count="$(git -C "$INSTALL_DIR" diff --numstat | awk 'NF { count++ } END { print count + 0 }')"
    mode_count="$(git -C "$INSTALL_DIR" diff --summary | grep -c '^ mode change ' || true)"

    echo -e "${BLUE}Einordnung der lokalen Abweichungen:${NC}"
    echo -e "  Tracking-Aenderungen: ${tracked_count}"
    echo -e "  Zusatzdateien:        ${untracked_count}"
    echo -e "  Inhaltsaenderungen:   ${content_count}"
    echo -e "  Rechte-/Moduswechsel: ${mode_count}"

    if [ "$content_count" -eq 0 ] && [ "$mode_count" -gt 0 ]; then
        echo -e "${YELLOW}Hinweis: Das sieht nach Datei-Rechte-/Modus-Aenderungen aus, nicht nach geaendertem Inhalt.${NC}"
        echo -e "${YELLOW}Unter WSL kann das durch Mount-/chmod-Verhalten entstehen. Pruefung: git diff --summary${NC}"
    elif [ "$content_count" -gt 0 ]; then
        echo -e "${YELLOW}Hinweis: Es gibt echte Inhaltsaenderungen. Die ersten betroffenen Dateien:${NC}"
        git -C "$INSTALL_DIR" diff --name-only | head -n 20 | sed 's/^/  - /'
    fi
}

if ! command -v git >/dev/null 2>&1; then
    echo -e "${RED}Fehler: git ist nicht installiert.${NC}"
    exit 1
fi

if ! git -C "$INSTALL_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "${RED}Fehler: $INSTALL_DIR ist kein Git-Repository.${NC}"
    exit 1
fi

git -C "$INSTALL_DIR" fetch origin --prune

LOCAL_SHA="$(git -C "$INSTALL_DIR" rev-parse HEAD)"
REMOTE_SHA="$(git -C "$INSTALL_DIR" rev-parse origin/main)"
STATUS_OUTPUT="$(git -C "$INSTALL_DIR" status --short)"
BEHIND_COUNT="$(git -C "$INSTALL_DIR" rev-list --count HEAD..origin/main)"
AHEAD_COUNT="$(git -C "$INSTALL_DIR" rev-list --count origin/main..HEAD)"

echo -e "${BLUE}Lokaler Commit:${NC}  $LOCAL_SHA"
echo -e "${BLUE}Remote Commit:${NC}   $REMOTE_SHA"
echo -e "${BLUE}Commits hinter main:${NC} $BEHIND_COUNT"
echo -e "${BLUE}Commits vor main:${NC}   $AHEAD_COUNT"

if [ -n "$STATUS_OUTPUT" ]; then
    echo -e "${YELLOW}Lokale Aenderungen vorhanden:${NC}"
    print_local_change_diagnostics "$STATUS_OUTPUT"
    echo
    print_colored_git_status <<< "$STATUS_OUTPUT"
else
    echo -e "${GREEN}Keine lokalen Aenderungen im Setup-Repository.${NC}"
fi

if [ "$LOCAL_SHA" = "$REMOTE_SHA" ] && [ -z "$STATUS_OUTPUT" ]; then
    echo -e "${GREEN}Das Setup ist aktuell und sauber.${NC}"
elif [ "$BEHIND_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}Es sind Updates verfuegbar. Auf Wunsch kann jetzt scripts/auto_update.sh ausgefuehrt werden.${NC}"
else
    echo -e "${YELLOW}Der Setup-Stand weicht von origin/main ab, aber nicht nur durch neue Remote-Commits.${NC}"
fi
