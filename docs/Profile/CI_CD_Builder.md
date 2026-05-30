# CI_CD_Builder

## Zweck

CI/CD und lokale Checks vorbereiten.

## Status

- Installationsreife: planned
- Ressourcenklasse: medium
- Empfohlene Geraete: WSL2, Oracle VPS

## Empfohlene Tools

- github_cli
- act
- shellcheck
- shfmt

## Sicherheitsregeln

- Keine schweren Installer automatisch starten.
- Secrets nur unter `~/.openclaw_ultimate_user_data` speichern.
- Remotezugriff bevorzugt ueber WireGuard/Tailscale/Allowlist.
- Schreibende Agentenaktionen brauchen Human Approval.

## Installationshinweis

Dieses Profil ist zuerst als Planungs- und Auswahlprofil gedacht. Einzelne Tools muessen bewusst im Setup-Menue ausgewaehlt werden.

## Beispiel-Prompt

```text
Pruefe das Profil CI_CD_Builder fuer mein System. Erstelle einen sicheren Installationsplan mit Ressourcencheck, aber starte keine schweren Installer automatisch.
```
