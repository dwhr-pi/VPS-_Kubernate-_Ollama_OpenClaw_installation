# Home_Network_Defense

## Zweck

Heimnetz, DNS-Schutz, IoT-Segmentierung.

## Status

- Installationsreife: planned
- Ressourcenklasse: medium
- Empfohlene Geraete: Raspberry Pi, Home Server

## Empfohlene Tools

- pihole
- adguard_home
- crowdsec

## Sicherheitsregeln

- Keine schweren Installer automatisch starten.
- Secrets nur unter `~/.openclaw_ultimate_user_data` speichern.
- Remotezugriff bevorzugt ueber WireGuard/Tailscale/Allowlist.
- Schreibende Agentenaktionen brauchen Human Approval.

## Installationshinweis

Dieses Profil ist zuerst als Planungs- und Auswahlprofil gedacht. Einzelne Tools muessen bewusst im Setup-Menue ausgewaehlt werden.

## Beispiel-Prompt

```text
Pruefe das Profil Home_Network_Defense fuer mein System. Erstelle einen sicheren Installationsplan mit Ressourcencheck, aber starte keine schweren Installer automatisch.
```
