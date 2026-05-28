# Low Resource Mode

Der Low Resource Mode ist fuer WSL2, MiniPCs, kleine VPS und Systeme mit wenig freiem Windows-C:-Speicher gedacht.

## Aktivieren

Empfohlene Logik:

- Keine schweren Tools automatisch installieren.
- Ressourcenwerte aus Cache/Registry anzeigen, nicht live minutenlang berechnen.
- Nur `stable` und kleine `beta`-Tools anbieten.
- Airbyte, AutoGPT, OpenHands, ComfyUI, Blender, Nextcloud, n8n und Kubernetes nur mit expliziter Warnung.

## Grenzwerte

| Ressource | Warnung | Block fuer schwere Tools |
|---|---|---|
| Linux/WSL frei | < 20 GB | < 10 GB |
| Windows C: frei | < 50 GB | < 20 GB |
| RAM | < 8 GB | < 6 GB |
| Swap | 0 GB | bei grossen Builds |

## Gute Startauswahl

- Ollama mit kleinem Modell
- OpenClaw Basis
- GitHub CLI
- Shellcheck/shfmt
- Uptime Kuma oder leichter Doctor
- RAG erst mit kleinen lokalen Datenmengen

## Nicht empfohlen

- Airbyte abctl/kind
- grosse Docker Compose Stacks
- GPU-/CUDA-Pakete ohne GPU
- Monorepo-Builds unter Speicherknappheit
