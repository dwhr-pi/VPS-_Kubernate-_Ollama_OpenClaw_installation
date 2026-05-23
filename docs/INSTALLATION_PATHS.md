# Installationspfade

## MiniPC / WSL2

- Geeignet fuer Ollama, OpenClaw, Open WebUI, RAG, Office, leichte Automatisierung.
- WSL2 braucht systemd, korrekte Windows-Host-Speicherpruefung und Docker-Sonderbehandlung.
- Docker Compose muss bei fehlenden Socket-Rechten ueber `sudo docker compose` laufen.

## Oracle VPS

- Geeignet fuer leichte Web-UIs, Automatisierung, Reverse Proxy, Monitoring und statische Dienste.
- Keine grossen GPU-/Video-/3D-Stacks erwarten.
- Remote-Zugriff nur ueber Tailscale, Cloudflare Access oder Reverse Proxy mit Auth.

## Lokaler Linux-PC

- Bester stabiler Pfad fuer Docker, GPU, lokale Modelle, Office-/RAG-/Dev-Profile.
- Dienste standardmaessig localhost-first betreiben.

## GPU-Workstation

- Geeignet fuer ComfyUI, Video, Blender, Whisper/faster-whisper, lokale groessere Modelle.
- VRAM, CUDA/ROCm und Modellordner sauber trennen.

## Kubernetes spaeter

- Fuer Renderfarm, LLM-Worker, Batch-Jobs, Monitoring und Storage.
- Nicht als Default-Setup; erst nach stabilen Einzeltool-Installern.
