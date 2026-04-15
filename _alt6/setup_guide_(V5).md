# 📖 Umfassender Setup Guide (V5)

Willkommen zum detaillierten Setup Guide für Ihr hybrides KI- und Smart Home System! Dieses Dokument bietet einen tiefen Einblick in die Architektur, die einzelnen Komponenten und deren Zusammenspiel. Es ist als Referenz für die Installation, Konfiguration und Wartung Ihres Systems gedacht.

---

## 🌐 1. Systemarchitektur: Hybrid & Modular

Unser Setup verfolgt einen hybriden Ansatz, der die Stärken Ihres lokalen Letsung MiniPCs mit der Skalierbarkeit und Verfügbarkeit mehrerer Cloud-VPS kombiniert. Die Architektur ist modular aufgebaut, um Flexibilität bei der Installation und Konfiguration zu gewährleisten.

### 1.1. Letsung MiniPC (WSL2) - Lokale Intelligenz & Edge Computing

Dein MiniPC dient als zentrale lokale Intelligenz und Edge-Computing-Plattform. Hier laufen ressourcenintensive, privacy-sensible und latenzkritische Dienste.

*   **Betriebssystem:** Windows mit WSL2 (Ubuntu 22.04 LTS)
*   **Hardware:** 16GB RAM, 70GB SSD (dediziert für WSL2)
*   **Internet:** Fritzbox 7590 AX (dynamische IP, Glasfaser geplant)
*   **Dienste:**
    *   **Ollama:** Lokales LLM-Backend mit `llama3.2:1b` als primäres Modell für schnelle, lokale Anfragen und als Fallback für Gemini.
    *   **OpenClaw (Hauptinstanz):** Der Kern-KI-Agent, der deine Befehle verarbeitet, Skills ausführt und mit anderen Diensten interagiert. Beinhaltet OpenClaw RL (Reinforcement Learning) für adaptives Verhalten und den `gcali` Skill für Google Kalender.
    *   **Home Assistant Core:** Die zentrale Smart Home Plattform für die Steuerung deiner Geräte, Automatisierungen und die Integration des Google Kalenders. Erreichbar über einen Cloudflare Tunnel.
    *   **Cloudflared:** Stellt einen sicheren Tunnel für den externen Zugriff auf Home Assistant und OpenClaw bereit, unerlässlich für den Alexa Skill und den Zugriff von VPS-Diensten.
    *   **Ruflo:** Das offizielle GitHub-Projekt für Workflow-Automatisierung und -Orchestrierung, lokal installiert und mit OpenClaw integriert.

### 1.2. Oracle Cloud Free Tier VPS (oder ähnlicher 24GB RAM VPS) - Cloud-Native & 24/7 Dienste

Dieser VPS hostet Dienste, die hohe Verfügbarkeit, Skalierbarkeit und 24/7-Betrieb erfordern. Er dient als Cloud-Gateway und Rechenzentrum für bestimmte Aufgaben.

*   **Hardware:** 24GB RAM (Oracle Free Tier)
*   **Dienste:**
    *   **K3s (Kubernetes) Cluster:** Ein leichtgewichtiges Kubernetes-Cluster für die Orchestrierung von Containern.
    *   **Zenbot Trading Bot:** Für automatisierte Krypto-Trading-Operationen, läuft als Kubernetes Deployment.
    *   **OpenManus (Agent):** Ein weiterer KI-Agent für Web-Recherche, Datenanalyse und andere Cloud-basierte Aufgaben, läuft als Kubernetes Deployment.
    *   **Gemini-Ollama Fallback Proxy:** Ein intelligenter Proxy-Dienst, der Anfragen an Google Gemini sendet und bei Fehlern oder Ratenlimits automatisch auf den lokalen Ollama-Dienst auf deinem MiniPC (via Cloudflare Tunnel oder VPN) umschaltet. Läuft als Kubernetes Deployment.

### 1.3. Zusätzliche kostenlose VPS (z.B. Google Cloud Free Tier, AWS Free Tier) - Spezialisierte Dienste

Um die Haupt-VPS zu entlasten und die Ausfallsicherheit zu erhöhen, können weitere kostenlose VPS für spezialisierte, nicht-kritische Dienste genutzt werden.

*   **Dienste:**
    *   **Monitoring:** Grafana und Prometheus für die Überwachung der Systemleistung und Anwendungsmetriken.
    *   **Backup-Dienste:** Automatisierte Backups für kritische Daten (z.B. MongoDB für Zenbot, Home Assistant Konfigurationen).
    *   **Spezialisierte APIs/Dienste:** Bei Bedarf weitere Dienste, die eine hohe Verfügbarkeit erfordern oder geografisch verteilt sein sollen.

---

## 🛠️ 2. Installationsprozess: Interaktiv & Modular

Der Installationsprozess ist interaktiv und modular gestaltet. Du kannst zwischen verschiedenen Setup-Typen und Profilen wählen.

### 2.1. Setup-Typen

*   **Hybrid Setup (MiniPC + Multi-VPS):** Die empfohlene Option, die die Last optimal verteilt und die volle Funktionalität bietet.
*   **Standalone VPS Setup (Cloud-Native):** Installiert alle Cloud-Dienste auf einem einzigen VPS mit K3s.
*   **Standalone MiniPC Setup (Lokal):** Installiert alle lokalen Dienste (Ollama, OpenClaw, Home Assistant, Ruflo) nur auf deinem MiniPC, ohne VPS-Anbindung.

### 2.2. Profile (Installieren & Deinstallieren)

Profile ermöglichen es dir, spezifische Toolsets und Konfigurationen für bestimmte Anwendungsfälle zu installieren. Du kannst mehrere Profile gleichzeitig installieren und bei Bedarf auch wieder deinstallieren.

*   **Programmierer-Setup:** Tools für Entwicklung, Code-Generierung (z.B. DeepSeek Coder Modell für Ollama), Git-Integration.
*   **Media & Musik:** Tools für Audio-Verarbeitung (FFmpeg, Audio-AI), Video-Generierung und Alexa-Integration.
*   **KI-Forschung:** Spezialisierte Bibliotheken und Konfigurationen für OpenClaw RL, erweiterte LLM-Modelle (z.B. Gemini-1.5-Pro).
*   **Texter, Werbung & Marketing:** Tools für Content-Generierung, SEO-Analyse, Social Media Integration und spezialisierte LLM-Modelle für Textproduktion.

### 2.3. Ruflo Integration

Ruflo ist ein leistungsstarkes Workflow-Automatisierungs-Tool von GitHub. Es wird lokal auf deinem MiniPC installiert und kann über OpenClaw gesteuert werden, um komplexe Aufgaben und Automatisierungen zu orchestrieren. Die Installation erfolgt direkt aus den GitHub-Quellen mit `pnpm`.

---

## 🔑 3. API-Keys & Port-Konfiguration

Alle notwendigen API-Keys und die Port-Konfiguration sind im `API_KEY_GUIDE.md` detailliert beschrieben. Es ist entscheidend, dieses Dokument vor der Installation zu lesen, um alle Voraussetzungen zu erfüllen und potenzielle Konflikte zu vermeiden.

---

## ⚠️ 4. Wichtige Hinweise

*   **pnpm:** Alle Node.js-basierten Projekte (wie OpenClaw und Ruflo) werden mit `pnpm` installiert und gebaut, um die Abhängigkeitsverwaltung zu optimieren.
*   **Ollama Modell:** Das Standard-Ollama-Modell ist `llama3.2:1b`, um die Ressourcen deines MiniPCs optimal zu nutzen.
*   **Dynamische IP:** Die Integration von Hurricane Electric für dynamisches DNS ist vorgesehen, um deinen MiniPC auch mit dynamischer IP-Adresse erreichbar zu machen.
*   **Sicherheit:** Achte stets auf die Sicherheit deiner API-Keys und deines Systems. Verwende starke Passwörter und halte deine Systeme aktuell.

---

## ❓ 5. Häufig gestellte Fragen (FAQ)

*   **Kann ich mehrere Profile gleichzeitig installieren?** Ja, die Profile sind so konzipiert, dass sie koexistieren können. Du kannst sie über das Hauptmenü installieren und deinstallieren.
*   **Wie deinstalliere ich ein Profil?** Wähle die entsprechende Option im Hauptmenü. Das Skript wird versuchen, alle vom Profil installierten Komponenten sauber zu entfernen.
*   **Was passiert, wenn ein Port-Konflikt auftritt?** Das `port_check.sh` Skript wird dich warnen. Du musst dann entweder den Konflikt manuell lösen oder die Konfiguration des betroffenen Dienstes anpassen.
*   **Wie aktualisiere ich das Setup?** Führe den `curl`-Befehl erneut aus. Das Skript wird das Repository aktualisieren und dir die Option geben, Komponenten neu zu installieren oder zu aktualisieren.

---

Wir wünschen dir viel Erfolg und Freude mit deinem neuen, leistungsstarken KI- und Smart Home System!
