# Port Matrix

Diese Matrix listet die wichtigsten Standardports der aktuell dokumentierten Dienste. Nicht jeder Port ist in jedem Profil aktiv. Vor Installation immer Portkonflikte prüfen.

| Port | Dienst | Konflikthinweis |
|---:|---|---|
| 1880 | Node-RED | oft frei, für Home- und Flow-Setups relevant |
| 1883 | Mosquitto MQTT | häufig mit anderen MQTT-Setups kollisionsfrei |
| 3000 | Open WebUI oder andere Web-UIs | sehr konfliktanfällig |
| 3001 | Grafana | oft durch lokale Dashboards belegt |
| 3003 | Langfuse | mit anderen Dev-UIs abgleichen |
| 3004 | Uptime Kuma | lokal meist unkritisch |
| 3005 | Forgejo | Gitea/ähnliche Dienste beachten |
| 3006 | Metabase | nur ein BI-Dienst parallel |
| 4000 | LiteLLM | Gateway-Port bewusst reservieren |
| 5432 | PostgreSQL | klassischer DB-Port |
| 5678 | n8n | mit anderen n8n-Instanzen kollisionsanfällig |
| 6333 | Qdrant | wichtig für RAG-/Memory-Stacks |
| 7860 | Stable Diffusion WebUI / Forge | GPU-Workflows |
| 8000 | MCPO / APIs / diverse Python-Apps | hoher Konfliktkandidat |
| 8003 | Airbyte | nur bei aktiver Datenpipeline |
| 8004 | Healthchecks | einfach freizuhalten |
| 8010 | Paperless-ngx | DMS-Port |
| 8055 | Directus | Low-Code/API-UI |
| 8081 | Stirling PDF | PDF-/OCR-Stack |
| 8082 | Nextcloud | Web-DMS/Dateidienst |
| 8083 | NocoDB | No-Code-Datenbank-UI |
| 8090 | Appsmith | Low-Code-App-Builder |
| 8099 | Zigbee2MQTT | Smart-Home-Dashboard |
| 8123 | Home Assistant | sehr zentral im Smart-Home-Profil |
| 8188 | ComfyUI | Bild-/Video-Node-Workflows |
| 9000 | MinIO API | Objekt-Storage |
| 9001 | MinIO Console | auch von anderen Diensten gern genutzt |
| 9090 | Prometheus | Monitoring-Kern |
| 9998 | Apache Tika | Dokumenten-Parsing |
| 10000 | Budibase | App-Builder |
| 11434 | Ollama | lokaler Modellserver |
| 19999 | Netdata | Host-Monitoring |

## Empfohlene Prüfung

```bash
bash scripts/operations/check_port_conflicts.sh
```
