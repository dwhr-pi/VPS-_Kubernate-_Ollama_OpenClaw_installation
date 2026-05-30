# Email_Assistant

## Zweck

Mail-Zusammenfassung, Entwuerfe und Regeln.

## Status

- Installationsreife: planned
- Ressourcenklasse: medium
- Empfohlene Geraete: Oracle VPS, WSL2

## Empfohlene Tools

- stalwart_mail
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
Pruefe das Profil Email_Assistant fuer mein System. Erstelle einen sicheren Installationsplan mit Ressourcencheck, aber starte keine schweren Installer automatisch.
```
