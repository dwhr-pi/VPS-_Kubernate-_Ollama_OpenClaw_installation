# MCP Server Hub

## Zweck

Der MCP Server Hub sammelt sichere, lokale MCP-Server fuer OpenClaw/Codex-kompatible Agenten.

## Kandidaten

- `modelcontextprotocol/servers`
- Dateisystem-Server mit erlaubten Pfaden
- Git/GitHub-Server mit read-only Default
- Browser-/Playwright-Server nur mit Allowlist
- SQLite/DuckDB-Server fuer lokale Daten

## Sicherheitsregeln

- Keine globalen Dateisystemrechte.
- Keine Secrets an MCP-Tools uebergeben.
- Schreibende MCP-Tools nur mit Freigabe.
- Netzwerkzugriff nur mit Allowlist.
- Logs unter `~/.openclaw_ultimate_user_data/logs`.

## Installationsstatus

`documentation-first`. Erst Healthchecks und Tool-Gates bauen, dann im Menue aktivieren.

## Optionaler Gateway-Kandidat

[Obot und Cloud-/Modellgrenzen](HYBRID_CLOUD_MCP.md#2-obot-mcp-gateway-platform-kandidat-kein-fertiger-installer):
Quellenbewertung, Community-Limits und Betriebsabhaengigkeiten.
[Obot-Quellenverwaltung](tools/obot.md) ist im Tool-Menue aufgenommen;
kein fertiger nativer Runtime-Installer, kein automatischer Dienststart und kein Docker-Fallback.
