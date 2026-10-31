# AudioSeal aus GitHub, ohne Docker

## Zuerst lesen: Zweck und Ressourcen

AudioSeal ist eine **Python-Bibliothek fuer eigene Audio-Wasserzeichen**: Generator und Detektor.
Kein universeller Deepfake-Detektor und kein Werkzeug zum Entfernen von Herkunftshinweisen. Ein
negatives Ergebnis beweist weder Echtheit noch Abwesenheit anderer Wasserzeichen. Ergebnisse
brauchen Kontext.
[Offizielle Beschreibung](https://github.com/facebookresearch/audioseal/blob/e63a8a0e5cdf7bb797159c92ba15961557fe9bd2/README.md).

Optionaler, experimenteller Installer: **CPU-Pakete werden bei ausdruecklicher Installation
eingerichtet**, nicht nur Quellen abgelegt. Kein Docker, CUDA, Server, Port, Mikrofonzugriff oder
Modell-/Audio-Test. Das Paket allein kann noch keine Wasserzeichen erkennen: Gewichte und Anwendung
sind separate Schritte.

Unsere konservative Setup-Reserve (keine gemessenen Upstream-Minima):

| Ziel / Bereich                         | Voraussetzung                                                                              |
| -------------------------------------- | ------------------------------------------------------------------------------------------ |
| Linux / WSL2 / MiniPC / Oracle VPS     | x86_64, Python 3.10-3.13, Git, flock; 6 GiB Gesamt-RAM und 4 GiB aktuell verfuegbar        |
| Speicher                               | mindestens 8 GiB frei am Installationsziel; unter WSL zusaetzlich 8 GiB auf Windows C:     |
| GPU / Gaming-PC / RTX 5080 / Dual Xeon | CPU-Paketpfad ohne VRAM-Pflicht; kein CUDA-/Multi-GPU-Training                             |
| RPi5 / Oracle ARM / andere ARM-Systeme | automatischer Paketpfad noch nicht freigegeben; separate Wheel-/Buildpruefung erforderlich |
| Kubernetes                             | kein automatisches Deployment; spaeter privater ressourcenbegrenzter Worker                |

Andere schwere Jobs vorher beenden. Es wird kein Swap, Docker-Socket, System-Python oder WSL-Limit
umgestellt. Ressourcenwerte sind Schutzreserven, keine Garantie fuer erfolgreiche Paketinstallation
oder spaetere Audioleistung.

## Installieren

Im aktuellen Setup-Verzeichnis zunaechst den Plan lesen:

```bash
bash scripts/tools/audioseal_install.sh --dry-run
```

Danach **AudioSeal** im Tools-Menue bewusst auswaehlen oder:

```bash
bash scripts/tools/audioseal_install.sh
bash scripts/tools/audioseal_doctor.sh
bash scripts/tools/audioseal_status.sh
```

Ohne `sudo` aufrufen. Git und flock bei Bedarf unter Ubuntu separat einrichten:

```bash
sudo apt-get update
sudo apt-get install git util-linux python3 python3-venv
```

Bei fehlendem `ensurepip` nutzt der Installer die bereits vorhandene, eng begrenzte venv-Reparatur:
nur paketverwaltetes Debian-/Ubuntu-System-Python unter `/usr/bin`, passendes `pythonX.Y-venv`,
sudo-Freigabe und APT-Lock-Wartezeit. Kein System-Python ersetzen, keine fremden Python-Builds
automatisch umbauen. Das laesst sich abschalten:

```bash
AUDIOSEAL_AUTO_VENV=0 bash scripts/tools/audioseal_install.sh
```

Eigenen kompatiblen Interpreter ueber `AUDIOSEAL_PYTHON_BIN=/pfad/python3` auswaehlen. Python 3.12
von Ubuntu 24.04 ist fuer diesen Paketpfad vorgesehen; ein alter Python-3.11-Source-Build ist nicht
erforderlich.

## Was installiert wird

Fester
[GitHub-Commit](https://github.com/facebookresearch/audioseal/tree/e63a8a0e5cdf7bb797159c92ba15961557fe9bd2)
`e63a8a0e5cdf7bb797159c92ba15961557fe9bd2`, Paketversion **0.2.0**. Kein `main`-/`latest`-Update.
Der Quellstand wurde gelesen, aber noch nicht durch einen echten Linux-Paketbuild und Audiotest
bestaetigt.

```text
~/.openclaw_ultimate_user_data/tools/audioseal/
  source/           gepinnter GitHub-Checkout
  venv/             private Python-/CPU-Pakete
  constraints.txt   torch==2.10.0+cpu
  source-built      Commit und CPU-Erfolgsmarkierung
  operation.lock
~/.openclaw_ultimate_user_data/install_logs/audioseal_*.log
```

`OPENCLAW_USER_DATA_DIR` kann ein anderes absolutes normalisiertes Ziel ausserhalb des Setup-Repos
festlegen. Umleitende Verzeichnis-Symlinks werden abgelehnt; der normale Python-Symlink innerhalb
einer venv bleibt erlaubt.

AudioSeal selbst wird mit Flit **aus dem GitHub-Checkout** gebaut, nicht durch
`pip install audioseal` aus PyPI ersetzt. PyTorch **2.10.0+cpu** kommt vom offiziellen
PyTorch-CPU-Index, ohne CUDA-Pakete. NumPy, OmegaConf, einops und Buildwerkzeuge kommen aus PyPI.
Abhaengigkeiten sind ausser Torch nicht voll gepinnt/gehasht; ein kompletter Dependency-Lock und
SBOM bleiben offen. GitHub als Primaerquelle bedeutet nicht, dass alle Fremdbibliotheken dort
liegen. Fremder Build-Code laeuft mit Benutzerrechten; keine Installation als root.

Keine Dev-/Training-Extras, torchaudio, Decoder oder Hugging-Face-Login werden automatisch
eingerichtet. Status/Doctor pruefen Commit, Paketmetadaten und `pip check`, ohne `audioseal`/`torch`
zu importieren. Das ist kein Modelltest. Install/Update haben Lock, private Logs und Diskmessung
vor/nach Paketaufbau. Dry-Run/Status/Doctor laden nichts nach und reparieren keine Systempakete.

## Modelle und sichere spaetere Nutzung

**Wichtige Sicherheitsgrenze:** Der
[Upstream-Loader](https://github.com/facebookresearch/audioseal/blob/e63a8a0e5cdf7bb797159c92ba15961557fe9bd2/src/audioseal/loader.py)
verwendet `torch.load(..., weights_only=False)`. Checkpoints koennen damit Python-Code ausfuehren.
Niemals ungepruefte Gewichte aus Mails, Uploads oder beliebigen Modell-Repositories laden. Eigenen
unprivilegierten Prozess, beschraenkte Dateirechte und getrennte Testumgebung verwenden.

Der Loader kann bei Modellkarten externe URLs/Hugging Face kontaktieren und lokal cachen. Das ist im
Installer nicht aktiviert: kein `load_detector`, `load_generator` oder `from_pretrained`.
HF-Offlinemodus allein blockiert nicht jeden moeglichen Downloadpfad des Loaders. Vor spaeterer
Nutzung genaue Modellrevision, Herkunft, Hashes, Rechte und Netzwerkfreigabe separat pruefen.
Upstream nennt MIT auch fuer Gewichte; konkrete Revision trotzdem kontrollieren.

Fuer spaetere eigene Anwendungen:

1. Nur eigene/freigegebene Arbeitskopien benutzen, Original und Hash sichern.
2. Vertrauenswuerdige offizielle Gewichte getrennt pruefen/freigeben.
3. Ein-/Ausgabe und Samplerate pruefen; Anwendung ausserhalb des Setup-Repos entwickeln. Diese
   Bibliothek liefert hier kein fertiges Desktop-/CLI-Audioprogramm.
4. Eigene Inhalte optional mit Wasserzeichen versehen oder bekannte eigene AudioSeal-Wasserzeichen
   pruefen; keine automatischen Echtheitsurteile.
5. Bearbeitete Ergebnisse kennzeichnen; keine Cloud-Uploads ohne Freigabe.

Es wird bewusst kein sofort ausfuehrbares Modelllade-Beispiel installiert. Ein spaeterer
OpenClaw-/n8n-Auftrag braucht einen gesondert getesteten privaten Worker mit validierten Pfaden,
Timeout, einem Job gleichzeitig und manueller Freigabe. Keine beliebigen Shell-/Checkpoint-Pfade aus
Agentenprompts uebernehmen.

## Reparatur, Update, Deaktivieren

```bash
bash scripts/tools/audioseal_install.sh --repair
bash scripts/tools/audioseal_update.sh
bash scripts/tools/audioseal_uninstall.sh
```

Normale Installation verwendet konsistente Pakete wieder. Update/Repair bauen denselben Pin; neue
Versionen werden nicht ungeprueft verfolgt. Fremde oder veraenderte Quellordner und fremde
venv-Ziele bleiben unangetastet; zuerst manuell sichern. Angefangene echte venv wird ohne Loeschung
vervollstaendigt. Kein transaktionaler Paket-Rollback. Bei Fehler kein neuer Erfolgsmarker.

Deinstallieren deaktiviert nur den Setup-Marker: Quelle, venv, Modelle, Audios und Logs bleiben
erhalten. Weiterer manueller Import bleibt technisch moeglich. Kein automatisches Entfernen von
Nutzerdaten oder globalen Python-Paketen.

Offen: echter CPU-/Import-/Modell-Smoke-Test, ARM-Wheels, kompletter Lock, gemessene Performance und
abgesicherter Anwendungsworker. Hier nur Offline-Mocks; keine WSL-, Modell- oder Audioaktionen durch
Codex.
