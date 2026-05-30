# Mailserver AI Assistant

Der Mailserver AI Assistant nutzt Stalwart Mail als Kern und OpenClaw/Ollama als
Assistenzschicht.

## Funktionen

- Mailboxen vorschlagen
- Aliase vorschlagen
- DNS pruefen
- eingehende Mails zusammenfassen
- Antwortentwuerfe erstellen
- Spam-/Phishing-Risiko markieren

## Nicht erlaubt

- automatisch senden
- offenes Relay
- Catch-all ohne Freigabe
- Passwoerter oder DKIM Private Keys anzeigen

Details: `tools/mail/README.md`

## Next Improvements: Mail AI Operations

- Stalwart bleibt Mailserver-Kern; KI-Schicht erstellt nur Entwuerfe und Regeln mit Freigabe.
- Nie automatisch senden, loeschen oder weiterleiten ohne Regel/Freigabe.
- DKIM/SPF/DMARC/PTR/rDNS und Rate-Limits sind Pflicht fuer produktiven Betrieb.
- Backups muessen Restore-Test enthalten, nicht nur Backup-Lauf.
