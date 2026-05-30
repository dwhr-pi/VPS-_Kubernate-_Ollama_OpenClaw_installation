# Local_Voice_Assistant

## Zweck

Lokaler Sprachassistent ohne Cloudpflicht.

## Status

- Installationsreife: planned
- Ressourcenklasse: medium
- Empfohlene Geraete: Raspberry Pi, Home Server

## Empfohlene Tools

- whisper_cpp
- piper
- home_assistant

## Sicherheitsregeln

- Keine schweren Installer automatisch starten.
- Secrets nur unter `~/.openclaw_ultimate_user_data` speichern.
- Remotezugriff bevorzugt ueber WireGuard/Tailscale/Allowlist.
- Schreibende Agentenaktionen brauchen Human Approval.

## Installationshinweis

Dieses Profil ist zuerst als Planungs- und Auswahlprofil gedacht. Einzelne Tools muessen bewusst im Setup-Menue ausgewaehlt werden.

## Beispiel-Prompt

```text
Pruefe das Profil Local_Voice_Assistant fuer mein System. Erstelle einen sicheren Installationsplan mit Ressourcencheck, aber starte keine schweren Installer automatisch.
```
