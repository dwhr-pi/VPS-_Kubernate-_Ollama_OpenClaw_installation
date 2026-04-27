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

## Profile im Überblick

### Programmierer
- Fokus: Entwicklungs- und Automatisierungs-Workflows
- Tatsächlicher Setup-Kern: Huginn, Clawhub CLI
- Hauptlücke: dokumentiertes Coding-Modell wie DeepSeek Coder wird nicht automatisch installiert

### Media_Musik
- Fokus: Medien- und Musik-Workflows
- Tatsächlicher Setup-Kern: Clawbake
- Hauptlücke: dokumentierte Audio-/Video-Tooling-Breite ist script-seitig kaum umgesetzt

### KI_Forschung
- Fokus: RL, visuelle LLM-Workflows, Experimentieren
- Tatsächlicher Setup-Kern: OpenClaw RL, Flowise, LangFlow
- Hauptlücke: dokumentierte Forschungsmodelle wie `gemini-1.5-pro` werden nicht automatisch provisioniert

### Texter_Werbung_Marketing
- Fokus: Content- und Workflow-Automatisierung
- Tatsächlicher Setup-Kern: n8n, Activepieces
- Hauptlücke: keine dedizierten SEO-, Social- oder Text-Tools im Skript

### Rechtsberatung_Steuerrecht
- Fokus: Recherche, PDF-Analyse, OCR
- Tatsächlicher Setup-Kern: `pup`, `jq`, `wget`, `curl`, `poppler-utils`, `tesseract-ocr`
- Hauptlücke: Zotero wird nur manuell empfohlen, nicht installiert

## Profil-Differenzen

| Profil | Tatsächlich installierte Kern-Tools | Wichtige Abweichungen |
|---|---|---|
| Programmierer | Huginn, Clawhub CLI | Kein automatischer Ollama-Coder-Model-Pull |
| Media_Musik | Clawbake | Kein FFmpeg, keine Audio-AI, keine Video-Tools |
| KI_Forschung | OpenClaw RL, Flowise, LangFlow | Kein automatisches Forschungsmodell-Setup |
| Texter_Werbung_Marketing | n8n, Activepieces | Keine SEO-/Social-/Text-Spezialtools |
| Rechtsberatung_Steuerrecht | Web-Fetch, PDF/OCR | Zotero nur manuell, fehlendes Skill-Skript |

## Relevante globale Befunde

- `docs/Profile/` fehlte ursprünglich vollständig.
- Viele Tool-Skripte bauen Projekte, richten aber keinen dauerhaften Dienst ein.
- Mehrere Dienste konkurrieren standardmäßig um Port `3000`.
- OpenClaw-Konfiguration nutzt inkonsistent `OLLAMA_HOST` und `OLLAMA_BASE_URL`.
- Die Variable `PRIMÄRES_LLM_ANBIETER` ist dokumentiert, aber als Nicht-ASCII-Umgebungsvariable betrieblich fragil.
