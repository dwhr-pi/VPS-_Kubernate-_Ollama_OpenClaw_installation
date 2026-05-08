# Huginn `.env` Guide

Diese Datei erklaert, **wo** die Huginn-`.env` in diesem Setup gepflegt wird und **wie** sie sicher bearbeitet werden soll.

## Pfade

- Bearbeitbare Vorlage im Benutzer-Workspace:
  `~/.openclaw_ultimate_user_data/huginn/.env.template`
- Runtime-Datei der Huginn-Installation:
  `/opt/huginn/.env`
- Repo-Vorlage:
  `scripts/config_templates/huginn/.env.template`

## Empfohlener Workflow

1. Oeffne im Setup unter `Optionen` den Punkt `Huginn Konfiguration (.env Vorlage)`.
2. Bearbeite dort die Vorlage im Benutzer-Workspace.
3. Wende die Vorlage bewusst auf `/opt/huginn/.env` an.

Dadurch bleiben deine Anpassungen ausserhalb des Git-Repositories und ueberstehen Setup-Updates deutlich sauberer.

## Was ist wichtig?

- `APP_SECRET_TOKEN` sollte gesetzt sein.
  Wenn der Wert leer bleibt, erzeugt das Setup bei der Installation einen lokalen Secret-Token.
- Fuer die Datenbank braucht Huginn mindestens:
  - `DATABASE_ADAPTER`
  - `DATABASE_NAME`
  - bei `postgresql` oder `mysql2` auch `DATABASE_USERNAME` und `DATABASE_PASSWORD`
- Fuer lokale Setups ist `APP_HOST=127.0.0.1` ein guter Default.

## Freigabe nach aussen

Die Huginn-Weboberflaeche sollte nicht roh ins Internet gestellt werden.

Empfohlen:

- lokal oder nur im privaten Netz testen
- fuer Admin-Zugriff bevorzugt `Tailscale`
- fuer oeffentliche Freigaben nur ueber abgesicherten Reverse Proxy oder Cloudflare Tunnel

## Bezug zum Installer

Der Huginn-Installer nutzt diese Vorlage, wenn `/opt/huginn/.env` noch nicht existiert.
Wenn die Runtime-Datei schon existiert, bleibt sie unberuehrt, bis du sie bewusst ueber den Huginn-Konfigurationseditor ersetzt.
