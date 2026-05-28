# Profil: Infrastructure Security

## Zweck

Dieses Profil beschreibt den sicheren Betrieb von Hurricane Electric,
Oracle VPS, WireGuard, Heimnetz-Waechter, K3s und On-Demand-GPU-Server.

## Zielgruppe

Einsteiger und Betreiber, die das Ultimate KI Setup sicher aus dem Internet
erreichbar machen wollen, ohne sensible KI- und Heimdienste direkt zu
veroeffentlichen.

## Empfohlene Tools

- WireGuard
- UFW oder nftables
- CrowdSec
- Fail2Ban
- Caddy, Traefik oder NGINX
- Uptime Kuma
- Prometheus / Grafana optional
- K3s optional

## Erlaubte Aktionen

- VPS absichern
- WireGuard Tunnel aufbauen
- RTX-Server per Wake-on-LAN starten
- Monitoring und Healthchecks einrichten
- n8n/Webhooks abgesichert bereitstellen

## Verbotene/gefaehrliche Aktionen

- Ollama oeffentlich freigeben
- OpenClaw Gateway oeffentlich freigeben
- Kubernetes API oeffentlich freigeben
- Home Assistant oeffentlich ohne Auth/VPN freigeben
- Docker/K3s interne Ports ins Internet stellen
- Secrets in Git speichern

## Beispiel-Prompt

```text
Pruefe meine HE/Oracle/WireGuard/Homecluster-Konfiguration.
Behandle Cloudflare nur als optionale Alternative.
Stelle sicher, dass Ollama, OpenClaw, Home Assistant, Kubernetes API,
ComfyUI und Whisper nicht oeffentlich erreichbar sind.
Gib mir nur sichere, reversible Schritte.
```
