# Required And Optional Services

## Core

- OpenClaw
- Ollama
- PostgreSQL
- Qdrant

## Voice

- Whisper or faster-whisper
- Piper
- optional openWakeWord

## Browser

- Chromium
- Playwright

## Infrastructure

- Docker or Podman
- Kubernetes/K3s optional

## Monitoring

- Prometheus
- Grafana
- Loki optional
- Uptime Kuma optional

## Smart Home

- Home Assistant optional
- MQTT/Mosquitto optional

## Security Defaults

- bind services to `127.0.0.1` by default
- expose externally only through WireGuard/Tailscale/reverse proxy with auth
- keep secrets under `~/.openclaw_ultimate_user_data`
