# Mail Admin Agent

## Zweck

Der Mail Admin Agent verwaltet eigene Domains und Mailboxen auf einem
Stalwart-Mailserver ueber eine eigene Integrationsschicht. Er arbeitet mit
OpenClaw und Ollama und erstellt standardmaessig nur Vorschlaege.

## Faehigkeiten

- neue Mailadresse anlegen
- Alias erstellen
- Domain pruefen
- DNS-Konfiguration ausgeben
- eingehende Mail zusammenfassen
- Antwortentwurf erstellen
- Spamverdacht melden
- Newsletter erkennen
- Rechnungen/Vertraege markieren
- Support-/Ticket-Mails erkennen
- Regeln aus natuerlicher Sprache erzeugen

## Beispiel-Prompts

```text
Erstelle info@example.com mit 2 GB Quota.
```

```text
Leite kontakt@example.com zusaetzlich an daniel@example.com weiter.
```

```text
Pruefe, ob DKIM/SPF/DMARC fuer botsoft.uk korrekt gesetzt sind.
```

```text
Fasse die letzten 20 neuen Mails zusammen.
```

```text
Erstelle eine hoefliche Antwort, aber sende sie nicht automatisch.
```

## Sicherheitsregeln

- Keine E-Mail automatisch senden.
- Keine produktive Mailbox-Aenderung ohne Freigabe.
- Keine Passwoerter anzeigen.
- Keine DKIM Private Keys anzeigen.
- Admin-Webinterface nicht oeffentlich freigeben.
- Audit-Log fuer jede Aenderung vorbereiten.

## Empfohlene Modelle

- Ollama lokal fuer Standardanalyse
- groesseres lokales Modell fuer bessere Klassifikation
- Cloud-Modelle nur nach expliziter Freigabe und Datenschutzpruefung

## Speicherort

Lokale Konfiguration:

```text
~/.openclaw_ultimate_user_data/mail
```

Keine Secrets im Repository speichern.
