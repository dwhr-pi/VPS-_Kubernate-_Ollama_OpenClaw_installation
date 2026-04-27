# Inkonsistenzbericht

## Profil-Dokumentation

- `docs/Profile/` fehlte im ursprünglichen Repository vollständig.
- Die Profilwahrheit lag verteilt in `readme.md`, `docs/setup_guide.md` und `scripts/profiles/*.sh`.

## Dokumentiert, aber nicht sauber im Setup umgesetzt

### Programmierer
- DeepSeek-Coder oder ein anderes Coding-Modell für Ollama wird erwähnt, aber nicht automatisch installiert.
- Git-Integration wird dokumentiert, aber nicht als eigenständiges Profil-Setup umgesetzt.
- Observability-, Secrets- und Queue-Bausteine wie Prometheus, Grafana, Loki, OpenTelemetry, Vault, Redis, RabbitMQ oder NATS sind in `docs/Profil/Programmierer.doc.md` beschrieben, aber noch nicht als eigene Tools im Setup vorhanden.

### Media_Musik
- Audio-Verarbeitung, Video-Generierung und Alexa-Bezug werden dokumentiert.
- Das Profilskript installiert jetzt `Clawbake`, `FFmpeg`, `librosa`, `pydub`, `Demucs` und `Whisper`.
- MusicGen, Riffusion, Stable Diffusion, ControlNet und echte Video-Generatoren fehlen weiterhin.

### KI_Forschung
- Erweiterte LLM-Modelle wie `gemini-1.5-pro` werden dokumentiert.
- Das Profilskript installiert jetzt `OpenClaw RL`, `Flowise`, `LangFlow`, `LangChain`, `LlamaIndex`, `MLflow` und `Whisper`.
- Ray, vLLM, Stable Diffusion und EnviroLLM fehlen weiterhin.

### Texter_Werbung_Marketing
- SEO, Social Media und spezialisierte Textproduktion werden dokumentiert.
- Das Profilskript installiert jetzt `n8n`, `Activepieces`, `LangChain`, `ChromaDB` und `Playwright`.
- API-Integrationen wie Google Analytics, Meta Ads, TikTok Ads, HubSpot, Notion, Airtable, Buffer, Zapier, Make, Ahrefs, SEMrush und ElevenLabs fehlen weiterhin.

### Rechtsberatung_Steuerrecht
- Zotero ist dokumentiert.
- Das Profilskript installiert jetzt Zotero, `LangChain`, `LlamaIndex` und `ChromaDB`, referenziert aber weiterhin ein fehlendes Skill-Skript.
- Neo4j, EULLM, ALIENTELLIGENCE, Fristen-Checker und Risiko-Scoring sind dokumentiert, aber noch nicht als Tools umgesetzt.

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
- `scripts/openclaw_skill_config.sh` wird im Profil `Rechtsberatung_Steuerrecht` referenziert, existiert aber nicht.

## Sicherheitsrelevante Abweichungen

- OpenClaw ist in der Vorlage mit `HOST=0.0.0.0` konfiguriert.
- `scripts/k8s_deployments.yaml` enthält einen `LoadBalancer` für den `gemini-ollama-proxy`.
- Secrets sind als Klartext-Platzhalter in `.env.template` und `config.json.template` vorgesehen.
