# Firewall_IDS_IPS

## Zweck

Firewall, IDS/IPS und Log-basierte Abwehr.

## Status

- Installationsreife: planned
- Ressourcenklasse: medium
- Empfohlene Geraete: Oracle VPS, Home Server

## Empfohlene Tools

- ufw
- crowdsec
- suricata
- wazuh

## Sicherheitsregeln

- Keine schweren Installer automatisch starten.
- Secrets nur unter `~/.openclaw_ultimate_user_data` speichern.
- Remotezugriff bevorzugt ueber WireGuard/Tailscale/Allowlist.
- Schreibende Agentenaktionen brauchen Human Approval.

## Installationshinweis

Dieses Profil ist zuerst als Planungs- und Auswahlprofil gedacht. Einzelne Tools muessen bewusst im Setup-Menue ausgewaehlt werden.

## Beispiel-Prompt

```text
Pruefe das Profil Firewall_IDS_IPS fuer mein System. Erstelle einen sicheren Installationsplan mit Ressourcencheck, aber starte keine schweren Installer automatisch.
```
