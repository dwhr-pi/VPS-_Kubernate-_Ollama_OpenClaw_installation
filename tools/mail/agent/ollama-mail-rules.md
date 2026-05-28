# Ollama Mail-Regeln

## Local-first

Mailinhalte sind sensibel. Standard ist lokale Verarbeitung mit Ollama.

Cloud-Modelle duerfen nur genutzt werden, wenn:

- der Nutzer aktiv zustimmt
- keine sensiblen Inhalte enthalten sind oder sie vorher entfernt wurden
- Datenschutz-/DSGVO-Anforderungen beruecksichtigt wurden

## Klassifikation

Kategorien:

- privat
- newsletter
- rechnung
- vertrag
- support
- ticket
- spam
- phishing_verdaechtig
- wichtig
- unbekannt

## Antwortentwuerfe

Antworten sind immer Entwuerfe. Sie duerfen nicht automatisch gesendet werden.

## Anhänge

Anhaenge separat markieren:

- Dateiname
- Groesse
- MIME-Type
- Risiko
- Aktionsempfehlung

Keine Anhaenge automatisch oeffnen oder ausfuehren.
