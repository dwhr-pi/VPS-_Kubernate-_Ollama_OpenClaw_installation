# Inkonsistenzbericht

## Profil-Dokumentation

- `docs/Profile/` fehlte im ursprünglichen Repository vollständig.
- Die Profilwahrheit lag verteilt in `readme.md`, `docs/setup_guide.md` und `scripts/profiles/*.sh`.

## Dokumentiert, aber nicht sauber im Setup umgesetzt

### Programmierer
- DeepSeek-Coder oder ein anderes Coding-Modell für Ollama wird erwähnt, aber nicht automatisch installiert.
- Git-Integration wird dokumentiert, aber nicht als eigenständiges Profil-Setup umgesetzt.
- Observability-, Secrets- und Queue-Bausteine wie Prometheus, Grafana, Loki, OpenTelemetry, Vault, Redis, RabbitMQ oder NATS sind jetzt als eigene Tools im Setup vorhanden.

### Media_Musik
- Audio-Verarbeitung, Video-Generierung und Alexa-Bezug werden dokumentiert.
- Das Profilskript installiert jetzt `Clawbake`, `FFmpeg`, `librosa`, `pydub`, `Demucs` und `Whisper`.
- MusicGen, Riffusion, Stable Diffusion und ControlNet sind jetzt als Setup-Module vorhanden; echte externe Video-Generatoren bleiben weiterhin credential- und dienstabhängig.

### Audio
- Die dokumentierten Kernwerkzeuge `Whisper`, `ffmpeg`, `Piper` und `Coqui TTS` sind jetzt als installierbare Bausteine vorhanden.
- Das zusätzliche Laufzeitmodul `Voice_Assistant_Runtime` ist jetzt vorhanden; offen bleibt nur Feintuning für ein produktives End-to-End-Voice-Setup.

### KI_Forschung
- Erweiterte LLM-Modelle wie `gemini-1.5-pro` werden dokumentiert.
- Das Profilskript installiert jetzt `OpenClaw RL`, `Flowise`, `LangFlow`, `LangChain`, `LlamaIndex`, `MLflow` und `Whisper`.
- Ray, vLLM, Stable Diffusion und EnviroLLM sind jetzt als Setup-Module oder Tool-Äquivalente vorhanden.

### Agent_Orchestrator
- Queue-/Event-Bus-, Memory- und Observability-Bausteine sind jetzt als installierbare Module vorhanden: `Redis`, `NATS`, `Qdrant`, `Weaviate`, `Prometheus`, `Grafana`, `Loki`.
- Dedizierte Laufzeitmodule für Routing und Memory-Policies sind jetzt vorhanden; offen bleibt produktives Policy-Feintuning.

### Research_Agent
- Trend-Monitoring ist jetzt als installierbares Modul vorhanden.
- Eigene Module für GitHub-Research und Repo-Vergleich sind jetzt vorhanden; offen bleibt ein stärker vorkonfigurierter Monitoring-Standard.

### Texter_Werbung_Marketing
- SEO, Social Media und spezialisierte Textproduktion werden dokumentiert.
- Das Profilskript installiert jetzt `n8n`, `Activepieces`, `LangChain`, `ChromaDB` und `Playwright`.
- API-Integrationen wie Google Analytics, Meta Ads, TikTok Ads, HubSpot, Notion, Airtable, Buffer, Zapier, Make, Ahrefs, SEMrush und ElevenLabs sind jetzt als Connector-Module im Setup vorhanden.

### Content_Automation
- `Piper`, `Coqui_TTS`, `YT_DLP`, `Stable_Diffusion_WebUI` und `Trend_Monitor` sind jetzt als installierbare Module vorhanden.
- Thumbnail- und Upload-Module sind jetzt vorhanden; offen bleibt nur eine vollständig produktionsfertige End-to-End-Verdrahtung mit echten Zielplattform-Credentials.

### Rechtsberatung_Steuerrecht
- Zotero ist dokumentiert.
- Das Profilskript referenziert jetzt ein vorhandenes Skill-Skript.
- Neo4j, EULLM, AI Powered Law Firms, Fristen-Checker und Risiko-Scoring sind jetzt als Tools oder Module umgesetzt.

### Security_Analyst
- `nmap`, `nikto`, `trivy` und `Fail2Ban` sind jetzt als installierbare Module vorhanden.
- Zusätzliche Workflow-Module für Fail2Ban-Analyse und Security-Workflows sind jetzt vorhanden; offen bleibt nur tieferes Compliance-Feintuning.

### Trading_AI
- `Web3_APIs` und `Exchange_APIs` sind jetzt als installierbare Module vorhanden.
- Dedizierte Module für Zenbot-Integration, Risiko-/Strategieanalyse und Backtests sind jetzt vorhanden.

### Visual_Creator
- `stable-diffusion-webui`, `comfyui` und `RealESRGAN` sind jetzt als installierbare Module vorhanden.
- Zusätzliche Module für AnimateDiff, SVD, Runway-Connector und Upscaler-Pipeline sind jetzt vorhanden; offen bleibt nur produktives Pipeline-Feintuning.

### LLM_Builder
- Die GitHub-basierten Kernbausteine `Data_Juicer`, `Unsloth`, `LLaMA_Factory`, `Axolotl` und `Llama_CPP_Toolchain` sind jetzt als installierbare Module vorhanden.
- Offen bleibt bewusst ein fixer Ein-Klick-Trainingslauf, weil Basismodelle, Datensätze, Hyperparameter und Hardware zwischen Projekten stark variieren.

## Im Setup vorhanden, aber schwach oder gar nicht dokumentiert

- `Ruflo` wird mittlerweile script-seitig mit Node.js-22-Absicherung und CLI-Verlinkung installiert.
- `AutoGPT` wird per Docker Compose provisioniert.
- `vps_standalone.sh` ist jetzt ein ehrliches K3s-Foundation-Setup statt ein halbfertiger Platzhalter.

## Konfigurations-Inkonsistenzen

- `scripts/config_templates/openclaw/.env.template` nutzt `OLLAMA_HOST`.
- `scripts/hybrid_setup.sh` schreibt `OLLAMA_BASE_URL`.
- `scripts/config_templates/openclaw/.env.template` und `config.json.template` dokumentieren `PRIMÄRES_LLM_ANBIETER`, was als Umgebungsvariable unnötig fragil ist.

## Port- und Dienst-Inkonsistenzen

- `docs/API_KEY_GUIDE.md` listet kritische Ports `3000`, `5678`, `7860`, `8123`, `11434`, `27017`.
- `scripts/port_check.sh` prüft aktuell nur `11434`, `18789`, `8123`, `8080`.
- `3000` als Kollisionsport für OpenClaw, Flowise, Activepieces, Huginn und Zenbot wird nicht script-seitig geprüft.

## Fehlende Dateien oder Referenzen

- `docs/Profile/` fehlte ursprünglich.
- `scripts/openclaw_skill_config.sh` ist jetzt vorhanden und wird im Rechtsprofil direkt verwendet.

## Sicherheitsrelevante Abweichungen

- OpenClaw ist in der Vorlage mit `HOST=0.0.0.0` konfiguriert.
- `scripts/k8s_deployments.yaml` enthält einen `LoadBalancer` für den `gemini-ollama-proxy`.
- Secrets sind als Klartext-Platzhalter in `.env.template` und `config.json.template` vorgesehen.
