# VPS-_Kubernate-_Ollama_OpenClaw_installation - Ultimate Setup V11

Dies ist das ultimative Setup für ein hybrides KI- und Smart Home System, das deinen Letsung MiniPC (WSL2) und mehrere kostenlose VPS kombiniert. Es integriert eine Vielzahl von Tools und KI-Agenten, die direkt aus GitHub-Quellen kompiliert werden.

## 🚀 Schnelle Installation (One-Liner)

Um die interaktive Installationsplattform zu starten, führe einfach den folgenden Befehl in deinem Terminal aus:

```bash
curl -sSL https://raw.githubusercontent.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/main/install.sh | bash
```

Dieser Befehl lädt das `install.sh` Skript herunter und führt es aus. Das Skript klont dieses Repository und startet das interaktive Setup-Menü, das dich durch die weiteren Schritte führt.

**Für private Repositories:** Das Skript wird dich nach einem GitHub Personal Access Token (PAT) fragen. Eine Anleitung zur Erstellung findest du in der `docs/PRIVATE_REPO_GUIDE.md`.

## 🔄 Setup erneut starten

Wenn du das Setup-Menü erneut starten möchtest, navigiere in das Installationsverzeichnis (standardmäßig `~/openclaw_ultimate_setup`) und führe das Hauptskript aus:

```bash
cd ~/openclaw_ultimate_setup
bash ./setup_ultimate.sh
```

## 📖 Dokumentation

Eine detaillierte Anleitung zur Konfiguration, API-Keys, Port-Analyse und den verschiedenen Setup-Optionen findest du in der `docs/API_KEY_GUIDE.md`, `docs/setup_guide.md` und `docs/DNS_DDoS_GUIDE.md` innerhalb dieses Repositorys.

## 🛠️ Enthaltene Komponenten & Tools

Das Setup bietet eine breite Palette an Tools, die du nach Bedarf installieren und deinstallieren kannst:

*   **Ollama:** Lokales LLM-Backend mit flexiblem Modell-Management (z.B. `llama3.2:1b`, `deepseek-coder`, `mistral`). Dient als leistungsstarke lokale KI-Engine für schnelle und datenschutzsensible Anfragen.
*   **Google Gemini:** Primäres Cloud-LLM mit Fallback zu Ollama. Bietet Zugang zu den neuesten und leistungsstärksten KI-Modellen von Google, mit Ollama als zuverlässiger Notlösung.
*   **OpenManus:** KI-Agenten-Framework für automatisierte Aufgaben. Ermöglicht die Erstellung und Ausführung intelligenter Agenten, die komplexe Aufgaben selbstständig erledigen.
*   **OpenClaw:** KI-Agenten-Framework mit Reinforcement Learning (RL) und Skill-Integration (z.B. `gcali` für Google Kalender). Eine erweiterte Plattform für lernende KI-Agenten, die sich an neue Situationen anpassen können.
*   **Clawhub CLI:** Kommandozeilen-Tool zur Interaktion mit Clawhub-Diensten. Vereinfacht die Verwaltung und Steuerung deiner Clawhub-basierten KI-Dienste über die Kommandozeile.
*   **Clawhub:** Zentraler Server für die Orchestrierung und Verwaltung von KI-Agenten und deren Interaktionen. Bietet eine zentrale Schnittstelle für die Kommunikation und Koordination deiner KI-Agenten.
*   **OpenClaw RL:** Reinforcement Learning Erweiterung für OpenClaw, ermöglicht dem Agenten das Lernen durch Interaktion. Verbessert die Adaptionsfähigkeit und Entscheidungsfindung deiner KI-Agenten.
*   **Clawbake:** Tool zur Automatisierung von Builds und Deployments. Beschleunigt die Entwicklung und Bereitstellung von Softwareprojekten durch automatisierte Prozesse.
*   **n8n:** Workflow-Automatisierungstool, das viele Apps und Dienste verbindet. Ermöglicht die visuelle Erstellung komplexer Automatisierungen und Integrationen ohne Code.
*   **Activepieces:** Open-Source-Alternative zu Zapier für Workflow-Automatisierung. Eine flexible Plattform zur Automatisierung von Aufgaben und zur Verbindung verschiedener Anwendungen.
*   **Flowise / LangFlow:** Open-Source-UIs für LLM-Anwendungen, basierend auf LangchainJS, zur visuellen Erstellung von LLM-Workflows. Ermöglicht die einfache Gestaltung und das Testen von KI-Anwendungen durch Drag-and-Drop-Oberflächen.
*   **Pipedream:** Serverless-Plattform zur Integration von APIs und Diensten (Self-Hosted Option). Ideal für die schnelle Entwicklung und Bereitstellung von Backend-Logik und Integrationen.
*   **Huginn:** Open-Source-Agentensystem, das Aktionen im Web automatisiert (ideal für Programmierer-Profil). Ermöglicht das Sammeln, Filtern und Reagieren auf Informationen aus dem Internet.
*   **Zenbot-trader:** Plattform für automatisierten Krypto-Handel. Ein leistungsstarkes Tool für algorithmischen Handel auf verschiedenen Kryptowährungsbörsen.
*   **Kimi 2:** KI-Agent von Moonshot AI für intelligente Interaktionen und Aufgaben. Ein fortschrittlicher KI-Assistent, der komplexe Anfragen verstehen und bearbeiten kann.
*   **Hugging Face:** Integration von Hugging Face Modellen, entweder lokal über Ollama oder über die Hugging Face Inference API. Ermöglicht den Zugriff auf eine riesige Bibliothek von vortrainierten KI-Modellen.
*   **Home Assistant Core:** Smart Home Automatisierung. Die zentrale Steuerung für dein Smart Home, die eine Vielzahl von Geräten und Diensten integriert.
*   **Alexa Skill Integration:** Verbindung zu Alexa über Cloudflare Tunnel. Ermöglicht die Sprachsteuerung deiner Smart-Home-Geräte und KI-Agenten über Amazon Alexa.
*   **Kubernetes (K3s):** Für VPS-basierte Deployments. Eine leichtgewichtige Kubernetes-Distribution für die Orchestrierung von Containern auf deinen VPS.
*   **Ruflo:** GitHub-Workflow-Automatisierung und -Orchestrierung. Optimiert die Entwicklungsprozesse durch automatisierte Workflows und CI/CD-Pipelines.
*   **Multi-VPS-Strategie:** Optimierte Ressourcennutzung über mehrere kostenlose VPS. Eine Strategie zur Verteilung der Last und Erhöhung der Ausfallsicherheit durch Nutzung mehrerer Cloud-Anbieter.

## 👤 Profil-Management

Das Setup unterstützt die Installation und Deinstallation verschiedener Profile über eine interaktive Checkliste. Du kannst mehrere Profile gleichzeitig installieren und verwalten.

*   **Programmierer-Setup:** Enthält Tools für Entwicklung, Code-Generierung (z.B. DeepSeek Coder Modell für Ollama), Git-Integration und Huginn. Ideal für Entwickler, die ihre Produktivität mit KI-Unterstützung steigern möchten.
*   **Media & Musik:** Beinhaltet Tools für Audio-Verarbeitung (FFmpeg, Audio-AI), Video-Generierung und die Alexa-Integration. Perfekt für Kreative, die KI zur Erstellung und Bearbeitung von Medieninhalten nutzen wollen.
*   **KI-Forschung:** Umfasst spezialisierte Bibliotheken und Konfigurationen für OpenClaw RL und erweiterte LLM-Modelle (z.B. Gemini-1.5-Pro). Für Forscher und Enthusiasten, die an der Entwicklung und dem Training von KI-Modellen arbeiten.
*   **Texter, Werbung & Marketing:** Stellt Tools für Content-Generierung, SEO-Analyse, Social Media Integration und spezialisierte LLM-Modelle für Textproduktion bereit. Optimiert für Marketingexperten und Texter, die ihre Inhalte mit KI verbessern möchten.
*   **Rechtsberatung & Steuerrecht:** Tools für Web-Search & Fetch, PDF-Reader/Document-Parser, Zotero. Für die Analyse von Rechtsdokumenten und Steuerrecht, unterstützt durch spezialisierte KI-Agenten.

## ⚙️ Verzeichnisstruktur

```
. # Repository Root
├── install.sh                  # One-Liner Bootstrapper (mit Privat-Repo Support)
├── setup_ultimate.sh           # Interaktives Haupt-Setup-Menü
├── README.md                   # Diese Datei
├── scripts/
│   ├── auto_update.sh          # Skript für System- und pnpm-Updates
│   ├── ollama_model_manager.sh # Skript für Ollama Modell-Management
│   ├── openclaw_config_manager.sh # Skript für OpenClaw Konfigurationsverwaltung
│   ├── base_install.sh         # Basis-Installation von System-Abhängigkeiten, pnpm
│   ├── hybrid_setup.sh         # Spezifisches Setup für Letsung MiniPC (WSL2) und Vorbereitung für Multi-VPS
│   ├── vps_standalone.sh       # Spezifisches Setup für reinen VPS (K3s, Kubernetes Deployments)
│   ├── install_local_only.sh   # Spezifisches Setup für reinen MiniPC (Lokal)
│   ├── ruflo_install.sh        # Skript für Ruflo Installation & Management
│   ├── port_check.sh           # Skript zur Überprüfung von Port-Konflikten
│   ├── k8s_deployments.yaml    # Kubernetes Deployment-Definitionen für VPS-Dienste
│   ├── config_templates/       # Verzeichnis für Konfigurationsvorlagen
│   │   └── openclaw/
│   │       ├── .env.template
│   │       └── config.json.template
│   └── tools/                  # Verzeichnis für Tool-Installations-/Deinstallationsskripte
│       ├── openmanus_install.sh
│       ├── openmanus_uninstall.sh
│       ├── openclaw_install.sh
│       ├── openclaw_uninstall.sh
│       ├── clawhub_cli_install.sh
│       ├── clawhub_cli_uninstall.sh
│       ├── clawhub_install.sh
│       ├── clawhub_uninstall.sh
│       ├── openclaw_rl_install.sh
│       ├── openclaw_rl_uninstall.sh
│       ├── clawbake_install.sh
│       ├── clawbake_uninstall.sh
│       ├── n8n_install.sh
│       ├── n8n_uninstall.sh
│       ├── activepieces_install.sh
│       ├── activepieces_uninstall.sh
│       ├── flowise_install.sh
│       ├── flowise_uninstall.sh
│       ├── langflow_install.sh
│       ├── langflow_uninstall.sh
│       ├── pipedream_install.sh
│       ├── pipedream_uninstall.sh
│       ├── huginn_install.sh
│       ├── huginn_uninstall.sh
│       ├── zenbot_trader_install.sh
│       ├── zenbot_trader_uninstall.sh
│       ├── kimi2_install.sh
│       ├── kimi2_uninstall.sh
│       ├── huge_facing_install.sh
│       └── huge_facing_uninstall.sh
│   └── profiles/               # Verzeichnis für Profil-Installations-/Deinstallationsskripte
│       ├── Programmierer_install.sh
│       ├── Programmierer_uninstall.sh
│       ├── Media_Musik_install.sh
│       ├── Media_Musik_uninstall.sh
│       ├── KI_Forschung_install.sh
│       ├── KI_Forschung_uninstall.sh
│       ├── Texter_Werbung_Marketing_install.sh
│       ├── Texter_Werbung_Marketing_uninstall.sh
│       ├── Rechtsberatung_Steuerrecht_install.sh
│       └── Rechtsberatung_Steuerrecht_uninstall.sh
├── docs/
│   ├── API_KEY_GUIDE.md        # Detaillierte Anleitung für API-Keys, Ports und Fallback-Routing
│   ├── setup_guide.md          # Umfassende Dokumentation des gesamten Setups
│   ├── PRIVATE_REPO_GUIDE.md   # Anleitung für die Installation aus einem privaten Repository
│   └── DNS_DDoS_GUIDE.md       # Anleitung zur DNS-Umstellung und DDoS-Schutz
└── installed_profiles.txt      # Liste der aktuell installierten Profile
└── installed_tools.txt         # Liste der aktuell installierten Tools
```

## ⚠️ Wichtige Hinweise

*   **API-Keys:** Werden während der Installation abgefragt oder müssen manuell in Konfigurationsdateien hinterlegt werden. Nutze den OpenClaw Konfigurations-Manager für die `.env` und `config.json`.
*   **Ressourcen:** Das Setup ist für eine optimale Verteilung auf einen Letsung MiniPC (16GB RAM / 70GB Disk) und einen Oracle Cloud Free Tier VPS (24GB RAM) sowie weitere kostenlose VPS ausgelegt.
*   **Dynamische IP:** Hurricane Electric wird für die dynamische DNS-Auflösung des MiniPCs verwendet. Eine detaillierte Anleitung zur Umstellung und zum DDoS-Schutz findest du in `docs/DNS_DDoS_GUIDE.md`.

Wir wünschen dir viel Erfolg bei der Einrichtung deines intelligenten, automatisierten Systems!
