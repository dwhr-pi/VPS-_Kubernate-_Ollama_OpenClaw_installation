# Port Matrix

Diese Matrix listet die wichtigsten Standardports im Repo. Standardregel ab jetzt: Dienste werden nach Moeglichkeit nur auf `127.0.0.1` gebunden und erst bewusst ueber Tunnel oder Reverse Proxy freigegeben.

## Kernports

| Port | Dienst | Kategorie | Hinweis |
|---:|---|---|---|
| 3000 | Open WebUI | UI | haeufiger UI-Port, lokal binden |
| 3001 | Grafana | Monitoring | Auth und starke Passwoerter setzen |
| 3003 | Langfuse | LLMOps | Prompt-/Trace-Daten schuetzen |
| 3004 | Uptime Kuma | Monitoring | Monitoring nicht offen exponieren |
| 4000 | LiteLLM | Gateway | Upstream-Keys nur in `.env` |
| 5432 | PostgreSQL | Data | nie ohne Auth / Firewall oeffnen |
| 6333 | Qdrant | RAG | nur intern oder mit Proxy |
| 7700 | Meilisearch | Search | Indexdaten koennen sensibel sein |
| 9090 | Prometheus | Monitoring | intern halten |
| 11434 | Ollama | Runtime | lokal oder im privaten Netz halten |

## Automation, Apps und Office

| Port | Dienst | Kategorie | Hinweis |
|---:|---|---|---|
| 1880 | Node-RED | Automation | Flows und Credentials schuetzen |
| 3006 | Metabase | BI | nur mit Rollenmodell betreiben |
| 5678 | n8n | Automation | Workflow-Credentials extern halten |
| 8004 | Healthchecks | Monitoring | Cron-Metadaten intern halten |
| 8010 | Paperless-ngx | Office | Dokumentdaten sensibel behandeln |
| 8055 | Directus | Apps | API-/CMS-Rechte trennen |
| 8081 | Stirling PDF | Office | nur intern freigeben |
| 8082 | Nextcloud | Office | TLS, Backup und MFA einplanen |
| 8083 | NocoDB | Apps | DB-Zugriff begrenzen |
| 8090 | Appsmith | Apps | nur intern oder via Auth |
| 10000 | Budibase | Apps | Low-Code-Instanzen absichern |

## Smart Home, Media und Edge

| Port | Dienst | Kategorie | Hinweis |
|---:|---|---|---|
| 1883 | Mosquitto | IoT | MQTT nicht offen ins Internet haengen |
| 8099 | Zigbee2MQTT | IoT | lokale Funkgeraete besonders schuetzen |
| 8123 | Home Assistant | IoT | extern nur ueber Tunnel/Proxy |
| 8188 | ComfyUI | Media | GPU-Frontend intern halten |
| 7860 | Stable Diffusion WebUI Forge | Media | kann mit anderen KI-UIs kollidieren |
| 12101 | Rhasspy | Voice | Audiodaten und Mikrofonzugriffe schuetzen |
| 19999 | Netdata | Monitoring | Host-Telemetrie nicht offen veroeffentlichen |

## Storage und Infrastruktur

| Port | Dienst | Kategorie | Hinweis |
|---:|---|---|---|
| 8003 | Airbyte | Data | Konnektoren und Secrets beachten |
| 9000 | MinIO API | Storage | Access Keys niemals im Repo |
| 9001 | MinIO Console | Storage | Console nur intern oder via Auth |
| 9998 | Apache Tika | Dokumente | Parser nicht ungeschuetzt freigeben |

## Aktuelle Port-Risiken

- mehrere UIs konkurrieren konzeptionell um klassische Webports wie `3000`
- `Flowise`, `LangFlow`, `LibreChat`, `AnythingLLM` und weitere UI-Stacks sind noch nicht repo-weit auf feste Default-Ports normiert
- lokale Compose-Stacks und spaetere K3s-Ingress-Pfade brauchen noch eine gemeinsame Port-/Hostname-Taxonomie

## Empfehlung

Vor groesseren Installationen zuerst Port- und Ressourcenpruefung laufen lassen:

```bash
bash scripts/operations/check_port_conflicts.sh
```
