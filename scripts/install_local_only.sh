#!/bin/bash
# ==============================================================================
# INSTALL_LOCAL_ONLY.SH - Standalone MiniPC Setup (Lokal)
# Dieses Skript installiert alle lokalen Komponenten für einen reinen MiniPC-Betrieb.
# ==============================================================================

# Farben
GREEN=\033[032m
BLUE=\033[034m
RED=\033[031m
YELLOW=\033[133m
NC=\033[0m

echo -e "${BLUE}Starte Standalone MiniPC-Setup: Home Assistant, Cloudflared, gcali...${NC}"

# 1. Home Assistant Core Installation
echo -e "${GREEN}1/3: Installiere Home Assistant Core...${NC}"
python3 -m venv /srv/homeassistant
/srv/homeassistant/bin/pip install wheel
/srv/homeassistant/bin/pip install homeassistant

# Systemd Service für Home Assistant
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

# Cloudflared Tunnel konfigurieren (Platzhalter - Benutzer muss Token eingeben)
echo -e "${YELLOW}Bitte melden Sie sich bei Cloudflare an und erstellen Sie einen Tunnel. Fügen Sie dann den Token hier ein.${NC}"
read -p "Cloudflare Tunnel Token: " CF_TUNNEL_TOKEN
sudo cloudflared tunnel login
sudo cloudflared tunnel create alexa-skill-tunnel
sudo cloudflared tunnel route dns alexa-skill-tunnel your_domain.com # Domain anpassen
sudo cloudflared tunnel run --token $CF_TUNNEL_TOKEN alexa-skill-tunnel

echo -e "${GREEN}Cloudflared installiert und Tunnel konfiguriert (manuelle Token-Eingabe erforderlich).${NC}"

# 3. gcali Skill Integration (OpenClaw)
echo -e "${GREEN}3/3: Integriere gcali Skill in OpenClaw...${NC}"
# Annahme: gcali Skill-Dateien sind im dwhr-pi Repo unter openclaw/skills/gcali
# Kopiere diese in die OpenClaw Installation

# Hier müsste der Pfad zum geklonten dwhr-pi Repo bekannt sein
# Fürs Erste nehmen wir an, dass die gcali Dateien manuell kopiert werden müssen

echo -e "${YELLOW}Hinweis: gcali Skill-Dateien müssen manuell in /opt/openclaw/skills/gcali kopiert werden.${NC}"
echo -e "${YELLOW}Folgen Sie den Anweisungen im API_KEY_GUIDE.md für die Google Kalender API-Einrichtung.${NC}"

echo -e "${GREEN}Standalone MiniPC-Setup abgeschlossen. Bitte prüfen Sie die Konfigurationen und starten Sie OpenClaw/Home Assistant neu.${NC}"
