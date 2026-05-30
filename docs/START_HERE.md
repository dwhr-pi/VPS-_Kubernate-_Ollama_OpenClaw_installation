# START HERE

Wenn du neu startest, beginne hier.

## Merksatz

```text
HE vorne, Oracle steuert, Pi weckt, RTX rechnet.
```

## Sicherer erster Weg

1. Lies [Beginner Guide](BEGINNER_GUIDE.md).
2. Starte nur Basis.
3. Installiere Ollama/OpenClaw lokal.
4. Richte Oracle VPS erst als Control Node ein.
5. Verbinde Heimnetz nur ueber WireGuard.
6. Nutze Queue Manager, bevor schwere Jobs starten.

## Nicht direkt oeffentlich machen

- Ollama
- OpenClaw Gateway
- Kubernetes API
- Home Assistant
- NAS
- Datenbanken
- ComfyUI
- Whisper

## Startpfade 2026 Next Improvements

- MiniPC lokal: Low Resource Mode, Piper, Ollama klein, Queue default 1.
- WSL2 lokal: Windows-C:-Speicher, Python-Versionen, Docker optional, keine schweren Builds parallel.
- Oracle VPS: Control Node, WireGuard, Mail-DNS, Monitoring, keine sensiblen Heimdienste oeffentlich.
- Hurricane Electric DNS/Domain: DNS bewusst setzen, keine Wildcards ohne Schutz, rDNS fuer Mail beachten.
- Home Assistant zuhause: nur ueber VPN/Reverse Proxy mit Auth, keine offenen Admin-Panels.
- GPU Workstation: Media-/Avatar-/vLLM-/RVC-Jobs ueber Queue starten.
- Low Resource Mode: Glances/Netdata statt vollem Grafana-Stack, SQLite-Queue statt Redis/RabbitMQ.
- Security First Mode: Secrets extern, Ports minimal, check_secrets/check_ports/check_resource_budget vor Installationen.
