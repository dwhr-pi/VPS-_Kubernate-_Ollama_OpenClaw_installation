# openwebui_frontend

## Zweck

Setzt Open WebUI als Standard-Frontend für Chats, Agenten und Multi-Model-Zugriff.

## Use Cases

- Chat-UI für lokale Modelle
- LiteLLM-gestützter Multi-Model-Zugriff
- OpenClaw-nahe Frontend-Arbeit

## Enthaltene Tools

- `Open_WebUI`
- `LiteLLM`
- optional `MCPO`

## Installation

```bash
scripts/tools/open_webui_install.sh
scripts/tools/litellm_install.sh
scripts/tools/mcpo_install.sh
```

## Ports

- `3000` Open WebUI
- `4000` LiteLLM
- `8000` MCPO typischer Proxy-Port

## Modelle

- `llama3.2:3b`
- `qwen2.5:7b`
- `mistral:7b`

## Abhängigkeiten

- Ollama
- LiteLLM
- API-Keys für Cloud-Fallbacks

## Ressourcenverbrauch (CPU / RAM / Storage)

- CPU: niedrig bis mittel
- RAM: ab 8-16 GB plus Modell
- Storage: moderat

## Sicherheitshinweise

- Registrierung in Open WebUI möglichst deaktivieren
- Admin-Zugänge nicht offen ins Netz stellen

## Start / Stop / Status Befehle

```bash
docker compose -f /opt/open_webui/docker-compose.yml up -d
docker compose -f /opt/open_webui/docker-compose.yml down
docker ps
```

## Test-Command

```bash
curl http://localhost:3000
```

## Deinstallation

```bash
scripts/tools/open_webui_uninstall.sh
scripts/tools/litellm_uninstall.sh
scripts/tools/mcpo_uninstall.sh
```
