# Projektaudit vom 20.10.2026

## Auftrag, Umfang und Ausgangsstand

Gesamte Repository-Struktur, zentrale Tool-/Profil-/Port-Registries, Markdown-Verweise,
Python-Syntax, vorhandene CI-Workflows, Quellinstaller und beide Queue-Pfade wurden untersucht. Dies
ist ein Struktur-/Codeaudit mit gezielten Offline-Tests, **keine Vollabnahme aller Installationen**.

Zu Beginn waren lokales HEAD und GitHub-HEAD identisch: `9cada7eee15be642d7a1c511dd3c74e5091ee2c8`.
Nachfolgende lokale Aenderungen sind nicht automatisch auf GitHub veroeffentlicht. Keine
WSL-Zugriffe, Tool-/Modellinstallationen, Dienste, Wallets oder Cloud-Aufrufe. Externe
Modellkataloge und Toolversionen wurden nicht pauschal auf `latest` gesetzt.

| Bestand vor der Ueberarbeitung | Anzahl |
| ------------------------------ | -----: |
| Zentrale Tools                 |    340 |
| Zentrale Profile               |    245 |
| Registry-Ports                 |     44 |
| Markdown-Dateien               |   1019 |
| Python-Testmodule              |     65 |

## Was bereits gut ist

- Tools, Profile, Skills, Stacks und Dokumentation besitzen getrennte Bereiche.
- Neue Quellinstaller verwenden feste Pins, private User-Workspaces und explizite Freigaben statt
  unkontrollierter Modell-/Dienststarts.
- Log-/Disk-/Rollback-/Status- und Lizenzkorrekturen haben gezielte Tests.
- Geheimnisse, Wallets und grosse Modellartefakte sind weitgehend ausgeschlossen.
- Umfangreiche Sicherheits-, Ressourcen-, Queue- und Einstiegsthemen sind vorhanden.

## In diesem Durchgang korrigiert

| Befund                                                                    | Aenderung                                                                                                               |
| ------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| Persoenliche Windows-/Worktree-Links sind fuer GitHub-Nutzer unbrauchbar  | Vorhandene Ziele in README und Dokumentation portabel relativ verlinkt; fehlende alte Huginn-ENV-Vorlage nicht erfunden |
| Ungeschlossener Codeblock im Setup-Guide verschluckt Abschnitte           | Ueberzaehligen Fence entfernt                                                                                           |
| Registry-Checks erkennen nur Teilfehler                                   | Wiederholbaren Offline-Audit mit semantischer Validierung, Link-/Python-Pruefung und JSON-Ausgabe ergaenzt              |
| Registry-Sync verlangt Installer fuer reine Planungsprofile               | Explizites documentation-first + auto_install=false wird korrekt beruecksichtigt                                        |
| Keine Python-Regressionstests in CI                                       | Separaten Workflow fuer statische Checks und Fixture-Tests ergaenzt                                                     |
| `bash -n install.sh setup_ultimate.sh` prueft nicht beide Skripte separat | CI-Aufrufe getrennt                                                                                                     |
| Gemeinsamer Quellinstaller verschluckt unbekannte Flags bei Dry-Run       | Echte Argumentpruefung, Aktionskonflikte vor Dateiaenderungen ablehnen                                                  |
| Queue kann mehrere Worker gleichzeitig starten                            | Gemeinsame Worker-Sperre; Minimalmodus erlaubt ausdruecklich nur Parallelitaet 1                                        |
| TSV-Schreibzugriffe koennen Jobs verlieren                                | Getrennte Metadatensperre fuer Add/Claim/Abschluss/Cancel/Pause/Resume; Tempdateien im gleichen Verzeichnis             |
| Pause/Resume arbeitet trotz TSV-Nutzung nur auf SQLite                    | Backend-konsistent umgesetzt; Submit verwendet bei TSV denselben Pfad                                                   |
| Statusabfrage erzeugt Dateien und fuehrt Shell-Konfiguration aus          | Status liest nur vorhandene Queue; keine Konfiguration ausfuehren, keine Rohkommandos ausgeben                          |
| SQLite-Eingaben und Ergebnisse sind unzureichend validiert                | Prioritaet/Timeout pruefen; Exit-Code-Spalte mit erhaltender Migration, TSV-Exit-Code in Spalte 8                       |
| Python-Caches und Node-Abhaengigkeiten sind nicht allgemein ignoriert     | Ignore-Regeln und LF-Regel fuer Python ergaenzt                                                                         |

Der wiederholbare Einstieg ist [Projektqualitaet pruefen](REPOSITORY_QUALITY.md).
Tool-/Profil-/Port-/Config-/Registry-Sync-Pruefungen laufen ohne Fehler; bestehende
Metadaten-/Alias-Hinweise bleiben sichtbar.

## Offene Luecken, nicht durch erfundene Metadaten verdecken

| Luecke im Ausgangsbestand                                         | Anzahl / Bedeutung                                                    | Prioritaet |
| ----------------------------------------------------------------- | --------------------------------------------------------------------- | ---------- |
| Tools ohne eigene `doc`-Zuordnung                                 | 260; Sammeldokumentation kann existieren, keine automatische Freigabe | P1         |
| Tools ohne `doctor_script`                                        | 283; nicht gleichbedeutend mit voellig fehlender Statuspruefung       | P1         |
| Tools ohne `update_script`                                        | 283; Menue-/generische Pfade muessen einzeln abgeglichen werden       | P1         |
| Tools ohne Status                                                 | 107; keinesfalls pauschal stable setzen                               | P1         |
| Profile ohne Status                                               | 38                                                                    | P1         |
| Fehlende Primaerquellen-Zuordnung im bestehenden Tool-Check       | 55 Hinweise; Quellen je Kandidat nachpruefen                          | P1         |
| Alte Profilnamen / Docs / Installer ausserhalb zentraler Registry | Registry-Sync zeigt Alias-/Legacy-Gruppen und verwaiste Eintraege     | P2         |
| Historisch viele teils ueberlappende Review-/Matrixseiten         | Ein Einstieg mit Datumsstand statt weitere konkurrierende Wahrheiten  | P2         |

Die 105 Profile ohne Installer sind ueberwiegend bewusste documentation-first- Eintraege. Daraus
werden keine automatischen schweren Installationen erzeugt.

## Naechste klar begrenzte Arbeiten

1. **P1: Tool-Lifecycle-Matrix vervollstaendigen.** Zuerst haeufig genutzte Tools: Quelle,
   Pin/Release-Strategie, Scope source/build/runtime, Doctor, Update und datenerhaltende
   Deinstallation an einem gemeinsamen Vertrag ausrichten.
2. **P1: Queue weiter haerten.** Harte Prozessbaum-/cgroup-Grenzen, Windows-Host- Disk-Pruefung je
   Jobziel, verlorene laufende Jobs nach Neustart, sichere Retry-/Cancel-Semantik und
   SQLite-Paralleltests getrennt entwickeln.
3. **P1: Installations-Smoketests.** Getrennte frische Linux-/WSL-/ARM-Testhosts nur nach Freigabe;
   nie persoenliche Installationen als Testumgebung verwenden.
4. **P1: Source-ready nicht als runtime-ready darstellen.** Einheitliche Menue- Legende und
   Migrationsregeln fuer alle bisherigen Marker, ohne fremde Daten zu loeschen oder einen
   erfolgreichen Modellstart zu behaupten.
5. **P2: Doku konsolidieren.** Legacy-Profile auf kanonische Eintraege abbilden, README kuerzen und
   alte Audits als historisch markieren; bestehende Links dabei erhalten.
   Geheimnisse-/Provider-Katalog bleibt zentral unter `_API-Keys`.
6. **P2: CI konsolidieren und Supply Chain pruefen.** Ueberlappende Jobs,
   ShellCheck-/Formatter-Altschulden, Action-Pins und Release-Verifikation kontrolliert bereinigen,
   nicht fehlgeschlagene Pruefungen mit `|| true` verdecken.

## Testgrenzen

Abschliessender lokaler Nachweis: 61 gezielte Tests bestanden, ein echter
Linux-`flock`-Parallelitaetstest unter Windows uebersprungen. Der statische Gesamtaudit meldet 0
Fehler, keine erkannten defekten lokalen Inline-Dateilinks und 971 verbleibende Metadatenhinweise.
Tool-/Profil-/Port-/Config- und Registry- Sync-Checks sowie die Syntax der geaenderten Shellskripte
sind erfolgreich.

Gezielte Audit-/Queue-/Quellinstaller-Fixtures werden lokal ausgefuehrt. Der komplette
Windows-Unittest-Lauf wurde wegen langer Laufzeit abgebrochen; er ist nicht als bestanden zu
verstehen. Auch der Voll-Shellsyntaxlauf ueber mehr als 1500 Skripte wurde lokal wegen langer
Laufzeit beendet; die geaenderten Shellskripte wurden gezielt erfolgreich geprueft. ShellCheck wurde
mangels vorhandenem Werkzeug lokal nicht ausgefuehrt oder nachinstalliert. Die echte
`flock`-Parallelitaet wird unter Windows uebersprungen und im Linux-CI-Test abgedeckt, sobald der
Workflow veroeffentlicht und ausgefuehrt ist. Keine GPU-/Modell-/Installationsmessungen. Der lokale
Check bescheinigt auch keine rechtliche Compliance oder Vollsicherheit.
