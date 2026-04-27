#!/bin/bash
# ==============================================================================
# INSTALL_LOCAL_ONLY.SH - Standalone MiniPC Setup (Lokal)
# Dieses Skript installiert alle lokalen Komponenten für einen reinen MiniPC-Betrieb.
# ==============================================================================

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

TTY_DEVICE="/dev/tty"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_ASSISTANT_USER="homeassistant"
HOME_ASSISTANT_HOME="/var/lib/homeassistant"
HOME_ASSISTANT_VENV="/srv/homeassistant"

read_from_tty() {
    local prompt="$1"
    local target_var="$2"
    local secret="${3:-false}"
    local input_value

    if [ ! -e "$TTY_DEVICE" ]; then
        echo -e "${RED}Fehler: Kein interaktives Terminal für Eingaben verfügbar.${NC}"
        exit 1
    fi

    if [ "$secret" = "true" ]; then
        read -r -s -p "$prompt" input_value < "$TTY_DEVICE"
        echo
    else
        read -r -p "$prompt" input_value < "$TTY_DEVICE"
    fi

    printf -v "$target_var" '%s' "$input_value"
}

echo -e "${BLUE}Starte Standalone MiniPC-Setup: Home Assistant, Cloudflared, gcali...${NC}"

# 1. Home Assistant Core Installation
echo -e "${GREEN}1/3: Installiere Home Assistant Core...${NC}"
if ! id -u "$HOME_ASSISTANT_USER" >/dev/null 2>&1; then
    sudo useradd --system --create-home --home-dir "$HOME_ASSISTANT_HOME" --shell /usr/sbin/nologin "$HOME_ASSISTANT_USER"
fi
sudo mkdir -p "$HOME_ASSISTANT_VENV" "$HOME_ASSISTANT_HOME/.homeassistant"
sudo chown -R "$HOME_ASSISTANT_USER":"$HOME_ASSISTANT_USER" "$HOME_ASSISTANT_VENV" "$HOME_ASSISTANT_HOME"
sudo -u "$HOME_ASSISTANT_USER" python3 -m venv "$HOME_ASSISTANT_VENV"
sudo -u "$HOME_ASSISTANT_USER" "$HOME_ASSISTANT_VENV/bin/pip" install wheel
sudo -u "$HOME_ASSISTANT_USER" "$HOME_ASSISTANT_VENV/bin/pip" install homeassistant

sudo cp "$SCRIPT_DIR/../docs/homeassistant.service" /etc/systemd/system/homeassistant@homeassistant.service
sudo systemctl daemon-reload
sudo systemctl enable homeassistant@homeassistant
sudo systemctl start homeassistant@homeassistant

echo -e "${GREEN}Home Assistant Core installiert und gestartet.${NC}"

# 2. Cloudflared Installation & Konfiguration (für Alexa Skill)
echo -e "${GREEN}2/3: Installiere Cloudflared für Alexa Skill...${NC}"
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared.deb
sudo cloudflared service install

echo -e "${YELLOW}Bitte melden Sie sich bei Cloudflare an und erstellen Sie einen Tunnel.${NC}"
echo -e "${YELLOW}Der Token wird nur erfasst; die eigentlichen Tunnel-Befehle werden anschließend als manuelle Schritte ausgegeben, damit das Skript nicht blockiert.${NC}"
read_from_tty "Cloudflare Tunnel Token: " CF_TUNNEL_TOKEN true

if [ -n "$CF_TUNNEL_TOKEN" ]; then
    echo -e "${BLUE}Cloudflare Tunnel Token erfasst.${NC}"
    echo -e "${YELLOW}Führen Sie die folgenden Befehle bei Bedarf manuell aus:${NC}"
    echo "sudo cloudflared tunnel login"
    echo "sudo cloudflared tunnel create alexa-skill-tunnel"
    echo "sudo cloudflared tunnel route dns alexa-skill-tunnel <ihre-domain>"
    echo "sudo cloudflared tunnel run --token <ihr-token> alexa-skill-tunnel"
else
    echo -e "${YELLOW}Kein Cloudflare Tunnel Token eingegeben. Cloudflared wurde installiert, die Tunnel-Konfiguration bleibt manuell.${NC}"
fi

echo -e "${GREEN}Cloudflared installiert. Die Tunnel-Konfiguration ist als manueller Schritt dokumentiert.${NC}"

# 3. gcali Skill Integration (OpenClaw)
echo -e "${GREEN}3/3: Integriere gcali Skill in OpenClaw...${NC}"
echo -e "${YELLOW}Hinweis: gcali Skill-Dateien müssen manuell in /opt/openclaw/skills/gcali kopiert werden.${NC}"
echo -e "${YELLOW}Folgen Sie den Anweisungen im API_KEY_GUIDE.md für die Google Kalender API-Einrichtung.${NC}"

echo -e "${GREEN}Standalone MiniPC-Setup abgeschlossen. Bitte prüfen Sie die Konfigurationen und starten Sie OpenClaw/Home Assistant neu.${NC}"
