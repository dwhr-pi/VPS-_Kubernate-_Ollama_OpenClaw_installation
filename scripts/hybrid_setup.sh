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

TTY_DEVICE="/dev/tty"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_ASSISTANT_USER="homeassistant"
HOME_ASSISTANT_HOME="/var/lib/homeassistant"
HOME_ASSISTANT_VENV="/srv/homeassistant"
OPENCLAW_DIR="/opt/openclaw"

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

escape_sed_replacement() {
    printf '%s' "$1" | sed -e 's/[\/&]/\\&/g'
}

ensure_ollama_available() {
    if ! command -v ollama >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Ollama ist nicht installiert.${NC}"
        exit 1
    fi

    if ! ollama list >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Ollama ist installiert, aber der Dienst ist nicht erreichbar.${NC}"
        echo -e "${YELLOW}Bitte starten Sie Ollama zuerst, z.B. mit 'ollama serve'.${NC}"
        exit 1
    fi
}

ensure_openclaw_env() {
    if [ ! -d "$OPENCLAW_DIR" ]; then
        echo -e "${RED}Fehler: OpenClaw wurde unter ${OPENCLAW_DIR} nicht gefunden.${NC}"
        exit 1
    fi

    if [ ! -f "$OPENCLAW_DIR/.env" ]; then
        if [ -f "$OPENCLAW_DIR/.env.example" ]; then
            cp "$OPENCLAW_DIR/.env.example" "$OPENCLAW_DIR/.env"
        else
            echo -e "${RED}Fehler: Weder .env noch .env.example wurden unter ${OPENCLAW_DIR} gefunden.${NC}"
            exit 1
        fi
    fi
}

echo -e "${BLUE}Starte Hybrid-Setup für Letsung MiniPC und Multi-VPS...${NC}"

# 1. Ressourcenplan (für Dokumentation)
cat <<EOF > ~/RESOURCE_PLAN.md
# Ressourcenplan für Hybrid-Setup

Dieses Setup verteilt die Last und Funktionalitäten auf Ihren Letsung MiniPC und mehrere VPS, um optimale Leistung und Kostenersparnis zu gewährleisten.

## Letsung MiniPC (WSL2) - 16GB RAM / 70GB Disk

*   **Ollama:** Lokales LLM-Backend für \`llama3.2:1b\` (Fallback für Gemini, Privacy-Modus).
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
ensure_ollama_available
if ! ollama pull llama3.2:1b; then
    echo -e "${RED}Fehler: Ollama Modell konnte nicht heruntergeladen werden. Prüfen Sie Ihre Ollama-Installation.${NC}"
    exit 1
fi

# 3. OpenClaw .env Konfiguration (Gemini-Ollama Fallback)
echo -e "${GREEN}2/5: Konfiguriere OpenClaw .env für Gemini-Ollama Fallback...${NC}"
ensure_openclaw_env
read_from_tty "Bitte geben Sie Ihren Google Gemini API Key ein: " GEMINI_API_KEY true
GEMINI_API_KEY_ESCAPED="$(escape_sed_replacement "$GEMINI_API_KEY")"

sed -i "s/^LLM_PROVIDER=.*/LLM_PROVIDER=gemini/" "$OPENCLAW_DIR/.env"
sed -i "s/^GEMINI_API_KEY=.*/GEMINI_API_KEY=$GEMINI_API_KEY_ESCAPED/" "$OPENCLAW_DIR/.env"
sed -i "s/^GEMINI_MODEL=.*/GEMINI_MODEL=gemini-1.5-flash/" "$OPENCLAW_DIR/.env"
sed -i "s/^OLLAMA_BASE_URL=.*/OLLAMA_BASE_URL=http:\/\/localhost:11434/" "$OPENCLAW_DIR/.env"
sed -i "s/^OLLAMA_MODEL=.*/OLLAMA_MODEL=llama3.2:1b/" "$OPENCLAW_DIR/.env"
if ! grep -q "FALLBACK_TO_OLLAMA" "$OPENCLAW_DIR/.env"; then
    echo "FALLBACK_TO_OLLAMA=true" >> "$OPENCLAW_DIR/.env"
fi

echo -e "${GREEN}OpenClaw .env erfolgreich konfiguriert.${NC}"

# 4. Home Assistant Core Installation
echo -e "${GREEN}3/5: Installiere Home Assistant Core...${NC}"
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

# 5. Cloudflared Installation & Konfiguration (für Alexa Skill)
echo -e "${GREEN}4/5: Installiere Cloudflared für Alexa Skill...${NC}"
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared.deb
sudo cloudflared service install

echo -e "${YELLOW}Bitte melden Sie sich bei Cloudflare an und erstellen Sie einen Tunnel.${NC}"
echo -e "${YELLOW}Anschließend wird nur noch der Token erfasst und die weiteren Schritte als Hinweise ausgegeben, damit das Skript nicht im Vordergrund blockiert.${NC}"
echo -e "${YELLOW}Siehe dazu auch docs/CLOUDFLARE_TUNNEL_GUIDE.md für die Cloudflare-Seitenfolge bis zum Tunnel-Token.${NC}"
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

# 6. gcali Skill Integration (OpenClaw)
echo -e "${GREEN}5/5: Integriere gcali Skill in OpenClaw...${NC}"
echo -e "${YELLOW}Hinweis: gcali Skill-Dateien müssen manuell in /opt/openclaw/skills/gcali kopiert werden.${NC}"
echo -e "${YELLOW}Folgen Sie den Anweisungen im API_KEY_GUIDE.md für die Google Kalender API-Einrichtung.${NC}"

echo -e "${GREEN}Hybrid-Setup abgeschlossen. Bitte prüfen Sie die Konfigurationen und starten Sie OpenClaw/Home Assistant neu.${NC}"
