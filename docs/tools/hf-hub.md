# Hugging Face Hub aus GitHub, ohne Docker

## Zuerst: Voraussetzungen und Grenzen

**HF_Hub** installiert den Python-Client `huggingface-hub` **2.2.0** und dessen
`hf`-CLI aus dem offiziellen [GitHub-Quellstand](https://github.com/huggingface/huggingface_hub/tree/acfdf30d99441317270cca6e9362dd7f9ff47c55).
Commit `acfdf30d99441317270cca6e9362dd7f9ff47c55`, Release `v2.2.0`;
Apache-2.0 fuer Clientcode. Modell-/Datensatzrechte gelten separat.
Optional/experimental im Setup, keine automatische Profilinstallation.

| Bereich | Konservative Setup-Reserve, keine gemessenen Upstream-Minima |
|---|---|
| Betriebssystem | Linux/WSL2, normaler Benutzer, x86_64 oder ARM64; Git, flock, Python 3.10-3.13 |
| RAM | mindestens 1 GiB gesamt und 512 MiB aktuell verfuegbar |
| Speicher | mindestens 2 GiB frei am Ziel; unter WSL zusaetzlich 2 GiB Windows C: |
| MiniPC / Oracle VPS / RPi5 | nur Client; ARM64-Wheels erforderlich, echter ARM-Pakettest noch offen |
| Gaming-PC / RTX 5080 / Dual Xeon | keine GPU-/VRAM-Pflicht, keine CUDA-Pakete |
| Kubernetes | kein Deployment/Dienst; spaeter privater begrenzter Worker |

Diese Reserve umfasst **nicht** spaetere Modelle/Datensaetze; diese koennen
Hunderte GB/TB belegen. Kein automatischer WSL-/Swap-/Docker-Umbau.
Keine Logins, Tokenabfragen, Modell-/Dataset-Downloads, Uploads, Inferenz,
kostenpflichtigen Jobs, Trainings oder Serverstarts beim Installieren/Doctor.
Eine installierte CLI ist keine Freigabe fuer solche Aktionen.

## Installation

Im aktuellen Setup-Verzeichnis:

```bash
bash scripts/tools/hf_hub_install.sh --dry-run
# Danach bewusst HF_Hub im Tools-Menue auswaehlen oder:
bash scripts/tools/hf_hub_install.sh
bash scripts/tools/hf_hub_doctor.sh
bash scripts/tools/hf_hub_status.sh
```

Ohne sudo aufrufen. Ubuntu-Python 3.12 passt; eigene Interpreter ueber
`HF_HUB_PYTHON_BIN=/pfad/python3`. Fehlende Basiswerkzeuge bei Bedarf separat:

```bash
sudo apt-get update
sudo apt-get install git util-linux python3 python3-venv
```

Fehlendes `venv`/`ensurepip` wird vor Clone/Paketbuild erkannt. Die vorhandene
eng begrenzte Reparatur kann fuer paketverwaltetes Ubuntu-/Debian-Python unter
`/usr/bin` das passende `pythonX.Y-venv` nach sudo-Freigabe nachinstallieren.
APT-Sperren werden begrenzt abgewartet, nie geloescht. Kein System-Python ersetzen,
kein Custom-Python durch apt umbauen. Abschalten der Basisreparatur:

```bash
HF_HUB_AUTO_VENV=0 bash scripts/tools/hf_hub_install.sh
```

## Ablage und Quellen

```text
~/.openclaw_ultimate_user_data/tools/hf_hub/
  source/       gepinnter GitHub-Checkout
  venv/bin/hf   private CLI, kein globaler PATH-Eintrag
  source-built  Commit und Paket-Erfolgsmarker
  operation.lock
~/.openclaw_ultimate_user_data/install_logs/hf_hub_*.log
```

`OPENCLAW_USER_DATA_DIR` kann ein anderes absolutes normalisiertes Ziel ausserhalb
des Setup-Repos festlegen. Umleitende Verzeichnis-/CLI-Symlinks werden abgelehnt;
der normale venv-Python-Symlink bleibt erlaubt. System-Python, andere venvs und
Shellprofile werden nicht umgestellt.

Client und CLI werden aus diesem Checkout gebaut, nicht durch ein beliebiges
PyPI-Hub-Paket ersetzt. Buildwerkzeuge und Abhaengigkeiten kommen aus PyPI.
`hf-xet` ist auf x86_64/ARM64 eine native Pflichtabhaengigkeit dieses Releases:
der Installer akzeptiert dafuer nur Wheels, keinen stillen Rust-Source-Build.
Fehlt ein passendes Wheel, stoppt pip. Keine Torch-/MCP-/OAuth-/Dev-Extras.
Abhaengigkeiten sind noch nicht vollstaendig gehasht/gepinnt; Lock/SBOM offen.
Fremder Paket-Buildcode laeuft mit Benutzerrechten, daher nicht als root bauen.

Diese venv ist getrennt von [HF_Datasets](hf-datasets.md). Dessen eigene
Hub-Abhaengigkeit wird nicht ersetzt oder umkonfiguriert. Der Paketmanager kann
auch andere Upstream-Entrypoints wie `tiny-agents` bereitstellen; das Setup
startet diese nicht und installiert keine zugehoerigen MCP-/Agenten-Extras.

Ein Operationslock verhindert parallele Tool-Operationen. Logs sind privat,
Disk wird vor/nach Paketaufbau gemessen. Konsistenter Bestand wird wiederverwendet.
Doctor/Status pruefen Quell-Pin, Paketversion, `hf`-Entrypoint-Metadaten,
vorhandenes CLI-Skript und `pip check` **ohne CLI-Start oder Hub-Import**.
Das ist kein echter CLI-/Transfer-/Login-Smoke-Test. Dry-Run/Checks installieren
nichts und reparieren keine Systempakete.

## Sicherer Einstieg ohne Download

Version nur aus Paketmetadaten lesen:

```bash
ROOT="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}"
"$ROOT/tools/hf_hub/venv/bin/python" -I -B -c \
  'from importlib.metadata import version; print(version("huggingface-hub"))'
```

Vor spaeterer eigener Nutzung private Ablage/Offline-Modus in derselben Shell
festlegen, ohne dies als technische Sandbox zu verstehen:

```bash
ROOT="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}"
export HF_HOME="$ROOT/huggingface"
export HF_HUB_CACHE="$HF_HOME/hub"
export HF_HUB_DISABLE_TELEMETRY=1
export HF_HUB_DISABLE_IMPLICIT_TOKEN=1
export HF_HUB_OFFLINE=1
```

Diese Umgebungsvariablen ersetzen keine Firewall, Dateirechte oder Quotas.
Der Installer liest/schreibt keine vorhandenen HF-Token und ruft weder
`hf auth login` noch `whoami` als Test auf. Anmeldung ist fuer oeffentliche,
nicht gesperrte Inhalte nicht pauschal erforderlich. Bei gated/private Inhalten
spaeter bewusst minimale Read-Berechtigungen verwenden; Token nicht in
Kommandozeilen, Logs, Git oder Agentenprompts schreiben.

Die native CLI kann bei manueller Nutzung Netzwerk-/Schreib-/Loeschaktionen
und kostenpflichtige Cloud-Funktionen ausloesen. Das Setup schraenkt diese CLI
nicht technisch ein. Fuer eine spaetere Verwendung die
[offizielle CLI-Anleitung](https://huggingface.co/docs/huggingface_hub/en/guides/cli)
lesen und genau Repo-ID, Revision, erlaubte Dateien, Rechte und Zielpfad pruefen.
Kein Voll-Snapshot oder Upload als Installationstest. Offline-Modus nur bewusst
fuer eine freigegebene Aktion aendern; harte Byte-/Zeit-/Dateigrenzen separat
umsetzen. [Datensatz-/Streaming-Grenzen](../media_studio/VIDEO_TRAINING_DATASETS.md).

OpenClaw/n8n duerfen spaeter nur validierte Auftragsdaten an einen eigenen
privaten Queue-Worker liefern. Zuerst ein Job, Timeout und explizite Freigaben;
keine beliebigen CLI-Argumente/Shellbefehle oder Token an Agenten durchreichen.
Dieser Installer startet noch keinen solchen Worker.

## Update, Reparatur und Deaktivierung

```bash
bash scripts/tools/hf_hub_install.sh --repair
bash scripts/tools/hf_hub_update.sh
bash scripts/tools/hf_hub_uninstall.sh
```

Update/Repair verwenden denselben Pin statt `main`/`latest`. Fremde, geaenderte
oder unvollstaendige Quellordner werden nicht geloescht/zurueckgesetzt;
fremde venv-Ordner werden abgelehnt. Manuell pruefen/sichern. Angefangene echte
venv bleibt erhalten und wird vervollstaendigt, kein transaktionaler Rollback.
Bei Fehler kein neuer Erfolgsmarker. Logs nennen den Reparaturpfad.

Deinstallation deaktiviert nur den Marker und erhaelt Quelle, CLI, venv, Cache,
Nutzdaten und Token. Manuelle CLI-Nutzung bleibt moeglich. Token werden nicht
widerrufen und Cloud-Ressourcen nicht gestoppt; diese separat kontrollieren.

Offen: echte Linux-/ARM-Paketinstallation, CLI-Smoke-Test ohne Netzwerk,
vollstaendiger Dependency-Lock und begrenzter Transferworker. Hier nur Offline-
Tests mit Mocks, keine Installation in deiner WSL oder Dateiuebertragung.
