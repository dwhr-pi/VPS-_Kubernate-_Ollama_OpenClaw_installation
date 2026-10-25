# cAdvisor: nativer GitHub-Build mit privater Go-Basis

cAdvisor erfasst im spaeteren Betrieb Container-/cgroup-Ressourcen fuer
Monitoring. Ein gebautes Binary ist noch kein eingerichteter Exporter und
kein Nachweis, dass Host-/WSL-Containerdaten vollstaendig sichtbar sind.

## Fehler vom 25.10.2026: Go fehlt

Das Log um 02:00 zeigt einen Abbruch vor dem Quellenbuild. Die Speicherpruefung
war erfolgreich. cAdvisor ist jetzt an den vorhandenen zustimmungspflichtigen
privaten Go-Bootstrap angebunden:

```bash
bash scripts/tools/cadvisor_install.sh --dry-run
# Explicit consent for the private Go prerequisite:
bash scripts/tools/cadvisor_install.sh --install-build-deps
bash scripts/tools/cadvisor_doctor.sh
```

Ohne Flag fragt ein interaktives Terminal mit `[j/N]`. Enter, EOF oder fehlende
Zustimmung genehmigt keinen Download. Dry-Run bleibt auch mit Flag schreibfrei.
Build-/Statuspruefungen laden keine Toolchain still nach.

## Abbruch waehrend go build am 25.10.2026 um 04:25

Das gemeldete Log endet mitten in `go build`, danach erscheint PowerShell.
Ein Abschlussstatus, Compilerfehler oder OOM-Nachweis fehlt. Die Disk-Vorpruefung
war erfolgreich; sie prueft weder den gesamten Windows-RAM noch spaetere
Speicherspitzen. Ein beendeter WSL-/Shellprozess oder Speicherdruck ist moeglich,
aber anhand dieses Logs nicht bewiesen. Kein erfolgreicher Buildnachweis.

Der cAdvisor-Build verwendet jetzt **`-p=1`, `GOMAXPROCS=1` und
`GOMEMLIMIT=768MiB`**, auch fuer Go-Unterprozesse der Asset-Erstellung.
Das senkt die Parallelitaet. GOMEMLIMIT ist ein weiches GC-Ziel **je Prozess**,
keine harte Grenze fuer Compiler, Linker, Windows oder die gesamte WSL-VM und
keine Garantie gegen OOM. Siehe [Go GC Guide](https://go.dev/doc/gc-guide#Memory_limit).
Der Build kann dadurch deutlich laenger dauern.

Compiler-Ausgabe wird laufend ins aktuelle Operationslog geschrieben, nicht
erst nach Ende des Builds gesammelt. Der Rueckgabepuffer ist begrenzt; im Log
stehen PID, Statusmeldungen alle 30 Sekunden und der beobachtete Exitstatus.
Signal-/Timeoutabbrueche sind Fehler, keine Installation. Ein kompletter VM-
oder Hostabbruch kann jedoch auch den Logger toeten: danach ist weiterhin kein
abschliessender Logeintrag garantiert. Das Setup faengt normale Installerfehler
bereits ab; ein WSL-Abbruch kann nicht durch Bash abgefangen werden.

Vor erneutem Build zuerst diagnostizieren, nicht blind Daten/Lockdateien loeschen:

```powershell
# Read-only WSL inventory in PowerShell:
wsl --list --verbose
wsl --status
```

```bash
# Read-only diagnostics inside the affected Linux distribution:
free -h
df -h / /mnt/c
ps -eo pid,ppid,comm,rss --sort=-rss | head -20
dmesg -T | grep -Ei 'out of memory|oom|killed process'
# If persistent journals exist, also inspect the previous boot:
journalctl -k -b -1 --no-pager | grep -Ei 'out of memory|oom|killed process'
```

Kernel-Logs koennen ohne zusaetzliche Leserechte unzugaenglich und nach einem
VM-Neustart verloren sein. Fehlende Treffer widerlegen OOM nicht. Fuer den
naechsten Start aus PowerShell den Exitcode direkt nach dem WSL-Aufruf mit
`$LASTEXITCODE` erfassen. Keine automatische WSL-RAM-/Swap-/Treiber-Aenderung.
Bei OOM-Indizien zuerst parallele schwere Jobs geordnet beenden und WSL-/Host-
RAM separat pruefen. Keine Schutzgrenze umgehen.

Danach den aktualisierten Installer erneut starten. Bleibt nach dem harten
Abbruch ein `operation.lock` oder ein nativer Ordner ohne Buildnachweis zurueck,
blockiert das Setup absichtlich. Erst sicherstellen, dass kein Build mehr laeuft,
Besitz und Inhalt pruefen und den Bestand sichern; kein pauschales `rm -rf`
auf Tool-, Cache- oder Nutzerdatenordner. Private Go-Toolchain weiterverwenden.

## Version und Quellen

Der [gepruefte cAdvisor-Pin](https://github.com/google/cadvisor/tree/c57813afc32715351dff34ab76a6164bcb0e5c9d)
deklarierte in [go.mod](https://github.com/google/cadvisor/blob/c57813afc32715351dff34ab76a6164bcb0e5c9d/go.mod)
und [cmd/go.mod](https://github.com/google/cadvisor/blob/c57813afc32715351dff34ab76a6164bcb0e5c9d/cmd/go.mod)
Go **1.25.0** als Mindestversion. Ein passendes vorhandenes Go wird bevorzugt.
Das ist keine pauschale Garantie fuer alle kuenftigen Abhaengigkeitsversionen.

Andernfalls kann der bestehende Bootstrap nach Zustimmung **go1.27.3**
aus dem offiziellen Go-Archiv mit fester SHA256 und Groesse privat einrichten.
Das ist eine binaere Buildwerkzeug-Ausnahme, kein Source-Build von Go.
System-Go, globale PATH-Einstellungen und Shellprofile bleiben unveraendert.
Quelle und Pruefwerte: [private_go.py](../../scripts/tools/helpers/private_go.py).

Private Basis:
`~/.openclaw_ultimate_user_data/tools/cadvisor/toolchain/`.
Die Tool-Reserve bleibt bei **8192 MiB**. Der Go-Helper prueft ausserdem
mindestens 4 GiB freien Zielspeicher; dies ist keine additive 12-GiB-Grenze
und keine Garantie fuer den gesamten Buildbedarf. Unter WSL bleibt Windows-
Hostspeicher einzubeziehen. Keinen Speicherwaechter fuer einen Versuch umgehen.

## Build und Betrieb trennen

Der native Build arbeitet aus dem GitHub-Checkout, erzeugt die Webassets mit
dem [gepinnten Upstream-Skript](https://github.com/google/cadvisor/blob/c57813afc32715351dff34ab76a6164bcb0e5c9d/build/assets.sh)
und baut das Modul in `cmd`. Das Skript baut auch den dort versionierten
go-bindata-Helfer. Go-Module kommen ueber den konfigurierten Modulproxy mit
Pruefsummenkontrolle; nicht jeder Dependency-Download kommt direkt von GitHub.
`GOTOOLCHAIN=local` verhindert einen stillen Go-Toolchainwechsel.

Der Installer startet nur die Versionsprobe, keinen Monitoring-Daemon, keine
Host-Erfassung, kein Docker und keine systemd-Unit. Spaetere Hostpfad-/cgroup-/
Socket-Zugriffe sowie Listener/Auth/Firewall muessen gesondert freigegeben
werden. Insbesondere keinen Docker-Socket oder privilegierten Dienst allein
wegen eines erfolgreichen Builds erlauben.

Private Toolchain bleibt bei App-Deinstallation erhalten. Vorhandene Container,
Volumes, Archiv-/Monitoringdaten und /opt-Installationen werden nicht migriert
oder geloescht. Ein fehlgeschlagener Bootstrap erzeugt keinen erfolgreichen
App-Buildnachweis; vorhandene Daten bleiben erhalten.

Offline-Fixtures pruefen Zustimmung, Kindprozess-PATH und Fehlerpfade. Ein
echter Ubuntu-/WSL-Build oder eine Messwertabnahme wurde hier nicht ausgefuehrt.
Siehe [Docker-zu-GitHub-Migration](../DOCKER_TO_GITHUB.md).
