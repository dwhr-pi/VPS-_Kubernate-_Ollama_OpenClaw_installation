#!/bin/bash
# ==============================================================================
# HYBRID_SETUP.SH - Hybrid-Setup (MiniPC + Multi-VPS)
# Dieses Skript konfiguriert den Letsung MiniPC und bereitet die VPS-Integration vor.
# ==============================================================================

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

echo -e "${BLUE}Starte Hybrid-Setup für Letsung MiniPC und Multi-VPS...${NC}"

# 1. Ressourcenplan (für Dokumentation)
cat <<EOF > ~/RESOURCE_PLAN.md
# Ressourcenplan für Hybrid-Setup

Dieses Setup verteilt die Last und Funktionalitäten auf Ihren Letsung MiniPC und mehrere VPS, um optimale Leistung und Kostenersparnis zu gewährleisten.

## Letsung MiniPC (WSL2) - 16GB RAM / 70GB Disk

*   **Ollama:** Lokales LLM-Backend für `llama3.2:1b` (Fallback für Gemini, Privacy-Modus).
*   **OpenClaw (Hauptinstanz):** Kern-KI-Agent mit OpenClaw RL und gcali Skill.
*   **Home Assistant Core:** Lokale Smart Home Steuerung, Google Kalender Integration, Alexa Skill Backend (via Cloudflare Tunnel).
*   **Cloudflared:** Tunnel für sicheren externen Zugriff auf Home Assistant und OpenClaw.

## Oracle Cloud Free Tier VPS (oder ähnlicher 24GB RAM VPS)

*   **K3s (Kubernetes) Control Plane & Worker:** Leichtgewichtiges Kubernetes-Cluster.
*   **Zenbot Trading Bot:** Für 24/7 Krypto-Trading-Operationen.
*   **OpenManus (Agent):** Für Web-Recherche, Datenanalyse und Cloud-basierte Aufgaben.
*   **Gemini-Ollama Fallback Proxy:** Ein kleiner Dienst, der Anfragen an Gemini sendet und bei Ausfall/Limit auf den Ollama auf dem MiniPC (via VPN/Tunnel) umschaltet.

## Zusätzliche kostenlose VPS (z.B. Google Cloud Free Tier, AWS Free Tier)

*   **Monitoring:** Grafana und Prometheus für System- und Anwendungsüberwachung.
*   **Backup-Dienste:** Automatisierte Backups für MongoDB (Zenbot) und Home Assistant Konfigurationen.
*   **Spezialisierte Dienste:** Bei Bedarf weitere spezialisierte Dienste, die hohe Verfügbarkeit erfordern.

EOF

# 2. Ollama Modell herunterladen
echo -e "${GREEN}1/5: Lade Ollama Modell llama3.2:1b herunter...${NC}"
ollama pull llama3.2:1b
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: Ollama Modell konnte nicht heruntergeladen werden. Prüfen Sie Ihre Ollama-Installation.${NC}"
    exit 1
fi

# 3. OpenClaw .env Konfiguration (Gemini-Ollama Fallback)
echo -e "${GREEN}2/5: Konfiguriere OpenClaw .env für Gemini-Ollama Fallback...${NC}"
OPENCLAW_DIR="/opt/openclaw"
if [ ! -f "$OPENCLAW_DIR/.env" ]; then
    cp "$OPENCLAW_DIR/.env.example" "$OPENCLAW_DIR/.env"
fi

# API Key Abfrage für Gemini
read -p "Bitte geben Sie Ihren Google Gemini API Key ein: " GEMINI_API_KEY

# .env aktualisieren
sed -i "s/^LLM_PROVIDER=.*/LLM_PROVIDER=gemini/" "$OPENCLAW_DIR/.env"
sed -i "s/^GEMINI_API_KEY=.*/GEMINI_API_KEY=$GEMINI_API_KEY/" "$OPENCLAW_DIR/.env"
sed -i "s/^GEMINI_MODEL=.*/GEMINI_MODEL=gemini-1.5-flash/" "$OPENCLAW_DIR/.env"
sed -i "s/^OLLAMA_BASE_URL=.*/OLLAMA_BASE_URL=http:\/\/localhost:11434/" "$OPENCLAW_DIR/.env"
sed -i "s/^OLLAMA_MODEL=.*/OLLAMA_MODEL=llama3.2:1b/" "$OPENCLAW_DIR/.env"
# Füge Fallback-Variable hinzu, falls nicht vorhanden
if ! grep -q "FALLBACK_TO_OLLAMA" "$OPENCLAW_DIR/.env"; then
    echo "FALLBACK_TO_OLLAMA=true" >> "$OPENCLAW_DIR/.env"
fi

echo -e "${GREEN}OpenClaw .env erfolgreich konfiguriert.${NC}"

# 4. Home Assistant Core Installation
echo -e "${GREEN}3/5: Installiere Home Assistant Core...${NC}"
python3 -m venv /srv/homeassistant
/srv/homeassistant/bin/pip install wheel
/srv/homeassistant/bin/pip install homeassistant

# Systemd Service für Home Assistant
sudo cp /opt/openclaw/docs/homeassistant.service /etc/systemd/system/homeassistant@homeassistant.service
sudo systemctl daemon-reload
sudo systemctl enable homeassistant@homeassistant
sudo systemctl start homeassistant@homeassistant

echo -e "${GREEN}Home Assistant Core installiert und gestartet.${NC}"

# 5. Cloudflared Installation & Konfiguration (für Alexa Skill)
echo -e "${GREEN}4/5: Installiere Cloudflared für Alexa Skill...${NC}"
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared.deb
sudo cloudflared service install

# Cloudflared Tunnel konfigurieren (Platzhalter - Benutzer muss Token eingeben)
echo -e "${YELLOW}Bitte melden Sie sich bei Cloudflare an und erstellen Sie einen Tunnel. Fügen Sie dann den Token hier ein.${NC}"
read -p "Cloudflare Tunnel Token: " CF_TUNNEL_TOKEN
sudo cloudflared tunnel login
sudo cloudflared tunnel create alexa-skill-tunnel
sudo cloudflared tunnel route dns alexa-skill-tunnel your_domain.com
sudo cloudflared tunnel run --token $CF_TUNNEL_TOKEN alexa-skill-tunnel

echo -e "${GREEN}Cloudflared installiert und Tunnel konfiguriert (manuelle Token-Eingabe erforderlich).${NC}"

# 6. gcali Skill Integration (OpenClaw)
echo -e "${GREEN}5/5: Integriere gcali Skill in OpenClaw...${NC}"
# Annahme: gcali Skill-Dateien sind im dwhr-pi Repo unter openclaw/skills/gcali
# Kopiere diese in die OpenClaw Installation

# Hier müsste der Pfad zum geklonten dwhr-pi Repo bekannt sein
# Fürs Erste nehmen wir an, dass die gcali Dateien manuell kopiert werden müssen

echo -e "${YELLOW}Hinweis: gcali Skill-Dateien müssen manuell in /opt/openclaw/skills/gcali kopiert werden.${NC}"
echo -e "${YELLOW}Folgen Sie den Anweisungen im API_KEY_GUIDE.md für die Google Kalender API-Einrichtung.${NC}"

echo -e "${GREEN}Hybrid-Setup abgeschlossen. Bitte prüfen Sie die Konfigurationen und starten Sie OpenClaw/Home Assistant neu.${NC}"
