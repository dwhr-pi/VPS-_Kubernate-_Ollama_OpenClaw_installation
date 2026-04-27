# Profil-Index

Dieses Verzeichnis bündelt den aktuell aus dem Repository rekonstruierten Profil-Stand.

Wichtiger Hinweis:
Im aktuellen Repository existierten vor dieser Zusammenführung keine dedizierten Profil-Dateien unter `docs/Profile/`.
Die Inhalte in diesem Verzeichnis wurden daher aus folgenden Quellen zusammengeführt:

- `readme.md`
- `docs/setup_guide.md`
- `docs/API_KEY_GUIDE.md`
- `scripts/profiles/*.sh`
- `scripts/tools/*.sh`
- `scripts/base_install.sh`
- `scripts/hybrid_setup.sh`
- `scripts/install_local_only.sh`
- `scripts/vps_standalone.sh`
- `docs/Profil/*.doc.md`

## Profilquellen und abgeleitete Dateien

Die fachlichen Quelldateien unter [docs/Profil](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profil:1) sind lokal vorhanden und in die abgeleiteten Profilseiten übernommen:

| Quelle in `docs/Profil` | Abgeleitete Datei in `docs/Profile` |
|---|---|
| `Programmierer.doc.md` | `Programmierer.md` |
| `Media_Musik.doc.md` | `Media_Musik.md` |
| `KI_Forschung.doc.md` | `KI_Forschung.md` |
| `Texter_Werbung_Marketing.doc.md` | `Texter_Werbung_Marketing.md` |
| `Rechtsberatung_Steuerrecht.doc.md` | `Rechtsberatung_Steuerrecht.md` |
| `Agent_Orchestrator.doc.md` | `Agent_Orchestrator.md` |
| `Audio.doc.md` | `Audio.md` |
| `Content_Automation.doc.md` | `Content_Automation.md` |
| `Research_Agent.doc.md` | `Research_Agent.md` |
| `Security_Analyst.doc.md` | `Security_Analyst.md` |
| `Trading_AI.doc.md` | `Trading_AI.md` |
| `Visual_Creator.doc.md` | `Visual_Creator.md` |

## Profile im Überblick

### Programmierer
- Fokus: Entwicklungs- und Automatisierungs-Workflows
- Tatsächlicher Setup-Kern: Huginn, Clawhub CLI, LangGraph, CrewAI, AutoGen, Playwright, ChromaDB
- Hauptlücke: dokumentiertes Coding-Modell wie DeepSeek Coder wird nicht automatisch installiert

### Media_Musik
- Fokus: Medien- und Musik-Workflows
- Tatsächlicher Setup-Kern: Clawbake, FFmpeg, librosa, pydub, Demucs, Whisper
- Hauptlücke: dokumentierte Audio-AI- und Video-Tooling-Breite ist weiterhin nur teilweise umgesetzt

### KI_Forschung
- Fokus: RL, visuelle LLM-Workflows, Experimentieren
- Tatsächlicher Setup-Kern: OpenClaw RL, Flowise, LangFlow, LangChain, LlamaIndex, MLflow, Whisper
- Hauptlücke: dokumentierte Forschungsmodelle wie `gemini-1.5-pro` werden nicht automatisch provisioniert

### Texter_Werbung_Marketing
- Fokus: Content- und Workflow-Automatisierung
- Tatsächlicher Setup-Kern: n8n, Activepieces, LangChain, ChromaDB, Playwright
- Hauptlücke: keine dedizierten SEO-, Social- oder Text-Tools im Skript

### Rechtsberatung_Steuerrecht
- Fokus: Recherche, PDF-Analyse, OCR
- Tatsächlicher Setup-Kern: `pup`, `jq`, `wget`, `curl`, `poppler-utils`, `tesseract-ocr`, Zotero, LangChain, LlamaIndex, ChromaDB
- Hauptlücke: die angekündigte OpenClaw-Skill-Integration für Rechtsquellen fehlt weiterhin

### Agent_Orchestrator
- Fokus: Aufgabenzerlegung, Routing, Mehragenten-Koordination
- Tatsächlicher Setup-Kern: LangGraph, CrewAI, AutoGen, ChromaDB, Redis, NATS, Qdrant, Weaviate, Prometheus, Grafana, Loki
- Hauptlücke: kein dediziertes Laufzeitmodul für Policies, Retry-Logik und Konfliktauflösung

### Audio
- Fokus: Speech-to-Text, Text-to-Speech, Audio-Cleanup
- Tatsächlicher Setup-Kern: Whisper, FFmpeg, librosa, pydub, Piper, Coqui_TTS
- Hauptlücke: kein vollständiger Voice-Assistant-Laufzeitstack

### Content_Automation
- Fokus: Skript, Voiceover, Videoschnitt und Workflow-Automation
- Tatsächlicher Setup-Kern: FFmpeg, Whisper, Playwright, n8n, Activepieces, Piper, Coqui_TTS, YT_DLP, Stable_Diffusion_WebUI, Trend_Monitor
- Hauptlücke: keine vollständig vorkonfigurierte End-to-End-Laufzeitpipeline

### Research_Agent
- Fokus: Repository-Analyse, Dokumentationsverständnis, Setup-Verbesserung
- Tatsächlicher Setup-Kern: Playwright, LangChain, LlamaIndex, ChromaDB, Qdrant, Weaviate, Trend_Monitor
- Hauptlücke: keine vollständig vorkonfigurierte Repo-Vergleichs- und Monitoring-Pipeline

### Security_Analyst
- Fokus: Exposure, Logs, Schwachstellenprüfung, Hardening
- Tatsächlicher Setup-Kern: Port-Check, Nmap, Nikto, Trivy, Fail2Ban
- Hauptlücke: keine vollwertige Pentest- oder Compliance-Workflow-Kette

### Trading_AI
- Fokus: Marktanalyse, Strategietests, Bot-Integration
- Tatsächlicher Setup-Kern: Zenbot_trader, Web3_APIs, Exchange_APIs
- Hauptlücke: kein dediziertes Backtest- oder Risikomodul

### Visual_Creator
- Fokus: Bild-, Video- und Asset-Pipelines
- Tatsächlicher Setup-Kern: FFmpeg, Stable_Diffusion_WebUI, ComfyUI, RealESRGAN
- Hauptlücke: keine vollständig vorkonfigurierte lokale Bild-/Video-Laufzeitpipeline

## Profil-Differenzen

| Profil | Tatsächlich installierte Kern-Tools | Wichtige Abweichungen |
|---|---|---|
| Programmierer | Huginn, Clawhub CLI, LangGraph, CrewAI, AutoGen, Playwright, ChromaDB | Kein automatischer Ollama-Coder-Model-Pull, kein Observability-/Queue-Stack |
| Media_Musik | Clawbake, FFmpeg, librosa, pydub, Demucs, Whisper | Keine MusicGen-/Riffusion-/Video-Tools |
| KI_Forschung | OpenClaw RL, Flowise, LangFlow, LangChain, LlamaIndex, MLflow, Whisper | Kein automatisches Forschungsmodell-Setup, kein Ray/vLLM |
| Texter_Werbung_Marketing | n8n, Activepieces, LangChain, ChromaDB, Playwright | Keine SEO-/Social-/CRM-/Ads-Spezialtools |
| Rechtsberatung_Steuerrecht | Web-Fetch, PDF/OCR, Zotero, LangChain, LlamaIndex, ChromaDB | Fehlendes Skill-Skript, keine Legal-KG-/Risk-Tools |
| Agent_Orchestrator | LangGraph, CrewAI, AutoGen, ChromaDB, Redis, NATS, Qdrant, Weaviate, Prometheus, Grafana, Loki | Keine fertige Policy-/Retry-/Konfliktlogik |
| Audio | Whisper, FFmpeg, librosa, pydub, Piper, Coqui_TTS | Kein kompletter Voice-Assistant-Stack |
| Content_Automation | FFmpeg, Whisper, Playwright, n8n, Activepieces, Piper, Coqui_TTS, YT_DLP, Stable_Diffusion_WebUI, Trend_Monitor | Keine vorkonfigurierte End-to-End-Laufzeitpipeline |
| Research_Agent | Playwright, LangChain, LlamaIndex, ChromaDB, Qdrant, Weaviate, Trend_Monitor | Keine fertige Repo-Vergleichs- und Monitoring-Pipeline |
| Security_Analyst | Port-Check, Nmap, Nikto, Trivy, Fail2Ban | Kein vollwertiger Pentest-/Compliance-Workflow |
| Trading_AI | Zenbot_trader, Web3_APIs, Exchange_APIs | Kein dediziertes Backtest-/Risikomodul |
| Visual_Creator | FFmpeg, Stable_Diffusion_WebUI, ComfyUI, RealESRGAN | Keine vorkonfigurierte lokale Bild-/Video-Laufzeitpipeline |

## Relevante globale Befunde

- `docs/Profile/` fehlte ursprünglich vollständig.
- Viele Tool-Skripte bauen Projekte, richten aber keinen dauerhaften Dienst ein.
- Mehrere Dienste konkurrieren standardmäßig um Port `3000`.
- OpenClaw-Konfiguration nutzt inkonsistent `OLLAMA_HOST` und `OLLAMA_BASE_URL`.
- Die Variable `PRIMÄRES_LLM_ANBIETER` ist dokumentiert, aber als Nicht-ASCII-Umgebungsvariable betrieblich fragil.
