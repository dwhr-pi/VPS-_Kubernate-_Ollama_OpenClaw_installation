# Profil: Data_Analytics_BI

## Zweck
Analyse- und BI-Profil für DuckDB, Jupyter, Metabase und Reports.

## Use Cases
- Datenanalyse
- lokale Notebooks
- Reports
- Dashboards

## Enthaltene Tools
- DuckDB
- JupyterLab
- Metabase
- Grafana
- Airbyte optional
- dbt optional

## Installation
```bash
scripts/profiles/Data_Analytics_BI_install.sh
```

## Ports
- 3001
- 3006

## Modelle
- optionale lokale Analysemodelle

## Abhängigkeiten
- Python

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: mittel
- RAM: 12 GB+
- Storage: 20 GB+

## Sicherheitshinweise
- Notebook-Daten und Dashboards absichern

## Start / Stop / Status Befehle
```bash
docker ps
```

## Test-Command
```bash
bash scripts/profiles/Data_Analytics_BI_install.sh
```

## Deinstallation
```bash
scripts/profiles/Data_Analytics_BI_uninstall.sh
```
