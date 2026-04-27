# Install Checklist

Diese Checkliste beschreibt den aktuell reproduzierbaren Setup-Weg auf Basis der vorhandenen Skripte.

## 1. Bootstrap

```bash
curl -sSL https://raw.githubusercontent.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/main/install.sh | bash
```

## 2. Basis-Setup

Im Menü:

1. `System-Update (OS & pnpm)` ausführen
2. sicherstellen, dass OpenClaw erfolgreich unter `/opt/openclaw` gebaut wurde
3. prüfen, dass Node.js `22.x` aktiv ist

## 3. Zielplattform wählen

- `Hybrid: Letsung MiniPC + Multi-VPS`
- `Standalone: Nur MiniPC`
- `Standalone: Nur VPS (Cloud-Native)`

## 4. OpenClaw konfigurieren

Über den OpenClaw-Konfigurations-Manager:

- `.env.template` anpassen
- `config.json.template` anpassen
- Konfiguration nach `/opt/openclaw` anwenden

Besonders prüfen:

- `GEMINI_API_KEY`
- `OLLAMA_HOST`
- `OLLAMA_MODEL`
- `JWT_SECRET`
- `ADMIN_EMAIL`
- `ADMIN_PASSWORD`
- `GOOGLE_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET`
- `GOOGLE_REDIRECT_URI`
- `CLOUDFLARE_TUNNEL_ID`
- `CLOUDFLARE_TUNNEL_SECRET`

## 5. Ollama vorbereiten

Mindestens ein Modell installieren:

```bash
ollama pull llama3.2:1b
```

Optional weitere Modelle manuell über den Ollama-Modell-Manager installieren.

## 6. Profile installieren

### Programmierer
- `scripts/profiles/Programmierer_install.sh`
- installiert: Huginn, Clawhub CLI, LangGraph, CrewAI, AutoGen, Playwright, ChromaDB

### Media_Musik
- `scripts/profiles/Media_Musik_install.sh`
- installiert: Clawbake, FFmpeg, librosa, pydub, Demucs, Whisper

### KI_Forschung
- `scripts/profiles/KI_Forschung_install.sh`
- installiert: OpenClaw RL, Flowise, LangFlow, LangChain, LlamaIndex, MLflow, Whisper

### Texter_Werbung_Marketing
- `scripts/profiles/Texter_Werbung_Marketing_install.sh`
- installiert: n8n, Activepieces, LangChain, ChromaDB, Playwright

### Rechtsberatung_Steuerrecht
- `scripts/profiles/Rechtsberatung_Steuerrecht_install.sh`
- installiert: Web-Fetch- und PDF/OCR-Werkzeuge, Zotero, LangChain, LlamaIndex, ChromaDB

### Agent_Orchestrator
- `scripts/profiles/Agent_Orchestrator_install.sh`
- installiert: LangGraph, CrewAI, AutoGen, ChromaDB, Redis, NATS, Qdrant, Weaviate, Prometheus, Grafana, Loki

### Audio
- `scripts/profiles/Audio_install.sh`
- installiert: Whisper, FFmpeg, librosa, pydub, Piper, Coqui_TTS

### Content_Automation
- `scripts/profiles/Content_Automation_install.sh`
- installiert: FFmpeg, Whisper, Playwright, n8n, Activepieces, Piper, Coqui_TTS, YT_DLP, Stable_Diffusion_WebUI, Trend_Monitor

### Research_Agent
- `scripts/profiles/Research_Agent_install.sh`
- installiert: Playwright, LangChain, LlamaIndex, ChromaDB, Qdrant, Weaviate, Trend_Monitor

### Security_Analyst
- `scripts/profiles/Security_Analyst_install.sh`
- installiert: Nmap, Nikto, Trivy, Fail2Ban

### Trading_AI
- `scripts/profiles/Trading_AI_install.sh`
- installiert: Zenbot_trader, Web3_APIs, Exchange_APIs

### Visual_Creator
- `scripts/profiles/Visual_Creator_install.sh`
- installiert: FFmpeg, Stable_Diffusion_WebUI, ComfyUI, RealESRGAN

## 7. Port-Check

Das vorhandene Skript deckt nur einen Teil ab:

```bash
scripts/port_check.sh
```

Zusätzlich manuell prüfen:

- `3000`
- `5678`
- `7860`
- `8000`
- `27017`

## 8. Dienste starten

Der aktuelle Repo-Stand provisioniert nicht alle Tools als dauerhafte Services.

Manuell relevant:

- OpenClaw: `cd /opt/openclaw && pnpm dev`
- Huginn: `RAILS_ENV=production bundle exec rails server -p 3000`
- Home Assistant: `sudo systemctl start homeassistant@homeassistant`
- Ruflo: `ruflo --help`

## 9. Externe Integrationen finalisieren

- Cloudflare Tunnel einrichten
- DNS bei Hurricane Electric oder Cloudflare prüfen
- Google Kalender OAuth korrekt registrieren
- Hugging Face Token, Kimi API-Key und weitere Zielsystem-Secrets hinterlegen

## 10. VPS/Kubernetes optional ergänzen

Für VPS-Deployments:

- `scripts/vps_standalone.sh` ausführen
- danach `scripts/k8s_deployments.yaml` prüfen und nur gezielt anwenden

Wichtiger Hinweis:
`scripts/k8s_deployments.yaml` enthält Beispiel-/Risikostellen und sollte vor produktiver Nutzung gehärtet werden.
