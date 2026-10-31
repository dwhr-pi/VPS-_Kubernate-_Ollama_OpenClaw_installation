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
