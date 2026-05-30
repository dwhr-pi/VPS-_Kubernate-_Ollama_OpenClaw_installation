# Queue_Job_Manager

## Zweck

Lokale Warteschlange fuer Codex, OpenClaw und n8n Jobs, damit schwere Aufgaben nicht parallel eskalieren.

## Status

- Installationsreife: planned
- Ressourcenklasse: medium
- Empfohlene Geraete: WSL2, Oracle VPS, Home Server

## Empfohlene Tools

- queue_manager
- redis
- n8n

## Sicherheitsregeln

- Keine schweren Installer automatisch starten.
- Secrets nur unter `~/.openclaw_ultimate_user_data` speichern.
- Remotezugriff bevorzugt ueber WireGuard/Tailscale/Allowlist.
- Schreibende Agentenaktionen brauchen Human Approval.

## Installationshinweis

Dieses Profil ist zuerst als Planungs- und Auswahlprofil gedacht. Einzelne Tools muessen bewusst im Setup-Menue ausgewaehlt werden.

## Beispiel-Prompt

```text
Pruefe das Profil Queue_Job_Manager fuer mein System. Erstelle einen sicheren Installationsplan mit Ressourcencheck, aber starte keine schweren Installer automatisch.
```
