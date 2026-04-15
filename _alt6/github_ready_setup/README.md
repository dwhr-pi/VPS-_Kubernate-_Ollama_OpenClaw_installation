# VPS-_Kubernate-_Ollama_OpenClaw_installation - Ultimate Setup V4

Dies ist das ultimative Setup für ein hybrides KI- und Smart Home System, das Ihren Letsung MiniPC (WSL2) und mehrere kostenlose VPS kombiniert. Es integriert OpenClaw, Ollama (mit `llama3.2:1b`), Google Gemini, Home Assistant, Alexa Skills, Zenbot Trading Bot und weitere Komponenten, die direkt aus GitHub-Quellen kompiliert werden.

## 🚀 Schnelle Installation (One-Liner)

Um die interaktive Installationsplattform zu starten, führen Sie einfach den folgenden Befehl in Ihrem Terminal aus:

```bash
curl -sSL https://raw.githubusercontent.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/main/install.sh | bash
```

Dieser Befehl lädt das `install.sh` Skript herunter und führt es aus. Das Skript klont dieses Repository und startet das interaktive Setup-Menü, das Sie durch die weiteren Schritte führt.

**Für private Repositories:** Das Skript wird Sie nach einem GitHub Personal Access Token (PAT) fragen. Eine Anleitung zur Erstellung finden Sie in der `docs/PRIVATE_REPO_GUIDE.md`.

## 📖 Dokumentation

Eine detaillierte Anleitung zur Konfiguration, API-Keys, Port-Analyse und den verschiedenen Setup-Optionen finden Sie in der `docs/API_KEY_GUIDE.md` und `docs/setup_guide.md` innerhalb dieses Repositorys.

## 🛠️ Enthaltene Komponenten

*   **OpenClaw:** KI-Agenten-Framework mit Reinforcement Learning (RL) und `gcali` (Google Kalender) Skill.
*   **Ollama:** Lokales LLM-Backend mit `llama3.2:1b` als Fallback für Gemini.
*   **Google Gemini:** Primäres Cloud-LLM.
*   **Home Assistant Core:** Smart Home Automatisierung.
*   **Alexa Skill Integration:** Verbindung zu Alexa über Cloudflare Tunnel.
*   **Zenbot:** Krypto-Trading Bot.
*   **Kubernetes (K3s):** Für VPS-basierte Deployments.
*   **Multi-VPS-Strategie:** Optimierte Ressourcennutzung über mehrere kostenlose VPS.

## ⚙️ Verzeichnisstruktur

```
. # Repository Root
├── install.sh                  # One-Liner Bootstrapper (mit Privat-Repo Support)
├── setup_ultimate_v4.sh        # Interaktives Haupt-Setup-Menü
├── README.md                   # Diese Datei
├── scripts/
│   ├── base_install.sh         # Basis-Installation von System-Abhängigkeiten, pnpm, OpenClaw, Ollama
│   ├── hybrid_setup.sh         # Spezifisches Setup für Letsung MiniPC (WSL2) und Vorbereitung für Multi-VPS
│   ├── vps_standalone.sh       # Spezifisches Setup für reinen VPS (K3s, Kubernetes Deployments)
│   ├── port_check.sh           # Skript zur Überprüfung von Port-Konflikten
│   └── k8s_deployments.yaml    # Kubernetes Deployment-Definitionen für VPS-Dienste
└── docs/
    ├── API_KEY_GUIDE.md        # Detaillierte Anleitung für API-Keys, Ports und Fallback-Routing
    ├── setup_guide.md          # Umfassende Dokumentation des gesamten Setups
    └── PRIVATE_REPO_GUIDE.md   # Anleitung für die Installation aus einem privaten Repository
```

## ⚠️ Wichtige Hinweise

*   **API-Keys:** Werden während der Installation abgefragt oder müssen manuell in Konfigurationsdateien hinterlegt werden.
*   **Ressourcen:** Das Setup ist für eine optimale Verteilung auf einen Letsung MiniPC (16GB RAM / 70GB Disk) und einen Oracle Cloud Free Tier VPS (24GB RAM) sowie weitere kostenlose VPS ausgelegt.
*   **Dynamische IP:** Hurricane Electric wird für die dynamische DNS-Auflösung des MiniPCs verwendet.

Wir wünschen Ihnen viel Erfolg bei der Einrichtung Ihres intelligenten, automatisierten Systems!
