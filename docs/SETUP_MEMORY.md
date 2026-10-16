# Setup Memory

## HF Datasets GitHub-Basispaket, 2026-10-16

- 5.1.0, Pin efe6ea4f88260b1a5066f28a9c90d82365a29f42, private venv;
  keine Decoder-/Torch-/Training-Extras und keine Daten-/Modell-/Token-Aktionen.
- >=2 GiB gesamt, >=1 GiB verfuegbar, 4 GiB Disk/WSL-Hostreserve. Python
  3.10-3.13, Linux x86_64/ARM64-Wheel-Pfad; echte Pakettests noch offen.
- PyArrow/NumPy/pandas nur Wheels; HF-Hub-Bibliothek als Abhaengigkeit,
  separater HF_Hub-Menuepfad bleibt planned. Bestehende ensurepip-Reparatur genutzt.

## AudioSeal GitHub-CPU-Paket, 2026-10-16

- AudioSeal 0.2.0, Pin e63a8a0e5cdf7bb797159c92ba15961557fe9bd2; private
  Python-venv, Torch 2.10.0+cpu, keine Dev-/CUDA-/Modell-/Audioaktionen.
- >=6 GiB gesamt, >=4 GiB verfuegbar, 8 GiB Disk/WSL-Hostreserve. Linux x86_64,
  Python 3.10-3.13. Wiederverwendete sichere ensurepip-Reparatur nur bei Installation.
- Checkpoint-Loader nutzt weights_only=False; nur vertrauenswuerdige Gewichte,
  kein universeller Deepfake-Detektor. Nur Offline-Tests; kein echter Pakettest.

## DeepFilterNet GitHub-Rust-CPU, 2026-10-16

- v0.5.6, Commit 978576aa8400552a4ce9730838c635aa30db5e61; native deep-filter-CLI
  aus libDF, kein Docker/Python/PyTorch. Cargo.lock, ein Buildjob.
- Mitgeliefertes DFN3-ONNX-Modell aus GitHub eingebettet, kein separater
  Modell-/Audio-/Mikrofon-/Dienststart. Kein Deepfake-/Authentizitaetsdetektor.
- >=6 GiB Gesamt-RAM, >=4 GiB verfuegbar, 8 GiB Disk/WSL-Hostreserve;
  Toolchain separat, echte Linux-/ARM-Buildtests offen. Nur Offline-Mocks.

## Qwen Code RAM-Budget, 2026-10-16

- Alte 8192-MB-Pruefung las MemTotal, nicht freien RAM. Neue lokale
  Planungsregel: >=7168 MiB gesamt und >=5120 MiB MemAvailable, vor Downloads.
- Upstream-Build behielt 4096-MiB-Node-Heap; pnpm child-concurrency=1,
  network-concurrency=4. Kein belegtes Minimum/Erfolgsgarantie, keine WSL-Aenderung.

## Qwen Desktop manuelle Uebergabe, 2026-10-16

- Install/Update warten interaktiv nach Browserangebot auf Enter und
  [(j)a/(N)ein]-Abschlussbestaetigung. Keine automatische Windows-Installation.
- Exit 0 bestaetigt manuell, 3 verschoben/EOF, 1 Browserfehler. Tools-Menue
  behandelt 3 als skipped, 0 ohne automatisch verifizierten Installiert-Haken.
- --open-download bleibt reine Browser-Uebergabe ohne Wartephase.

## Agent Framework venv-Reparatur, 2026-10-16

- Import von venv allein erkennt fehlendes ensurepip unter Ubuntu nicht.
- Vor Clone/Build gezielt pythonX.Y-venv fuer paketverwaltetes System-Python
  nach sudo-Freigabe installieren; bestehender APT-Lock-Helper, Opt-out
  AGENT_FRAMEWORK_AUTO_VENV=0. Keine Reparatur von Custom-Python via apt.
- Partial-venv und Quelle bleiben erhalten; --repair vervollstaendigt sie.
- Nur Offline-Mocks testen; keine WSL-/Systeminstallation durch Codex.

## Pyannote Audio GitHub/CPU, 2026-10-16

- Release 4.0.4, Commit 78c0d16a5f558adb1024d112e6857b3204b450b3,
  eigener GitHub-Source-Installer ohne Docker; source-ready ist kein Modelltest.
- Optional CPU-Pakete nur PYANNOTE_AUDIO_INSTALL_RUNTIME=1 und
  INSTALL_HEAVY_TOOLS=1, private venv, Torch/Audio 2.10.0, TorchCodec 0.10.0.
- Keine Imports von Pipeline/torch bei Checks, Modelle/Token separat.
  Telemetrie-Flags bei spaeterer Nutzung explizit setzen. Keine Echtheitsbewertung.
- Keine WSL-/Medienzugriffe durch Codex. Deaktivierung erhaelt alle Daten.

## FILM GitHub-Quellen, 2026-10-16

- google-research/frame-interpolation auf Pin
  69f8708f08e62c2edf46a27616a4bfcf083e2076, Source-only ohne Docker.
- Upstream archiviert; TensorFlow 2.6.2/Legacy-CUDA nicht ungeprueft auf
  Ubuntu 24.04 oder RTX 5080 installieren. Quellmarker ist kein Inferenztest.
- Original-CLI kann vorhandene Ausgabeframes entfernen: eigene neue
  Jobordner und Originalkopien fuer spaetere manuelle Tests voraussetzen.
- Keine Live-WSL-/TensorFlow-/Modell-/Videoaktionen. Uninstall nur Marker.

## SUPIR GitHub-Quellen, 2026-10-16

- Fanghua-Yu/SUPIR master, Commit bda91af2000042f8bedfec8897d92917e67c1d88,
  eigener Source-only-Installer ohne Docker. Marker ist keine GPU-Laufzeit.
- FastAPI 0.95.1 verlangt Pydantic <2, Gradio 4.16.0 >=2; automatische
  Legacy-Pakete nicht freigeben. Keine Python-3.8-/Conda-/Modellinstallation.
- SUPIR Software License Agreement mit kommerziellen Einschraenkungen
  klar dokumentieren, nicht pauschal als MIT/Apache behandeln.
- Offline-Syntax/Pin-Checks, Lock/Logs, Deaktivierung ohne Datenloeschung.
  Keine Eingriffe in WSL oder laufende Dienste durch Codex.

## ComfyUI-GGUF GitHub-Node, 2026-10-16

- Eigener Source-Installer fuer city96/ComfyUI-GGUF, Pin
  6ea2651e7df66d7585f6ffee804b20e92fb38b8a, ohne Docker/Modelle.
- Vorhandenes ComfyUI voraussetzen; gguf in dessen venv, bestehende
  Paketversionen per Constraints erhalten. Node-Link erst nach Paketpruefung.
- Source-only ohne Integration moeglich; Uninstall entfernt nur eigenen
  Node-Link/Marker, nicht Quelle/Pakete/Modelle. Keine WSL-/ComfyUI-Liveeingriffe.

## Wan21 GitHub-Quellinstallation, 2026-10-16

- Wan-Video/Wan2.1 auf Commit 9737cba9c1c3c4d04b33fcad41c111989865d315
  ohne Docker; source-ready prueft nur saubere Quellen/Syntax.
- WAN21_INSTALL_RUNTIME=1 und INSTALL_HEAVY_TOOLS=1 fuer experimentelle
  private CUDA-Pakete, nach GPU/nvcc/Ressourcenchecks. Keine Gewichte/Starts.
- Kein SDPA-Fallback versprechen: Upstream-Modell ruft flash_attention direkt.
  Doctor nur Metadaten, echter CUDA-/RTX-5080-Renderpfad weiter ungetestet.
- Keine WSL-Eingriffe durch Codex; Uninstall erhaelt Quelle/venv/Modelle.

## Cline GitHub-VSIX, 2026-10-16

- Eigener optionaler Paketinstaller statt Hybrid-Guard: offizielles VSIX
  v4.1.25 mit festem Release-Hash, kein Docker oder schwerer Source-Build.
- release-ready/package_ready pruefen nur die Paketbereitstellung; niemals
  als Nachweis einer installierten Windows-/WSL-Extension ausgeben.
- Manuelle VSIX-Installation im gewuenschten Editorprofil dokumentiert.
  Kein code-Aufruf, Login, Agent, API, Modell oder WSL-Eingriff durch Codex.

## Karaoke Formats Installation, 2026-10-16

- Eigener SRT/LRC-Konverter erhielt einen privaten Installer fuer einen Starter
  aus dem vorhandenen GitHub-Checkout; keine separate Kopie, kein Docker/pip.
- SHA-256-Pruefung erkennt geaenderte/fehlende Quelle; Tool-Update erneuert
  den Starter. Lock, private Logs, Disk-Reserve und Offline-Doctor integriert.
- Keine Medienverarbeitung/Downloads/WSL-Eingriffe beim Entwickeln. Uninstall
  entfernt nur verwalteten Starter und Registrierung, keine Medien/Quellen.

## Microsoft Agent Framework GitHub-Source, 2026-10-16

- Planungs-Platzhalter durch optionalen Python-Core-Installer ersetzt:
  1.22.0, Commit 17b1a14bd5b4c774c18d5b827b4f5b97bed3cbee,
  python/packages/core aus GitHub, private venv, PyPI-Abhaengigkeiten.
- Ressourcenpruefung vor Downloads, Operations-Lock, private Logs,
  Offline-Status/Doctor und datenerhaltende Deaktivierung.
- Kein Docker, Modell-/Providerstart, .NET, AutoGen-Migration oder WSL-Eingriff.
  Nur Offline-/Mocktests; realer Source-Build und Ollama-Integration noch offen.

## Qwen Code Runtime-Bootstrap, 2026-10-16

- Abbruch wegen fehlendem Node durch private Bereitstellung bei ausdruecklicher
  Installation/Repair ersetzen. Node 22.22+/npm >=10 via vorhandenem GitHub-nvm.
- Corepack 0.34.0 privat per npm, pnpm 11.24.0 samt Upstream-SHA-512 im
  tools/qwen_code/runtime/corepack-cache; keine globalen Shims/Profile aendern.
- Vor Downloads Ressourcen/Lock/Log, Pruefungen mit Corepack-Netzwerk aus.
  QWEN_CODE_AUTO_RUNTIME=0 sperrt Bootstrap. Kein echter Download, WSL-Zugriff,
  Login, Agentenstart oder Modellabruf durch Codex. Revision:
  2026-10-16-private-node-corepack-bootstrap.

## Automaton Runtime-Bootstrap, 2026-10-16

- Automaton fehlte Node: Node/npm ueber vorhandenen GitHub-nvm-Helfer privat
  unter tools/automaton/runtime/nvm bereitstellen. pnpm@10.28.1 separat per
  npm --prefix unter runtime/pnpm, ohne globales Update/Lifecycle-Skripte.
- Nur Installation/Repair nach Ressourcen/Lock/Log, opt-out
  AUTOMATON_AUTO_RUNTIME=0; Status/Doctor ohne Downloads, kein Agentenstart.
- System-Node, ~/.nvm, Shellprofile, Wallets und WSL durch Codex unveraendert.
  Revision 2026-10-16-private-node-pnpm-bootstrap. Kein echter Runtime-Download.

## FreeLLMAPI privater Node-Bootstrap, 2026-10-16

- Neuer Source-Installer erreicht, aber Node fehlte: automatischen Bootstrap
  nur in expliziter Installation/Repair ergaenzt. Runtime-Revision:
  2026-10-16-private-node-bootstrap; Source-Revision bleibt erkennbar.
- Vorhandenen node_tool_common-Helfer nutzen, private NVM_DIR unter
  tools/freellmapi/runtime/nvm, strenge FreeLLMAPI-Node/npm-Kompatibilitaet.
- nvm v0.40.8 GitHub; Node-22-Binary/npm offiziell, kein System-Node-Austausch.
  Laufzeit bei spaeterem Start aktivieren, nicht erneut installieren.
- FREELLMAPI_AUTO_NODE=0 verhindert Bootstrap. Kein echter Download/Build,
  WSL-Zugriff oder Service-Start durch Codex; Tests verwenden Stubs.

## Qwen Code / alte FreeLLMAPI-Meldung, 2026-10-16

- GitHub-main enthielt bei erneuter Onlinepruefung noch den alten FreeLLMAPI-
  Docker-Helfer. Lokale Bearbeitung ist nicht Veroeffentlichung/Verteilung.
  Neuer Helfer meldet Revision 2026-10-16-github-source-no-docker.
- Qwen_Code eigener optionaler Source-Installer v0.25.1 am Commit
  c1a8218f38203e272e6e965778ed6a2795cfeed7; kein Hybrid-Platzhalter mehr.
- pnpm 11.24.0/Corepack, Node 22.x, CLI-Build/Bundle ohne Docker-/Sandboxbuild,
  Login/Agent/Modelldownload. 8 GiB RAM/10 GiB Disk Planungsreserve.
- Aenderungen nur im Windows-Repo; keine WSL-/Runtime-Eingriffe, kein Push.

## Automaton Source, 2026-10-16

- Optionaler GitHub-Source-Build am Commit d8f816881fd24b6f5e3d616e59edec387a447667,
  Node 22.x/pnpm 10.28.1, ohne Docker. Kein Runtime-/Wallet-/Provisionierungsstart.
- Privater User-Workspace, Buildmarker, Lock, Log und Ressourcenchecks;
  Rebuild statt blindem main-Update, Code bei Deaktivierung erhalten.
- Offline-review.py bleibt separat und erlaubt keine Ausfuehrung.
- Keine produktiven Wallets, WSL-Eingriffe, globalen CLI- oder Dienstinstallationen.

## FreeLLMAPI Source, 2026-10-16

- Installer baut GitHub v0.14.2 / 57c0669233bbe0c70a0f9f9927613192be948773
  ohne Docker; npm-Abhaengigkeiten aus Upstream-Lockfile. Keine Engine-/Node-Installation.
- Build und Start getrennt: FREELLMAPI_ENABLE_NETWORK=1 nur vor nativem
  Vordergrundstart, HOST 127.0.0.1 erzwungen, native-data separat von altem data/.
- Private ENV nicht als Shell laden, keine Keys erzeugen/rotieren/importieren.
  Port/Lock/Commit/Origin/dirty-Source pruefen, kein automatisches Kill/Reset.
- Nur Offline-Mocktests, kein Live-Build/Routerstart oder WSL-Eingriff.

## Qwen Desktop / Modellpfad, 2026-10-15

- Qwen_Desktop ist Qwen Code Desktop, nicht Qwen Chat/Studio oder QwenWork.
  Offiziellen desktop-latest-Einstieg und desktop-v0.25.2-x64-Asset verifiziert.
- Eigener planned/manual-windows-Menueeintrag, optionale Profilreferenz,
  Anleitung docs/tools/qwen-desktop-windows.md. PowerShell prueft nur
  lokalen Installer-Hash/Authenticode, installiert/startet nichts.
- Unterbrochenen Hybrid-Katalog mit HYBRID_MODELS_AND_WAN.md vervollstaendigt:
  sechs Modellfamilien, sieben geplante Tools; keine geaenderten Modelldefaults.
- Keine Downloader, keine Keys, keine WSL-/Docker-/Service-/Treiber-Aenderung,
  keine Publikation. Provider-/Desktop-Livetests fehlen noch.

## Defensiver Audio-Review, 2026-10-14

- Pyannote_Audio, DeepFilterNet, AudioSeal neu planned, keine Runtime.
- Demucs/UVR5/Audacity/RVC nicht dupliziert, Quellen/Doku ergaenzt.
- Exakte Signalkomponente fuer Subtraktion erforderlich: Hintergrund abziehen
  laesst Stimme uebrig, Prompt/neu erzeugte Stimme ist keine exakte Referenz.
- Keine allgemeine 8-kHz-/Tiefpass-/RVC-Echtheitsreparatur; kein Wasserzeichen-
  entfernen, kein unkritisches Fake-/Echturteil. Originale und Arbeitskopien trennen.
- Python/OpenClaw/n8n nur Workflowvertrag, keine Installation oder WSL-Aenderung.

## Social-Avatar-Stack, 2026-10-14

- CogVideoX/LTX_Video/SD_Next/Pinokio/Windmill/TGI und Fal_Client/Veo_API
  planned; gemeinsame nicht-installierende Guards. Keine WSL-/Runtime-Aenderung.
- Vorhandenes AI_Influencer-Profil erweitert; kein Doppelprofil.
- Veo/fal sind externe Dienste, SDK != lokales Modell. Windmill nicht pauschal
  MIT/Apache, TGI Maintenance Mode, Pinokio keine Container-Sandbox.
- Social-Workflow und JSON-Vorlage sind Entwuerfe, Limits nicht durchgesetzt,
  Cloud/Uploads/Publikation deaktiviert. AnimateDiff-Legacy-Registry-Luecke bleibt TODO.

## Hugging-Face-Videodaten, 2026-10-14

- HF_Datasets, HF_Hub, Video2Dataset als planned, keine automatische Installation.
- Vorhandenes Dataset_Curator-Profil erweitert; kein neues Doppelprofil.
- FineVideo/VIDGEN-1M/Panda-70M/MiraData/VALID mit Primaerquellen und Grenzen
  in media_studio/VIDEO_TRAINING_DATASETS.md. VALID nur historische Karte verifiziert.
- Streaming ist kein hartes Byte-Limit; FineVideo ist nicht automatisch ein
  universeller T2V-Trainingsinput. Panda-Lizenz nichtkommerziell/Forschung.
- Beispiel-Freigabeprotokoll ist inaktiv. Keine Dataset-/Modelldownloads,
  keine Trainingsjobs, keine WSL-Eingriffe oder GitHub-Publikation.

## Audio-/Video-Erweiterung, 2026-10-14

- 20 planned-Kandidaten mit gemeinsamem nicht-installierendem Guard; Tool-Menue/Registry synchron ergaenzt.
- Audio_Postproduction_Local_First bleibt planned. Bestehende TTS-/ASR-/FFmpeg-Tools wiederverwenden.
- Eigene Karaoke_Formats-CLI konvertiert nur Basis-SRT/LRC offline; kein Alignment,
  kein ASR, keine Uebersetzung. Export nur mit --apply in neue Datei ausserhalb Git.
- Produktions-/Karaoke-/MIDI-Leitfaeden korrigieren Lizenz-, GPU- und Timing-Versprechen.
- Keine WSL-Aenderung, keine Installation, keine Gewichte, keine Publikation.

Diese Datei dient als dauerhafte Projekt-Erinnerung fuer spaetere Chats und Folgearbeiten am Setup.

## Agentic Coding, 2026-10-14

- [Einsteiger-Leitfaden](AGENTIC_CODING_GUIDE.md), Aufgabenvorlagen und planned-Profil ergaenzt.
- Vorhandene Coding-Tools dokumentiert, nicht neu installiert. Microsoft Agent Framework nur als Kandidat registriert; AutoGen-Upstream Maintenance Mode, keine automatische Migration.
- Allgemeines Automatenprinzip nicht mit Conway Automaton gleichsetzen. Automaton-Runtime und Wallet-Funktionen bleiben gesperrt.
- Keine WSL-/Runtime-Aenderungen; Queue-Locks, harte Limits und Client-Tests bleiben Voraussetzung fuer autonome Ausfuehrung.

## Automaton, 2026-10-14

- Conway-Research/automaton als planned/high-risk registriert; nur Offline-Review-Prototyp.
- Wallet-Datei upstream nicht mit verschluesseltem Tresor verwechseln; keine Zenbot-Seeds importieren.
- Install/Run/Update/Uninstall gesperrt; bestehende Wallets/WSL bleiben unangetastet.
- Details und offene Freigabekriterien: [Automaton](tools/automaton.md).

## Stand 2026-05-11

## Stand 2026-05-16

### Aider / Coding-Agent

- Letzter Installationsfehler: `rm: cannot remove '/opt/aider': Permission denied`.
- Ursache: Der gemeinsame Scaffold-Installer hatte `/opt/aider` mit `sudo` vorbereitet, loeschte alte Clone-Reste beim Neuaufbau aber ohne `sudo`.
- Fix: `scripts/tools/helpers/scaffold_tool_common.sh` nutzt jetzt eine pfadgeschuetzte Aufraeumfunktion fuer `/opt/*` und User-Home-Pfade, bevor ein Git-Clone neu erstellt wird.
- Nachfolgefehler: `fatal: could not create work tree dir '/opt/aider': Permission denied`.
- Ursache: Nach dem sicheren Loeschen wurde direkt nach `/opt/aider` geklont, obwohl der normale User nicht in `/opt` schreiben darf.
- Fix-Erweiterung: Die Aufraeumfunktion erstellt das Zielverzeichnis danach mit `sudo mkdir -p` und setzt Besitzrechte auf den aktuellen User, bevor `git clone` in das leere Verzeichnis schreibt.
- Wichtig: Der Fix ist bewusst zentral, damit auch andere Scaffold-Tools von alten Root-Resten sauber repariert werden koennen.
- Neue Doku dazu: `docs/AIDER_INTEGRATION_GUIDE.md`.

### TODO: Aider funktional nachruesten

- `scripts/aider/run_aider_task.sh` erstellen.
- Allowlist fuer erlaubte Repositories und optionalen Dry-Run-Patchmodus ergaenzen.
- OpenClaw-Tooldefinition fuer Repo-Analyse, Patch-Vorschlag und Testlauf ergaenzen.
- Nach Aider-Aenderungen automatisch `git diff`, `scripts/validate_config.sh` und passende Tests anbieten.

### OpenCode / Coding-Agent-Scaffold

- Letzter Installationsfehler: `rm: cannot remove '/opt/opencode': Permission denied`.
- Ursache ist sehr wahrscheinlich eine alte Helper-Version oder eine andere Setup-Kopie, weil OpenCode den gemeinsamen Scaffold-Helper nutzt.
- Aktueller Fix: Der Scaffold-Helper nutzt eine pfadgeschuetzte `sudo rm -rf`-Routine fuer alte `/opt/<tool>`-Reste.
- Im neuen Installationslog muss `Scaffold-Helper: sichere /opt-Aufraeumroutine aktiv.` erscheinen. Fehlt diese Zeile, wurde nicht der aktuelle Setup-Stand gestartet.
- Neue Doku dazu: `docs/OPENCODE_INTEGRATION_GUIDE.md`.

### TODO: OpenCode funktional nachruesten

- `scripts/opencode/run_opencode_task.sh` erstellen.
- OpenCode-Startkommando je Upstream-Stand automatisch erkennen.
- OpenClaw-Tooldefinition fuer OpenCode als optionalen Coding-Agent ergaenzen.
- Doctor-Check fuer `/opt/opencode`, Git-Ref und Modellkonfiguration ergaenzen.

### GitHub CLI / gh

- Letzter Installationsfehler: `rm: cannot remove '/opt/github_cli': Permission denied`.
- GitHub CLI nutzt ebenfalls den gemeinsamen Scaffold-Helper und baut aus `https://github.com/cli/cli.git` nach `/opt/github_cli`.
- Der aktuelle Helper entfernt alte `/opt/<tool>`-Reste mit einer pfadgeschuetzten `sudo rm -rf`-Routine.
- Im neuen Installationslog muss `Scaffold-Helper: sichere /opt-Aufraeumroutine aktiv.` erscheinen. Fehlt diese Zeile, wurde noch eine alte Setup-Kopie gestartet.
- Neue Doku dazu: `docs/GITHUB_CLI_INTEGRATION_GUIDE.md`.

### TODO: GitHub CLI funktional nachruesten

- `scripts/github_cli/gh_safe.sh` als Allowlist-Wrapper erstellen.
- Read-only Default fuer `gh repo view`, `gh issue list`, `gh pr list`, `gh run list`.
- Schreibende Aktionen nur nach expliziter Freigabe.
- Doctor-Check fuer `gh --version` und optional `gh auth status`.

### Podman / Container Runtime

- Installationslog zeigt aktivierte systemd-Einheiten: `podman-auto-update.service`, `podman-auto-update.timer`, `podman-clean-transient.service`, `podman-restart.service`, `podman.service`, `podman.socket`.
- Das ist kein Fehler, aber eine wichtige Autostart-/Update-Nebenwirkung.
- `podman.socket` stellt eine lokale API bereit und darf nicht unbewusst extern freigegeben werden.
- `podman-auto-update.timer` kann Container aktualisieren, wenn passende Labels/Units genutzt werden. Fuer reproduzierbare Tests sollte Auto-Update optional und bewusst bleiben.
- Neue Doku dazu: `docs/PODMAN_CONTAINER_RUNTIME_GUIDE.md`.

### TODO: Podman funktional nachruesten

- Doctor-Check fuer `podman --version`, `podman info`, `podman.socket` und `podman-auto-update.timer`.
- Setup-Option fuer Auto-Update aktivieren/deaktivieren ergaenzen.
- Podman als Runtime fuer `Code_Sandbox` und spaetere OpenClaw-Toolausfuehrung dokumentieren.
- Security-Hinweis: Socket nur lokal, rootless bevorzugen, keine `--privileged`-Defaults.

### Clawbake

- Alter Fehler: `Fehler: Clawbake Repository nicht erreichbar: https://github.com/openclaw/clawbake.git`.
- Neue Quelle laut Nutzer und GitHub-Pruefung: `https://github.com/NeurometricAI/clawbake`.
- Wichtige Korrektur: Die neue Quelle ist kein pnpm-Projekt, sondern ein Go/Kubernetes/Helm/OpenClaw-Operator-Projekt.
- Installer wurde auf die neue Quelle, Remote-Backup bei Quellenwechsel, Go/Make-Pruefung und `make build` umgestellt.
- Nachfolgefehler: `fatal: could not create work tree dir '/opt/clawbake': Permission denied`.
- Ursache: Nach `sudo rm -rf /opt/clawbake` wurde direkt nach `/opt/clawbake` geklont, obwohl der normale User nicht in `/opt` schreiben darf.
- Fix: Der Installer erzeugt nun das Zielverzeichnis mit `sudo mkdir`, setzt Besitzrechte und klont in das leere Zielverzeichnis.
- `CLAWBAKE_SKIP_BUILD=true` kann genutzt werden, um nur das Repository vorzubereiten.
- Neue Doku dazu: `docs/CLAWBAKE_INTEGRATION_GUIDE.md`.

### TODO: Clawbake funktional nachruesten

- Clawbake als `advanced`/`experimental` markieren.
- Doctor-Check fuer Git-Remote, Go-Version, Makefile und Helm/Kubernetes-Abhaengigkeiten.
- Helm-/K3s-Deployment als getrennte Advanced-Option dokumentieren.
- Secrets/OIDC/Gateway-Konfiguration nur im User-Workspace ablegen.

### Aktueller Clawbake-Befund aus Installationslogs

- Wenn `go: downloading github.com/jackc/pgservicefile ...` erscheint, ist das kein Installationsfehler, sondern ein normaler Go-Modul-Download aus dem PostgreSQL-Umfeld.
- Der Loghinweis `Clawbake braucht für echten Betrieb Kubernetes, PostgreSQL/OIDC-Secrets und Helm-/Values-Konfiguration` bedeutet: Quelle/Build sind vorbereitet, aber der produktive Kubernetes-Deployment-Pfad ist noch offen.
- Fuer die Setup-Statusanzeige sollte Clawbake spaeter drei Zustaende bekommen: `prepared` fuer Repo vorhanden, `built` fuer lokales Build-Artefakt, `deployed` fuer laufenden Kubernetes-/Helm-Betrieb.

### Clawbake und MySQL/MariaDB

- Der aktuelle Upstream ist PostgreSQL-only: `db/sqlc.yaml` setzt `engine: postgresql`, der Go-Code nutzt `pgx/v5`, die Migration nutzt `database/pgx/v5`, und das Helm-Chart erzeugt PostgreSQL-URLs.
- MySQL/MariaDB waere fuer Clawbake kein einfacher Adapter-Schalter, sondern ein echter Port mit neuen Migrationen, sqlc-Generator, Treiber, Tests und Helm-Templates.
- Der Installer akzeptiert deshalb nur `CLAWBAKE_DATABASE_ENGINE=postgresql` und bricht bei `mysql`, `mariadb` oder `mysql2` bewusst ab.

### Authentik / Authelia / OIDC

- OIDC ist kein einzelnes Tool, sondern ein Login-Standard auf Basis von OAuth2.
- Authentik und Authelia wurden als optionale Security-/SSO-Bausteine aufgenommen.
- Authentik ist ein komfortabler Identity Provider mit Web-UI und eignet sich eher fuer VPS, K3s und Homelab-Setups mit mehreren Diensten.
- Authelia ist eine schlanke Auth-/MFA-Schicht vor Webdiensten und eignet sich gut fuer MiniPC, Homelab und Reverse-Proxy-Schutz.
- Installationsskripte erzeugen nur lokale Vorlagen unter `~/.openclaw_ultimate_user_data/auth/...` und starten bewusst keinen produktiven Dienst.
- Authentik nutzt im Setup lokale Port-Mappings `9010`/`9444`, damit kein Konflikt mit MinIO `9000` entsteht. Authelia nutzt `9091`.
- Neue Doku dazu: `docs/AUTH_OIDC_HELM_SECRETS_GUIDE.md`.

### Installationsueberwachung / Sofortdiagnose

- Der manuelle Nach-Schritt-Dialog der erweiterten Installationsueberwachung bietet jetzt neben `[N]` und `[Z]` auch:
- `[L]` zeigt direkt das aktuelle bzw. letzte Installationslog.
- `[D]` startet sofort `scripts/tool_log_diagnostics.sh --log <log> --no-email`.
- `[E]` startet sofort `scripts/tool_log_diagnostics.sh --log <log> --email-now ai-chat-to-markdown@web.de`.
- `tool_log_diagnostics.sh` unterstuetzt dafuer neu `--email-now` bzw. `--send-email`, damit nach expliziter Auswahl keine zweite Rueckfrage mehr noetig ist.
- Voraussetzung fuer E-Mail: `Mail_Utils_MSMTP` installieren und lokal `~/.msmtprc` sowie `~/.openclaw_ultimate_user_data/mail/mail_settings.env` konfigurieren. Keine SMTP-Zugangsdaten ins Repo schreiben.

### LangGraph / Bibliothekstools

- LangGraph ist kein eigenstaendiger Webdienst und kein Desktopprogramm, sondern eine Python-Bibliothek fuer zustandsbehaftete Agenten- und Workflow-Graphen.
- Eine erfolgreiche Installation unter `/opt/langgraph/venv` bedeutet nur, dass LangGraph importierbar ist. Es funktioniert dadurch noch nicht automatisch direkt in OpenClaw.
- OpenClaw soll LangGraph spaeter ueber ein klares Tool-/Worker-Skript nutzen, z. B. `scripts/langgraph/run_graph_tool.py`.
- Geplanter Ablauf: OpenClaw Task -> LangGraph Python-Worker -> Ollama/LiteLLM/Qdrant/Langfuse -> Markdown/JSON-Ergebnis unter `~/.openclaw_ultimate_user_data/langgraph/runs`.
- Erste sinnvolle LangGraph-Use-Cases: Repo-Review-Graph, Install-Log-Diagnose-Graph, RAG-Antwort-Graph, Profil-Planungs-Graph, defensiver Security-Audit-Graph.
- Fuer alle Bibliothekstools gilt: Installation allein reicht nicht. Sie brauchen Smoke-Test, Beispielskript, Ergebnisformat, Doctor-Check und eine klare Integrationsbeschreibung.
- Neue Doku dazu:
  - `docs/LANGGRAPH_INTEGRATION_GUIDE.md`
  - `docs/TOOL_USAGE_AND_INTEGRATION_GUIDE.md`

### TODO: LangGraph funktional nachruesten

- `scripts/langgraph/run_graph_tool.py` erstellen.
- `examples/langgraph/repo_review_graph.py` erstellen.
- OpenClaw-Tooldefinition fuer LangGraph-Aufrufe ergaenzen.
- LangGraph-Doctor-Check in `scripts/doctor.sh` aufnehmen.
- Optional Langfuse/OpenLIT-Tracing anbinden.
- Safety: Default `read-only`, `dry-run`, keine Secrets im Graph-State.

### CrewAI / Multi-Agent-Teams

- CrewAI wurde erfolgreich als Python-Agentenframework unter `/opt/crewai/venv` installiert, laut Log mit `crewai-1.14.4`.
- CrewAI ist wie LangGraph kein eigenstaendiger Webdienst, sondern wird ueber Python-Skripte, Teams und Rollen-Workflows genutzt.
- Geeignete Integrationsform: OpenClaw Task -> `scripts/crewai/run_crew_task.py` -> CrewAI Team -> Ollama/LiteLLM/Qdrant -> Markdown/JSON-Report.
- Gute erste Teams: Repo-Maintainer-Team, Install-Log-Diagnose-Team, Profil-Builder-Team, defensives Security-Review-Team.
- Neue Doku dazu: `docs/CREWAI_INTEGRATION_GUIDE.md`.

### TODO: CrewAI funktional nachruesten

- `scripts/crewai/run_crew_task.py` erstellen.
- `examples/crewai/repo_maintainer_team.py` erstellen.
- CrewAI-Smoke-Test in `scripts/doctor.sh` ergaenzen.
- OpenClaw-Tooldefinition fuer CrewAI-Aufrufe ergaenzen.
- Ausgabeordner `~/.openclaw_ultimate_user_data/crewai/runs` standardisieren.
- Optional Langfuse/OpenLIT-Tracing anbinden.
- Safety: Default `read-only`, `dry-run`, keine autonomen Shell-/Browseraktionen.

### AutoGen / Multi-Agent-Chats

- AutoGen wurde laut Installationslog erfolgreich unter `/opt/autogen/venv` installiert, u. a. mit `pyautogen-0.10.0`, `autogen-core-0.7.5` und `autogen-agentchat-0.7.5`.
- AutoGen ist kein Webdienst, sondern ein Python-Framework fuer Multi-Agent-Chats, Reviewer-Agenten, Planner/Worker-Muster und User-Proxy-Freigaben.
- Geeignete Integrationsform: OpenClaw Task -> `scripts/autogen/run_autogen_task.py` -> Planner/Worker/Reviewer/User-Proxy -> Ollama/LiteLLM/Qdrant -> Markdown/JSON-Report.
- Gute erste Szenarien: Repo-Review-Chat, Installationsfehler-Triage, Security-Findings-Review, Profil-Design-Review.
- Neue Doku dazu: `docs/AUTOGEN_INTEGRATION_GUIDE.md`.

### TODO: AutoGen funktional nachruesten

- `scripts/autogen/run_autogen_task.py` erstellen.
- `examples/autogen/repo_review_chat.py` erstellen.
- AutoGen-Smoke-Test in `scripts/doctor.sh` ergaenzen.
- OpenClaw-Tooldefinition fuer AutoGen-Aufrufe ergaenzen.
- Ausgabeordner `~/.openclaw_ultimate_user_data/autogen/runs` standardisieren.
- User-Proxy-/Approval-Konzept fuer riskante Aktionen dokumentieren.
- Safety: Default `read-only`, `dry-run`, keine autonomen Shell-/Browseraktionen ohne Freigabe.

### Playwright / Browser Automation

- Playwright ist kein Webdienst, sondern ein Browser-Automation-Framework.
- Eine vorhandene Python-Umgebung unter `/opt/playwright/venv` reicht nur fuer den Python-Import; fuer echte Browserlaeufe muessen Browser-Binaries wie Chromium installiert sein.
- Pruefbefehle: `source /opt/playwright/venv/bin/activate`, `python -c "import playwright"`, `python -m playwright install chromium`.
- Geeignete Integrationsform: OpenClaw Task -> `scripts/playwright/browser_worker.py` -> headless Chromium -> Screenshot/HTML/JSON unter `~/.openclaw_ultimate_user_data/playwright/`.
- Playwright kann fuer OpenClaw, Browser_Automation_Agent, Huginn, n8n, LangGraph, CrewAI und AutoGen als sicher begrenzter Browser-Worker dienen.
- Neue Doku dazu: `docs/PLAYWRIGHT_INTEGRATION_GUIDE.md`.

### TODO: Playwright funktional nachruesten

- `scripts/playwright/browser_worker.py` erstellen.
- `scripts/playwright/screenshot_url.py` erstellen.
- Allowlist unter `~/.openclaw_ultimate_user_data/playwright/allowed_targets.txt` einfuehren.
- Doctor-Check fuer Playwright-Import und Chromium-Binary ergaenzen.
- OpenClaw-Tooldefinition fuer Browser-Screenshot und HTML-Extraktion ergaenzen.
- Safety: nur erlaubte Ziele, Rate-Limit, keine Captcha-Umgehung, keine Cookies/Screenshots ins Repo.

### ChromaDB / lokaler Vektorstore

- ChromaDB wurde laut Installationslog erfolgreich unter `/opt/chromadb/venv` installiert, u. a. mit `chromadb-1.5.9`.
- ChromaDB ist kein klassisches Desktopprogramm. Es kann als Python-Bibliothek direkt in RAG-/Memory-Skripten oder optional als lokaler HTTP-Server genutzt werden.
- ChromaDB wird nicht automatisch von Ollama oder OpenClaw genutzt. Es braucht eine Pipeline: Import/Chunking -> Embeddings -> ChromaDB -> Retrieval -> Kontext fuer Ollama/OpenClaw.
- Empfohlener Datenpfad: `~/.openclaw_ultimate_user_data/chromadb/`.
- Geeignete Integrationsform: OpenClaw Task -> `scripts/chromadb/query_memory.py` -> ChromaDB PersistentClient -> relevante Dokumente/Erinnerungen -> OpenClaw-Kontext.
- ChromaDB passt zu OpenClaw, Memory_Import_Export, Personal_Knowledge_Memory, Document_Intelligence, LangGraph, CrewAI und AutoGen.
- Neue Doku dazu: `docs/CHROMADB_INTEGRATION_GUIDE.md`.

### TODO: ChromaDB funktional nachruesten

- `scripts/chromadb/import_markdown_memory.py` erstellen.
- `scripts/chromadb/query_memory.py` erstellen.
- Embedding-Modell und Standardpipeline fuer Ollama/OpenClaw festlegen.
- Doctor-Check fuer ChromaDB-Import und optionalen Serverport ergaenzen.
- OpenClaw-Tooldefinition fuer ChromaDB-RAG-Kontext ergaenzen.
- Memory_Import_Export-Profil mit ChromaDB-Beispielpipeline verbinden.
- Safety: keine privaten ChromaDB-Datenbanken oder Exporte ins Repo.

### Code_Sandbox

- Diagnosemeldung `Keine Treffer fuer das Diagnosemuster gefunden` ist bei erfolgreicher Installation kein Fehler, sondern bedeutet nur, dass der Logfilter keine bekannten Problemzeilen gefunden hat.
- Logstatus: `Starte Installation von Code_Sandbox...` gefolgt von `Code_Sandbox wurde erfolgreich installiert.`
- Code_Sandbox ist aktuell ein vorbereitetes Sandbox-Modul unter `/opt/code_sandbox`, kein vollstaendiger Runner und kein Webdienst.
- Die Installation erzeugt `.env.template`, `README.md` und einen Platzhalter-`run.sh`.
- Ziel: OpenClaw, Programmierer-, LLM-Builder- und Agentenprofile sollen spaeter riskante Codeausfuehrung ueber Docker/Podman/Devcontainer statt direkt auf dem Host starten.
- Neue Doku dazu: `docs/CODE_SANDBOX_USAGE_GUIDE.md`.

### TODO: Code_Sandbox funktional nachruesten

- `scripts/code_sandbox/run_in_sandbox.sh` erstellen.
- Policy-Datei unter `~/.openclaw_ultimate_user_data/code_sandbox/policy.env` einfuehren.
- Docker-Backend mit `--network none`, `--memory`, `--cpus` und Timeout bauen.
- Optional Podman- und Devcontainer-Backend.
- OpenClaw-Tooldefinition fuer Sandbox-Kommandos ergaenzen.
- Doctor-Check fuer Docker/Podman und Sandbox-Testlauf.
- Safety: keine Secrets, kein Docker-Socket-Mount, kein `--privileged`, keine Host-Pfade ausser explizitem Workspace.

## Als veraltet identifiziert

Diese Punkte gelten im Projektverlauf inzwischen als veraltet, problematisch oder nur noch als Legacy-Verhalten:

### Setup / Update-Pfad

- Der fruehere weiche Setup-Update-Pfad mit `git pull --ff-only` ohne harten Repo-Abgleich war fehleranfaellig, weil alte lokale Repo-Dateien neue Staende blockieren oder teilweise stehen bleiben konnten.
- Fuer das Setup-Repository gilt deshalb der harte Abgleich auf `main` inzwischen als bevorzugter Standard.

### Huginn Upstream / Installer-Meldungen

- Die Formulierung `HUGINN_REPO_REF ueberschreiben` gilt als veraltet; der Wert wird jetzt im Setup ausgewaehlt oder festgelegt.
- Ein Huginn-Lauf ohne vorgeschaltetes Auswahlmenue fuer den Upstream-Stand gilt als veraltet; die Ref-Wahl gehoert jetzt vor den eigentlichen Installationslauf.

### Huginn Konfigurationsablage

- Ein neuer Huginn-Lauf, der sich blind an Huginns alter `.env.example` orientiert, gilt als veraltet.
- Sichere Huginn-Werte gehoeren in den Benutzer-Workspace unter `~/.openclaw_ultimate_user_data/huginn/`.
- Alte Datenbank-Defaults wie `huginn_development`, `root` und leeres Passwort gelten fuer dieses Setup als Legacy und sollen nicht mehr der Standard sein.

### Huginn Datenbankpfade

- Die alten Fallbacks in `config/database.yml` mit `username: root`, Produktionspasswort-Fallback und `reconnect: true` gelten als Legacy.
- Der alte PostgreSQL-Gemstand `pg-1.1.3` gilt unter Ruby 3.2 in diesem Huginn-Upstream als veraltet und inkompatibel.
- Der alte mysql2-Pfad `0.5.3` gilt unter Ruby 3.2 als veraltet.

### Huginn Ruby-/Gem-Altlasten

- Die folgenden Huginn-Teilbereiche gelten in diesem Upstream auf moderner Ruby-Basis als veraltet oder besonders stoeranfaellig:
  - `google-cloud-translate` mit altem `grpc 1.42.0`
  - `mini_racer` / `libv8-node`
  - `ruby-growl`
  - `net-ftp-list`
  - `gmail_xoauth` ohne nachgezogene `net-imap` / `net-smtp` / `net-pop`-Kompatibilitaet
- Das alte Asset-/Startverhalten ohne Production-Asset-Precompile gilt ebenfalls als veraltet.

### Huginn Laufzeitverhalten

- Ein Huginn-Betrieb nur mit Webserver ohne Worker gilt fuer echte Verarbeitung als unvollstaendig und damit als veralteter Betriebsmodus.
- Bei HTML-Extraction im `Website Agent` gilt `value: "text"` in diesem Huginn-Stand als veraltet bzw. unpassend; erwartet werden XPath-Ausdruecke wie `string(.)` oder `normalize-space(.)`.
- Das alte YAML-Ladeverhalten ueber `YAML.load` im Jobs-Pfad gilt fuer den aktuellen Psych-Stack als veraltet.

### Huginn UI-/Workflow-Eigenheiten

- Der Eindruck, dass ein Scenario-Reimport immer einen echten Klon erzeugt, gilt fuer diesen Huginn-Stand als falsch bzw. veraltet.
- Bestehende Scenarios koennen beim Reimport anhand ihrer Export-Identitaet wiedererkannt und aktualisiert werden.

### Huginn

- Der aktuelle Huginn-Installer wurde intensiv fuer Ruby `3.2.x` gehaertet.
- Das Setup erzeugt jetzt auch automatisch einen echten Huginn-`INVITATION_CODE`, wenn die `.env` noch leer ist oder noch auf dem unsicheren Default `try-huginn` steht.
- Der aktuelle Huginn-Invitation-Code laesst sich jederzeit mit `grep '^INVITATION_CODE=' /opt/huginn/.env` im Terminal nachlesen.
- Der erste Huginn-Admin kann bei Bedarf ohne Web-Registrierung direkt per `rails runner` angelegt werden, indem `requires_no_invitation_code!` gesetzt wird.
- Der `dry_runnable.rb`-Pfad wurde fuer Ruby 3.2 angepasst, damit Agenten wieder speicherbar sind.
- Der `jobs_helper.rb`-Pfad wurde fuer den aktuellen Psych/YAML-Stack auf `YAML.unsafe_load` umgestellt, damit die `Jobs`-Seite wieder funktioniert.
- Fuer echte Huginn-Verarbeitung reichen im aktuellen Setup nicht nur der Webserver, sondern zusaetzlich ein Worker-Prozess mit `RAILS_ENV=production bundle exec rails runner bin/threaded.rb`.
- Huginn nutzt in diesem Setup jetzt standardmaessig den Port `3002`, damit kein Konflikt mit OpenClaw auf `3000` und Grafana auf `3001` entsteht.
- Portkonflikte muessen im Setup kuenftig immer mitgedacht werden: upstream-defaults und setup-empfohlene Ports sollten beide benannt werden. Fuer Huginn gilt: upstream oft `3000`, Setup-Empfehlung bewusst `3002`.
- Beim `Website Agent` dieses Huginn-Stands muss HTML-Extraction in `extract` mit XPath-Werten wie `string(.)` oder `normalize-space(.)` arbeiten; `value: "text"` fuehrt hier leicht zu leeren Payload-Feldern trotz erfolgreichem Abruf.
- Scenario-Export und Reimport koennen bestehende Scenarios anhand ihrer internen Export-Identitaet wiedererkennen; ein lokal umbenanntes Scenario kann beim Reimport derselben Exportdatei wieder auf den alten Exportnamen zurueckfallen.
- Der Installer richtet nach erfolgreicher Huginn-Installation nach Moeglichkeit zwei lokale `systemd`-Dienste ein: `huginn-web.service` und `huginn-worker.service`.
- Im Setup-Hauptmenue gibt es jetzt einen zentralen Start-Manager `Installierte Dienste starten`, der bekannte Startziele gesammelt oder gezielt anstossen kann.
- Der Start-Manager erzeugt bei Bedarf ein anpassbares Autostart-Skript unter `~/.openclaw_ultimate_user_data/autostart/start_selected_tools.sh`.
- Dieses Autostart-Skript muss vor dem eigentlichen Start einen Abbruchpfad zurueck ins Setup anbieten, damit Konfigurationsaenderungen vor einem erneuten Start moeglich bleiben.
- Der Installer bevorzugt fuer neue Huginn-`.env` jetzt die sichere Vorlage aus `~/.openclaw_ultimate_user_data/huginn/.env.template` und bereinigt alte DB-Defaults wie `root`/`huginn_development`.
- Die Warnung `MYSQL_OPT_RECONNECT is deprecated` stammt im Huginn-Stand nicht primaer vom MySQL-Server-Update, sondern vom alten `reconnect`-Default in `config/database.yml`; der Installer setzt diesen Default jetzt auf `false`.
- Wenn die sichere Huginn-Vorlage versehentlich auf `DATABASE_ADAPTER=postgresql` steht, laeuft der alte `pg-1.1.3`-Stack unter Ruby 3.2 in `pg_ext.so` aus; der Installer gibt dafuer jetzt einen gezielten Hinweis statt nur allgemein bei `db:create` zu scheitern.
- Der offizielle aktuelle Huginn-Upstream spricht in der Installationsdoku derzeit weiterhin von `master`; unsere Huginn-Auswahl und Doku sollten diesen Namen fuer den Teststand konsistent verwenden statt zwischen `main` und `master` zu mischen.
- `master` ist gegenueber `v2022.08.18` sichtbar moderner bei Ruby, OpenAI-kompatiblen `.env`-Optionen und dem HTTP-Backend-Pfad; MySQL/MariaDB bleibt laut offizieller Installationsdateien aber weiter ein realer Standardpfad.
- Fuer VPS/K3s-Szenarien mit Clawbake ist PostgreSQL bei Huginn strategisch vorzuziehen, weil Clawbake upstream PostgreSQL-only ist. Lokale MiniPC-/WSL2-Huginn-Tests koennen weiterhin mit MySQL/MariaDB sinnvoll sein.
- Sinnvoller Workflow: Huginn-Agents/Scenarios lokal absichern und testen, dann ohne Secrets exportieren und in eine VPS-Huginn-Instanz mit PostgreSQL importieren; bei Bedarf auch umgekehrt von VPS nach lokal zurueckholen.
- Eine einfache funktionierende Testkette wurde erfolgreich bestaetigt:
  - `Manual Event Agent`
  - `Event Formatting Agent`
- Die alten problematischen Huginn-Zweige werden jetzt proaktiv erkannt und bei Bedarf entschärft:

### Sprachpakete

- Das Setup kann jetzt nachinstallierbare Sprachpakete aus `~/.openclaw_ultimate_user_data/language_packs/` laden.
- Sprachpakete werden nach der eingebauten Setup-Sprache als Overlay geladen und koennen vorhandene `TXT_*`-Texte gezielt ueberschreiben.
- Fuer die Verwaltung gibt es jetzt `Optionen -> Sprachpakete verwalten`.
- Das Repo enthaelt mit `language_packs/de_core_ui/` bereits ein erstes deutsches Starter-Paket, das spaeter in ein eigenes Repo ausgelagert werden kann.
- Das separate Repo `Ultimate_KI_Setup-Sprachenpakete` soll kuenftig parallel zum Haupt-Setup mit gepflegt werden, damit exportierbare Sprachpakete und Setup-Integration nicht auseinanderlaufen.
  - `google-cloud-translate` / `grpc 1.42.0`
  - `mini_racer` / `libv8-node`
  - `ruby-growl`
  - `net-ftp-list`
  - `gmail_xoauth`
  - `mysql2 0.5.3`
- Der reale Huginn-Lauf vom `2026-05-11` erreichte nach den Gem-Fixes nicht mehr den alten Bundler-/gRPC-Abbruch, sondern scheiterte erst bei der Datenbankverbindung.

### Aktueller echter Restfehler bei Huginn

- Logdatei: `/home/ubuntu/.openclaw_ultimate_user_data/install_logs/20260511_173138_tool_install_Huginn.log`
- Relevanter Fehler:
  - `Mysql2::Error::ConnectionError: Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock'`
- Befund dazu:
  - `DATABASE_ADAPTER=mysql2`
  - `DATABASE_NAME=huginn_development`
  - `DATABASE_USERNAME=root`
  - `DATABASE_PASSWORD=""`
  - kein lokaler Socket unter `/var/run/mysqld/mysqld.sock`
  - `mysql.service` und `mariadb.service` waren auf dem System nicht vorhanden

### MySQL-/MariaDB-Nutzung im Repository

Geprueft wurden:

- `scripts/tools/`
- `scripts/profiles/`
- `stacks/`

Aktueller Befund:

- Eine aktive MySQL-/MariaDB-Nutzung ist im aktuellen Setup derzeit vor allem bei `Huginn` sichtbar.
- Das Trading-Profil mit `Zenbot_trader` bzw. der verlinkten externen GitHub-Plattform richtet im lokalen Setup aktuell **keinen** MySQL-/MariaDB-Dienst ein.
- Fuer `ZenTrade AI` wurde im aktuellen lokalen Repository **kein** eigener Quelltreffer gefunden. Falls spaeter ein externer `ZenTrade AI`-Stand angebunden wird, muss dessen Datenbankbedarf separat im Zielrepo geprueft werden.
- In den aktuellen Profilskripten und Stacks gibt es ausdrueckliche **PostgreSQL- und SQLite-Pfade**, die nicht pauschal auf MySQL/MariaDB umgestellt werden sollten.

### Bewusste DB-Ausnahmen im Projekt

Diese Komponenten sind im aktuellen Setup fachlich bewusst nicht auf MySQL/MariaDB verdrahtet:

- `Data_Engineering` installiert explizit `postgres` und `pgvector`.
- `Personal_Knowledge_OS` installiert explizit `sqlite_vec`.
- `Programmierer` fuehrt sowohl `sqlite` als auch `postgres` als allgemeine Infrastrukturbausteine.
- `Langfuse` nutzt im Tool-Setup PostgreSQL.
- `Healthchecks` nutzt im Tool-Setup PostgreSQL.
- `Paperless_NGX` nutzt im Tool-Setup PostgreSQL.
- `llmops-platform` nutzt fuer `langfuse` einen eigenen PostgreSQL-Dienst.
- Das Kubernetes-Beispiel fuer `zenbot` zeigt aktuell `MongoDB`, nicht MySQL/MariaDB.

### Projektregel fuer kuenftige Chats

- MariaDB/MySQL soll im Projekt bevorzugt dort verwendet werden, wo der Zielstack frei zwischen Adaptern waehlen kann und der Betrieb damit vereinheitlicht werden soll.
- PostgreSQL-, SQLite- oder MongoDB-native Pfade sollen **nicht** automatisch auf MariaDB/MySQL umgestellt werden, nur um einen globalen Einheitsstandard zu erzwingen.
- Vor jeder kuenftigen DB-Umstellung ist zuerst zu pruefen, ob der jeweilige Upstream-Stack technisch oder dokumentarisch auf PostgreSQL, SQLite oder MongoDB zugeschnitten ist.
- Fuer `Huginn` ist MySQL/MariaDB aktuell der reale operative Kandidat, solange keine bewusste Entscheidung fuer `postgresql` oder `sqlite3` getroffen wird.
- Ausnahme/Ergaenzung: Wenn Huginn auf einer VPS oder in K3s zusammen mit Clawbake betrieben werden soll, ist PostgreSQL fuer Huginn vorzuziehen, weil Clawbake selbst PostgreSQL-only ist.

### Praktische Schlussfolgerung

Fuer Huginn gibt es aktuell drei sinnvolle DB-Pfade:

1. lokalen MySQL- oder MariaDB-Dienst installieren und starten
2. externen MySQL-Host in `/opt/huginn/.env` ueber `DATABASE_HOST` und optional `DATABASE_PORT` setzen
3. Huginn auf `postgresql` oder `sqlite3` umstellen

### Wichtige Dateien

- [scripts/tools/huginn_install.sh](/C:/Users/danie/Documents/GitHub/VPS,_Kubernate,_Ollama_OpenClaw_installation/scripts/tools/huginn_install.sh:1)
- [docs/HUGINN_ENV_GUIDE.md](/C:/Users/danie/Documents/GitHub/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/HUGINN_ENV_GUIDE.md:1)
- [scripts/config_templates/huginn/.env.template](/C:/Users/danie/Documents/GitHub/VPS,_Kubernate,_Ollama_OpenClaw_installation/scripts/config_templates/huginn/.env.template:1)

### Hinweis fuer Folge-Chats

Wenn ein spaeterer Chat an Huginn weiterarbeitet, sollte er zuerst diese Punkte als bekannt voraussetzen:

- Der fruehere `grpc 1.42.0`-Fehler ist nicht mehr der primaere Blocker.
- Der aktuelle reale Restfehler ist die fehlende lokale MySQL-/MariaDB-Infrastruktur fuer Huginn.
- Vor weiteren Gem-/Bundler-Eingriffen sollte zuerst entschieden werden, ob Huginn mit `mysql2`, `postgresql` oder `sqlite3` betrieben werden soll.

### Jarvis / FritzBox / Alexa / Home Assistant

- Fuer die Kombination aus Fritz!Box/Fritz!Fon, Home Assistant, optionaler Alexa-Bridge und lokalem Sprachassistenten gibt es jetzt das Profil `Jarvis_FritzBox_Alexa_Home_Assistant`.
- Das sogenannte `Jarvis Brain` ist kein einzelnes Tool, sondern eine logische Zentrale aus Ollama, OpenClaw, Home Assistant, Node-RED/MQTT, optionalem Memory und lokaler STT/TTS-Pipeline.
- Alexa soll dabei nicht als eigentliche Telefonanlage verstanden werden. Fritz!Box oder spaeter Asterisk/SIP sind die Telefonie-Schicht; Alexa ist hoechstens optionaler Trigger oder Ausgabekanal.
- Datenschutzregel: keine heimliche Anrufaufzeichnung, keine Cloud-Weitergabe privater Anrufdaten als Standard, keine sicherheitskritischen Smart-Home-Aktionen ohne Bestaetigung.

### OpenHiggsStack / AI Cinema Studio

- Neues optionales Profil: `OpenHiggsStack_AI_Cinema_Studio`.
- Zweck: offene, lokale bzw. hybride Alternative zu cloudbasierten AI-Cinema-/Marketing-Studios.
- Kernbausteine: OpenClaw, Ollama, ComfyUI, Wan2.x, FFmpeg, n8n.
- `scripts/install-openhiggsstack.sh` bereitet Ordner, Log und `.env` vor, installiert nach Moeglichkeit `ffmpeg` und fragt vor dem ComfyUI-Klon.
- Grosse Modelle wie Wan2.1/Wan2.2, Flux oder Cloud-Modelle werden nie automatisch heruntergeladen.
- Fuer allgemeine Installationsfehler gibt es `scripts/last_install_log.sh`, um das neueste Log sofort anzuzeigen oder via bestehender Diagnose-Mail weiterzugeben.

### Installationsueberwachung / Log- und Speicherdiagnose

- Ursache fuer das beobachtete Weiterinstallieren nach `[Z]`: Der normale Tool-Batch hatte den Abbruch bereits, aber Profil-/Gruppeninstallationen haben `TOOL_BATCH_ABORT_REQUESTED` nicht konsequent bis zur Profilansicht zurueckgegeben.
- Fix: `show_tool_group_checklist` und `toggle_tool_group_bulk` brechen nun nach `install_tool` und `uninstall_tool` sofort ab, setzen `PROFILE_FLOW_ABORT_REQUESTED=1` und springen zurueck, sobald `[Z]` oder `[z]` gewaehlt wurde.
- Neue Sofortbefehle: `bash scripts/last_install_log.sh --failed`, `bash scripts/last_install_log.sh --diagnostics` und `bash scripts/last_install_log.sh --snapshot`.
- `scripts/install_run_diagnostics.sh` erstellt einen Bericht ueber mehrere aktuelle Logs statt nur ueber das letzte Tool. Damit gehen fruehere fehlgeschlagene Tools im selben Installationslauf nicht mehr unter.
- `scripts/dependency_snapshot.sh` dokumentiert Speicherorte, `/opt`, Python-venvs, apt-Markierungen, Node/npm/pnpm und Docker/Podman-Spuren. Das ist wichtig, weil Deinstallation nicht automatisch alle Caches, globalen Abhaengigkeiten, Container-Images oder Modellordner entfernt.
- Deinstallationen laufen im Tool-Management und in Profil-Toolgruppen jetzt vor Installationen, damit bei knappen Datentraegern zuerst Speicher freigegeben wird.
- Fehler nach `install_tool`/`uninstall_tool` oeffnen den Sofortdialog auch ohne aktivierte erweiterte Ueberwachung. Bei Fehlern ist Enter bewusst wie `[Z]`, damit nicht versehentlich weiterinstalliert wird.
- Alte Fehlerlogs koennen ueber die Installationsueberwachung oder per `bash scripts/cleanup_setup_logs.sh --apply --failed-only` gezielt geloescht werden.
