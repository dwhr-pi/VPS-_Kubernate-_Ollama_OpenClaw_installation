# Setup Guide: OpenClaw & AI Infrastructure - Ultimate Setup V7

## 1. Einführung

Dieser umfassende Guide beschreibt die Installation und Konfiguration einer hochflexiblen und leistungsstarken KI- und Smart Home Infrastruktur. Das System ist darauf ausgelegt, sowohl auf einem lokalen MiniPC (Letsung mit WSL2) als auch auf mehreren Cloud-basierten Virtual Private Servern (VPS) zu laufen, um eine optimale Ressourcennutzung und Ausfallsicherheit zu gewährleisten. Die Installation erfolgt vollautomatisch über ein interaktives Bash-Skript, das direkt von GitHub bezogen wird.

### 1.1 Architektur-Übersicht

Die Architektur basiert auf einem hybriden Ansatz:

*   **Letsung MiniPC (WSL2):** Dient als lokaler Hub für datenschutzsensible Anwendungen, Home Assistant, lokale LLMs (Ollama) und als Edge-Computing-Knoten. Die dynamische IP wird über Hurricane Electric DNS verwaltet.
*   **Oracle Cloud Free Tier VPS:** Bietet eine kostenlose, leistungsstarke Cloud-Umgebung für Kubernetes (K3s), weitere LLMs, und 24/7 laufende Dienste wie Zenbot-trader oder n8n.
*   **Weitere kostenlose VPS (optional):** Können für spezifische Dienste wie Monitoring, Backup oder zusätzliche LLM-Instanzen genutzt werden, um die Last zu verteilen und die Verfügbarkeit zu erhöhen.

Die Kommunikation zwischen den Komponenten erfolgt über sichere Kanäle (z.B. Cloudflare Tunnel, VPNs) und API-Schnittstellen.

## 2. Installations-Voraussetzungen

Bevor du mit der Installation beginnst, stelle sicher, dass die folgenden Voraussetzungen erfüllt sind:

*   **Betriebssystem:** Ubuntu 22.04 LTS (oder neuer) auf dem MiniPC (innerhalb von WSL2) und auf allen VPS-Instanzen.
*   **Internetverbindung:** Stabile Internetverbindung auf allen Systemen.
*   **GitHub-Konto:** Für den Zugriff auf die Installationsskripte und die Projekt-Repositories.
*   **GitHub Personal Access Token (PAT):** Erforderlich, wenn du das Setup aus einem privaten Repository installierst (siehe `PRIVATE_REPO_GUIDE.md`).
*   **Cloud-Konten:** Konten bei Oracle Cloud (für Free Tier VPS), Google Cloud (für Gemini API, Google Calendar API), Cloudflare (für Tunnel, DNS) und Hurricane Electric (für dynamisches DNS).
*   **API-Keys:** Alle notwendigen API-Keys müssen bereitgehalten werden (siehe `API_KEY_GUIDE.md`).

## 3. Der Installationsprozess

Die Installation erfolgt über ein interaktives Bash-Skript (`setup_ultimate_v7.sh`), das über einen One-Liner-Befehl gestartet wird. Das Skript führt dich durch ein Menü, in dem du verschiedene Setup-Optionen und Profile auswählen kannst.

### 3.1 Start der Installation

Führe den folgenden Befehl in deinem Terminal aus:

```bash
curl -sSL https://raw.githubusercontent.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/main/install.sh | bash
```

Das `install.sh`-Skript klont das Repository und startet das Hauptmenü.

### 3.2 Hauptmenü-Optionen

Das Hauptmenü bietet folgende Optionen:

*   **1. System-Update (OS & pnpm):** Aktualisiert das Betriebssystem und `pnpm` auf die neuesten Versionen.
*   **2. Ollama Modell-Manager:** Ermöglicht die Installation und Deinstallation spezifischer Ollama-Modelle.
*   **3. Hybrid: Letsung MiniPC + Multi-VPS (Empfohlen):** Installiert das Setup auf deinem MiniPC und bereitet die Multi-VPS-Umgebung vor.
*   **4. Standalone: Nur VPS (Cloud-Native):** Installiert das Setup auf einem einzelnen VPS mit Kubernetes (K3s).
*   **5. Standalone: Nur MiniPC (Lokal):** Installiert alle Komponenten lokal auf deinem MiniPC ohne VPS-Anbindung.
*   **6. Ruflo: Installation & Management:** Installiert und verwaltet das Ruflo-System.
*   **7. Tools: Installieren & Deinstallieren:** Ein Untermenü zur Auswahl spezifischer Tools (n8n, Activepieces, Flowise, etc.).
*   **8. Profile: Installieren & Deinstallieren:** Ein Untermenü zur Auswahl und Verwaltung von Profilen (Programmierer, Media & Musik, KI-Forschung, Texter/Werbung/Marketing).
*   **9. Dokumentation & API-Key Guide:** Zeigt diesen Guide und den API-Key Guide an.
*   **10. System-Check & Port-Analyse:** Führt eine Analyse der Systemressourcen und Port-Verfügbarkeit durch.
*   **11. OpenClaw starten (Dev-Modus):** Startet OpenClaw im Entwicklungsmodus.
*   **12. Home Assistant starten:** Startet den Home Assistant Dienst.
*   **13. Beenden:** Beendet das Installationsprogramm.

### 3.3 Profil-Management

Das Profil-Management (Option 8 im Hauptmenü) ermöglicht die Installation und Deinstallation von thematisch gebündelten Softwarepaketen. Du kannst mehrere Profile gleichzeitig installieren.

*   **Programmierer-Setup:** Enthält Tools für Entwicklung, Code-Generierung (z.B. DeepSeek Coder Modell für Ollama), Git-Integration und Huginn.
*   **Media & Musik:** Beinhaltet Tools für Audio-Verarbeitung (FFmpeg, Audio-AI), Video-Generierung und die Alexa-Integration.
*   **KI-Forschung:** Umfasst spezialisierte Bibliotheken und Konfigurationen für OpenClaw RL und erweiterte LLM-Modelle (z.B. Gemini-1.5-Pro).
*   **Texter, Werbung & Marketing:** Stellt Tools für Content-Generierung, SEO-Analyse, Social Media Integration und spezialisierte LLM-Modelle für Textproduktion bereit.

### 3.4 Tool-Management

Das Tool-Management (Option 7 im Hauptmenü) ermöglicht die Installation und Deinstallation einzelner Tools. Hier eine Übersicht der verfügbaren Tools:

*   **Ollama:** Lokales LLM-Backend. Du kannst über den Ollama Modell-Manager (Option 2 im Hauptmenü) spezifische Modelle installieren und verwalten.
*   **OpenManus:** Ein KI-Agenten-Framework für automatisierte Aufgaben.
*   **OpenClaw:** Ein KI-Agenten-Framework mit Reinforcement Learning (RL) und Skill-Integration (z.B. `gcali` für Google Kalender).
*   **Clawhub CLI:** Ein Kommandozeilen-Tool zur Interaktion mit Clawhub-Diensten.
*   **OpenClaw RL:** Die Reinforcement Learning Erweiterung für OpenClaw.
*   **Clawbake:** Ein Tool zur Automatisierung von Builds und Deployments.
*   **n8n:** Ein Workflow-Automatisierungstool, das viele Apps und Dienste verbindet.
*   **Activepieces:** Eine Open-Source-Alternative zu Zapier für Workflow-Automatisierung.
*   **Flowise / LangFlow:** Open-Source-UIs für LLM-Anwendungen, basierend auf LangchainJS, zur visuellen Erstellung von LLM-Workflows.
*   **Pipedream:** Eine Serverless-Plattform zur Integration von APIs und Diensten (Self-Hosted Option ist komplex und wird auf die offizielle Doku verwiesen).
*   **Huginn:** Ein Open-Source-Agentensystem, das Aktionen im Web automatisiert (wird auch im Programmierer-Profil installiert).
*   **Zenbot-trader:** Eine Plattform für automatisierten Krypto-Handel.

## 4. Konfiguration und API-Keys

Die detaillierte Konfiguration von API-Keys, Port-Einstellungen und Fallback-Routing zwischen Gemini und Ollama ist im `API_KEY_GUIDE.md` beschrieben. Bitte lies diese Datei sorgfältig durch, bevor du mit der Konfiguration beginnst.

## 5. Multi-VPS-Strategie

Um die Ressourcen optimal zu nutzen und die Stabilität zu erhöhen, wird eine Multi-VPS-Strategie empfohlen. Hier sind einige Vorschläge:

*   **Letsung MiniPC:** Home Assistant, lokale Ollama-Instanzen (für schnelle, datenschutzsensible Anfragen), Alexa Skill über Cloudflare Tunnel.
*   **Oracle Cloud Free Tier VPS:** Kubernetes (K3s) Cluster, Zenbot-trader, n8n, Activepieces, Flowise/LangFlow, Pipedream (Self-Hosted).
*   **Zusätzliche kostenlose VPS:** Können für spezifische Dienste wie Monitoring (z.B. Prometheus/Grafana), Backup-Lösungen oder weitere LLM-Instanzen genutzt werden.

## 6. Fehlerbehebung und Support

Sollten während der Installation oder Konfiguration Probleme auftreten, konsultiere bitte zuerst die `API_KEY_GUIDE.md` und die `PRIVATE_REPO_GUIDE.md`. Bei weiteren Fragen oder Problemen kannst du Issues im GitHub-Repository erstellen.

Wir wünschen dir viel Erfolg bei der Einrichtung deines intelligenten, automatisierten Systems!
