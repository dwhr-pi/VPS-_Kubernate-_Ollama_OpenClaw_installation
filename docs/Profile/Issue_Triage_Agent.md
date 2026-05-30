# Issue_Triage_Agent

## Zweck

Issues zusammenfassen, labeln und priorisieren.

## Status

- Installationsreife: planned
- Ressourcenklasse: light
- Empfohlene Geraete: WSL2, Oracle VPS

## Empfohlene Tools

- github_cli
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
Pruefe das Profil Issue_Triage_Agent fuer mein System. Erstelle einen sicheren Installationsplan mit Ressourcencheck, aber starte keine schweren Installer automatisch.
```
