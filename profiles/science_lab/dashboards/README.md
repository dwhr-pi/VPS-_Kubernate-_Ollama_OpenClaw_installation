# Wissenschaftliche Dashboards

Dieser Ordner ist der gemeinsame Startpunkt fuer Science-Lab-Dashboards.

Empfohlene Metriken:

- GPU-Auslastung, VRAM, Temperatur und Stromaufnahme
- JupyterLab- und Batchjob-Laufzeiten
- Speicherverbrauch pro Profil und Projekt
- Kubernetes-Queue, Node-Status und Jobstatus
- Laborwerte aus Home Assistant, MQTT oder CSV-Import
- Paper-/PDF-Auswertungsstatus und Report-Status

Stabile Basis:

- Grafana fuer Visualisierung
- Prometheus fuer Metriken
- JSONL/CSV/SQLite fuer einfache lokale Messdaten

Optional:

- InfluxDB fuer Zeitreihen
- Node-RED oder n8n fuer Sensor- und Workflow-Automation
- Kubernetes-Dashboards fuer verteilte GPU-/CPU-Jobs
