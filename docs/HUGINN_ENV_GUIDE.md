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

## Erster Funktionstest im Webinterface

Ein sehr einfacher erster Test ist ein `Manual Event Agent`.

1. Oeffne `Agents`.
2. Klicke `New Agent`.
3. Waehle `Manual Event Agent`.
4. Vergib einen Namen, z. B. `Erster Test`.
5. Trage als Optionen zum Beispiel ein:

```json
{
  "payload": {
    "message": "Hallo aus meinem ersten Huginn-Test",
    "source": "manual_test"
  }
}
```

6. Speichere den Agenten.

Wichtig:

- Bei diesem Agententyp gibt es je nach Huginn-Oberflaeche nicht immer einen auffaelligen `Run`-Button.
- Beim `Manual Event Agent` wird auf der Detailseite stattdessen ein eigenes Formular mit einem `Submit`-Button verwendet.
- Dort kann direkt ein JSON-Event eingetragen und abgesendet werden, zum Beispiel:

```json
{
  "message": "Hallo aus meinem ersten Huginn-Test",
  "source": "manual_test"
}
```

- Wenn mehrere Test-Events auf einmal erzeugt werden sollen, kann auf der Detailseite stattdessen ein Top-Level-Schluessel `payloads` mit einem Array von Objekten verwendet werden.
- Der einfachste Erfolgsindikator ist, dass beim Agenten in der Liste oder Detailansicht die Anzahl der `Events` hochgeht.
- Wenn dort bereits `2` oder mehr Events stehen, hat der Test im Kern schon funktioniert.

Danach kannst du in der Agent-Detailansicht oder ueber `Events` pruefen, ob Nutzdaten wie diese sichtbar sind:

- `message: Hallo aus meinem ersten Huginn-Test`
- `source: manual_test`

## Erste funktionierende Agent-Kette

Ein guter zweiter Test ist eine kleine Kette aus:

1. `Manual Event Agent`
2. `Event Formatting Agent`

Beispiel fuer den `Event Formatting Agent`:

```json
{
  "instructions": {
    "message": "Nachricht: {{ message }}",
    "origin": "{{ source }}"
  },
  "mode": "clean"
}
```

Wichtig:

- Der `Manual Event Agent` muss den `Event Formatting Agent` als Empfaenger gesetzt haben.
- Beim `Event Formatting Agent` sollte `Propagate immediately` auf `Yes` stehen.
- Fuer die echte Verarbeitung reicht der Webserver allein nicht aus. Huginn braucht zusaetzlich einen laufenden Worker-Prozess.

Wenn danach beim `Event Formatting Agent` `Last received event` und `Events created` hochgehen, funktioniert die Agent-Kette.

## Huginn lokal starten

Fuer einen funktionierenden lokalen Betrieb auf diesem Setup werden zwei Prozesse gebraucht:

### 1. Webserver

```bash
cd /opt/huginn
RAILS_ENV=production RAILS_SERVE_STATIC_FILES=1 bundle exec rails server -b 127.0.0.1 -p 3000
```

### 2. Worker

```bash
cd /opt/huginn
RAILS_ENV=production bundle exec rails runner bin/threaded.rb
```

Ohne den Worker werden Events oft nur in die Queue gelegt, aber nicht weiterverarbeitet. Typische Symptome sind:

- Agenten erzeugen zwar Events
- verbundene Empfaenger-Agenten erhalten aber nichts
- `Last received event` bleibt auf `never`
- Job-Eintraege erscheinen, werden aber nicht sauber abgearbeitet

## Freigabe nach aussen

Die Huginn-Weboberflaeche sollte nicht roh ins Internet gestellt werden.

Empfohlen:

- lokal oder nur im privaten Netz testen
- fuer Admin-Zugriff bevorzugt `Tailscale`
- fuer oeffentliche Freigaben nur ueber abgesicherten Reverse Proxy oder Cloudflare Tunnel

## Bezug zum Installer

Der Huginn-Installer nutzt diese Vorlage, wenn `/opt/huginn/.env` noch nicht existiert.
Wenn die Runtime-Datei schon existiert, bleibt sie unberuehrt, bis du sie bewusst ueber den Huginn-Konfigurationseditor ersetzt.
