# Tool Matrix

Diese Matrix zeigt die derzeit sinnvoll verdrahteten Toolgruppen. Sie ist bewusst kompakter als `scripts/tools/` und unterscheidet zwischen `Core`, `Optional`, `Experimental` und `High-Risk`.

Die bevorzugten Primaerquellen sind in `docs/GITHUB_TOOL_SOURCES.md` dokumentiert. Ein Tool gilt erst dann als installierbar, wenn Quelle, Installer, Uninstaller, Healthcheck, Ressourcenhinweis und sichere Defaults vorhanden sind.

Wichtig zur Zaehlung:

- die automatische Live-Zaehlung erfolgt im Setup unter `Tool-Management`
- dort werden `Gesamtzahl` und `bereits installierte Tools` direkt aus der Tool-Liste und der Statusdatei berechnet
- diese Markdown-Datei bleibt bewusst eine thematische Uebersicht und nicht die laufende Statusanzeige

## Core

| Gruppe | Tools | Einsatz |
|---|---|---|
| Runtime | `ollama`, `docker`, `docker_compose_plugin`, `k3s` | lokale und serverseitige Laufzeit |
| Gateway / UI | `litellm`, `open_webui`, `langfuse` | Modellzugang, Telemetrie, UI |
| Coding / Agenten | `openclaw`, `aider`, `openhands`, `continue_dev`, `langgraph`, `crewai`, `autogen` | Coding, Orchestrierung, Agenten |
| RAG / Dokumente | `qdrant`, `chromadb`, `lightrag`, `llamaindex`, `haystack`, `docling`, `apache_tika`, `paperless_ngx` | Wissensspeicher und Dokument-Pipelines |
| Monitoring | `prometheus`, `grafana`, `loki`, `healthchecks`, `uptime_kuma`, `netdata`, `node_exporter`, `cadvisor` | Metriken, Logs, Hostzustand |
| Security | `trivy`, `gitleaks`, `semgrep`, `syft`, `grype`, `fail2ban`, `crowdsec`, `tailscale`, `cloudflared` | defensives Hardening, privater Remote-Zugriff, veröffentlichte Tunnel und Scans |

## Optional

| Gruppe | Tools | Einsatz |
|---|---|---|
| No-Code / Low-Code | `n8n`, `activepieces`, `node_red`, `flowise`, `langflow`, `appsmith`, `budibase`, `nocodb`, `directus` | interne Apps, Automatisierung, Daten-Frontends |
| Office / Knowledge | `nextcloud`, `stirling_pdf`, `pandoc`, `meilisearch`, `searxng`, `jupyterlab`, `duckdb`, `metabase`, `minio` | DMS, Berichte, Suche, Notiz-/Dateischicht |
| DevOps | `github_cli`, `act`, `pre_commit`, `release_please`, `ansible`, `opentofu`, `argocd_cli`, `grafana_alloy`, `restic`, `rclone`, `borgbackup` | Repo-, Release- und Plattformpflege |
| Browser / Research | `playwright`, `puppeteer`, `gbox` | kontrollierte Browser-/Desktop-/Android-Tests und Web-Analysen |
| Web-Automation | `huginn`, `firecrawl` | Event-Automation, Agentenketten, Webhook-Routing und Webquellen-Connectoren |
| Smart Home / Edge | `home_assistant`, `mosquitto`, `zigbee2mqtt`, `esphome` | lokale IoT- und Sensor-Workflows |

## Experimental

| Tools | Grund |
|---|---|
| `openmanus`, `clawhub`, `clawhub_cli` | mehrere GitHub-Quellen, Build-/Netzwerkfragilitaet moeglich |
| `video`- und `voice-clone`-nahe Toolketten | hoher Ressourcenbedarf, heterogene Upstreams |
| `flowise` und `langflow` parallel | funktional sinnvoll, aber Port- und Bedienkonzept noch nicht vereinheitlicht |
| `gbox` | vielversprechende Android-/Browser-/Desktop-/MCP-Agentenumgebung, aber Login-/Cloud-/Device-Zugriffe muessen sauber begrenzt werden |

## High-Risk

| Tools / Bereiche | Risiko |
|---|---|
| `Web3_Crypto_Agent`, Trading-Stacks | keine Live-Orders, Seeds oder echten Exchange-Keys als Default |
| Voice-/Clone-/Face-/Video-Workflows | Rechte, Einwilligung, Missbrauchsrisiko |
| Browser-/Scraping-/OSINT-Automation | Rechts- und Datenschutzgrenzen klar einhalten |
| Security-Scanner und Infra-Automation | nur defensiv und mit Review in produktionsnahen Umgebungen |

## Wichtige Luecken

Diese Kandidaten sind fachlich sinnvoll, aber in diesem Repo noch nicht sauber als installierbare Standardmodule hinterlegt:

- `browser-use`
- `SWE-agent`
- `Tabby`
- `Typesense`
- `detect-secrets`
- `OpenBao`
- `SOPS`
- `age`
- `Taskfile`
- `just`
- `Kopia`
- `Superset`
- `Evidence.dev`
- `DVC`
- `Label Studio`

Sie sind gute Kandidaten fuer die naechste Ausbaustufe, sollten aber erst mit klarer Install-/Uninstall-/Status-Logik nachgezogen werden.

`Tailscale` ist bewusst bereits integriert, weil es direkt zur Sicherheitsgrundregel des Repos passt: Admin-Zugriffe nach Moeglichkeit privat statt ueber offene Web-Panels oder rohe Host-Ports.
