# database_backend

## Zweck

Stellt relationale, Key-Value-, Objekt- und Plattform-Backends für Agenten, UI, Monitoring und RAG bereit.

## Use Cases

- Postgres für strukturierte Daten
- Redis für Queue/State
- MinIO für Artefakte
- Supabase für Auth/Realtime/Storage

## Enthaltene Tools

- `Postgres`
- `Redis`
- `MinIO`
- `Supabase`

## Installation

```bash
scripts/tools/postgres_install.sh
scripts/tools/redis_install.sh
scripts/tools/minio_install.sh
scripts/tools/supabase_install.sh
```

## Ports

- `5432` Postgres
- `6379` Redis
- `9000` MinIO API
- `9001` MinIO Console

## Modelle

- keine

## Abhängigkeiten

- Docker für MinIO und Supabase
- Volumes und Backups

## Ressourcenverbrauch (CPU / RAM / Storage)

- CPU: niedrig bis mittel
- RAM: ab 8-16 GB
- Storage: stark datenabhängig

## Sicherheitshinweise

- Default-Passwörter sofort ändern
- Storage nicht ungeschützt ins Netz stellen

## Start / Stop / Status Befehle

```bash
sudo systemctl status postgresql || true
docker ps
```

## Test-Command

```bash
pg_isready || true
```

## Deinstallation

```bash
scripts/tools/postgres_uninstall.sh
scripts/tools/redis_uninstall.sh
scripts/tools/minio_uninstall.sh
scripts/tools/supabase_uninstall.sh
```
