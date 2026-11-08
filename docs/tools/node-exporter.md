# Node Exporter: GitHub-Build und Go-Voraussetzung

Node Exporter stellt Systemmetriken fuer Prometheus bereit, beispielsweise CPU, RAM, Dateisysteme
und Netzwerk. Der Installer kompiliert Node Exporter aus dem gepinnten offiziellen
GitHub-Repository, nicht aus einem Docker-Image. Er startet keinen Exporter und oeffnet keinen Port.

## Fehler: go fehlt

Das Log vom 23.10.2026 um 23:03 zeigt eine fehlende Go-Toolchain, keinen Speicherabbruch. Der
[gepruefte go.mod-Vertrag](https://github.com/prometheus/node_exporter/blob/b9e296a911c8beaf89177362e75cc80bfa89eb7e/go.mod)
verlangt mindestens Go 1.26. Ein beliebiges Ubuntu-Paket `golang-go` kann dafuer zu alt sein; der
Installer installiert/aktualisiert kein System-Go.

Nach Aktualisierung deiner lokalen Setup-Dateien:

```bash
# Preview only: no toolchain/application download or host changes.
bash scripts/tools/node_exporter_install.sh --dry-run
# Explicit consent for the private Go prerequisite, if needed.
bash scripts/tools/node_exporter_install.sh --install-build-deps
```

Eine passende vorhandene Go-Version wird bevorzugt. Fehlt sie oder ist sie zu alt, fragt ein
interaktiver Aufruf mit `[j/N]` nach Zustimmung. Ohne Zustimmung und ohne das explizite Flag erfolgt
kein Toolchain-Download.

## Private Toolchain statt globaler Installation

Der vorhandene [private_go-Bootstrap](../../scripts/tools/helpers/private_go.py) verwendet Go 1.27.3
aus den offiziellen Go-Downloadarchiven, mit festgelegter Groesse und SHA256 aus den
[offiziellen Metadaten](https://go.dev/dl/?mode=json). Diese Compiler-Abhaengigkeit ist ein
offizielles Go-Archiv, kein GitHub- Source-Build des Compilers. Die Primaeranwendung Node Exporter
bleibt ein GitHub-Source-Build. Kein apt, sudo, Container oder globaler PATH-Wechsel.

Ziel der privaten Basis-Toolchain: `~/.openclaw_ultimate_user_data/tools/node_exporter/toolchain/`.
Bereits verifizierte private Toolchains werden erneut geprueft und wiederverwendet. Version und
Architektur muessen passen. Der Buildprozess erhaelt nur lokal PATH/GOROOT; `GOTOOLCHAIN=local`
verhindert unkontrollierte Go-Toolchain-Nachdownloads durch Modulbefehle.

Die Speicher-/RAM-Pruefung erfolgt vor dem Go-Download. Die Reserve bleibt 4 GiB, unter WSL auch auf
C:. Die zuletzt gemeldeten 7,9 GiB haben diese Pruefung bestanden, sind aber kein Grund, die
allgemeine Platzwarnung oder den benoetigten Puffer zu ignorieren. Ein
Netzwerk-/Proxy-/Pruefsummenfehler bleibt ein Fehler im aktuellen Installationslog; kein
Schein-Erfolgsmarker.

Die private Basis-Toolchain bleibt bei einem spaeteren Buildfehler oder bei der Deinstallation von
Node Exporter erhalten. Nur der neue native Build liegt im getrennten `native-github/`-Verzeichnis.
Bestehende Container, Volumes, `/opt`-Daten, Logs und gemeinsame Basiswerkzeuge bleiben unberuehrt.

## Betrieb separat freigeben

Der Installer prueft nach dem Build nur `--version`, keinen laufenden Dienst. Bei einem spaeteren
manuellen Start ausdruecklich lokal binden: `--web.listen-address=127.0.0.1:9100`. Node Exporter
kann sensible Hostmetriken offenlegen; Remote-Zugriff nur ueber freigegebenes VPN oder gesicherten
Proxy. Siehe [Migrationsuebersicht](../DOCKER_TO_GITHUB.md).

<!-- BEGIN GENERATED VPS SSH -->

## VPS ueber SSH bedienen

Voraussetzung: ein bereits gepruefter Setup-Checkout und ein selbst eingerichteter
SSH-Alias `vps` (Benutzer, Host und Schluessel in deiner SSH-Konfiguration).
Alternativ `vps` durch `BENUTZER@VPS_HOST` ersetzen. Den Host-Fingerprint vorher
unabhaengig pruefen; keine Host-Key-Pruefung abschalten. Keine Zugangsdaten in Git.

Auf deinem Client (PowerShell, Linux oder macOS):

```bash
ssh -t vps
```

Danach **im Linux-Terminal des VPS**. Den Pfad bei einem Branch-Checkout anpassen;
ein Windows-/Desktop-Tool wird durch SSH nicht zu einer VPS-Anwendung:

```bash
cd "$HOME/openclaw_ultimate_setup" || exit 1
test -f scripts/tool_commands.py || exit 1
```

Zuerst nur den Offline-Plan lesen (keine Installation und kein Dienststart):

```bash
python3 -I -B scripts/tool_commands.py show node_exporter
```

### SSH-Aktionen: `node_exporter`

Status und Diagnose lesen den privaten Tool-Zustand auf dem VPS:

```bash
python3 -I -B scripts/tool_commands.py run node_exporter --action status
python3 -I -B scripts/tool_commands.py run node_exporter --action doctor
```

Die folgenden Befehle **einzeln und nur nach Freigabe** ausfuehren, nicht als
gemeinsamen Ablauf: Installation, spaeter Update oder bewusst Deinstallation.
Vorher Quellen, Lizenz, Ressourcen und Daten-Erhaltungsregeln dieser Anleitung pruefen.

Installieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run node_exporter --action install --apply --confirm node_exporter:install
```

Aktualisieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run node_exporter --action update --apply --confirm node_exporter:update
```

Deinstallieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run node_exporter --action uninstall --apply --confirm node_exporter:uninstall
```

Fehlende Build-Abhaengigkeiten stoppen den Versuch. Nur fuer Install/Update
`--install-build-deps` nach separater Download-Freigabe ergaenzen. Kein Auto-Yes,
kein Docker-Fallback; Source-Build/Status ist keine erfolgreiche Runtime-Abnahme.

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](../HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](../generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
