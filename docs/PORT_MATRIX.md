# Port Matrix

Diese Matrix listet die wichtigsten Standardports der dokumentierten Dienste. Nicht jeder Port ist in jedem Profil aktiv.

| Port | Dienst | Konflikthinweis |
|---:|---|---|
| 1880 | Node-RED | Smart-Home-/Flow-Port |
| 1883 | Mosquitto MQTT | MQTT-Basisport |
| 3000 | Open WebUI | konfliktanfälliger Web-UI-Port |
| 3001 | Grafana | Dashboard-Zugriff |
| 3003 | Langfuse | LLM-Telemetrie |
| 3004 | Uptime Kuma | Uptime-Monitoring |
| 3005 | Forgejo | Self-Hosted Git |
| 3006 | Metabase | BI-Frontend |
| 4000 | LiteLLM | Gateway-Port |
| 5432 | PostgreSQL | Datenbank |
| 6333 | Qdrant | Vektor-DB |
| 7700 | Meilisearch | Suche |
| 7860 | Stable Diffusion WebUI Forge | Bild-/Video-UI |
| 8003 | Airbyte | Dateningestion |
| 8004 | Healthchecks | Cron-/Job-Monitoring |
| 8010 | Paperless-ngx | DMS-Port |
| 8055 | Directus | Low-Code/API-UI |
| 8081 | Stirling PDF | PDF-Tooling |
| 8082 | Nextcloud | Files/DMS |
| 8083 | NocoDB | No-Code-Datenbank-UI |
| 8088 | cAdvisor | Container-Monitoring |
| 8090 | Appsmith | Low-Code-App-Builder |
| 8099 | Zigbee2MQTT | Smart-Home-Dashboard |
| 8123 | Home Assistant | Smart-Home-Zentrale |
| 8188 | ComfyUI | Node-basiertes Medien-Frontend |
| 9000 | MinIO API | Objekt-Storage |
| 9001 | MinIO Console | Objekt-Storage-Weboberfläche |
| 9090 | Prometheus | Monitoring |
| 9998 | Apache Tika | Dokumentenparser |
| 10000 | Budibase | App-Builder |
| 11434 | Ollama | lokaler Modellserver |
| 12101 | Rhasspy | lokaler Sprachassistent |
| 19999 | Netdata | Host-Monitoring |

Empfohlene Prüfung:

```bash
bash scripts/operations/check_port_conflicts.sh
```
