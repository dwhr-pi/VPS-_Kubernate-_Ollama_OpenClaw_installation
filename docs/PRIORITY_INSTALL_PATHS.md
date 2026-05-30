# Priority Install Paths

## Empfohlene Installation

1. Nur Basis
2. MiniPC + Ollama + OpenClaw
3. Oracle VPS Master
4. Hurricane Electric DNS/DDNS
5. Raspberry Pi Worker
6. Queue Manager
7. Security Hardening
8. Mailserver optional
9. GPU Render Worker optional

## Nur Basis

- Git
- Bash
- Python/Node nur nach Bedarf
- keine Docker-Pflicht

## MiniPC + Ollama + OpenClaw

- Ollama
- OpenClaw
- Qdrant optional
- lokale Ports nur `127.0.0.1`

## Oracle VPS Master

- WireGuard
- Reverse Proxy
- UFW
- CrowdSec/Fail2Ban
- Uptime Kuma
- n8n optional

## Queue Manager

```bash
bash scripts/tools/queue_manager_install.sh --dry-run
bash scripts/tools/queue_manager_install.sh --prepare
```

## Mailserver

Stalwart Mail nur nach DNS/PTR/rDNS/Firewall-Pruefung vorbereiten.
