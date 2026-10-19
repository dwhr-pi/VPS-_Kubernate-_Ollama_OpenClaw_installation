# Veo-API-Client aus GitHub, ohne Docker

Stand 16.10.2026. Der Menuepunkt **Veo_API** installiert das offizielle
[Google Gen AI Python-SDK](https://github.com/googleapis/python-genai),
Version [v2.31.0](https://github.com/googleapis/python-genai/releases/tag/v2.31.0),
Commit `6bbead9ec73eee0b2557c4bf07406d3574b01533`.
Die Python-Distribution heisst **google-genai**, nicht veo.

**Veo selbst wird nicht installiert.** Die SDK-Quellen sind Apache-2.0;
Googles Videomodelle und API-Dienste sind dadurch weder lokal verfuegbar
noch automatisch kostenlos. Es wird kein Docker benoetigt.

## 1. Installation

Im Setup-Verzeichnis unter Tools Veo_API auswaehlen oder:

```bash
bash scripts/tools/veo_api_install.sh --dry-run
bash scripts/tools/veo_api_install.sh
bash scripts/tools/veo_api_status.sh
bash scripts/tools/veo_api_doctor.sh
```

Der Installer prueft zuerst Python und Ressourcen, laedt den festen
GitHub-Commit und installiert den Repository-Root in eine private venv:

```text
~/.openclaw_ultimate_user_data/tools/veo_api/source/
~/.openclaw_ultimate_user_data/tools/veo_api/venv/
~/.openclaw_ultimate_user_data/tools/veo_api/source-built
~/.openclaw_ultimate_user_data/install_logs/veo_api_*.log
```

Die Hauptquelle ist GitHub. Build-/Runtime-Abhaengigkeiten kommen als Wheels
von PyPI, nicht aus Docker. Kein `local-tokenizer`-, `aiohttp`- oder
`pyopenssl`-Extra wird angefordert; insbesondere kein lokales
PyTorch-/Transformers-/Modellpaket. Es gibt keine GPU-Anforderung.

Die Installation fuehrt den Python-Paketbuild aus. Doctor prueft nur
Distribution, Version, lokalen Quellursprung und `pip check`, ohne
`google.genai` zu importieren oder einen Client anzulegen.

## 2. Voraussetzungen und Speicherwache

- Normaler Linux-Benutzer; automatischer Wheel-Pfad fuer x86_64 oder ARM64.
- Vorhandenes Python 3.10-3.13 mit SSL, venv und ensurepip. Upstream
  unterstuetzt weitere Versionen; unser automatischer Pfad ist bewusst enger.
- Git, flock und Coreutils; keine Docker-Installation. Fehlende venv-Systempakete
  nur nach ausdruecklicher Zustimmung, siehe unten.
- 1 GiB RAM gesamt, mindestens 512 MiB verfuegbar, 2 GiB freie Linux-Disk
  und unter WSL soweit messbar 2 GiB Windows-C:-Reserve.

Ubuntu-Python 3.12 passt. Einen anderen vorhandenen Interpreter bewusst waehlen:

```bash
VEO_API_PYTHON_BIN=python3.11 bash scripts/tools/veo_api_install.sh
```

Fehlendes venv/ensurepip bietet der Installer seit 19.10.2026 als gezielte
Reparatur an, beispielsweise `python3.12-venv`. Abfrage: `[(j)a/(N)ein]`,
Standard Nein. Ohne Terminal keine Installation; ausdrueckliches Opt-in:

```bash
VEO_API_INSTALL_VENV_DEPS=1 bash scripts/tools/veo_api_install.sh --repair
```

`VEO_API_INSTALL_VENV_DEPS=0` sperrt die Paketinstallation. Nur das zum
ausgewaehlten System-Python unter `/usr/bin/python3.X` passende Paket wird
angeboten. Private Interpreter, aktive venvs sowie SSL-/Versionsfehler werden
nicht durch Installation eines fremden venv-Pakets repariert.
Ressourcenpruefung, Sperre und aktuelles Tool-Log kommen vor der Reparatur.
APT wartet begrenzt auf Paketverwaltungssperren; keine Sperrdateien werden
geloescht. Paket- oder Nachpruefungsfehler stoppen vor Clone/Build.
Das Setup ersetzt kein System-Python; Quellen und bestehende venvs werden
nicht automatisch geloescht. APT dient nur der Systemvoraussetzung, das SDK
kommt weiterhin aus GitHub. Keine Google-API-Abfragen, Uploads oder Videojobs.

Fehlende Wheels fuehren zum Abbruch, nicht zum ungefragten nativen Grossbuild.
MiniPC, RPi5 und Oracle VPS koennen als Clienthost dienen, sofern die
Python-/Wheel-Voraussetzungen passen. RTX-Workstation/Dual-Xeon haben keinen
lokalen Veo-Inferenzvorteil. Kein Kubernetes-Deployment; Windows/macOS nativ
sind mit diesem Bash-Installer nicht getestet.

Ein Lock verhindert parallele Installationen. Diskwerte und Fehler werden
protokolliert; Fehler erhalten Quellen und Benutzerdaten. Keine automatischen
Reset-/Clean-/Loeschaktionen. Dry-Run ist ohne Download und Dateierstellung.

## 3. Zugangsdaten, Datenschutz und Kosten

**Fuer Installation/Doctor wird kein Google-Key benoetigt.**
Kein gcloud-Login, kein Lesen von Application Default Credentials (ADC),
kein Key-Test, Upload, Modellaufruf, Polling oder Videodownload wird ausgefuehrt.
Google-Key-/Credential- und Projektvariablen werden nur im Installer-
Unterprozess entfernt; deine aufrufende Shell bleibt unveraendert.
Das ist keine Betriebssystem-Sandbox und keine technische Cloud-Kostensperre.

Vor einer spaeteren eigenen Nutzung separat pruefen:

1. API-/Cloud-Konto, Abrechnung, Freigabe des konkreten Veo-Modells und
   Verfuegbarkeit fuer den gewaehlten API-Pfad/die Region.
2. Authentifizierungsweg: API-Key und ADC/Cloud-Projekt sind verschiedene
   Wege und nicht beliebig austauschbar. Aktuelle offizielle Dokumentation
   des gewaehlten Dienstes lesen, keine Modell-ID aus alten Beispielen kopieren.
3. Anbieterlimits, Budgetwarnungen und eigene feste Auftragslimits.
   Budgetwarnungen alleine garantieren keinen harten Kostenstopp.
4. Rechte und Einwilligung fuer Text/Bild/Audio/Personen; keine vertraulichen
   Dokumente oder Personalakten ungeprueft extern verarbeiten lassen.
5. Einen Auftrag gleichzeitig, feste Timeouts und begrenzte Wiederholungen.
   Asynchrones Polling nicht endlos laufen lassen und Auftraege nicht
   versehentlich durch wiederholte Submit-Aufrufe duplizieren.

Echte Secrets nur ausserhalb des Repos mit restriktiven Dateirechten.
Keine API-Keys in Markdown, Prompts, Git, Logs oder URL-Beispielen.
Es wird bewusst kein sofort laufender Generierungs-/Uploadworkflow geliefert.
Es werden weder ein lokaler Port noch eine oeffentliche Adminoberflaeche geoeffnet.

Fuer lokale Videoproduktion weiterhin die vorhandenen ComfyUI-/Videomodell-
Pfade pruefen. Das Google-SDK macht Veo nicht auf deiner GPU selbsthostbar.

## 4. Update, Status und Deaktivierung

```bash
bash scripts/tools/veo_api_update.sh --dry-run
bash scripts/tools/veo_api_update.sh
bash scripts/tools/veo_api_install.sh --repair
bash scripts/tools/veo_api_uninstall.sh
```

Update behaelt Version/Commit und wechselt nicht automatisch auf latest.
Das SDK ist gepinnt; seine Abhaengigkeiten sind noch kein vollstaendiger
Hash-Lock und koennen bei erneuter Aufloesung variieren.

Status meldet ausschliesslich lokale SDK-Konsistenz, keine Veo-Verfuegbarkeit,
Kostenfreiheit, Kontoberechtigung oder erfolgreiche Videogenerierung.
Uninstall deaktiviert nur den Marker. Quellen, venv, eigene Daten und
eventuell separat angelegte Zugangsdaten bleiben erhalten; das SDK wird
dadurch nicht technisch unbenutzbar.

Offen: echte Linux-/ARM-/Python-Installationsmatrix, Dependency-Hash-Lock
und separat freizugebende API-Integration mit verifiziertem Kostenlimit.
Repository-Tests verwenden nur lokale Mocks, keine reale Installation/API.

Technische Quellen:
[Paketmetadaten am Pin](https://github.com/googleapis/python-genai/blob/6bbead9ec73eee0b2557c4bf07406d3574b01533/pyproject.toml),
[offizielle SDK-Dokumentation](https://googleapis.github.io/python-genai/),
[Code-Lizenz](https://github.com/googleapis/python-genai/blob/6bbead9ec73eee0b2557c4bf07406d3574b01533/LICENSE).
