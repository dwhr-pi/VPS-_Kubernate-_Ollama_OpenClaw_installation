# Supply_Chain_Security

## Zweck

SBOM, Secrets, Container- und Release-Pruefungen.

## Status

- Installationsreife: planned
- Ressourcenklasse: medium
- Empfohlene Geraete: WSL2, Oracle VPS

## Empfohlene Tools

- gitleaks
- trivy
- syft
- grype
- cosign
- sops
- age

## Sicherheitsregeln

- Keine schweren Installer automatisch starten.
- Secrets nur unter `~/.openclaw_ultimate_user_data` speichern.
- Remotezugriff bevorzugt ueber WireGuard/Tailscale/Allowlist.
- Schreibende Agentenaktionen brauchen Human Approval.

## Installationshinweis

Dieses Profil ist zuerst als Planungs- und Auswahlprofil gedacht. Einzelne Tools muessen bewusst im Setup-Menue ausgewaehlt werden.

## Beispiel-Prompt

```text
Pruefe das Profil Supply_Chain_Security fuer mein System. Erstelle einen sicheren Installationsplan mit Ressourcencheck, aber starte keine schweren Installer automatisch.
```
