# Jarvis_Home_Command_Center

## Zweck

Lokale Home-Command-Zentrale mit Freigaben.

## Status

- Installationsreife: planned
- Ressourcenklasse: medium
- Empfohlene Geraete: Home Server, Raspberry Pi

## Empfohlene Tools

- home_assistant
- mosquitto
- openclaw

## Sicherheitsregeln

- Keine schweren Installer automatisch starten.
- Secrets nur unter `~/.openclaw_ultimate_user_data` speichern.
- Remotezugriff bevorzugt ueber WireGuard/Tailscale/Allowlist.
- Schreibende Agentenaktionen brauchen Human Approval.

## Installationshinweis

Dieses Profil ist zuerst als Planungs- und Auswahlprofil gedacht. Einzelne Tools muessen bewusst im Setup-Menue ausgewaehlt werden.

## Beispiel-Prompt

```text
Pruefe das Profil Jarvis_Home_Command_Center fuer mein System. Erstelle einen sicheren Installationsplan mit Ressourcencheck, aber starte keine schweren Installer automatisch.
```
