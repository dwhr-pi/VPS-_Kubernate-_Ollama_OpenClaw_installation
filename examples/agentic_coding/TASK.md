# Uebungsauftrag: Kontaktfilter

Status: Beispielvorlage, keine ausfuehrbare Queue und kein fertig erstelltes CRM.
Nur synthetische Daten verwenden. Vor Start Arbeitsrepo und Bearbeitungsbereich
konkret festlegen; kein Zugriff auf das echte HR-/Vertriebssystem.

## Ziel und Testfaelle

Eine vorhandene Kontaktliste soll nach dem Feld `company` gefiltert werden.
Keine neue Datenbank, kein Webscraping, kein Login oder Netzwerk erforderlich.
Die Liste wird nicht veraendert; Reihenfolge der Treffer bleibt erhalten.

| Eingabe | Erwartung |
|---|---|
| Suchtext leer oder nur Leerzeichen | alle vorhandenen Kontakte |
| `acme`, Firma `ACME Test` | Treffer ohne Beachtung von Gross-/Kleinschreibung |
| Suchtext mit Rand-Leerzeichen | wie getrimmter Suchtext |
| `buerger`, Firma `Buerger Test` | Treffer; keine unvereinbarte Umlaut-Transliteration |
| Firmenwert fehlt oder ist null | leere Suche behaelt den Kontakt; nichtleere Suche kein Treffer |
| zwei Treffer | urspruengliche Reihenfolge |
| keine Treffer | leere Liste |

## Vorab ausfuellen

- Freigegebenes Arbeitsrepo und Basis-Commit: vom Betreiber einzutragen.
- Erlaubte Implementierungs-/Testdateien: vom Betreiber einzutragen.
- Exakt genehmigter Testbefehl und Laufzeit: vom Betreiber einzutragen.
- Schreibfreigabe: zunaechst nein, nur Analyse/Plan.
- Keine Dependencies, Secrets, Netzwerk-, Wallet-, WSL- oder Service-Aenderungen.
- Maximal drei Korrekturrunden, zehn Schritte, zehn Minuten, ein Job.
- Kein Commit/Push/Deployment ohne weitere Freigabe.

Ein Agent muss stoppen, solange Repo, Dateien oder Testbefehl nicht festgelegt
sind. Die Vorlage setzt diese Grenzen nicht technisch durch.

## Abgabe

Geaenderte Dateien, Diff-Erklaerung, wirklich ausgefuehrte Tests mit Exit-Codes
und offene Risiken berichten. Keine Tests abschwaechen, um Gruen zu erzwingen.
Fuer ein echtes CRM zusaetzlich Mandantentrennung/Berechtigungen unabhaengig
testen; diese Uebung implementiert noch kein sicheres Mehrbenutzersystem.
