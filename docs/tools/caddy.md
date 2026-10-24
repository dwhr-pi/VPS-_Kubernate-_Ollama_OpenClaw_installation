# Caddy: GitHub-Build und Go-Voraussetzung

Caddy ist ein Webserver und Reverse Proxy mit automatisierbarer HTTPS-
Konfiguration. Der Setup-Installer baut das Programm aus dem offiziellen,
gepinnten GitHub-Quellcode, nicht aus Docker oder einem fertigen Caddy-Archiv.
Installation und Serverbetrieb sind getrennte Schritte.

## Fehler: go fehlt

Das Log vom 24.10.2026 um 00:50 zeigt eine fehlende Go-Toolchain. Die
Speicherpruefung war bestanden; die allgemeine Warnung bei weniger als
50 GiB auf C: ist nicht die Ursache dieses Abbruchs.

Der [gepruefte go.mod-Vertrag](https://github.com/caddyserver/caddy/blob/2b47a1849f86389825623d6d36ee528da8b9e5fb/go.mod)
verlangt mindestens Go 1.26. Ein beliebiges Ubuntu-Paket `golang-go` kann
dafuer zu alt sein. Der Installer ersetzt kein System-Go.

Nach Uebernahme aller aktualisierten Setup-Dateien Caddy erneut im Tools-
Menue installieren. Bei fehlendem/zu altem Go fragt ein interaktives Terminal
nach Zustimmung fuer die private Toolchain. Alternativ ausdruecklich freigeben:

```bash
# Preview only: no toolchain download, compilation or host change.
bash scripts/tools/caddy_install.sh --dry-run
# Explicit consent for a private Go prerequisite, then build Caddy from GitHub.
bash scripts/tools/caddy_install.sh --install-build-deps
```

Eine vorhandene passende Go-Version wird bevorzugt. Ansonsten verwendet der
[private Go-Bootstrap](../../scripts/tools/helpers/private_go.py) das offizielle
Go-1.27.3-Archiv mit fester Groesse und SHA256. Das Archiv ist eine Compiler-
Abhaengigkeit, kein GitHub-Source-Build des Compilers. Caddy selbst wird
weiterhin aus GitHub gebaut. Ohne Zustimmung erfolgt kein Toolchain-Download.

Die private Basis-Toolchain liegt unter
`~/.openclaw_ultimate_user_data/tools/caddy/toolchain/`. Eine bereits gepruefte
private Toolchain wird erneut verifiziert und wiederverwendet. Nur die
Build-Unterprozesse erhalten den passenden PATH/GOROOT; globaler PATH und
System-Go bleiben unveraendert. `GOTOOLCHAIN=local` verhindert automatische
Go-Toolchain-Upgrades durch Modulbefehle. Kein apt, sudo oder Docker.

## Speicher, Fehler und Deinstallation

Vor Toolchain-Download und Quellen-Build werden Speicher und RAM geprueft.
Die Reserve bleibt 4 GiB, unter WSL auch auf C:. Die zuletzt gemeldeten
7,9 GiB bestehen diese Vorpruefung, sind aber kein Grund, den knappen
Windows-Speicher oder weiteren benoetigten Puffer zu ignorieren.

Download-, Versions-, Pruefsummen- und Buildfehler bleiben im aktuellen
Operationslog. Es entsteht kein falscher Installationsmarker. Rollback
betrifft nur den neu erstellten nativen Buildordner; die private Basis-
Toolchain bleibt wie andere Basiswerkzeuge bei Fehler/Deinstallation erhalten.
Alte Container, Volumes, `/opt`-Daten und Secrets bleiben unangetastet.

## Fehler nach erfolgreichem Build: Permission denied: go.sum

Im Log vom 24.10.2026 um 02:08 wurden Compiler, Modulpruefung, Build und
Programmaufruf bereits erfolgreich durchlaufen. Erst danach kam der
Berechtigungsfehler. Der betroffene private Go-Modulcache enthaelt
standardmaessig schreibgeschuetzte Modulverzeichnisse; das bisherige Cleanup
mit `shutil.rmtree` konnte daran scheitern. Auch der folgende Rollback konnte
denselben Fehler ausloesen und damit die erste Fehlermeldung ueberdecken.
Ohne vollstaendigen Traceback ist der konkrete betroffene Pfad im alten Log
nicht abschliessend nachweisbar; dieser Cleanup-Fehlerpfad ist nun abgedeckt.

Der Installer hebt den Schreibschutz jetzt ausschliesslich im eigenen
`native-github/_build/.build-home/go-mod` vor dessen Entfernung auf.
Symlinks/Junctions werden dabei nicht verfolgt. Kein `sudo`, kein rekursives
`chmod` auf Nutzerdaten, keine Aenderung an globalen Go-Caches oder Quellen.
Go behaelt waehrend des Builds seine standardmaessigen Cache-Rechte.
Ein fehlschlagender Rollback wird separat protokolliert; der urspruengliche
Build-/Cleanup-Fehler bleibt sichtbar und kein Erfolgsmarker wird belassen.

Nach Uebernahme der aktualisierten Dateien kann die Installation erneut
ausgewaehlt werden. Die bereits gepruefte private Go-Toolchain wird
wiederverwendet. Falls der alte fehlgeschlagene Rollback einen Ordner ohne
Buildnachweis hinterlassen hat, siehe die ausdrueckliche Reparatur unten.

Die Ausgabe `unknown` von `caddy version` ist bei einem Quellen-Build ohne
Release-Versionsstempel kein Fehlercode und kein Nachweis einer Release-
Versionsnummer. Der Installer prueft zusaetzlich Pin und Artefakt-Hashes,
aber keine laufende Webserverinstanz. Das Log zeigt keinen Speicherabbruch.

Hintergrund: [Go-Modulcache und Schreibschutz](https://go.dev/ref/mod#module-cache).

## Reparatur: vorhandener nativer Ordner ohne Buildnachweis

Das zweite Log vom 24.10.2026 um 04:15 zeigt einen Restordner des vorherigen
Versuchs. Dies ist keine erneute Go-/Buildstoerung: Der Installer stoppt
bewusst vor dem Ueberschreiben. Ein fehlender Marker wird nicht einfach
erzeugt und eine vorhandene Binaerdatei nicht ungeprueft als installiert gewertet.

Nach Uebernahme der aktualisierten Setup-Dateien ist diese gesonderte,
datenerhaltende Reparatur moeglich:

```bash
# Preview only; no move, download or build:
bash scripts/tools/caddy_install.sh --repair --quarantine-incomplete --dry-run
# Explicit consent to preserve the old directory, then rebuild from GitHub:
bash scripts/tools/caddy_install.sh --repair --quarantine-incomplete
```

Die interaktive Installation im Tools-Menue bietet dieselbe Erhaltung mit
einer separaten Ja/Nein-Frage an. Ohne Zustimmung oder bei nichtinteraktiver
Ausfuehrung ohne Flag bleibt der Ordner unveraendert. Ein einfacher
`--repair` ist keine stillschweigende Freigabe zum Verschieben.
Die Option gilt ausschliesslich fuer Caddy ohne vorhandenen Buildmarker.
Ein vorhandener, aber ungueltiger Marker bleibt ein manueller Prueffall.

Vor jeder Verschiebung laufen die normalen Speicher-/Toolchain-Pruefungen.
Danach wird der komplette Altordner innerhalb desselben Tool-Verzeichnisses
umbenannt, etwa nach
`~/.openclaw_ultimate_user_data/tools/caddy/native-github-incomplete-<zufall>/native-github`.
Das aktuelle Operationslog nennt den tatsaechlichen Sicherungspfad; daneben
steht eine `RECOVERY.json` mit dem ausdruecklichen Status **nicht installiert**.
Unbekannte Dateien, Konfigurationen und Verknuepfungen bleiben erhalten;
die Reparatur fuehrt sie nicht aus und importiert keine alten Secrets.
Die Sicherung wird nicht automatisch geloescht, auch nicht bei erneutem
Buildfehler oder bei der Deinstallation des spaeteren neuen Builds.

Anschliessend entsteht ein neuer Ordner aus dem festen GitHub-Pin. Die
vorhandene gepruefte private Go-Toolchain bleibt am bisherigen Platz und
wird wiederverwendet. Es wird kein Dienst gestartet. Nur ein erfolgreich
abgeschlossener neuer Build erhaelt einen Buildmarker.

**Speicher:** Das Umbenennen kopiert den Altbestand nicht, gibt aber auch
keinen Platz frei. Bei zuletzt rund 6 GiB auf C: bleibt der Speicher knapp.
Die normale 4-GiB-Mindestreserve wird nicht umgangen; sie garantiert nicht
genug Platz fuer den gesamten Build. Scheitert die Vorpruefung, wird noch
nichts verschoben. Den Sicherungsordner spaeter erst nach eigener Pruefung
und separat freigegebener Bereinigung entfernen; keine pauschale Loeschung
von `tools/caddy`, Toolchains oder Userdaten.

## Kein automatischer Webserverbetrieb

Der Installer fuehrt nach dem Build lediglich `caddy version` aus. Er
startet keinen Server, oeffnet keine Ports 80/443/2019, erzeugt keinen
Caddyfile, fordert keine ACME-Zertifikate an und liest keine vorhandenen
Zertifikatsdaten. systemd, Domain, TLS, Authentifizierung, Reverse-Proxy-Ziele
und Firewall muessen separat geprueft und freigegeben werden. Die Admin-API
nicht ungeschuetzt oeffentlich erreichbar machen.

Siehe [Docker-zu-GitHub-Migration](../DOCKER_TO_GITHUB.md) und
[Node Exporter mit derselben Go-Voraussetzung](node-exporter.md).
