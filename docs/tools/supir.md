# SUPIR aus GitHub, ohne Docker

## Wichtig vor dem Start

SUPIR ist Bildrestaurierung mit generativer Detailsynthese, kein nativer
8K-Videogenerator. Rekonstruierte Details koennen erfunden sein; Ergebnisse
nicht als forensischen Beweis oder originalgetreue Wiederherstellung ausgeben.
Originalbilder unveraendert behalten und Rechte/Einwilligungen beachten.

Das Setup hat jetzt einen eigenen **experimentellen GitHub-Quellinstaller**
statt des Hybrid-Platzhalters. Er klont
[Fanghua-Yu/SUPIR](https://github.com/Fanghua-Yu/SUPIR) am festen Commit
`bda91af2000042f8bedfec8897d92917e67c1d88` aus dem Upstream-Zweig `master`.
Kein Docker, kein Container, kein Modell- oder Cloud-Aufruf.

**Grenze:** Das ist eine Quellinstallation, keine fertige Python-/GPU-Laufzeit.
Es werden weder pip-Pakete noch Conda, Python 3.8, Treiber oder Gewichte
installiert. `source-ready`/`source_ready: true` bedeutet nur gepinnten,
unveraenderten Quellcode mit gepruefter Syntax. Status meldet bewusst
`runtime_ready: false`; auch der allgemeine Toolmarker beweist keine Inferenz.

## Lizenz nicht mit GitHub-Verfuegbarkeit verwechseln

Der Pin enthaelt ein eigenes **SUPIR Software License Agreement**, keine
pauschale MIT-/Apache-Freigabe. Abschnitt 3 beschreibt Einschraenkungen fuer
kommerzielle Nutzung und eine gesonderte schriftliche Erlaubnis/Lizenz.
Vor Nutzung, Veroeffentlichung oder Weitergabe von Code, Gewichten oder damit
erzeugten Arbeitsergebnissen die passenden Bedingungen selbst pruefen.
Modell-/Datenlizenzen kommen hinzu; dieses Setup erteilt keine Nutzungsrechte.
[Original-Lizenz des Pins](https://github.com/Fanghua-Yu/SUPIR/blob/bda91af2000042f8bedfec8897d92917e67c1d88/LICENSE).

## Warum keine blinde Paketinstallation?

Die [gepinnten Requirements](https://github.com/Fanghua-Yu/SUPIR/blob/bda91af2000042f8bedfec8897d92917e67c1d88/requirements.txt)
enthalten bereits einen eindeutigen Konflikt:

| Paket | Gepinnter Stand | Pydantic-Anforderung laut Paketmetadaten |
|---|---|---|
| FastAPI | 0.95.1 | `<2.0.0` |
| Gradio | 4.16.0 | `>=2.0` |

Diese Anforderungen sind in einer gemeinsamen Umgebung nicht gleichzeitig
erfuellbar. Primaerquellen:
[FastAPI-Metadaten](https://pypi.org/pypi/fastapi/0.95.1/json) und
[Gradio-Metadaten](https://pypi.org/pypi/gradio/4.16.0/json).
Ein Wechsel auf Python 3.11 oder ein Docker-Container loest diesen Konflikt
nicht von selbst. `--no-deps` wuerde ihn nur verstecken.

Ausserdem nennt das alte Upstream-Rezept Python 3.8 und zahlreiche alte
Pins neben offenen torch-/xformers-Anforderungen. Ubuntu 24.04/Python 3.12
darf deshalb nicht einfach mit diesem Runtime-Rezept gleichgesetzt werden.
Die pauschale Installation alter GPU-Pakete kann weitere Build-, CUDA- und
Sicherheitsprobleme erzeugen. Es wurde hier kein Vulnerability-Audit ausgefuehrt.

`SUPIR_INSTALL_RUNTIME=1` wird vor Aenderungen mit konkreter Begruendung
abgewiesen, auch wenn `INSTALL_HEAVY_TOOLS=1` gesetzt ist. Das umgeht keine
Nutzerentscheidung, sondern verhindert eine als funktionierend dargestellte,
bereits widerspruechliche Runtime-Installation. Die Quellinstallation bleibt
ohne diese Variable verfuegbar.

## Schritt fuer Schritt: Quellen installieren

Voraussetzungen: Linux, normaler Benutzer, Bash, Git, Python 3.10+ fuer die
reine Syntaxpruefung, flock und realpath/coreutils. Python 3.12 ist fuer diese
Quellpruefung geeignet. Keine GPU oder virtuelle Python-Umgebung noetig.
Fehlende Basiswerkzeuge bewusst separat einrichten; kein sudo im Toolaufruf.

Unsere konservative Installationsreserve: **1 GiB freie Ziel-Disk**, unter
WSL zusaetzlich **2 GiB Windows-C:-Reserve**. Dies ist nicht der Speicherbedarf
von SDXL, LLaVA oder SUPIR-Modellen. Eine konkrete getestete RAM-/VRAM-Grenze
fuer die noch nicht freigegebene GPU-Laufzeit wird hier nicht behauptet.
MiniPC, WSL, RPi und Oracle-VPS koennen die Quellen vorbereiten; spaetere
Inferenz gehoert auf einen separat geplanten GPU-Host. Keine RTX-5080-,
ARM-, Kubernetes- oder Windows-Portable-Kompatibilitaet ist damit nachgewiesen.

```bash
# Im aktuellen Ultimate-Setup-Checkout, ohne sudo:
bash scripts/tools/supir_install.sh --dry-run
bash scripts/tools/supir_install.sh
bash scripts/tools/supir_status.sh
bash scripts/tools/supir_doctor.sh
```

Oder im Tools-Menue **SUPIR** bewusst auswaehlen. Ziel:
`~/.openclaw_ultimate_user_data/tools/supir/source/`.
Der Installer prueft Git-Quelle, Commit, unveraenderte Dateien und die Syntax
ausgewaehlter Einstiegsdateien. Kein Import von SUPIR, torch, Gradio oder
Modellcode; selbst `test.py --help` wird nicht ausgefuehrt.
Quellen werden nicht in eine laufende ComfyUI-Installation eingebunden.

Protokolle: `~/.openclaw_ultimate_user_data/install_logs/supir_*.log`.
`OPENCLAW_USER_DATA_DIR` kann einen anderen absoluten, normalisierten
User-Workspace ausserhalb des Repositories setzen. Symlink-Umleitungen
werden abgelehnt. Keine echten Keys, privaten Daten oder neuen Modellpfade
werden erzeugt oder nach Git geschrieben.

## Modellpfade und spaetere Laufzeit

Die Originaldatei `CKPT_PTH.py` hat Upstream-Beispielpfade, die auf deinem
Rechner nicht automatisch existieren. Sie sind kein Ergebnis der Installation.
Upstream beschreibt zudem automatische CLIP-Downloads bei bestimmten
Pfadwerten. Deshalb keine Konfiguration blind auf `None` setzen und dann
einen Server starten. Gewichte, Groessen, Revisionen, Hashes und Lizenzen
vorher getrennt pruefen; keine automatische Token-/Tresoruebernahme.

Fuer eine spaetere Runtime-Freigabe sind erforderlich:

1. Konfliktfreien, getesteten Dependency-Lock mit aktueller Sicherheitspruefung
   erstellen, gegebenenfalls in einem klar gekennzeichneten gepflegten Fork.
2. Separat isolierte venv, CUDA-/GPU-/Python-Kompatibilitaet und Ressourcenbudget
   testen; keine bestehende ComfyUI- oder Systemumgebung ueberschreiben.
3. Modellgewichte bewusst bereitstellen und einen kleinen Test mit eigenen
   Bildern durchfuehren; keine automatischen Cloud-Uploads.
4. Erst danach einen begrenzten Queue-Worker fuer OpenClaw/n8n planen, ein
   GPU-Job gleichzeitig, feste Laufzeitgrenze, keine oeffentliche Gradio-API.

Diese Runtime-/ComfyUI-/Queue-Integration ist hier **nicht implementiert**.
Quellbereitstellung darf deshalb nicht als funktionierendes Restoration-Studio
oder freigegebener kommerzieller Dienst verkauft werden.

## Update, Fehler und Deaktivierung

```bash
bash scripts/tools/supir_update.sh
bash scripts/tools/supir_install.sh --repair
bash scripts/tools/supir_uninstall.sh
```

Update und Repair pruefen denselben Pin, kein automatisches `pull master`.
Wiederholte Installation verwendet einen konsistenten Checkout erneut.
Fremde, unvollstaendige oder veraenderte Quellen werden nicht geloescht,
ersetzt oder zurueckgesetzt. Erst manuell sichern/umbenennen, dann erneut
installieren. Konfigurationsaenderungen im verwalteten Checkout gelten
ebenfalls als lokale Aenderungen. Keine automatische Datenmigration.

Ein Lock verhindert parallele Aktionen. Fehlgeschlagene neue Installationen
erhalten keinen Erfolgsmarker. Doctor/Status arbeiten offline und erzeugen
keinen Workspace. Doctor prueft nur Quellcode, keine Runtime-/Modellfunktion.
Uninstall deaktiviert nur den Setup-Marker; Quellen, eigene Umgebungen,
Gewichte, Bilder, Workflows und Logs bleiben erhalten. Keine Prozesse werden
beendet und keine Daten rekursiv geloescht.

Entwicklung und Tests hier erfolgen nur mit synthetischen Offline-Dateien und
Mocks. Keine echte SUPIR-/GPU-Installation und kein Eingriff in deine WSL.
