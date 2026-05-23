# Installation Wizard

Dieser Wizard beschreibt sichere Installationspfade. Er ersetzt keine interaktive Auswahl, sondern dient als Entscheidungshilfe fuer Nutzer und fuer spaetere Setup-Menues.

## 1. Minimal lokal

Geeignet fuer: WSL2, MiniPC, Linux-PC ohne grosse GPU.

Empfohlen:
- Ollama
- OpenClaw
- Open WebUI
- Qdrant oder ChromaDB
- n8n oder Node-RED
- Uptime Kuma optional

Nicht sofort:
- grosse Video-/Bildmodelle
- Kubernetes
- offene Web-Panels
- schwere Docker-Stacks

## 2. MiniPC + Smart Home

Empfohlen:
- Tailscale statt offener Ports
- Home Assistant Integration
- MQTT/Node-RED/n8n
- Netdata/Uptime Kuma
- Backup mit Restic/Rclone

Wichtig:
- Admin-UIs nicht ins Internet oeffnen.
- Secrets in `~/.openclaw_ultimate_user_data` halten.

## 3. GPU / Medien

Empfohlen:
- ComfyUI
- Blender
- FFmpeg
- Whisper.cpp/faster-whisper
- Piper

Vorher pruefen:
- VRAM
- CUDA/ROCm
- Modellcache
- freier Windows-Host-Speicher bei WSL2

## 4. VPS / Remote

Empfohlen:
- Cloudflare Tunnel oder Tailscale
- Reverse Proxy nur mit Auth
- Monitoring-Agenten
- keine privaten RAG-Daten ohne Verschluesselung

Nicht empfohlen:
- grosse Modelle ohne GPU
- offene Docker-Sockets
- Admin-Panels auf `0.0.0.0`

## 5. Kubernetes spaeter

Kubernetes erst nutzen, wenn Einzelinstallation, Backups und Ports stabil sind.

Startreihenfolge:
1. Storage und Backups
2. Secrets
3. Monitoring
4. leichte Services
5. GPU-/Render-/LLM-Worker

