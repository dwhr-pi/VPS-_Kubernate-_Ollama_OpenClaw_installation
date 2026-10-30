# SD.Next aus GitHub, ohne Docker

## Fehlendes ensurepip / venv (19.10.2026)

Fehlt `ensurepip`, bietet der Installer bei einem passenden Ubuntu-System-Python das versionsgenaue
Paket an, beispielsweise `python3.12-venv`. Abfrage: `[(j)a/(N)ein]`, Standard Nein. Ohne Terminal
erfolgt keine Installation. Alternativ ist `SDNEXT_INSTALL_VENV_DEPS=1` die ausdrueckliche
Zustimmung; `0` deaktiviert die Paketinstallation. Diese Zustimmung gilt nur fuer das notwendige
Systempaket, nicht fuer Modelle, PyTorch oder Dienste.

Speicherpruefung, eigenes aktuelles Log und Installationssperre erfolgen zuvor. APT wartet begrenzt
auf Paketverwaltungssperren; Fehler stoppen vor dem Clone. Nach der Paketinstallation werden `venv`
und `ensurepip` erneut geprueft. SD.Next selbst bleibt am GitHub-Pin, ohne Docker. Kein
System-Python wird ersetzt. Bei einem privaten Python oder einer bereits aktiven venv wird nicht
versucht, ein unpassendes Ubuntu-Paket nachzuinstallieren. Dort den Interpreter separat reparieren
oder `SDNEXT_PYTHON_BIN` passend setzen. Vorhandene unvollstaendige SD.Next-venvs werden weiterhin
nicht automatisch geloescht.

Stand: 16.10.2026. Quelle: [vladmandic/sdnext](https://github.com/vladmandic/sdnext). Unser fester
Quellstand ist `b7dcb0ce870181a40d1246fde1febbff5593a750` vom 11.10.2026. Code: Apache-2.0; Modelle
und Erweiterungen haben eigene Bedingungen.

## 1. Was der neue Installer macht

Der bisherige Social-Media-Platzhalter wurde durch eigene SD.Next-Skripte ersetzt. Im Tools-Menue
SD_Next auswaehlen oder im Setup-Verzeichnis aufrufen:

```bash
bash scripts/tools/sdnext_install.sh --dry-run
bash scripts/tools/sdnext_install.sh
bash scripts/tools/sdnext_status.sh
bash scripts/tools/sdnext_doctor.sh
```

**Ergebnis: GitHub-Quellen und eine isolierte Python-Umgebung, noch keine betriebsbereite
Bild-/Video-WebUI.** Es wird kein Docker verwendet. Kein Modell, PyTorch, Treiber oder Zusatzpaket
wird automatisch heruntergeladen. Auch Submodule und Extension-Installer werden nicht gestartet.

Standardziel ausserhalb des Repositories:

```text
~/.openclaw_ultimate_user_data/tools/sdnext/
  source/         gepinnter GitHub-Checkout
  venv/           private Python-Umgebung mit venv-eigenem pip
  source-ready    Marker nach erfolgreicher Quellen-/venv-Pruefung
  operation.lock Schutz gegen parallele Installer
~/.openclaw_ultimate_user_data/install_logs/sdnext_*.log
```

Python 3.10-3.13 mit SSL, venv und ensurepip muss vorhanden sein. Ubuntu 24.04 mit Python 3.12 ist
fuer diesen Quellstand grundsaetzlich vorgesehen; einzelne GPU-Backends koennen engere Grenzen
haben. Ein abweichendes vorhandenes Python waehlt man bewusst, ohne das System-Python zu ersetzen:

```bash
SDNEXT_PYTHON_BIN=python3.11 bash scripts/tools/sdnext_install.sh
```

Bei fehlendem ensurepip/venv das zum gewaehlten Python passende Ubuntu-venv-Paket separat
einrichten. Danach `--repair` verwenden. Eine bereits beschaedigte venv wird nicht geloescht: erst
sichern und separat umbenennen.

## 2. Speicherwache und Wiederholung

Vor Download/venv-Erstellung prueft das Setup 2 GiB freie Linux-Disk und, falls unter WSL messbar, 4
GiB freie Windows-C:-Reserve. Das sind nur Reserven fuer **Quellen + venv**, keine Zusage fuer die
komplette Laufzeit. Log und Disk-Messung werden bei der eigentlichen Operation geschrieben. Dry-Run
legt keine Verzeichnisse an und greift nicht aufs Netz zu.

Install/Update wiederholen denselben Pin. Vorhandene fremde, unvollstaendige oder veraenderte
Checkouts werden nicht ueberschrieben. Es gibt kein automatisches git reset, git clean oder
rekursives Loeschen. Ein abgebrochener Clone bleibt zur Pruefung erhalten; --repair ist keine
Erlaubnis, eigene Dateien zu verwerfen.

## 3. Erststart bewusst separat

**Warnung:** Upstreams `webui.sh`/`launch.py` installiert beim ersten Start weitere Pakete. Selbst
`--help` oder ein Import von `installer.py` kann Paketinstallation ausloesen. `--test` fuehrt
Modell-Pipelines aus und ist kein sicherer Install-only-Modus. Deshalb ruft unser Installer diese
Dateien nicht auf und prueft Python-Dateien nur syntaktisch.

Vor dem folgenden manuellen Schritt:

1. [Offizielle Installationsanleitung](https://vladmandic.github.io/sdnext-docs/Installation/) und
   GPU-/Backend-Voraussetzungen lesen. Python-Pakete kommen auch aus Paketindizes und
   GPU-Repositories; die Hauptquelle bleibt GitHub.
2. Fuer die Laufzeit als vorsichtige Planung mindestens 16 GiB RAM und 50 GiB freie
   Disk/Windows-Hostreserve einplanen; grosse Modelle brauchen erheblich mehr. Dies sind keine
   getesteten Upstream-Minima.
3. GPU/Treiber/PyTorch aufeinander abstimmen; eine RTX 5080 braucht eine passende Blackwell-faehige
   Kombination. Kein automatischer Treiberumbau.
4. Port 7860 auf Konflikte mit ComfyUI/AUTOMATIC1111 pruefen. Nur einen schweren
   Installations-/GPU-Job gleichzeitig ausfuehren.
5. Noch keine privaten Dokumente, Tokens oder fremden Extensions hinterlegen.

**Nur wenn du Paketdownloads und den lokalen WebUI-Start jetzt bewusst willst:**

```bash
base="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/sdnext"
cd "$base/source"
source "$base/venv/bin/activate"
export PYTHON="$base/venv/bin/python"
export venv_dir="$base/venv"
# Manuelle Runtime-Einrichtung UND WebUI-Start, nicht Teil unseres Installers:
bash webui.sh --server-name 127.0.0.1 --port 7860 --safe --skip-git
```

`--safe` deaktiviert User-Extensions, ist aber keine Betriebssystem-Sandbox. `--skip-git` begrenzt
Upstream-Git-Operationen; Paketinstaller koennen weiterhin eigene GitHub-Abhaengigkeiten laden.
Fehlende Built-in-Submodule ggf. separat nach Upstream-Anleitung und Review einrichten, nicht blind
alle nachladen. Dieser Erststart ist hier **nicht end-to-end getestet**.

Kein `--listen`, kein `--share`, kein API-Listener nach aussen. Im Browser danach nur
[localhost:7860](http://127.0.0.1:7860) verwenden. Oeffentliche Erreichbarkeit, Tunnel, Cloud oder
Auth-Ausnahmen nicht aktivieren. Der Installer selbst bindet keinen Port; deshalb bleibt seine
Portliste leer.

## 4. Zielhost und Ressourcen

| Zielhost             | Empfehlung                                                               |
| -------------------- | ------------------------------------------------------------------------ |
| WSL2 / MiniPC        | Quellen moeglich; Runtime-RAM/Disk vor Erststart gesondert pruefen       |
| RPi5                 | kein empfohlener Inferenzhost; ARM-/Paket-/Backend-Kompatibilitaet offen |
| Oracle VPS           | kein oeffentliches GPU-WebUI; eher Steuerung/Queue                       |
| Gaming-PC / RTX 5080 | lokale GPU-Workstation bevorzugt; VRAM modell-/aufloesungsabhaengig      |
| Dual Xeon            | viele CPU-Kerne ersetzen nicht die passende GPU/VRAM                     |
| K3s                  | kein Deployment durch diesen nativen Installer; gesonderter Workerplan   |

Keine pauschale GPU-Mindestgroesse: Modell, Quantisierung, Bildgroesse, Offload und Video-Dauer
bestimmen VRAM/RAM/Disk. Fuer Laufzeit ohne passende GPU keine brauchbare Geschwindigkeit zusagen.
Quellen-/venv-Setup benoetigt keine GPU.

## 5. Update, Doctor und Deinstallation

```bash
bash scripts/tools/sdnext_update.sh --dry-run
bash scripts/tools/sdnext_update.sh
bash scripts/tools/sdnext_install.sh --repair
bash scripts/tools/sdnext_uninstall.sh
```

Update wechselt nicht heimlich auf master/latest. Runtime-Aenderungen und Upstream-Selbstupdates
werden nicht rueckgaengig gemacht. Aendert ein manueller Start Dateien, kann die strenge
Quellenpruefung danach bewusst abbrechen. Status/Doctor attestieren nur Pin, sauberen Checkout und
isolierte venv, keine GPU-/Bildgenerierungsbereitschaft; `runtime_ready` bleibt false im Sinne von
**nicht durch das Setup nachgewiesen**.

Uninstall deaktiviert nur den Marker. Quellen, venv, Modelle, eigene Bilder, Konfigurationen und
Logs bleiben erhalten. Vor jedem manuellen Aufraeumen deren Pfade und Backups pruefen.

Offen: vollstaendige Runtime-Pins je GPU, Submodul-Audit, automatischer sicherer Install-only-Pfad
ohne Modell-/Serverstart, Queue-/Ressourcenwache fuer Erststart, GPU-Smoke-Test. Registry deshalb
experimental, keine automatische Installation.

Pruefgrundlage:
[gepinntes launch.py](https://github.com/vladmandic/sdnext/blob/b7dcb0ce870181a40d1246fde1febbff5593a750/launch.py),
[Installer](https://github.com/vladmandic/sdnext/blob/b7dcb0ce870181a40d1246fde1febbff5593a750/installer.py),
[CLI-Argumente](https://github.com/vladmandic/sdnext/blob/b7dcb0ce870181a40d1246fde1febbff5593a750/modules/cmd_args.py).
