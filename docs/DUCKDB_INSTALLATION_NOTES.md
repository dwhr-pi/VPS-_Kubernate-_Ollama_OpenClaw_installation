# DuckDB Installation Notes

## Warum `apt install duckdb` fehlschlagen kann

Ubuntu 24.04/Noble liefert in den Standard-Repositories kein offizielles Paket mit dem Namen `duckdb`.
Der Fehler

```text
E: Unable to locate package duckdb
```

ist deshalb kein lokaler Defekt des Systems, sondern ein falscher Installationspfad.

## Stabiler Installationspfad im Setup

Das Ultimate KI Setup installiert DuckDB deshalb ueber das offizielle GitHub-Release-Binary:

```bash
bash scripts/tools/duckdb_install.sh
```

Der Installer verwendet standardmaessig:

```text
Quelle: https://github.com/duckdb/duckdb
Release: v1.1.3
Ziel: /opt/duckdb
Symlink: /usr/local/bin/duckdb
```

Der Installer benoetigt `curl` und `unzip`. Falls diese Werkzeuge fehlen, installiert das Setup sie vor dem Download automatisch ueber `apt`.

Die Version kann bewusst ueberschrieben werden:

```bash
DUCKDB_VERSION=v1.1.3 bash scripts/tools/duckdb_install.sh
```

## Vorab pruefen

```bash
bash scripts/tools/duckdb_install.sh --check
bash scripts/tools/duckdb_install.sh --dry-run
```

## Ressourcenbedarf

DuckDB ist ein leichtes lokales Analysewerkzeug.

| Bereich | Empfehlung |
| --- | --- |
| RAM | 1 GB Minimum, 4 GB+ fuer groessere Tabellen |
| Speicher | wenige 100 MB fuer Binary, zusaetzlich Platz fuer Datenbanken |
| Ports | keine |
| Docker | nicht erforderlich |
| WSL2 | geeignet, aber Datenbanken besser im Linux-Dateisystem statt auf langsamen Windows-Mounts speichern |

## Deinstallation

```bash
bash scripts/tools/duckdb_uninstall.sh
```

Lokale `.duckdb`-Datenbanken werden dabei nicht geloescht.
