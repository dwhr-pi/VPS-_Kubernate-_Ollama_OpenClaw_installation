# n8n Git Installation

## Ziel

n8n kann als Workflow-Schicht fuer OpenClaw, Ollama, myNextCloud, Home Assistant und Monitoring dienen. Git-/Source-Builds sind schwerer als Paket-/Containerpfade und bleiben opt-in.

## Voraussetzungen

- Node 22 empfohlen
- Corepack aktiv
- pnpm passend zum Repo
- mindestens 8 GB RAM, besser 16 GB
- Swap unter WSL2/VPS
- ausreichend Speicher

## Build-Hinweise

- Monorepo nicht blind im Root bauen.
- Lockfile und Workspace-Dateien beachten.
- Bei Buildfehlern Log anzeigen und Batch stoppen.
- Keine API-Keys in `.env` im Repo.

## systemd

systemd nur optional. Unter WSL2 ggf. User-Service oder manueller Start.

## Reverse Proxy

- Default lokal auf `127.0.0.1`.
- Remote nur via Tailscale oder Cloudflare Access.

## Beispielworkflows

- URL pruefen
- Pi-hole Domainanalyse
- Datei zusammenfassen
- GitHub Issue erstellen
- lokalen OpenClaw-Agenten ausfuehren
