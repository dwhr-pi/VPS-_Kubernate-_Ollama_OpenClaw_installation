# TGI aus GitHub, ohne Docker

## Zuerst: Installationsumfang und Wartungsstatus

Text Generation Inference (TGI) ist ein LLM-Inferenzsystem, kein Videogenerator. Upstream befindet
sich im **Maintenance Mode** und verweist fuer neue Systeme auf Alternativen. Das bedeutet nicht,
dass die Quellen verschwinden, aber auch keine Zusage neuer Modell-/GPU-Unterstuetzung.
[Upstream-Hinweis und lokale Installation](https://github.com/huggingface/text-generation-inference#local-install).

Das Setup verwendet Release **v3.3.7**, festen
[Commit dfb3fbe78e0d1d69251bd33065591c61bafdfaa8](https://github.com/huggingface/text-generation-inference/tree/dfb3fbe78e0d1d69251bd33065591c61bafdfaa8).
Code-Lizenz Apache-2.0; Modell-/Kernel-/Abhaengigkeitslizenzen separat pruefen.
Optional/experimental, kein automatischer Profilpfad und kein Docker.

**Ehrliche Trennung:**

| Setup-Modus                                  | Ergebnis                                               | Nicht enthalten                                                         |
| -------------------------------------------- | ------------------------------------------------------ | ----------------------------------------------------------------------- |
| Standardinstallation                         | gepinnter GitHub-Quellcheckout, Layout-/Syntaxpruefung | keine Pakete, nativen Binaries, Modelle oder Inferenz                   |
| TGI_BUILD_LAUNCHER=1 + INSTALL_HEAVY_TOOLS=1 | zusaetzlich nativer Rust-Launcher                      | Router, Python-Shard, GPU-Kernel und Gewichte fehlen weiterhin          |
| Vollstaendiger nativer Inferenzserver        | noch nicht automatisiert/getestet                      | kein Versprechen eines fertigen TGI-Servers durch die beiden Pfade oben |

Ein Launcher koordiniert andere Prozesse. Er kann allein kein Modell bedienen. `source_ready` und
`launcher_built` sind daher getrennt von `inference_ready`, das hier immer **false** bleibt.
Installation/Doctor starten keine Binaries, Server, Ports, Downloads von Modellen, Cloud-Logins oder
Inferenzanfragen.

## Voraussetzungen und Ressourcen

| Ziel / Modus                                       | CPU, RAM, VRAM, Speicher                                                                                                    |
| -------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| Quellen: WSL2, MiniPC, Oracle VPS, RPi5, Dual Xeon | Linux als normaler Benutzer, Git, flock, Python 3.10+; 1 CPU/1 GiB RAM als nicht gemessener Planungswert; keine GPU noetig  |
| Quellen: Disk-Pruefung                             | 1 GiB frei am Ziel, unter WSL 2 GiB Windows C:; kein separater RAM-Hardcheck fuer Quellen                                   |
| Optionaler Launcher-Build                          | ein Buildjob, mindestens 6 GiB Gesamt-RAM und 4 GiB aktuell verfuegbar; 10 GiB frei am Ziel und unter WSL 10 GiB Windows C: |
| Gaming-PC / RTX 5080                               | kein GPU-/CUDA-Test durch den Launcher-Build; keine garantierte Kompatibilitaet der alten TGI-Kernel mit Blackwell          |
| ARM / Kubernetes                                   | Quellen moeglich; echter ARM-Launcher-Build und Deployment nicht getestet, kein Cluster-/Daemonstart                        |

Dies sind konservative Setup-Reserven, keine gemessenen Upstream-Minima. Modelle und vollstaendige
CUDA-/Python-Umgebungen brauchen zusaetzlichen Platz. Kein automatischer
Swap-/WSL-/Treiber-/System-Python-Umbau.

## Schritt 1: GitHub-Quellen installieren

Im aktuellen Setup-Verzeichnis:

```bash
bash scripts/tools/tgi_install.sh --dry-run
# Nach Pruefung bewusst TGI im Tools-Menue waehlen oder:
bash scripts/tools/tgi_install.sh
bash scripts/tools/tgi_status.sh
bash scripts/tools/tgi_doctor.sh
```

Git, Python und flock ggf. unter Ubuntu separat bereitstellen:

```bash
sudo apt-get update
sudo apt-get install git python3 util-linux
```

Den Installer selbst ohne sudo aufrufen. Es wird kein Upstream-`make install` ausgefuehrt; dessen
Serverpfad ist nicht mit einem blossen Source-Checkout gleichzusetzen. Submodule werden nicht
initialisiert, Git-LFS-Smudge bleibt aus.

```text
~/.openclaw_ultimate_user_data/tools/tgi/
  source/                                  GitHub-Pin
  source-ready                             Quellmarker
  build/release/text-generation-launcher    nur nach optionalem Build
  launcher-built                           Commit und lokaler Binary-Hash
  operation.lock
~/.openclaw_ultimate_user_data/install_logs/tgi_*.log
```

`OPENCLAW_USER_DATA_DIR` kann ein anderes absolutes normalisiertes Ziel ausserhalb Git festlegen.
Umleitende Symlinks werden abgelehnt. Quellen werden auf Commit, sauberen Zustand, Paketdateien und
Python-Syntax geprueft; keine TGI-/Torch-Imports. Lock verhindert parallele Tool-Operationen; Logs
und Diskmessung vor/nach Operation.

## Schritt 2: Optional nur den nativen Launcher bauen

Nur fuer einen bewusst gewaehlten Buildhost mit ausreichenden Ressourcen. Vorhandene aktuelle
Rust-/Cargo-Toolchain, C-Compiler, pkg-config/OpenSSL sowie Python **3.10-3.12 mit Python.h und
libpython** fuer PyO3 sind erforderlich. Ubuntu-Basiswerkzeuge bei Bedarf selbst einrichten:

```bash
sudo apt-get install build-essential pkg-config libssl-dev python3-dev cargo rustc
```

Das ist keine Garantie, dass die Distributions-Rust-Version alle gelockten Crates bauen kann. Bei
inkompatibler Toolchain abbrechen/Log pruefen, keine automatische Lockfile-Aenderung oder pauschalen
Dependency-Upgrades. `TGI_PYTHON_BIN=/pfad/python3.12` kann einen vorhandenen passenden Interpreter
auswaehlen. Es wird kein Fremd-Python gebaut oder System-Python ersetzt.

```bash
TGI_BUILD_LAUNCHER=1 INSTALL_HEAVY_TOOLS=1 \
  bash scripts/tools/tgi_install.sh
```

Dieser ausdrueckliche Build laedt Rust-Abhaengigkeiten aus crates.io/Git und fuehrt fremde
Buildskripte aus. Cargo verwendet seinen vorhandenen Benutzercache und gegebenenfalls vorhandene
Rustup-Toolchain-Regeln. Kein globales Cargo- Installationsziel: `CARGO_TARGET_DIR` zeigt in den
privaten Tool-Workspace. Ein Job, `--locked`, gezielt `text-generation-launcher`, kein gesamter
Workspace. Cargo.lock ist keine vollstaendige Sicherheitspruefung/SBOM.

Der Release-Tag v3.3.7 enthaelt im Cargo-Workspace die Versionsangabe `3.3.6-dev0`. Diese
Upstream-Abweichung wird nicht umgeschrieben und eine Binary wird nicht faelschlich anhand der
Zeichenkette 3.3.7 verworfen. Doctor prueft den lokal erzeugten Hash, fuehrt den Launcher aber nicht
aus. Hash ist Konsistenzpruefung, keine Upstream-Signatur oder Funktionstest.

## Was fuer echte native Inferenz noch fehlt

Der
[Upstream-Serverbuild](https://github.com/huggingface/text-generation-inference/blob/v3.3.7/server/Makefile)
enthaelt Python-/uv-Schritte sowie gesonderte Kernel-/CUDA-Builds und Downloads. Ein vollstaendiger
nativer Pfad muss Router, Python-Shard, Protobuf-Werkzeuge, getestete Torch/CUDA/Kernels und eine
modellbezogene Konfiguration zusammenbringen. Dieses Setup automatisiert diese ungetestete
Kombination nicht nebenbei. Ein blindes `BUILD_EXTENSIONS=True make install` ist keine sichere
Standardloesung fuer jeden WSL-/MiniPC-/RTX-Rechner. CPU-Inferenz ist nicht TGI-Hauptziel.

Vor spaeterem Start Modellrevision, Speicher/VRAM, Gewichtsherkunft und Lizenz pruefen; eigene
Read-Token ausserhalb Git/Logs. Keine beliebigen Remote-Modelle oder fremden Python-Code ohne
Freigabe laden. Erst nach expliziter Einrichtung nur Loopback/VPN, Authentifizierung und
Request-/Kostenlimits vorsehen, keine oeffentliche API oder Tunnel. Es wird kein Beispiel
installiert, das automatisch ein Modell herunterlaedt oder den Server mit einer unsicheren Bindung
startet.

OpenClaw/n8n koennen spaeter eine gepruefte private Modell-API nutzen; nicht den Launcher beliebig
mit Shellargumenten steuern. Queue, ein schwerer Job, Timeout und Freigaben getrennt konfigurieren.
Fuer einen neuen lokalen Einstieg sind die bereits vorhandenen Ollama-/llama.cpp-/vLLM-Pfade separat
zu bewerten; dieser Installer migriert keine Modelle oder Dienste dorthin.

## Update, Reparatur, Deaktivierung

```bash
bash scripts/tools/tgi_update.sh
bash scripts/tools/tgi_install.sh --repair
bash scripts/tools/tgi_uninstall.sh
```

Update/Repair behalten denselben Pin. Mit denselben Build-Opt-ins wird auch der Launcher erneut
gebaut; ohne sie bleiben vorhandene Binaries erhalten. Ein konsistenter Launcher wird bei normaler
Installation wiederverwendet. Fremde, unvollstaendige oder geaenderte Quellen werden nicht
zurueckgesetzt oder geloescht; manuell sichern/pruefen. Bei Buildfehler kein neuer Buildmarker. Kein
transaktionaler Binary-Rollback. Deaktivierung entfernt nur die Marker, erhaelt alle Quellen,
Binaries, Modelle/Caches und Logs; manuelle Benutzung ist weiter moeglich. Keine Prozesse, Tokens
oder Cloud-Ressourcen werden angefasst.

Offen: echter nativer Launcher-Build, ABI-/Linkerpruefung und vollstaendiger
Router-/Python-/GPU-/Modellpfad. Hier nur Offline-Mocks, keine WSL-Installation.
