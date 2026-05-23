# Recommended First Install

Dieser Pfad ist fuer neue Systeme gedacht, damit nicht zu frueh schwere oder riskante Komponenten installiert werden.

## Reihenfolge

1. Systemcheck: OS, WSL2, RAM, freier Linux-/Host-Speicher, Shell-Line-Endings.
2. Core: Git, curl, Python-venv, Node.js LTS/Corepack, Build-Werkzeuge.
3. Ollama und OpenClaw.
4. Open WebUI oder lokale UI.
5. RAG-Basis: Qdrant oder ChromaDB.
6. Automation: n8n oder Node-RED.
7. Monitoring: Uptime Kuma oder Netdata.
8. Backup: Restic/Rclone.
9. Erst danach Medien/GPU/Kubernetes/Android/Cloud-Stacks.

## Warum diese Reihenfolge?

- Fehler sind kleiner und leichter zu diagnostizieren.
- Speicherverbrauch wird pro Tool messbar.
- Ports und Secrets werden vor Remote-Freigaben geklaert.
- WSL2-Probleme mit Host-Speicher fallen frueh auf.

## Stop-Regeln

Stoppe und pruefe, wenn:
- Windows-Host-Speicher knapp ist, auch wenn Linux viel frei meldet.
- Docker-Daemon nicht erreichbar ist.
- Node/Python-Version nicht zum Upstream passt.
- ein Git-Clone unvollstaendig ist.
- ein Installer versucht, echte Secrets oder Live-Keys anzulegen.

