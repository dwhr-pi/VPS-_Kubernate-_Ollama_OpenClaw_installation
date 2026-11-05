# Node-RED: GitHub-Build mit privater Node-/npm-Basis

Node-RED verbindet im spaeteren Betrieb Dienste und Geraete ueber Flows. Der Installer baut die
Anwendung, aktiviert aber keine Flows, Geraetezugriffe, Editoroberflaeche oder systemd-Dienste.

## Fehler vom 25.10.2026: node fehlt

Das Log um 02:47 zeigt fehlendes Node.js vor dem Build, keinen Speichermangel. Der Installer kann
jetzt nach Zustimmung eine private Node-/npm-Basis bereitstellen. Der Zigbee2MQTT-pnpm-Weg bleibt
davon getrennt.

Nach Uebernahme der aktualisierten Setup-Dateien:

```bash
bash scripts/tools/node_red_install.sh --dry-run
# Explicit consent for private Node/npm:
bash scripts/tools/node_red_install.sh --install-build-deps
bash scripts/tools/node_red_doctor.sh
```

Ohne Flag fragt ein interaktives Terminal mit `[j/N]`; Enter oder EOF lehnt ab. Dry-Run bleibt auch
mit Flag schreibfrei. Build-/Status-Aktivierung laedt keine fehlende Toolchain still herunter. Eine
kompatible vorhandene Kombination wird bevorzugt; die konservative Auswahl akzeptiert Node 22 ab
22.13 oder Reihe 24, zusammen mit npm 10.9.9.

## Quellen und Paketmanager-Vertrag

### Fehler um 22:25: double-loading config /dev/null

Node **22.23.4** wurde erfolgreich geprueft. npm brach vor der eigentlichen Konfigurationsaufloesung
ab, weil der Bootstrap dieselbe Datei `/dev/null` gleichzeitig fuer `userconfig` und `globalconfig`
setzte. Das war ein Fehler unserer Bootstrap-Umgebung, kein nachgewiesener Node-/npm-Defekt, kein
Speicherplatzproblem und kein Grund, eigene `.npmrc`-Dateien zu loeschen.

Versionspruefungen erhalten jetzt zwei **unterschiedliche leere Dateien** in einem privaten
temporaeren Verzeichnis. Dieses Verzeichnis wird auch nach Fehlern entfernt. Fuer `npm ci` und den
Build liegen getrennte leere User-/Global- Konfigurationen im privaten
`_build/.build-home/.npm-config/`-Arbeitsbereich. Case-Varianten geerbter Config-Pfadvariablen
werden nur im Kindprozess ersetzt. Ein bestehender nichtleerer Konfigurationspfad wird nicht
ueberschrieben. Persoenliche und globale `.npmrc` bleiben unangetastet; Projektkonfigurationen des
geprueften Checkouts sind davon nicht pauschal ausgeschlossen.

Nach Uebernahme der aktualisierten Skripte erneut:

```bash
bash scripts/tools/node_red_install.sh --install-build-deps
```

Ein bereits fertig validierter privater Bestand wird weiter geprueft und wiederverwendet. Das
fehlgeschlagene Download-Staging dieses Logs wurde nicht als fertige Toolchain freigegeben; deshalb
kann ein erneuter Download noetig sein. Keine globale npm-Neuinstallation, kein
`npm cache clean --force` und kein Entfernen des Benutzerprofils erforderlich. Ein echter
Node-RED-Build bleibt separat abzunehmen; Offline-Fixtures testen den Konfigurationsvertrag.

Die
[package.json am GitHub-Pin](https://github.com/node-red/node-red/blob/df0a87cce1a243e21a2e0eb0fdbdbb8c4732392f/package.json)
beschreibt Node-RED 5.0.9 mit Node >=22.9 und einem npm-Buildskript. Unser privater Bootstrap
verwendet **Node 22.23.4 mit gebuendeltem npm 10.9.9** aus dem offiziellen
[Node-Archiv](https://nodejs.org/dist/v22.23.4/). Groesse und
[SHA256](https://nodejs.org/dist/v22.23.4/SHASUMS256.txt) werden vor Ausfuehrung geprueft. Die
gebuendelte npm-Version ist in
[Node deps/npm/package.json](https://github.com/nodejs/node/blob/v22.23.4/deps/npm/package.json)
nachvollziehbar. Sie ist unsere Bootstrap-Version, keine behauptete exakte Upstream-Anforderung an
den Build-Paketmanager. Die npm-Dependency in der Node-RED-package.json ist davon zu unterscheiden.

Node/npm sind binaere Buildwerkzeug-Ausnahmen; Node-RED selbst wird aus dem gepinnten
GitHub-Checkout gebaut. Kein Docker, nvm, globales npm-Installieren, Corepack-Update oder
System-Node-Ersatz. Dependency-Pakete duerfen aus der npm- Registry kommen.
Installations-/Buildskripte sind ausfuehrbarer Fremdcode, keine Sandbox. Kein Node-/npm-Source-Build
oder vollstaendiger Livebuild belegt.

Nur regulaere Node-/npm-Dateien werden aus dem Archiv uebernommen, keine Archiv-Symlinks oder
Spezialdateien. Ein eigener lokaler npm-Launcher verwendet die zugehoerige Node-Binaerdatei; er
installiert keine globalen Programme. Private Dateien und Versionen werden vor Wiederverwendung
erneut geprueft.

## Speicher und Datenerhalt

Neue Bootstrap-Reserve: **9216 MiB**, also 8192 MiB Toolreserve plus 1024 MiB
Download-/Entpackpuffer. Unter WSL muss auch Windows C: diese Grenze erfuellen. Die Schutzgrenze
wird nicht abgesenkt; waehrend des Builds kann weiterer Speicher benoetigt werden.

Private Basis unter `~/.openclaw_ultimate_user_data/tools/node_red/toolchain/`. Nur
Build-Kindprozesse bekommen deren PATH. System-Node und Shellprofile bleiben unveraendert.
Fehlgeschlagenes neues Staging wird entfernt; kein fertiger Toolchain-Marker vor erfolgreicher
Versionspruefung. Eine fertige Toolchain bleibt bei spaeterem App-Fehler oder App-Deinstallation
erhalten.

Fehlt beim privaten Versionstest `libatomic.so.1`, wird der gezielte Ubuntu-24.04-Reparaturweg fuer
`libatomic1` separat bestaetigt. Das Downloadflag allein genehmigt kein apt. Optionaler
ausdruecklicher Wert: `NODE_RED_INSTALL_RUNTIME_LIBS=1`; Standard `ask`, `0` lehnt ab. Status prueft
nur und installiert auch mit gesetztem Wert `1` keine Bibliothek. Gemeinsame Systembibliotheken
bleiben bei Deinstallation erhalten.

## Vor spaeterem Start

Bestehende `.node-red`-Verzeichnisse, Flows, Credential-Dateien, Container und Volumes werden nicht
geaendert oder importiert. Der Paketbuild startet weder `npm start` noch `red.js`. Kein Port wird
freigegeben und keine Nachricht gesendet.

Vor produktivem Betrieb separat pruefen: geschuetztes Benutzerverzeichnis,
Credential-Verschluesselungsschluessel, Editor-/API-Authentifizierung, interne Bindung, TLS/VPN,
erlaubte Nodes, ausgehende Verbindungen und Restore. Importierte Flows koennen Shellbefehle und
externe Aktionen ausloesen; deshalb nicht ungeprueft deployen. Buildbereitschaft ist keine
Betriebsabnahme.

Offline-Fixtures pruefen Zustimmung, Archivschutz, Integritaet und Fehlerpfade. Ein echter
Ubuntu-/WSL-Build wurde hier nicht ausgefuehrt. Siehe
[Docker-zu-GitHub-Migration](../DOCKER_TO_GITHUB.md).

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
python3 -I -B scripts/tool_commands.py show node_red
```

### SSH-Aktionen: `node_red`

Status und Diagnose lesen den privaten Tool-Zustand auf dem VPS:

```bash
python3 -I -B scripts/tool_commands.py run node_red --action status
python3 -I -B scripts/tool_commands.py run node_red --action doctor
```

Die folgenden Befehle **einzeln und nur nach Freigabe** ausfuehren, nicht als
gemeinsamen Ablauf: Installation, spaeter Update oder bewusst Deinstallation.
Vorher Quellen, Lizenz, Ressourcen und Daten-Erhaltungsregeln dieser Anleitung pruefen.

Installieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run node_red --action install --apply --confirm node_red:install
```

Aktualisieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run node_red --action update --apply --confirm node_red:update
```

Deinstallieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run node_red --action uninstall --apply --confirm node_red:uninstall
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
