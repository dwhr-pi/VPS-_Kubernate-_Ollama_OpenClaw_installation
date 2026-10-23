# Zigbee2MQTT: GitHub-Build und private Node-/pnpm-Basis

Zigbee2MQTT verbindet Zigbee-Geraete ueber einen eigenen Koordinator mit
einem MQTT-Broker. Damit lassen sich beispielsweise Sensoren und Schalter
in Home Assistant einbinden. Ein erfolgreicher Build allein verbindet
noch keine Hardware und ersetzt weder Koordinator noch Broker.

## Fehler im Log: node fehlt

Der Versuch vom 24.10.2026 um 01:38 scheiterte am fehlenden Node.js.
Die erste Speicherpruefung war knapp erfuellt: Im Log stehen 8192 MiB
auf Windows C: bei ebenfalls 8192 MiB Mindestreserve.
Danach kann auch noch das exakt benoetigte pnpm fehlen.

Nach Uebernahme der aktualisierten Setup-Dateien:

```bash
bash scripts/tools/zigbee2mqtt_install.sh --dry-run
# Explicit consent for private build prerequisites:
bash scripts/tools/zigbee2mqtt_install.sh --install-build-deps
bash scripts/tools/zigbee2mqtt_doctor.sh
```

Ohne Flag fragt ein interaktives Terminal nach Zustimmung. Ohne Zustimmung
oder bei nichtinteraktiver Ausfuehrung ohne Flag erfolgt kein Download.
Der Dry-Run bleibt auch mit Flag ohne Installation.

## Versionsvertrag und Quellen

Der feste [GitHub-Quellstand](https://github.com/Koenkk/zigbee2mqtt/tree/344b6e03b43644c97154a72ca9eae17193c553a2)
ist Version 2.14.2. Seine [package.json](https://github.com/Koenkk/zigbee2mqtt/blob/344b6e03b43644c97154a72ca9eae17193c553a2/package.json)
nennt pnpm 11.26.0. Dessen Node-Anforderung ist mindestens 22.13.
Unser Installer akzeptiert konservativ Node 22 ab 22.13 oder die Reihe 24;
dies ist enger als der ungewoehnlich weit gefasste Zigbee2MQTT-Engine-Ausdruck.
Passende vorhandene Node-/pnpm-Werkzeuge werden gemeinsam bevorzugt.

Fehlt eine passende Kombination, kann der Installer fuer Linux amd64/arm64
nach Zustimmung eine private Kombination bereitstellen:

- Node **22.23.4**, binaere Runtime von [nodejs.org](https://nodejs.org/dist/v22.23.4/), feste Groesse und [SHA256](https://nodejs.org/dist/v22.23.4/SHASUMS256.txt).
- pnpm **11.26.0**, binaeres Paket aus dem [offiziellen GitHub-Release](https://github.com/pnpm/pnpm/releases/tag/v11.26.0), feste Groesse und SHA256.

Das sind ausdruecklich Binaer-Ausnahmen fuer Buildwerkzeuge, keine Source-
Builds von Node oder pnpm. Zigbee2MQTT selbst wird aus GitHub gebaut, nicht
aus einem Docker-Image. Paketabhaengigkeiten kommen ueber pnpm und die
gefrorene Lockdatei; der gesamte Abhaengigkeitsgraph ist kein ausschliesslicher
GitHub-Source-Build. Kein `curl | bash`, nvm, globales npm-Installieren oder
automatisches Corepack-Upgrade wird verwendet.

Die Basis liegt unter
`~/.openclaw_ultimate_user_data/tools/zigbee2mqtt/toolchain/`.
Nur Build-Unterprozesse erhalten deren PATH. System-Node, Shellprofile und
globaler PATH bleiben unveraendert. npm/Corepack werden nicht installiert.
Bei Wiederverwendung werden private Dateien erneut gegen den gespeicherten
Integritaetsnachweis geprueft; dies schuetzt nicht vor einem lokalen Angreifer,
der gleichzeitig Dateien und Nachweise manipulieren kann.

## Speicherplatz zuerst freimachen

Vor einem neuen Node-/pnpm-Bootstrap werden **9216 MiB** freier Zielspeicher
und unter WSL auch freier Windows-Host-Speicher verlangt: 8192 MiB Reserve
plus 1024 MiB Download-/Entpackpuffer. Gegenueber dem Log fehlen mindestens
1024 MiB. Mehr Puffer freizumachen ist sinnvoll; die Vorpruefung garantiert
keinen erfolgreichen Build bei weiter wachsendem Speicherbedarf.
Die Schutzgrenze wird nicht abgesenkt.

Die Archive werden vor Ausfuehrung gegen Groesse und SHA256 geprueft.
Abgebrochene neue Downloads hinterlassen keinen fertigen Toolchain-Marker.
Eine erfolgreich eingerichtete private Basis bleibt bei spaeterem App-Fehler
und App-Deinstallation erhalten. Bestehende Daten, Logs und Container bleiben
unberuehrt; App-Rollback betrifft nur die neu angelegten App-Dateien.

## Build und Betrieb bleiben getrennt

Der Build fuehrt `pnpm install --frozen-lockfile` und `pnpm run build` aus.
Upstream baut dabei TypeScript und schreibt mit `node index.js writehash`
den Quellenhash; siehe [Einstiegspunkt am Pin](https://github.com/Koenkk/zigbee2mqtt/blob/344b6e03b43644c97154a72ca9eae17193c553a2/index.js).
Keine Anwendung, kein Pairing, kein MQTT-Client, Webfrontend oder Dienst
wird gestartet. Keine USB-/Seriellrechte werden veraendert.
Abhaengigkeits-Buildskripte sind ausfuehrbarer Fremdcode, keine Sandbox.

Vor einem spaeteren manuellen Betrieb separat pruefen: stabiler Koordinator-
Pfad, USB-/WSL-Durchreichung, Firmware, Broker und Zugangsdaten, Zigbee-
Netzwerkschluessel, Backups, interne Frontend-Bindung und Authentifizierung.
Vorhandene Konfigurationen nicht durch Beispielwerte ueberschreiben.
Ein Buildmarker ist keine Hardware- oder Betriebsabnahme. Der echte
Ubuntu-/WSL-Build wurde fuer diese Aenderung nicht ausgefuehrt.

Siehe [Docker-zu-GitHub-Migration](../DOCKER_TO_GITHUB.md).
