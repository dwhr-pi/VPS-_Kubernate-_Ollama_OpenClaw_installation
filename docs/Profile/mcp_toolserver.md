# mcp_toolserver

## Zweck

Standardisiert MCP- und OpenAPI-fähige Toolserver für Agenten, UI und Automationsschichten.

## Use Cases

- lokale Toolserver über HTTP bereitstellen
- Open WebUI und OpenClaw an Tools anbinden
- mehrere MCP-Server zentral bündeln

## Enthaltene Tools

- `MCPO`
- `Browser_Tool`
- `File_System_Tool`
- `Firecrawl`

## Installation

```bash
scripts/tools/mcpo_install.sh
scripts/tools/browser_tool_install.sh
scripts/tools/file_system_tool_install.sh
scripts/tools/firecrawl_install.sh
```

## Ports

- `8000` typischer MCPO-Port

## Modelle

- modellunabhängig

## Abhängigkeiten

- Python
- Toolserver-Kommandos
- optional LiteLLM / Open WebUI

## Ressourcenverbrauch (CPU / RAM / Storage)

- CPU: niedrig
- RAM: ab 4-8 GB
- Storage: gering

## Sicherheitshinweise

- MCPO immer mit API-Key betreiben
- nur explizit freigegebene Toolserver veröffentlichen

## Start / Stop / Status Befehle

```bash
cd /opt/mcpo
./venv/bin/mcpo --help
ps aux | grep mcpo
```

## Test-Command

```bash
mcpo --help
```

## Deinstallation

```bash
scripts/tools/mcpo_uninstall.sh
```
