# Tool Usage and Integration Guide

Diese Datei beschreibt die grundsaetzliche Nutzungskategorie der Tools. Ziel: Ein Tool soll nicht nur installiert sein, sondern auch klar als Dienst, CLI, Web-UI, Desktopprogramm, Bibliothek oder Integrationsbaustein verstanden werden.

## Tool-Kategorien

| Kategorie | Start/Nutzung | Beispiele | Hinweis |
|---|---|---|---|
| Dienst mit Web-UI | systemd, Docker, Compose oder lokaler Server | Huginn, n8n, Open WebUI, Grafana, Uptime Kuma | braucht Port, Auth, Healthcheck |
| API-Dienst | lokaler HTTP-Port | Ollama, LiteLLM, Qdrant, Meilisearch | meist kein Desktopfenster |
| CLI-Tool | Terminalbefehl | gh, aider, opencode, podman, gitleaks, trivy, syft, grype, restic, rclone | gut fuer Doctor/Automation |
| Python-Bibliothek | Python-Skript/venv | LangGraph, LlamaIndex, CrewAI, AutoGen | wird importiert, nicht gestartet |
| Desktopprogramm | Fenster/GUI | Blender, Android Studio, teils OBS | eher Windows/Linux-Desktop |
| Browser-App/PWA | Webinterface im Browser | Open WebUI, Grafana, Home Assistant, Nextcloud | Android oft via Browser oder App |
| Mobile-App-Anbindung | offizielle oder kompatible App | Tailscale, Home Assistant, Nextcloud, Grafana | Server bleibt lokal/VPS |

## Beispiele fuer direkte Nutzung

| Tool | Nutzung |
|---|---|
| Ollama | `ollama serve`, `ollama run llama3.2` |
| Open WebUI | Browser auf Port `3000`, ideal via Tailscale oder lokal |
| LiteLLM | API-Gateway auf Port `4000`, Clients nutzen OpenAI-kompatible API |
| Qdrant | Vektor-DB auf Port `6333`, Nutzung ueber RAG-Skripte |
| ChromaDB | Python-Vektorstore oder lokaler Server; wird erst durch RAG-/Memory-Skripte genutzt, nicht automatisch durch Ollama/OpenClaw |
| Huginn | Web auf Port `3002`, Worker via `huginn-worker.service` |
| n8n | Web auf Port `5678`, Credentials nur im User-Workspace |
| GitHub CLI | `gh --version`, `gh auth status`; fuer Issues, PRs und Actions |
| Aider | `source /opt/aider/venv/bin/activate`, dann im Git-Repo `aider` starten |
| OpenCode | Scaffold unter `/opt/opencode`; Upstream-README pruefen und mit Ollama/LiteLLM konfigurieren |
| Podman | `podman --version`, `podman info`; Container-Runtime, kein Webinterface |
| Clawbake | Advanced Kubernetes/OpenClaw-Operator unter `/opt/clawbake`; Go/Make/Helm/K3s-Kontext |
| LangGraph | `source /opt/langgraph/venv/bin/activate`, dann Python-Skript ausfuehren |
| CrewAI | `source /opt/crewai/venv/bin/activate`, dann Python-Team/Skript ausfuehren |
| AutoGen | `source /opt/autogen/venv/bin/activate`, dann Python-Agentenchat/Skript ausfuehren |
| Playwright | `source /opt/playwright/venv/bin/activate`, dann `python -m playwright install chromium` und eigene Browser-Skripte ausfuehren |
| Flowise | Web-UI fuer visuelle LLM-Flows |
| Code_Sandbox | vorbereitetes Modul unter `/opt/code_sandbox`; braucht spaeter Docker/Podman/Devcontainer-Runner |
| LangFlow | Web-UI/Python-nahe visuelle LLM-Flows |
| Aider | Terminal-Coding-Agent im Git-Repo |
| Continue.dev | IDE-Erweiterung, nicht Serverdienst |
| ClamAV | `clamscan`, Signaturen via `freshclam` |
| YARA | `yara rules.yar datei` |

## Integrationsreife

| Reife | Bedeutung |
|---|---|
| `direct` | Tool kann nach Installation direkt genutzt oder gestartet werden |
| `service` | Tool braucht Dienststart, Port und ggf. Login |
| `library` | Tool muss in Skript/Projekt eingebunden werden |
| `bridge-needed` | Tool ist installiert, braucht aber noch Adapter fuer OpenClaw/n8n/Huginn |
| `planned` | dokumentiert, aber noch keine vollautomatische Nutzung |

## Tools, die Bibliotheken statt Apps sind

Diese Tools sind wichtig, wirken aber nach Installation "unsichtbar":

- Aider
- OpenCode
- GitHub CLI
- Podman
- Clawbake
- LangGraph
- CrewAI
- AutoGen
- Playwright
- ChromaDB
- Code_Sandbox
- LlamaIndex
- LangChain-nahe Pakete
- CrewAI
- AutoGen
- OpenLIT
- manche RAG-/Parser-Pakete

Fuer diese Tools sollten kuenftig Beispielskripte und OpenClaw-Adapter angelegt werden.

## OpenClaw-Integration als Standardmuster

```text
OpenClaw
  -> klares Toolskript unter scripts/<bereich>/
  -> nutzt CLI/API/Bibliothek
  -> schreibt Ergebnis nach ~/.openclaw_ultimate_user_data/reports/
  -> OpenClaw liest Ergebnis wieder ein
```

## TODO fuer alle Bibliothekstools

- [ ] Kurzen Import-/Smoke-Test im jeweiligen Installationsskript ergaenzen.
- [ ] Beispielskript unter `examples/` oder `scripts/examples/` anlegen.
- [ ] Ergebnisformat als Markdown und JSON definieren.
- [ ] Doctor-Check ergaenzen.
- [ ] Dokumentieren, ob OpenClaw, n8n, Huginn oder ein CLI-Aufruf die bevorzugte Integration ist.
