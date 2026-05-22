#!/usr/bin/env bash
set -euo pipefail

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "Act"

ACT_DIR="${ACT_DIR:-/opt/act}"
ACT_REPO_URL="${ACT_REPO_URL:-https://github.com/nektos/act.git}"

echo -e "${BLUE}Starte Installation von Act aus GitHub-Quelle...${NC}"
echo -e "${YELLOW}Hinweis: Ubuntu Noble stellt kein apt-Paket 'act' bereit. Act wird deshalb aus dem GitHub-Repository gebaut.${NC}"

if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y git golang-go build-essential ca-certificates
else
    echo -e "${RED}Fehler: apt-get nicht gefunden. Bitte git, Go und Build-Werkzeuge manuell installieren.${NC}"
    exit 1
fi

sudo mkdir -p "$(dirname "$ACT_DIR")"
sudo chown -R "$USER:$USER" "$(dirname "$ACT_DIR")"

if [ -d "$ACT_DIR/.git" ]; then
    echo -e "${YELLOW}Act Repository existiert bereits unter ${ACT_DIR}. Aktualisiere Repository...${NC}"
    git -C "$ACT_DIR" pull --ff-only || {
        echo -e "${YELLOW}Git-Update war nicht möglich. Vorhandene lokale Kopie bleibt erhalten.${NC}"
    }
elif [ -e "$ACT_DIR" ] && [ "$(find "$ACT_DIR" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l)" -gt 0 ]; then
    echo -e "${RED}Fehler: ${ACT_DIR} existiert, ist aber kein leeres Git-Repository.${NC}"
    echo -e "${YELLOW}Bitte Verzeichnis prüfen oder Act vorher deinstallieren.${NC}"
    exit 1
else
    rm -rf "$ACT_DIR"
    git clone "$ACT_REPO_URL" "$ACT_DIR"
fi

echo -e "${BLUE}Baue Act CLI...${NC}"
cd "$ACT_DIR"

build_act_from_source() {
    local target
    local build_targets=(
        "."
        "./cmd"
        "./cmd/act"
    )

    for target in "${build_targets[@]}"; do
        if go list "$target" >/dev/null 2>&1; then
            echo -e "${BLUE}Versuche Go-Build-Ziel: ${target}${NC}"
            if go build -o act "$target"; then
                return 0
            fi
        fi
    done

    echo -e "${YELLOW}Bekannte Build-Ziele haben nicht gepasst. Suche nach main-Packages...${NC}"
    while IFS= read -r target; do
        [ -n "$target" ] || continue
        echo -e "${BLUE}Versuche gefundenes main-Package: ${target}${NC}"
        if go build -o act "$target"; then
            return 0
        fi
    done < <(go list ./... 2>/dev/null | while IFS= read -r package_name; do
        if [ "$(go list -f '{{.Name}}' "$package_name" 2>/dev/null)" = "main" ]; then
            printf '%s\n' "$package_name"
        fi
    done)

    return 1
}

if ! build_act_from_source; then
    echo -e "${RED}Fehler: Act konnte nicht aus dem GitHub-Quellcode gebaut werden.${NC}"
    echo -e "${YELLOW}Hinweis: Der aktuelle Act-Upstream hat offenbar eine geaenderte Go-Struktur oder benoetigt eine neuere Go-Toolchain.${NC}"
    echo -e "${YELLOW}Debug-Hinweis: Im Repository kannst du mit 'go list ./...' die verfuegbaren Go-Packages pruefen.${NC}"
    exit 1
fi

sudo install -m 0755 "$ACT_DIR/act" /usr/local/bin/act

echo -e "${GREEN}Act wurde erfolgreich installiert: $(command -v act)${NC}"
act --version || true
mark_current_tool_installed
