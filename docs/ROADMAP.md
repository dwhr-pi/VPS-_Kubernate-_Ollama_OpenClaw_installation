# Roadmap

Diese Roadmap priorisiert Konsistenz, Sicherheit und belastbare Installationspfade vor weiterer Funktionsbreite.

## P0: Security und Konsistenz

- `config/tools.yml`, `config/profiles.yml` und `config/ports.yml` als verbindliche zentrale Wahrheit halten
- Compose- und Stack-Dateien auf `.env` statt `.env.example` umstellen
- Standardports nur lokal binden, externe Freigabe nur ueber Tunnel oder Reverse Proxy
- Secret-Scanning als Pflichtpfad fuer lokale Commits und CI sichtbar machen
- Profil- und Tool-Doku strikt mit den echten Skripten synchronisieren

## P1: Coding-, Sandbox- und Browser-Pfade

- `Programmierer`, `AI_Project_Manager`, `Browser_Automation_Agent` und `Repo_Maintainer` funktional durchtesten
- `Clawhub`, `Clawhub CLI`, `OpenHands`, `Aider` und `Playwright` auf WSL2 und VPS weiter abklopfen. `OpenManus` hat inzwischen eine robustere venv-/Torch-/flash-attn-Installationslogik, bleibt aber abhängig vom aktuellen Upstream-Stand.
- gemeinsame Status-/Repair-/Dry-Run-Schnittstelle fuer Tool-Skripte definieren
- Ressourcenchecks fuer grosse Node-/Python-Builds vereinheitlichen

## P2: Evaluation, RAG, Dokumente

- `Prompt_Engineering_Studio`, `AI_Agent_Evaluation`, `RAG_Wissensdatenbank`, `Document_Intelligence` zusammenziehen
- eval- und dokumentbezogene Toolketten um fehlende Installer wie `DVC`, `Label Studio`, `Haystack`, `Typesense` erweitern
- ingestierbare Dokumente, OCR-Pfade und RAG-Speicher mit klaren Datenschutzgrenzen versehen

## P3: Apps, Automation und Office

- `NoCode_LowCode_AI`, `Local_AI_App_Builder` und `Email_Office_Automation` mit stabilen Port- und Auth-Standards versehen
- lokale App-Builder und Automations-Stacks gegen Wildwuchs bei Ports, Volumes und Secret-Dateien haerten
- spaeter optionale Profile fuer Meeting-, Mail- und Kalender-Workflows nachziehen

## P4: Media, Voice, IoT und Web3 Safe

- GPU-/VRAM-Hinweise weiter schaerfen
- Voice-/Clone-/Video-Profile mit deutlicheren Ethik- und Rechtehinweisen versehen
- `Robotics_IoT_Edge_AI` und `Smart_Home_Automation` mit Backup- und Netzwerksegmentierungs-Checks erweitern
- Web3/Trading weiterhin strikt auf Analyse, Paper-Trading und manuelle Bestaetigung begrenzen

## P5: Governance und Plattformbetrieb

- Profilempfehlungen fuer `MiniPC`, `WSL2`, `VPS`, `GPU-Workstation` und `Kubernetes` konsolidieren
- Backup-Punkte vor groesseren Setup-Aenderungen automatisieren
- Healthcheck-, Status- und Repair-Funktionen systematisch in die Menues heben
- optionale GitOps-Pfade fuer K3s nur dann weiter ausbauen, wenn die lokale Basis stabil ist
# Roadmap Zusatz 2026

- Job Queue fuer Codex/OpenClaw/n8n stabilisieren.
- HE/Oracle/WireGuard als Standardpfad fertig testen.
- Stalwart Mail als optionalen, gehaerteten Mailserver vorbereiten.
- MCP Toolserver nur read-only-first aktivieren.
- Supply-Chain-Checks lokal und in CI ausbauen.
- GPU-/Render-Pipelines nur ueber Queue und Opt-in starten.
## Roadmap: Voice Studio & AI Singer

### P0: Sichere Basis
- Piper + FFmpeg als leichtes Minimal-Setup dokumentieren.
- VoiceStudioAgent als read-only-first OpenClaw-Agent nutzen.
- Rohdaten und Modelle ausschliesslich unter `~/.openclaw_ultimate_user_data/voice_studio/` speichern.

### P1: Studio-Workflows
- Podcast_Studio und Audiobook_Studio mit Job Queue verbinden.
- n8n-Workflows fuer Text zu Sprache, Hoerbuch und Podcast als sichere Vorlagen ausbauen.
- Home Assistant mit Piper als Standard-Sprachausgabe testen.

### P2: GPU-/Singer-Labor
- Voice_Clone, AI_Singer, AI_Choir, Dubbing_Studio und Voice_Laboratory nur mit GPU-/RAM-Preflight aktivieren.
- RVC, Seed-VC, DiffSinger, OpenUtau, NNSVS und UVR5 einzeln evaluieren.
- Training nur mit Einwilligungsnachweis, Kennzeichnung und manueller Freigabe.
## Roadmap: AI Media Production Studio

### P0: Sichere Rollen- und Skriptbasis
- `docs/CHARACTER_LIBRARY.md` fuer Rollen, Stimmen und Sicherheitsfelder nutzen.
- News-, Podcast-, Hoerbuch- und Moderationsworkflows zuerst ohne Avatarvideo testen.
- KI-Kennzeichnung und manuelle Freigabe als Pflicht behalten.

### P1: Lokale Produktion
- Piper, FFmpeg und vorhandene Voice-Studio-Profile fuer einfache Produktionen nutzen.
- Podcast-, Newsroom- und Hoerbuch-Workflows ueber n8n und Job Queue verbinden.
- Character Library mit fiktiven Rollen ausbauen.

### P2: GPU-Avatarstudio
- MuseTalk, LivePortrait, Hallo2, SkyReels-A1, EMO, SadTalker und Wav2Lip einzeln evaluieren.
- Keine automatische Installation, keine automatische Veroeffentlichung.
- GPU-/VRAM-Checks, Lizenzpruefung und Einwilligungspflicht vor jedem echten Projekt dokumentieren.
## Roadmap: Media-Studio-Struktur

### P0: Ordnung und Auffindbarkeit
- Neue Hauptstruktur unter `docs/media_studio`, `docs/voice_studio`, `docs/film_studio`, `docs/broadcasting`, `docs/avatar_studio`, `docs/choir_system`, `docs/agents/media`, `docs/workflows/media` und `docs/tutorials/media` pflegen.
- Alte Top-Level-Dokumente vorerst nicht loeschen, damit Links nicht brechen.

### P1: Setup-Menue vorbereiten
- MEDIA STUDIO als Hauptkategorie mit Unterpunkten Voice Studio, AI Singer Studio, Choir Studio, Broadcasting Studio, Podcast Studio, Audiobook Studio, Avatar Studio, Film Studio, Dubbing Studio und Virtual Human Studio dokumentieren.
- Stub-Installer unter `scripts/tools/media/` bleiben sicher und starten keine schweren Builds.

### P2: Echte Installer nur nach Preflight
- Echte Installer erst ergaenzen, wenn RAM/VRAM/Speicher, Lizenz, Modellgewichte, Einwilligung und Rollback pro Tool definiert sind.
- Avatar- und Voice-Cloning-Tools nur mit manueller Bestaetigung und Job Queue starten.
