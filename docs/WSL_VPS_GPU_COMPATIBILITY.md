# WSL, VPS und GPU Compatibility

| Bereich | WSL2 | VPS | GPU-Workstation | Hinweis |
|---|---|---|---|---|
| Ollama | gut | gut fuer kleine Modelle | sehr gut | GPU in WSL separat pruefen |
| OpenClaw | gut | gut | gut | Shell-/Toolzugriff begrenzen |
| Huginn/n8n | gut mit systemd | gut | gut | Credentials auslagern |
| Qdrant/Chroma | gut | gut | gut | Daten nicht oeffentlich exponieren |
| Grafana/Prometheus | gut | gut | gut | Auth/Tunnel nutzen |
| ComfyUI/Forge | eingeschraenkt ohne GPU | nicht empfohlen | sehr gut | grosse Modelle/VRAM |
| Android SDK | moeglich | Build-Server optional | gut | SDK nicht in Minimalpfad |
| Tailscale/cloudflared | gut | sehr gut | gut | sicherer als offene Ports |
| K3s | moeglich, aber anspruchsvoll | gut | gut | erst nach Docker/Netzwerk-Stabilitaet |
