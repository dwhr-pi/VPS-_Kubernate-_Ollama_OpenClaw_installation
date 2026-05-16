# Port Security Matrix

Technische Quelle: `config/ports.yml`.

## Grundregel

Alle lokalen Dienste sollten standardmaessig nur auf `127.0.0.1`, LAN oder Tailnet erreichbar sein. Oeffentliche Freigabe nur bewusst ueber Tailscale, Cloudflare Tunnel oder Reverse Proxy mit Auth.

| Port | Dienst | Risiko | Empfehlung |
|---:|---|---|---|
| 3000 | Open WebUI/OpenClaw-nahe UIs | Prompts, Modelle, Logins | nicht oeffentlich ohne Auth |
| 3001 | Grafana | Infrastrukturdetails | starkes Admin-Passwort, Reverse Proxy |
| 3002 | Huginn | Automationsdaten | lokal/Tailnet, keine Default-User |
| 4000 | LiteLLM | API-Gateway und Keys | Keys nur User-Workspace |
| 5432 | PostgreSQL | Datenbank | nie oeffentlich, lokal binden |
| 5678 | n8n | Credentials und Automationen | nur mit Auth und Backup |
| 6333 | Qdrant | Dokument-/Embeddingdaten | lokal oder Auth-Proxy |
| 7700 | Meilisearch | Suchindexe | Master-Key und lokale Bindung |
| 7860/8188 | SD/ComfyUI | GPU-Workflows, Uploads | nicht oeffentlich |
| 8123 | Home Assistant | Smart Home | nur LAN/Tailnet, MFA |
| 9090 | Prometheus | Metriken | intern halten |
| 11434 | Ollama | Modellserver | lokal binden |
| 19999 | Netdata | Host-Telemetrie | intern oder Auth |
