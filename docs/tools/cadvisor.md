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
