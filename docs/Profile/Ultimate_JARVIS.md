# Ultimate JARVIS

Status: `planned` / `documentation-first`

## Zweck

Ultimate JARVIS beschreibt ein lokales KI-Betriebsprofil fuer einen dauerhaften Assistenten mit Voice, Memory, Agenten-Orchestrierung, RAG, Smart Home und Infrastrukturhilfe.

## Zielgruppe

- Homelab- und MiniPC-Nutzer
- Entwickler mit lokalem Ollama/OpenClaw-Setup
- VPS-/K3s-Betreiber
- Nutzer, die einen lokalen Assistenten mit klaren Sicherheitsgrenzen aufbauen wollen

## Ressourcenbedarf

| Modus | CPU | RAM | Speicher | GPU |
| --- | --- | --- | --- | --- |
| Minimal | 4 Kerne | 8 GB | 30 GB | nein |
| Empfohlen | 8 Kerne | 16-32 GB | 100 GB | optional |
| High-End | 12+ Kerne | 64 GB | 500 GB+ | ja |

## Empfohlene Tools

- Ollama
- OpenClaw
- Qdrant
- PostgreSQL
- Whisper / faster-whisper
- Piper
- Playwright
- Prometheus
- Grafana

## Optionale Tools

- Open WebUI
- Langfuse
- Home Assistant
- Kubernetes/K3s
- Loki
- Uptime Kuma

## Ports

Keine Ports automatisch oeffnen. Typische interne Ports muessen lokal oder per VPN geschuetzt bleiben:

- Ollama: `127.0.0.1:11434`
- OpenClaw Gateway: lokal/VPN
- Qdrant: lokal/VPN
- PostgreSQL: lokal/VPN
- Grafana: lokal/VPN oder Reverse Proxy mit Auth

## Sicherheitsnotizen

- Read-only-first.
- Dry-run-first.
- Keine autonomen Shell-, Docker-, Kubernetes- oder Smart-Home-Aktionen.
- Keine Secrets im Repo.
- Externe APIs nur mit Kostenwarnung.
- Smart-Home- und Infrastrukturaktionen nur mit Bestaetigung.

## Installationsbefehl

Dieses Profil ist aktuell dokumentationsbasiert:

```bash
bash setup_ultimate.sh
```

Danach einzeln die benoetigten Tools installieren. Keine Komplettinstallation aus diesem Profil starten.

## Testbefehl

```bash
bash scripts/check_tools.sh
bash scripts/check_profiles.sh
bash scripts/doctor.sh
```

## Deinstallationshinweis

Da dieses Profil nichts automatisch installiert, gibt es keine zentrale Deinstallation. Entferne einzelne Tools ueber das Tool-Menue.

## Bekannte Fehler

- Zu wenig Windows-C:-Speicher unter WSL kann Docker-/Model-Downloads abbrechen.
- Docker-Socket-Rechte koennen `sudo docker compose` oder neue WSL-Sitzung erfordern.
- Voice- und GPU-Funktionen sind stark hardwareabhaengig.

## Reparaturhinweise

- Erst Basisdienste pruefen: Ollama, OpenClaw, Qdrant.
- Dann Voice-Pipeline getrennt testen.
- Memory nur mit Testdaten befuellen.
- Docker/K3s erst nach Sicherheitscheck aktivieren.

## Struktur

Siehe auch:

- `profiles/ultimate-jarvis/`
- `docs/agents/ultimate-jarvis.md`
- `docs/memory/ultimate-jarvis-memory.md`
- `docs/voice_studio/ultimate-jarvis-voice.md`
- `docs/rag/ultimate-jarvis-rag.md`
- `docs/monitoring/ultimate-jarvis-monitoring.md`
- `docs/home_assistant/ultimate-jarvis-home-assistant.md`
