# Manus-Interview: Was unser lokales KI-Setup davon nutzen kann

**Sinn und Zweck:** Aus dem Interview uebernehmen wir einen nachvollziehbaren
Entwicklungsprozess: Anforderungen, Code, Tests, lokale Vorschau, Fehlerbericht
und manuelle Freigabe. Das hilft unseren Coding-Agenten, Ergebnisse zu pruefen,
statt lediglich Quelltext zu erzeugen. Kein Manus-Konto oder Cloud-Zugang noetig.

Stand: 21.10.2026. Quelle der Anregung: vom Nutzer bereitgestellter Interviewtext.
Die Aussagen sind **kein unabhaengiger Nachweis fuer die interne Manus-Architektur**.
Der Text nennt keinen konkreten quelloffenen Manus-Preview-/Hosting-Server.
Deshalb wird hier kein fremdes Repository als offizielles Manus ausgegeben.
Die unten verlinkten Open-Source-Projekte sind eigenstaendige Alternativen.

## Einordnung und GitHub-Quellen

Ergaenzung vom 22.10.2026: [Toolauswahl und weiterer Manus-Interviewabgleich](manus-interview-2026-10-22.md)
mit dem separaten Repository-Skill `sprach-infra-tooling`. Vorhandene CI-Beispiele
und Folien werden weiterverwendet; Manus-interne Links sind keine lokalen Artefakte.

Neu: [Wiederverwendbarer Skill, Go-/Rust-CI und Deployment](manus-ci-cd-deployment.md)
mit konkreten, inaktiven Pipeline-Beispielen und einer Praesentation.

Weitere Stacks: [Sprachen, Shells und Infrastruktur](manus-language-infrastructure-sources.md)
fuer JS/TS, Go, C/C++, Rust, Bash, PowerShell, SQL, Container, Kubernetes und IaC.
Quellenangaben sind keine neuen Installationen oder Systemfreigaben.

Die nachgereichten **30 offiziellen Werkzeug-Repositories** sind im
[vollstaendigen Quellenkatalog](manus-development-sources.md) nach Themen
aufgeschluesselt, einschliesslich uv, pre-commit, Coverage.py, Hypothesis,
Starlette, Pydantic, Uvicorn und CI. Dort sind auch Repository-Umzuege und die
**archivierte Playwright GitHub Action** mit ihrer CLI-Alternative dokumentiert.
Offizielle Werkzeugquellen sind kein Nachweis fuer die interne Manus-Toolchain.

| Baustein | Aufgabe | Quelle / Lizenzhinweis | Integration / Bedarf / Risiko |
|---|---|---|---|
| Python, venv, pip | Isolierte Projektumgebung | [CPython](https://github.com/python/cpython), PSF; [pip](https://github.com/pypa/pip), MIT | Bereits Grundlagen; fehlendes ensurepip beachten, kein globales pip |
| Git | Diffs und versionierte Aenderungen | [git/git](https://github.com/git/git), GPL-2.0 | Bereits vorhanden; Commit/Push brauchen Freigabe |
| pytest | Funktions-/Regressionstests | [pytest-dev/pytest](https://github.com/pytest-dev/pytest), MIT | Vorhandener Tool-Eintrag; Testcode/Plugins werden ausgefuehrt |
| Black | Einheitliche Python-Formatierung | [psf/black](https://github.com/psf/black), MIT | **Neu optional installierbar** aus GitHub; 2 GiB Disk-Reserve, kein Autoformat |
| mypy | Statische Python-Typpruefung | [python/mypy](https://github.com/python/mypy), MIT plus eingebundene Lizenzen | **Neu optional installierbar** aus GitHub; 2 GiB Disk-Reserve, Pluginrisiko |
| Ruff | Linting und alternative Formatierung | [astral-sh/ruff](https://github.com/astral-sh/ruff), MIT | Anleitung/Alternative, kein neuer Menue-Installer; Source-Build braucht Rust/Cargo |
| FastAPI | Typisierte lokale APIs | [fastapi/fastapi](https://github.com/fastapi/fastapi), MIT | Projektabhaengigkeit, kein globaler Dienst; ASGI-Server separat erforderlich |
| Flask / Django | Kleines Backend / vollstaendige Webanwendung | [pallets/flask](https://github.com/pallets/flask), BSD-3-Clause; [django/django](https://github.com/django/django), BSD-3-Clause | Projektentscheidung, nicht alle Frameworks parallel installieren |
| React / Vite / TypeScript | Weboberflaeche, Dev-Server, Typen | [react/react](https://github.com/react/react), MIT; [vitejs/vite](https://github.com/vitejs/vite), MIT; [microsoft/TypeScript](https://github.com/microsoft/TypeScript), Apache-2.0 | Projektlokal; Node-/Paketmanager-Version am jeweiligen Pin pruefen |
| Playwright | Browsertests und Screenshots | [microsoft/playwright](https://github.com/microsoft/playwright), Apache-2.0 | Vorhandener Baustein; Browserdownload und RAM/Disk separat freigeben |
| WebsiteFactory | Briefing zu Astro-/Tailwind-Projekt | [Unser Repository](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation) | Vorhandener Prototyp, keine Manus-Hosting-Garantie |
| Jupyter, pandas, NumPy | Explorative Datenanalyse | [jupyterlab](https://github.com/jupyterlab/jupyterlab), BSD-3-Clause; [pandas](https://github.com/pandas-dev/pandas), BSD-3-Clause; [numpy](https://github.com/numpy/numpy), BSD-3-Clause | Nur bei Datenaufgaben; Notebooks koennen Code ausfuehren |

Die neuen Installer und ihre Voraussetzungen stehen unter
[Black und mypy](../tools/dev-quality.md). Vorhandene pytest-/Playwright-Installer
werden hier **nicht** heimlich migriert: Der bisherige pytest-Helfer nutzt PyPI
und apt, ist also noch kein ausschliesslicher GitHub-Installationspfad. Die
Tabelle unterscheidet GitHub-Quellen von tatsaechlich implementierten Installern.
Node, Browser, Datenbanken und Modelle werden nicht automatisch nachinstalliert.

## 1. Projekt klein und isoliert aufbauen

```text
mein-projekt/
  pyproject.toml
  src/meinpaket/__init__.py
  tests/test_core.py
  README.md
  .gitignore
  docs/build-report.md
```

Ein virtueller Python-Interpreter ersetzt keine Sandbox. Fuer Python-Projekte
genuegt haeufig pytest plus **entweder** Black **oder** Ruff-Formatierung.
Nicht beide Formatierer abwechselnd auf dieselben Dateien anwenden.
Das Beispiel unter [examples/dev-quality/](../../examples/dev-quality/README.md)
enthaelt bewusst keine Paketinstallation und keine automatische Repo-Formatierung.

## 2. Pruefungen vor Aenderungen festlegen

```bash
python -m pytest tests/
python -m black --check --diff src/ tests/
python -m mypy src/
```

Diese Befehle setzen eine bewusst vorbereitete Projektumgebung voraus. Alternativ
Black/mypy ueber ihre privaten Interpreterpfade aufrufen; siehe Tool-Anleitung.
Ruff kann Linting und Formatpruefung liefern, wenn es separat vorhanden ist:

```bash
ruff check src/ tests/
ruff format --check src/ tests/
```

Statische Typpruefung beweist keine korrekte Geschaeftslogik. Tests pruefen nur
abgedeckte Faelle. Erfolg darf nicht aus einem Beispielbericht abgeleitet werden:
immer echte Exit-Codes, Testzahlen und verbleibende Luecken dokumentieren.

## 3. Lokale Vorschau sicher starten

Der Interviewbefehl `python -m http.server 8000` bindet ohne Einschraenkung auch
an Netzwerkschnittstellen. Fuer eine reine statische Vorschau stattdessen:

```bash
python -m http.server 8000 --bind 127.0.0.1 --directory ./public
```

`./public` muss ausschliesslich die freigegebenen statischen Ausgabedateien
enthalten, niemals `.env`, Personalakten, Wallets oder das ganze Home-Verzeichnis.
Dies ist kein FastAPI-/Django-Server und keine Produktiv-Hostingloesung.
Port vorher mit der vorhandenen [Portpruefung](../../scripts/check_ports.sh)
kontrollieren; keinen fremden Prozess beenden, um den Port frei zu machen.

Bei einem bewusst vorbereiteten Vite-Projekt z.B.:

```bash
pnpm dev --host 127.0.0.1 --port 5173 --strictPort
```

Dieses Beispiel braucht ein passendes `dev`-Skript. Es installiert kein Vite.
Build, Vorschau und Produktiv-Deployment sind unterschiedliche Schritte.
Entwicklungsserver anschliessend bewusst stoppen. Keine `0.0.0.0`-Freigabe,
kein Tunnel, Docker-, Firewall- oder Kubernetes-Eingriff durch diese Anleitung.
Externe Fonts, Analytics oder APIs koennen trotz lokalem Preview Daten senden.

## 4. Browserpruefung und Bericht

Mit bereits freigegebenem Playwright mindestens Desktop und Mobile pruefen:
Hauptseite erreichbar, Navigation, Formulare/Fehlermeldungen, Konsole und
Netzwerkfehler. Screenshots mit synthetischen Testdaten anlegen, nicht mit
echten Kundeninformationen. Der Screenshot allein beweist keine Funktion.
Server-/Browserstart, Downloads und Testskripte erfordern eigene Freigabe.

Im Bericht festhalten: Git-Commit/Basisstand, verwendete Versionen, Befehle,
Exit-Codes, Dauer, Screenshots, fehlgeschlagene Checks und bewusst nicht
ausgefuehrte Tests. Keine API-Keys, Cookies oder kompletten HTTP-Header loggen.

## 5. Queue und begrenzte Korrekturschleife

[Unsere Queue](../CODEX_TASK_QUEUE.md) kann freigegebene einzeilige Test-/Build-
Kommandos seriell abarbeiten. Beispiel vom Setup-Root aus:

```bash
bash scripts/queue/queue_add.sh --priority normal -- 'cd /absoluter/projektpfad && python -m pytest tests/'
bash scripts/queue/queue_status.sh
# Erst nach ausdruecklicher Ausfuehrungsfreigabe:
bash scripts/queue/queue_run_next.sh
```

Projektpfad vor Nutzung anpassen, bei Leerzeichen zusaetzlich korrekt quoten.
Ein Queue-Eintrag fuehrt noch nichts aus. Nicht direkt das ganze Repo in einen
Endlos-Agenten geben. **Maximal drei Korrekturrunden pro Aufgabe**, dann mit
Fehlerbericht anhalten. Dies ist eine Agentenvorgabe, kein neu implementierter
technischer Drei-Runden-Guard. Die Queue ist keine harte Ressourcen-Sandbox.

## 6. Agentenrollen einschliesslich Automaton

| Rolle | Freigegebene Arbeit | Grenze |
|---|---|---|
| Jarvis / OpenClaw | Aufgabe und vorhandene Queue koordinieren | Keine implizite Systemadministration |
| Ollama-Coder | Lokale Vorschlaege und begrenzte Patches | Lokales Modell muss selbst bereitstehen |
| Claude Code / Qwen Code / Gemini CLI | Implementierung und Bericht im freigegebenen Projekt | API-Nutzung separat bewilligen, keine Keys in Prompts |
| Automaton | Dieselben abgegrenzten Entwicklungsaufgaben nach separater Einrichtung | Keine Wallet, Zahlung, Replikation oder selbststaendige Tool-Installation hier freigeben |

Beispiel fuer einen gemeinsamen Arbeitsauftrag:

```text
Arbeite nur im ausdruecklich freigegebenen Projektordner.
Lies die Aufgabe und vorhandene Tests, plane einen kleinen Patch.
Nutze nur zuvor freigegebene lokale Werkzeuge und synthetische Testdaten.
Fuehre die vereinbarten Tests aus, dokumentiere echte Exit-Codes.
Maximal drei Korrekturrunden; danach mit Fehlerbericht stoppen.
Keine Paketinstallation, Cloud-Abfrage, Wallet, USB-/WSL-Aktion oder Serverfreigabe.
Kein git reset --hard, automatischer Commit, Push oder Deployment.
Bei fehlenden Rechten, Speicherplatz oder Werkzeugen mit Diagnose stoppen.
```

Diese Rollenteilung ist ein **Konzept und Prompt**, keine bereits eingerichtete
Verbindung zwischen den Runtimes. Weiter: [Automaton](../tools/automaton.md),
[Coding-Agenten](../agents/coding-agent-profiles.md),
[WebsiteFactory](../tools/websitefactory.md), [Agentic Coding](../tools/agentic-coding.md).

## 7. Git erst nach Pruefung

`git status` und `git diff` vor/nach dem Patch vergleichen. Nur passende Dateien
stagen, nicht pauschal `git add .`; `.env`, venvs, Browserprofile und persoenliche
Daten ausschliessen. Unabhaengige Nutzer-Aenderungen bleiben erhalten.
Commit, Push und Veroeffentlichung sind jeweils bewusste Betreiberentscheidungen.
Lokale Aenderungen in diesem Setup sind noch keine Aktualisierung auf GitHub.
