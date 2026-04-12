# VPS-_Kubernate-_Ollama_OpenClaw_installation - Ultimate Setup V5

Dies ist das ultimative Setup für ein hybrides KI- und Smart Home System, das deinen Letsung MiniPC (WSL2) und mehrere kostenlose VPS kombiniert. Es integriert OpenClaw, Ollama (mit `llama3.2:1b`), Google Gemini, Home Assistant, Alexa Skills, Zenbot Trading Bot, Ruflo und weitere Komponenten, die direkt aus GitHub-Quellen kompiliert werden.

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
./setup_ultimate_v5.sh
```

## 📖 Dokumentation

Eine detaillierte Anleitung zur Konfiguration, API-Keys, Port-Analyse und den verschiedenen Setup-Optionen findest du in der `docs/API_KEY_GUIDE.md` und `docs/setup_guide.md` innerhalb dieses Repositorys.

## 🛠️ Enthaltene Komponenten

*   **OpenClaw:** KI-Agenten-Framework mit Reinforcement Learning (RL) und `gcali` (Google Kalender) Skill.
*   **Ollama:** Lokales LLM-Backend mit `llama3.2:1b` als Fallback für Gemini.
*   **Google Gemini:** Primäres Cloud-LLM.
*   **Home Assistant Core:** Smart Home Automatisierung.
*   **Alexa Skill Integration:** Verbindung zu Alexa über Cloudflare Tunnel.
*   **Zenbot:** Krypto-Trading Bot.
*   **Kubernetes (K3s):** Für VPS-basierte Deployments.
*   **Ruflo:** GitHub-Workflow-Automatisierung und -Orchestrierung.
*   **Multi-VPS-Strategie:** Optimierte Ressourcennutzung über mehrere kostenlose VPS.

## ⚙️ Verzeichnisstruktur

```
. # Repository Root
├── install.sh                  # One-Liner Bootstrapper (mit Privat-Repo Support)
├── setup_ultimate_v5.sh        # Interaktives Haupt-Setup-Menü
├── README.md                   # Diese Datei
├── scripts/
│   ├── base_install.sh         # Basis-Installation von System-Abhängigkeiten, pnpm, OpenClaw, Ollama
│   ├── hybrid_setup.sh         # Spezifisches Setup für Letsung MiniPC (WSL2) und Vorbereitung für Multi-VPS
│   ├── vps_standalone.sh       # Spezifisches Setup für reinen VPS (K3s, Kubernetes Deployments)
│   ├── install_local_only.sh   # Spezifisches Setup für reinen MiniPC (Lokal)
│   ├── ruflo_install.sh        # Skript für Ruflo Installation & Management
│   ├── port_check.sh           # Skript zur Überprüfung von Port-Konflikten
│   └── k8s_deployments.yaml    # Kubernetes Deployment-Definitionen für VPS-Dienste
├── scripts/
│   └─ profiles/
│      ├── KI_Forschung_install.sh               # Spezifisches Setup für "KI Forschung"
│      ├── KI_Forschung_uninstall.sh             # Spezifisches Deinstallation für "KI Forschung"
│      ├── Media_Musik_install.sh                # Spezifisches Setup für "Media Musik"
│      ├── Media_Musik_uninstall.sh              # Spezifisches Deinstallation für "Media Musik"
│      ├── Programmierer_install.sh              # Spezifisches Setup für "Programmierer"
│      ├── Programmierer_uninstall.sh            # Spezifisches Deinstallation für "Programmierer"
│      ├── Texter_Werbung_Marketing_install.sh   # Spezifisches Setup für "Texter Werbung Marketing"
│      └── Texter_Werbung_Marketing_uninstall.sh # Spezifisches Deinstallation für "Texter Werbung Marketing"
└── docs/
    ├── API_KEY_GUIDE.md        # Detaillierte Anleitung für API-Keys, Ports und Fallback-Routing
    ├── setup_guide.md          # Umfassende Dokumentation des gesamten Setups
    └── PRIVATE_REPO_GUIDE.md   # Anleitung für die Installation aus einem privaten Repository
```

## 👤 Profil-Management

Das Setup unterstützt die Installation und Deinstallation verschiedener Profile. Du kannst mehrere Profile gleichzeitig installieren.

*   **Programmierer-Setup:** Tools für Entwicklung, Code-Generierung (z.B. DeepSeek Coder Modell für Ollama), Git-Integration.
*   **Media & Musik:** Tools für Audio-Verarbeitung (FFmpeg, Audio-AI), Video-Generierung und Alexa-Integration.
*   **KI-Forschung:** Spezialisierte Bibliotheken und Konfigurationen für OpenClaw RL, erweiterte LLM-Modelle (z.B. Gemini-1.5-Pro).
*   **Texter, Werbung & Marketing:** Tools für Content-Generierung, SEO-Analyse, Social Media Integration und spezialisierte LLM-Modelle für Textproduktion.

## ⚠️ Wichtige Hinweise

*   **API-Keys:** Werden während der Installation abgefragt oder müssen manuell in Konfigurationsdateien hinterlegt werden.
*   **Ressourcen:** Das Setup ist für eine optimale Verteilung auf einen Letsung MiniPC (16GB RAM / 70GB Disk) und einen Oracle Cloud Free Tier VPS (24GB RAM) sowie weitere kostenlose VPS ausgelegt.
*   **Dynamische IP:** Hurricane Electric wird für die dynamische DNS-Auflösung des MiniPCs verwendet.

Wir wünschen dir viel Erfolg bei der Einrichtung deines intelligenten, automatisierten Systems!
