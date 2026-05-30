# MCP Server Gateway

## Status

- Installationsstatus: planned / documentation-first
- Automatische Installation: nein
- Ressourcenklasse: medium

## Zweck

Zentrale und sichere Verwaltung von MCP-Servern fuer OpenClaw/Ollama/Agenten.

## Empfohlene Tools

- modelcontextprotocol_servers
- mcp_filesystem_server
- mcp_git_server
- mcp_postgres_server
- mcp_sqlite_server
- browsermcp
- docker_mcp_registry

## Minimalpfad

1. `bash scripts/preflight.sh --dry-run` ausfuehren.
2. Nur leichte, dokumentierte Komponenten aktivieren.
3. Schwere oder serverartige Komponenten erst nach Doctor-, Port-, Secret- und Ressourcencheck installieren.

## Full-Pfad

- Erst wenn Installer, Doctor, Uninstaller, Portdoku, Ressourcenwerte und Restore-/Rollback-Schritte vorhanden sind.
- Lange Aufgaben ueber Queue Worker Orchestrator planen.

## Sicherheitswarnungen

- Keine Secrets ins Repo oder in Logs schreiben.
- Admin-Oberflaechen nicht oeffentlich exponieren.
- Dienste standardmaessig an `127.0.0.1` binden.
- Remote-Zugriff ueber WireGuard/Tailscale/Reverse Proxy mit Auth.

## Doctor-/Preflight-Bedarf

- CPU/RAM/Swap/Disk pruefen.
- WSL2 und Windows-C:-Speicher pruefen.
- Ports und Secrets pruefen.
- Installer/Uninstaller/Status pruefen.

## Beispiel-Prompt

```text
Bewerte dieses Profil im Dry-Run: benoetigte Tools, Risiken, Ressourcen, Ports, Secrets und sichere naechste Schritte. Installiere nichts ohne Freigabe.
```
