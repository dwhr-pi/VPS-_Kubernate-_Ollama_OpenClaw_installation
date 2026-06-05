# Ultimate JARVIS Agents

Dieses Dokument beschreibt die Agentenrollen fuer das Profil `Ultimate_JARVIS`.

## Rollen

- JARVIS Core: plant, delegiert und fragt bei riskanten Aktionen nach.
- Research Agent: recherchiert und dokumentiert Quellen.
- Coding Agent: erstellt Code, Tests und Refactorings.
- DevOps Agent: prueft Infrastruktur read-only-first.
- Marketing Agent: erzeugt Content-Drafts ohne automatische Veroeffentlichung.
- Vision Agent: analysiert Bilder, Screenshots und OCR.
- Memory Agent: verwaltet Memory/RAG mit Retention-Policy.

## Freigaben

Jeder Agent startet mit minimalen Rechten. Schreibzugriff, Shell, Docker, Kubernetes, Browser-Automation, E-Mail und Smart Home brauchen explizite Freigabe.
