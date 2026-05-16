# Aider Integration Guide

## Zweck

Aider ist ein terminalbasierter Coding-Agent fuer Git-Repositories. Er eignet sich fuer Patch-Erstellung, Refactoring, kleinere Features, Tests, Code-Erklaerungen und Git-Diff-basierte Arbeit.

Im Setup ist Aider als Coding-Agent-Tool gedacht, nicht als dauerhafter Webdienst. Es laeuft direkt im Terminal im jeweiligen Projektordner.

## Installation im Setup

Der Installer legt Aider standardmaessig unter `/opt/aider` ab und erstellt dort eine Python-Umgebung.

Wichtiger Reparaturhinweis:

- Wenn eine fruehere Installation `/opt/aider` mit Root-Rechten angelegt hat, kann ein normaler `rm -rf /opt/aider` scheitern.
- Der gemeinsame Scaffold-Installer entfernt alte `/opt/<tool>`-Reste deshalb mit `sudo`, aber nur fuer sichere Pfade wie `/opt/*` oder den User-Home-Bereich.
- Dadurch betrifft der Fix auch aehnliche Scaffold-Tools, ohne beliebige Loeschpfade zu erlauben.

## Schnelltest

```bash
cd /opt/aider
source venv/bin/activate
aider --version || python -m aider --version
```

Wenn der direkte `aider`-Befehl nicht gefunden wird:

```bash
find /opt/aider/venv -type f -name aider -o -name "aider*"
python -m aider --help
```

## Nutzung im Repository

Vor jeder Nutzung sollte der Git-Status sauber oder bewusst verstanden sein:

```bash
cd ~/openclaw_ultimate_setup
git status --short
source /opt/aider/venv/bin/activate
aider
```

Mit lokalem Modell ueber Ollama oder LiteLLM ist je nach Aider-Version eine passende Provider-Konfiguration noetig. Praxisnah ist:

```bash
cd ~/openclaw_ultimate_setup
source /opt/aider/venv/bin/activate
aider --model ollama_chat/qwen2.5-coder:7b
```

Wenn ein LiteLLM-Gateway genutzt wird, sollte Aider gegen die OpenAI-kompatible Gateway-URL konfiguriert werden. API-Schluessel gehoeren nicht ins Repository, sondern in die ausgelagerte User-Konfiguration unter `~/.openclaw_ultimate_user_data`.

## Sinnvolle Kombinationen

- `Ollama`: lokale Coding-Modelle wie Qwen Coder, DeepSeek Coder oder CodeLlama.
- `LiteLLM`: einheitliches Gateway fuer lokale und externe Modelle.
- `OpenClaw`: kann Aider spaeter als Terminal-/Patch-Werkzeug ansteuern.
- `Code_Sandbox`: Tests und riskante Befehle getrennt ausfuehren.
- `pre-commit`, `ruff`, `black`, `eslint`, `shellcheck`: Qualitaetskontrolle nach Aider-Aenderungen.
- `act`: GitHub-Actions-Workflows lokal pruefen.

## Sicherheitsregeln

- Aider nur in bewusst ausgewaehlten Repositories starten.
- Vorher `git status --short` pruefen.
- Keine Secrets, Tokens, SSH-Keys oder `.env`-Dateien in Prompts einfuegen.
- Aenderungen immer mit `git diff` pruefen.
- Tests lokal ausfuehren, bevor Aenderungen uebernommen oder gepusht werden.
- Bei produktiven Systemskripten zuerst im `Code_Sandbox`- oder Testmodus pruefen.

## OpenClaw-Integration als TODO

Geplanter Ausbau:

- Wrapper `scripts/aider/run_aider_task.sh` fuer kontrollierte Aider-Aufgaben.
- Allowlist fuer erlaubte Arbeitsverzeichnisse.
- Optionaler Dry-Run-Modus mit Patch-Ausgabe statt Direktedit.
- OpenClaw-Tooldefinition fuer "Repo analysieren", "Patch vorschlagen", "Tests starten".
- Automatischer Nachtest mit `scripts/doctor.sh`, `scripts/validate_config.sh` und passenden Projekt-Tests.

## Einordnung

Aider ist fuer das Programmierer-/Codex-Sandbox-Setup besonders sinnvoll. Auf einem schwachen MiniPC sollte es bevorzugt mit kleinen lokalen Modellen oder ueber LiteLLM-Fallback genutzt werden. Auf GPU-Workstations kann es direkt mit groesseren lokalen Coding-Modellen arbeiten.
