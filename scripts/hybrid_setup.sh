#!/bin/bash
# ==============================================================================
# HYBRID-SETUP (MINIPC + MULTI-VPS)
# Verteilung der Last auf Letsung (16GB RAM) und Oracle VPS (24GB RAM)
# ==============================================================================

# Farben
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Konfiguriere Hybrid-Setup (MiniPC + VPS)...${NC}"

# 1. Lastverteilung Plan (Dokumentation)
cat <<EOF > ~/RESOURCE_PLAN.txt
RESSOURCENPLANUNG (HYBRID):
---------------------------
Letsung MiniPC (Lokal):
- Ollama (llama3.2:1b) -> Fokus auf Privacy & Fallback
- Home Assistant Core -> Fokus auf lokale Steuerung (Alexa, Kalender)
- OpenClaw RL Agent -> Fokus auf Lernen aus Nutzer-Interaktion

Oracle VPS (Cloud):
- K3s (Kubernetes) Cluster Control Plane
- Zenbot Trading Dashboard -> Fokus auf 24/7 Verfügbarkeit
- OpenManus (Agent) -> Fokus auf Web-Recherche & Cloud-Tasks
- Gemini-Proxy -> Fokus auf API-Routing (Gemini-Ollama Fallback)

Zusätzliche kostenlose VPS (z.B. Google Cloud Free Tier):
- Monitoring (Grafana/Prometheus)
- Backup-Dienste (MongoDB Backups)
EOF

# 2. Installation von pnpm (Zwingend erforderlich!)
echo -e "${GREEN}[1/5] Installiere pnpm global...${NC}"
if ! command -v pnpm >/dev/null 2>&1; then
    sudo npm install -g pnpm
fi

# 3. OpenClaw & OpenManus (GitHub Source Build)
echo -e "${GREEN}[2/5] Baue OpenClaw aus Quellen (pnpm)...${NC}"
cd ~
git clone https://github.com/openclaw/openclaw.git
cd openclaw
pnpm install
pnpm build
# gcali Skill Integration
mkdir -p skills/gcali
# Hier werden die Skill-Dateien aus dem dwhr-pi Repo eingebunden
cd ~

# 4. Ollama & llama3.2:1b (Ressourcenschonend)
echo -e "${GREEN}[3/5] Konfiguriere Ollama (llama3.2:1b)...${NC}"
ollama pull llama3.2:1b

# 5. Fallback-Routing Konfiguration
echo -e "${GREEN}[4/5] Konfiguriere Gemini-Ollama-Fallback...${NC}"
cat <<EOF > ~/openclaw/.env
LLM_PROVIDER=gemini
GEMINI_API_KEY=PLACEHOLDER
GEMINI_MODEL=gemini-1.5-flash
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3.2:1b
EOF

echo -e "${BLUE}Hybrid-Setup erfolgreich vorbereitet!${NC}"
