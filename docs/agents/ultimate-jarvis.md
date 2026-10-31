# Ultimate JARVIS Agents

Dieses Dokument beschreibt die Agentenrollen fuer das Profil `Ultimate_JARVIS`.

[Hermes als optionale getrennte Jarvis-Laufzeit](../tools/hermes-jarvis-weekend.md):
Wochenendleitfaden, Briefing, Entwurfs-Skill und Abnahme. Keine automatische OpenClaw-Migration,
Kontoverbindung oder Erweiterung der Jarvis-Core-Rechte.

## Rollen

[Dashboard- und Sprachkonzept mit Hermes](../tools/jarvis-hermes-dashboard.md): sicherer
Einrichtungsablauf und Briefing, kein bereits gestarteter Dienst.

Coding-Erweiterungen werden **nicht in Jarvis eingebaut**, sondern als
[getrennte Profile](coding-agent-profiles.md) vorbereitet: Claude-Code-Agent, Gemini-Code-Agent und
Ollama-Coder. Jarvis-Core waehlt nur die Rolle; OpenClaw, MCP und Kubernetes bleiben getrennte
Infrastruktur-Layer.

- JARVIS Core: plant, delegiert und fragt bei riskanten Aktionen nach.
- Research Agent: recherchiert und dokumentiert Quellen.
- Coding Agent: erstellt Code, Tests und Refactorings.
- DevOps Agent: prueft Infrastruktur read-only-first.
- Marketing Agent: erzeugt Content-Drafts ohne automatische Veroeffentlichung.
- Vision Agent: analysiert Bilder, Screenshots und OCR.
- Memory Agent: verwaltet Memory/RAG mit Retention-Policy.

## Freigaben

Jeder Agent startet mit minimalen Rechten. Schreibzugriff, Shell, Docker, Kubernetes,
Browser-Automation, E-Mail und Smart Home brauchen explizite Freigabe.
