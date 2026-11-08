# Mosquitto: GitHub-Build unter Ubuntu/WSL

Mosquitto ist ein MQTT-Broker fuer den Nachrichtenaustausch, beispielsweise zwischen Home Assistant,
Sensoren und Automatisierungen. Der Setup-Installer kompiliert die Anwendung aus dem gepinnten
offiziellen GitHub-Repository; er installiert weder ein Docker-Image noch den Broker als
Ubuntu-Paket.

## Fehler: cmake fehlt

Das Log vom 23.10.2026 um 22:03 zeigt einen Abbruch wegen des fehlenden Buildwerkzeugs `cmake`. Die
Speicherpruefung war mit rund 7,9 GiB auf C: oberhalb der fuer Mosquitto verlangten 4 GiB. Die
groessere Warnschwelle von 50 GiB ist eine allgemeine Vorsichtsmeldung, nicht der Abbruchgrund.

Der gepinnte
[CMake-Vertrag](https://github.com/eclipse-mosquitto/mosquitto/blob/83f2620f0b955b89aadce32cceb96a8e81950f5e/CMakeLists.txt)
verlangt CMake >=3.24, C-/C++-Compiler sowie unter anderem OpenSSL und cJSON. Das aktivierte
[SQLite-Persistenzplugin](https://github.com/eclipse-mosquitto/mosquitto/blob/83f2620f0b955b89aadce32cceb96a8e81950f5e/plugins/CMakeLists.txt)
braucht auch SQLite-Header. Nur cmake nachzuinstallieren kann deshalb zum naechsten Fehler wegen
fehlender Entwicklungsbibliotheken fuehren.

## Gefuehrte Reparatur

Nach Aktualisierung der lokalen Setup-Dateien Mosquitto im Tools-Menue erneut installieren. Unter
Ubuntu 24.04 zeigt der Installer fehlende Buildpakete an und fragt bei einem interaktiven Terminal
mit `[j/N]` nach Zustimmung. Ohne Zustimmung erfolgt keine apt-Aktion. In nichtinteraktiven Aufrufen
muss die Freigabe ausdruecklich uebergeben werden:

```bash
# Preview only: no apt, source download or build.
bash scripts/tools/mosquitto_install.sh --dry-run
# Explicit consent for the displayed build dependencies, then GitHub build.
bash scripts/tools/mosquitto_install.sh --install-build-deps
```

Die festgelegte Paketliste enthaelt ausschliesslich Buildwerkzeuge und Bibliotheken: `git`, `cmake`,
`build-essential`, `pkg-config`, `libssl-dev`, `libcjson-dev`, `libsqlite3-dev`, `libedit-dev`,
`libmicrohttpd-dev`. Bereits installierte Pakete werden nicht erneut angefordert. Die Reparatur
fuehrt `apt-get update` und eine Installation nur fehlender Pakete mit
`--no-remove --no-install-recommends` aus. apt kann abhaengige Pakete aktualisieren. Root/sudo wird
nur fuer diesen freigegebenen Schritt verwendet; der GitHub-Build wird dadurch nicht zu einem
sudo-Build.

Wer die Basiswerkzeuge separat einrichten moechte:

```bash
sudo apt-get -o DPkg::Lock::Timeout=300 update
sudo apt-get -o DPkg::Lock::Timeout=300 install --no-remove --no-install-recommends \
  git cmake build-essential pkg-config libssl-dev libcjson-dev libsqlite3-dev \
  libedit-dev libmicrohttpd-dev
bash scripts/tools/mosquitto_install.sh
```

Andere Distributionen/Versionen richten passende Abhaengigkeiten selbst ein; der gefuehrte
apt-Schritt gilt nur fuer Ubuntu 24.04. Insbesondere liefert Ubuntu 22.04 nicht automatisch die hier
benoetigte CMake-Version. Es werden keine fremden Paketquellen, globalen Python- oder
Node-Laufzeiten eingerichtet.

## Grenzen und Daten

Speicher- und RAM-Vorpruefung erfolgen vor der Paketinstallation. Ein Fehler oder eine Ablehnung
bleibt im aktuellen Operationslog sichtbar; es entsteht kein Installationsmarker. Fehler nach dem
Quellen-Download entfernen nur den neu angelegten privaten Buildordner. Gemeinsame Basiswerkzeuge
bleiben auch bei einem Buildfehler oder einer spaeteren Deinstallation installiert.

Kein Brokerstart, kein Port 1883/9001, keine Benutzeranlage und kein Zugriff auf alte Container,
`/opt/mosquitto`, Volumes oder Secrets. Konfiguration, Authentifizierung und localhost-/VPN-Bindung
werden separat eingerichtet. Siehe [Migrationsuebersicht](../DOCKER_TO_GITHUB.md).

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
python3 -I -B scripts/tool_commands.py show mosquitto
```

### SSH-Aktionen: `mosquitto`

Status und Diagnose lesen den privaten Tool-Zustand auf dem VPS:

```bash
python3 -I -B scripts/tool_commands.py run mosquitto --action status
python3 -I -B scripts/tool_commands.py run mosquitto --action doctor
```

Die folgenden Befehle **einzeln und nur nach Freigabe** ausfuehren, nicht als
gemeinsamen Ablauf: Installation, spaeter Update oder bewusst Deinstallation.
Vorher Quellen, Lizenz, Ressourcen und Daten-Erhaltungsregeln dieser Anleitung pruefen.

Installieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run mosquitto --action install --apply --confirm mosquitto:install
```

Aktualisieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run mosquitto --action update --apply --confirm mosquitto:update
```

Deinstallieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run mosquitto --action uninstall --apply --confirm mosquitto:uninstall
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
