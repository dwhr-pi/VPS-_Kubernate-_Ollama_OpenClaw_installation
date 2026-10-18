# DeepFilterNet aus GitHub, ohne Docker

## Zuerst: Zweck und Voraussetzungen

Optionaler **experimenteller Rust-CPU-Build**, keine Pflichtinstallation.
DeepFilterNet reduziert Rauschen in Sprache. Es entfernt keinen Deepfake,
rekonstruiert keine echte Originalstimme und beweist keine Authentizitaet.
Originalaufnahmen unveraendert sichern; nur autorisierte Arbeitskopien bearbeiten.

Der Installer verwendet [Release v0.5.6](https://github.com/Rikorose/DeepFilterNet/releases/tag/v0.5.6),
Commit `978576aa8400552a4ce9730838c635aa30db5e61`. Bewusst kein `main`/`latest`.
Das ist ein aelterer stabiler Release, keine Behauptung aktueller Wartung oder
eines Audits aller Rust-Abhaengigkeiten. Code: MIT/Apache-2.0 laut
[Cargo-Manifest](https://github.com/Rikorose/DeepFilterNet/blob/v0.5.6/libDF/Cargo.toml).
Modell-/Medienrechte separat pruefen.

Unsere konservativen **Build-Reserven**, keine gemessenen Upstream-Minima:

| Ziel | CPU / RAM / VRAM / freier Speicher |
|---|---|
| Linux, MiniPC, WSL2 | ein Cargo-Buildjob; 6 GiB gesamt, 4 GiB aktuell verfuegbar; keine GPU/VRAM-Pflicht; 8 GiB Disk |
| WSL2 | zusaetzlich 8 GiB auf Windows C:; kein automatischer WSL-/Swap-Umbau |
| Oracle VPS / RPi5 ARM64 | gleicher CPU-Quellbuild; kleine RAM-Konfigurationen ungeeignet; ARM noch nicht Ende-zu-Ende getestet |
| Gaming-PC / RTX 5080 / Dual Xeon | CPU-Pfad, kein CUDA-/Multi-GPU-Build; mehr Kerne erhoehen hier nicht die Parallelitaet |
| Kubernetes | kein Deployment/Daemon; CLI spaeter nur in einem begrenzten privaten Worker betreiben |

Linux als normaler Benutzer, Git, flock, SHA-256, timeout, C-Linker und
**Rust/Cargo** erforderlich. Vorhandenes Rust unter `~/.cargo/bin` wird auch
ohne Shell-Neustart erkannt. Fehlen Build-Werkzeuge, bietet der Installer unter
Ubuntu/Debian deren Einrichtung nach Ressourcenpruefung mit `[(j)a/(N)ein]` an.
Ohne Bestaetigung wird nichts installiert. Fuer bewusst freigegebene,
nichtinteraktive Aufrufe: `DEEPFILTERNET_INSTALL_BUILD_DEPS=1`; mit `0` sperren.
Nur Basis-/Build-Werkzeuge kommen dabei via apt (mit Sperrwartezeit),
DeepFilterNet selbst weiterhin aus GitHub, ohne Docker. Dry-Run/Status/Doctor/
Deaktivierung installieren keine Abhaengigkeiten. Alternativ manuell:

```bash
sudo apt-get update
sudo apt-get install git util-linux coreutils build-essential cargo rustc
```

Rust-Builds koennen trotz erfuellter Reserve scheitern. Das alte Cargo.lock
mit einer aktuellen Rust-Version ist nicht hier real gebaut worden. Es wird
nicht automatisch eine Toolchain heruntergestuft oder ein Lockfile umgeschrieben.

## Installation im Setup

1. Aktuelles Setup-Arbeitsverzeichnis verwenden und Plan lesen:

```bash
bash scripts/tools/deepfilternet_install.sh --dry-run
```

2. Im Tools-Menue **DeepFilterNet** bewusst auswaehlen, alternativ:

```bash
bash scripts/tools/deepfilternet_install.sh
bash scripts/tools/deepfilternet_doctor.sh
bash scripts/tools/deepfilternet_status.sh
```

Keine Docker-, Python-, pip-, PyTorch-, GPU-, Mikrofon- oder Cloud-Einrichtung.
Der offizielle GitHub-Checkout enthaelt bereits `DeepFilterNet3_onnx.tar.gz`;
dieses Modell wird mit `default-model` in die CPU-Binary eingebettet.
**Nicht modellfrei:** GitHub liefert Code und enthaltene Gewichte. Cargo laedt
Build-Abhaengigkeiten aus crates.io/Git-Quellen gemaess Cargo.lock. `--locked`
sperrt die Aufloesung, macht den Build aber weder offline noch vollstaendig
vertrauenswuerdig. Build-Skripte fremder Crates laufen mit Benutzerrechten.

```text
~/.openclaw_ultimate_user_data/tools/deepfilternet/
  source/                     gepinnter GitHub-Checkout
  build/release/deep-filter    lokale CPU-CLI
  source-built                Commit und lokal erzeugter Binary-Hash
  operation.lock
~/.openclaw_ultimate_user_data/install_logs/deepfilternet_*.log
```

`OPENCLAW_USER_DATA_DIR` kann ein anderes absolutes normalisiertes Verzeichnis
ausserhalb des Repos festlegen. Symlink-Ziele werden abgelehnt. Kein globales
CLI/PATH und keine Shellprofile werden veraendert. Cargo nutzt seinen vorhandenen
Benutzercache. Der Hash ist ein Konsistenzcheck, keine Upstream-Signatur.

Ein vorhandener sauberer Build wird wiederverwendet. Build mit einem Job,
Ressourcencheck vor Downloads, Operationslock und Diskmessung vorher/nachher.
Bei Fehler bleibt der Erfolgsmarker aus. --version wird nach dem Build mit
Timeout geprueft; es liest keine Audios. Doctor prueft nur Commit und Hash,
fuehrt die Binary nicht aus und testet keine Rauschminderung.

## Manuelle Anwendung auf einer Kopie

Nach eigener Freigabe, **nicht als Teil des Installers**, zunaechst eine kurze
WAV-Arbeitskopie testen. 48 kHz ist der dokumentierte Modellpfad; Ausgabe in
einem neuen Ordner, niemals Original- und Ausgabeordner gleich setzen.
Die CPU-CLI heisst `deep-filter`, nicht die Python-CLI `deepFilter`.

```bash
ROOT="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}"
OUT="$HOME/deepfilternet-test-$(date +%Y%m%d_%H%M%S)"
mkdir "$OUT"
"$ROOT/tools/deepfilternet/build/release/deep-filter" \
  --output-dir "$OUT" /pfad/zur/freigegebenen-arbeitskopie.wav
```

Nicht automatisch ausfuehren. Ergebnisse anhoeren und als bearbeitet
kennzeichnen. Hall, Musik und konkurrierende Sprecher werden nicht garantiert
sauber getrennt. Fuer forensische Untersuchungen kann jede Bearbeitung relevante
Spuren veraendern. Keine Herkunftsverschleierung oder Umgehung von Detektoren.

## Update, Fehler und Deaktivierung

```bash
bash scripts/tools/deepfilternet_install.sh --repair
bash scripts/tools/deepfilternet_update.sh
bash scripts/tools/deepfilternet_uninstall.sh
```

Update/Repair bauen denselben geprueften Pin, kein automatisches Upgrade.
Fremde/geaenderte/unvollstaendige Quellordner werden nicht geloescht oder
zurueckgesetzt: manuell sichern/pruefen. Logs bei Buildfehlern lesen; weder
Cargo.lock automatisch erneuern noch endlos wiederholen. Kein transaktionaler
Binary-Rollback. Deinstallation deaktiviert **nur den Marker** und erhaelt
Quelle, Binary, Modell, Audios und Logs. Die Binary ist danach weiterhin
manuell ausfuehrbar; dies ist keine technische Zugriffssperre.

## OpenClaw / n8n

Keine aktive Integration wird gestartet. Spaeter kann ein freigegebener lokaler
[Queue-Worker](../JOB_QUEUE_AGENT_WORKER.md) die CLI fuer genau eine Arbeitskopie
aufrufen: Pfade validieren, eigene Ausgabeverzeichnisse, Timeout, nur ein Job,
keine Shellbefehle aus Mail-/Audio-Metadaten und keine automatischen Uploads.
Kein Port, Token oder API-Key notwendig. Mikrofon-/PipeWire-/LADSPA-Dienste und
Training sind nicht enthalten.

Offen: echter Linux-/ARM-Source-Build, Rust-Toolchain-Kompatibilitaet, SBOM/
Vulnerability-Scan, Audioqualitaetsvergleich und gemessene Laufzeit/RAM-Werte.
Hier wurden nur Offline-Tests mit Mocks durchgefuehrt, keine WSL-Installation.
