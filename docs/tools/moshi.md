# Moshi aus GitHub, ohne Docker

Moshi ist ein Full-duplex-Sprachdialogsystem mit Mimi-Audiocodec, kein universeller
Hoerbuch-/Musikgenerator. Der Installer verwendet den
[offiziellen GitHub-Quellstand](https://github.com/kyutai-labs/moshi/tree/e6a55d2722a65870ef52a6c9f6ecfc0e90f38362),
Commit `e6a55d2722a65870ef52a6c9f6ecfc0e90f38362`, Paketversion `0.2.13`. Status **experimental**,
nur nach bewusster Auswahl im Setup.

## Installation

```bash
bash scripts/tools/moshi_install.sh --dry-run
bash scripts/tools/moshi_install.sh
bash scripts/tools/moshi_status.sh
bash scripts/tools/moshi_doctor.sh
bash scripts/tools/moshi_install.sh --repair
bash scripts/tools/moshi_update.sh
```

Das Monorepo hat mehrere Backends. Dieser Installer baut nur das Python- Paket im Unterordner
**`moshi/`**, nicht den Repository-Root, MLX, Rust oder den Webclient. Installation mit `--no-deps`
in einer privaten venv. **Das Basispaket ist noch keine betriebsbereite Sprachdialog-Laufzeit.**
Keine Docker-Nutzung, Torch-/Audio-Pakete, Modelle, Server, Mikrofonzugriff, Training, WebUI oder
offenen Ports. Das Menue setzt keinen allgemeinen Bereitschaftseintrag. Status `installed`
bezeichnet nur das Basispaket; `runtime_dependencies`, `models_checked`, `inference_tested` bleiben
`false`. Doctor prueft Pin/Paketmetadaten ohne Moshi-/Torch-Import oder Modellzugriff.

Voraussetzungen: normaler Linux-Benutzer auf x86_64/ARM64, Bash, Git, flock, realpath, Python
3.10-3.12 mit venv, ensurepip und SSL. Ubuntu-Python 3.12 passt zur Basisinstallation.
`MOSHI_PYTHON_BIN` waehlt einen vorhandenen Interpreter; kein Ersetzen des System-Python oder
Treiberumbau. Upstream erlaubt Python >=3.10,<3.15, dieser Installer begrenzt den Basispfad
konservativ auf 3.10-3.12. GPU-Kompatibilitaet folgt daraus nicht.

### Fehlendes venv/ensurepip reparieren

Seit 19.10.2026 bietet der Installer das versionspassende Ubuntu-Paket an, beispielsweise
`python3.12-venv`. Abfrage: `[(j)a/(N)ein]`, Standard Nein. Ohne Terminal keine Installation;
ausdrueckliches nichtinteraktives Opt-in:

```bash
MOSHI_INSTALL_VENV_DEPS=1 bash scripts/tools/moshi_install.sh --repair
```

`MOSHI_INSTALL_VENV_DEPS=0` deaktiviert die Paketinstallation. Nur das zum gewaehlten System-Python
unter `/usr/bin/python3.X` passende Paket wird angeboten. Private Interpreter, aktive venvs und
SSL-/Versionsfehler erfordern separate Pruefung; kein System-Python wird ersetzt. Speicherpruefung,
Sperre und aktuelles Tool-Log kommen vor der Reparatur. APT wartet begrenzt auf
Paketverwaltungssperren, ohne Sperrdateien zu loeschen. Nach Paketinstallation wird venv/ensurepip
erneut geprueft; bei Fehlern kein Clone/Build. Moshi bleibt aus GitHub, ohne Docker. Die Zustimmung
gibt keine GPU-Runtime, Modelle, Dienste oder Mikrofonzugriffe frei. Vorhandene fremde/beschaedigte
venvs werden nicht automatisch geloescht.

## Pfade und Ressourcen

Unter `${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/moshi/` liegen `source/`,
`venv/`, Lock und Setup-Marker. Das Python-Paket liegt in `source/moshi/`. Logs werden im
zugehoerigen `install_logs/` abgelegt. Daten im Setup-Repo, Symlink-Verzeichnisse und nicht
normalisierte Pfade werden abgelehnt. Fremde/unvollstaendige/geaenderte Quellen werden nicht
zurueckgesetzt oder geloescht. Update verwendet denselben Commit-Pin.

Basisreserve: 1 GiB Gesamt-RAM, 512 MiB aktuell frei, 2 GiB freie Disk und bei messbarem WSL-Host
ebenfalls 2 GiB Windows-C:-Reserve. Freier Dateisystemplatz wird vorher/nachher protokolliert. Diese
Werte gelten **nur fuer das Basispaket**, nicht fuer Modelle oder Echtzeitdialog.
MiniPC/RPi5/Oracle-VPS: Basisvorbereitung, keine getestete Inferenz. GPU-Workstation/Kubernetes:
Runtime und Budget separat planen. Upstream nennt fuer den PyTorch-Dialog eine GPU mit 24 GB
Speicher; kleinere oder quantisierte Varianten muessen gezielt getestet werden. Keine pauschale
Echtzeit-/RTX-5080-Zusage. macOS-MLX ist ein anderer Backend-Pfad.

## Offene Laufzeitintegration

Der gepinnte
[Paketvertrag](https://github.com/kyutai-labs/moshi/blob/e6a55d2722a65870ef52a6c9f6ecfc0e90f38362/moshi/pyproject.toml)
fordert unter anderem Torch >=2.2,<2.10, Linux-bitsandbytes >=0.45,<0.50 und sounddevice 0.5.
GPU-Wheels, Treiber, PortAudio und Audio-Ein-/Ausgabe sind separat zu pruefen.
`MOSHI_INSTALL_RUNTIME=1` wird mit Hinweis abgelehnt, statt unkontrolliert GPU-Pakete
herunterzuladen.

Noch erforderlich: getestete Hardware-/Paketkombination, explizites Modellbudget, konkrete
Modellkarte/Revision, bewusster Download und lokaler Audio-/Dialogtest. Kein
`moshi.server`/`moshi.client`-Aufruf im Installer oder Doctor. Ein kuenftiger Server muss explizit
auf Loopback gebunden werden; keine oeffentliche Freigabe oder Hintergrundaufnahme.

GitHub liefert die Anwendung; pip kann isolierte Build-Werkzeuge aus PyPI laden. Kein komplett
gehashter Offline-Build. Die dynamische Paketversion wird von setuptools aus dem literalen
`__version__` gelesen; der Doctor importiert das SDK nicht. HF-Token werden im Installer- Subprozess
entfernt, Hub-/Transformers-Offline-Flags gesetzt. Das ist keine Netzwerksandbox und ersetzt keine
Betriebssicherheitspruefung.

```bash
bash scripts/tools/moshi_uninstall.sh
```

Deaktiviert nur den Setup-Marker, keine vollstaendige Dateiloeschung. Quellen, venv, Audios,
Modelle/Caches und Logs bleiben erhalten.

## Lizenz und Datenschutz

Python-Code:
[MIT](https://github.com/kyutai-labs/moshi/blob/e6a55d2722a65870ef52a6c9f6ecfc0e90f38362/LICENSE-MIT),
Rust-Backend: Apache-2.0. Upstream beschreibt die veroeffentlichten Moshi-/Mimi-Gewichte als **CC-BY
4.0**; konkrete Modellkarte und Namensnennungspflichten vor Nutzung pruefen. Keine fremden Stimmen
ohne Einwilligung verwenden; Mikrofonaufnahme erfordert bewusste Zustimmung, Zugriffsregeln und ein
Loeschkonzept. Keine Behauptung einer automatischen DSGVO-Konformitaet allein durch lokalen Betrieb.

Offline-Tests simulieren Paketinstallation, pruefen Monorepo-Pfad, Status, Registry und
Schutzmechanismen. Kein echter Build, Dialogtest oder Zugriff auf die WSL des Benutzers wurde dafuer
ausgefuehrt. Siehe [Medienkatalog](../media_studio/AUDIO_VIDEO_TOOL_CATALOG.md).
