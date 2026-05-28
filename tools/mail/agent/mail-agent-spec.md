# Mail Agent Spezifikation

Der Mail Agent ist eine Integrationsschicht fuer OpenClaw/Ollama. Er verwaltet
keinen Stalwart-Core-Code direkt, sondern spricht spaeter ueber eine gekapselte
API-Schicht mit Stalwart.

## Ziele

- Mailboxen vorbereiten, erstellen, sperren, loeschen
- Aliase und Weiterleitungen verwalten
- Domains und DNS pruefen
- Quotas setzen
- Passwortwechsel vorbereiten
- Web.de/GMX per IMAP importieren
- eingehende Mails klassifizieren
- Antwortentwuerfe erstellen
- Spam-/Phishing-Risiken markieren
- Audit-Log fuer alle Aenderungen schreiben

## Rollen

| Rolle | Rechte |
|---|---|
| Admin | alle Domains und Mailboxen verwalten |
| Domain-Admin | eigene Domain verwalten |
| User | eigene Mailbox, Aliase und Regeln sehen |
| KI-Agent | nur Vorschlaege, Entwuerfe und vorbereitete Aktionen |

## Sicherheitsregeln

- KI-Agent sendet niemals automatisch.
- Produktive Aenderungen brauchen Freigabe.
- Passwoerter werden nicht geloggt.
- DKIM Private Keys werden nicht gelesen oder angezeigt.
- Anhaenge werden separat markiert.
- Audit-Log enthaelt Aktion, Actor, Zeit, Zielobjekt und Ergebnis, aber keine
  unnoetigen Mailinhalte.

## Zielaktionen

```json
{
  "action": "create_mailbox",
  "domain": "example.tld",
  "local_part": "info",
  "quota_mb": 2048,
  "requires_approval": true
}
```

## Offene API-Punkte

Die konkrete Stalwart Management/JMAP/API-Version muss vor Implementierung
geprueft werden:

- Authentifizierung fuer Management API
- Domain-/Mailbox-Endpunkte
- Alias-/Forwarding-Endpunkte
- Quota-Endpunkte
- Audit-/Event-Logs
- IMAP-Import-Strategie
