# Memory_Governance

## Zweck

Regeln fuer Memory, Datenschutz und Loeschbarkeit.

## Status

- Installationsreife: planned
- Ressourcenklasse: medium
- Empfohlene Geraete: WSL2, Home Server

## Empfohlene Tools

- qdrant
- chromadb
- lightrag

## Sicherheitsregeln

- Keine schweren Installer automatisch starten.
- Secrets nur unter `~/.openclaw_ultimate_user_data` speichern.
- Remotezugriff bevorzugt ueber WireGuard/Tailscale/Allowlist.
- Schreibende Agentenaktionen brauchen Human Approval.

## Installationshinweis

Dieses Profil ist zuerst als Planungs- und Auswahlprofil gedacht. Einzelne Tools muessen bewusst im Setup-Menue ausgewaehlt werden.

## Beispiel-Prompt

```text
Pruefe das Profil Memory_Governance fuer mein System. Erstelle einen sicheren Installationsplan mit Ressourcencheck, aber starte keine schweren Installer automatisch.
```
