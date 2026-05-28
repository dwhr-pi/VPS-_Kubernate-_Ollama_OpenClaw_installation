# Recommended Advanced Setup

Ziel: Home-Server oder staerkerer MiniPC mit Monitoring, RAG und Automatisierung.

## Empfohlen

- Minimal Setup als Basis
- LiteLLM, Langfuse/OpenLIT
- Qdrant plus Meilisearch
- Paperless-ngx, Stirling PDF, Docling
- n8n oder Huginn, nicht beide sofort
- Prometheus, Grafana, Loki oder Netdata
- Tailscale fuer privaten Zugriff

## Nur bewusst

- Airbyte nur mit 32 GB frei Minimum, besser 64 GB und 8-12 GB RAM.
- Activepieces nur wenn Bun/Node-Pfad stabil ist.
- Kubernetes/K3s erst nach Backup, Port- und Storageplan.

## Tests

```bash
bash scripts/doctor.sh
bash scripts/check_tools.sh
bash scripts/check_profiles.sh
```
