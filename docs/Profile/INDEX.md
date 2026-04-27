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

Die fünf fachlichen Quelldateien unter [docs/Profil](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profil:1) sind lokal vorhanden und in die abgeleiteten Profilseiten übernommen:

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

## Profil-Differenzen

| Profil | Tatsächlich installierte Kern-Tools | Wichtige Abweichungen |
|---|---|---|
| Programmierer | Huginn, Clawhub CLI, LangGraph, CrewAI, AutoGen, Playwright, ChromaDB | Kein automatischer Ollama-Coder-Model-Pull, kein Observability-/Queue-Stack |
| Media_Musik | Clawbake, FFmpeg, librosa, pydub, Demucs, Whisper | Keine MusicGen-/Riffusion-/Video-Tools |
| KI_Forschung | OpenClaw RL, Flowise, LangFlow, LangChain, LlamaIndex, MLflow, Whisper | Kein automatisches Forschungsmodell-Setup, kein Ray/vLLM |
| Texter_Werbung_Marketing | n8n, Activepieces, LangChain, ChromaDB, Playwright | Keine SEO-/Social-/CRM-/Ads-Spezialtools |
| Rechtsberatung_Steuerrecht | Web-Fetch, PDF/OCR, Zotero, LangChain, LlamaIndex, ChromaDB | Fehlendes Skill-Skript, keine Legal-KG-/Risk-Tools |

## Relevante globale Befunde

- `docs/Profile/` fehlte ursprünglich vollständig.
- Viele Tool-Skripte bauen Projekte, richten aber keinen dauerhaften Dienst ein.
- Mehrere Dienste konkurrieren standardmäßig um Port `3000`.
- OpenClaw-Konfiguration nutzt inkonsistent `OLLAMA_HOST` und `OLLAMA_BASE_URL`.
- Die Variable `PRIMÄRES_LLM_ANBIETER` ist dokumentiert, aber als Nicht-ASCII-Umgebungsvariable betrieblich fragil.
