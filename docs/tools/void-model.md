# VOID: GitHub-Quellinstallation ohne Docker

VOID entfernt Objekte samt beeinflussten Interaktionen aus Videos. Die
[offizielle Netflix-Quelle](https://github.com/Netflix/void-model/tree/e3914f8f551dd4b880661991fd6b28cd1699a97a)
basiert auf CogVideoX. Das Setup pinnt Commit
`e3914f8f551dd4b880661991fd6b28cd1699a97a`, Status **experimental**.
Keine erfundene Release-/Python-Paketversion: Der Root hat weder
`setup.py` noch `pyproject.toml` und wird nicht mit pip installiert.

## Installation und Lifecycle

```bash
bash scripts/tools/void_model_install.sh --dry-run
bash scripts/tools/void_model_install.sh
bash scripts/tools/void_model_status.sh
bash scripts/tools/void_model_doctor.sh
bash scripts/tools/void_model_update.sh
bash scripts/tools/void_model_install.sh --repair
```

Der Installer bereitet echte GitHub-Quellen vor: `inference/`, `videox_fun/`,
`config/`, `VLM-MASK-REASONER/`, README, Lizenz und Requirements.
Sparse-Checkout schliesst Medien/Gewichte, .env-Dateien und Notebooks aus.
Git verwendet Partial-Fetch mit `--filter=blob:none`, keine rekursiven
Submodule oder Git-LFS-Downloads. Das beschraenkt den Arbeitsbaum;
Transport-/Metadatenbedarf haengt auch von GitHub/Git ab.

**Nur Quellinstallation, noch keine betriebsbereite Video-Laufzeit.**
Keine Docker-/System-/Python-Pakete, venv, SAM-, CogVideoX- oder VOID-Modelle,
Inferenz, Masken-/GUI-/Notebook-Start, Training, Dienste oder Cloud-Aufrufe.
`source_ready` beschreibt nur gepruefte Quellen, `runtime_ready` bleibt
`false`. Auch das Menue meldet keine fertige Video-Anwendung.

## Pfade und Schutz

Ziel ist `${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/void_model/`.
Darin liegen `source/`, Lock und Quellmarker; Logs werden unter dem
zugehoerigen `install_logs/` angelegt. Keine Daten im Setup-Repo,
Symlink-/nicht normalisierte Datenpfade werden abgelehnt.
Fremde, geaenderte oder unvollstaendige Quellen werden nicht geloescht oder
zurueckgesetzt. Nach manueller Pruefung/Sicherung `--repair` erneut aufrufen.
Updates verwenden denselben Pin, kein automatisches main/latest-Upgrade.

Normaler Linux-Benutzer, Bash, Git, Python 3.10+ fuer AST-Syntaxpruefung,
flock und realpath erforderlich. Keine Systeminstallation dieser Werkzeuge.
Installer-Reserve: 1 GiB freie Ziel-Disk und bei messbarem WSL-Host
2 GiB Windows-C:. Vorher/nachher wird Dateisystemplatz protokolliert.
Der Doctor kontrolliert Pin, Sparse-Policy und ausgewaehlte Python-Syntax
mit `ast.parse`, ohne Module zu importieren oder APIs anzusprechen.

```bash
bash scripts/tools/void_model_uninstall.sh
```

Deaktiviert nur den Quellmarker. Quelle, eigene Daten/Modelle, Caches und
Logs bleiben erhalten; keine vollstaendige Dateiloeschung.

## Laufzeit und Ressourcen bleiben offen

Die [Upstream-Requirements](https://github.com/Netflix/void-model/blob/e3914f8f551dd4b880661991fd6b28cd1699a97a/requirements.txt)
enthalten unter anderem Torch 2.7.1, torchvision 0.22.1 und DeepSpeed 0.17.6.
Ein blindes Requirements-Install wuerde schwere Inferenz-/Trainingsteile
vermischen. Deshalb wird `VOID_MODEL_INSTALL_RUNTIME=1` klar abgelehnt,
statt ungeprueft GPU-Pakete zu installieren. Eine separate, getestete
Inferenz-venv, FFmpeg, CUDA-/Wheel-/ARM-Pruefung und Modell-Hashes fehlen noch.

Upstream nennt fuer den Notebook-Schnellstart eine GPU mit **40 GB+ VRAM**.
Das Notebook laedt Modelle und fuehrt Inferenz aus; der Installer startet es
nicht. Eine RTX 5080 erfuellt diese Angabe nicht automatisch. Keine eigene
Offload-/Quantisierungs- oder Geschwindigkeitszusage. MiniPC/RPi/VPS sind
hier nur fuer Quellvorbereitung vorgesehen, nicht als getestete Inferenzhosts.
GPU-Workstation/Kubernetes: VRAM, RAM und Modell-/Cache-Disk getrennt planen;
die kleine Installer-Reserve ist dafuer nicht ausreichend.

## Cloud-Grenze und Rechte

Die mitgelieferte Maskenpipeline verwendet Gemini/Google API sowie
separat benoetigte SAM2/SAM3-Modelle. **GitHub-Code bedeutet hier nicht,
dass der gesamte Workflow lokal arbeitet.** Im Installer-Subprozess werden
Gemini-/Google-/HF-Token entfernt und Hub-Offline-Flags gesetzt; keine
Secrets werden abgefragt oder protokolliert. Das ist keine Netzwerksandbox.
Masken/Prompts fuer reine Inferenz koennen bewusst lokal vorbereitet werden;
ein gepruefter vollstaendig lokaler Maskenadapter ist damit nicht implementiert.

Modellwahl, API-Freigabe und echte Videodaten bleiben separate Entscheidungen.
Keine vertraulichen Aufnahmen an Gemini senden. Eigene/freigegebene Videos,
Einwilligungen und Kennzeichnung von Bearbeitungen beachten; kein Werkzeug
zum vermeintlich beweissicheren Wiederherstellen urspruenglicher Szenen.
Code-Lizenz: [Apache-2.0](https://github.com/Netflix/void-model/blob/e3914f8f551dd4b880661991fd6b28cd1699a97a/LICENSE).
VOID-/CogVideoX-/SAM-Modellbedingungen und Datenrechte separat pruefen.

Offline-Tests pruefen Registry, Menue, Quell-/Pfadschutz, Syntax ohne Import
und Sparse-Ausschluesse in einem synthetischen lokalen Git-Repository.
Kein echter Upstream-Clone, Paket-/Modellbau, GPU-Test, WSL-Zugriff oder
Videobearbeitung wurde dafuer ausgefuehrt.
Siehe [Medienkatalog](../media_studio/AUDIO_VIDEO_TOOL_CATALOG.md).
