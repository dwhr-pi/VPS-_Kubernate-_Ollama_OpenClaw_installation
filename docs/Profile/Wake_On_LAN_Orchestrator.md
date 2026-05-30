# Wake_On_LAN_Orchestrator

## Zweck

Weckt GPU-/KI-Server bei Bedarf ueber WireGuard und Wake-on-LAN.

## Status

- Installationsreife: planned
- Ressourcenklasse: light
- Empfohlene Geraete: Raspberry Pi, Home Server

## Empfohlene Tools

- wireguard
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
Pruefe das Profil Wake_On_LAN_Orchestrator fuer mein System. Erstelle einen sicheren Installationsplan mit Ressourcencheck, aber starte keine schweren Installer automatisch.
```
