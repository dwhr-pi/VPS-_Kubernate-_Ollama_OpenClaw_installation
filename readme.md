# VPS- Kubernate- Ollama & OpenClaw installation - Ultimate Setup V11.06

Dies ist das ultimative Setup für ein hybrides KI- und Smart Home System, das deinen Letsung MiniPC (WSL2) und mehrere kostenlose VPS kombiniert. Es integriert eine Vielzahl von Tools und KI-Agenten, die direkt aus GitHub-Quellen kompiliert werden.

## 🚀 Schnelle Installation (One-Liner)

Um die interaktive Installationsplattform zu starten, führe einfach den folgenden Befehl in deinem Terminal aus:

```bash
cd ~
curl -sSL https://raw.githubusercontent.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/main/install.sh | bash
```

Dieser Befehl lädt das `install.sh` Skript herunter und führt es aus. Das Skript klont dieses Repository und startet das interaktive Setup-Menü, das dich durch die weiteren Schritte führt.

**Wichtig für Einsteiger:** Während der Installation wirst du mehrfach nach einem Passwort gefragt. Gemeint ist dabei das `sudo`-Passwort deines Linux-Benutzers, also das Passwort des Ubuntu-/Linux-Users innerhalb von WSL oder auf deinem Server.

**Sprachauswahl schon beim ersten Start:** Noch vor der Frage nach einem privaten GitHub-Repository kannst du jetzt bereits die Setup-Sprache festlegen. Diese Auswahl wird ausgelagert gespeichert und bei späteren Starts wiederverwendet.

**Für private Repositories:** Das Skript wird dich nach einem GitHub Personal Access Token (PAT) fragen. Eine Anleitung zur Erstellung findest du in der `docs/PRIVATE_REPO_GUIDE.md`.

**Für die OpenClaw `.env`:** Eine eigene Detaildokumentation zur `.env`-Struktur, zu den Feldern und zur originalen OpenClaw-Vorlage findest du in [docs/OPENCLAW_ENV_GUIDE.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/OPENCLAW_ENV_GUIDE.md:1).

**Wichtig für sensible Daten:** Bearbeitbare und sensible Dateien werden ab den neueren Setup-Versionen zusätzlich außerhalb des Repositories in `~/.openclaw_ultimate_user_data` abgelegt. Dadurch bleiben API-Keys, bearbeitete Vorlagen und Statusdateien beim Repo-Update sauber getrennt und werden nicht versehentlich ins Git-Repository geschrieben.

Dazu gehören jetzt insbesondere:

- OpenClaw-`.env`- und `config.json`-Vorlagen
- Statusdateien für installierte Tools und Profile
- editierbare Installations-Messwerte
- ausgelagerte Sprachvorgaben in `~/.openclaw_ultimate_user_data/setup_preferences.conf`
- Profil-Quellen aus `docs/Profil`
- abgeleitete Profilseiten aus `docs/Profile`
- ein separater Bereich für künftige Benutzer-Prompts

## 🔐 Sicherheit bei der Nutzung

Dieses Setup trennt ab den neueren Versionen bewusst zwischen:

- dem eigentlichen Git-Repository
- und deinem persönlichen Benutzer-Workspace unter `~/.openclaw_ultimate_user_data`

Das ist wichtig, weil dort typischerweise sensible Inhalte liegen können:

- API-Keys
- bearbeitete `.env`-Dateien
- Zugangsdaten
- Statusdateien
- angepasste Konfigurationsvorlagen

Darauf solltest du achten:

- Niemals echte Secrets in Git committen oder auf GitHub hochladen.
- Bearbeite sensible Vorlagen möglichst nur über den ausgelagerten Benutzer-Workspace.
- Sichere deine `.env` lokal zusätzlich, wenn du wichtige API-Keys eingetragen hast.
- Wenn du den Rechner oder die WSL weitergibst, lösche den Benutzer-Workspace gezielt mit.
- Wenn du einen öffentlichen Host, VPS oder `0.0.0.0` nutzt, setze immer sichere Tokens und Passwörter.

Wichtig:

- Das Entfernen von `~/openclaw_ultimate_setup` löscht nicht automatisch deinen ausgelagerten Benutzer-Workspace.
- Das ist Absicht, damit persönliche Daten und bearbeitete Vorlagen beim Repo-Update oder Neu-Klonen nicht verloren gehen.
- Wenn du wirklich alles entfernen möchtest, lösche zusätzlich:

```bash
rm -rf ~/.openclaw_ultimate_user_data
```

## 🔄 Setup erneut starten

Wenn du das Setup-Menü erneut starten möchtest, navigiere in das Installationsverzeichnis (standardmäßig `~/openclaw_ultimate_setup`) und führe das Hauptskript aus:

```bash
cd ~/openclaw_ultimate_setup
bash ./setup_ultimate.sh
```

## 🔁 Setup aktualisieren oder lokal entfernen

Wenn es Änderungen im Repository gab und du dein bestehendes Setup aktualisieren möchtest, ziehe zuerst den aktuellen Stand und starte danach das Menü erneut:

```bash
cd ~/openclaw_ultimate_setup
git fetch origin --prune
git checkout main 2>/dev/null || git checkout -b main --track origin/main
git pull --ff-only origin main
bash ./setup_ultimate.sh
```

Wenn dabei eine Meldung zu lokalen Änderungen in Dateien wie `install.sh` oder `setup_ultimate.sh` erscheint, dann blockiert nicht GitHub das Update, sondern dein lokales Setup-Repository ist nicht mehr sauber. Das kann auch schon durch ältere Teststände oder frühere lokale Dateien passieren, selbst wenn du selbst nichts bewusst bearbeitet hast.

In diesem Fall gibt es jetzt zwei sichere Wege:

- im Menü den Punkt `Setup hart mit GitHub main abgleichen` verwenden
- oder den One-Liner-Installer erneut starten und den angebotenen harten Repo-Abgleich bestätigen

Wichtig dabei:

- Es werden nur Dateien im Setup-Repository zurückgesetzt.
- Dein ausgelagerter Benutzer-Workspace unter `~/.openclaw_ultimate_user_data` bleibt erhalten.
- Vor dem harten Abgleich legt der Installer jetzt zusätzlich eine Sicherung des Repo-Zustands unter `~/.openclaw_ultimate_user_data/repo_update_backups` an.

Alternativ kannst du im Menü den Punkt `Setup-Update + System-Update (Repo, OS & pnpm)` nutzen. Dieser zieht den aktuellen Repository-Stand direkt im Setup-Verzeichnis und aktualisiert danach Ubuntu sowie `pnpm`.

Wenn danach trotzdem noch ein älterer Setup-Stand angezeigt wird, liegen im Verzeichnis oft noch lokale Änderungen oder Zusatzdateien. Dann zieht `git pull` absichtlich nicht einfach darüber.

Prüfen:

```bash
cd ~/openclaw_ultimate_setup
git status
```

Wenn du sicher bist, dass lokale Setup-Änderungen verworfen werden dürfen, kannst du das Setup hart auf den aktuellen GitHub-Stand zurücksetzen:

```bash
cd ~/openclaw_ultimate_setup
git fetch origin --prune
git reset --hard origin/main
bash ./setup_ultimate.sh
```

Dafür gibt es jetzt auch direkt im Menü einen eigenen Punkt:

- `Setup hart mit GitHub main abgleichen`

Dieser Weg ist hilfreich, wenn trotz normalem `git pull` noch ein älterer Setup-Stand angezeigt wird.

Wenn du ganz sauber neu anfangen willst, ist auch das weiterhin möglich:

```bash
cd ~
rm -rf ~/openclaw_ultimate_setup
curl -sSL https://raw.githubusercontent.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/main/install.sh | bash
```

Wenn du das lokale Setup wieder entfernen möchtest, hast du zwei saubere Wege:

1. Zuerst im Menü `Tools: Installieren & Deinstallieren` und `Profile: Installieren & Deinstallieren` alle gewünschten Komponenten wieder abwählen.
2. Danach das lokale Arbeitsverzeichnis entfernen:

```bash
cd ~
rm -rf ~/openclaw_ultimate_setup
```

Wenn du zusätzlich lokal installierte Komponenten wie `Home Assistant`, `Ollama` oder einzelne Tools vollständig entfernen willst, nutze die jeweiligen `*_uninstall.sh` Skripte im Menü oder direkt unter `scripts/tools/`.

Wenn du zusätzlich den ausgelagerten Benutzer-Workspace mit sensiblen Daten entfernen möchtest, kannst du das entweder im Menü über `Benutzer-Workspace verwalten` tun oder manuell:

```bash
rm -rf ~/.openclaw_ultimate_user_data
```

## 📖 Dokumentation

Eine detaillierte Anleitung zur Konfiguration, API-Keys, Port-Analyse und den verschiedenen Setup-Optionen findest du in der `docs/API_KEY_GUIDE.md`, `docs/setup_guide.md`, `docs/DNS_DDoS_GUIDE.md` und [docs/OPENCLAW_ENV_GUIDE.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/OPENCLAW_ENV_GUIDE.md:1) innerhalb dieses Repositorys.

Zusätzliche Hilfen:

*   `docs/CLOUDFLARE_TUNNEL_GUIDE.md` erklärt Schritt für Schritt, wie du den benötigten Cloudflare-Tunnel und Token anlegst.
*   `docs/WSL_SETUP_GUIDE.md` erklärt WSL unter Windows, Ubuntu-24.04 bzw. andere Linux-Distributionen, sowie Deinstallation und komplettes Zurücksetzen.
*   `docs/INSTALLATION_BENCHMARKS.md` beschreibt die editierbaren Installations-Schätzwerte und verweist auf `~/.openclaw_ultimate_user_data/setup_metrics.conf`.
*   sensible und bearbeitbare Setup-Dateien liegen jetzt außerhalb des Repos in `~/.openclaw_ultimate_user_data`.
*   über `Benutzer-Workspace verwalten` kannst du diese ausgelagerten Dateien anzeigen, neu aus dem Repo kopieren oder vollständig löschen.
*   das Setup zeichnet für wichtige Vorgänge jetzt zusätzlich reale Messwerte in `~/.openclaw_ultimate_user_data/metrics_logs/operation_history.tsv` auf.

Zusätzlich gibt es zwei Profil-Verzeichnisse:

*   `docs/Profil/` enthält die fachlichen Quelltexte und Prompt-Sammlungen je Profil.
*   `docs/Profile/` enthält die daraus abgeleiteten, repo-spezifischen Profilseiten mit tatsächlichem Setup-Stand, installierbaren Tools und OpenClaw-/Ollama-Fit.

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
*   **AutoGPT:** Agenten-Plattform von Significant Gravitas zum Erstellen, Starten und Verwalten komplexer KI-Workflows. Kann lokal per Docker Compose betrieben werden.
*   **Pipedream:** Serverless-Plattform zur Integration von APIs und Diensten (Self-Hosted Option). Ideal für die schnelle Entwicklung und Bereitstellung von Backend-Logik und Integrationen.
*   **Huginn:** Open-Source-Agentensystem, das Aktionen im Web automatisiert (ideal für Programmierer-Profil). Ermöglicht das Sammeln, Filtern und Reagieren auf Informationen aus dem Internet.
*   **FFmpeg:** CLI-Werkzeug für Audio- und Videoverarbeitung. Unterstützt Medienprofile bei Konvertierung, Extraktion und Transcoding.
*   **Zenbot-trader:** Plattform für automatisierten Krypto-Handel. Ein leistungsstarkes Tool für algorithmischen Handel auf verschiedenen Kryptowährungsbörsen.
*   **Kimi 2:** KI-Agent von Moonshot AI für intelligente Interaktionen und Aufgaben. Ein fortschrittlicher KI-Assistent, der komplexe Anfragen verstehen und bearbeiten kann.
*   **Hugging Face:** Integration von Hugging Face Modellen, entweder lokal über Ollama oder über die Hugging Face Inference API. Ermöglicht den Zugriff auf eine riesige Bibliothek von vortrainierten KI-Modellen.
*   **Zotero:** Literatur- und Quellenverwaltung für Recherche- und Dokumentations-Workflows, besonders relevant für Rechts- und Wissensprofile.
*   **Home Assistant Core:** Smart Home Automatisierung. Die zentrale Steuerung für dein Smart Home, die eine Vielzahl von Geräten und Diensten integriert.
*   **Alexa Skill Integration:** Verbindung zu Alexa über Cloudflare Tunnel. Ermöglicht die Sprachsteuerung deiner Smart-Home-Geräte und KI-Agenten über Amazon Alexa.
*   **Kubernetes (K3s):** Grundlage für VPS-basierte Deployments. Das Setup bereitet einen VPS mit K3s, `kubectl` und einer sauberen Verzeichnisstruktur für nachfolgende Kubernetes-Manifeste vor.
*   **Ruflo:** Multi-Agenten- und Automatisierungsplattform mit CLI. Das Setup installiert Ruflo aus GitHub, stellt Node.js und `pnpm` bereit und verlinkt die CLI für lokale Nutzung.
*   **Multi-VPS-Strategie:** Optimierte Ressourcennutzung über mehrere kostenlose VPS. Eine Strategie zur Verteilung der Last und Erhöhung der Ausfallsicherheit durch Nutzung mehrerer Cloud-Anbieter.

## 👤 Profil-Management

Das Setup unterstützt die Installation und Deinstallation verschiedener Profile über eine interaktive Checkliste. Du kannst mehrere Profile gleichzeitig installieren und verwalten.

Neu dazu kommt eine Blockansicht im Menü:

*   komplette Profile schnell auswählen
*   Profilblöcke öffnen
*   Kernmodule, erweiterte Module und Integrationen getrennt anzeigen
*   einzelne Tools innerhalb eines Profils gezielt an- oder abwählen

*   **Programmierer-Setup:** Enthält Tools für Entwicklung, Code-Generierung (z.B. DeepSeek Coder Modell für Ollama), Git-Integration und Huginn. Ideal für Entwickler, die ihre Produktivität mit KI-Unterstützung steigern möchten.
*   **Media & Musik:** Beinhaltet Tools für Audio-Verarbeitung (FFmpeg, Audio-AI), Video-Generierung und die Alexa-Integration. Perfekt für Kreative, die KI zur Erstellung und Bearbeitung von Medieninhalten nutzen wollen.
*   **KI-Forschung:** Umfasst spezialisierte Bibliotheken und Konfigurationen für OpenClaw RL und erweiterte LLM-Modelle (z.B. Gemini-1.5-Pro). Für Forscher und Enthusiasten, die an der Entwicklung und dem Training von KI-Modellen arbeiten.
*   **Texter, Werbung & Marketing:** Stellt Tools für Content-Generierung, SEO-Analyse, Social Media Integration und spezialisierte LLM-Modelle für Textproduktion bereit. Optimiert für Marketingexperten und Texter, die ihre Inhalte mit KI verbessern möchten.
*   **Rechtsberatung & Steuerrecht:** Tools für Web-Search & Fetch, PDF-Reader/Document-Parser, Zotero. Für die Analyse von Rechtsdokumenten und Steuerrecht, unterstützt durch spezialisierte KI-Agenten.
*   **Agent Orchestrator:** Profil für Aufgabenzerlegung, Mehragenten-Routing und Ergebnis-Synchronisierung mit LangGraph, CrewAI, AutoGen und Memory-Bausteinen.
*   **Audio:** Sprach- und Audioprofil mit Whisper, FFmpeg, Piper, Coqui TTS, librosa und pydub.
*   **Content Automation:** Profil für automatisierte Content-Pipelines von Skript über Voiceover und Videoschnitt bis zum Upload.
*   **Research Agent:** Rechercheprofil für Repository-Analyse, Dokumentationsauswertung und Setup-Verbesserungen.
*   **Security Analyst:** Security- und Hardening-Profil mit Scan- und Prüfwerkzeugen wie Nmap, Nikto, Trivy und Fail2Ban.
*   **Trading AI:** Profil für Marktanalyse, Bot-gestützte Strategietests und Trading-Integrationen.
*   **Visual Creator:** Kreativprofil für Bild-, Video- und Asset-Pipelines mit Stable Diffusion WebUI, ComfyUI, FFmpeg und RealESRGAN.

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
│   ├── vps_standalone.sh       # Bereitet einen reinen VPS mit K3s, kubectl und Deployment-Workspace für spätere Kubernetes-Manifeste vor
│   ├── install_local_only.sh   # Spezifisches Setup für reinen MiniPC (Lokal)
│   ├── ruflo_install.sh        # Installiert Ruflo aus GitHub, stellt Node.js 22 und pnpm sicher und verlinkt die CLI
│   ├── port_check.sh           # Skript zur Überprüfung von Port-Konflikten
│   ├── k8s_deployments.yaml    # Kubernetes Deployment-Definitionen für VPS-Dienste
│   ├── config_templates/       # Verzeichnis für Konfigurationsvorlagen
│   │   └── openclaw/
│   │       ├── .env.template
│   │       └── config.json.template
│   └── tools/                  # Verzeichnis für Tool-Installations-/Deinstallationsskripte
│       ├── openmanus_install.sh       # Installiert OpenManus aus GitHub und richtet die Python-Abhängigkeiten ein
│       ├── openmanus_uninstall.sh     # Entfernt die OpenManus Installation wieder vom System
│       ├── openclaw_install.sh        # Installiert OpenClaw und baut das Projekt mit pnpm
│       ├── openclaw_uninstall.sh      # Entfernt die OpenClaw Installation vollständig
│       ├── clawhub_cli_install.sh     # Installiert die Clawhub CLI oder nutzt bei Bedarf das Clawhub Haupt-Repository als Fallback
│       ├── clawhub_cli_uninstall.sh   # Entfernt die Clawhub CLI Installation wieder
│       ├── clawhub_install.sh         # Installiert den Clawhub Server für Agenten-Orchestrierung
│       ├── clawhub_uninstall.sh       # Entfernt die Clawhub Server-Installation
│       ├── openclaw_rl_install.sh     # Installiert die Reinforcement-Learning-Erweiterung für OpenClaw aus primärem oder alternativem Repository
│       ├── openclaw_rl_uninstall.sh   # Entfernt die OpenClaw RL Installation wieder
│       ├── clawbake_install.sh        # Installiert Clawbake für Build- und Deployment-Automatisierung
│       ├── clawbake_uninstall.sh      # Entfernt Clawbake vom System
│       ├── n8n_install.sh             # Installiert n8n und baut die Workflow-Plattform mit pnpm
│       ├── n8n_uninstall.sh           # Entfernt die n8n Installation vollständig
│       ├── activepieces_install.sh    # Installiert Activepieces als Open-Source Workflow-Automatisierung
│       ├── activepieces_uninstall.sh  # Entfernt Activepieces wieder vom System
│       ├── flowise_install.sh         # Installiert Flowise zur visuellen Erstellung von LLM-Workflows
│       ├── flowise_uninstall.sh       # Entfernt die Flowise Installation wieder
│       ├── langflow_install.sh        # Installiert LangFlow für visuelle LangChain-Workflows
│       ├── langflow_uninstall.sh      # Entfernt LangFlow wieder vom System
│       ├── autogpt_install.sh         # Installiert AutoGPT und startet die Plattform per Docker Compose
│       ├── autogpt_uninstall.sh       # Stoppt AutoGPT Container und entfernt die lokale Installation
│       ├── pipedream_install.sh       # Bereitet die Self-Hosted Installation von Pipedream vor
│       ├── pipedream_uninstall.sh     # Entfernt eine vorhandene Pipedream Installation wieder
│       ├── huginn_install.sh          # Installiert Huginn für ereignisgesteuerte Web-Automatisierungen
│       ├── huginn_uninstall.sh        # Entfernt die Huginn Installation vollständig
│       ├── ffmpeg_install.sh          # Installiert FFmpeg für Audio- und Videoverarbeitung im Medienprofil
│       ├── ffmpeg_uninstall.sh        # Entfernt FFmpeg wieder vom System
│       ├── zenbot_trader_install.sh   # Installiert die Zenbot-Trader-Plattform für automatisierten Krypto-Handel
│       ├── zenbot_trader_uninstall.sh # Entfernt die Zenbot-Trader Installation wieder
│       ├── kimi2_install.sh           # Installiert Kimi K2.5 aus primärem oder alternativem Repository und richtet Python-Abhängigkeiten ein
│       ├── kimi2_uninstall.sh         # Entfernt die Kimi Installation vollständig
│       ├── huge_facing_install.sh     # Erklärt die Einbindung von Hugging Face Modellen in das Setup
│       ├── huge_facing_uninstall.sh   # Entfernt die hinterlegte Hugging-Face-Integration aus dem Setup-Kontext
│       ├── zotero_install.sh          # Installiert Zotero für Recherche- und Wissensmanagement unter Linux
│       └── zotero_uninstall.sh        # Entfernt die Zotero Installation wieder
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
│       ├── Rechtsberatung_Steuerrecht_uninstall.sh
│       ├── Agent_Orchestrator_install.sh
│       ├── Agent_Orchestrator_uninstall.sh
│       ├── Audio_install.sh
│       ├── Audio_uninstall.sh
│       ├── Content_Automation_install.sh
│       ├── Content_Automation_uninstall.sh
│       ├── Research_Agent_install.sh
│       ├── Research_Agent_uninstall.sh
│       ├── Security_Analyst_install.sh
│       ├── Security_Analyst_uninstall.sh
│       ├── Trading_AI_install.sh
│       ├── Trading_AI_uninstall.sh
│       ├── Visual_Creator_install.sh
│       └── Visual_Creator_uninstall.sh
├── docs/
│   ├── API_KEY_GUIDE.md        # Detaillierte Anleitung für API-Keys, Ports und Fallback-Routing
│   ├── INSTALLATION_BENCHMARKS.md # Editierbare Schätzwerte für Downloadzeit, Installationszeit und GB-Bedarf
│   ├── setup_guide.md          # Umfassende Dokumentation des gesamten Setups
│   ├── PRIVATE_REPO_GUIDE.md   # Anleitung für die Installation aus einem privaten Repository
│   ├── DNS_DDoS_GUIDE.md       # Anleitung zur DNS-Umstellung und DDoS-Schutz
│   ├── Profil/                 # Fachliche Profilquellen und Prompt-Sammlungen je Themenprofil
│   │   ├── Programmierer.doc.md
│   │   ├── Media_Musik.doc.md
│   │   ├── KI_Forschung.doc.md
│   │   ├── Texter_Werbung_Marketing.doc.md
│   │   └── Rechtsberatung_Steuerrecht.doc.md
│   └── Profile/                # Abgeleitete Profilseiten mit tatsächlichem Setup-Stand
│       ├── INDEX.md
│       ├── INCONSISTENCY_REPORT.md
│       ├── INSTALL_CHECKLIST.md
│       ├── profiles.json
│       ├── Programmierer.md
│       ├── Media_Musik.md
│       ├── KI_Forschung.md
│       ├── Texter_Werbung_Marketing.md
│       └── Rechtsberatung_Steuerrecht.md
├── config/
│   └── setup_metrics.conf      # Editierbare Benchmarks, Platzbedarf und Zeit-Schätzwerte
└── installed_profiles.txt      # Liste der aktuell installierten Profile
└── installed_tools.txt         # Liste der aktuell installierten Tools
```

## ⚠️ Wichtige Hinweise

*   **API-Keys:** Werden während der Installation abgefragt oder müssen manuell in Konfigurationsdateien hinterlegt werden. Nutze den OpenClaw Konfigurations-Manager für die `.env` und `config.json`.
*   **`sudo`-Passwort:** Wenn `sudo` ein Passwort verlangt, ist das das Passwort deines Linux-Benutzers. Unter WSL ist das nicht dein Windows-Passwort, sondern das Passwort des Ubuntu-/Linux-Users.
*   **`zstd` Voraussetzung:** Einige Installationen oder Paketentpackungen benötigen `zstd`. Das Setup installiert `zstd` jetzt direkt mit den Basis-Abhängigkeiten.
*   **pnpm Warnung zu ignorierten Build-Skripten:** Wenn `pnpm` z. B. `@discordjs/opus@0.10.0` als ignoriertes Build-Skript meldet, bietet das Setup jetzt am Ende des OpenClaw-Builds einen separaten Bestätigungsschritt für `pnpm approve-builds` an.
*   **Ressourcen:** Das Setup ist für eine optimale Verteilung auf einen Letsung MiniPC (16GB RAM / 70GB Disk) und einen Oracle Cloud Free Tier VPS (24GB RAM) sowie weitere kostenlose VPS ausgelegt.
*   **Dynamische IP:** Hurricane Electric wird für die dynamische DNS-Auflösung des MiniPCs verwendet. Eine detaillierte Anleitung zur Umstellung und zum DDoS-Schutz findest du in `docs/DNS_DDoS_GUIDE.md`.

Wir wünschen dir viel Erfolg bei der Einrichtung deines intelligenten, automatisierten Systems!
