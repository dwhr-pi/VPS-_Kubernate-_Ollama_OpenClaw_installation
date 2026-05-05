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
- installiert: Huginn, Clawhub CLI

### Media_Musik
- `scripts/profiles/Media_Musik_install.sh`
- installiert: Clawbake

### KI_Forschung
- `scripts/profiles/KI_Forschung_install.sh`
- installiert: OpenClaw RL, Flowise, LangFlow

### Texter_Werbung_Marketing
- `scripts/profiles/Texter_Werbung_Marketing_install.sh`
- installiert: n8n, Activepieces

### Rechtsberatung_Steuerrecht
- `scripts/profiles/Rechtsberatung_Steuerrecht_install.sh`
- installiert: Web-Fetch- und PDF/OCR-Werkzeuge

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

## 11. Profilhinweis: Influencer_LiveCam_Streaming_AI

Fuer das Profil `Influencer_LiveCam_Streaming_AI` zusaetzlich einplanen:

- `OBS Studio` lokal oder auf dem Creator-Host
- `ffmpeg` fuer Clip- und Re-Encode-Workflows
- `Ollama` mit kleinem bis mittlerem lokalen Modell
- `faster-whisper` fuer Transkription
- `Piper` optional fuer lokale TTS
- `ComfyUI` oder `Fooocus` optional fuer Thumbnail- und Branding-Ideen
- Speicherplatz fuer Aufnahmen, Transkripte, Clips und Assets
- Datenschutzpruefung fuer Chat-Logs, Fan-Kommunikation und Moderationsspeicher
- keine oeffentliche Freigabe sensibler Creator- oder Admin-Panels ohne Tunnel, Reverse Proxy oder privates Overlay

## 12. Profilhinweis: Ethical_HackerGPT

Fuer das Profil `Ethical_HackerGPT` zusaetzlich einplanen:

- Default immer `audit` und `read-only` denken
- Allowlist nur mit eigenen oder lokal isolierten Zielen befuellen
- bei leerer Allowlist nur `127.0.0.1` und `localhost` verwenden
- Output-Verzeichnis `./reports/security` pruefen
- Basistools wie `nmap`, `gitleaks`, `semgrep`, `trivy`, `syft`, `grype`, `ufw`, `fail2ban` und `lynis` defensiv nutzen
- optionale Tools und Labs nur bewusst aktivieren
- keine oeffentlichen IP-Ranges oder fremden Domains pruefen

## 13. Profilhinweis: Living_Persona_System

Fuer das Profil `Living_Persona_System` zusaetzlich einplanen:

- Persona-Dateien sauber trennen in `personas/`, `memory/` und `prompts/`
- Persona-Memory datensparsam und nachvollziehbar halten
- keine versteckte Menschenausgabe oder Identitaetsvortaeuschung bauen
- `Ollama` und `OpenClaw` fuer Routing und Prompt-Aufbau vorbereiten
- optional `Qdrant` oder `ChromaDB` nur dann nutzen, wenn Memory wirklich ueber Einzelfiles hinausgehen soll
- Testfaelle fuer Rollenwechsel, Memory-Recall und Kontextmodi anlegen

## 14. Profilhinweis: Next_Level_Persona_System

Fuer das Profil `Next_Level_Persona_System` zusaetzlich einplanen:

- Persona-Templates unter `personas/` und Prompt-Bausteine unter `prompts/persona/` pruefen
- Memory-Struktur unter `memory/personas/<persona_id>/` sauber halten
- oeffentliche Nutzung nur mit Disclosure-Regeln
- `scripts/persona/install_persona_system.sh` fuer den Workspace-Aufbau nutzen
- `scripts/persona/validate_personas.sh` vor produktiver Verwendung ausfuehren
- Voice-, STT-, Bild-/Video- und Telefon-Hooks nur bewusst aktivieren
