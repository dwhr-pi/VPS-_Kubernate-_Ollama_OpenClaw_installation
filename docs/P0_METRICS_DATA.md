# P0-B: Messwerte als Daten statt Shell-Code

Stand: 03.11.2026. Fortsetzung des Claude-Review-Auftrags auf
`codex/claude-review-p0-20261103`. Keine Benutzerdateien gelesen oder migriert, kein echter
Installer-/Dienst-/Modell-/Clusterstart, kein WSL-Zugriff und keine Docker-Installation.

## Bestaetigter Befund und Umsetzung

Am Ausgangscommit `7ee6cb5a7d0ff256e594a403d5a81041658ad521` schrieb
`show_metrics_editor` nach `/tmp/metrics_config_edit`; `load_metrics_config` fuehrte anschliessend
die editierte Datei mit `source` aus. Die Operationserfassung und der Status-Helfer ersetzten
dieselbe Konfiguration ausserdem unabhaengig voneinander. Eine Datei fuer Schaetzwerte darf
weder eine Shell-Erweiterung noch ein ungepruefter Schreibpfad sein.

`scripts/security/metrics_config.py` implementiert jetzt:

- Literales Zuweisungsformat mit Kommentaren, normalen Anfuehrungszeichen und erlaubten
  Messwerte-Namen. Keine Shell-Auswertung, Imports aus Daten, `eval`, Command Substitution
  oder Umgebungsvariablen wie `PATH`/`BASH_ENV`. Doppelte Schluessel und Kontrollzeichen werden abgelehnt.
- Vollstaendige Validierung vor Ausgabe. Der Bash-Loader uebernimmt erst bei erfolgreichem
  Parserabschluss die Daten mit `read -r` und `printf -v`, nicht ueber generierten Shell-Code.
- Begrenzt auf zwei MiB und auf die externe Datei `setup_metrics.conf`. Elternverzeichnisse
  werden descriptor-relativ ohne Symlink-Following geprueft; eigenes, nicht fremd beschreibbares Ziel.
- Persistente, private Lockdatei `.setup-metrics.lock` mit nicht blockierendem `flock`.
  Neue Dateien 0600, exklusive temporaere Datei im Zielverzeichnis, `fsync` und atomare Publikation.
  Keine rekursive Bereinigung und kein Loeschen des Lock-Inodes nach Freigabe.
- Editorvergleich gegen den zuvor gelesenen SHA256. Parallele Aenderung oder belegte Sperre:
  Abbruch statt Ueberschreiben. Keine automatische Uebernahme fremder/verlinkter Dateien.
- Operationserfassung und `status_tracking.sh` aktualisieren Historienwerte ueber denselben
  gesperrten Merge-Pfad. Nicht betroffene Schaetzwerte/History bleiben erhalten.

Der Editor verwendet `dialog --stdout` und haelt die Ausgabe im Speicher. Abbruch schreibt
nichts. Vorhandene Menuepunkte, Dateinamen, Status-/Logpfade und der Installationsweg bleiben erhalten.
Die Standardvorlage mit ueber 60 Schluesseln wird als echte Testeingabe geprueft.

## Aufrufe und Aktivierung

```bash
# Ohne Argumente oder mit --dry-run nur Plan, ohne Dateizugriff:
python3 -I -B scripts/security/metrics_config.py --dry-run
# Reine Validierung auf dem eigenen nativen Linux-Host; gibt nur SHA256 aus:
python3 -I -B scripts/security/metrics_config.py check \
  --file "$HOME/.openclaw_ultimate_user_data/setup_metrics.conf"
```

`init`, `edit` und `merge` schreiben nur mit ausdruecklichem `--apply`; das bestehende Setup
uebergibt dies nur in seinen vorgesehenen Initialisierungs-/Editor-/Messwertpfaden.
Ohne diese Option bleibt es beim Plan. `read` ist eine interne Datenschnittstelle und gibt die
erlaubten Messwerte aus; dort keine Geheimnisse ablegen. Ein Fehler hat Exitcode 1 und eine
redigierte Meldung ohne Dateiinhalt. Der Helfer fuehrt keine fremden Programme aus.

## Kompatibilitaet und Breaking Changes

Alte, eigene, nicht fremd beschreibbare 0644-Messwertdateien bleiben lesbar; die naechste
ausdrueckliche Aktualisierung publiziert 0600. Ein 0755-Workspace ist fuer diese nicht geheimen
Messwerte zulaessig, sofern er dem Benutzer gehoert und nicht fremd beschreibbar ist.
Das ist **keine** Lockerung der separaten 0700/0600-Vertraege fuer ENV/Secrets.

Shell-Ausdruecke, freie Variablennamen, doppelte Schluessel, Zeilenfortsetzungen und mehrzeilige
Werte werden nicht migriert oder ausgefuehrt, sondern abgelehnt. Fuer numerisch verwendete Werte
sind nur begrenzte ganze Zahlen bzw. ganzzahlige GB-Bereiche erlaubt. Bestehende ungueltige Dateien bleiben
bei Validierungsfehlern erhalten und muessen lokal als Daten korrigiert werden; nicht `source`n.
Es werden keine Rechte bestehender Dateien still mit chmod/chown repariert.

Publikation benoetigt natives POSIX mit `dir_fd`, `O_NOFOLLOW` und `flock`. Unter WSL muss der
Helfer mit Linux-Python laufen; es gibt keinen automatischen WSL-Aufruf oder schwachen Windows-
Fallback. Ein nativer Windows-Python kann Parser/Plan testen, aber nicht in den Workspace schreiben.

Bei einem konkurrierenden Edit/Record wird nicht automatisch wiederholt. Die Oberflaeche meldet
den Fehler; nach Beendigung des anderen Vorgangs erneut oeffnen. TSV-Historien, sonstige Dialog-
Temp-Dateien, andere per `source` geladene Konfigurationen und globale Workspace-/Backup-Locks
sind nicht durch diesen Patch insgesamt gehaertet. Bereits laufende alte Installer respektieren
das neue Lock nicht; vor einem Versionswechsel geordnet beenden, keine parallelen Altprozesse.

## Abnahme und Rollback

```bash
python3 -B -m unittest discover -s tests -p test_metrics_config.py -v
python3 -B -m unittest discover -s tests -p test_operation_log.py -v
python3 -B -m unittest discover -s tests -p test_setup_shell_contracts.py -v
shellcheck setup_ultimate.sh scripts/helpers/status_tracking.sh
bash -n setup_ultimate.sh scripts/helpers/status_tracking.sh
```

Tests verwenden ausschliesslich synthetische temporaere Dateien und extrahierte Funktionen,
nicht das komplette Setup. Die POSIX-Abnahme prueft 0600, Symlinks, Hardlinks, gesperrte Dateien,
belegte Locks, veraltete Editor-Revisionen und den Erhalt des Originals bei Validierungsfehlern.
Der neue Test ist im bestehenden Ubuntu-24.04-CI-Job eingetragen. Unter Windows werden die
POSIX-Dateitests begruendet uebersprungen, nicht als erfolgreich behauptet.

Lokaler Nachweis: neun gezielte Suites mit 81 unterschiedlichen Tests, davon 73 bestanden und
acht plattformbedingt uebersprungen. Darunter 17 neue Messwerte-Tests mit elf Erfolgen und sechs
nativen POSIX-Skips. Parser-/Registry-/Menue-/Shell-Helfer-/Audit-/Dokumentationspruefungen bestanden.
ShellCheck, shfmt, Bash-Syntax, Markdownlint und Diff-Pruefung
bestanden; gezielte redigierte Gitleaks-Dateiscans ohne Befund. Kein Vollhistoriennachweis.

In zwei erweiterten Laeufen von `test_operation_log.py` trat jeweils ein 60-Sekunden-Timeout
auf (`test_failed_creation_clears_old_log_reference` bzw.
`test_installer_output_appends_and_names_are_unique`). Beide Tests bestanden einzeln erneut;
die beteiligten Fixture-Funktionen und `operation_log.sh` sind identisch zum Basiscommit.
Der dritte vollstaendige Lauf bestand unveraendert mit 16/16 Tests in 55,970 Sekunden. Das
ist keine bestaetigte Ursachenanalyse der intermittierenden Timeouts und keine gesamte CI-Abnahme.
Zeitgrenzen und Tests wurden nicht abgeschwaecht. Die Linux-CI muss den aktuellen Head separat pruefen.

Echte Menuebedienung, Linux-/ARM-Fresh-Host-Abnahme, Stromausfall-/Filesystem-Fault-Injection
und gesamte GitHub-CI sind davon getrennte offene Nachweise. Keine Runtime-Hochstufung.

Rollback: vorherige gepruefte Version nur gezielt und ohne Nutzdatenloeschung wiederherstellen.
Eine Konfigurationsdatei nie deshalb wieder ausfuehren, um sie lesen zu koennen. Bei Parser-
Inkompatibilitaet zuerst eine Kopie lokal untersuchen, Messwerte-Editor voruebergehend nicht nutzen
und eine Datenmigration mit Testfall ergaenzen. Historien-/Modell-/Workspace-Dateien nicht loeschen.
