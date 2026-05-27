#!/bin/bash
# ==============================================================================
# AUTOGPT_INSTALL.SH - Installation von AutoGPT
# AutoGPT ist eine Agenten-Plattform von Significant Gravitas.
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
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/tools/helpers/simple_tool_common.sh"
init_tool_tracking "AutoGPT"

AUTOGPT_DIR="/opt/autogpt"
AUTOGPT_PLATFORM_DIR="$AUTOGPT_DIR/autogpt_platform"
AUTOGPT_INSTALLER_REVISION="2026-05-27-buildx-preflight"
AUTOGPT_BUILDX_VERSION="${AUTOGPT_BUILDX_VERSION:-v0.34.1}"
AUTOGPT_REPOS=(
    "${AUTOGPT_REPO_URL:-}"
    "https://github.com/significant-gravitas/autogpt.git"
    "https://github.com/dwhr-pi/AutoGPT.git"
)
AUTOGPT_DOCKER_NEEDS_SUDO=false

docker_info_available_for_autogpt() {
    if docker info >/dev/null 2>&1; then
        AUTOGPT_DOCKER_NEEDS_SUDO=false
        return 0
    fi
    if sudo docker info >/dev/null 2>&1; then
        AUTOGPT_DOCKER_NEEDS_SUDO=true
        return 0
    fi
    return 1
}

run_autogpt_docker_buildkit() {
    if $AUTOGPT_DOCKER_NEEDS_SUDO; then
        sudo env DOCKER_BUILDKIT=1 docker "$@"
    else
        env DOCKER_BUILDKIT=1 docker "$@"
    fi
}

run_autogpt_compose_buildkit() {
    if $AUTOGPT_DOCKER_NEEDS_SUDO; then
        sudo env DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 docker compose "$@"
    else
        env DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 docker compose "$@"
    fi
}

ensure_autogpt_buildx_plugin() {
    local arch
    local buildx_url
    local tmp_file
    local plugin_dir="/usr/local/lib/docker/cli-plugins"
    local plugin_path="$plugin_dir/docker-buildx"
    local plugin_dir_alt="/usr/local/libexec/docker/cli-plugins"
    local plugin_path_alt="$plugin_dir_alt/docker-buildx"

    if docker buildx version >/dev/null 2>&1 && sudo docker buildx version >/dev/null 2>&1; then
        echo -e "${GREEN}Docker Buildx Plugin ist vorhanden: $(docker buildx version 2>/dev/null | head -n 1)${NC}"
        return 0
    fi

    echo -e "${YELLOW}Docker Compose meldet ohne Buildx haeufig: 'Docker Compose requires buildx plugin to be installed'.${NC}"
    echo -e "${BLUE}Installiere Docker Buildx Plugin aus GitHub-Quelle: https://github.com/docker/buildx (${AUTOGPT_BUILDX_VERSION})${NC}"

    if ! command -v curl >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y curl ca-certificates
    fi

    arch="$(uname -m)"
    case "$arch" in
        x86_64|amd64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        armv7l) arch="arm-v7" ;;
        armv6l) arch="arm-v6" ;;
        *)
            echo -e "${RED}Fehler: Keine Buildx-Binary-Architektur fuer '$arch' hinterlegt.${NC}"
            return 1
            ;;
    esac

    buildx_url="https://github.com/docker/buildx/releases/download/${AUTOGPT_BUILDX_VERSION}/buildx-${AUTOGPT_BUILDX_VERSION}.linux-${arch}"
    tmp_file="$(mktemp)"
    curl -fsSL "$buildx_url" -o "$tmp_file"
    sudo mkdir -p "$plugin_dir"
    sudo install -m 0755 "$tmp_file" "$plugin_path"
    sudo mkdir -p "$plugin_dir_alt"
    sudo install -m 0755 "$tmp_file" "$plugin_path_alt"
    rm -f "$tmp_file"

    if ! docker buildx version >/dev/null 2>&1 && sudo docker buildx version >/dev/null 2>&1; then
        echo -e "${YELLOW}Buildx ist nur mit sudo sichtbar. Das ist fuer diesen Installer ausreichend, solange Docker Compose ebenfalls per sudo laeuft.${NC}"
        return 0
    fi

    if docker buildx version >/dev/null 2>&1 || sudo docker buildx version >/dev/null 2>&1; then
        echo -e "${GREEN}Docker Buildx Plugin installiert: $(sudo docker buildx version 2>/dev/null | head -n 1)${NC}"
        return 0
    fi

    echo -e "${RED}Fehler: Docker Buildx Plugin konnte nicht aktiviert werden.${NC}"
    return 1
}

verify_autogpt_buildkit() {
    local tmp_dir

    tmp_dir="$(mktemp -d)"
    cat > "$tmp_dir/Dockerfile" <<'EOF'
# syntax=docker/dockerfile:1
FROM alpine:3.20
RUN --mount=type=cache,target=/tmp/autogpt-buildkit-cache echo buildkit-ok
EOF

    echo -e "${BLUE}Pruefe Docker BuildKit mit kleinem Test-Build...${NC}"
    if run_autogpt_docker_buildkit build -q "$tmp_dir" >/dev/null; then
        rm -rf "$tmp_dir"
        echo -e "${GREEN}Docker BuildKit ist aktiv und kann RUN --mount=type=cache verarbeiten.${NC}"
        return 0
    fi

    rm -rf "$tmp_dir"
    echo -e "${RED}Fehler: Docker BuildKit ist nicht aktiv oder nicht nutzbar.${NC}"
    echo -e "${YELLOW}AutoGPT benoetigt BuildKit, weil der Upstream-Docker-Build RUN --mount=type=cache verwendet.${NC}"
    echo -e "${YELLOW}Ohne diesen Test wuerde der grosse Build spaeter mit 'the --mount option requires BuildKit' abbrechen.${NC}"
    echo -e "${YELLOW}Reparaturhinweis:${NC} Docker-Daemon/Compose pruefen und BuildKit aktivieren. Danach Docker neu starten und AutoGPT erneut starten."
    echo -e "${YELLOW}WSL-Hinweis:${NC} Wenn Docker gerade installiert wurde, kann ein Neustart der Shell oder von WSL/Docker noetig sein."
    return 1
}

echo -e "${BLUE}Starte Installation von AutoGPT...${NC}"
echo -e "${YELLOW}AutoGPT-Installer-Revision:${NC} ${AUTOGPT_INSTALLER_REVISION}"

AUTOGPT_REPO_URL=""
for repo in "${AUTOGPT_REPOS[@]}"; do
    [ -z "$repo" ] && continue
    if git ls-remote "$repo" HEAD >/dev/null 2>&1; then
        AUTOGPT_REPO_URL="$repo"
        break
    fi
done

if [ -z "$AUTOGPT_REPO_URL" ]; then
    echo -e "${RED}Fehler: Kein erreichbares AutoGPT Repository gefunden.${NC}"
    echo -e "${YELLOW}Geprüft wurden significant-gravitas/autogpt und dwhr-pi/AutoGPT.${NC}"
    echo -e "${YELLOW}Setzen Sie bei Bedarf AUTOGPT_REPO_URL auf die korrekte Git-URL und starten Sie das Skript erneut.${NC}"
    exit 1
fi

if [ -d "$AUTOGPT_DIR" ]; then
    echo -e "${YELLOW}AutoGPT Verzeichnis $AUTOGPT_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$AUTOGPT_DIR"
    git pull --ff-only
else
    echo -e "${BLUE}Klone AutoGPT in $AUTOGPT_DIR...${NC}"
    sudo mkdir -p "$AUTOGPT_DIR"
    sudo chown -R "$USER":"$USER" "$AUTOGPT_DIR"
    git clone "$AUTOGPT_REPO_URL" "$AUTOGPT_DIR"
    cd "$AUTOGPT_DIR"
fi

echo -e "${BLUE}Prüfe Docker-Abhängigkeiten für AutoGPT...${NC}"
ensure_docker_compose_available

if ! command -v make >/dev/null 2>&1; then
    echo -e "${YELLOW}make nicht gefunden, installiere build-essential...${NC}"
    sudo apt update
    sudo apt install -y build-essential
fi

if ! command -v docker >/dev/null 2>&1 || ! sudo docker compose version >/dev/null 2>&1; then
    echo -e "${RED}Fehler: Docker oder Docker Compose konnten nicht installiert werden.${NC}"
    exit 1
fi

sudo systemctl enable --now docker >/dev/null 2>&1 || true
sudo usermod -aG docker "$USER" >/dev/null 2>&1 || true

if ! docker_info_available_for_autogpt; then
    echo -e "${RED}Fehler: Docker-Daemon ist nicht erreichbar. AutoGPT benoetigt Docker Compose.${NC}"
    exit 1
fi

if ! ensure_autogpt_buildx_plugin; then
    echo -e "${RED}Fehler: AutoGPT kann ohne Docker Buildx Plugin nicht zuverlaessig gebaut werden.${NC}"
    exit 1
fi

if [ ! -d "$AUTOGPT_PLATFORM_DIR" ]; then
    echo -e "${RED}Fehler: AutoGPT Plattform-Verzeichnis nicht gefunden: $AUTOGPT_PLATFORM_DIR${NC}"
    exit 1
fi

cd "$AUTOGPT_PLATFORM_DIR"

if [ ! -f ".env" ] && [ -f ".env.default" ]; then
    echo -e "${BLUE}Erstelle AutoGPT .env aus .env.default...${NC}"
    cp .env.default .env
fi

echo -e "${BLUE}Starte AutoGPT Plattform per Docker Compose mit BuildKit...${NC}"
echo -e "${YELLOW}Hinweis: AutoGPT wird aus GitHub geklont, der Upstream-Docker-Build zieht jedoch Basis-Images und Container-Abhaengigkeiten.${NC}"
echo -e "${YELLOW}BuildKit wird benoetigt, weil AutoGPT Dockerfile-Features wie RUN --mount=type=cache nutzt.${NC}"
echo -e "${YELLOW}Hinweis zu pip/Poetry-Warnungen:${NC} Falls waehrend des Docker-Builds 'Running pip as root' erscheint, betrifft das den Container-Build."
echo -e "${YELLOW}Der AutoGPT-Installer installiert Poetry/Python-Pakete nicht global per pip auf dem WSL-Host.${NC}"
echo -e "${YELLOW}Hinweis zu Prisma/Poetry:${NC} Meldungen wie 'Generated Prisma Client Python' oder 'gen-prisma-stub ... not installed as a script' stammen aus dem AutoGPT-Backend-Build."
echo -e "${YELLOW}Solange der Docker-Compose-Start am Ende erfolgreich ist, sind diese Prisma-/Poetry-Zeilen Warnungen des Upstream-Builds und kein separater Setup-Abbruch.${NC}"
if ! verify_autogpt_buildkit; then
    exit 1
fi

run_autogpt_compose_buildkit up -d
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: AutoGPT Docker Compose Start fehlgeschlagen.${NC}"
    echo -e "${YELLOW}Reparaturhinweis: Pruefe, ob der Docker-Daemon laeuft und BuildKit verfuegbar ist.${NC}"
    echo -e "${YELLOW}Der typische Fehler lautet: 'the --mount option requires BuildKit'.${NC}"
    echo -e "${YELLOW}Wenn der letzte sichtbare Block Prisma/Poetry nennt, bitte die Zeilen danach pruefen: Prisma-Generierung allein ist meist nicht der eigentliche Fehler.${NC}"
    exit 1
fi

echo -e "${GREEN}AutoGPT Installation abgeschlossen.${NC}"
echo -e "${YELLOW}Die Plattform liegt unter ${AUTOGPT_DIR}.${NC}"
echo -e "${YELLOW}Falls Docker gerade neu installiert wurde, kann eine neue Shell-Anmeldung für die Docker-Gruppe nötig sein.${NC}"
echo -e "${YELLOW}Die AutoGPT Plattform ist nach dem Start typischerweise unter http://localhost:3000 erreichbar.${NC}"
mark_current_tool_installed
