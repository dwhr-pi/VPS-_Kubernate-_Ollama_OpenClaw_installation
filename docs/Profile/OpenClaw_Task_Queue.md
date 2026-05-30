# OpenClaw_Task_Queue

## Zweck

OpenClaw-Aufgaben seriell planen und priorisieren.

## Status

- Installationsreife: planned
- Ressourcenklasse: medium
- Empfohlene Geraete: Oracle VPS, Home Server

## Empfohlene Tools

- openclaw
- queue_manager
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
Pruefe das Profil OpenClaw_Task_Queue fuer mein System. Erstelle einen sicheren Installationsplan mit Ressourcencheck, aber starte keine schweren Installer automatisch.
```
