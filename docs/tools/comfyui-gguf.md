# ComfyUI-GGUF aus GitHub, ohne Docker

## Voraussetzungen zuerst

Dies ist eine **Custom-Node fuer eine vorhandene ComfyUI-Installation**, kein
eigener Server und kein Modellpaket. Quelle:
[city96/ComfyUI-GGUF](https://github.com/city96/ComfyUI-GGUF), Apache-2.0,
fester Commit `6ea2651e7df66d7585f6ffee804b20e92fb38b8a`.
Die Setup-Integration ist experimentell, kein bestaetigter GPU-Renderpfad.

Standardziel: vorhandenes `/opt/comfyui` mit `main.py`, `comfy/`,
`custom_nodes/` und eigener `venv/bin/python`. ComfyUI muss ausreichend aktuell
sein, um die vom Plugin verwendeten Custom Ops zu unterstuetzen; ein genauer
getesteter ComfyUI/Node-Versionssatz steht noch aus.
[Upstream-Installationshinweise](https://github.com/city96/ComfyUI-GGUF#installation).

### Meldung: ComfyUI fehlt/unvollstaendig

Das Protokoll allein beweist nicht, ob ComfyUI wirklich fehlt oder nur an einem
anderen Pfad liegt. GGUF ist ein Plugin, kein eigenstaendiger Bildgenerator.
Der Installer installiert daher nicht ungefragt das schwere ComfyUI/PyTorch.

Die neue Erkennung verwendet zuerst ein ausdrueckliches `COMFYUI_ROOT`, sonst
das Ziel einer bestehenden GGUF-Registrierung. Ohne beides prueft sie nur diese
festen Pfade, ohne Laufwerks-/Netzwerksuche:

```text
/opt/comfyui
/opt/ComfyUI
<User-Workspace>/tools/comfyui/source
<User-Workspace>/tools/comfyui
~/ComfyUI
```

Ein Kandidat muss `main.py` und `comfy/` enthalten. Nur ein eindeutiger Treffer
wird gewaehlt; bei mehreren Treffern muss der Benutzer den Pfad setzen.
Python wird aus `venv/bin/python` oder `.venv/bin/python` erkannt; mehrere
Umgebungen brauchen ebenfalls eine ausdrueckliche Auswahl. Es wird zur
Pfaderkennung kein Interpreter gestartet. Bestehende Registrierungen merken
bereits Ziel und Python; Status/Doctor/Update verwenden diese wieder.

Wenn ComfyUI wirklich fehlt: zuerst **ComfyUI** im Tools-Menue bewusst installieren,
danach **ComfyUI_GGUF**. Der vorhandene ComfyUI-Installer verlangt erheblich mehr
Speicher (derzeit 40 GiB Linux / 30 GiB Windows-C: unter WSL); diese Pruefung nicht
umgehen. Wenn es vorhanden ist, den Ordner **mit** `main.py` angeben, nicht den
Elternordner. Fehlende Dateien, fehlender Interpreter und Rechteprobleme werden
getrennt gemeldet. Ein Ordnername allein belegt keine fertige Installation.

```bash
COMFYUI_ROOT=/ABSOLUTER/PFAD/ComfyUI \
  bash scripts/tools/comfyui_gguf_install.sh --dry-run
# Nach Pruefung denselben Aufruf ohne --dry-run bewusst ausfuehren.
```

Fuer einen Sonderpfad wie einen anderen Stack-Checkout immer `COMFYUI_ROOT`
explizit setzen. Native Windows-Portable-/Conda-Pfade sind damit nicht automatisch
unterstuetzt. Keine automatischen Rechteaenderungen, Ordnerloeschungen oder
Downloads von ComfyUI/Modellen. Nur Quellcode ohne Basisinstallation ist mit
`COMFYUI_GGUF_MODE=source` moeglich, aber noch keine aktive Erweiterung.

Benutzer braucht Schreibrechte in `custom_nodes`; **nicht mit sudo starten**.
ComfyUI und Installer muessen unter einem Benutzer laufen, der auf den privaten
Node-Quellordner zugreifen darf. Keine automatischen Besitzer-/Rechteaenderungen.
Python 3.10+ und eine vorhandene ComfyUI-venv mit torch, packaging und pip sind
erforderlich. Basiswerkzeuge: Bash, Git, flock, Python 3 und realpath/coreutils.
Python 3.12 passt. Kein Docker, System-Python-, CUDA- oder PyTorch-Update.

Konservative Setup-Diskreserve: **1 GiB** am User-Workspace und am ComfyUI-Ziel,
unter WSL zusaetzlich **2 GiB frei auf Windows C:**. Dies sind Installationsreserven,
keine gemessenen Modell-Mindestwerte. Der Plugin-Download benoetigt keine GPU;
Rendering braucht modell-/quantisierungsabhaengig RAM/VRAM. Weniger Bits
garantieren nicht, dass jedes Modell auf eine bestimmte GPU passt. MiniPC/RPi/VPS
koennen Quellen vorbereiten, echte Generierung auf geeignetem GPU-Rechner testen.

## Schritt 1: Plan und Ziel kontrollieren

ComfyUI zuerst selbst sauber beenden, nachdem laufende Jobs fertig sind.
Das Setup stoppt oder startet keine Prozesse.

```bash
# Im aktuellen Ultimate-Setup-Checkout, ohne sudo:
bash scripts/tools/comfyui_gguf_install.sh --dry-run
bash scripts/tools/comfyui_gguf_install.sh
bash scripts/tools/comfyui_gguf_status.sh
bash scripts/tools/comfyui_gguf_doctor.sh
```

Oder **ComfyUI_GGUF** im Tools-Menue bewusst auswaehlen. Fuer ein anderes
vorhandenes ComfyUI denselben Pfad fuer alle Aktionen angeben:

```bash
COMFYUI_ROOT=/ABSOLUTER/PFAD/ComfyUI \
COMFYUI_GGUF_PYTHON_BIN=/ABSOLUTER/PFAD/ComfyUI/.venv/bin/python \
  bash scripts/tools/comfyui_gguf_install.sh --dry-run
```

Nach Pruefung ohne `--dry-run` ausfuehren. Der Interpreter muss eine echte
venv sein, kein System-Python. Ein separat konfigurierter Interpreter muss
wirklich zu der ausgewaehlten ComfyUI-Instanz gehoeren. Windows-Portable-Python
und Conda/System-Python sind von diesem Linux-Helfer nicht abgedeckt.

## Schritt 2: Was der Installer macht

Er klont den festen GitHub-Pin nach
`~/.openclaw_ultimate_user_data/tools/comfyui_gguf/source/` und prueft Git-Quelle,
Commit, unveraenderte Dateien und Python-Syntax. Kein Import von Plugin, ComfyUI
oder GPU-Paketen beim Pruefen. Im gewaehlten ComfyUI wird nur dieser verwaltete
Link angelegt:

```text
ComfyUI/custom_nodes/ComfyUI-GGUF
  -> ~/.openclaw_ultimate_user_data/tools/comfyui_gguf/source
```

Die benoetigte `gguf`-Pythonbibliothek wird in **ComfyUIs bestehender venv**
geprueft. Vorhandenes `gguf>=0.13.0` wird weiterverwendet. Fehlt es, wird
`gguf==0.19.0` mit Binaerpaketen aus PyPI installiert; der Node-Code kommt aus
GitHub. Kein `pip install` des Nodes als eigenstaendige Anwendung.
Vorher werden die vorhandenen Paketversionen in einer Constraints-Datei im
privaten Tool-Workspace festgehalten. Bestehende Versionen werden bei der
Installation nicht automatisch aktualisiert, auch torch/numpy nicht.

Bei Konflikten, einem alten vorhandenen gguf oder fehlenden Wheels wird
abgebrochen: keine automatische Aufloesung durch globale Upgrades. ComfyUI-
Umgebung zuerst sichern und den Konflikt bewusst selbst loesen. Constraints
sind eine Versionsaufnahme, **kein vollstaendiges Backup oder Rollback**.
Neue Pakete koennen nach einem spaeteren Fehler erhalten bleiben.

`sentencepiece` und `protobuf` werden nicht automatisch hinzugefuegt: sie
werden fuer bestimmte Tokenizer-/Textencoder-Pfade benoetigt, nicht fuer den
minimalen GGUF-Diffusionsmodell-Loader. Vor solchen Workflows die optionalen
Pakete samt Versionskonflikten separat in derselben ComfyUI-venv pruefen.

## Schritt 3: Selbst neu starten und pruefen

Nach erfolgreicher Installation ComfyUI selbst wie bisher starten, nur lokal
oder ueber VPN, keine neue oeffentliche Freigabe. Dann einen kleinen eigenen
Workflow testen, z. B. mit `Unet Loader (GGUF)`. Passende GGUF-Modellgewichte
separat nach Lizenz-/Groessenpruefung in den vom Upstream beschriebenen
ComfyUI-Modellpfad legen; **keine automatischen Modelldownloads**.
Keine Garantie, dass jedes GGUF, jede LoRA oder ein WanVideoWrapper-Workflow
mit diesem nativen Loader kompatibel ist.

Doctor prueft nur verwalteten Link, Git-Pin, Syntax, Paketversion und `pip check`.
Er ist kein Node-Import-/GUI-/GPU-Funktionstest. Keine API, keine Modellimporte,
Cloud, Workflows oder Server werden durch die Setup-Pruefung gestartet.

## Nur Quellen, ohne ComfyUI

```bash
COMFYUI_GGUF_MODE=source bash scripts/tools/comfyui_gguf_install.sh
```

Das bereitet nur den GitHub-Checkout vor, installiert keine Pakete und legt
keinen neuen Node-Link an. `source-ready` ist **keine aktive Integration**.
Eine schon vorhandene Integration wird dadurch nicht entfernt. Fuer spaetere
Einbindung erneut im Standardmodus mit dem richtigen ComfyUI-Pfad installieren.

## Update und Entfernen

```bash
bash scripts/tools/comfyui_gguf_update.sh
bash scripts/tools/comfyui_gguf_install.sh --repair
bash scripts/tools/comfyui_gguf_uninstall.sh
```

Immer dieselben COMFYUI_ROOT-/Python-Overrides verwenden. Ein Workspace
verwaltet genau ein ComfyUI-Ziel. Vor Zielwechsel die bisherige Integration
mit deren Pfaden deaktivieren. Update prueft denselben Pin und laesst bereits
kompatible Pakete bestehen; kein stilles `git pull main` oder Manager-Upgrade.
Fremde Custom-Node-Ordner werden nicht ersetzt. Veraenderte/unvollstaendige
Quellen zuerst manuell sichern; kein automatischer Reset oder Loeschen.
Symlink-Umleitungen in Workspace/Zielpfaden werden abgelehnt; nur der explizite
verwaltete Node-Link ist erlaubt. Vorhandene ComfyUI-Symlink-Installationen
mit ihrem aufgeloesten realen Pfad angeben.

Uninstall entfernt **nur den verwalteten Node-Link und die Setup-Marker**.
Quellcode, installierte Python-Pakete, Modelle, Workflows, Exporte und Logs
bleiben erhalten. ComfyUI bei Bedarf anschliessend selbst neu starten.
Protokolle: `~/.openclaw_ultimate_user_data/install_logs/comfyui_gguf_*.log`.
`OPENCLAW_USER_DATA_DIR` erlaubt einen anderen absoluten User-Workspace
ausserhalb des Repos. Die Installationsaktionen besitzen ein Operations-Lock.

Windows-Portable: den separaten
[offiziellen Windows-Pfad](https://github.com/city96/ComfyUI-GGUF#installation)
mit dessen eingebettetem Python verwenden, nicht diese Linux-venv-Erkennung.
Codex hat keine vorhandene WSL/ComfyUI-Installation beruehrt. Hier werden
nur synthetische Offline-/Mocktests ausgefuehrt; echter Node-Import und
Render-/Modell-/ARM-/Windows-Portable-Kompatibilitaet bleiben offen.
