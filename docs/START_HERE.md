# START HERE

[GitLab/OpenForge/GENIE.AI und MLflow](tools/gitlab-openforge-mlflow.md):
Quellenpruefung, Namensabgrenzung und optionaler Einstieg mit Offline-CI sowie
ausdruecklich gestartetem lokalem Ollama-Review. Keine neue Runtime aktiviert;
GitLab- und Codeberg-Installationen weiterhin ungeprueft.

[Docker-Installer durch native GitHub-Builds ersetzen](DOCKER_TO_GITHUB.md):
Alle 43 Pfade registriert: 41 Buildrezepte, 2 offene Migrationen; PyAirbyte als separates SDK zusaetzlich.
Forgejo verwendet nach Freigabe die offizielle Codeberg-Quelle statt GitHub.
Kein automatisches Entfernen bestehender Container/Volumes.

[P0-Codepaket: Update, PAT und datenerhaltender Compose-Uninstall](P0_SAFETY_CHANGES.md):
lokale Fixture-Tests abgeschlossen, Ubuntu-24.04-VM-Abnahme noch offen.

Zuerst [aktuellen Nachweisstand](CURRENT_STATUS.md) und
[erste 60 Minuten](FIRST_60_MINUTES.md) lesen. Der
[Audit vom 23.10.2026](AUDIT_2026-10-23.md) nennt offene P0-Risiken;
die nachstehenden Installationspfade sind keine Produktionsfreigabe.

[Neue produktionsnahe Baseline](PRODUCTION_BASELINE.md): getrennte Ansible-,
Kubernetes-, Monitoring-, SOPS-/Restic- und CI-Dateien mit Offline-Pruefungen.
Bestehende produktive Konfigurationen werden nicht automatisch ersetzt.

[Welche Tools fehlen im Setup?](TOOL_SETUP_GAPS.md) und
[vollstaendiger statischer Abgleich](TOOL_SETUP_AUDIT.md): Dokumentation,
Registry, Menue und Runtime sind nicht gleichbedeutend.

[Webinar-Stack mit deinem KI-Setup](tutorials/webinar-stack.md):
Skript, Marp-Folien, Anmeldung, Mailstrecken und Live/Replay, ohne Docker-Pflicht.

[Hermes-/Jarvis-Wochenendleitfaden](tools/hermes-jarvis-weekend.md):
optional und getrennt vom Kernsetup, mit Briefing und Kundenanfragen-Entwurf.

[Agentic_OS: nur optional evaluieren](tools/agentic-os.md), nicht als neue
Kernplattform. Im Tools-Menue nur gepinnte GitHub-Quellen ohne Dashboardstart.

[Aktueller Projektaudit](PROJECT_AUDIT_2026_10_20.md) und
[Projekt ohne Installation pruefen](REPOSITORY_QUALITY.md).

[Colibri: grosse Modelle auf MiniPC und RTX 5080?](tools/colibri.md)
erklaert SSD-Streaming und den optionalen GitHub-Quellinstaller ohne Docker/Modelle.

[Lokale KI-Leistung messen](tools/local-ai-benchmarks.md):
reproduzierbare Benchmarks statt Schaetzungen aus Gaming-Scores.

[Speicherplanung: UMA, VRAM und Offloading](memory/UNIFIED_MEMORY_AND_OFFLOADING.md)
erklaert RAM-/GPU-Budgets, WSL-Grenzen und den Offline-Rechner ohne Systemaenderungen.

Wenn du neu startest, beginne hier.

## Merksatz

```text
HE vorne, Oracle steuert, Pi weckt, RTX rechnet.
```

## Sicherer erster Weg

1. Lies [Beginner Guide](BEGINNER_GUIDE.md).
2. Starte nur Basis.
3. Installiere Ollama/OpenClaw lokal.
4. Richte Oracle VPS erst als Control Node ein.
5. Verbinde Heimnetz nur ueber WireGuard.
6. Nutze Queue Manager, bevor schwere Jobs starten.

## Nicht direkt oeffentlich machen

- Ollama
- OpenClaw Gateway
- Kubernetes API
- Home Assistant
- NAS
- Datenbanken
- ComfyUI
- Whisper

## Startpfade 2026 Next Improvements

- MiniPC lokal: Low Resource Mode, Piper, Ollama klein, Queue default 1.
- WSL2 lokal: Windows-C:-Speicher, Python-Versionen, Docker optional, keine schweren Builds parallel.
- Oracle VPS: Control Node, WireGuard, Mail-DNS, Monitoring, keine sensiblen Heimdienste oeffentlich.
- Hurricane Electric DNS/Domain: DNS bewusst setzen, keine Wildcards ohne Schutz, rDNS fuer Mail beachten.
- Home Assistant zuhause: nur ueber VPN/Reverse Proxy mit Auth, keine offenen Admin-Panels.
- GPU Workstation: Media-/Avatar-/vLLM-/RVC-Jobs ueber Queue starten.
- Low Resource Mode: Glances/Netdata statt vollem Grafana-Stack, SQLite-Queue statt Redis/RabbitMQ.
- Security First Mode: Secrets extern, Ports minimal, check_secrets/check_ports/check_resource_budget vor Installationen.
