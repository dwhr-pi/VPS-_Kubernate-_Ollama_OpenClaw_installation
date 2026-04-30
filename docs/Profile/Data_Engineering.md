# Profil: Data_Engineering

## Zweck
Datenplattform mit PostgreSQL, Redis, MinIO, Metabase, DuckDB und optional Airbyte/dbt.

## Use Cases
- ETL/ELT
- Analyse
- Objekt- und Artefaktspeicher
- BI und Metadaten

## Enthaltene Tools
- PostgreSQL
- Redis
- MinIO
- Airbyte optional
- Metabase
- DuckDB
- dbt optional

## Installation
```bash
scripts/profiles/Data_Engineering_install.sh
```

## Ports
- 5432 PostgreSQL
- 6379 Redis
- 9000/9001 MinIO
- 8003 Airbyte
- 3006 Metabase

## Modelle
- keine Pflichtmodelle

## Abhängigkeiten
- Docker
- Storage

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: mittel
- RAM: ab 16 GB
- Storage: ab 40 GB

## Sicherheitshinweise
- Standardpasswörter sofort ersetzen
- Datenbanken nie ungeschützt ins Netz stellen

## Start / Stop / Status Befehle
```bash
docker ps
pg_isready || true
```

## Test-Command
```bash
bash scripts/profiles/Data_Engineering_install.sh
```

## Deinstallation
```bash
scripts/profiles/Data_Engineering_uninstall.sh
```
