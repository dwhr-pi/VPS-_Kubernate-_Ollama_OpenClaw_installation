# VPS-_Kubernate-_Ollama_OpenClaw_installation - Ultimate Setup V7

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
./setup_ultimate_v7.sh
```

## 📖 Dokumentation

Eine detaillierte Anleitung zur Konfiguration, API-Keys, Port-Analyse und den verschiedenen Setup-Optionen findest du in der `docs/API_KEY_GUIDE.md` und `docs/setup_guide.md` innerhalb dieses Repositorys.

## 🛠️ Enthaltene Komponenten & Tools

Das Setup bietet eine breite Palette an Tools, die du nach Bedarf installieren und deinstallieren kannst:

*   **Ollama:** Lokales LLM-Backend mit flexiblem Modell-Management (z.B. `llama3.2:1b`, `deepseek-coder`, `mistral`).
*   **Google Gemini:** Primäres Cloud-LLM mit Fallback zu Ollama.
*   **OpenManus:** KI-Agenten-Framework für automatisierte Aufgaben.
*   **OpenClaw:** KI-Agenten-Framework mit Reinforcement Learning (RL) und Skill-Integration (z.B. `gcali` für Google Kalender).
*   **Clawhub CLI:** Kommandozeilen-Tool zur Interaktion mit Clawhub-Diensten.
*   **Clawbake:** Tool zur Automatisierung von Builds und Deployments.
*   **n8n:** Workflow-Automatisierungstool, das viele Apps und Dienste verbindet.
*   **Activepieces:** Open-Source-Alternative zu Zapier für Workflow-Automatisierung.
*   **Flowise / LangFlow:** Open-Source-UIs für LLM-Anwendungen, basierend auf LangchainJS, zur visuellen Erstellung von LLM-Workflows.
*   **Pipedream:** Serverless-Plattform zur Integration von APIs und Diensten (Self-Hosted Option).
*   **Huginn:** Open-Source-Agentensystem, das Aktionen im Web automatisiert (ideal für Programmierer-Profil).
*   **Zenbot-trader:** Plattform für automatisierten Krypto-Handel.
*   **Home Assistant Core:** Smart Home Automatisierung.
*   **Alexa Skill Integration:** Verbindung zu Alexa über Cloudflare Tunnel.
*   **Kubernetes (K3s):** Für VPS-basierte Deployments.
*   **Ruflo:** GitHub-Workflow-Automatisierung und -Orchestrierung.
*   **Multi-VPS-Strategie:** Optimierte Ressourcennutzung über mehrere kostenlose VPS.

## 👤 Profil-Management

Das Setup unterstützt die Installation und Deinstallation verschiedener Profile über eine interaktive Checkliste. Du kannst mehrere Profile gleichzeitig installieren und verwalten.

*   **Programmierer-Setup:** Tools für Entwicklung, Code-Generierung (z.B. DeepSeek Coder Modell für Ollama), Git-Integration, Huginn.
*   **Media & Musik:** Tools für Audio-Verarbeitung (FFmpeg, Audio-AI), Video-Generierung und Alexa-Integration.
*   **KI-Forschung:** Spezialisierte Bibliotheken und Konfigurationen für OpenClaw RL, erweiterte LLM-Modelle (z.B. Gemini-1.5-Pro).
*   **Texter, Werbung & Marketing:** Tools für Content-Generierung, SEO-Analyse, Social Media Integration und spezialisierte LLM-Modelle für Textproduktion.

## ⚙️ Verzeichnisstruktur

```
. # Repository Root
├── install.sh                  # One-Liner Bootstrapper (mit Privat-Repo Support)
├── setup_ultimate_v7.sh        # Interaktives Haupt-Setup-Menü
├── README.md                   # Diese Datei
├── scripts/
│   ├── auto_update.sh          # Skript für System- und pnpm-Updates
│   ├── ollama_model_manager.sh # Skript für Ollama Modell-Management
│   ├── base_install.sh         # Basis-Installation von System-Abhängigkeiten, pnpm
│   ├── hybrid_setup.sh         # Spezifisches Setup für Letsung MiniPC (WSL2) und Vorbereitung für Multi-VPS
│   ├── vps_standalone.sh       # Spezifisches Setup für reinen VPS (K3s, Kubernetes Deployments)
│   ├── install_local_only.sh   # Spezifisches Setup für reinen MiniPC (Lokal)
│   ├── ruflo_install.sh        # Skript für Ruflo Installation & Management
│   ├── port_check.sh           # Skript zur Überprüfung von Port-Konflikten
│   ├── k8s_deployments.yaml    # Kubernetes Deployment-Definitionen für VPS-Dienste
│   └── tools/                  # Verzeichnis für Tool-Installations-/Deinstallationsskripte
│       ├── openmanus_install.sh
│       ├── openmanus_uninstall.sh
│       ├── openclaw_install.sh
│       ├── openclaw_uninstall.sh
│       ├── clawhub_cli_install.sh
│       ├── clawhub_cli_uninstall.sh
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
│       └── zenbot_trader_uninstall.sh
│   └── profiles/               # Verzeichnis für Profil-Installations-/Deinstallationsskripte
│       ├── Programmierer_install.sh
│       ├── Programmierer_uninstall.sh
│       ├── Media_Musik_install.sh
│       ├── Media_Musik_uninstall.sh
│       ├── KI_Forschung_install.sh
│       ├── KI_Forschung_uninstall.sh
│       ├── Texter_Werbung_Marketing_install.sh
│       └── Texter_Werbung_Marketing_uninstall.sh
├── docs/
│   ├── API_KEY_GUIDE.md        # Detaillierte Anleitung für API-Keys, Ports und Fallback-Routing
│   ├── setup_guide.md          # Umfassende Dokumentation des gesamten Setups
│   └── PRIVATE_REPO_GUIDE.md   # Anleitung für die Installation aus einem privaten Repository
└── installed_profiles.txt      # Liste der aktuell installierten Profile
└── installed_tools.txt         # Liste der aktuell installierten Tools
```

## ⚠️ Wichtige Hinweise

*   **API-Keys:** Werden während der Installation abgefragt oder müssen manuell in Konfigurationsdateien hinterlegt werden.
*   **Ressourcen:** Das Setup ist für eine optimale Verteilung auf einen Letsung MiniPC (16GB RAM / 70GB Disk) und einen Oracle Cloud Free Tier VPS (24GB RAM) sowie weitere kostenlose VPS ausgelegt.
*   **Dynamische IP:** Hurricane Electric wird für die dynamische DNS-Auflösung des MiniPCs verwendet.

Wir wünschen dir viel Erfolg bei der Einrichtung deines intelligenten, automatisierten Systems!
