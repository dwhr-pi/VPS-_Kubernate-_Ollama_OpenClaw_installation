# Huginn Upstream-Versionen (`HUGINN_REPO_REF`) - Erklaerung fuer das Setup

## Ueberblick

Die Variable `HUGINN_REPO_REF` bestimmt, welcher Stand des offiziellen Huginn-Repositories verwendet wird.

Beispiel:

```bash
HUGINN_REPO_REF=v2022.08.18
```

Dabei kann es sich um folgende Typen handeln:

- Release-Tag
- Branch (`master` / `main`)
- spezifischer Commit
- eigener Fork/Branch

Offizielle Releases befinden sich hier:

- [Huginn Releases](https://github.com/huginn/huginn/releases)

Im Setup wird Huginn jetzt bewusst branch-orientiert verwaltet:

- die Auswahl liegt ausserhalb des Repositories in `~/.openclaw_ultimate_user_data/custom_sources.conf`
- dort werden `CUSTOM_REPO_HUGINN_URL`, `CUSTOM_REPO_HUGINN_REF` und `CUSTOM_REPO_HUGINN_PROFILE` gespeichert
- aenderst du Branch, Tag, Commit oder Fork, sollte danach der Huginn-Installer erneut laufen
- dadurch behandelt das Setup jeden Huginn-Stand als eigenen Installationslauf mit passenden Bundle-, Datenbank- und Fallback-Schritten

---

## 1. Stable Release Tag (empfohlen fuer stabile Produktion)

Beispiel:

```bash
HUGINN_REPO_REF=v2022.08.18
```

Dies ist der aktuell letzte offizielle Huginn-Release-Tag.

### Eigenschaften

Vorteile:

- stabil
- getestet
- reproduzierbar
- weniger Breaking Changes
- geeignet fuer kleine VPS/Home-Server
- ideal fuer produktive Langzeitinstallationen

Nachteile:

- aeltere Ruby-/Gem-Versionen
- weniger moderne API-Kompatibilitaet
- weniger aktuelle Sicherheitsupdates
- manche moderne Integrationen fehlen

### Empfohlene Nutzung

Geeignet fuer:

- klassische Automationen
- RSS/Webhook-Agenten
- Home Automation
- kleine Produktionssysteme
- Systeme mit geringem Wartungsaufwand

---

## 2. `master` / `main` Branch (modernster Entwicklungsstand)

Beispiel:

```bash
HUGINN_REPO_REF=master
```

oder:

```bash
HUGINN_REPO_REF=main
```

Dies verwendet den neuesten Entwicklungsstand direkt vom GitHub-Repository.

### Eigenschaften

Vorteile:

- neueste Features
- modernere Dependencies
- bessere Docker-Kompatibilitaet
- modernere Ruby-Versionen
- aktuellere Sicherheitsfixes
- bessere API-Kompatibilitaet

Nachteile:

- experimenteller
- Breaking Changes moeglich
- inkompatible Agenten moeglich
- ungetestete Aenderungen moeglich

### Empfohlene Nutzung

Geeignet fuer:

- Kubernetes
- moderne Docker-Stacks
- AI-/LLM-Workflows
- Ollama/OpenClaw
- LangChain
- Entwickler-/Testsysteme

---

## 3. Spezifischer Commit SHA (maximal reproduzierbar)

Beispiel:

```bash
HUGINN_REPO_REF=e605da6
```

Dies pinnt exakt einen bestimmten Commit.

### Eigenschaften

Vorteile:

- maximale Reproduzierbarkeit
- perfekt fuer GitOps/Kubernetes
- identische Builds
- kontrollierte Deployments

Nachteile:

- manuelles Testen erforderlich
- keine automatischen Updates

### Empfohlene Nutzung

Geeignet fuer:

- Enterprise-Deployments
- Kubernetes
- CI/CD
- produktive Cluster
- Snapshot-basierte Systeme

---

## 4. Eigener Fork / eigener Branch

Beispiel:

```bash
HUGINN_REPO_URL=https://github.com/USERNAME/huginn.git
HUGINN_REPO_REF=my-ai-branch
```

Dies erlaubt eigene Erweiterungen.

### Empfohlene Nutzung

Geeignet fuer:

- Ollama-Integration
- OpenClaw-Agenten
- KI-Workflows
- Telegram-/Discord-/Matrix-Integrationen
- Zenbot-Steuerung
- eigene AI-Agents
- RAG-Workflows
- LangChain/OpenWebUI

---

## Empfehlung fuer dieses Setup

### Empfohlener Standard

```bash
HUGINN_REPO_REF=v2022.08.18
```

Grund:

- stabil
- bewaehrt
- kompatibel
- geringer Wartungsaufwand

Das ist im Setup das empfohlene Profil:

```bash
CUSTOM_REPO_HUGINN_PROFILE="stable-release"
CUSTOM_REPO_HUGINN_REF="v2022.08.18"
```

---

## Empfehlung fuer moderne AI-/LLM-Systeme

Fuer folgende Systeme empfiehlt sich langfristig ein modernerer Huginn-Stand:

- Ollama
- OpenClaw
- LangChain
- Kubernetes
- moderne Docker-Stacks
- AI-Agenten
- Webhook-/API-intensive Workflows

Dann kann alternativ verwendet werden:

```bash
HUGINN_REPO_REF=master
```

Im Setup kann dafuer das Profil `master-ai` gesetzt werden.

Wichtig:

- regelmaessige Backups
- PostgreSQL Dumps
- Docker Volume Snapshots
- zuerst in Staging testen

---

## Empfehlung fuer dieses Repository

Langfristig empfohlen:

### Eigener getesteter Produktions-Branch

Beispiel:

```bash
CUSTOM_REPO_HUGINN_PROFILE="custom-fork"
CUSTOM_REPO_HUGINN_URL="https://github.com/USERNAME/huginn.git"
CUSTOM_REPO_HUGINN_REF="my-production-2026"
```

Vorteile:

- kontrollierte Updates
- getestete AI-Integrationen
- stabile Kubernetes-Kompatibilitaet
- reproduzierbare Container
- eigene Security-/Dependency-Fixes

Dies ist insbesondere sinnvoll fuer:

- Ollama
- OpenClaw
- AI-Agenten
- Zenbot
- Workflow-Orchestrierung
- Langzeitbetrieb

---

## Technische Empfehlung

Fuer moderne Huginn-Deployments empfohlen:

- Ruby 3.x
- PostgreSQL statt MySQL
- Docker Compose oder Kubernetes
- externe Redis-Instanz
- Reverse Proxy (Traefik/Caddy)
- automatische Container-Updates
- Monitoring
- Backup-Automation

---

## Huginn im AI-Setup

In diesem Projekt wird Huginn nicht nur als klassischer Automatisierer betrachtet.

Empfohlen wird die Nutzung als:

## "AI Workflow Router"

Beispiele:

- empfaengt Events/Webhooks
- verarbeitet Datenstroeme
- ruft Ollama/OpenClaw APIs auf
- startet AI-Agenten
- steuert Zenbot
- sendet Telegram-/Discord-/Matrix-Nachrichten
- triggert Bild-/Video-KI
- ueberwacht Services
- verbindet externe APIs

Dadurch wird Huginn zu einer zentralen Orchestrierungsplattform innerhalb des gesamten KI-Stacks.

---

## Hinweis

Viele aeltere Huginn-Tutorials im Internet basieren noch auf:

- alten Ruby-Versionen
- veralteten Dockerfiles
- SQLite/MySQL
- klassischen VPS-Setups

Fuer moderne AI-/Kubernetes-Deployments sollten aktuelle Container- und Security-Standards verwendet werden.

## Setup-Hinweis

Die Huginn-Branch-Konfiguration laesst sich im Setup ueber diesen Weg aendern:

1. `Optionen / Tools`
2. `Custom GitHub-Quellen & Ollama-Builds`
3. `Huginn Branch/Ref konfigurieren`

Dort stehen aktuell folgende Profile bereit:

- `stable-release`
- `master-ai`
- `main-ai`
- `pinned-commit`
- `custom-fork`

## Quellen

- [Huginn GitHub Repository](https://github.com/huginn/huginn)
- [Huginn Releases](https://github.com/huginn/huginn/releases)
