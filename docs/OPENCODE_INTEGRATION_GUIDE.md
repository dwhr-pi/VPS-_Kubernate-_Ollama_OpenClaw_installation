# OpenCode Integration Guide

## Zweck

OpenCode ist als Codex-aehnlicher Coding-Agent-Workspace gedacht. Im Setup wird es als optionales Coding-Agent-Scaffold vorbereitet und unter `/opt/opencode` geklont.

OpenCode ist kein klassischer Hintergrunddienst wie Huginn oder Grafana. Je nach Upstream-Stand wird es ueber das im geklonten Repository dokumentierte CLI- oder App-Startkommando genutzt.

## Installationshinweis

Der Installer nutzt den gemeinsamen Scaffold-Helper. Wenn eine alte Installation `/opt/opencode` mit Root-Rechten angelegt hat, kann eine alte Helper-Version beim Neu-Klonen mit folgendem Fehler scheitern:

```txt
rm: cannot remove '/opt/opencode': Permission denied
```

Aktueller Fix:

- Der Scaffold-Helper entfernt alte `/opt/<tool>`-Reste mit `sudo`.
- Der Loeschpfad ist auf sichere Ziele wie `/opt/*` oder den User-Home-Bereich begrenzt.
- Das leere Zielverzeichnis wird danach mit korrekten User-Rechten neu angelegt, bevor `git clone` startet.
- Im Log erscheint jetzt der Hinweis `Scaffold-Helper: sichere /opt-Aufraeumroutine aktiv.`

Wenn dieser Hinweis im neuen Log fehlt, wurde noch eine alte Setup-Kopie gestartet.

## Schnelltest nach Installation

```bash
cd /opt/opencode
git status --short
git rev-parse --short HEAD
ls -la
```

Danach die aktuelle Upstream-Anleitung pruefen:

```bash
sed -n '1,180p' README.md
find . -maxdepth 2 -iname "package.json" -o -iname "pnpm-workspace.yaml" -o -iname "bun.lockb" -o -iname "bun.lock"
```

## Nutzung mit Ollama oder LiteLLM

Die vorbereitete `.env.template` nutzt lokale Defaults:

```env
OPENCODE_PROVIDER=ollama
OPENCODE_MODEL=qwen3-coder:30b
OLLAMA_HOST=http://127.0.0.1:11434
```

Fuer schwache MiniPCs sollte ein kleineres Coding-Modell genutzt werden, zum Beispiel ein 7B-Coder-Modell. Fuer GPU-Workstations kann ein groesseres Modell sinnvoll sein.

## Kombinationen

- `Ollama`: lokale Coding-Modelle.
- `LiteLLM`: OpenAI-kompatibles Gateway und Fallbacks.
- `OpenClaw`: spaetere Steuerung als Repo-Analyse-/Patch-Agent.
- `Code_Sandbox`: sichere Testausfuehrung fuer generierte Patches.
- `Aider`: Alternative oder Ergaenzung fuer terminalbasierte Patch-Arbeit.

## Sicherheitsregeln

- Nicht direkt auf produktiven Repositories ohne sauberen Git-Status arbeiten.
- Keine Secrets oder `.env`-Dateien in Prompts kopieren.
- Patches immer mit `git diff` pruefen.
- Autonome Shell-Aktionen nur in erlaubten Projektordnern ausfuehren.

## TODO fuer OpenClaw

- Wrapper `scripts/opencode/run_opencode_task.sh` erstellen.
- Allowlist fuer erlaubte Repositories ergaenzen.
- Ergebnisformat Markdown/JSON unter `~/.openclaw_ultimate_user_data/opencode/runs/` festlegen.
- Doctor-Check fuer `/opt/opencode`, Git-Ref und Startkommando ergaenzen.
