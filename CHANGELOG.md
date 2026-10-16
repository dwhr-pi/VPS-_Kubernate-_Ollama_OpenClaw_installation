# Changelog

## Unreleased

- Pinokio: eigener nativer GitHub-Release-Downloadassistent v8.2.0 statt
  Social-Platzhalter; Browser nur mit Freigabe, Wartepause und manuelle
  Bestaetigung ohne falschen Installationsnachweis. Windows-Hash dokumentiert.

- TGI: gepinnte GitHub-Quellinstallation ohne Docker, optional nativer
  Launcher-Build mit doppeltem Opt-in, Lock/Logs/Ressourcen und Hashchecks.
  Maintenance Mode und fehlende Router-/Python-/GPU-Inferenzlaufzeit klar getrennt.

- ViDubb: gepinnter GitHub-Sparse-Quellinstaller ohne Docker; keine .env/
  Medien/Gewichte im Arbeitsbaum, kein Import/Paket-/Appstart. Legacy-Pins,
  Importinstallationen, oeffentliches Gradio und loeschende Verarbeitung
  dokumentiert: Quellinstallation ist noch keine betriebsbereite Dubbing-Laufzeit.

- ComfyUI-GGUF: eindeutige bekannte ComfyUI-Pfade und venv/.venv erkennen,
  registrierte Ziel-/Python-Pfade wiederverwenden. Mehrdeutige Funde abbrechen;
  fehlende Basisdateien konkret nennen, keine ungefragte schwere Basisinstallation.

- HF_Hub: eigener GitHub-Client-/CLI-Installer fuer 2.2.0 in privater venv
  statt Planned-Guard. Ressourcen/ensurepip, Lock/Logs, hf-Entrypoint-Metadaten;
  hf-xet nur Wheel. Kein Docker, Login, Transfer oder Cloudjob beim Installieren.

- HF_Datasets: eigener GitHub-Source-Installer fuer 5.1.0 in privater venv
  statt documentation-first-Guard. Ressourcen/ensurepip, Lock/Logs und
  datenerhaltende Deaktivierung; Wheels fuer Arrow/NumPy/pandas, keine
  schweren Extras, Datensatz-/Modell-Downloads oder Trainingsjobs.

- AudioSeal: eigener gepinnter GitHub-Paketinstaller mit privater CPU-venv
  statt planned-Guard; Ressourcen/venv-Reparatur, Lock/Logs, Metadatenchecks
  und datenbewahrende Deaktivierung. Kein Docker, Modell-/Audiozugriff oder
  Echtheitsurteil; unsicheres Checkpoint-Unpickling dokumentiert.

- DeepFilterNet: eigener GitHub-Rust-CPU-Installer fuer v0.5.6 statt
  documentation-first-Guard; kein Docker/Python. Ein Buildjob, Lock/Logs,
  Ressourcenpruefung, Binary-Hash/Versioncheck, datenbewahrende Deaktivierung.
  GitHub-Modell wird eingebettet, keine Audiobearbeitung beim Installieren.

- Qwen Code: Gesamt-RAM und aktuell verfuegbaren RAM getrennt pruefen;
  8-GB-Geraeteklasse ab 7168 MiB gesamt und 5120 MiB verfuegbar zulassen.
  pnpm-Installationsparallelitaet begrenzen; Disk-/WSL-Reserven bleiben erhalten.

- Qwen Desktop: nach Browser-Uebergabe auf Enter und manuelle Abschlussbestaetigung
  warten. Tools-Menue unterscheidet bestaetigt/verschoben/Browserfehler, statt
  erfolgreiche Browser-Uebergaben pauschal als Installationsfehler zu melden.

- Microsoft Agent Framework: venv/ensurepip vor GitHub-Download pruefen;
  fehlendes versioniertes Ubuntu-/Debian-venv-Paket mit sudo und APT-Sperrenschutz
  nachinstallieren. Repair erhaelt Quellen/venv; System-Python bleibt unveraendert.

- Pyannote_Audio: eigener GitHub-Source-Installer fuer Release 4.0.4 statt
  Audio-Review-Platzhalter; optionale private CPU-Laufzeit mit Torch/Audio/
  Codec-Pins, Ressourcencheck und doppeltem Opt-in. Keine Modelle/Token/
  Pipeline-/Audioaktionen; Offline-Doctor, Telemetrie-Hinweise und Marker-Deaktivierung.

- FILM: eigener gepinnter GitHub-Quellinstaller statt Hybrid-Platzhalter,
  ohne Docker. Archivierten TensorFlow-2.6.2-Pfad und Ausgabe-Loeschverhalten
  dokumentiert; keine blinde Runtime-/Modellinstallation. Offline-Pruefungen,
  Disk-Reserve, Lock/Logs und datenerhaltende Deaktivierung.

- SUPIR: eigener gepinnter GitHub-Quellinstaller statt Hybrid-Platzhalter,
  ohne Docker/Modelle. Lizenzgrenzen und belegten Pydantic-Konflikt dokumentiert;
  keine blinde Legacy-/GPU-Paketinstallation. Source-Status, Offline-Doctor,
  Disk-Reserve, Lock/Logs und datenerhaltende Deaktivierung.

- ComfyUI_GGUF: eigener gepinnter GitHub-Custom-Node-Installer statt Hybrid-
  Platzhalter, ohne Docker. Vorhandenes ComfyUI/venv pruefen, gguf bei Bedarf
  ohne Upgrade bestehender Pakete ergaenzen, verwalteter Node-Link; keine
  Modelle/Serverstarts. Source-only, Lock/Logs, Offline-Doctor und sicherer Unlink.

- Wan21: eigener gepinnter GitHub-Quellinstaller statt Hybrid-Platzhalter,
  ohne Docker/Modelle. Schwere CUDA-12.8-/PyTorch-/Flash-Attention-Pakete
  nur mit doppeltem Opt-in und Preflight; Quell- und Runtime-Marker getrennt.
  Offline-Doctor, Lock/Logs und datenerhaltende Deaktivierung.

- Cline: Hybrid-Platzhalter durch eigenen GitHub-Release-VSIX-Pfad ersetzt,
  v4.1.25 mit SHA-256/Publisher-Pruefung, Lock, Logs und Offline-Doctor.
  Paketbereitstellung ohne Docker; Editor-Installation separat und klar
  vom Paketstatus getrennt, keine IDE-/Provider-/Agentenaktionen.

- Qwen_Desktop: offizielle Windows-Downloadseite nach freiwilliger
  [(j)a/(N)ein]-Bestaetigung im Browser oeffnen; explizit --open-download
  moeglich. Kein Download/Installerstart oder falscher Installationsstatus.

- Karaoke_Formats: bisher ins Leere laufende Menue-Installation durch privaten
  CLI-Starter aus dem vorhandenen GitHub-Setup-Checkout ersetzt. Ohne Docker,
  Pakete oder zweiten Clone; SHA-256, Disk-Reserve, Operations-Lock, Logs,
  Offline-Status/Doctor und datenerhaltende Deinstallation.

- Microsoft_Agent_Framework: geplanten Platzhalter durch optionalen GitHub-
  Source-Installer fuer Python-Core 1.22.0 ersetzt. Private venv, fester Commit,
  Ressourcencheck, Lock, Logs und Offline-Doctor; kein Docker/Agentenstart.
  Deinstallation deaktiviert die Erfolgsmarkierung und erhaelt Daten/venv.

- Qwen_Code: fehlendes Node/npm privat via GitHub-nvm bereitstellen, Corepack
  0.34.0 in privatem npm-Prefix und pnpm 11.24.0 mit Upstream-Hash im eigenen
  Corepack-Cache. Kein globales Update, Login, Agent oder Docker. Opt-out:
  QWEN_CODE_AUTO_RUNTIME=0; Doctor/Dry-Run ohne Downloads.

- Automaton: private automatische Node-22/npm- und pnpm-10.28.1-Bereitstellung
  nach Ressourcencheck/Lock, nur bei ausdruecklicher Installation/Repair.
  Kein System-Node-/globales pnpm-Update, keine Downloads bei Status/Doctor,
  kein Agentenstart. Mit AUTOMATON_AUTO_RUNTIME=0 deaktivierbar.

- FreeLLMAPI: fehlendes/inkompatibles Node/npm bei expliziter Installation oder
  Repair automatisch privat ueber vorhandenen GitHub-nvm-Helfer bereitstellen.
  Ressourcen/Lock/Log vor Bootstrap; kompatible Runtimes weiterverwenden,
  Status/Doctor/Start ohne Downloads, System-Node/Shellprofile unveraendert.

- Qwen_Code vom allgemeinen Hybrid-Platzhalter auf eigenen gepinnten GitHub-
  CLI-Source-Build ohne Docker umgestellt; kein Login/Start/Modell-Download.
- FreeLLMAPI-Installer gibt Source-Revision aus; Tutorial zum Erkennen des
  alten Docker-Skripts ergaenzt. Lokale Aenderungen sind noch kein GitHub-Update.

- Automaton: optionaler gepinnter GitHub-Source-Build ohne Docker mit pnpm,
  Ressourcenchecks, privatem Buildlog, Lock und datenerhaltender Deaktivierung.
  Kein Agentenstart, Wallet-Zugriff, globale CLI oder Dienst; Offline-Review bleibt separat.

- FreeLLMAPI auf gepinnten GitHub-Source-Build ohne Docker umgestellt:
  npm ci/build, lokaler SQLite-Smoke-Test, Lock/Logs/Ressourcenchecks.
  Start separat im Vordergrund mit localhost-Zwang und sicher gelesenem ENV;
  alte Containerdaten bleiben unberuehrt, keine automatische Migration.

- Qwen_Desktop (Qwen Code Desktop) als manueller Windows-GUI-Pfad ergaenzt:
  offizieller Desktop-Download, sichere Erstnutzung, lokaler Hash-/Signaturcheck.
  CLI/Chat/Studio/QwenWork getrennt, keine pauschale Open-Source-/Free-Tier-Zusage.
- Hybrid-Katalog fuer Modellfamilien/Wan und sieben geplante Tools
  vervollstaendigt; keine aktiven Modelldownloads, 8K- oder VRAM-Versprechen.

- Defensiver Audio-Review: drei planned-Kandidaten und bestehende Audioquellen
  verknuepft, Originalerhalt, Separation/Diarisierung und Wasserzeichen-Grenzen
  dokumentiert. Fehlerhafte Ausloeschungs-/Echtheitsversprechen korrigiert;
  keine Herkunftsverschleierung, Modellinstallation oder Audioverarbeitung.

- Social-Avatar-Stack: acht geplante Tool-/Cloud-Kandidaten, bestehendes
  AI_Influencer-Profil und AvatarAgent erweitert. Lokaler Einsteigerleitfaden,
  Lizenz-/Ressourcengrenzen, Workflowvertrag und inaktive Budgetvorlage.
  Keine Installation, Cloud-Fallbacks oder automatische Veroeffentlichung.

- Hugging-Face-Video-Datenpfad: HF_Datasets/HF_Hub/Video2Dataset planned in
  Registry/Menue; Dataset_Curator optional erweitert. Quellenkatalog,
  Streaming-/Lizenz-/Speicherwarnungen und inaktives Freigabeprotokoll ergaenzt.
  Keine Installation, Downloads oder Trainingsstarts.

- Audio-/Video-Nachbearbeitung: 20 planned-Kandidaten, Quellen-/Ressourcenkatalog,
  Hoerbuch-/Dubbing-/Karaoke-/MIDI-Leitfaeden und planned-Profil. Offline-SRT/LRC-
  Konverter mit explizitem Export; keine Modell-/Runtime-Installation.

- Agentic-Coding-Leitfaden, Auftragsvorlagen und planned-Profil ergaenzt; vorhandene Coding-Tools mit Quellen/Doku verknuepft. Microsoft Agent Framework als optionaler planned-Kandidat, AutoGen-Maintenance-Hinweis, aktuelle OpenCode-Quelle. Keine Autonomie-/Kosten-/Stabilitaetsgarantie, keine Aufhebung der Automaton-Sperren.

- Personalaktenpfade werden vom allgemeinen unverschluesselten Workspace-Backup ausgeschlossen und mit Warnung ausgewiesen; separater verschluesselter Akten-Backupjob ist vor Produktivbetrieb verpflichtend einzuplanen.

- Personalakten_Local_First (planned) und Personnel_Documents_AI (experimental): Offline-Validierung und explizite lokale Ollama-Vorschlaege, kein Paperless-Schreiben/RAG. Paperless-Installer ohne feste Passwoerter, localhost-Bindung, private ENV/DB-Volumes, Opt-in und datenbewahrendem Stop; /opt-Altinstallationen brauchen bewusste Migration. Datenschutz-/GoBD-/ACL-/Restore-Grenzen dokumentiert.

- Automaton von Conway Research als planned/high-risk im Tool-Menue registriert: Offline-Vorschlagspruefer, gesperrte Runtime-Aktionen, Quellenstand und Zenbot/OpenClaw-Integrationsplan. Wallet-Speicherung und Survival-Behauptungen korrigiert; keine Keys, Zahlungen oder WSL-Eingriffe.

- Embedded_Debug_HIL als geplantes Tool/Profil mit nutzbarem Offline-Registerbericht, PATH-Doctor, Agentenregeln und lokalen OpenOCD-/pyOCD-Beispielen. Live-MCP, Hardwarezugriff und Source-Installer bewusst noch nicht freigegeben; keine Flash-/Reset-Automatik.

- FreeLLMAPI optional/experimental im Tool-Menue, Registry und Portmatrix: GHCR v0.14.2, localhost 3011, explizites Docker-Opt-in, private User-ENV und datenbewahrende Deinstallation. Tutorial fuer Claude Code/OpenClaw mit Kosten-, Datenschutz- und Offline-Grenzen; kein automatischer Client-Umbau.

- Lokaler age-verschluesselter ENV-Tresor im User-Backupverzeichnis, Optionen-Menue 19, Tool-/Feldzuordnungen und standardmaessige Vorschau; generierte Klartext-ENV nicht im normalen Workspace-Backup, verschluesselter Tresor separat enthalten.

- Node Exporter korrigiert erneut: kein Root-Mount im Standardprofil, weil Docker rprivate beim Root-Bind ablehnen kann. Begrenzte /proc-/sys-Collector-Auswahl; root/rslave nur explizit.

- OpenTelemetry bietet fehlende Docker-/Compose-Pakete nach explizitem Opt-in an; vorhandene Clients werden nicht durch zweite Engines ersetzt, Paketfamilien und --no-remove schuetzen vor Konfliktbereinigung.

- Promptfoo nutzt gemeinsame Node/nvm-Bereitstellung mit Puppeteer und installiert npm 11.11.0 bei Bedarf privat im User-Workspace statt System-npm zu ersetzen; Dry-Run bleibt ohne Installation.

- Puppeteer laedt vorhandenes nvm oder stellt bei Bedarf nvm v0.40.8/Node 22 samt npm im Benutzerkonto bereit; kein System-Node-Ersatz, keine Downloads im Dry-Run.

- RIFE kann fehlendes Python nach Opt-in und Disk-Pruefung als isoliertes CPython 3.11.17 aus GitHub bauen; Dry-Run ohne Build, explizite Interpretervorgaben bleiben verbindlich.

- Supabase laedt Images seriell und wiederholt erkannte Netzwerkabbrueche maximal dreimal mit Backoff; Start erst nach erfolgreichem Pull, keine Cache-/Datenloeschung.

- Whisper_CPP-Deinstallation nutzt nach fester Pfadpruefung sudo statt des unprivilegierten Node-Helfers; Dry-Run, Fehlerstatus und Regressionstest ergaenzt.

- Tool-Menue entfernt veraltete Ollama-Haekchen aus beiden Statusdateien, wenn kein ausfuehrbarer Ollama-Befehl vorhanden ist; verhindert Wiederherstellung durch Legacy-Statusmigration.

- Kustomize ersetzt apt durch GitHub-Release v5.8.2 mit SHA256 fuer amd64/arm64; Dry-Run, Client-Test und Binary-Deinstallation ergaenzt, Registry verdrahtet.

- Mosquitto entfernt die ungenutzte WebSocket-Freigabe 9001, bindet MQTT an localhost und erlaubt MOSQUITTO_HOST_PORT. Neue Config verweigert anonyme Clients; bestehende Config bleibt erhalten.

- MusicGen: Python 3.10/3.11, FFmpeg-Entwicklungspakete fuer PyAV, GitHub-Tag v1.3.0, fruehe Disk-Sperre und Backup inkompatibler venv.

- Node Exporter nutzt standardmaessig rprivate statt rslave fuer WSL-kompatible Root-Mounts und bindet 9100 an localhost. Git-Docker-Helfer setzt bei Compose-Fehler keinen Installiert-Status.

- OpenTelemetry nutzt den Docker-Compose-sudo-Fallback, prueft Speicher vor Installation, bindet neue OTLP-Ports an localhost und erhaelt bestehende Konfigurationen. Kein automatischer Docker-/Gruppenumbau.

- Promptfoo prueft Node >=22.22.0 und den Upstream-CI-Pin npm 11.11.0 vor Installation; npm ci, Build und CLI-Smoke-Test muessen erfolgreich sein. Keine apt-Node-Installation und kein fehlerverdeckender npm-Fallback.

- Puppeteer prueft Node >=22.12.0 vor Installation, stellt unzip vor Chrome-Download bereit und testet Paket/Browserdatei; Node-Helfer erzwingt Engine-Anforderungen.

- RIFE prueft Python 3.10/3.11 vor Installation, sichert inkompatible .venv und verhindert den NumPy-Source-Build unter Python 3.12; CPU-PyTorch als Standard, GPU-Quelle optional.

- Syft ersetzt den fehlenden apt-Pfad durch feste Anchore-GitHub-Releases mit SHA256 fuer amd64/arm64; Binary-Deinstallation, Doku und Registry angepasst.

- Velero-404 behoben: korrekte versionsgebundene GitHub-Assets, SHA256 aus CHECKSUM, amd64/arm64 und CLI-Dry-Run; Registry ergaenzt.

- Stable Diffusion WebUI prueft Python 3.10/3.11, sichert inkompatible venv und nutzt Upstream-Vorbereitung; fehlgeschlagene Pillow-/tokenizers-Installationen werden nicht mehr als Erfolg gemeldet.

- Forge ersetzt den fehlerhaften Repo-Root-Editable-Install durch Upstream-`launch.py --exit`, Python-3.10/3.11-Pruefung und separate venv; alte `.venv` bleibt erhalten.

- K9s verwendet feste offizielle GitHub-Releases mit SHA256-Pruefung statt Ubuntu-apt; Binary-Deinstallation und Registry ergaenzt.

- Kubectl ersetzt den fehlenden Ubuntu-apt-Pfad durch offizielle, SHA256-gepruefte Releases fuer amd64/arm64; Registry und Binary-Deinstallation angepasst.

- Kubectx/Kubens entfernt den geprueften `/opt/kubectx`-Ordner mit sudo; Fehler werden als fehlgeschlagene Deinstallation erfasst.

- n8n prueft Node >=22.22.0 vor Clone/Basisinstallation, respektiert die pnpm-Version des Checkouts und aktiviert strikte Engine-/Lockfile-Pruefung. Mosquitto/Node-RED als Nutzer des gemeinsamen sudo-Deinstallationsfixes dokumentiert.

- Airbyte prueft Ressourcen vor apt/Messwertinitialisierung, bietet `--check`/`--dry-run` und zeigt fehlenden RAM; Docker wird ueber den gemeinsamen Helfer statt als festes `docker.io` bereitgestellt.

- Supabase startet Compose ueber den sudo-faehigen Docker-Helfer; vorhandene `.env` bleibt erhalten und Docker-Paketfamilien werden nicht mehr fest erzwungen.

- Whisper.cpp verwendet einen CMake-CPU-Build mit expliziten Compiler-/CMake-Abhaengigkeiten, zwei Build-Jobs und CLI-Smoke-Test statt des Node-Installationshelfers.

- Zotero und zentrale Basisabhaengigkeiten warten begrenzt auf apt/dpkg-Sperren; leere Paketnamen loesen keine Paketinstallation mehr aus.

- Gemeinsame Git/Docker-Deinstallation (u. a. Metabase) entfernt gepruefte `/opt`-Toolordner mit sudo und meldet Stop-/Loeschfehler statt Erfolg.

- AutoGPT prueft Host-Speicher und RAM/Swap vor Clone und Docker-Installation; `--check`/`--dry-run` bieten eine reine Host-Pruefung mit konkreten Fehlmengen.

- Governance-Dokument fuer Fork-Support, genehmigte Support-Branches, signierte Support-Freigaben und sichere Rueckfuehrung in `main` ergaenzt.
- README und Integritaets-Tutorial auf das neue Fork-/Support-Modell verlinkt.
- HE/Oracle/WireGuard/Homecluster-Zielarchitektur als Einsteiger-Tutorial, Security-Doku, K3s-Hinweise, Wake-on-LAN-Skripte und sichere Beispiel-Stacks ergaenzt.
- Stalwart Mail als optionalen Mailserver-Kern mit HE-DNS-Doku, Oracle-VPS-Hardening, OpenClaw/Ollama-Mail-Agent, Control-Panel-Plan und sicheren Setup-Wrappern ergaenzt.
- AutoGPT-Installer um Diagnose fuer Frontend-`pnpm build`/`ELIFECYCLE`-Fehler, Edge-Runtime-Warnungen und Docker-Git-Metadatenwarnungen erweitert.
- AutoGPT-Installer erkennt RabbitMQ-Compose-Startfehler jetzt getrennt vom Frontend-Build und gibt passende Docker-Compose-Diagnosebefehle aus.
- AutoGPT-Installer prueft vor dem schweren Build/Start jetzt Linux-/WSL-Speicher, Windows-C:-Speicher, Docker-Root-Speicher sowie RAM+Swap.
- Tool- und Profiluebersichten starten jetzt standardmaessig im Schnellmodus; Zeit-/Speichermesswerte werden bei grossen Listen automatisch ausgeblendet.
- Clawhub-Installer installiert fehlende Bun-Basisabhaengigkeiten wie `unzip`, bevor `bun.sh/install` gestartet wird.
- Docker-Stack-Installer wie Langfuse, LiteLLM und Open WebUI fallen bei fehlender Docker-Socket-Berechtigung jetzt auf `sudo docker compose` zurueck.
- Docker-Compose-Stack-Helper gibt seine Revision im Installationslog aus, damit alte WSL-Kopien sofort erkennbar sind.
- Llama_CPP_Toolchain nutzt fuer den CMake-Build jetzt `--parallel "$(nproc)"`, damit keine quotierte `-j`-Zahl an CMake uebergeben wird.
- GitHub Contribution-, Security-, CODEOWNERS-, PR-/Issue-Template- und Branch-Protection-Dokumentation professionalisiert.
- WebsiteFactory / WebBuild-Agent als neuer lokaler Workflow-Prototyp ergaenzt: Astro/Tailwind-Projektgenerator, Ollama-Default, JSON-Queue, Queue-Worker, Setup-Wrapper und Beispielbriefing.

## V11.16

- neue Review- und Roadmap-Doku
- neue Profile für DevOps, Data, Document AI, Voice Assistant, Web3, Compliance, Personal Knowledge und Repo-Maintenance
- neue Security-Audits
- neues Gesamt-Healthcheck-Skript
- neuer Ressourcen-Estimator
- neue Tool-Installer für Maintainer-, Voice-, Web3- und Compliance-Bausteine
- Menü- und Profilintegration erweitert

## V11.15

- Registry-Grundlagen, Audit-Doku, Matrixen und zusätzliche Studio-Profile
## 2026-05-30 - Voice Studio und AI Singer erweitert

- Neue Voice-Profile fuer Voice Studio, AI Singer, AI Choir, Voice Clone, Podcast, Hoerbuch, Dubbing und Voice Laboratory ergaenzt.
- Voice-Studio-Tools als GitHub-/Open-Source-Quellen registriert: StyleTTS2, OpenVoice, RVC, Seed-VC, DiffSinger, OpenUtau, NNSVS, UVR5 und Audacity.
- AI Choir System, Trainings-Tutorials, VoiceStudioAgent und n8n/Home-Assistant-Workflow-Vorlagen dokumentiert.
- Sicherheitsregeln ergaenzt: nur eigene oder freigegebene Stimmen, Kennzeichnung von KI-Stimmen, keine Rohdaten oder Modelle im Repo, keine automatische Veroeffentlichung.
## 2026-05-30 - AI Media Production Studio erweitert

- Neue Profile fuer virtuelle Personen, Broadcast-Rollen, Dubbing, Podcast, Radio, Filmregie, Casting und Voice Direction ergaenzt.
- Character Library, AI Actor Studio, Broadcast Studio, Newsroom, Film Studio, Dubbing Studio, LipSync Studio und Ressourcenklassen dokumentiert.
- Avatar-, LipSync- und TTS-Tools als geplante GitHub-Quellen registriert: Fish Speech, MeloTTS, Kokoro TTS, Spark-TTS, Hallo2, MuseTalk, LivePortrait, SadTalker, EMO, SkyReels-A1 und Wav2Lip.
- Sicherheitsregeln fuer KI-Kennzeichnung, Einwilligung echter Personen, DSGVO-nahe Ablage und keine automatische Veroeffentlichung ergaenzt.
## 2026-05-30 - Media Studio Unterverzeichnisse strukturiert

- Neue Dokumentationsstruktur fuer Media, Voice, Singer, Choir, Broadcasting, Film, Avatar, Agenten, Workflows und Tutorials angelegt.
- Media-Profile nach `docs/profiles/media/`, Agenten nach `docs/agents/media/`, Workflows nach `docs/workflows/media/` und Tutorials nach `docs/tutorials/media/` gespiegelt.
- `config/tools.yml` um strukturierte Kategorien `voice_tools`, `singing_tools`, `avatar_tools`, `audio_tools` und `broadcast_tools` erweitert.
- Sichere Stub-Installer unter `scripts/tools/media/` angelegt; sie dokumentieren den geplanten Installationspfad, starten aber keine schweren Builds.
## 2026-05-30 - Coqui TTS Python-Kompatibilitaet dokumentiert

- Coqui TTS in `config/tools.yml` als `experimental` mit Python-Anforderung `>=3.9,<3.12` markiert.
- Ubuntu-24.04-/Python-3.12-Abbruch als erwarteten Schutz dokumentiert.
- Piper als stabilen lokalen TTS-Fallback in Voice-Studio-Doku hervorgehoben.
- Neue Kompatibilitaetsseite `docs/voice_studio/COQUI_TTS_COMPATIBILITY.md` ergaenzt.

## 2026-05-30 - Next Improvements Audit Queue Checks

- Audit docs/SETUP_AUDIT_2026_NEXT_IMPROVEMENTS.md ergaenzt.
- Neue planned/documentation-first Profile fuer Queue, MCP Gateway, Secrets, Observability, RAG, Backup, Netzwerk, Mail, Android und Model Router ergaenzt.
- Tool-Katalog um GitHub-Kandidaten mit Status, Ressourcen, Risiko, Ports, Secrets, Doctor und Uninstaller-Spalten erweitert.
- SQLite-basierte Queue-Minimalvariante unter scripts/queue/ vorbereitet.
- Neue Checks fuer Secrets, Ressourcenbudget, Queue, Mail-DNS und Observability angelegt.
## 2026-05-30 - dbt Installer auf GitHub-Unterordner korrigiert

- `scripts/tools/dbt_install.sh` installiert dbt-core nicht mehr aus dem Repository-Root, sondern aus dem Unterordner `core`.
- Der bekannte setuptools-Fehler `Multiple top-level packages discovered in a flat-layout` wird dadurch vermieden.
- `docs/DBT_INSTALLATION_NOTES.md` mit Ursache, Korrektur und Adapter-Hinweis ergaenzt.
## 2026-05-30 - Next Level Profile und Codex Task Queue

- Neue planned/documentation-first Profile fuer Betrieb, KI/Agenten, Security, Infrastruktur, Medien, Android und Projektsteuerung ergaenzt.
- `docs/CODEX_TASK_QUEUE.md` und TSV-basierte Minimalqueue unter `scripts/queue/` angelegt.
- Next-Level-Dokumente fuer Setup Review, Missing Profiles/Tools, Deployment Matrix, Security, HE/Oracle-DDoS, Backup/Restore, Beginner Wizard und Test Matrix ergaenzt.
- Security-Wrapper `scripts/security/scan_secrets.sh` und `scripts/security/scan_supply_chain.sh` ergaenzt.
