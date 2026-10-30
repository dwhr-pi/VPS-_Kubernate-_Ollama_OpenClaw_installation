# Eigene lokale App statt Abo: Analyse, Steckbrief und Bau mit REA

**Ziel:** Aus den wenigen Funktionen, die du wirklich brauchst, eine eigene kleine Anwendung
entwickeln. Eigener Name, eigene Umsetzung, eigenes Design. Keine geschuetzte App kopieren oder
Lizenzpflichten umgehen. [REA und Installation](../tools/rea.md) sind ein optionales Hilfsmittel,
keine Voraussetzung fuer das Interview mit Screenshots.

## 1. Realistisch anfangen

Geeignet sind beispielsweise ein persoenlicher Habit-Tracker, Notizbuch, Aufgabenliste,
Zeiterfassung oder ein kleines Dashboard. Waehle drei bis fuenf Kernfunktionen statt ein ganzes
CRM/ERP nachbauen zu wollen. Abo-Kosten verschwinden nicht garantiert: Entwicklung, Tests, Updates,
Sicherheit, Backups und ggf. Modell-/API-Kosten bleiben. Ein bestaetigter Build bedeutet noch keine
zuverlaessige Alltagstauglichkeit.

| Phase               | Ergebnis                                                      | Freigabe                                  |
| ------------------- | ------------------------------------------------------------- | ----------------------------------------- |
| Berechtigung / Ziel | Eigene Anforderungen, rechtmaessig zugaengliche Beobachtungen | Keine fremden Konten oder Systeme pruefen |
| Funktionsanalyse    | steckbrief.md, offene Fragen, V1-Abgrenzung                   | Noch kein Code/REA-Toolaufruf             |
| Architektur         | Kleiner Plan, Datenmodell, Testfaelle                         | Erst danach Bau freigeben                 |
| Implementierung     | Eigener Code und Gestaltung                                   | Nur im neuen Projektordner                |
| Abnahme             | Gepruefte Ablaeufe, Export, Backup/Restore, Startanleitung    | Nicht automatisch veroeffentlichen        |

## 2. Vorbereitung und REA-Einordnung

1. Erstelle ausserhalb des Setup-Repos einen neuen Projektordner, etwa `meine-app`. Keine
   produktiven Dateien in diesen Ordner kopieren.
2. Verwende fuenf bis zehn selbst erstellte, bereinigte Screenshots und beschreibe deine konkreten
   Ablaeufe. Namen, E-Mails, Tokens, Kontostaende und andere personenbezogene Daten vorher entfernen
   oder durch Testdaten ersetzen.
3. Klaere, was du rechtmaessig ansehen/testen darfst. Dokumentiere den Umfang; ein bezahltes Konto
   erlaubt nicht automatisch jede Art von Analyse.
4. Fuer reine Anforderungen genuegt der Coding-Agent. REA nur fuer eine konkret begruendete und
   separat erlaubte Untersuchung heranziehen. Kein Debugger, MITM, Prozess-Anhaengen oder
   Dekompilieren als Standard.
5. [REA-Anleitung](../tools/rea.md) lesen: GitHub-Checkout, optionaler Build und manuelle
   MCP-Freigabe sind drei getrennte Schritte. Kein Docker erforderlich.

Ein MCP-Server kann wesentlich mehr Rechte erhalten als fuer diese Aufgabe noetig. Ziel-Allowlist,
beschraenkter Arbeitsordner, Testkonto und Tool-Freigaben nutzen. Keine Produktionszugangsdaten,
Wallets oder ENV-Tresor-Dateien in den Agentenkontext geben. Prompts sind kein technischer
Sandbox-Ersatz. Bei Cloud-Modellen werden auch Screenshots/Promptinhalte extern verarbeitet; lokale
Dateien bedeuten nicht automatisch lokale Inferenz.

## 3. Analyse-Prompt zum Kopieren

In Claude Code oder einem kompatiblen Coding-Agenten im neuen Projektordner:

```text
Ich nutze [Name der App] fuer [2 bis 5 Saetze zu meinen Ablaeufen].
Ich moechte eine eigene, lokale Anwendung fuer meinen Bedarf entwickeln.
In diesem Schritt nur Anforderungen verstehen, noch nichts bauen.

1. Sieh dir nur meine freigegebenen Screenshots und Beschreibungen an.
   Keine Secret-/ENV-Dateien lesen und keine Original-Server kontaktieren.
2. Interviewe mich in nummerierten Runden mit hoechstens 3 Fragen.
   Gib je Frage eine begruendete Empfehlung. Frage nur entscheidende Luecken.
3. Klaere Screens, Funktionen, Ablaeufe, Fehlerfaelle, gespeicherte Daten,
   Export, Backup/Restore, Offline-Bedarf und was ich bewusst nicht brauche.
4. Ohne separate Freigabe keine REA-Aufrufe. Falls noetig, schlage erst
   Ziel, Berechtigung, konkrete Operationen und Risiken vor.
   Keine Dekompilierung, Traffic-Aufnahme, Prozessanhaenge oder
   Umgehung von Login, Paywall, DRM oder Lizenzpruefungen.
5. Leite eine allgemeine Funktionsbeschreibung ab, keine Kopieranleitung
   fuer Code, Layout, Texte, Logos oder Assets des Originals.
6. Schreibe nach Klaerung steckbrief.md: eigene Ziele, Screens, Datenmodell,
   Ablaeufe, Akzeptanztests, V1, spaeter und offene Entscheidungen.
   Kennzeichne Annahmen und unbelegte Schlussfolgerungen.

Meine Beschreibung: [Beschreibung einfuegen].
```

Antworte beispielsweise mit "1 ja, 2 lokal, 3 spaeter". Bei einer unwichtigen Detailfrage kannst du
eine begruendete Annahme erlauben. Sicherheits- und Rechtefragen duerfen nicht einfach vom Agenten
wegentschieden werden.

Den Steckbrief aufbewahren: Ein neuer Chat kann ihn lesen; derselbe Chat ist bequem, aber keine
technische Voraussetzung. Keine Secrets als Gedächtnis in Markdown schreiben. Saubere Trennung:
Beobachtungen und Anforderungen zuerst, Implementierung danach. Das reduziert Kopierrisiken, ist
aber keine rechtliche Zertifizierung eines Clean-Room-Verfahrens.

## 4. Bau-Prompt zum Kopieren

Nach Pruefung des Steckbriefs:

```text
Lies steckbrief.md und den vorhandenen freigegebenen Kontext.
Entwickle daraus eine eigene lokale App, nicht eine Kopie des Originals.

Regeln:
- Eigener Code, eigene Marke, eigener Name und eigenes Layout.
- Keine Originaltexte, Logos, Bilder, Icons, Schriften oder Programmteile
  uebernehmen. Fremde Bausteine nur mit dokumentierter passender Lizenz.
- Keine Anmeldung, Paywall, Lizenzpruefung oder andere Schutzmassnahme umgehen.
- Keine fremden Server abgreifen; Daten nur aus meinem rechtmaessigen Export
  oder aus ausdruecklich freigegebenen Schnittstellen importieren.
- Nur V1 aus dem Steckbrief. Moeglichst wenig Abhaengigkeiten.
- Daten standardmaessig lokal, Preview nur auf 127.0.0.1.
- Keine Secrets im Code, kein automatisches Deployment, kein fremder API-Key.
- Nur im neuen Projektordner arbeiten. Keine WSL-/Systemaenderungen.

Ablauf:
1. Zeige einen kurzen Plan: Screens, Technik, Datenmodell und Testreihenfolge.
   Warte auf meine ausdrueckliche Freigabe.
2. Baue danach in kleinen Schritten. Teste Kernablaeufe und Fehlerfaelle.
   Hoechstens 3 Korrekturrunden je Problem, danach Diagnose statt Endlosschleife.
3. Pruefe Import/Export und eine echte Backup-Wiederherstellung mit Testdaten.
4. Liefere README.md, Lizenz-/Abhaengigkeitshinweise und docs/test-report.md.
   Erklaere Start, Stop, Updates, Backup und verbleibende Luecken einfach.
5. Nichts veroeffentlichen und kein Abo fuer mich kuendigen.
```

## 5. Beispiel: Kleine Aufgaben-App

| Bedarf            | Eigene Umsetzung                                  | Akzeptanztest                                |
| ----------------- | ------------------------------------------------- | -------------------------------------------- |
| Aufgabe mit Datum | Eigenes Formular, Titel und Termin                | Ungueltiges Datum wird abgefangen            |
| Liste filtern     | Eigene Filter fuer offen/erledigt                 | Filter zeigt korrekte Testdaten              |
| Erinnerung        | Explizit vereinbarte lokale Erinnerung            | Auch nach Neustart kontrolliert testen       |
| Daten behalten    | Kleine lokale Datenbank oder passende Dateiablage | Neustart behaelt Eintraege                   |
| Umziehen          | JSON-/CSV-Export und Import                       | Rundlauf ohne Datenverlust                   |
| Wiederherstellung | Geprueftes Backup                                 | Leeren Testbestand aus Backup rekonstruieren |

Nicht ungeprueft versprechen, eine Browser-App koenne ohne laufenden Prozess oder benoetigte
Betriebssystemfreigabe Erinnerungen zustellen. Mit Testdaten pruefen, was bei geschlossenem Browser,
Neustart und Offline-Modus passiert. Produktionsdaten erst nach Berechtigungs- und Backup-Pruefung
importieren.

## 6. Was ist rechtlich zu beachten?

**Orientierung, keine individuelle Rechtsberatung.** Die Aussage "privat und eigener Code ist immer
erlaubt" waere zu pauschal. Land, konkrete Handlungen, Berechtigungen, Verträge und Schutzrechte
zaehlen. Vor gewerblicher Veroeffentlichung oder unklarer Analyse fachlichen Rat einholen.

Der EuGH hat in **C-406/10 (SAS Institute, 2. Mai 2012)** zwischen Programmfunktionalitaet/Ideen und
geschuetzter Ausdrucksform unterschieden. Das ist keine pauschale Erlaubnis, Code, Handbuchtexte
oder Gestaltung zu kopieren. Siehe die
[offizielle Gerichtsmitteilung](https://curia.europa.eu/jcms/upload/docs/application/pdf/2012-05/cp120053en.pdf).

In Deutschland nennt `https://www.gesetze-im-internet.de/urhg/__69d.html` (§ 69d Abs. 3 UrhG;
unverifizierte Originalreferenz, CI Transportfehler, 30.10.2026) Bedingungen fuer das Beobachten,
Untersuchen und Testen durch Berechtigte. `https://www.gesetze-im-internet.de/urhg/__69e.html` (§
69e UrhG; unverifizierte Originalreferenz, CI Transportfehler, 30.10.2026) regelt enge
Voraussetzungen fuer bestimmte Interoperabilitaets-Dekompilierungen, nicht ein allgemeines Recht,
konkurrierende Produkte zu kopieren.

| Sicherer Projektgrundsatz                   | Grenze                                                                                |
| ------------------------------------------- | ------------------------------------------------------------------------------------- |
| Allgemeine eigene Anforderungen formulieren | Keine Uebernahme geschuetzter Ausdrucksformen                                         |
| Eigene Gestaltung und Kennzeichnung         | Marken-/Designrechte und Verwechslungsgefahr gesondert pruefen                        |
| Eigene oder passend lizenzierte Bausteine   | Lizenzbedingungen/Attribution einhalten                                               |
| Rechtmaessige eigene Exporte                | Datenschutz und Exportberechtigungen pruefen                                          |
| Nur autorisierte Beobachtung                | Login-/Lizenz-/DRM-Umgehung und unbefugte Zugriffe nicht Bestandteil dieses Workflows |

Auch private Nutzung hebt nicht saemtliche Pflichten auf. Nutzungsbedingungen sind kein Ersatz fuer
die Pruefung zwingender gesetzlicher Rechte; umgekehrt ersetzt ein eigener Prompt keine Erlaubnis.
REA selbst grenzt seine Unterstuetzung im
[Disclaimer](https://github.com/morluto/rea/blob/1629266e3c08c90fed6bba5383528af7986a12b7/DISCLAIMER.md)
auf rechtmaessige Einsaetze ein. Keine unbefugten Zielsysteme testen.

## 7. Alltagstest statt vorschneller Kuendigung

Kernablaeufe mehrere Tage mit Test-/freigegebenen Daten ausprobieren. Export, Restore, Erinnerungen
und Fehlerbehandlung pruefen. Fehler mit reproduzierbaren Schritten melden statt ungeprueft alles
neu bauen zu lassen. Erst selbst ueber eine Kuendigung entscheiden, wenn Zuverlaessigkeit,
Datenmitnahme und ein Rueckweg zum alten Produkt geklaert sind. Es gibt keine Garantie, dass eine
Woche Testzeit fuer jede Anwendung genuegt.

## 8. Wenn etwas nicht funktioniert

| Problem                                          | Vorgehen                                                                                               |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------------ |
| REA im Setup vorbereitet, aber /mcp zeigt nichts | Quellvorbereitung ist keine MCP-Aktivierung; erst gebaute CLI und gezielten Registrierungsplan pruefen |
| Node/npm fehlt oder falsche Version              | Keine pauschalen globalen Updates; passende Runtime bewusst bereitstellen                              |
| Kontext verloren                                 | steckbrief.md in neuem Chat lesen lassen                                                               |
| Analyse-Ergebnis unklar                          | Belege und Unsicherheit dokumentieren, nicht als Original-Implementierung ausgeben                     |
| Qwen-Desktop-Anbindung fehlt                     | Version/MCP-Unterstuetzung pruefen; Qwen Chat nicht mit Qwen Code verwechseln                          |
| Speicherplatz knapp                              | Aktuelles Installationslog pruefen; Build nicht erzwingen                                              |

Weitere Einstiegspunkte: [REA](../tools/rea.md), [WebsiteFactory](../tools/websitefactory.md),
[Agentic Coding](../tools/agentic-coding.md) und [find-skills](../tools/find-skills.md).
