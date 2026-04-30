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

### LLM_Builder
- `scripts/profiles/LLM_Builder_install.sh`
- installiert: Ollama, Data_Juicer, Unsloth, LLaMA_Factory, Llama_CPP_Toolchain, Axolotl sowie ergänzende Evaluations- und Orchestrierungsbausteine

## 7. Plattform-Stack erweitern

Fuer den produktionsnaeheren Ausbau stehen jetzt zusaetzliche Plattformprofile und Einzeltools bereit:

### LLMOps
- `scripts/tools/litellm_install.sh`
- `scripts/tools/open_webui_install.sh`
- `scripts/tools/langfuse_install.sh`
- `scripts/tools/openlit_install.sh`

### RAG / Knowledge Base
- `scripts/tools/qdrant_install.sh`
- `scripts/tools/chromadb_install.sh`
- `scripts/tools/llamaindex_install.sh`
- `scripts/tools/langchain_install.sh`
- `scripts/tools/data_juicer_install.sh`

### MCP / Toolserver
- `scripts/tools/mcpo_install.sh`

### Security / Guardrails
- `scripts/tools/guardrails_ai_install.sh`
- `scripts/tools/promptfoo_install.sh`
- `scripts/tools/trivy_install.sh`
- `scripts/tools/gitleaks_install.sh`

### Monitoring / Observability
- `scripts/tools/grafana_install.sh`
- `scripts/tools/prometheus_install.sh`
- `scripts/tools/loki_install.sh`
- `scripts/tools/uptime_kuma_install.sh`
- `scripts/tools/netdata_install.sh`

### Daten und Storage
- `scripts/tools/postgres_install.sh`
- `scripts/tools/redis_install.sh`
- `scripts/tools/minio_install.sh`
- `scripts/tools/supabase_install.sh`

## 8. Vorkonfigurierten Plattform-Stack starten

Alternativ oder zusaetzlich kannst du den vorkonfigurierten Plattform-Stack unter `stacks/llmops-platform` nutzen:

```bash
cd stacks/llmops-platform
cp .env.example .env
docker compose up -d
```

Danach pruefen:

- `LiteLLM`: `http://localhost:4000`
- `Open WebUI`: `http://localhost:3000`
- `Qdrant`: `http://localhost:6333`
- `Langfuse`: `http://localhost:3003`
- `Grafana`: `http://localhost:3001`
- `Prometheus`: `http://localhost:9090`

## 9. Ollama-Modelle und Modelfiles verwalten

- ueber `⚙ Optionen -> Ollama Modellkatalog`
- ueber `⚙ Optionen -> Ollama Modelfile-Assistent`
- fuer eigene Fine-Tuning-Projekte ueber `⚙ Optionen -> LLM-Builder Projektstruktur-Assistent`

## 10. Port-Check

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

## 11. Dienste starten

Der aktuelle Repo-Stand provisioniert nicht alle Tools als dauerhafte Services.

Manuell relevant:

- OpenClaw: `cd /opt/openclaw && pnpm dev`
- Huginn: `RAILS_ENV=production bundle exec rails server -p 3000`
- Home Assistant: `sudo systemctl start homeassistant@homeassistant`
- Ruflo: `ruflo --help`

## 12. Externe Integrationen finalisieren

- Cloudflare Tunnel einrichten
- DNS bei Hurricane Electric oder Cloudflare prüfen
- Google Kalender OAuth korrekt registrieren
- Hugging Face Token, Kimi API-Key und weitere Zielsystem-Secrets hinterlegen

## 13. VPS/Kubernetes optional ergänzen

Für VPS-Deployments:

- `scripts/vps_standalone.sh` ausführen
- danach `scripts/k8s_deployments.yaml` prüfen und nur gezielt anwenden

Wichtiger Hinweis:
`scripts/k8s_deployments.yaml` enthält Beispiel-/Risikostellen und sollte vor produktiver Nutzung gehärtet werden.
