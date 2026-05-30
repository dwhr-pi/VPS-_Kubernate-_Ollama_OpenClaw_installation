# Roadmap Next Profiles

## P0: Security und Konsistenz

- Doctor-Skripte regelmaessig im Setup-Menue sichtbar machen.
- Secret-Scan vor Commit als Standardempfehlung.
- Profile mit `status` und `tier` weiter vervollstaendigen.

## P1: Codex, Browser und Agenten

- Browser-Automation nur mit Allowlist.
- Self-Learning-Agent-Lab als Replay-/Eval-Umgebung ausbauen.
- Prompt-Generator-Studio mit Prompt-Registry verbinden.

## P2: Memory, RAG und Dokumente

- Memory Import/Export mit Redaction-Pipeline.
- Docling/Tika/Paperless/Qdrant besser zusammenfuehren.
- Profile `Document_AI` und `Document_Intelligence` konsolidieren.

## P3: Media, GPU und Android

- Render-Farm/GPU-Workstation nur nach Hardware-Check.
- Android-App-Builder erst nach SDK-/Gradle-Doctor.
- Legal-Safe-Creator fuer Creator-Workflows erweitern.
# 11.17 Planned Profile Roadmap

Prioritaet fuer die naechsten stabilen Ausbauschritte:

1. `AI_Testing_QA_Lab`: Shell-/Profil-/Prompt-Tests zuerst stabilisieren.
2. `Local_AI_Office_Suite`: LibreOffice CLI, Pandoc, Tesseract und Docling als risikoarme lokale Tools.
3. `Model_Router_Cost_Control`: LiteLLM/Ollama/Open-WebUI mit Kosten- und Provider-Sperren.
4. `Personal_Memory_Knowledge_OS`: Memory-Import nur lokal und mit Loesch-/Exportpfad.
5. `Network_HomeLab_ZeroTrust`: Tailscale/cloudflared/Uptime Kuma ohne offene Admin-Ports.

Schwere oder riskante Profile wie Android SDK, Nextcloud, Headscale, MobSF, scancode-toolkit und Browserless bleiben `planned` oder `experimental`, bis Installationspfad und Healthchecks getestet sind.
# Roadmap Zusatz 2026

Neue planned Profilgruppen:

- Plattform/Betrieb: Queue Manager, LLMOps Control Plane, Wake-on-LAN, Update/Rollback
- KI/Agenten: Codex Worker, OpenClaw Task Queue, MCP Hub, RAG Document Factory
- Sicherheit: HE DNS Hardening, Firewall/IDS/IPS, Secrets Vault, Mail Security
- Medien: AI Content Multiplier, Render Queue, ComfyUI Workflow Manager
- Alltag: Home Assistant Agent, Local Voice Assistant, Email Assistant
- Entwicklung: Repo Auditor, Issue Triage, CI/CD Builder, Docs Automation

Alle neuen Profile bleiben zunaechst `planned` und starten keine schweren
Installer automatisch.
