# monitoring_observability

## Zweck

Standardisiert Plattform-, Modell-, Agenten- und Uptime-Monitoring für den produktiven Betrieb.

## Use Cases

- LLM-Tracing
- Container- und Host-Monitoring
- Dashboards
- Uptime-Checks

## Enthaltene Tools

- `Langfuse`
- `OpenLIT`
- `Grafana`
- `Prometheus`
- `Loki`
- `Uptime_Kuma`
- `Netdata`

## Installation

```bash
scripts/tools/langfuse_install.sh
scripts/tools/openlit_install.sh
scripts/tools/grafana_install.sh
scripts/tools/prometheus_install.sh
scripts/tools/loki_install.sh
scripts/tools/uptime_kuma_install.sh
scripts/tools/netdata_install.sh
```

## Ports

- `3003` Langfuse
- `3001` Grafana
- `9090` Prometheus
- `3100` Loki
- `3004` Uptime Kuma
- `19999` Netdata

## Modelle

- modellunabhängig

## Abhängigkeiten

- Docker
- Logs und OTEL-Instrumentierung

## Ressourcenverbrauch (CPU / RAM / Storage)

- CPU: mittel
- RAM: ab 12-24 GB
- Storage: je nach Trace- und Log-Menge ab 20 GB

## Sicherheitshinweise

- Monitoring-Zugänge absichern
- Langfuse und Grafana nicht ohne Auth freigeben

## Start / Stop / Status Befehle

```bash
docker ps
curl http://localhost:9090/-/healthy
```

## Test-Command

```bash
curl http://localhost:3003
```

## Deinstallation

```bash
scripts/tools/langfuse_uninstall.sh
scripts/tools/openlit_uninstall.sh
scripts/tools/grafana_uninstall.sh
scripts/tools/prometheus_uninstall.sh
scripts/tools/loki_uninstall.sh
scripts/tools/uptime_kuma_uninstall.sh
scripts/tools/netdata_uninstall.sh
```
