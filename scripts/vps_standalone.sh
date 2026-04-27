#!/bin/bash
# ==============================================================================
# VPS_STANDALONE.SH - VPS-only Foundation Setup (Cloud-Native)
# Bereitet einen VPS fuer K3s-basierte Deployments vor und legt eine saubere
# Grundlage fuer OpenManus, Zenbot und weitere Dienste an.
# ==============================================================================

set -euo pipefail

# Farben
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

VPS_STACK_DIR="/opt/openclaw-vps"
MANIFEST_DIR="$VPS_STACK_DIR/manifests"
STATE_FILE="$VPS_STACK_DIR/README.md"

run_sudo() {
    if [ "${EUID}" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Benoetigter Befehl '$1' ist nicht verfuegbar.${NC}"
        exit 1
    fi
}

install_base_packages() {
    if ! command -v apt-get >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Dieses Skript unterstuetzt aktuell nur apt-basierte Systeme.${NC}"
        exit 1
    fi

    echo -e "${GREEN}1/4: Installiere grundlegende VPS-Abhaengigkeiten...${NC}"
    run_sudo apt-get update
    run_sudo apt-get install -y curl ca-certificates git
}

install_k3s() {
    echo -e "${GREEN}2/4: Pruefe K3s Installation...${NC}"

    if command -v k3s >/dev/null 2>&1; then
        echo -e "${YELLOW}K3s ist bereits installiert. Ueberspringe Neuinstallation.${NC}"
    else
        echo -e "${BLUE}Installiere K3s (Lightweight Kubernetes)...${NC}"
        curl -sfL https://get.k3s.io | sh -
    fi

    if ! run_sudo systemctl is-active --quiet k3s; then
        echo -e "${RED}Fehler: Der K3s-Dienst laeuft nicht erfolgreich.${NC}"
        echo -e "${YELLOW}Bitte pruefen Sie 'sudo systemctl status k3s' fuer Details.${NC}"
        exit 1
    fi

    if ! command -v kubectl >/dev/null 2>&1; then
        echo -e "${YELLOW}kubectl ist nicht direkt im PATH. Verwende /usr/local/bin/kubectl, falls vorhanden.${NC}"
        if [ -x /usr/local/bin/kubectl ]; then
            export PATH="/usr/local/bin:$PATH"
        fi
    fi

    require_command kubectl
    echo -e "${GREEN}K3s laeuft und kubectl ist verfuegbar.${NC}"
}

prepare_workspace() {
    echo -e "${GREEN}3/4: Lege VPS-Workspace und Deployment-Hinweise an...${NC}"
    run_sudo mkdir -p "$MANIFEST_DIR"
    run_sudo tee "$STATE_FILE" >/dev/null <<EOF
# OpenClaw VPS Standalone Foundation

Dieser VPS wurde fuer K3s-basierte Deployments vorbereitet.

Vorbereitete Verzeichnisse:
- $VPS_STACK_DIR
- $MANIFEST_DIR

Empfohlene naechste Schritte:
1. OpenManus Deployment-Manifest nach $MANIFEST_DIR/openmanus.yaml legen und mit kubectl anwenden.
2. Zenbot Deployment-Manifest nach $MANIFEST_DIR/zenbot.yaml legen und mit kubectl anwenden.
3. Optionalen Gemini/Ollama-Proxy nach $MANIFEST_DIR/gemini-ollama-proxy.yaml legen.
4. Status pruefen mit:
   sudo kubectl get nodes
   sudo kubectl get pods -A

Wichtiger Hinweis:
Dieses Skript installiert bewusst keine unfertigen Platzhalter-Deployments mehr.
Es bereitet den VPS verifizierbar vor, damit nachfolgende Kubernetes-Manifeste
sauber und reproduzierbar eingespielt werden koennen.
EOF
}

print_summary() {
    echo -e "${GREEN}4/4: VPS-Foundation erfolgreich vorbereitet.${NC}"
    echo -e "${BLUE}K3s-Status:${NC}"
    run_sudo kubectl get nodes || true
    echo ""
    echo -e "${YELLOW}Hinweis:${NC} OpenManus, Zenbot und der Gemini/Ollama-Proxy werden hier nicht mehr als unfertige Platzhalter installiert."
    echo -e "${YELLOW}Die naechsten manuellen Deployment-Schritte finden Sie in:${NC} $STATE_FILE"
}

echo -e "${BLUE}Starte VPS-Standalone-Foundation-Setup...${NC}"

install_base_packages
install_k3s
prepare_workspace
print_summary
