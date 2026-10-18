# Wan2.1 aus GitHub, ohne Docker

## Menue-Status

Das Tools-Menue gleicht die Registrierung mit `source-ready` ab, ohne Git,
GPU oder Netzwerk abzufragen. Registrierung bedeutet vorbereitete Quellen,
nicht fertige Inferenz. Deaktivierung entfernt den Eintrag aus beiden
Statusdateien; erhaltene Quellen allein markieren Wan21 nicht als installiert.
Eine leere Hauptstatusdatei wird nicht erneut aus der alten Kopie importiert.

## Zuerst: Was wird installiert?

`Wan21` verwendet jetzt einen eigenen **experimentellen GitHub-Installer**, nicht
mehr den gemeinsamen Hybrid-Platzhalter. Quelle ist
[Wan-Video/Wan2.1](https://github.com/Wan-Video/Wan2.1), fester Commit
`9737cba9c1c3c4d04b33fcad41c111989865d315`. Keine automatische Verfolgung
von `main`, kein Container, keine automatische Treiberinstallation.

Es gibt drei getrennte Schritte:

1. **Quellcode installieren:** Standard des Menuepunkts, klein und ohne GPU.
2. **GPU-Python-Laufzeit installieren:** schwere Pakete, nur mit zwei Opt-ins.
3. **Modellgewichte bereitstellen und Videos erzeugen:** separate manuelle
   Schritte, nicht Bestandteil dieses Installers.

`source-ready`/`source_ready: true` beweist nur einen sauberen gepinnten
Quellstand mit Syntaxpruefung. Es ist **keine fertige Videolaufzeit**.
`runtime-ready` bedeutet nur erfolgreiche Paket-/Metadatenpruefung, nicht
getestete CUDA-Kernels oder fertige Modelle. Das allgemeine Setup erfasst den
Quellmarker, keinen vollstaendigen GPU-/Modelltest.

## Voraussetzungen und Ressourcen

| Variante | Unsere Setup-Reserve | Weitere Voraussetzungen |
|---|---|---|
| Nur Quellcode | 512 MiB freie Ziel-Disk, unter WSL 1 GiB Windows-C:-Reserve | Linux, normaler Benutzer, Git, Bash, Python 3, flock |
| GPU-Pakete | 16 GiB Gesamt-RAM, 32 GiB freie Ziel-Disk und unter WSL 32 GiB frei auf C: | Linux x86_64, Python 3.10-3.12 mit venv, NVIDIA-Treiber/GPU, CUDA Toolkit 12.8 mit nvcc, C++-Compiler, tar |
| Modelle/Rendering | zusaetzlich modell-, aufloesungs- und laengenabhaengiger Speicher/RAM/VRAM | getrennt planen und vor jedem Job messen |

Das sind konservative **Setup-Grenzen**, keine gemessenen universellen
Wan-Mindestanforderungen. Die C:-Pruefung wird im vorhandenen WSL-Helfer ueber
`/mnt/c` ermittelt; unbekannte/externe Datentraeger separat kontrollieren.
Python 3.12 von Ubuntu 24.04 passt zum automatisierten Paketpfad. Das Setup
ersetzt kein System-Python und baut hier kein zusaetzliches Python.

Upstream nennt fuer T2V-1.3B etwa **8,19 GB VRAM**; das ist kein pauschaler
Wert fuer 14B, hohe Aufloesung oder jeden Workflow.
[Upstream-Ressourcenhinweis](https://github.com/Wan-Video/Wan2.1#readme).
RTX 5080/Blackwell ist **nicht** automatisch kompatibel mit jeder Flash-
Attention-Version: CUDA, PyTorch und Kernel-Unterstuetzung separat testen.
Auf MiniPC, RPi oder Oracle-VPS ohne passende GPU nur den Quellpfad nutzen;
Rendering auf einem getrennten GPU-Worker. Kein GPU-Sharing/Cluster-Deployment
wird hier eingerichtet. ARM-Codebereitstellung ist moeglich, der automatische
GPU-Paketpfad bleibt auf x86_64 begrenzt.

## 1. Quellinstallation

Im aktuellen Setup-Checkout, ohne sudo:

```bash
bash scripts/tools/wan21_install.sh --dry-run
bash scripts/tools/wan21_install.sh
bash scripts/tools/wan21_status.sh
bash scripts/tools/wan21_doctor.sh
```

Oder **Wan21** im Tools-Menue bewusst auswaehlen. Quelle wird unter
`~/.openclaw_ultimate_user_data/tools/wan21/source/` abgelegt. Git-Prompt ist
deaktiviert: fuer das oeffentliche Repo werden keine GitHub-Zugangsdaten
benoetigt. Syntaxpruefung per AST, keine `wan`-/`torch`-Imports oder Inferenz.
Fehlende Basiswerkzeuge muessen bewusst separat eingerichtet werden.

## 2. Optionale schwere CUDA-Pakete

Erst auf dem passenden GPU-Rechner nach Ressourcen-/CUDA-Pruefung ausfuehren:

```bash
WAN21_INSTALL_RUNTIME=1 INSTALL_HEAVY_TOOLS=1 \
  bash scripts/tools/wan21_install.sh --dry-run

WAN21_INSTALL_RUNTIME=1 INSTALL_HEAVY_TOOLS=1 \
  bash scripts/tools/wan21_install.sh
```

Der Dry-Run zeigt den Plan, installiert und testet keine GPU. Der reale Aufruf
prueft vor Downloads RAM, Disk, GPU/Treiber und CUDA-Buildwerkzeuge.
`WAN21_PYTHON_BIN=/absoluter/pfad/python3` waehlt optional vorhandenes Python.
`WAN21_BUILD_JOBS=1` begrenzt Flash-Attention-Buildparallelitaet; Standard 2,
maximal 4. Nur **einen** solchen Installations-/Renderjob gleichzeitig ausfuehren.

Die private `venv/` erhaelt PyTorch 2.10.0 und torchvision 0.25.0 als CUDA-12.8-
Wheels von [PyTorch](https://pytorch.org/get-started/previous-versions/).
Buildwerkzeuge, Flash Attention und weitere Abhaengigkeiten kommen aus PyPI;
NumPy ist auf 1.26.4 und Transformers auf `<5` begrenzt. Diese Einschraenkungen
reduzieren bekannte Brueche, ersetzen aber keinen vollstaendigen Lockfile-/
Kompatibilitaetstest. Weitere Upstream-Abhaengigkeiten sind nicht komplett
mit Versionen/Hashes verriegelt; ein spaeterer Lauf kann andere Pakete erhalten.

Der Programmcode kommt aus GitHub, **nicht alle Abhaengigkeiten**. Flash
Attention kann nativen Fremdcode kompilieren; niemals als root bauen. Der
[gepruefte Modellpfad](https://github.com/Wan-Video/Wan2.1/blob/9737cba9c1c3c4d04b33fcad41c111989865d315/wan/modules/model.py)
ruft `flash_attention` direkt auf. Das Paket deshalb nicht einfach weglassen
und eine garantiert funktionierende SDPA-Fallback-Laufzeit behaupten.
Paketbau erfolgt in einer separaten lokalen `runtime-build.*`-Kopie aus dem
gepinnten Git-Archiv; der verwaltete Checkout bleibt sauber. Diese Kopie ist
kein zweiter Update-Kanal und bleibt zur Fehlerdiagnose erhalten.

Der Installer startet weder Generator noch Gradio, DashScope, Cloud-Login,
API, Webserver oder Modelle. Er prueft anschliessend `pip check` und Metadaten,
keine Renderfunktion. Eine gescheiterte Paketinstallation erhaelt keinen neuen
Runtime-Erfolgsmarker; Quellcode und Diagnose-Dateien bleiben erhalten.

## 3. Modellgewichte und erster Test

Gewichte sind **nicht im GitHub-Clone enthalten**. Geeignete offizielle
Wan-AI-Checkpoints separat nach Lizenz-, Revision-, Downloadgroessen- und
Speicherpruefung von den im Upstream verlinkten Modellquellen beziehen.
Nicht alle T2V-/I2V-Checkpoints sind austauschbar. Kein automatisches Login,
Tokenlesen oder Hugging-Face-Download durch diesen Installer.

Erst wenn GPU-Pakete UND passende Gewichte vorliegen, selbst einen kleinen
Test mit eigenen erlaubten Prompts starten. Beispiel fuer den 1.3B-T2V-Pfad,
mit eigenem existierendem Checkpoint-Verzeichnis:

```bash
cd "$HOME/.openclaw_ultimate_user_data/tools/wan21/source"
../venv/bin/python generate.py --task t2v-1.3B --size '832*480' \
  --ckpt_dir /PFAD/ZUM/Wan2.1-T2V-1.3B \
  --offload_model True --t5_cpu \
  --prompt 'A paper boat floating on a calm pond'
```

Dieser Befehl erzeugt erst bei manueller Ausfuehrung ein Video und ist kein
automatisch getestetes Ergebnis. Fuer eigene Exporte vorzugsweise ein
privates Ausgabeziel ueber die Optionen des gepinnten Generators angeben.
Keine Cloud-Prompt-Erweiterung aktivieren. OpenClaw/n8n duerfen spaeter nur
validierte Jobparameter in einer seriellen GPU-Queue uebergeben, nicht
ungefilterte Shellstrings. Adapter, ComfyUI-Nodes und Render-Queue-Verdrahtung
sind **nicht** Teil dieses Installers. Personen-/Stimmenrechte beachten.

## Update, Fehler und Deaktivierung

```bash
bash scripts/tools/wan21_update.sh
bash scripts/tools/wan21_install.sh --repair
bash scripts/tools/wan21_uninstall.sh
```

Update prueft denselben Pin, kein stilles `git pull main`. Fuer erneute
GPU-Paketinstallation die beiden Opt-in-Variablen erneut setzen. Normaler
Install-Aufruf laesst bereits konsistente Pakete bestehen. Doctor/Status
laden nichts herunter und legen keinen Workspace an. Doctor mit vorhandenem
Runtime-Marker prueft dessen Pakete offline, nicht GPU oder Modelle.

Workspace-Override: `OPENCLAW_USER_DATA_DIR`, absolut und ausserhalb Git.
Symlinks und fremde/veraenderte/unvollstaendige Quellen werden abgelehnt,
nicht geloescht oder zurueckgesetzt. Nach manuellem Sichern/Umbenennen erneut
installieren. Lock verhindert parallele Operationen. Protokolle liegen in
`~/.openclaw_ultimate_user_data/install_logs/wan21_*.log`.

Deinstallation bedeutet **Deaktivierung der Setup-Marker**: Quellcode, venv,
Build-Dateien, Gewichte, Exporte und Logs bleiben erhalten. Manuell gestartete
Programme werden nicht beendet. Derzeit kein transaktionaler venv-Rollback.
Keine Keys, Tokens oder privaten Daten in Git/Prompts/Logs speichern.

Getestet werden hier nur Offline-/Mockpfade. Ein echter CUDA-/Flash-Attention-
Build, Modellrendering und die RTX-5080-Kompatibilitaet bleiben offen.
