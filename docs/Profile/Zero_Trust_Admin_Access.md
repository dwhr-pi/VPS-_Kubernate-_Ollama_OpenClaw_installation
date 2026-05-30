# Zero_Trust_Admin_Access

## Zweck

Adminzugriff ueber VPN, Allowlist und starke Auth.

## Status

- Installationsreife: planned
- Ressourcenklasse: medium
- Empfohlene Geraete: Oracle VPS, Home Server

## Empfohlene Tools

- wireguard
- tailscale
- headscale

## Sicherheitsregeln

- Keine schweren Installer automatisch starten.
- Secrets nur unter `~/.openclaw_ultimate_user_data` speichern.
- Remotezugriff bevorzugt ueber WireGuard/Tailscale/Allowlist.
- Schreibende Agentenaktionen brauchen Human Approval.

## Installationshinweis

Dieses Profil ist zuerst als Planungs- und Auswahlprofil gedacht. Einzelne Tools muessen bewusst im Setup-Menue ausgewaehlt werden.

## Beispiel-Prompt

```text
Pruefe das Profil Zero_Trust_Admin_Access fuer mein System. Erstelle einen sicheren Installationsplan mit Ressourcencheck, aber starte keine schweren Installer automatisch.
```
