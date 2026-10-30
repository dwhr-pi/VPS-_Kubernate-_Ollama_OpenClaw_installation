# ViDubb aus GitHub, ohne Docker

## Zuerst: Quellinstallation, nicht betriebsbereit

Der Setup-Eintrag **ViDubb** hat jetzt einen eigenen GitHub-Quellinstaller. Er ersetzt den
allgemeinen Planned-Guard, richtet aber **bewusst noch keine lauffaehige Dubbing-Umgebung** ein.
Keine Docker-Pflicht. Kein Import von `app.py`/`inference.py`, keine Python-Pakete, Checkpoints,
Stimmen, Videos, Cloud-Aufrufe, Dienste oder GUI-Starts bei Installation/Doctor.

Fester
[Quellstand](https://github.com/medahmedkrichen/ViDubb/tree/6a90ea25fd14d7cb241f1c5759fc9f4b8b93f49d):
`6a90ea25fd14d7cb241f1c5759fc9f4b8b93f49d`. Kein erfundenes Release, kein automatisches
`main`/`latest`. Experimenteller Quellpfad, nicht getestet als kompletter Synchronisationsworkflow.
Projektcode Apache-2.0; Wav2Lip, XTTS und andere Gewichte/Komponenten haben eigene Bedingungen.

## Warum kein blindes pip install oder App-Start?

Die Pruefung des
[Einstiegscodes](https://github.com/medahmedkrichen/ViDubb/blob/6a90ea25fd14d7cb241f1c5759fc9f4b8b93f49d/app.py)
zeigt Paketinstallationen bereits beim Import, NLTK-Downloads, Einlesen einer `.env` und Gradio mit
`share=True`. Die Verarbeitung loescht Arbeitsordner und enthaelt einen fest auf CUDA gesetzten
Whisper-Pfad. Modellbedingungen werden per Umgebungsvariable automatisch bestaetigt. Groq ist ein
moeglicher Cloud-Pfad. Das ist kein sicherer Local-first-Startstandard und keine CPU-Garantie.

Die
[Requirements](https://github.com/medahmedkrichen/ViDubb/blob/6a90ea25fd14d7cb241f1c5759fc9f4b8b93f49d/requirements.txt)
pinnen u. a. TensorFlow **2.8.0rc0**, pyannote.audio **3.3.2** und Gradio **5.8.0**; der Einstieg
installiert zusaetzlich alte TTS-Pakete. Keine getestete gemeinsame
Python-/CUDA-/Ubuntu-24.04-/RTX-5080-Konfiguration ableiten. Eine andere Python-Version allein
behebt diese Nebenwirkungen nicht.

Darum blockiert `VIDUBB_INSTALL_RUNTIME=1` weiterhin die Laufzeitinstallation mit konkreter
Begruendung, statt alte Pakete ungeprueft zu installieren. Keine Schutzumgehung durch
`INSTALL_HEAVY_TOOLS=1`.

## Voraussetzungen und Installation

| Ziel / Ressourcenklasse            | Quellinstallation                                                                                                          |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| Linux / WSL2 / MiniPC / VPS / RPi5 | normaler Benutzer, Git mit Sparse-/Partial-Clone-Unterstuetzung, Python 3.10+, flock                                       |
| RAM / CPU / VRAM                   | reine Git-/AST-Pruefung, keine GPU; 1 CPU/1 GiB RAM als Planungswert, kein gemessenes Minimum oder separater RAM-Hardcheck |
| Freier Speicher                    | gepruefte Reserve 1 GiB am Ziel, unter WSL 2 GiB Windows C:                                                                |
| Gaming-PC / RTX 5080 / Dual Xeon   | keine besondere GPU-Freigabe durch den Quellinstaller                                                                      |
| Kubernetes / ARM                   | nur Quellen, keine Nodes/Pods/Worker oder getestete Dubbing-Laufzeit                                                       |

Im aktuellen Setup-Verzeichnis:

```bash
bash scripts/tools/vidubb_install.sh --dry-run
# Danach bewusst im Tools-Menue ViDubb waehlen oder:
bash scripts/tools/vidubb_install.sh
bash scripts/tools/vidubb_status.sh
bash scripts/tools/vidubb_doctor.sh
```

Nicht mit sudo aufrufen. Basiswerkzeuge ggf. separat unter Ubuntu installieren:

```bash
sudo apt-get update
sudo apt-get install git python3 util-linux
```

Es entsteht **nur ein kontrollierter Quellcheckout**, kein verwendbarer Dubbing-Server.
`source_ready=true` ist nicht `runtime_ready=true`.

## Ablage und Sparse-Checkout

```text
~/.openclaw_ultimate_user_data/tools/vidubb/
  source/          gepinnter, eingeschraenkter GitHub-Checkout
  source-ready     Pin der geprueften Quellen
  operation.lock
~/.openclaw_ultimate_user_data/install_logs/vidubb_*.log
```

`OPENCLAW_USER_DATA_DIR` kann ein anderes absolutes normalisiertes Ziel ausserhalb des Repos setzen.
Umleitende Symlinks werden abgelehnt. Kein globaler Python- oder PATH-Umbau und keine Aenderung
deiner WSL-Konfiguration.

Es werden nur README/Lizenz/Requirements, Python-Einstiege und die Codebereiche `tools`/`Wav2Lip`
ausgecheckt. Die eingecheckte Upstream-`.env` wird **nicht gelesen, ausgegeben oder in den
Arbeitsbaum uebernommen**. Medien-/Notebook-/Gewichts- Dateitypen werden ausgeschlossen,
Git-LFS-Smudge bleibt aus. Der Git-Objektspeicher ist keine bereinigte, zur Weiterveroeffentlichung
geeignete Quellverteilung: historische oder ausgeschlossene Dateien koennen weiterhin zu Git
gehoeren. Keine fremden Zugangsdaten verwenden und den Checkout nicht oeffentlich sichern.

Partial Fetch mit `--filter=blob:none` reduziert Transfers, ist aber keine harte Byte-Quota.
Git-Server/Protokoll bestimmen uebertragene Objekte; der Installer verspricht keine vollstaendig
medienfreie Git-Datenbank. Keine Submodule werden initialisiert und keine Downloader/Build-Skripte
ausgefuehrt.

Vor Download: Disk-/Windows-Reserve; dann Lock, private Logs, Messung vorher/ nachher. Source-Doctor
prueft Pin, saubere Quelle, Sparse-Muster und AST-Syntax, **ohne Module zu importieren**. Er testet
weder Modelle noch GUI/GPU/Cloud.

## Update, Reparatur und Deaktivierung

```bash
bash scripts/tools/vidubb_update.sh
bash scripts/tools/vidubb_install.sh --repair
bash scripts/tools/vidubb_uninstall.sh
```

Update/Repair behalten denselben Pin. Fremde, volle, geaenderte oder unvollstaendige Checkouts
werden nicht geloescht/zurueckgesetzt: erst manuell sichern/pruefen. Es gibt keine automatische
Bearbeitung der Upstream-`.env`. Deaktivierung entfernt nur den Marker; Quellen, eigene Daten und
Logs bleiben. Sie verbietet nicht technisch, den Upstream-Code anschliessend selbst zu starten.
Genau das sollte vor dem nachfolgenden Sicherheitsumbau **nicht** geschehen.

## Naechster notwendiger Schritt fuer eine lauffaehige Integration

1. Import-Nebenwirkungen und oeffentliche Gradio-Freigabe in einer separat kontrollierten
   Integrationsschicht entfernen; nur Loopback, explizite Starts.
2. Getesteten Python-/Torch-/TTS-/TensorFlow-Lock erstellen; getrennte venv, sichere
   Checkpoint-Herkunft und reale GPU-Kompatibilitaet testen.
3. Pro Auftrag ein neues Arbeitsverzeichnis, keine pauschalen Loeschbefehle; Eingaben/Outputs und
   Secrets strikt trennen.
4. Provider und Modelldownloads einzeln freigeben; keine automatischen Lizenz- oder
   Nutzungsbedingungen bestaetigen. Stimmen/Personen nur mit Einwilligung.
5. Erst danach OpenClaw/n8n ueber die vorhandene Queue anbinden: ein Job, Timeout, Ressourcenlimits,
   keine beliebigen Shell-/URL-/Token-Eingaben.

Offen sind somit **Laufzeitinstallation und End-to-End-Dubbing**, nicht nur ein kleiner Smoke-Test.
Hier ausschliesslich Offline-Pruefungen, keine Installation oder Medienverarbeitung in deiner WSL.
