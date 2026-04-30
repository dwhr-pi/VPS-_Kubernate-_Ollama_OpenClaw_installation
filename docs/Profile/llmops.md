# llmops

## Zweck

Baut die zentrale LLMOps-Plattform aus Gateway, UI, Monitoring, Security und lokalen/Cloud-Modellen.

## Use Cases

- einheitliche Modell-API für Ollama und Cloud-Provider
- produktionsreife Agentenplattform
- Multi-Model-Routing mit Fallback

## Enthaltene Tools

- `LiteLLM`
- `Open_WebUI`
- `Langfuse`
- `OpenLIT`
- `OpenClaw`

## Installation

```bash
scripts/tools/litellm_install.sh
scripts/tools/open_webui_install.sh
scripts/tools/langfuse_install.sh
scripts/tools/openlit_install.sh
```

## Ports

- `4000` LiteLLM
- `3000` Open WebUI
- `3003` Langfuse

## Modelle

- `llama3.2:3b`
- `qwen2.5:7b`
- `mistral:7b`

## Abhängigkeiten

- Docker
- Ollama
- API-Keys für Fallbacks

## Ressourcenverbrauch (CPU / RAM / Storage)

- CPU: mittel
- RAM: ab 16-32 GB sinnvoll
- Storage: ab 25 GB plus Modelle

## Sicherheitshinweise

- `LiteLLM` nur mit Master-Key betreiben
- `Open WebUI` nicht ungeschützt öffentlich freigeben
- Cloud-Keys nur im Benutzer-Workspace pflegen

## Start / Stop / Status Befehle

```bash
docker compose -f /opt/litellm/docker-compose.yml up -d
docker compose -f /opt/litellm/docker-compose.yml down
docker ps
```

## Test-Command

```bash
curl http://localhost:4000/health/readiness
```

## Deinstallation

```bash
scripts/tools/litellm_uninstall.sh
scripts/tools/open_webui_uninstall.sh
scripts/tools/langfuse_uninstall.sh
scripts/tools/openlit_uninstall.sh
```
