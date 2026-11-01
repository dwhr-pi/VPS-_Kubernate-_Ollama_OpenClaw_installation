# P0-A: Schutz vor destruktivem Legacy-Uninstall

Stand: 01.11.2026. Gilt fuer die registrierten Legacy-Einstiege
`scripts/tools/ollama_uninstall.sh` und `scripts/tools/openclaw_uninstall.sh`.

## Was sich aendert

**Diese beiden Legacy-Programme werden vorerst nicht automatisch deinstalliert.**
Ihre alten Installer erzeugen keinen belastbaren Besitz-/Dateimanifestvertrag.
UID, ein vorhandenes Verzeichnis, ein Installiert-Haekchen oder ein selbst
angelegter privater Marker reichen dafuer nicht aus. Ein neuer Marker darf nicht
nachtraeglich fremde oder bestehende Installationen zur Loeschung freigeben.

Der Schutzpatch schliesst die unmittelbar destruktiven Ausfuehrungspfade. Er
ist **kein neuer funktionsfaehiger verwalteter Uninstaller** und keine automatische
Migration. Auch Ansible-Core-Installationen unter `/opt/openclaw-core`, Container,
Paketinstallationen und selbst verwaltete Dienste werden nicht uebernommen.
Die Installation dieser Programme wird durch diesen Patch nicht veraendert;
deren bewegliche Quellen bleiben eine getrennte P0-B-Aufgabe.

- Standard und `--dry-run` liefern nur eine Metadaten-Vorschau bekannter fester
  Legacy-Pfade. Dies ist kein vollstaendiger Installationsfinder und kein
  Nachweis, dass bei abwesenden Pfaden das Programm insgesamt deinstalliert ist.
- Kein `sudo`, Dienststopp/-Disable/-Reload, rekursives Loeschen, Verschieben,
  Backup oder automatischer Secret-Export.
- Modelle, Agent-State, ENV/API-Keys, Workspace, bestehende Backups,
  Installationsstatus und Autostart bleiben erhalten.
- Pfadkomponenten werden auf Links/Junctions geprueft. Marker werden nur per
  Metadaten inspiziert: Dateityp, UID, Rechte und Linkzahl. Inhalte von Programmen,
  Markern, Konfigurationen oder Secrets werden nicht geoeffnet.
- Ein Modus-0600-Marker in einem privaten Verzeichnis wird lediglich als
  `private-but-unverified` ausgewiesen. Er erteilt keine Loeschberechtigung.
- ENV-Umleitungen per `OPENCLAW_DIR` und alte positive Freigaben wie
  `OPENCLAW_REMOVE_STATE=yes`, `OPENCLAW_UNINSTALL_ASSUME_YES=true` oder
  `OPENCLAW_BACKUP_STATE=yes` werden abgelehnt. Werte werden nicht ausgegeben.
- Der Guard verwendet weder `HOME` noch `OPENCLAW_USER_DATA_DIR` als Loesch- oder
  Schreibziel. Die Wrapper ignorieren ein geerbtes `INSTALL_DIR` und laden keinen
  Status-/APT-Helfer.

## Aufruf und Exitcodes

Im geprueften Repository auf Linux/WSL mit vorhandenem Python 3:

```bash
rc=0
bash scripts/tools/ollama_uninstall.sh --dry-run || rc=$?
printf 'Vorschau-Exitcode: %s\n' "$rc"
```

```bash
rc=0
bash scripts/tools/openclaw_uninstall.sh --dry-run || rc=$?
printf 'Vorschau-Exitcode: %s\n' "$rc"
```

| Exitcode | Bedeutung |
| --- | --- |
| 3 | Nur Vorschau/Sicherheitssperre, NICHT deinstalliert |
| 1 | Apply gesperrt, unsichere Metadaten, nicht pruefbarer Pfad oder alte Freigabevariable |
| 2 | Ungueltige oder widerspruechliche Optionen; kein Force-/Zielpfad-Schalter |
| 0 | Nur Hilfe; niemals Bestaetigung einer automatischen Entfernung |

`--apply` ist ausdruecklich gesperrt, auch mit sudo oder scheinbar passendem
Marker. Nicht durch alte Skriptkopien, `rm -rf`, ein handgeschriebenes Receipt
oder ein pauschales Chown umgehen. Hier gibt es bewusst keinen solchen Fallback.
Eine individuell gepruefte manuelle Migration ist ein gesonderter Auftrag.

Im Tools-Menue wird die Vorschau vor der generischen Uninstall-Routine gestartet:
keine vorgelagerte Log-Bereinigung, Messung, Rollback-Sperre, Entfernung von
Statuszeilen oder Autostart-Eintraegen fuer diese beiden Core-Tools. Selbst ein
unerwarteter Exitcode 0 des Guards loest dort keinen Uninstall-Erfolg aus.
Der Menue-Handler kann mit 0 zurueckkehren, um im interaktiven Setup zu bleiben;
das ist kein Tool-Uninstall-Erfolg. Andere Tools behalten ihren bisherigen Ablauf.
Der normale Start des gesamten Setups kann weiterhin eigene allgemeine
Workspace-/Statusaktionen ausfuehren; die Nebenwirkungsfreiheit betrifft die
Guard-Vorschau und ihren Core-Uninstall-Zweig, nicht das gesamte Setup.

## Tests und Grenzen

```bash
python3 -I -B -m unittest discover -s tests -p test_legacy_core_uninstall.py -v
```

Fixtures pruefen Datenerhalt, Wiederholung, fehlende/unsichere/fremde Marker,
Pfadumleitung, Symlinks, Fehlerweitergabe, EOF ohne Eingabeschleife, echte
Wrapper-Argumente/-Exitcodes und die reale Menuefunktion mit isolierten Stubs.
Auch die generische Erfolgs-/Fehlerbehandlung anderer Tools bleibt getestet.
Der Guard hat keinen mutierenden oder Dienst-ausfuehrenden Implementierungspfad;
ein Dienststopp wird deshalb weder versucht noch als erfolgreich behauptet.
Die bisher geforderte Abnahme eines geprueften verwalteten Dienststopps bleibt
Teil des noch fehlenden vollstaendigen Lifecycle-Vertrags.

Die Ubuntu-24.04-P0-CI enthaelt diese Suite und beide Bash-Syntaxpruefungen.
Das Hinzufuegen eines Jobs ist noch kein gruener Online-Lauf. Lokale Ergebnisse
und verbleibende Grenzen stehen im [Review-Bericht](REVIEW_FINDINGS.md).
Kein produktiver Uninstall, WSL-Zugriff, Secret-Zugriff oder Runtime-Test wurde
fuer diese Implementierung durchgefuehrt. Ein echter Symlink-Test kann unter
Windows ohne entsprechende Rechte uebersprungen werden; unter POSIX muss er
ausgefuehrt werden und darf dort nicht als Skip verschwinden.

Lokal am 01.11.2026: Guard-Suite 21 Tests ohne Fehler mit einem begruendeten
Windows-Symlink-Skip; einschliesslich bestehender P0-/Regressionssuites insgesamt
119 Tests, 115 bestanden und vier plattformbedingte Skips. Keine vollstaendige
Testsuite aller Tools oder aktuelle Online-CI-Abnahme.
Die betroffenen Shell-Dateien bestehen `bash -n`, ShellCheck und shfmt;
geaenderte Dokumentation besteht Markdownlint und den lokalen Linkaudit.

## Abnahme, Breaking Change und Rollback

Abnahme dieses Schutzpatches: kein destruktiver Legacy-Pfad erreichbar,
kein falscher Removed-Status, explizite Exitcodes, fehlender/fehlerhafter Guard
schliesst sicher, gezielte Fixtures und statische Checks bestehen.

**Breaking Change:** Eine bestehende Ollama-/OpenClaw-Legacy-Installation laesst
sich nicht mehr ueber diese zwei Menue-/Skriptpfade automatisch entfernen.
Es wurde keine Datei migriert oder entfernt; daher ist kein Daten-Restore fuer
diesen Patch erforderlich.

Code-Rollback ist ein eigener reviewter Revert des P0-A-Commits. Dabei wuerden
die alten destruktiven Pfade zurueckkehren: sie nicht als Betriebs-/Recovery-Weg
ausfuehren. Bei Problemen den Guard geschlossen lassen und den Fehler getrennt
beheben. Kein Reset/Clean, kein Rollback privater Daten und keine Marker-Adoption.

## Bewusst noch offen

Ein vollstaendiger verwalteter Uninstaller benoetigt einen vertrauenswuerdigen
Receipt-Erzeuger ab frischer Installation, einen separaten geprueften
Legacy-Migrationsprozess, belegte Dateiliste/Service-Zuordnung, abgestufte
Freigaben, konsistente Statusaktualisierung und echte Linux-Abnahme. Diese
Bausteine werden nicht durch ein erfundenes Markerformat vorgetaeuscht.
