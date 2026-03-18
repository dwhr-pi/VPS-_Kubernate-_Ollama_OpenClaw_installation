#!/bin/bash
# ==============================================================================
# VOLLAUTOMATISCHES GITHUB-BASIERTES SETUP V2 (WSL2 / Ubuntu)
# Fokus: Kompilieren aus Quellen, KEIN Docker, Gemini & Ollama Integration
# Komponenten: Ollama, OpenManus, OpenClaw (incl. RL), Home Assistant, 
#              Google Kalender Skills, Alexa Skill, Zenbot, DDNS
# ==============================================================================

# Farben für die Ausgabe
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Starte das erweiterte GitHub-basierte Setup V2...${NC}"

# 1. System-Update & Basis-Abhängigkeiten
echo -e "${GREEN}[1/10] Installiere System-Abhängigkeiten...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git build-essential python3-pip python3-venv python3-dev \
                    libffi-dev libssl-dev libjpeg-dev zlib1g-dev autoconf \
                    libxml2-dev libxslt1-dev libxmlsec1-dev libffi-dev libpcre3-dev \
                    jq screen bc mongodb-server nodejs npm ffmpeg

# 2. Ollama & Gemini Integration
echo -e "${GREEN}[2/10] Konfiguriere KI-Backends (Ollama & Gemini)...${NC}"
curl -fsSL https://ollama.com/install.sh | sh
sleep 5
ollama serve > /dev/null 2>&1 &
sleep 5
ollama pull llama3.2 

echo -e "${BLUE}Bitte geben Sie Ihren Google Gemini API Key ein:${NC}"
read -p "Gemini API Key: " GEMINI_KEY

# 3. OpenClaw RL (Reinforcement Learning Version) & OpenManus
echo -e "${GREEN}[3/10] Installiere OpenClaw RL & OpenManus...${NC}"
mkdir -p ~/ai-agents && cd ~/ai-agents

# OpenClaw RL Setup
git clone https://github.com/Gen-Verse/OpenClaw-RL.git
cd OpenClaw-RL
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
# RL Konfiguration (Beispielhaft)
echo "GEMINI_API_KEY=$GEMINI_KEY" > .env
echo "RL_TRAINING=true" >> .env
deactivate
cd ..

# OpenManus Setup
git clone https://github.com/open-manus/OpenManus.git
cd OpenManus
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cat <<EOF > config.yaml
llm:
  provider: gemini
  model: gemini-1.5-flash
  api_key: "$GEMINI_KEY"
EOF
deactivate
cd ~

# 4. Home Assistant Core & Google Kalender Integration
echo -e "${GREEN}[4/10] Installiere Home Assistant Core & Kalender-Skills...${NC}"
sudo useradd -rm homeassistant
sudo mkdir /srv/homeassistant
sudo chown homeassistant:homeassistant /srv/homeassistant
sudo -u homeassistant -H -s <<EOF
cd /srv/homeassistant
python3 -m venv .
source bin/activate
pip3 install homeassistant google-api-python-client google-auth-oauthlib
EOF

# Google Kalender Skill Vorbereitung (OAuth2)
echo -e "${BLUE}Hinweis: Für Google Kalender müssen Sie die credentials.json in /home/homeassistant/.homeassistant/ platzieren.${NC}"

# 5. Zenbot (Trading Bot)
echo -e "${GREEN}[5/10] Installiere Zenbot...${NC}"
git clone https://github.com/DeviaVir/zenbot.git ~/zenbot
cd ~/zenbot
npm install
sudo systemctl enable mongodb
sudo systemctl start mongodb
cp conf-sample.js conf.js
cd ~

# 6. Alexa Skill & Cloudflared
echo -e "${GREEN}[6/10] Konfiguriere Alexa Skill via Cloudflare Tunnel...${NC}"
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared.deb
rm cloudflared.deb

# 7. Hurricane Electric DDNS
echo -e "${GREEN}[7/10] Konfiguriere Hurricane Electric DDNS...${NC}"
read -p "HE.net Hostname: " HE_HOSTNAME
read -p "HE.net DDNS Key: " HE_KEY
cat <<EOF > ~/update_ddns.sh
#!/bin/bash
curl -4 "https://dyn.dns.he.net/nic/update?hostname=$HE_HOSTNAME&password=$HE_KEY"
EOF
chmod +x ~/update_ddns.sh
(crontab -l 2>/dev/null; echo "*/15 * * * * ~/update_ddns.sh") | crontab -

# 8. Systemd Services (HA, Ollama, OpenClaw RL)
echo -e "${GREEN}[8/10] Erstelle Systemd Services...${NC}"
# Home Assistant Service
sudo cat <<EOF > /etc/systemd/system/homeassistant.service
[Unit]
Description=Home Assistant
After=network-online.target
[Service]
Type=simple
User=homeassistant
ExecStart=/srv/homeassistant/bin/hass -c "/home/homeassistant/.homeassistant"
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

# OpenClaw RL Service
sudo cat <<EOF > /etc/systemd/system/openclaw-rl.service
[Unit]
Description=OpenClaw RL Agent
After=network.target
[Service]
Type=simple
User=$USER
WorkingDirectory=/home/$USER/ai-agents/OpenClaw-RL
ExecStart=/home/$USER/ai-agents/OpenClaw-RL/venv/bin/python main.py
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable homeassistant openclaw-rl
sudo systemctl start homeassistant

# 9. Alexa & Google Kalender Skill Details
echo -e "${GREEN}[9/10] Finale Skill-Konfiguration...${NC}"
# Hier könnten spezifische Skill-Dateien aus dem dwhr-pi Repo kopiert werden
# Beispiel: cp ~/ai-agents/OpenClaw-RL/skills/google_calendar.py ...

# 10. Abschluss
echo -e "${BLUE}Installation abgeschlossen!${NC}"
echo -e "Home Assistant: http://localhost:8123"
echo -e "Ollama: http://localhost:11434"
echo -e "OpenClaw RL läuft als Hintergrunddienst.${NC}"
