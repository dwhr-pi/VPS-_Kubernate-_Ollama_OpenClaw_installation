# Node-RED: GitHub-Build mit privater Node-/npm-Basis

Node-RED verbindet im spaeteren Betrieb Dienste und Geraete ueber Flows.
Der Installer baut die Anwendung, aktiviert aber keine Flows, Geraetezugriffe,
Editoroberflaeche oder systemd-Dienste.

## Fehler vom 25.10.2026: node fehlt

Das Log um 02:47 zeigt fehlendes Node.js vor dem Build, keinen Speichermangel.
Der Installer kann jetzt nach Zustimmung eine private Node-/npm-Basis
bereitstellen. Der Zigbee2MQTT-pnpm-Weg bleibt davon getrennt.

Nach Uebernahme der aktualisierten Setup-Dateien:

```bash
bash scripts/tools/node_red_install.sh --dry-run
# Explicit consent for private Node/npm:
bash scripts/tools/node_red_install.sh --install-build-deps
bash scripts/tools/node_red_doctor.sh
```

Ohne Flag fragt ein interaktives Terminal mit `[j/N]`; Enter oder EOF lehnt ab.
Dry-Run bleibt auch mit Flag schreibfrei. Build-/Status-Aktivierung laedt
keine fehlende Toolchain still herunter. Eine kompatible vorhandene Kombination
wird bevorzugt; die konservative Auswahl akzeptiert Node 22 ab 22.13 oder
Reihe 24, zusammen mit npm 10.9.9.

## Quellen und Paketmanager-Vertrag

Die [package.json am GitHub-Pin](https://github.com/node-red/node-red/blob/df0a87cce1a243e21a2e0eb0fdbdbb8c4732392f/package.json)
beschreibt Node-RED 5.0.9 mit Node >=22.9 und einem npm-Buildskript.
Unser privater Bootstrap verwendet **Node 22.23.4 mit gebuendeltem npm 10.9.9**
aus dem offiziellen [Node-Archiv](https://nodejs.org/dist/v22.23.4/).
Groesse und [SHA256](https://nodejs.org/dist/v22.23.4/SHASUMS256.txt) werden vor
Ausfuehrung geprueft. Die gebuendelte npm-Version ist in
[Node deps/npm/package.json](https://github.com/nodejs/node/blob/v22.23.4/deps/npm/package.json)
nachvollziehbar. Sie ist unsere Bootstrap-Version, keine behauptete exakte
Upstream-Anforderung an den Build-Paketmanager. Die npm-Dependency in der
Node-RED-package.json ist davon zu unterscheiden.

Node/npm sind binaere Buildwerkzeug-Ausnahmen; Node-RED selbst wird aus dem
gepinnten GitHub-Checkout gebaut. Kein Docker, nvm, globales npm-Installieren,
Corepack-Update oder System-Node-Ersatz. Dependency-Pakete duerfen aus der npm-
Registry kommen. Installations-/Buildskripte sind ausfuehrbarer Fremdcode,
keine Sandbox. Kein Node-/npm-Source-Build oder vollstaendiger Livebuild belegt.

Nur regulaere Node-/npm-Dateien werden aus dem Archiv uebernommen, keine
Archiv-Symlinks oder Spezialdateien. Ein eigener lokaler npm-Launcher verwendet
die zugehoerige Node-Binaerdatei; er installiert keine globalen Programme.
Private Dateien und Versionen werden vor Wiederverwendung erneut geprueft.

## Speicher und Datenerhalt

Neue Bootstrap-Reserve: **9216 MiB**, also 8192 MiB Toolreserve plus 1024 MiB
Download-/Entpackpuffer. Unter WSL muss auch Windows C: diese Grenze erfuellen.
Die Schutzgrenze wird nicht abgesenkt; waehrend des Builds kann weiterer
Speicher benoetigt werden.

Private Basis unter
`~/.openclaw_ultimate_user_data/tools/node_red/toolchain/`.
Nur Build-Kindprozesse bekommen deren PATH. System-Node und Shellprofile bleiben
unveraendert. Fehlgeschlagenes neues Staging wird entfernt; kein fertiger
Toolchain-Marker vor erfolgreicher Versionspruefung. Eine fertige Toolchain
bleibt bei spaeterem App-Fehler oder App-Deinstallation erhalten.

Fehlt beim privaten Versionstest `libatomic.so.1`, wird der gezielte
Ubuntu-24.04-Reparaturweg fuer `libatomic1` separat bestaetigt. Das Downloadflag
allein genehmigt kein apt. Optionaler ausdruecklicher Wert:
`NODE_RED_INSTALL_RUNTIME_LIBS=1`; Standard `ask`, `0` lehnt ab.
Status prueft nur und installiert auch mit gesetztem Wert `1` keine Bibliothek.
Gemeinsame Systembibliotheken bleiben bei Deinstallation erhalten.

## Vor spaeterem Start

Bestehende `.node-red`-Verzeichnisse, Flows, Credential-Dateien, Container und
Volumes werden nicht geaendert oder importiert. Der Paketbuild startet weder
`npm start` noch `red.js`. Kein Port wird freigegeben und keine Nachricht gesendet.

Vor produktivem Betrieb separat pruefen: geschuetztes Benutzerverzeichnis,
Credential-Verschluesselungsschluessel, Editor-/API-Authentifizierung, interne
Bindung, TLS/VPN, erlaubte Nodes, ausgehende Verbindungen und Restore.
Importierte Flows koennen Shellbefehle und externe Aktionen ausloesen;
deshalb nicht ungeprueft deployen. Buildbereitschaft ist keine Betriebsabnahme.

Offline-Fixtures pruefen Zustimmung, Archivschutz, Integritaet und Fehlerpfade.
Ein echter Ubuntu-/WSL-Build wurde hier nicht ausgefuehrt.
Siehe [Docker-zu-GitHub-Migration](../DOCKER_TO_GITHUB.md).
