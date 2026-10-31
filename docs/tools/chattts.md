# ChatTTS aus GitHub ohne Docker

Stand 16.10.2026. [Quelle](https://github.com/2noise/ChatTTS), Pin
`77b89ee281cd479f5b1a787ada330dc975ca1f2a`.

**Code: AGPLv3+. Veroeffentlichtes Modell laut Upstream: CC BY-NC 4.0, nicht fuer kommerzielle
Nutzung.** Eine GitHub-Installation hebt diese Modellbedingungen nicht auf. Primaere Sprachen sind
Englisch und Chinesisch; Deutsch oder allgemeines Voice Cloning werden hier nicht zugesagt.

## 1. Basispaket installieren

Unter Tools ChatTTS auswaehlen oder im Setup-Verzeichnis:

```bash
bash scripts/tools/chattts_install.sh --dry-run
bash scripts/tools/chattts_install.sh
bash scripts/tools/chattts_status.sh
bash scripts/tools/chattts_doctor.sh
```

Standard: GitHub-Quellpaket in privater venv, **--no-deps**, keine vollstaendige TTS-Laufzeit.
Setuptools baut das Paket aus setup.py; es wird nicht aus PyPI als ChatTTS-Ersatz bezogen.
Build-Abhaengigkeiten kommen von PyPI. Kein Docker, kein ChatTTS-/Torch-Import und keine
CLI-/WebUI-/Inferenz-Ausfuehrung.

Upstreams setup.py hat am Pin die Default-Paketversion 0.0.0 und kann sie ueber CHTTS_VER aendern.
Unser Installer setzt bewusst CHTTS_VER=0.0.0, damit eine geerbte Variable keine falsche Version
erzeugt. Das ist **keine behauptete offizielle Release-Version**: massgeblich ist der feste Commit.
Doctor prueft zusaetzlich den lokalen Installationsursprung.

```text
~/.openclaw_ultimate_user_data/tools/chattts/source/
~/.openclaw_ultimate_user_data/tools/chattts/venv/
~/.openclaw_ultimate_user_data/tools/chattts/source-built
~/.openclaw_ultimate_user_data/install_logs/chattts_*.log
```

Voraussetzungen: normaler Linux-Benutzer, x86_64/ARM64, Git, flock, Python 3.10-3.12 mit
SSL/venv/ensurepip. Ubuntu 3.12 passt zum Paketpfad; das ist noch keine Zusage fuer alle optionalen
Textnormalisierungs-Pakete. Alternativ `CHATTTS_PYTHON_BIN=python3.11` vor den Installer setzen. Bei
fehlendem venv/ensurepip bietet der Installer seit 19.10.2026 das versionspassende Ubuntu-Paket an,
beispielsweise `python3.12-venv`. Abfrage: `[(j)a/(N)ein]`, Standard Nein. Ohne Terminal keine
Installation. Ausdrueckliches nichtinteraktives Opt-in:

```bash
CHATTTS_INSTALL_VENV_DEPS=1 bash scripts/tools/chattts_install.sh --repair
```

`CHATTTS_INSTALL_VENV_DEPS=0` deaktiviert die Paketinstallation. Nur das zum gewaehlten
System-Python unter `/usr/bin/python3.X` passende Paket wird angeboten. Private Interpreter, aktive
venvs und SSL-/Versionsfehler erfordern separate Pruefung; kein System-Python wird ersetzt.
Speicherpruefung, Sperre und aktuelles Tool-Log kommen vor der Reparatur. APT wartet begrenzt auf
Paketverwaltungssperren, ohne Sperrdateien zu loeschen. Nach Paketinstallation wird venv/ensurepip
erneut geprueft; bei Fehlern kein Clone/Build. ChatTTS bleibt aus GitHub, ohne Docker. Die
Zustimmung gilt nicht fuer Torch, Modelle oder die optionale schwere Laufzeit. Vorhandene
fremde/beschaedigte venvs werden nicht automatisch geloescht.

Reserve Basispaket: 1 GiB RAM gesamt, 512 MiB aktuell verfuegbar, 2 GiB freie Linux-Disk sowie unter
WSL soweit messbar Windows-C:-Reserve. Kein Modell oder Audioexport ist darin budgetiert. Lock/Logs
und Vorher-/Nachher-Diskmessung sind integriert.

## 2. Optional die Core-Laufzeitabhaengigkeiten installieren

Zuerst Basispaket installieren, dann passende Torch-/torchaudio-Wheels fuer CPU/CUDA/ROCm bewusst
**in genau dieser venv** einrichten. Auf der
[offiziellen PyTorch-Seite](https://pytorch.org/get-started/locally/) die passende Kombination
waehlen; den Python-Pfad der venv statt globalem pip verwenden. Keine pauschale CUDA-Version fuer
jede GPU annehmen.

```bash
CHATTTS_INSTALL_RUNTIME=1 INSTALL_HEAVY_TOOLS=1 \
  bash scripts/tools/chattts_install.sh --dry-run
CHATTTS_INSTALL_RUNTIME=1 INSTALL_HEAVY_TOOLS=1 \
  bash scripts/tools/chattts_install.sh
```

Der echte Runtime-Schritt verlangt 8 GiB RAM gesamt, 4 GiB verfuegbar, 20 GiB freie Disk und
messbare Windows-C:-Reserve. Er prueft Torch/torchaudio nur per Metadaten und haelt beide exakten
Builds als pip-Constraints fest, statt eine bestehende CUDA-/CPU-Auswahl stillschweigend zu
ersetzen. Torch, torchaudio, NumPy, Numba und llvmlite brauchen passende Wheels. Andere
Core-Abhaengigkeiten koennen kleine Source-Builds benoetigen. Kein
Treiber-/CUDA-/Flash-Attention-/vLLM-/TransformerEngine-Installer.

**Dieser Modus installiert die Core-Abhaengigkeiten aus setup.py, nicht pauschal alle
Demo-/Textnormalisierungs-Abhaengigkeiten aus requirements.txt.** Letztere nennt unter Linux unter
anderem pynini==2.1.5, WeTextProcessing und nemo_text_processing. Dafuer koennen zusaetzliche native
Bibliotheken, andere Python-Versionen oder umfangreiche Builds notwendig sein. Nicht ungeprueft
global installieren. Auch Gradio/WebUI ist separat zu pruefen.

Pip check prueft Abhaengigkeitsmetadaten, nicht CUDA/ABI, Sprachqualitaet, Textnormalisierung oder
Inferenz. Die ganze Dependency-Kette ist noch kein reproduzierbarer Hash-Lock.

## 3. Modelle und WebUI sind separate Freigaben

Unser Installer setzt im eigenen Unterprozess Hub/Transformers offline und entfernt
Hub-Tokenvariablen. Deine aufrufende Shell bleibt unveraendert. Das ist keine
Betriebssystem-Netzwerksandbox. Es wird kein Chat.load, Download, Audioauftrag oder
Token-/Login-Test aufgerufen.

**Wichtig:** Upstreams `source="local"` beim Modellladen bedeutet nicht zwangslaufig offline.
Fehlende Assets koennen automatisch heruntergeladen werden. Fuer spaetere reine Dateinutzung den am
Pin dokumentierten Custom- Pfad und vollstaendige gepruefte Assets verwenden; Modellrechte vorher
lesen. Gewichte aus einem unbekannten Fork nicht blind uebernehmen.

Die Upstream-WebUI hat den Bind-Default **0.0.0.0** und Port 8080. Falls du sie spaeter bewusst mit
vollstaendiger Runtime und freigegebenen Modellen nutzt: `--server_name 127.0.0.1` explizit setzen
und Portkonflikte pruefen. Keine Share-/oeffentlichen Links, kein ungepruefter Tunnel. Es wird hier
bewusst kein sofort ausfuehrbarer WebUI-Start angeboten. Der Installer oeffnet keinen Port, deshalb
Registry-Portliste leer.

## 4. Zielhosts, Rechte und Wartung

| Host                 | Einordnung                                                       |
| -------------------- | ---------------------------------------------------------------- |
| MiniPC / WSL2        | Basispaket leicht; Core-Laufzeit und Modelle separat budgetieren |
| RPi5 / Oracle ARM    | Wheels/Native-Libs und Inferenz nicht hier bestaetigt            |
| Oracle VPS           | eher Queue/Steuerung; kein oeffentlicher Sprachdienst            |
| Gaming-PC / RTX 5080 | passende Torch-/Treiberkombination fuer GPU pruefen              |
| Dual Xeon            | viele Kerne ersetzen keine passende GPU/VRAM                     |
| Kubernetes           | kein Deployment durch diesen Installer                           |

RAM/VRAM und Geschwindigkeit haengen von Textlaenge, Batch, Backend und Modell ab; keine
garantierten GPU-Minima oder Echtzeitversprechen. Nur einen schweren Installations-/Generierungsjob
gleichzeitig starten. Windows/macOS nativ sind hier nicht getestet.

Nur eigene/lizenzierte Texte und autorisierte Stimmreferenzen verwenden, KI-Ausgabe kennzeichnen und
Audios privat sichern. Insbesondere keine kommerzielle Hoerbuch-/Social-Media-Freigabe fuer das
nichtkommerzielle Upstream-Modell aus dieser Integration ableiten.

```bash
bash scripts/tools/chattts_update.sh --dry-run
bash scripts/tools/chattts_update.sh
bash scripts/tools/chattts_install.sh --repair
bash scripts/tools/chattts_uninstall.sh
```

Fuer Core-Runtime-Update/Repair beide Freigaben wie oben setzen. Update behaelt denselben Pin, kein
latest. Fremde/veraenderte Checkouts und venvs werden nicht geloescht oder resettet.

Status trennt Paketinstallation, Runtime-Abhaengigkeiten, Modelle und Inferenztest. Package-Doctor
attestiert nur Pin/Version/venv/Quellursprung; Core-Runtime-Doctor prueft zusaetzlich
Torch-Metadaten und pip check. Uninstall entfernt nur den Marker: Quelle, venv, Modelle und Audios
bleiben.

Offen: echte CPU/GPU-/Textnormalisierungs-/WebUI-Testmatrix, Modellrevisionen/Hashes,
Dependency-Lock, Queue-/Backup-/Restore-Test. Repository-Tests sind lokal synthetisch, ohne reale
Installation oder Modelle.

Quellen:
[setup.py am Pin](https://github.com/2noise/ChatTTS/blob/77b89ee281cd479f5b1a787ada330dc975ca1f2a/setup.py),
[Laufzeitanforderungen](https://github.com/2noise/ChatTTS/blob/77b89ee281cd479f5b1a787ada330dc975ca1f2a/requirements.txt),
[README mit Lizenztrennung](https://github.com/2noise/ChatTTS/blob/77b89ee281cd479f5b1a787ada330dc975ca1f2a/README.md),
[Modellladen](https://github.com/2noise/ChatTTS/blob/77b89ee281cd479f5b1a787ada330dc975ca1f2a/ChatTTS/core.py).
