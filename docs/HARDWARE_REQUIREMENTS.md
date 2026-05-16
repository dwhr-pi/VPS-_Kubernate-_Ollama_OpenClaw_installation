# Hardware Requirements

## Minimal

- 2 CPU-Kerne
- 4 bis 8 GB RAM
- 30 GB freier Speicher
- geeignet fuer: Ollama kleine Modelle, OpenClaw, leichte RAG-Tests, Diagnose

## Recommended MiniPC / WSL2

- 4 bis 8 CPU-Kerne
- 16 bis 32 GB RAM
- 100 GB SSD frei
- geeignet fuer: Open WebUI, Qdrant, n8n, Huginn, Monitoring, Prompt/Eval

## GPU Workstation

- NVIDIA GPU mit 8 GB VRAM Minimum, 12 bis 24 GB VRAM empfohlen
- 32 bis 64 GB RAM
- 500 GB bis 2 TB SSD fuer Modelle/Assets
- geeignet fuer: ComfyUI, Forge, Video, Blender, Render-Farm

## VPS

- 2 bis 4 vCPU
- 4 bis 16 GB RAM
- kein GPU-Default
- geeignet fuer: Tunnel, leichte Automationen, Monitoring, kleine Gateways

## K3s

- nur nach Basisstabilitaet
- Storage, Backups und Ingress bewusst planen
- keine GPU-/Media-Stacks ohne Ressourcenpruefung
