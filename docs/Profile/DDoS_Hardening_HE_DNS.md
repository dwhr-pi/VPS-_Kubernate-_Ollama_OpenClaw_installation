# DDoS_Hardening_HE_DNS

## Zweck

Hurricane Electric DNS, Firewall, Rate-Limits und DDoS-Hinweise.

## Status

- Installationsreife: planned
- Ressourcenklasse: medium
- Empfohlene Geraete: Oracle VPS

## Empfohlene Tools

- crowdsec
- fail2ban
- ddclient_he
- caddy

## Sicherheitsregeln

- Keine schweren Installer automatisch starten.
- Secrets nur unter `~/.openclaw_ultimate_user_data` speichern.
- Remotezugriff bevorzugt ueber WireGuard/Tailscale/Allowlist.
- Schreibende Agentenaktionen brauchen Human Approval.

## Installationshinweis

Dieses Profil ist zuerst als Planungs- und Auswahlprofil gedacht. Einzelne Tools muessen bewusst im Setup-Menue ausgewaehlt werden.

## Beispiel-Prompt

```text
Pruefe das Profil DDoS_Hardening_HE_DNS fuer mein System. Erstelle einen sicheren Installationsplan mit Ressourcencheck, aber starte keine schweren Installer automatisch.
```
