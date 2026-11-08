# Zigbee2MQTT: GitHub-Build und private Node-/pnpm-Basis

Zigbee2MQTT verbindet Zigbee-Geraete ueber einen eigenen Koordinator mit einem MQTT-Broker. Damit
lassen sich beispielsweise Sensoren und Schalter in Home Assistant einbinden. Ein erfolgreicher
Build allein verbindet noch keine Hardware und ersetzt weder Koordinator noch Broker.

## Fehler im Log: node fehlt

Der Versuch vom 24.10.2026 um 01:38 scheiterte am fehlenden Node.js. Die erste Speicherpruefung war
knapp erfuellt: Im Log stehen 8192 MiB auf Windows C: bei ebenfalls 8192 MiB Mindestreserve. Danach
kann auch noch das exakt benoetigte pnpm fehlen.

Nach Uebernahme der aktualisierten Setup-Dateien:

```bash
bash scripts/tools/zigbee2mqtt_install.sh --dry-run
# Explicit consent for private build prerequisites:
bash scripts/tools/zigbee2mqtt_install.sh --install-build-deps
bash scripts/tools/zigbee2mqtt_doctor.sh
```

Ohne Flag fragt ein interaktives Terminal nach Zustimmung. Ohne Zustimmung oder bei
nichtinteraktiver Ausfuehrung ohne Flag erfolgt kein Download. Der Dry-Run bleibt auch mit Flag ohne
Installation.

## Fehler im Log: libatomic.so.1 fehlt (25.10.2026)

### Versuch um 00:48: keine Zustimmung erkannt

Dieser spaetere Versuch endet bereits vor dem Download. Er prueft deshalb die libatomic-Reparatur
noch nicht. Das alte Log unterscheidet leere Eingabe, Ablehnung und EOF nicht; daraus laesst sich
kein konkreter Eingabefehler ableiten. Die Rueckfragen stehen jetzt als sofort ausgegebene eigene
Zeilen im Terminal und Log. Sie warten auf Enter; ungueltige Antworten werden erneut abgefragt.
Leere Eingabe, ausdrueckliche Ablehnung, EOF und fehlendes Terminal erhalten unterschiedliche
Meldungen. Eine leere Eingabe bleibt sicherheitshalber Nein.

Beim erneuten interaktiven Aufruf die Node-/pnpm-Frage mit `j` und Enter beantworten. Alternativ
genehmigt `--install-build-deps` gezielt diesen Bootstrap; die apt-Reparatur erfordert weiterhin
eine separate Zustimmung. Bei EOF aus dem Menue den Installer direkt in einem interaktiven Terminal
starten. Keine automatische Zustimmung und keine Deinstallation wegen Ablehnung.

Im neuen Log startet Node, aber die pnpm-Binaerdatei scheitert bereits bei `--version` mit Exit 127.
Das ist eine fehlende Systembibliothek, noch kein Zigbee2MQTT-Buildfehler. Der Bootstrap erkennt
jetzt diese konkrete Meldung, zeigt den Reparaturbefehl im aktuellen Log und fragt separat mit
`[j/N]`. Der gefuehrte apt-Weg ist auf Ubuntu 24.04 und `libatomic1` begrenzt. Unbekannte
Loaderfehler loesen keine automatische Paketinstallation aus.

Manuelle Reparatur im betroffenen Ubuntu-/WSL-System:

```bash
sudo apt-get -o DPkg::Lock::Timeout=300 install --no-remove --no-install-recommends -y libatomic1
bash scripts/tools/zigbee2mqtt_install.sh --install-build-deps
```

Fuer bewusst nichtinteraktive Zustimmung kann beim Installer `ZIGBEE2MQTT_INSTALL_RUNTIME_LIBS=1`
gesetzt werden; `0` lehnt ab, `ask` ist Standard. Das Node-/pnpm-Downloadflag allein genehmigt diese
Systemreparatur nicht. Status-/Aktivierungspruefungen installieren nie Pakete, auch nicht mit
gesetztem Wert `1`; Dry-Run bleibt unveraendert schreibfrei. Nach apt wird die Version genau einmal
erneut geprueft. Ohne erfolgreiche Pruefung entsteht kein fertiger Toolchain-Marker. Gemeinsame
Systembibliotheken bleiben bei Deinstallation erhalten; bestehende Daten werden nicht geloescht.
Hier wurden weder apt noch ein echter WSL-Build ausgefuehrt.

## Versionsvertrag und Quellen

Der feste
[GitHub-Quellstand](https://github.com/Koenkk/zigbee2mqtt/tree/344b6e03b43644c97154a72ca9eae17193c553a2)
ist Version 2.14.2. Seine
[package.json](https://github.com/Koenkk/zigbee2mqtt/blob/344b6e03b43644c97154a72ca9eae17193c553a2/package.json)
nennt pnpm 11.26.0. Dessen Node-Anforderung ist mindestens 22.13. Unser Installer akzeptiert
konservativ Node 22 ab 22.13 oder die Reihe 24; dies ist enger als der ungewoehnlich weit gefasste
Zigbee2MQTT-Engine-Ausdruck. Passende vorhandene Node-/pnpm-Werkzeuge werden gemeinsam bevorzugt.

Fehlt eine passende Kombination, kann der Installer fuer Linux amd64/arm64 nach Zustimmung eine
private Kombination bereitstellen:

- Node **22.23.4**, binaere Runtime von [nodejs.org](https://nodejs.org/dist/v22.23.4/), feste
  Groesse und [SHA256](https://nodejs.org/dist/v22.23.4/SHASUMS256.txt).
- pnpm **11.26.0**, binaeres Paket aus dem
  [offiziellen GitHub-Release](https://github.com/pnpm/pnpm/releases/tag/v11.26.0), feste Groesse
  und SHA256.

Das sind ausdruecklich Binaer-Ausnahmen fuer Buildwerkzeuge, keine Source- Builds von Node oder
pnpm. Zigbee2MQTT selbst wird aus GitHub gebaut, nicht aus einem Docker-Image. Paketabhaengigkeiten
kommen ueber pnpm und die gefrorene Lockdatei; der gesamte Abhaengigkeitsgraph ist kein
ausschliesslicher GitHub-Source-Build. Kein `curl | bash`, nvm, globales npm-Installieren oder
automatisches Corepack-Upgrade wird verwendet.

Die Basis liegt unter `~/.openclaw_ultimate_user_data/tools/zigbee2mqtt/toolchain/`. Nur
Build-Unterprozesse erhalten deren PATH. System-Node, Shellprofile und globaler PATH bleiben
unveraendert. npm/Corepack werden nicht installiert. Bei Wiederverwendung werden private Dateien
erneut gegen den gespeicherten Integritaetsnachweis geprueft; dies schuetzt nicht vor einem lokalen
Angreifer, der gleichzeitig Dateien und Nachweise manipulieren kann.

## Speicherplatz zuerst freimachen

Vor einem neuen Node-/pnpm-Bootstrap werden **9216 MiB** freier Zielspeicher und unter WSL auch
freier Windows-Host-Speicher verlangt: 8192 MiB Reserve plus 1024 MiB Download-/Entpackpuffer.
Gegenueber dem Log fehlen mindestens 1024 MiB. Mehr Puffer freizumachen ist sinnvoll; die
Vorpruefung garantiert keinen erfolgreichen Build bei weiter wachsendem Speicherbedarf. Die
Schutzgrenze wird nicht abgesenkt.

Die Archive werden vor Ausfuehrung gegen Groesse und SHA256 geprueft. Abgebrochene neue Downloads
hinterlassen keinen fertigen Toolchain-Marker. Eine erfolgreich eingerichtete private Basis bleibt
bei spaeterem App-Fehler und App-Deinstallation erhalten. Bestehende Daten, Logs und Container
bleiben unberuehrt; App-Rollback betrifft nur die neu angelegten App-Dateien.

## Build und Betrieb bleiben getrennt

Der Build fuehrt `pnpm install --frozen-lockfile` und `pnpm run build` aus. Upstream baut dabei
TypeScript und schreibt mit `node index.js writehash` den Quellenhash; siehe
[Einstiegspunkt am Pin](https://github.com/Koenkk/zigbee2mqtt/blob/344b6e03b43644c97154a72ca9eae17193c553a2/index.js).
Keine Anwendung, kein Pairing, kein MQTT-Client, Webfrontend oder Dienst wird gestartet. Keine
USB-/Seriellrechte werden veraendert. Abhaengigkeits-Buildskripte sind ausfuehrbarer Fremdcode,
keine Sandbox.

Vor einem spaeteren manuellen Betrieb separat pruefen: stabiler Koordinator- Pfad,
USB-/WSL-Durchreichung, Firmware, Broker und Zugangsdaten, Zigbee- Netzwerkschluessel, Backups,
interne Frontend-Bindung und Authentifizierung. Vorhandene Konfigurationen nicht durch Beispielwerte
ueberschreiben. Ein Buildmarker ist keine Hardware- oder Betriebsabnahme. Der echte
Ubuntu-/WSL-Build wurde fuer diese Aenderung nicht ausgefuehrt.

Siehe [Docker-zu-GitHub-Migration](../DOCKER_TO_GITHUB.md).

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
python3 -I -B scripts/tool_commands.py show zigbee2mqtt
```

### SSH-Aktionen: `zigbee2mqtt`

Status und Diagnose lesen den privaten Tool-Zustand auf dem VPS:

```bash
python3 -I -B scripts/tool_commands.py run zigbee2mqtt --action status
python3 -I -B scripts/tool_commands.py run zigbee2mqtt --action doctor
```

Die folgenden Befehle **einzeln und nur nach Freigabe** ausfuehren, nicht als
gemeinsamen Ablauf: Installation, spaeter Update oder bewusst Deinstallation.
Vorher Quellen, Lizenz, Ressourcen und Daten-Erhaltungsregeln dieser Anleitung pruefen.

Installieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run zigbee2mqtt --action install --apply --confirm zigbee2mqtt:install
```

Aktualisieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run zigbee2mqtt --action update --apply --confirm zigbee2mqtt:update
```

Deinstallieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run zigbee2mqtt --action uninstall --apply --confirm zigbee2mqtt:uninstall
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
