# FritzBox_Mesh_Diagnostics

## Zweck

FRITZ!Box, Mesh und Heimnetzdiagnose.

## Status

- Installationsreife: planned
- Ressourcenklasse: light
- Empfohlene Geraete: WSL2, Raspberry Pi

## Empfohlene Tools

- nmap

## Sicherheitsregeln

- Keine schweren Installer automatisch starten.
- Secrets nur unter `~/.openclaw_ultimate_user_data` speichern.
- Remotezugriff bevorzugt ueber WireGuard/Tailscale/Allowlist.
- Schreibende Agentenaktionen brauchen Human Approval.

## Installationshinweis

Dieses Profil ist zuerst als Planungs- und Auswahlprofil gedacht. Einzelne Tools muessen bewusst im Setup-Menue ausgewaehlt werden.

## Beispiel-Prompt

```text
Pruefe das Profil FritzBox_Mesh_Diagnostics fuer mein System. Erstelle einen sicheren Installationsplan mit Ressourcencheck, aber starte keine schweren Installer automatisch.
```
