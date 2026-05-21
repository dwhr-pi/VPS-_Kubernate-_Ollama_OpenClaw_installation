# Profil: MCP_Agent_Tools

## Zweck
Toolserver- und MCP-Schicht für Agenten, UI und sichere Integrationen.

## Use Cases
- GitHub MCP
- Filesystem MCP
- Browser-/Fetch-MCP
- kontrollierte Shell-Nutzung

## Enthaltene Tools
- MCPO
- GitHub CLI
- Browser Tool
- File System Tool
- Firecrawl
- GBOX MCP fuer Android-/Device-nahe Agentensteuerung

## Installation
```bash
scripts/profiles/MCP_Agent_Tools_install.sh
```

## Ports
- 8000 typischer MCPO-Port

## Modelle
- modellunabhängig

## Abhängigkeiten
- Python
- API-Keys je nach Toolserver

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: niedrig
- RAM: ab 4 GB
- Storage: gering

## Sicherheitshinweise
- Shell-MCP nur mit expliziter Freigabe und Safe-Mode
- Dateisystem- und Browser-MCP nie offen ins Internet stellen
- GBOX MCP nur lokal oder hinter privatem Zugriff betreiben; Testgeraete und Testkonten bevorzugen

## Start / Stop / Status Befehle
```bash
mcpo --help
```

## Test-Command
```bash
bash scripts/profiles/MCP_Agent_Tools_install.sh
```

## Deinstallation
```bash
scripts/profiles/MCP_Agent_Tools_uninstall.sh
```
