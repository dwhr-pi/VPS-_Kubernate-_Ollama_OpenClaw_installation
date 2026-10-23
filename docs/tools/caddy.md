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

## Kein automatischer Webserverbetrieb

Der Installer fuehrt nach dem Build lediglich `caddy version` aus. Er
startet keinen Server, oeffnet keine Ports 80/443/2019, erzeugt keinen
Caddyfile, fordert keine ACME-Zertifikate an und liest keine vorhandenen
Zertifikatsdaten. systemd, Domain, TLS, Authentifizierung, Reverse-Proxy-Ziele
und Firewall muessen separat geprueft und freigegeben werden. Die Admin-API
nicht ungeschuetzt oeffentlich erreichbar machen.

Siehe [Docker-zu-GitHub-Migration](../DOCKER_TO_GITHUB.md) und
[Node Exporter mit derselben Go-Voraussetzung](node-exporter.md).
