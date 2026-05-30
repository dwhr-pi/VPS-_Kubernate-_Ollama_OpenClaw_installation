# Changelog

## Unreleased

- Governance-Dokument fuer Fork-Support, genehmigte Support-Branches, signierte Support-Freigaben und sichere Rueckfuehrung in `main` ergaenzt.
- README und Integritaets-Tutorial auf das neue Fork-/Support-Modell verlinkt.
- HE/Oracle/WireGuard/Homecluster-Zielarchitektur als Einsteiger-Tutorial, Security-Doku, K3s-Hinweise, Wake-on-LAN-Skripte und sichere Beispiel-Stacks ergaenzt.
- Stalwart Mail als optionalen Mailserver-Kern mit HE-DNS-Doku, Oracle-VPS-Hardening, OpenClaw/Ollama-Mail-Agent, Control-Panel-Plan und sicheren Setup-Wrappern ergaenzt.
- AutoGPT-Installer um Diagnose fuer Frontend-`pnpm build`/`ELIFECYCLE`-Fehler, Edge-Runtime-Warnungen und Docker-Git-Metadatenwarnungen erweitert.
- GitHub Contribution-, Security-, CODEOWNERS-, PR-/Issue-Template- und Branch-Protection-Dokumentation professionalisiert.

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
