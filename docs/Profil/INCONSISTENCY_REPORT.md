# Inkonsistenzbericht

## Profil-Dokumentation

- `docs/Profile/` fehlte im ursprünglichen Repository vollständig.
- Die Profilwahrheit lag verteilt in `readme.md`, `docs/setup_guide.md` und `scripts/profiles/*.sh`.

## Dokumentiert, aber nicht sauber im Setup umgesetzt

### Programmierer
- DeepSeek-Coder oder ein anderes Coding-Modell für Ollama wird erwähnt, aber nicht automatisch installiert.
- Git-Integration wird dokumentiert, aber nicht als eigenständiges Profil-Setup umgesetzt.

### Media_Musik
- Audio-Verarbeitung, Video-Generierung und Alexa-Bezug werden dokumentiert.
- Das Profilskript installiert faktisch nur `Clawbake`.

### KI_Forschung
- Erweiterte LLM-Modelle wie `gemini-1.5-pro` werden dokumentiert.
- Das Profilskript installiert nur `OpenClaw RL`, `Flowise` und `LangFlow`.

### Texter_Werbung_Marketing
- SEO, Social Media und spezialisierte Textproduktion werden dokumentiert.
- Das Profilskript installiert nur `n8n` und `Activepieces`.

### Rechtsberatung_Steuerrecht
- Zotero ist dokumentiert.
- Das Profilskript empfiehlt nur eine manuelle Installation.

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
- `scripts/tools/ffmpeg_install.sh` existiert nicht, obwohl Medien-Tooling in der Dokumentation impliziert wird.

## Sicherheitsrelevante Abweichungen

- OpenClaw ist in der Vorlage mit `HOST=0.0.0.0` konfiguriert.
- `scripts/k8s_deployments.yaml` enthält einen `LoadBalancer` für den `gemini-ollama-proxy`.
- Secrets sind als Klartext-Platzhalter in `.env.template` und `config.json.template` vorgesehen.
