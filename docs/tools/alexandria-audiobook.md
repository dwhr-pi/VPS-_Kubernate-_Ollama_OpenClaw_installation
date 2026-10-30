# Alexandria Audiobook aus GitHub ohne Docker

Stand 16.10.2026. [Quelle](https://github.com/Finrandojin/alexandria-audiobook), Pin
`be6343d95d94db5f88973aa25575a390f3ce46aa`. Alexandria verbindet Sprecherzuordnung und Qwen3-TTS zur
Hoerbuchproduktion. Code-Lizenz MIT; Modell-, LoRA-, Text- und Stimmenrechte separat pruefen.

**Der neue Installer richtet Quellen und eine isolierte Python-Umgebung ein, noch keine
betriebsbereite GPU-/Hoerbuch-Laufzeit.** Kein Docker oder Pinokio erforderlich.

## 1. Sicherer erster Installationsschritt

Unter Tools Alexandria_Audiobook auswaehlen oder im Setup-Verzeichnis:

```bash
bash scripts/tools/alexandria_audiobook_install.sh --dry-run
bash scripts/tools/alexandria_audiobook_install.sh
bash scripts/tools/alexandria_audiobook_status.sh
bash scripts/tools/alexandria_audiobook_doctor.sh
```

Der Installer prueft Python 3.10-3.12 samt venv/ensurepip/SSL, laedt den gepinnten Sparse-Checkout
und erstellt eine private venv. Keine Gewichte, Referenzaudios, config.json oder vortrainierten
LoRAs werden ausgecheckt. Python-Dateien werden nur syntaktisch per AST geprueft, nicht importiert.
Pinokio-Install-/Reset-/Torch-Skripte werden nicht ausgefuehrt.

Ziel ausserhalb des Setup-Repos:

```text
~/.openclaw_ultimate_user_data/tools/alexandria_audiobook/
  source/app/      App-Quellen und statische WebUI
  venv/           private Python-Umgebung
  source-ready    nach Quellen-/venv-Pruefung
  operation.lock
~/.openclaw_ultimate_user_data/install_logs/alexandria_audiobook_*.log
```

2 GiB Linux-Disk und unter WSL soweit messbar 4 GiB Windows-C:-Reserve werden verlangt, **nur fuer
Quellen/venv**, nicht fuer Torch/Modelle/Exporte. Ein Lock verhindert parallele Installer, Disk wird
vor/nachher gemessen. Dry-Run erstellt keine Dateien und laedt nichts herunter.

Ubuntu-Python 3.12 passt zur Vorbereitung. Alternativ bewusst:

```bash
ALEXANDRIA_PYTHON_BIN=python3.11 bash scripts/tools/alexandria_audiobook_install.sh
```

Bei fehlendem venv/ensurepip bietet der Installer seit 19.10.2026 das versionspassende Ubuntu-Paket
an, beispielsweise `python3.12-venv`. Abfrage: `[(j)a/(N)ein]`, Standard Nein. Ohne Terminal keine
Installation. Ausdrueckliches nichtinteraktives Opt-in:

```bash
ALEXANDRIA_INSTALL_VENV_DEPS=1 bash scripts/tools/alexandria_audiobook_install.sh --repair
```

`ALEXANDRIA_INSTALL_VENV_DEPS=0` deaktiviert diese Paketinstallation. Nur das gewaehlte
System-Python unter `/usr/bin/python3.X` wird so ergaenzt; private Interpreter und aktive venvs
muessen separat repariert werden. SSL- und Versionsfehler werden nicht durch ein venv-Paket
kaschiert. Speicherpruefung, Installationssperre und aktuelles Tool-Log kommen vorher. APT wartet
begrenzt auf Paketverwaltungssperren, ohne Sperrdateien zu loeschen. Nach Paketinstallation wird
venv/ensurepip erneut geprueft; bei Fehlern kein Clone/Build. APT dient nur dieser
Systemvoraussetzung. Alexandria bleibt am GitHub-Pin, ohne Docker, automatische Modelle oder
GPU-Pakete. Kein System-Python wird ersetzt; fremde/beschaedigte Checkouts oder venvs erst sichern
und pruefen, nichts wird automatisch geloescht.

## 2. GPU-Laufzeit separat einrichten

Upstreams install.js leert einen uv-Cache und installiert unter anderem qwen-tts==0.1.1. Die
app/requirements.txt allein ist nicht die komplette Laufzeit. torch.js waehlt je Plattform
CUDA-/ROCm-/CPU-Pakete und teilweise externe Flash-Attention-Wheels. Nicht ungeprueft uebernehmen!

1. [install.js am Pin](https://github.com/Finrandojin/alexandria-audiobook/blob/be6343d95d94db5f88973aa25575a390f3ce46aa/install.js)
   und
   [torch.js](https://github.com/Finrandojin/alexandria-audiobook/blob/be6343d95d94db5f88973aa25575a390f3ce46aa/torch.js)
   vor der nativen Einrichtung lesen.
2. In der privaten venv passende Torch-/torchaudio-/Qwen-/Systembibliotheken einrichten; FFmpeg fuer
   Audioexport vorsehen. Abhaengigkeiten kommen auch von PyPI/GPU-Indizes, Alexandria selbst bleibt
   GitHub-Quelle.
3. Fuer Pakete/Modellcache/Projekte/Exporte freien realen Hostspeicher pruefen, nicht nur die grosse
   freie WSL-Kapazitaet.
4. Erststart und Modellnutzung gesondert freigeben: laut Upstream werden Gewichte beim ersten
   TTS-Einsatz automatisch geladen. Kein Modell-/Adapter- oder Trainingsjob wird durch unseren
   Installer gestartet.

Eine Qwen3-TTS-Installation in einer anderen venv ist nicht automatisch fuer Alexandria verfuegbar.
Alternativ kann der [native Pinokio-Pfad](pinokio.md) verwendet werden, dort die offizielle
Alexandria-GitHub-URL manuell hinzufuegen. Das ist eine andere Installation mit eigener venv; nicht
beide ungeprueft mischen. Pinokio-Skripte sind keine Sandbox.

## 3. Erst nach fertiger Laufzeit manuell starten

**Kein Installationscheck:** Der App-Import kann Arbeitsverzeichnisse erzeugen. Bedienaktionen
koennen spaeter Adapter/Modelle laden oder LLM-Anfragen senden.

```bash
base="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/alexandria_audiobook"
cd "$base/source/app"
export ALEXANDRIA_HOST=127.0.0.1
export ALEXANDRIA_PORT=4200
"$base/venv/bin/python" app.py
```

Port 4200 vorher auf Konflikte pruefen. Browser: [localhost:4200](http://127.0.0.1:4200). Keine
Bindung an 0.0.0.0 oder oeffentlichen Tunnel. Unser Installer oeffnet keinen Port;
Registry-Portliste leer. In der App LLM-Anbieter/Endpunkt bewusst pruefen; lokale OpenAI-kompatible
Skriptaufbereitung ist kein Nachweis aller Modell-/TTS-Funktionen. Keine ungeprueften
Cloud-Fallbacks oder Schluessel.

## 4. Ressourcen, Sicherheit und Update

| Zielhost             | Einordnung                                                      |
| -------------------- | --------------------------------------------------------------- |
| MiniPC / WSL2        | Quellen/venv; CPU-TTS langsam, RAM/Disk separat pruefen         |
| RPi5 / Oracle ARM    | keine hier getestete Torch-/Qwen-Laufzeit                       |
| Oracle VPS           | Steuerung/Queue, keine oeffentliche Hoerbuch-WebUI              |
| Gaming-PC / RTX 5080 | GPU-Worker; Blackwell-faehige Torch-/Treiberkombination pruefen |
| Dual Xeon            | CPU-Kerne ersetzen nicht passende GPU/VRAM                      |
| Kubernetes           | kein Deployment durch diesen nativen Installer                  |

Vorsichtige Startplanung: 16 GiB RAM, 50 GiB freie Disk/Hostreserve und etwa 8 GiB VRAM; groessere
Modelle/Batches brauchen mehr. **Keine hier gemessenen oder garantierten Minima.** Mit kurzem
eigenen Text, eigener Stimme und nur einem Generierungsjob anfangen; LoRA-Training und grosse
Batches bleiben optional.

Nur eigene/lizenzierte Texte und Stimmen mit Einwilligung verwenden, KI-Inhalte kennzeichnen,
Projekte und Stimmreferenzen privat sichern. Keine echten Daten ins Repo. MIT-Code ist keine
pauschale Modell-/Stimmenfreigabe.

```bash
bash scripts/tools/alexandria_audiobook_update.sh --dry-run
bash scripts/tools/alexandria_audiobook_update.sh
bash scripts/tools/alexandria_audiobook_install.sh --repair
bash scripts/tools/alexandria_audiobook_uninstall.sh
```

Update behaelt den Pin; kein Reset/Clean/Loeschen lokaler Aenderungen. Benutzerdateien nach
manuellem App-Start koennen die strenge Quellenpruefung bewusst ausloesen. Projekte, Stimmen,
Configs und Exporte vor Updates sichern, Restore-Test mit kleinem Projekt durchfuehren.

Uninstall entfernt nur den Marker, nicht Quelle/venv/Modelle/Benutzerdaten. Ein separat gestarteter
Server wird dadurch nicht gestoppt. Status/Doctor bestaetigen Quellen/venv, keine
Inferenzbereitschaft.

Offen: getestete Runtime-Pins je GPU, Modell-Freigabe/Hashes, Ressourcenwache bei Generierung,
Queue-Anbindung, Export-/Restore-/Inferenz-Smoke-Test. Keine echte Installation oder Modellnutzung
waehrend unserer Repository-Tests.

Weitere Quellen:
[app.py](https://github.com/Finrandojin/alexandria-audiobook/blob/be6343d95d94db5f88973aa25575a390f3ce46aa/app/app.py),
[Runtime-Pakete](https://github.com/Finrandojin/alexandria-audiobook/blob/be6343d95d94db5f88973aa25575a390f3ce46aa/app/requirements.txt),
[Lizenz](https://github.com/Finrandojin/alexandria-audiobook/blob/be6343d95d94db5f88973aa25575a390f3ce46aa/LICENSE).
