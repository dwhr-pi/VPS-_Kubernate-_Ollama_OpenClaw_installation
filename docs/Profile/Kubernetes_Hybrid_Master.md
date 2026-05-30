# Kubernetes_Hybrid_Master

## Zweck

Hybrid-K3s/Kubernetes Master fuer VPS und Heimworker.

## Status

- Installationsreife: planned
- Ressourcenklasse: heavy
- Empfohlene Geraete: Oracle VPS, Kubernetes, Home Server

## Empfohlene Tools

- k3s
- helm
- grafana

## Sicherheitsregeln

- Keine schweren Installer automatisch starten.
- Secrets nur unter `~/.openclaw_ultimate_user_data` speichern.
- Remotezugriff bevorzugt ueber WireGuard/Tailscale/Allowlist.
- Schreibende Agentenaktionen brauchen Human Approval.

## Installationshinweis

Dieses Profil ist zuerst als Planungs- und Auswahlprofil gedacht. Einzelne Tools muessen bewusst im Setup-Menue ausgewaehlt werden.

## Beispiel-Prompt

```text
Pruefe das Profil Kubernetes_Hybrid_Master fuer mein System. Erstelle einen sicheren Installationsplan mit Ressourcencheck, aber starte keine schweren Installer automatisch.
```
