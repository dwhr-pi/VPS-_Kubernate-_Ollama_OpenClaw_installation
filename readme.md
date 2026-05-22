# VPS- Kubernate- Ollama & OpenClaw installation - Ultimate Setup V11.16

Dies ist das ultimative Setup für ein hybrides KI- und Smart-Home-System, das deinen Letsung MiniPC (WSL2) und mehrere kostenlose VPS kombiniert. Es integriert eine Vielzahl von Tools und KI-Agenten, die direkt aus GitHub-Quellen kompiliert oder lokal aufgebaut werden.

## 🧱 Zielbild

Das Repository entwickelt sich von einer reinen Tool-Sammlung zu einer modularen **LLMOps-Plattform**:

`Base System -> Runtime -> Model Gateway -> Agent Layer -> Memory/RAG -> Tool Layer -> UI -> Monitoring -> Security`

Die zugehoerige Architektur-Dokumentation findest du in [docs/ARCHITECTURE_LLMOPS_PLATFORM.md](docs/ARCHITECTURE_LLMOPS_PLATFORM.md).

## Quickstarts

| Ziel | Einstieg |
|---|---|
| Minimal lokal | `bash install.sh` starten und nur Basis/Programmierer waehlen |
| MiniPC + Ollama + OpenClaw | `Programmierer`, `RAG_Wissensdatenbank`, `Monitoring_Observability` |
| Medien/GPU | `Image_Generation_Studio`, `Video_Generation_Studio`, `Render_Farm_GPU_Workstation` |
| Smart Home/Jarvis | `Smart_Home_Automation`, `Voice_Command_Center`, `Personal_Assistant_Local_First` |
| Wissenschaft | `Physik`, `Bioinformatik`, `Molekuelsimulation`, `Mathematik_Simulation` |
| Security | `Security_DevSecOps`, `Zero_Trust_Remote_Access`, `Anti_Virus` |
| Kubernetes/VPS | `DevOps_SRE`, `Kubernetes_GPU_Orchestrator`, `Storage_NAS_Backup` |

Wichtige Uebersichten:

- [Setup Review und Verbesserungsplan](docs/SETUP_REVIEW_AND_IMPROVEMENT_PLAN.md)
- [Profilmatrix](docs/PROFILE_MATRIX.md)
- [Toolmatrix](docs/TOOL_MATRIX.md)
- [Portmatrix](docs/PORT_MATRIX.md)
- [Sicherheitsmodell](docs/SECURITY_MODEL.md)
- [Secret Handling](docs/SECRET_HANDLING.md)
- [Remote Access Entscheidungshilfe](docs/REMOTE_ACCESS_DECISION_TREE.md)
- [myBox + GBOX Integration](docs/myBOX_GBOX_INTEGRATION.md)

## 🟡 Gegenwärtiger Status

- `MiniPC`-Setup ist aktuell der stabilste abgeschlossene Pfad.
- Der laufende Funktionstest konzentriert sich derzeit bevorzugt auf das `Programmierer`-Setup.
- Weitere Profile und Plattformpfade werden aktuell funktional geprueft, bevor tiefer an der Feinkonfiguration gearbeitet wird.
- Neuere Plattform- und Ausbauprofile wurden jetzt strukturell in Doku und Registries aufgenommen, sind aber nicht alle schon als Top-Level-Menuepfade gleich weit durchgetestet.
- Neu hinzugekommen ist ausserdem das klar defensive Profil [Ethical_HackerGPT](docs/Profil/Ethical_HackerGPT.doc.md) fuer autorisierte Sicherheitsanalysen, Hardening, Reporting und lokale Security-Labs.
- Ebenfalls neu ist das modulare [Next Level Persona System](docs/Profil/Next_Level_Persona_System.md) fuer persistente Persona-, Memory- und Modus-Workflows mit sicheren Disclosure-Defaults.
- Fuer laenger laufende Baustellen und Chat-Uebergaenge gibt es jetzt zusaetzlich eine kleine dauerhafte Projekt-Erinnerung unter [docs/SETUP_MEMORY.md](docs/SETUP_MEMORY.md).
- Die aktuelle Review- und Prioritaetenliste liegt in [docs/SETUP_REVIEW_AND_NEXT_STEPS.md](docs/SETUP_REVIEW_AND_NEXT_STEPS.md).
- Neue modulare Profilbausteine: `Prompt_Generator_Studio`, `Memory_Import_Export`, `Self_Learning_Agent_Lab`, `Boardroom`, `Home_Network_Security`, `Android_App_Builder`, `AI_Dashboard_Builder`, `Render_Farm_GPU_Workstation`, `GameDev_3D_Studio_NEXTLEVEL`, `CAD_Konstrukteur`, `Architektur_3D_BIM`, `Robotertechnik_Anlagensteuerung`, `Physik`, `Chemie`, `Biologie`, `Bioinformatik`, `Molekuelsimulation`, `Robotik_Labor`, `Materialwissenschaft`, `Legal_Safe_Creator`, `Cyber_Security_AI` und `Anti_Virus`.

## 🚀 Schnelle Installation (One-Liner)

Um die interaktive Installationsplattform zu starten, führe einfach den folgenden Befehl in deinem Terminal aus:

```bash
cd ~
curl -sSL https://raw.githubusercontent.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/main/install.sh | bash
```

Dieser Befehl lädt das `install.sh` Skript herunter und führt es aus. Das Skript klont dieses Repository und startet das interaktive Setup-Menü, das dich durch die weiteren Schritte führt.

## Boardroom-Profil

Das [Boardroom-Profil](docs/Profile/Boardroom.md) hilft bei strategischen Entscheidungen im Setup. Es simuliert CFO, Operator, Vertriebler, Mentor und Skeptiker und erzeugt danach ein Chairman-Verdict. Aktivierung zum Beispiel mit: `Boardroom rufen: Soll ich X oder Y fuer unser Setup nutzen?`

**Wichtig für Einsteiger:** Während der Installation wirst du mehrfach nach einem Passwort gefragt. Gemeint ist dabei das `sudo`-Passwort deines Linux-Benutzers, also das Passwort des Ubuntu-/Linux-Users innerhalb von WSL oder auf deinem Server.

**Sprachauswahl schon beim ersten Start:** Noch vor der Frage nach einem privaten GitHub-Repository kannst du jetzt bereits die Setup-Sprache festlegen. Diese Auswahl wird ausgelagert gespeichert und bei späteren Starts wiederverwendet.

**Für private Repositories:** Das Skript wird dich nach einem GitHub Personal Access Token (PAT) fragen. Eine Anleitung zur Erstellung findest du in der `docs/PRIVATE_REPO_GUIDE.md`.

**Für die OpenClaw `.env`:** Eine eigene Detaildokumentation zur `.env`-Struktur, zu den Feldern und zur originalen OpenClaw-Vorlage findest du in [docs/OPENCLAW_ENV_GUIDE.md](docs/OPENCLAW_ENV_GUIDE.md).

**Für die Huginn `.env`:** Die Huginn-spezifische Vorlage, der Benutzer-Workspace-Pfad, der `INVITATION_CODE` und die Runtime-Datei unter `/opt/huginn/.env` sind jetzt in [docs/HUGINN_ENV_GUIDE.md](docs/HUGINN_ENV_GUIDE.md) dokumentiert.

**Für eigene Forks und Custom-Builds:** Die neue Anleitung für benutzerdefinierte GitHub-Quellen, eigene Repositories, GGUF-Exporte und `ollama create` findest du in [docs/CUSTOM_SOURCES_AND_BUILDS.md](docs/CUSTOM_SOURCES_AND_BUILDS.md).

**Wichtig für sensible Daten:** Bearbeitbare und sensible Dateien werden ab den neueren Setup-Versionen zusätzlich außerhalb des Repositories in `~/.openclaw_ultimate_user_data` abgelegt. Dadurch bleiben API-Keys, bearbeitete Vorlagen und Statusdateien beim Repo-Update sauber getrennt und werden nicht versehentlich ins Git-Repository geschrieben.

Dazu gehören jetzt insbesondere:

- OpenClaw-`.env`- und `config.json`-Vorlagen
- Huginn-`.env`-Vorlagen
- Statusdateien für installierte Tools und Profile
- editierbare Installations-Messwerte
- ausgelagerte Sprachvorgaben in `~/.openclaw_ultimate_user_data/setup_preferences.conf`
- lokale Ollama-Modelfiles in `~/.openclaw_ultimate_user_data/modelfiles`
- Profil-Quellen aus `docs/Profil`
- abgeleitete Profilseiten aus `docs/Profile`
- ein separater Bereich für künftige Benutzer-Prompts

**Wichtiger Stack-Standard:** Die Compose-Plattform unter `stacks/llmops-platform/` nutzt jetzt eine echte `.env` als Laufzeitdatei, waehrend `.env.example` nur noch die Vorlage ist. Exponierte Dienste werden dort standardmaessig nur an `127.0.0.1` gebunden und sollten erst bewusst ueber Tunnel oder Reverse Proxy freigegeben werden.

Fuer diesen Stack gibt es jetzt analog zu OpenClaw auch eine auslagerbare, editierbare Vorlage unter `scripts/config_templates/llmops-platform/.env.template`. Die bearbeitbare Benutzerkopie liegt unter `~/.openclaw_ultimate_user_data/llmops-platform/.env.template` und kann ueber `scripts/llmops_platform_config_manager.sh` auf `stacks/llmops-platform/.env` angewendet werden.

Für privaten Remote-Zugriff ist jetzt zusätzlich `Tailscale` als Tool vorgesehen. Das passt besonders an die Stelle, an der sonst unnötig offene Admin-Ports entstehen würden, etwa für `Open WebUI`, `Grafana`, `Home Assistant`, `SSH` oder interne Dashboards.

Für veröffentlichte, aber abgesicherte öffentliche Dienste ist zusätzlich `cloudflared` vorgesehen. Zusammen mit `Hurricane Electric` für DNS/DDNS und `Tailscale` für privaten Admin-Zugriff ist die gemeinsame Orientierung jetzt in [docs/REMOTE_ACCESS_DNS_GUIDE.md](docs/REMOTE_ACCESS_DNS_GUIDE.md) dokumentiert.

## 🧭 Neue Übersichten und Doctor-Skripte

- [docs/PROFILE_INDEX.md](docs/PROFILE_INDEX.md)
- [docs/TOOL_INDEX.md](docs/TOOL_INDEX.md)
- [docs/PROFILE_TOOL_MAPPING.md](docs/PROFILE_TOOL_MAPPING.md)
- [docs/PORT_SECURITY_MATRIX.md](docs/PORT_SECURITY_MATRIX.md)
- [docs/TOOL_DEPLOYMENT_MATRIX.md](docs/TOOL_DEPLOYMENT_MATRIX.md)
- [docs/TOOL_USAGE_AND_INTEGRATION_GUIDE.md](docs/TOOL_USAGE_AND_INTEGRATION_GUIDE.md)
- [docs/LANGGRAPH_INTEGRATION_GUIDE.md](docs/LANGGRAPH_INTEGRATION_GUIDE.md)
- [docs/CREWAI_INTEGRATION_GUIDE.md](docs/CREWAI_INTEGRATION_GUIDE.md)
- [docs/AUTOGEN_INTEGRATION_GUIDE.md](docs/AUTOGEN_INTEGRATION_GUIDE.md)
- [docs/AIDER_INTEGRATION_GUIDE.md](docs/AIDER_INTEGRATION_GUIDE.md)
- [docs/OPENCODE_INTEGRATION_GUIDE.md](docs/OPENCODE_INTEGRATION_GUIDE.md)
- [docs/GITHUB_CLI_INTEGRATION_GUIDE.md](docs/GITHUB_CLI_INTEGRATION_GUIDE.md)
- [docs/PODMAN_CONTAINER_RUNTIME_GUIDE.md](docs/PODMAN_CONTAINER_RUNTIME_GUIDE.md)
- [docs/CLAWBAKE_INTEGRATION_GUIDE.md](docs/CLAWBAKE_INTEGRATION_GUIDE.md)
- [docs/AUTH_OIDC_HELM_SECRETS_GUIDE.md](docs/AUTH_OIDC_HELM_SECRETS_GUIDE.md)
- [docs/Profile/Jarvis_FritzBox_Alexa_Home_Assistant.md](docs/Profile/Jarvis_FritzBox_Alexa_Home_Assistant.md)
- [docs/PLAYWRIGHT_INTEGRATION_GUIDE.md](docs/PLAYWRIGHT_INTEGRATION_GUIDE.md)
- [docs/CHROMADB_INTEGRATION_GUIDE.md](docs/CHROMADB_INTEGRATION_GUIDE.md)
- [docs/CODE_SANDBOX_USAGE_GUIDE.md](docs/CODE_SANDBOX_USAGE_GUIDE.md)
- [docs/HARDWARE_REQUIREMENTS.md](docs/HARDWARE_REQUIREMENTS.md)
- [docs/WSL_VPS_GPU_COMPATIBILITY.md](docs/WSL_VPS_GPU_COMPATIBILITY.md)
- [docs/ROADMAP_NEXT_PROFILES.md](docs/ROADMAP_NEXT_PROFILES.md)

Hinweis zur erweiterten Installationsueberwachung: Wenn sie aktiv ist, bietet der Nach-Schritt-Dialog direkte Sofortaktionen an. `[L]` zeigt das letzte Log, `[D]` erstellt eine Diagnose im Terminal und `[E]` sendet die Diagnose per konfigurierter E-Mail-Ausgabe. Wenn waehrend eines Installations-/Deinstallations-Batches ein Fehler auftritt, bricht `[Z]` bzw. `[z]` den laufenden Batch ab und fuehrt zurueck ins Setup statt blind mit dem naechsten Tool weiterzumachen.

Schnelle Log- und Speicherdiagnose:

```bash
bash scripts/last_install_log.sh --failed
bash scripts/last_install_log.sh --diagnostics
bash scripts/last_install_log.sh --snapshot
```

`--failed` zeigt die letzten erkannten Fehlerlogs, `--diagnostics` erstellt einen Bericht ueber den letzten Installationslauf und `--snapshot` schreibt einen Abhaengigkeiten-/Speicher-Snapshot nach `~/.openclaw_ultimate_user_data/diagnostic_reports`. Das hilft besonders nach grossen Tool-Installationen, weil Deinstallationen nicht automatisch alle Systempakete, Python-venvs, npm/pnpm-Caches, Docker-/Podman-Images, Modellordner oder Build-Caches entfernen.

Im Tool-Management werden Deinstallationen jetzt vor Installationen ausgefuehrt. Wenn in einem Batch also Tools abgewaehlt und andere neu angewaehlt werden, wird zuerst Speicher freigegeben und erst danach installiert. Bei Installationsfehlern erscheint der Log-/Diagnose-Dialog sofort, auch wenn die erweiterte Ueberwachung nicht aktiv ist; Enter entspricht in diesem Fehlerfall sicherheitshalber `Z` und springt zurueck ins Setup.

Vor und nach Tool-Installationen werden Speicherwerte gemessen. Die Historie liegt unter `~/.openclaw_ultimate_user_data/metrics_logs/operation_history.tsv` und direkte Tool-Skript-Messungen unter `~/.openclaw_ultimate_user_data/metrics_logs/tool_script_history.tsv`. Die jeweils letzte Messung wird zusaetzlich in `~/.openclaw_ultimate_user_data/setup_metrics.conf` als `LAST_...` bzw. `LAST_TOOL_SCRIPT_...` Wert fortgeschrieben.

Die Tool-Quellenpolitik steht ebenfalls in `setup_metrics.conf`: Standardmaessig sollen Primaertools aus GitHub kommen, waehrend Systemabhaengigkeiten wie `apt` erlaubt bleiben. Mit `STRICT_GITHUB_TOOL_SOURCES=true` kann das Setup Tool-Installer ohne erkannte GitHub-Quelle blockieren; bewusste Ausnahmen sind mit `ALLOW_NON_GITHUB_TOOL_SOURCE=1` moeglich.

Alte Fehlerlogs koennen gezielt rotiert werden:

```bash
bash scripts/cleanup_setup_logs.sh --dry-run --failed-only
bash scripts/cleanup_setup_logs.sh --apply --failed-only
```

## Optional: OpenHiggsStack / AI Cinema Studio

Higgsfield AI ist ein proprietaerer bzw. cloudbasierter AI-Video-/Image-/Marketing-Studio-Pfad mit CLI-/Agent-Anbindung. Dieses Setup ergaenzt dafuer eine offene, lokale Alternative: [OpenHiggsStack AI Cinema Studio](docs/Profile/OpenHiggsStack_AI_Cinema_Studio.md).

OpenHiggsStack ist kein 1:1-Klon, sondern eine modulare Pipeline aus `OpenClaw`, `Ollama`, `ComfyUI`, `Wan2.x`, `FFmpeg` und `n8n`. Cloud-APIs wie Higgsfield, Veo, Kling, Seedance, Runway, Pika oder Sora koennen optional spaeter angebunden werden, bleiben aber standardmaessig aus und benoetigen eigene Keys ausserhalb des Repositories.

Technischer Einstieg:

```bash
bash scripts/install-openhiggsstack.sh
bash scripts/last_install_log.sh
```

Das Installskript legt Ordner, Log und Beispielkonfiguration an, installiert nach Moeglichkeit `ffmpeg`, und fragt interaktiv, ob ComfyUI geklont werden soll. Grosse Modelle werden nicht automatisch heruntergeladen.

Wenn eine Installation fehlschlaegt, zeigt `bash scripts/last_install_log.sh` sofort das neueste Protokoll. Mit `bash scripts/last_install_log.sh --email` kann die bestehende Diagnose-Mail-Funktion genutzt werden, sofern SMTP/msmtp bereits konfiguriert ist.

## Optional: GameDev 3D Studio NEXTLEVEL

Das Profil [GameDev 3D Studio NEXTLEVEL](docs/Profile/GameDev_3D_Studio.md) beschreibt ein lokales AI Game Studio fuer Godot 4.x, Godot-Demo-Projekte, Blender, ComfyUI, Ollama-NPCs, OpenClaw als Game Master, n8n-Automation, Multiplayer-/Kubernetes-Pfade, Renderfarm, Voice und Modding.

Der Einstieg ist speicherschonend: Standardmaessig werden nur Ordnerstruktur, Env-Beispiel und Agent-/NPC-Beispiele angelegt. Grosse Schritte wie Godot-Quellcode, Demo-Projekte, Blender-Pakete oder ein Godot-Source-Build laufen nur, wenn sie bewusst per Umgebungsvariable aktiviert werden.

```bash
bash scripts/tools/gamedev_3d_studio_install.sh
GAMEDEV_CLONE_GODOT=1 GAMEDEV_CLONE_DEMOS=1 bash scripts/tools/gamedev_3d_studio_install.sh
```

## Optional: CAD_Konstrukteur

Das Profil [CAD_Konstrukteur](docs/Profile/CAD_Konstrukteur.md) beschreibt einen lokalen CAD-/3D-Druck-Assistenten fuer FreeCAD, CadQuery, OpenSCAD, Blender-Preview, Ollama-CAD-Code, OpenClaw-Agenten, N8n und Whisper-Sprachkommandos.

Der Pfad ist experimentell, aber bewusst pruefbar: Das Installationsskript installiert nach Moeglichkeit FreeCAD/OpenSCAD und eine Python-venv fuer CadQuery, waehrend Blender optional bleibt.

```bash
bash scripts/install/install_cad_tools.sh
bash scripts/check/check_cad_tools.sh
```

Beispielanwendung: Ein parametrisches Raspberry-Pi-, Mini-PC- oder ESP32-Gehaeuse mit Wandstaerke, Schraubloechern, Lueftungsschlitzen und STL-/STEP-Export vorbereiten. Sicherheitskritische oder tragende Bauteile muessen immer fachlich geprueft werden.

## Optional: Architektur 3D BIM

Das Profil [Architektur_3D_BIM](docs/Profile/Architektur_3D_BIM.md) beschreibt ein lokales Architektur-, BIM-/IFC-, CAD- und 3D-Rendering-Studio fuer FreeCAD, Blender, Bonsai/BlenderBIM, IFCOpenShell, QGIS, ComfyUI, OpenClaw-Agenten, n8n-Automation und optionale Renderfarm-/Kubernetes-Workflows.

Der Einstieg ist bewusst lokal-first und vorsichtig: Standardmaessig werden Projektordner, Dokumentation, Agentenrollen und Checks vorbereitet. Schwere Architektur-/CAD-/BIM-Pakete werden nur mit explizitem Opt-in installiert.

```bash
bash scripts/install_architektur_3d_bim_optional.sh
ARCH_INSTALL_CORE=1 bash scripts/install_architektur_3d_bim_optional.sh
bash profiles/architektur_3d_bim/scripts/check_architektur_stack.sh
```

Wichtig: KI-Entwuerfe, IFC-Analysen und Renderings ersetzen keine Fachplanung. Bau, Statik, Brandschutz, Elektroplanung, Energieausweis und Genehmigung muessen immer fachlich geprueft werden.

## Optional: Robotertechnik & Anlagensteuerung

Das Profil [Robotertechnik_Anlagensteuerung](docs/Profile/Robotertechnik_Anlagensteuerung.md) ist ein Simulation-first-Profil fuer ROS 2, Gazebo, MoveIt 2, Anlagenmonitoring, Sensorik, Predictive Maintenance, MQTT-/OPC-UA-/Modbus-Anbindung und sichere KI-Assistenz fuer technische Systeme.

Standardmaessig arbeitet dieses Profil im Simulations-, Diagnose- und Vorschlagsmodus. Reale Hardware darf nur mit explizitem Realmodus, menschlicher Freigabe, Not-Aus, Hardware-Interlocks, Grenzwerten und Audit-Logging angesteuert werden.

```bash
bash scripts/install_robotics_profile_optional.sh
bash profiles/robotik_anlagensteuerung/scripts/check_robotics_stack.sh
```

Validierung:

```bash
bash scripts/doctor.sh
bash scripts/validate_config.sh
bash scripts/check_profiles.sh
bash scripts/check_ports.sh
```

## Optional: Wissenschaftliche Science-Lab-Profile

Die Science-Lab-Profile [Physik](docs/Profile/Physik.md), [Chemie](docs/Profile/Chemie.md), [Biologie](docs/Profile/Biologie.md), [Bioinformatik](docs/Profile/Bioinformatik.md), [Molekuelsimulation](docs/Profile/Molekuelsimulation.md), [Robotik_Labor](docs/Profile/Robotik_Labor.md) und [Materialwissenschaft](docs/Profile/Materialwissenschaft.md) erweitern Ollama, OpenClaw, Codex, Kubernetes, JupyterLab, Dashboards, Whisper und Home-Assistant-Sensorik zu einer lokalen wissenschaftlichen Arbeitsumgebung.

Die Installer sind bewusst modular: Standardmaessig werden Ordner, Profilhinweise, Speicherprotokoll und eine Python-Umgebung vorbereitet. Grosse GitHub-Projekte werden nur mit `SCIENCE_CLONE_GITHUB=1` geklont; umfangreiche Python-Pakete werden nur mit `SCIENCE_INSTALL_PYTHON_DEPS=1` installiert.

```bash
bash scripts/profiles/Physik_install.sh
SCIENCE_CLONE_GITHUB=1 bash scripts/profiles/Molekuelsimulation_install.sh
SCIENCE_INSTALL_PYTHON_DEPS=1 bash scripts/profiles/Bioinformatik_install.sh
```

Docker ist fuer diese Profile nicht Pflicht. CUDA/ROCm werden erkannt und dokumentiert; Kubernetes-Offloading bleibt optional fuer groessere Simulationen, Batch-Analysen und GPU-Worker.

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
- lokale Modelfiles für eigene Ollama-Modelle

Darauf solltest du achten:

- Niemals echte Secrets in Git committen oder auf GitHub hochladen.
- Bearbeite sensible Vorlagen möglichst nur über den ausgelagerten Benutzer-Workspace.
- Sichere deine `.env` lokal zusätzlich, wenn du wichtige API-Keys eingetragen hast.
- Wenn du den Rechner oder die WSL weitergibst, lösche den Benutzer-Workspace gezielt mit.
- Wenn du einen öffentlichen Host, VPS oder `0.0.0.0` nutzt, setze immer sichere Tokens und Passwörter.
- Eigene Modelfiles und GGUF-Pfade solltest du möglichst ebenfalls nur im Benutzer-Workspace pflegen und nicht ins Git-Repository schreiben.
- Auch neue Plattform-Stacks fuer LiteLLM, Open WebUI, Langfuse, Qdrant oder MinIO sollen immer ueber `.env`-Dateien im Benutzer-Workspace oder in separaten lokalen Stack-Verzeichnissen konfiguriert werden, nicht im Git-Repository.

## ⚠️ Kostenfalle durch Cloud-APIs und Bezahldienste

Dieses Setup ist lokal-first ausgelegt und wurde so konzipiert, dass viele Funktionen kostenlos oder mit Open-Source-Komponenten genutzt werden koennen. Trotzdem koennen einzelne Tools, Agenten oder Workflows auf externe KI-APIs, Cloud-Dienste, bezahlte Modellanbieter, Speicher-, VPS-, E-Mail-, Trading-, Medien- oder Automationsdienste zugreifen, wenn dort API-Keys, Zahlungsdaten oder eine Kreditkarte hinterlegt sind.

Je nach Prompt, Fehlkonfiguration oder automatisiertem Workflow koennen dadurch unerwartete Kosten entstehen. Besonders kritisch sind Batch-Jobs, Agenten-Schleifen, automatische Mediengenerierung, Cloud-LLMs, Video-/Bild-APIs, Deployments, Speicher- und Traffic-Kosten sowie Dienste, die pro Anfrage, Token, Minute, GPU-Zeit oder Export abrechnen.

Best Practices:

- Nutze lokale Modelle und kostenlose Kontingente bevorzugt.
- Hinterlege Zahlungsdaten nur bei Diensten, die du wirklich nutzen willst.
- Setze harte Kostenlimits, Quotas, Budget-Warnungen und API-Limits beim Anbieter.
- Trage Cloud-API-Keys nur bewusst und nur im Benutzer-Workspace ein, niemals im Repository.
- Pruefe `.env`-Dateien, n8n-Workflows, Agenten-Tools und Fallback-Router, bevor du sie startest.
- Starte neue Agenten- oder Batch-Workflows zuerst mit kleinen Tests.
- Deaktiviere oder entferne API-Keys, wenn ein Tool nicht aktiv genutzt wird.
- Kontrolliere regelmaessig Anbieter-Dashboards und Rechnungsseiten.

Wichtig:

- Das Entfernen von `~/openclaw_ultimate_setup` löscht nicht automatisch deinen ausgelagerten Benutzer-Workspace.
- Das ist Absicht, damit persönliche Daten und bearbeitete Vorlagen beim Repo-Update oder Neu-Klonen nicht verloren gehen.
- Wenn du wirklich alles entfernen möchtest, lösche zusätzlich:

```bash
rm -rf ~/.openclaw_ultimate_user_data
```

## ⚠️ Trading-, Web3- und Finanzhinweis

Für Trading-, Web3- und finanznahe Profile gilt ausdrücklich:

- Keine Haftung für Verluste oder sonstige verursachte Schäden.
- Dieses Repository ist keine Anlageberatung, keine Finanzberatung und kein regulierter Trading-Dienst.
- Live-Trading, automatische Orderausführung und Wallet-nahe Automatisierung sind bewusst kein sicherer Standardpfad dieses Setups.

Warum dieser Hinweis wichtig ist:

- automatisierte Trading-Signale oder Handlungsempfehlungen können rechtlich schnell in Richtung regulierter Finanzdienstleistung fallen
- LLMs wie `Ollama` oder agentische Workflows mit `OpenClaw` sind für Marktentscheidungen nicht verlässlich genug
- API-Keys, Börsenzugänge, Wallets und Private Keys sind ein hohes Sicherheitsrisiko
- Nutzer können sich psychologisch zu stark auf KI-Ausgaben verlassen und Risiken unterschätzen

Deshalb gilt im Repository als Best Practice:

- erlaubt und sinnvoll:
  - Marktanalyse
  - Backtesting
  - Paper Trading
  - Alerts
  - Portfolio-Tracking
- nicht als Default:
  - echtes automatisches Trading
  - autonome Kauf-/Verkaufsentscheidungen durch KI
  - Live-Orders durch Agenten

Wenn du mit Trading- oder Web3-Profilen arbeitest:

- nutze zuerst Simulation, Dry-Run und Paper-Trading
- speichere niemals Seed-Phrases oder Private Keys im Repo
- behandle alle Wallet-, API- und Exchange-Zugänge wie Hochrisiko-Secrets
- lies zusätzlich die Sicherheits- und Profilhinweise in den jeweiligen Trading-/Web3-Dokumentationen

## 🧭 Installationspfade

### Minimal Setup

Empfohlen fuer einen schnellen lokalen Einstieg:

1. `Standalone: Nur MiniPC (Lokal)`
2. `Ollama`
3. `OpenClaw`
4. optional `Programmierer` oder `LLM_Builder`

### Full Setup

Empfohlen fuer eine lokale plus hybride AI-Plattform:

1. `Standalone: Nur MiniPC (Lokal)` oder `Hybrid`
2. `Programmierer`
3. `LLM_Builder`
4. `LiteLLM`
5. `Open_WebUI`
6. `Qdrant`
7. `Langfuse`
8. `Grafana`, `Prometheus`, `Loki`

### Cluster Setup

Empfohlen fuer VPS oder spaeteres Multi-Node-Sandboxing:

1. `Standalone: Nur VPS (Cloud-Native)`
2. `K3s`
3. `LiteLLM`
4. `Open_WebUI`
5. `Qdrant`
6. `Langfuse`
7. `Grafana`, `Prometheus`, `Loki`

Fuer einen vorkonfigurierten Plattform-Stack liegt jetzt auch ein Compose-Stack unter [stacks/llmops-platform/docker-compose.yml](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/stacks/llmops-platform/docker-compose.yml:1).

### Quickstart GPU Workstation

Empfohlen für lokale Medien- und Bild/Video-Workflows:

- `Standalone: Nur MiniPC` oder Linux-Workstation
- danach gezielt:
  - `Image_Generation`
  - `Video_Generation`
  - `Voice_Assistant`
- vorher unbedingt GPU, VRAM und SSD prüfen

### Quickstart Media AI

Für Audio, Bild, Video und Content-Pipelines:

- `Media_Musik`
- `Visual_Creator`
- `Image_Generation`
- `Video_Generation`
- `Voice_Assistant`

### Quickstart Secure Production-like

Für produktionsnähere Self-Hosted-Setups:

- `DevOps_SRE`
- `Security_DevSecOps`
- `Compliance_Privacy`
- `Monitoring_Observability`
- `Backup_Recovery`

## 🔄 Setup erneut starten

Wenn du das Setup-Menü erneut starten möchtest, navigiere in das Installationsverzeichnis (standardmäßig `~/openclaw_ultimate_setup`) und führe das Hauptskript aus:

```bash
cd ~/openclaw_ultimate_setup
bash ./setup_ultimate.sh
```

## 🔁 Setup aktualisieren oder lokal entfernen

Wenn es Änderungen im Repository gab und du dein bestehendes Setup aktualisieren möchtest, wird jetzt bewusst ein **harter Repo-Abgleich** empfohlen. So bleiben keine alten Setup-Dateien halb stehen, während dein ausgelagerter Benutzer-Workspace erhalten bleibt:

```bash
cd ~/openclaw_ultimate_setup
git status --short
git fetch origin --prune
git checkout main 2>/dev/null || git checkout -b main --track origin/main
git reset --hard origin/main
git clean -fd
printf '\nDas Repository ist jetzt aktualisiert.\n'
printf 'Du kannst die aktuelle Terminal-Ausgabe jetzt in Ruhe lesen oder kopieren.\n'
read -rp "Drücke Enter, um danach das Setup-Menü zu starten ... "
bash ./setup_ultimate.sh
```

Wenn du vor dem Neustart des Menüs den angezeigten Stand erst prüfen möchtest, ist diese kleine Pause bewusst hilfreich. So kannst du z. B. Git-Meldungen, Versionsstände oder Warnungen noch lesen und direkt aus dem Terminal kopieren, bevor das interaktive Setup weiterläuft.

Wichtig:

- Die Pause erscheint nur dann, wenn der harte Repo-Abgleich erfolgreich war.
- `git reset --hard origin/main` und `git clean -fd` verwerfen lokale Änderungen und ungetrackte Zusatzdateien **im Setup-Repository**.
- Dein ausgelagerter Benutzer-Workspace unter `~/.openclaw_ultimate_user_data` bleibt dabei erhalten.
- Die neueren Update-Skripte legen vor dem harten Abgleich zusätzlich eine Sicherung der verworfenen Repo-Differenzen unter `~/.openclaw_ultimate_user_data/repo_update_backups` an.

Wenn dabei vorher lokale Änderungen in Dateien wie `install.sh` oder `setup_ultimate.sh` auftauchen, ist das gerade der Grund für den harten Abgleich: Das Repo soll vollständig auf `origin/main` zurück, statt nur teilweise über `git pull` aktualisiert zu werden.

In diesem Fall gibt es jetzt zwei sichere Wege:

- im Menü den Punkt `Setup-Repository hart reparieren / auf GitHub main zurücksetzen` verwenden
- oder den One-Liner-Installer erneut starten, der bei vorhandenem Repo jetzt ebenfalls den harten Abgleich verwendet

Wichtig dabei:

- Es werden nur Dateien im Setup-Repository zurückgesetzt.
- Dein ausgelagerter Benutzer-Workspace unter `~/.openclaw_ultimate_user_data` bleibt erhalten.
- Vor dem harten Abgleich legt der Installer jetzt zusätzlich eine Sicherung des Repo-Zustands unter `~/.openclaw_ultimate_user_data/repo_update_backups` an.

Alternativ kannst du im Menü den Punkt `Setup-Update + System-Update (Repo, OS & pnpm)` nutzen. Dieser zieht den aktuellen Repository-Stand direkt im Setup-Verzeichnis und aktualisiert danach Ubuntu sowie `pnpm`.

Wenn danach trotzdem noch ein älterer Setup-Stand angezeigt wird, sollte zuerst geprüft werden, ob wirklich das richtige Repository-Verzeichnis verwendet wird. Ein normaler `git pull` ist dafür nicht mehr der empfohlene Weg.

Prüfen:

```bash
cd ~/openclaw_ultimate_setup
git status
```

Wenn du den harten Repo-Abgleich lieber manuell ausführen möchtest, kannst du das Setup so direkt auf den aktuellen GitHub-Stand zurücksetzen:

```bash
cd ~/openclaw_ultimate_setup
git fetch origin --prune
git reset --hard origin/main
printf '\nDas Repository wurde hart auf GitHub main zurückgesetzt.\n'
printf 'Du kannst die aktuelle Terminal-Ausgabe jetzt in Ruhe lesen oder kopieren.\n'
read -rp "Drücke Enter, um danach das Setup-Menü zu starten ... "
bash ./setup_ultimate.sh
```

Dafür gibt es jetzt auch direkt im Menü einen eigenen Punkt:

- `Setup-Repository hart reparieren / auf GitHub main zurücksetzen`

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

Eine detaillierte Anleitung zur Konfiguration, API-Keys, Port-Analyse und den verschiedenen Setup-Optionen findest du in der `docs/API_KEY_GUIDE.md`, `docs/setup_guide.md`, `docs/DNS_DDoS_GUIDE.md`, [docs/OPENCLAW_ENV_GUIDE.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/OPENCLAW_ENV_GUIDE.md:1) und [docs/ARCHITECTURE_LLMOPS_PLATFORM.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/ARCHITECTURE_LLMOPS_PLATFORM.md:1) innerhalb dieses Repositorys.

Zusätzliche Hilfen:

*   `docs/CLOUDFLARE_TUNNEL_GUIDE.md` erklärt Schritt für Schritt, wie du den benötigten Cloudflare-Tunnel und Token anlegst.
*   `docs/WSL_SETUP_GUIDE.md` erklärt WSL unter Windows, Ubuntu-24.04 bzw. andere Linux-Distributionen, sowie Deinstallation und komplettes Zurücksetzen.
*   `docs/INSTALLATION_BENCHMARKS.md` beschreibt die editierbaren Installations-Schätzwerte und verweist auf `~/.openclaw_ultimate_user_data/setup_metrics.conf`.
*   [docs/OLLAMA_MODEL_CATALOG.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/OLLAMA_MODEL_CATALOG.md:1) listet empfohlene lokale Modelle, Coding-Modelle und EU-nahe Modelle mit Groessen- und RAM-Hinweisen.
*   [docs/REPO_SYNC_AND_RECOVERY.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/REPO_SYNC_AND_RECOVERY.md:1) beschreibt saubere Sync-, Backup- und Wiederherstellungswege zwischen Windows, Ubuntu/WSL und Codex-Worktrees.
*   [docs/ROADMAP.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/ROADMAP.md:1) zeigt die naechsten Ausbauphasen der Plattform.
*   [docs/SECURITY_HARDENING.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/SECURITY_HARDENING.md:1) fasst Härtung, Agentenrisiken, Tunnel-Absicherung und Secret-Hygiene kompakt zusammen.
*   [docs/PROFILE_MATRIX.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/PROFILE_MATRIX.md:1), [docs/TOOL_MATRIX.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/TOOL_MATRIX.md:1) und [docs/PORT_MATRIX.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/PORT_MATRIX.md:1) geben die aktuelle Betriebsübersicht.
*   sensible und bearbeitbare Setup-Dateien liegen jetzt außerhalb des Repos in `~/.openclaw_ultimate_user_data`.
*   über `Benutzer-Workspace verwalten` kannst du diese ausgelagerten Dateien anzeigen, neu aus dem Repo kopieren oder vollständig löschen.
*   das Setup zeichnet für wichtige Vorgänge jetzt zusätzlich reale Messwerte in `~/.openclaw_ultimate_user_data/metrics_logs/operation_history.tsv` auf.
*   die neuen zentralen Registries liegen unter `config/tools.yml`, `config/profiles.yml` und `config/ports.yml`.

### Neue Plattformprofile

Zusaetzlich zu den fachlichen Profilen gibt es jetzt eine zweite Ebene fuer den produktionsnahen Plattformbetrieb:

- [docs/Profile/llmops.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profile/llmops.md:1)
- [docs/Profile/rag_knowledge_base.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profile/rag_knowledge_base.md:1)
- [docs/Profile/openwebui_frontend.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profile/openwebui_frontend.md:1)
- [docs/Profile/mcp_toolserver.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profile/mcp_toolserver.md:1)
- [docs/Profile/ai_security_guardrails.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profile/ai_security_guardrails.md:1)
- [docs/Profile/sandbox_coding_agent.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profile/sandbox_coding_agent.md:1)
- [docs/Profile/database_backend.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profile/database_backend.md:1)
- [docs/Profile/monitoring_observability.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profile/monitoring_observability.md:1)
- [docs/Profile/backup_storage.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profile/backup_storage.md:1)

Zusätzlich gibt es zwei Profil-Verzeichnisse:

*   `docs/Profil/` enthält die fachlichen Quelltexte und Prompt-Sammlungen je Profil.
*   `docs/Profile/` enthält die daraus abgeleiteten, repo-spezifischen Profilseiten mit tatsächlichem Setup-Stand, installierbaren Tools und OpenClaw-/Ollama-Fit.

### Neue Studio- und Spezialprofile

Zusätzlich wurden spezialisierte Ausbauprofile ergänzt:

*   `Video_Generation_Studio`
*   `Image_Generation_Studio`
*   `Voice_Clone_TTS_Studio`
*   `Music_AI_Studio`
*   `Web3_Crypto_Agent`
*   `Smart_Home_AI_Assistant`
*   `Document_Intelligence`
*   `Personal_Knowledge_Memory`
*   `DevOps_SRE_Agent`
*   `Data_Analytics_BI`
*   `Game_Dev_AI`
*   `Education_Tutor`

Die gesammelte Uebersicht steht in [docs/Profile/INDEX.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profile/INDEX.md:1).

## 🛠️ Enthaltene Komponenten & Tools

Das Setup bietet eine breite Palette an Tools, die du nach Bedarf installieren und deinstallieren kannst:

*   **Ollama:** Lokales LLM-Backend mit flexiblem Modell-Management (z.B. `llama3.2:1b`, `deepseek-coder`, `mistral`). Dient als leistungsstarke lokale KI-Engine für schnelle und datenschutzsensible Anfragen.
*   **Google Gemini:** Primäres Cloud-LLM mit Fallback zu Ollama. Bietet Zugang zu den neuesten und leistungsstärksten KI-Modellen von Google, mit Ollama als zuverlässiger Notlösung.
*   **OpenManus:** GitHub-basierte Agenten-/Automationsbasis. Der Installer prüft Python-venv, Torch und optionale Build-Fallen wie `flash-attn` vorsichtig und bricht mit Reparaturhinweisen ab, statt kaputte venvs stehenzulassen.
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
*   **Kimi 2:** Lokale GitHub-Referenz/Dokumentationsbasis für Kimi-/Moonshot-Workflows. Der Installer erzwingt keine `requirements.txt`, wenn Upstream aktuell keine Python-Projektstruktur bereitstellt.
*   **Hugging Face:** Integration von Hugging Face Modellen, entweder lokal über Ollama oder über die Hugging Face Inference API. Ermöglicht den Zugriff auf eine riesige Bibliothek von vortrainierten KI-Modellen.
*   **Zotero:** Literatur- und Quellenverwaltung für Recherche- und Dokumentations-Workflows, besonders relevant für Rechts- und Wissensprofile.
*   **Home Assistant Core:** Smart Home Automatisierung. Die zentrale Steuerung für dein Smart Home, die eine Vielzahl von Geräten und Diensten integriert.
*   **Alexa Skill Integration:** Verbindung zu Alexa über Cloudflare Tunnel. Ermöglicht die Sprachsteuerung deiner Smart-Home-Geräte und KI-Agenten über Amazon Alexa.
*   **Kubernetes (K3s):** Grundlage für VPS-basierte Deployments. Das Setup bereitet einen VPS mit K3s, `kubectl` und einer sauberen Verzeichnisstruktur für nachfolgende Kubernetes-Manifeste vor.
*   **Ruflo:** Multi-Agenten- und Automatisierungsplattform mit CLI. Das Setup installiert Ruflo aus GitHub, stellt Node.js und `pnpm` bereit und verlinkt die CLI für lokale Nutzung.
*   **Multi-VPS-Strategie:** Optimierte Ressourcennutzung über mehrere kostenlose VPS. Eine Strategie zur Verteilung der Last und Erhöhung der Ausfallsicherheit durch Nutzung mehrerer Cloud-Anbieter.

Zusätzlich im neuen Ausbau:

*   **RAG / Wissensschicht:** `LightRAG`, `Qdrant`, `ChromaDB`, `Apache Tika`, `Docling`
*   **Security:** `CrowdSec`, `Semgrep`, `Syft`, `Grype`, `UFW`
*   **Monitoring / Betrieb:** `Healthchecks`, `Node Exporter`, `Promtail`
*   **Automation / UI:** `Node-RED`, `Mosquitto`, `Zigbee2MQTT`, `ESPHome`, `Appsmith`, `Budibase`, `NocoDB`, `Directus`
*   **Media / Studio:** `GFPGAN`, `Rembg`, `faster-whisper`, `Blender`

Die aktuelle kuratierte Toolübersicht steht in [docs/TOOL_MATRIX.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/TOOL_MATRIX.md:1).

## 👤 Profil-Management

### Profilgruppen

- `Core`: Programmierer, KI_Forschung, Agent_Orchestrator, LLM_Builder
- `LLMOps`: RAG_Wissensdatenbank, Monitoring_Observability, Backup_Recovery, MCP_Agent_Tools
- `Coding`: Repo_Maintainer, Developer_CI_CD, DevOps_SRE
- `Media`: Media_Musik, Visual_Creator, Image_Generation, Video_Generation, Voice_Assistant
- `Security`: Security_Analyst, Security_DevSecOps, Compliance_Privacy
- `Data`: Data_Engineering, Data_Analytics_BI, Document_AI
- `Smart Home`: Smart_Home_Automation, Smart_Home_AI_Assistant
- `Web3`: Trading_AI, Trading_Crypto_Web3, Web3_Crypto_Tools, Web3_Crypto_Agent
- `Compliance`: Compliance_Privacy

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
*   **LLM-Builder:** Profil für einen realistischen lokalen Workflow rund um Datensatzaufbereitung, LoRA/QLoRA-Fine-Tuning, GGUF-Export, Quantisierung und Ollama-Einbindung.
*   **Document Intelligence:** Profil für OCR, Rechnungen, Verträge, PDF-/Markdown-/Docx-Konvertierung und lokale RAG-Ablage.
*   **Personal Knowledge Memory:** Profil für privates Wissensgedächtnis mit lokaler Vector-DB.
*   **DevOps SRE Agent:** Profil für CI/CD, Kubernetes, IaC, Healthchecks und Betriebsautomatisierung.
*   **Data Analytics BI:** Profil für DuckDB, JupyterLab, Metabase, Reports und Analytik.
*   **Game Dev AI:** Profil für Blender-, Asset- und Dialog-/Quest-Workflows.
*   **Education Tutor:** Profil für Lernassistenten, Quiz, Karteikarten und PDF-RAG.

Wichtige Orientierung:

*   die älteren Kernprofile bleiben kompakt und einsteigerfreundlich
*   `*_Studio`- und `*_Agent`-Profile sind die vertieften Spezialpfade
*   nicht jedes neue Profil ist schon als eigener Top-Level-Eintrag im grossen Hauptmenü verdrahtet; Skripte und Doku existieren aber bereits

## 💻 Codex-Nachbau und Plattformziele

Der optionale `Codex-Nachbau` im `Programmierer`-Profil ist fuer klassische Softwareprojekte bereits sinnvoll nutzbar:

- Linux
- Windows
- Web- und API-Projekte
- Container- und Serverdienste
- allgemeine Python-, Node-, Go- und Multi-Repo-Workflows

Mit zusaetzlichen Toolchains ebenfalls gut denkbar:

- Android mit Android SDK, Gradle, Flutter oder React Native
- ESP32 mit PlatformIO oder ESP-IDF
- Arduino mit Arduino CLI oder PlatformIO

Wichtige Grenze:

- iPhone- und macOS-Nativbuilds lassen sich fachlich vorbereiten, analysieren und grossteils generieren, der finale Build, die Signierung und der App-Store-/TestFlight-Weg brauchen aber weiterhin ein echtes macOS-/Xcode-System

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
│       ├── openmanus_install.sh       # Installiert OpenManus aus GitHub mit venv-/Torch-/flash-attn-Schutzlogik
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
│       ├── Visual_Creator_uninstall.sh
│       ├── LLM_Builder_install.sh
│       └── LLM_Builder_uninstall.sh
├── docs/
│   ├── API_KEY_GUIDE.md        # Detaillierte Anleitung für API-Keys, Ports und Fallback-Routing
│   ├── INSTALLATION_BENCHMARKS.md # Editierbare Schätzwerte für Downloadzeit, Installationszeit und GB-Bedarf
│   ├── ARCHITECTURE_LLMOPS_PLATFORM.md # Neue Layer-Architektur für die produktionsreife LLMOps-Plattform
│   ├── OLLAMA_MODEL_CATALOG.md # Kuratierter Ollama-Modellkatalog mit Größen- und RAM-Hinweisen
│   ├── setup_guide.md          # Umfassende Dokumentation des gesamten Setups
│   ├── PRIVATE_REPO_GUIDE.md   # Anleitung für die Installation aus einem privaten Repository
│   ├── DNS_DDoS_GUIDE.md       # Anleitung zur DNS-Umstellung und DDoS-Schutz
│   ├── Profil/                 # Fachliche Profilquellen und Prompt-Sammlungen je Themenprofil
│   │   ├── Programmierer.doc.md
│   │   ├── Media_Musik.doc.md
│   │   ├── KI_Forschung.doc.md
│   │   ├── Texter_Werbung_Marketing.doc.md
│   │   ├── Rechtsberatung_Steuerrecht.doc.md
│   │   └── LLM-Builder.doc.md
│   └── Profile/                # Abgeleitete Profilseiten mit tatsächlichem Setup-Stand
│       ├── INDEX.md
│       ├── INCONSISTENCY_REPORT.md
│       ├── INSTALL_CHECKLIST.md
│       ├── profiles.json
│       ├── Programmierer.md
│       ├── Media_Musik.md
│       ├── KI_Forschung.md
│       ├── Texter_Werbung_Marketing.md
│       ├── Rechtsberatung_Steuerrecht.md
│       ├── LLM-Builder.md
│       ├── llmops.md
│       ├── rag_knowledge_base.md
│       ├── openwebui_frontend.md
│       ├── mcp_toolserver.md
│       ├── ai_security_guardrails.md
│       ├── sandbox_coding_agent.md
│       ├── database_backend.md
│       ├── monitoring_observability.md
│       └── backup_storage.md
├── stacks/
│   └── llmops-platform/
│       ├── docker-compose.yml  # Plattform-Stack für LiteLLM, Open WebUI, Qdrant, Langfuse, Monitoring und Storage
│       ├── .env.example        # Beispiel-Umgebungsvariablen für den Plattform-Stack
│       └── litellm-config.yaml # Routing und Fallback-Konfiguration für LiteLLM
├── config/
│   ├── tools.yml               # Zentrale Tool-Registry
│   ├── profiles.yml            # Zentrale Profil-Registry
│   └── ports.yml               # Port-Registry mit Konfliktbasis
├── configs/
│   └── .env.example            # Beispiel-Konfigurationen ohne Secrets
└── .github/
    ├── workflows/              # Shellcheck, Markdownlint, Linkcheck, Secret Scan
    └── markdown-link-check.json
```

Wichtige Ergänzung:

*   persönliche und sensible Nutzerdaten liegen **nicht** im Repo, sondern in `~/.openclaw_ultimate_user_data`
*   die Setup-Messwerte und Statusdateien werden ebenfalls im Benutzer-Workspace geführt
*   `scripts/lib/` und `scripts/operations/` enthalten die neue gemeinsame Betriebs- und Prüfungslogik

## ⚠️ Wichtige Hinweise

*   **API-Keys:** Werden während der Installation abgefragt oder müssen manuell in Konfigurationsdateien hinterlegt werden. Nutze den OpenClaw Konfigurations-Manager für die `.env` und `config.json`.
*   **`sudo`-Passwort:** Wenn `sudo` ein Passwort verlangt, ist das das Passwort deines Linux-Benutzers. Unter WSL ist das nicht dein Windows-Passwort, sondern das Passwort des Ubuntu-/Linux-Users.
*   **`zstd` Voraussetzung:** Einige Installationen oder Paketentpackungen benötigen `zstd`. Das Setup installiert `zstd` jetzt direkt mit den Basis-Abhängigkeiten.
*   **pnpm Warnung zu ignorierten Build-Skripten:** Wenn `pnpm` z. B. `@discordjs/opus@0.10.0` als ignoriertes Build-Skript meldet, bietet das Setup jetzt am Ende des OpenClaw-Builds einen separaten Bestätigungsschritt für `pnpm approve-builds` an.
*   **Ressourcen:** Das Setup ist für eine optimale Verteilung auf einen Letsung MiniPC (16GB RAM / 70GB Disk) und einen Oracle Cloud Free Tier VPS (24GB RAM) sowie weitere kostenlose VPS ausgelegt.
*   **Dynamische IP:** Hurricane Electric wird für die dynamische DNS-Auflösung des MiniPCs verwendet. Eine detaillierte Anleitung zur Umstellung und zum DDoS-Schutz findest du in `docs/DNS_DDoS_GUIDE.md`.
*   **Trading / Web3:** Keine Seed-Phrases, Private Keys oder echte Börsen-Keys im Repo oder in Dokumentationsbeispielen speichern.
*   **Cloudflare / öffentliche Ports:** Exponierte Dienste immer mit Policies, HTTPS und minimalen Freigaben absichern.
*   **Registry-System:** Die neuen Dateien unter `config/` sind die Zielstruktur für künftige automatische Menü-Generierung, aber noch nicht jede Stelle des Hauptmenüs liest bereits daraus.

Wir wünschen dir viel Erfolg bei der Einrichtung deines intelligenten, automatisierten Systems!
