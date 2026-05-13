# Huginn Mail-Workflows auf Deutsch

Diese Datei sammelt **alltagstaugliche deutsche Vorlagen** fuer Mail-Workflows in Huginn.

Der Fokus liegt bewusst auf einfachen, robusten Bausteinen, die sowohl fuer den stabilen Stand `v2022.08.18` als auch als Ausgangspunkt fuer `main` geeignet sind.

## Vorbemerkung

Huginn ist fuer Mail **nicht auf Gmail beschraenkt**.

Sinnvolle Grundtrennung:

- **eingehende Mails** ueber `IMAP Folder Agent`
- **Filterlogik** ueber `Trigger Agent`
- **Aufbereitung** ueber `Event Formatting Agent`
- **Benachrichtigung oder Zusammenfassung** ueber `Email Agent` oder `Email Digest Agent`

Ausgehende Mails brauchen die `SMTP_*`-Werte in der Huginn-`.env`.

## Alltagsvorlage 1: Rechnungen, Termine und wichtige Benachrichtigungen

### Ziel

Huginn soll:

- neue Mails aus einem bestimmten Postfach oder Ordner holen
- nur wichtige Mails erkennen
- daraus saubere Ereignisse erzeugen
- dich sofort oder gesammelt informieren

### Typische Quellen

- Rechnungen
- Versand- und Bestellbestaetigungen
- Terminmails
- Wartungs- oder Systemmeldungen
- Support- oder Vertragsmails

## Empfohlene Agent-Kette

1. `IMAP Folder Agent`
2. `Trigger Agent`
3. `Event Formatting Agent`
4. optional:
   - `Email Agent` fuer sofortige Einzelbenachrichtigung
   - `Email Digest Agent` fuer taegliche Sammelmails

## 1. IMAP Folder Agent

Offizielle Huginn-Beschreibung:
- Der `IMAP Folder Agent` prueft einen IMAP-Server in angegebenen Ordnern und erzeugt Events fuer neue Mails.  
Quelle: [Huginn Wiki: Agent Types & Descriptions](https://github-wiki-see.page/m/huginn/huginn/wiki/Agent-Types-%26-Descriptions)

### Typische Einstellidee

Trage dort sinngemaess die Daten deines Mailanbieters ein:

- IMAP-Server
- Benutzername
- Passwort oder App-Passwort
- SSL/TLS aktiv
- zu ueberwachender Ordner

Typische Ordner:

- `INBOX`
- `INBOX/Rechnungen`
- `INBOX/Wichtig`
- provider-spezifische Unterordner

### Empfehlung

Wenn moeglich:

- zuerst einen **eigenen Mailordner** nur fuer relevante Mails nutzen
- oder serverseitig bereits vorsortieren lassen

Das reduziert die spaetere Filterlogik in Huginn deutlich.

## 2. Trigger Agent

Der `Trigger Agent` filtert aus den eingehenden Mail-Events nur die wirklich wichtigen Faelle.

Offizielle Huginn-Beschreibung:
- Der `Trigger Agent` prueft Regeln aus `path`, `value` und `type` gegen eingehende Event-Felder.  
Quelle: [Huginn Wiki: Agent Types & Descriptions](https://github-wiki-see.page/m/huginn/huginn/wiki/Agent-Types-%26-Descriptions)

### Wichtiger Praxishinweis

Je nach Huginn-Stand und Mailinhalt koennen die Event-Felder leicht variieren.

Typische Kandidaten sind:

- `subject`
- `from`
- `to`
- `body`
- `text`

Pruefe deshalb nach dem ersten IMAP-Test immer erst auf der `Events`-Seite, **wie dein IMAP-Event wirklich aussieht**.

### Beispiel-Regel fuer wichtige Mails

Diese Variante geht davon aus, dass ein Feld `subject` vorhanden ist:

```json
{
  "expected_receive_period_in_days": "2",
  "keep_event": "true",
  "rules": [
    {
      "type": "regex",
      "path": "subject",
      "value": "(Rechnung|Invoice|Termin|Bestellung|Mahnung|Wartung|Support)"
    }
  ],
  "message": "Wichtige Mail erkannt: {{subject}}"
}
```

Wenn du lieber ueber Absender filterst, kannst du stattdessen `path: "from"` verwenden.

## 3. Event Formatting Agent

Der `Event Formatting Agent` macht aus dem oft unruhigen Mail-Event ein sauberes Arbeitsformat fuer spaetere Benachrichtigungen oder Automationen.

Offizielle Huginn-Beschreibung:
- Der `Event Formatting Agent` formatiert eingehende Events und fuegt bei Bedarf neue Felder hinzu.  
Quelle: [Huginn Wiki: Agent Types & Descriptions](https://github-wiki-see.page/m/huginn/huginn/wiki/Agent-Types-%26-Descriptions)

### Beispielhafte deutsche Aufbereitung

```json
{
  "instructions": {
    "workflow": "mail_prioritaet",
    "headline": "{{subject}}",
    "absender": "{{from}}",
    "kurzinfo": "Wichtige Mail erkannt: {{subject}}",
    "quelle": "imap_mail",
    "rohtext": "{{body | truncate: 500}}"
  },
  "mode": "clean"
}
```

Hinweis:

- Falls `body` in deinem Event nicht existiert, teste stattdessen `text` oder den echten Feldnamen aus dem Event.

## 4A. Sofortige Einzelbenachrichtigung mit Email Agent

Offizielle Huginn-Beschreibung:
- Der `Email Agent` sendet eingehende Events sofort per E-Mail.  
Quelle: [Huginn Wiki: Agent Types & Descriptions](https://github-wiki-see.page/m/huginn/huginn/wiki/Agent-Types-%26-Descriptions)

### Beispiel

```json
{
  "subject": "Huginn Mail-Alarm: {{headline}}",
  "headline": "{{kurzinfo}}",
  "expected_receive_period_in_days": "2"
}
```

Gut fuer:

- Wartungswarnungen
- Sicherheitsmails
- dringende Rechnungen

## 4B. Taegliche Sammelmail mit Email Digest Agent

Offizielle Huginn-Beschreibung:
- Der `Email Digest Agent` sammelt Events und sendet sie nach Zeitplan gebuendelt per Mail.  
Quelle: [Huginn Wiki: Agent Types & Descriptions](https://github-wiki-see.page/m/huginn/huginn/wiki/Agent-Types-%26-Descriptions)

### Einsatzidee

Nutze ihn zum Beispiel fuer:

- taegliche Rechnungszusammenfassung
- taegliche Terminzusammenfassung
- Abenddigest aller wichtigen Eingaenge

### Praxis

Der `Email Digest Agent` ist besonders sinnvoll, wenn du nicht fuer jede einzelne Mail sofort eine neue Benachrichtigung willst.

## Konkrete Reihenfolge im Alltag

1. richte in deinem Mailanbieter einen separaten Ordner ein, z. B. `Wichtig fuer Huginn`
2. lasse dort per Serverregel Rechnungen, Termine oder wichtige Benachrichtigungen einsortieren
3. verbinde den `IMAP Folder Agent` mit genau diesem Ordner
4. pruefe auf der `Events`-Seite die echten Feldnamen
5. passe danach `Trigger Agent` und `Event Formatting Agent` an
6. entscheide, ob du sofortige Mails (`Email Agent`) oder einen Sammeldigest (`Email Digest Agent`) willst

## Warum dieser Workflow alltagstauglich ist

Er ist sinnvoll, weil er nicht nur ein Test-Agent bleibt, sondern sofort konkrete Arbeit spart:

- weniger manuelles Durchsehen von Mails
- schnellere Sicht auf wichtige Post
- vorbereitete Events fuer spaetere Automationen

Spaetere Ausbaustufen:

- Rechnungen zusaetzlich nach Anbieter unterscheiden
- Terminmails an Kalender-Workflows weitergeben
- wichtige Mails an Telegram, Slack oder Home Assistant melden
- Mails zusaetzlich in Dateien, Datenbanken oder Tickets ueberfuehren
