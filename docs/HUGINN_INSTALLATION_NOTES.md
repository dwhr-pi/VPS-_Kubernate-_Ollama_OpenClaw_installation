# Huginn Installation Notes

## Warum die Installation bei `mysql2` stoppen kann

Huginn ist eine Rails-Anwendung und braucht eine Datenbank. In diesem Setup ist
`mysql2` ein unterstuetzter Pfad, aber ein lokaler MySQL-/MariaDB-Dienst wird
nicht heimlich installiert, weil dabei ein dauerhaft laufender Datenbankdienst
entsteht.

Typischer Fehler:

```text
Huginn ist auf mysql2 konfiguriert, aber lokal ist aktuell kein erreichbarer MySQL-/MariaDB-Dienst verfügbar.
Erwarteter Socket: /var/run/mysqld/mysqld.sock
```

## Neuer Preflight

Der Installer prueft die lokale Datenbank jetzt direkt nach der `.env`-
Vorbereitung und vor dem langen Bundler-Schritt. Dadurch scheitert Huginn nicht
erst nach vielen Ruby-Gems, wenn die Datenbank ohnehin fehlt.

## Sichere Optionen

### Option 1: Lokale MariaDB bewusst vom Installer vorbereiten lassen

```bash
HUGINN_AUTO_INSTALL_LOCAL_DB=true bash scripts/tools/huginn_install.sh
```

Das installiert `mariadb-server`, startet den Dienst und legt Datenbank sowie
Benutzer anhand der Werte in `/opt/huginn/.env` an.

### Option 2: Externe Datenbank verwenden

In `/opt/huginn/.env`:

```env
DATABASE_ADAPTER=mysql2
DATABASE_HOST=DB_HOST_PLACEHOLDER
DATABASE_PORT=3306
DATABASE_NAME=huginn_production
DATABASE_USERNAME=huginn
DATABASE_PASSWORD=CHANGE_ME_OUTSIDE_REPO
```

### Option 3: PostgreSQL verwenden

```bash
HUGINN_DATABASE_ADAPTER=postgresql bash scripts/tools/huginn_install.sh
```

Der PostgreSQL-Pfad wird vom Installer ebenfalls vorbereitet, wenn ein lokaler
PostgreSQL-Dienst genutzt wird.

## Sicherheit

- Keine Datenbankpasswoerter ins Repo schreiben.
- Produktive Werte gehoeren in den Benutzer-Workspace oder nach `/opt/huginn/.env`.
- Huginn-Web nur lokal binden oder hinter VPN/Reverse Proxy mit Auth verwenden.
- Webhooks und Agenten koennen sensible Daten verarbeiten; Secrets gehoeren nicht
  in Szenarien, Logs oder Markdown-Beispiele.

