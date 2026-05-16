# Code Sandbox Usage Guide

## Kurzfassung

`Code_Sandbox` ist in diesem Repository aktuell ein vorbereitetes Sandbox-Modul. Es ist noch kein vollstaendiger, automatisch isolierender Container-Runner und kein eigenes Webinterface.

Die Installation erzeugt vor allem eine klare Arbeitsstruktur unter:

```bash
/opt/code_sandbox
```

Dort liegen u. a.:

```text
/opt/code_sandbox/README.md
/opt/code_sandbox/.env.template
/opt/code_sandbox/run.sh
```

Der aktuelle `run.sh` ist bewusst nur ein Platzhalter:

```bash
echo "Nutze Docker-Container oder ein eigenes Jail-System als Sandbox-Backend."
```

Das ist wichtig: Die Installation markiert das Modul als vorbereitet, aber sie fuehrt noch keine fremden Programme wirklich isoliert aus.

## Warum gibt es Code_Sandbox?

Das Modul ist als Sicherheits- und Workflow-Baustein fuer Coding-Agenten gedacht:

- OpenClaw soll spaeter Code nicht direkt auf dem Host ausfuehren.
- Programmierer-/LLM-Builder-Profile brauchen einen Ort fuer Tests, Builds und Experimente.
- Agentische Tools wie OpenHands, Aider, AutoGen, CrewAI oder LangGraph sollen riskante Aktionen nur in begrenzten Umgebungen ausfuehren.
- Docker, Podman, Devcontainer oder spaeter K3s koennen als Backend dienen.

## Aktuelle Nutzung

Nach der Installation kannst du den vorbereiteten Ordner ansehen:

```bash
ls -la /opt/code_sandbox
cat /opt/code_sandbox/README.md
cat /opt/code_sandbox/.env.template
```

Die Vorlage enthaelt aktuell:

```env
SANDBOX_RUNTIME=docker
SANDBOX_TIMEOUT_SECONDS=30
SANDBOX_MEMORY_LIMIT=1g
```

Damit ist dokumentiert, welche Laufzeit spaeter verwendet werden soll. Es ist aber noch keine vollstaendige Ausfuehrungslogik eingebaut.

## Kombinationen mit anderen Tools

| Tool/Profil | Rolle von Code_Sandbox | Status |
|---|---|---|
| OpenClaw | sichere Ausfuehrungsumgebung fuer Tool-Tasks | geplant |
| Programmierer | Tests, Builds, Repo-Experimente isolieren | vorbereitet |
| LLM_Builder | Trainings-/Build-Hilfsschritte begrenzen | vorbereitet |
| OpenHands | Agentenaktionen in Container/Jail auslagern | geplant |
| Aider | Tests nach Codeaenderungen in Sandbox ausfuehren | geplant |
| AutoGen/CrewAI/LangGraph | Worker duerfen nur Sandbox-Kommandos nutzen | geplant |
| Docker/Podman | moegliches Sandbox-Backend | Voraussetzung |
| Devcontainer CLI | reproduzierbare Projektumgebung | sinnvoller naechster Schritt |
| K3s | spaeter isolierte Worker-Jobs | advanced |

## Minimaler manueller Sandbox-Test mit Docker

Wenn Docker installiert ist, kann man heute bereits manuell eine einfache Wegwerf-Sandbox starten:

```bash
mkdir -p "$HOME/.openclaw_ultimate_user_data/code_sandbox/work"
docker run --rm \
  --network none \
  --memory 1g \
  --cpus 1 \
  -v "$HOME/.openclaw_ultimate_user_data/code_sandbox/work:/work:rw" \
  -w /work \
  python:3.12-slim \
  python --version
```

Das ist ein Beispiel fuer das Zielverhalten:

- kein Netzwerk
- begrenzter Speicher
- begrenzte CPU
- nur ein definierter Arbeitsordner gemountet
- Container wird nach dem Lauf geloescht

## Was noch nicht automatisch passiert

- Kein automatischer Docker-Runner fuer beliebige Kommandos.
- Keine OpenClaw-Tooldefinition fuer Sandbox-Ausfuehrung.
- Keine Policy-Datei fuer erlaubte Kommandos.
- Kein automatisches Kopieren von Repos in einen isolierten Workspace.
- Kein Ergebnisformat fuer Build-/Testberichte.
- Keine harte Isolation gegen alle Host-Risiken.

## OpenClaw-Zielbild

```text
OpenClaw Task
  -> scripts/code_sandbox/run_in_sandbox.sh
  -> Docker/Podman/Devcontainer
  -> begrenzter Workspace
  -> Test-/Build-Ergebnis als Markdown/JSON
  -> OpenClaw liest Ergebnis ein
```

Empfohlener Benutzerpfad:

```bash
~/.openclaw_ultimate_user_data/code_sandbox/
```

## Sicherheitsregeln

- Keine Secrets in den Sandbox-Workspace kopieren.
- Netzwerk standardmaessig deaktivieren.
- Nur erlaubte Repositories/Ordner mounten.
- Keine Docker-Socket-Mounts in Agenten-Sandboxes.
- Keine `--privileged` Container.
- CPU, RAM und Timeout begrenzen.
- Ergebnisse und Logs redigieren, bevor sie in Reports oder E-Mails gehen.

## TODO fuer spaeter

- [ ] `scripts/code_sandbox/run_in_sandbox.sh` erstellen.
- [ ] Policy-Datei `~/.openclaw_ultimate_user_data/code_sandbox/policy.env` einfuehren.
- [ ] Docker-Backend mit `--network none`, `--memory`, `--cpus`, Timeout.
- [ ] Optional Podman-Backend.
- [ ] Optional Devcontainer-Backend fuer Repo-nahe Projekte.
- [ ] OpenClaw-Tooldefinition fuer Sandbox-Kommandos.
- [ ] Doctor-Check fuer Docker/Podman und Sandbox-Testlauf.
- [ ] Ergebnisformat `reports/code_sandbox/*.md` und `*.json`.
