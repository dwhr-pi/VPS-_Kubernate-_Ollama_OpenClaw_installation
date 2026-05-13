# Deutsche Huginn-Vorlage: Rechnungen, Termine und wichtige Mails

Diese Vorlage ist fuer einen **wirklich nuetzlichen ersten Mail-Workflow** gedacht.

## Ziel

Huginn soll:

- neue Mails aus einem IMAP-Ordner holen
- nur wichtige Mails erkennen
- daraus saubere Events bauen
- und dich sofort oder gesammelt informieren

## Agent-Kette

1. `IMAP Folder Agent`
2. `Trigger Agent`
3. `Event Formatting Agent`
4. optional:
   - `Email Agent`
   - `Email Digest Agent`

## Filter-Idee

Relevante Mails:

- Rechnungen
- Termine
- Versandbestaetigungen
- Mahnungen
- Support- oder Wartungsmails

## Trigger-Beispiel

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

## Aufbereitungs-Beispiel

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

## Wichtiger Hinweis

Die echten Feldnamen aus dem `IMAP Folder Agent` solltest du nach dem ersten Test immer auf der `Events`-Seite pruefen.

Typische Felder sind:

- `subject`
- `from`
- `body`
- `text`

Wenn `body` leer ist, passe den Workflow auf den real vorhandenen Feldnamen an.
