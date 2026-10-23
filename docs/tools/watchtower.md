# Watchtower: GitHub-Build, Go-Voraussetzung und Legacy-Status

Watchtower aktualisiert Docker-Container anhand neuer Images. Es ist kein
Updater fuer native GitHub-Installationen und kein Kubernetes-Controller.
Fuer einen vollstaendig Docker-freien Host ist es deshalb nicht erforderlich.
Das Programm selbst kann trotzdem ohne Docker aus GitHub gebaut werden.

## Fehler: go fehlt

Der Versuch vom 24.10.2026 um 01:34 scheiterte am fehlenden Go-Compiler.
Die Speicherpruefung war bestanden; die Warnung ueber wenig freien
Windows-Speicher war nicht die Abbruchursache.

Der [gepinnten go.mod](https://github.com/containrrr/watchtower/blob/ca0e86e824ec05389ab972ea97d04d4bf0476e90/go.mod)
zufolge ist mindestens Go 1.20 erforderlich. Der Installer bevorzugt
vorhandenes passendes Go. Andernfalls fragt er interaktiv nach Zustimmung
fuer eine private Toolchain; nichtinteraktiv muss diese freigegeben werden:

```bash
bash scripts/tools/watchtower_install.sh --dry-run
# Explicit consent for the private Go build prerequisite:
bash scripts/tools/watchtower_install.sh --install-build-deps
bash scripts/tools/watchtower_doctor.sh
```

Nach Uebernahme der aktualisierten Dateien funktioniert dies auch ueber
das Tools-Menue mit interaktiver Nachfrage. Ohne Zustimmung kein Download.
Ein Dry-Run bleibt auch mit Freigabe-Flag ohne Installation.

Der vorhandene private Go-Bootstrap verwendet das offizielle Go-1.27.3-Archiv
mit fester Groesse und SHA256. Dies ist eine Binaer-Ausnahme fuer den Compiler,
nicht fuer Watchtower: Watchtower bleibt ein Build des festen GitHub-Commits.
Go-Module werden ueber den konfigurierten Modulproxy mit Go-Summenpruefung
geladen. Der gesamte Abhaengigkeitsgraph ist kein reiner GitHub-Source-Build.
Die Kompatibilitaet dieser alten Abhaengigkeiten mit dem privaten Compiler
ist hier nicht durch einen echten Ubuntu-Build abgenommen; Fehler erzeugen
keinen Erfolgsmarker und werden nicht durch automatische Upgrades kaschiert.

Die Toolchain liegt privat unter
`~/.openclaw_ultimate_user_data/tools/watchtower/toolchain/`.
Nur Build-Unterprozesse erhalten PATH/GOROOT; kein System-Go, apt, sudo,
Shellprofil oder globaler PATH wird geaendert. Automatische Go-Toolchain-
Upgrades sind durch `GOTOOLCHAIN=local` deaktiviert.

## Installation ist kein laufender Container-Updater

Der Quellen-Pin ist
`ca0e86e824ec05389ab972ea97d04d4bf0476e90`. Nach dem Build prueft der
Installer ausschliesslich `watchtower --help`. `--version` ist am Pin
nicht registriert und wird deshalb nicht verwendet.
Die Hilfe beendet den Cobra-Aufruf vor dem normalen PreRun-/Run-Pfad.
Es werden keine Container abgefragt, Images aktualisiert oder Dienste gestartet.

Der Buildmarker bestaetigt nur den Paket-/Programmaufbau, nicht die
Kompatibilitaet mit einer installierten Docker-API oder eine Betriebsfreigabe.
Ein spaeterer Betrieb benoetigt Docker-Zugriff und kann Container stoppen,
ersetzen und neu starten. Socketrechte sind hochprivilegiert; keine
ungeschuetzte TCP-Docker-API bereitstellen. Kein automatischer Socketzugriff,
keine Docker-Gruppenrechte und kein Autostart werden eingerichtet.

## Dringlichkeit und Grenzen

Das [offizielle Repository](https://github.com/containrrr/watchtower) wurde
am **17.12.2025 archiviert**. Dies ist ein experimenteller Legacy-Build,
keine Empfehlung fuer automatische Updates produktiver Systeme. Vor Betrieb
Abhaengigkeiten, Docker-API-Kompatibilitaet, Schwachstellen, Backups und
Rollback separat pruefen. Ein neuer Compiler repariert keine alten Module.

Es gelten weiterhin 4096 MiB freier Zielspeicher und unter WSL auch freier
Windows-Host-Speicher. Die 8210 MiB aus dem Log bestehen diese Vorpruefung,
garantieren aber nicht genug Platz fuer jeden spaeteren Build.

Fehler stehen im aktuellen Operationslog; neue App-Dateien werden nach
den datenerhaltenden Rollback-Regeln behandelt. Eine erfolgreich eingerichtete
private Go-Basis bleibt bei App-Fehler und Deinstallation erhalten.
Bestehende Container, Volumes, Logs und Secrets bleiben unangetastet.

Quellpruefung: [main.go](https://github.com/containrrr/watchtower/blob/ca0e86e824ec05389ab972ea97d04d4bf0476e90/main.go),
[Cobra-Einstieg](https://github.com/containrrr/watchtower/blob/ca0e86e824ec05389ab972ea97d04d4bf0476e90/cmd/root.go),
[registrierte Flags](https://github.com/containrrr/watchtower/blob/ca0e86e824ec05389ab972ea97d04d4bf0476e90/internal/flags/flags.go).
Siehe auch [Docker-zu-GitHub-Migration](../DOCKER_TO_GITHUB.md).
