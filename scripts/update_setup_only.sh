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
        echo -e "${YELLOW}Hinweis: Es sieht nach Datei-Rechte-/Modus-Aenderungen aus, nicht nach geaendertem Inhalt.${NC}"
        echo -e "${YELLOW}Das passiert unter WSL/Windows gelegentlich durch chmod-/Mount-Optionen.${NC}"
        echo -e "${YELLOW}Pruefung ohne Reparatur: git diff --summary${NC}"
        echo -e "${YELLOW}Falls sich das bestaetigt: git config core.fileMode false${NC}"
    elif [ "$content_count" -gt 0 ]; then
        echo -e "${YELLOW}Hinweis: Es gibt echte Inhaltsaenderungen. Diese werden nicht automatisch ueberschrieben.${NC}"
        echo -e "${YELLOW}Die ersten betroffenen Dateien:${NC}"
        git -C "$INSTALL_DIR" diff --name-only | head -n 20 | sed 's/^/  - /'
    fi
}

print_updated_files_between() {
    local old_sha="$1"
    local new_sha="$2"
    local changed

    [ "$old_sha" != "$new_sha" ] || return 0
    changed="$(git -C "$INSTALL_DIR" diff --name-status "$old_sha" "$new_sha" || true)"
    [ -n "$changed" ] || return 0

    echo
    echo -e "${GREEN}Durch dieses Update aktualisierte Dateien:${NC}"
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        echo -e "${GREEN}${line}${NC}"
    done <<< "$changed"
}

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
    print_local_change_diagnostics "$REPO_STATUS"
    echo
    echo -e "${YELLOW}Git-Status im Setup-Verzeichnis:${NC}"
    print_colored_git_status <<< "$REPO_STATUS"
    exit 2
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

LOCAL_SHA_FULL_BEFORE="$(git -C "$INSTALL_DIR" rev-parse HEAD)"
LOCAL_SHA_BEFORE="$(git -C "$INSTALL_DIR" rev-parse --short HEAD)"
REMOTE_SHA_BEFORE="$(git -C "$INSTALL_DIR" rev-parse --short origin/main)"
BEHIND_BEFORE="$(git -C "$INSTALL_DIR" rev-list --count HEAD..origin/main)"
AHEAD_BEFORE="$(git -C "$INSTALL_DIR" rev-list --count origin/main..HEAD)"

if [ "$BEHIND_BEFORE" -gt 0 ] && [ "$AHEAD_BEFORE" -eq 0 ]; then
    echo -e "${YELLOW}Vor Update: lokaler Stand war ${BEHIND_BEFORE} Commit(s) hinter origin/main.${NC}"
elif [ "$BEHIND_BEFORE" -eq 0 ] && [ "$AHEAD_BEFORE" -eq 0 ]; then
    echo -e "${GREEN}Vor Update: lokaler Stand war bereits aktuell (${LOCAL_SHA_BEFORE}).${NC}"
else
    echo -e "${YELLOW}Vor Update: lokaler Stand wich von origin/main ab (lokal ${LOCAL_SHA_BEFORE}, remote ${REMOTE_SHA_BEFORE}; ahead ${AHEAD_BEFORE}, behind ${BEHIND_BEFORE}).${NC}"
fi

echo -e "${GREEN}Führe Fast-Forward-Update aus...${NC}"
git -C "$INSTALL_DIR" pull --ff-only origin main
echo -e "${GREEN}Update ausgefuehrt.${NC}"

LOCAL_SHA="$(git -C "$INSTALL_DIR" rev-parse HEAD)"
REMOTE_SHA="$(git -C "$INSTALL_DIR" rev-parse origin/main)"
LOCAL_SHA_SHORT="$(git -C "$INSTALL_DIR" rev-parse --short HEAD)"
REMOTE_SHA_SHORT="$(git -C "$INSTALL_DIR" rev-parse --short origin/main)"
BEHIND_AFTER="$(git -C "$INSTALL_DIR" rev-list --count HEAD..origin/main)"
AHEAD_AFTER="$(git -C "$INSTALL_DIR" rev-list --count origin/main..HEAD)"

if [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
    echo -e "${GREEN}Nach Update: lokaler Stand ist jetzt aktuell bei ${LOCAL_SHA_SHORT}.${NC}"
    print_updated_files_between "$LOCAL_SHA_FULL_BEFORE" "$LOCAL_SHA"
    echo -e "${GREEN}Das Setup ist aktuell.${NC}"
    echo -e "${YELLOW}Starte das Menü danach neu, damit neue Menütexte und Sprachdateien sicher geladen werden.${NC}"
    exit 0
fi

echo -e "${YELLOW}Nach Update: lokaler Stand ist noch nicht identisch mit origin/main (lokal ${LOCAL_SHA_SHORT}, remote ${REMOTE_SHA_SHORT}; ahead ${AHEAD_AFTER}, behind ${BEHIND_AFTER}).${NC}"
echo -e "${GREEN}Setup-Update abgeschlossen.${NC}"
echo -e "${YELLOW}Falls sich das Setup selbst geaendert hat, starten Sie das Menue danach neu.${NC}"
