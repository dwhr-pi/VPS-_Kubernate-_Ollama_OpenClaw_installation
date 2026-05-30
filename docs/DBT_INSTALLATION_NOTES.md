# dbt Installation Notes

## Fehlerbild

Wenn der Installer den Root des GitHub-Repositories `dbt-labs/dbt-core` direkt per `pip install -e /opt/dbt_core` installiert, kann setuptools abbrechen:

```text
Multiple top-level packages discovered in a flat-layout: ['core', 'docker', 'schemas']
```

Das ist kein Speicher- oder Python-Problem. Es ist ein falscher Installationspfad.

## Ursache

`dbt-core` ist im Repository-Unterordner `core` paketiert. Der Repository-Root enthaelt mehrere Top-Level-Verzeichnisse und darf nicht als Python-Paket installiert werden.

## Korrektur im Setup

Der Installer `scripts/tools/dbt_install.sh` klont weiterhin die Primaerquelle von GitHub:

```text
https://github.com/dbt-labs/dbt-core.git
```

Installiert wird aber gezielt:

```bash
pip install -e /opt/dbt_core/core
```

## Adapter-Hinweis

`dbt-core` allein reicht fuer viele reale Projekte nicht. Je nach Zielsystem wird ein Adapter benoetigt, z. B.:

- `dbt-postgres`
- `dbt-duckdb`
- `dbt-bigquery`
- `dbt-snowflake`

Diese Adapter werden nicht automatisch installiert, weil sie vom Projekt, den Datenbanken und moeglichen Secrets abhaengen.

## Test

```bash
/opt/dbt_core/.venv/bin/dbt --version
```

