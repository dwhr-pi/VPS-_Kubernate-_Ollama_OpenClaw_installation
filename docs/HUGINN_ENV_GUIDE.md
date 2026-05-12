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
- `INVITATION_CODE` sollte nicht auf dem unsicheren Huginn-Default `try-huginn` bleiben.
  Wenn der Wert leer ist oder noch auf `try-huginn` steht, erzeugt das Setup jetzt automatisch einen lokalen Zufallscode.
- Fuer die Datenbank braucht Huginn mindestens:
  - `DATABASE_ADAPTER`
  - `DATABASE_NAME`
  - bei `postgresql` oder `mysql2` auch `DATABASE_USERNAME` und `DATABASE_PASSWORD`
- Fuer lokale Setups ist `APP_HOST=127.0.0.1` ein guter Default.

## Invitation Code und erster Benutzer

Huginn liest den Registrierungs-Code direkt aus `/opt/huginn/.env`:

```bash
grep '^INVITATION_CODE=' /opt/huginn/.env
```

Wenn du bewusst einen neuen Code setzen willst:

```bash
new_code="$(openssl rand -hex 12)"
sed -i "s/^INVITATION_CODE=.*/INVITATION_CODE=${new_code}/" /opt/huginn/.env
printf 'Neuer Huginn Invitation Code: %s\n' "$new_code"
```

Wenn du den ersten Admin lieber direkt im Terminal statt ueber die Web-Registrierung anlegen willst, geht das ohne Invitation Code so:

```bash
cd /opt/huginn
RAILS_ENV=production bundle exec rails runner "u=User.new(username: 'admin', email: 'admin@example.com', password: 'change-me-now', password_confirmation: 'change-me-now', admin: true); u.requires_no_invitation_code!; u.save!"
```

Danach solltest du das Passwort sofort auf einen eigenen sicheren Wert aendern.

## Freigabe nach aussen

Die Huginn-Weboberflaeche sollte nicht roh ins Internet gestellt werden.

Empfohlen:

- lokal oder nur im privaten Netz testen
- fuer Admin-Zugriff bevorzugt `Tailscale`
- fuer oeffentliche Freigaben nur ueber abgesicherten Reverse Proxy oder Cloudflare Tunnel

## Bezug zum Installer

Der Huginn-Installer nutzt diese Vorlage, wenn `/opt/huginn/.env` noch nicht existiert.
Wenn die Runtime-Datei schon existiert, bleibt sie unberuehrt, bis du sie bewusst ueber den Huginn-Konfigurationseditor ersetzt.
