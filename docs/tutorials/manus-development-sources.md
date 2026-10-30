# Entwicklungswerkzeuge: ergaenzte Quellen aus dem Manus-Interview

Anwendung: [Skill, CI/CD-Beispiele und Deployment](manus-ci-cd-deployment.md).

Fortsetzung: [Sprachen, Shells und Infrastruktur](manus-language-infrastructure-sources.md) mit 62
GitHub-Referenzen, Mirror-/Lizenzgrenzen und getrennten Freigaben fuer Tests, Container, Cluster,
SQL und Cloud.

**Sinn und Zweck:** Nachschlagewerk fuer die 30 nachgereichten GitHub-Quellen: Python-Projekte
isolieren, Code pruefen, Webanwendungen lokal anzeigen und reproduzierbare CI-Pruefungen
vorbereiten. Die Links verweisen auf die jeweiligen Werkzeugprojekte, **nicht auf Manus-Quellcode**.
Die Liste belegt nicht, welche Versionen oder internen Dienste Manus tatsaechlich nutzt.

Pruefstand: **21.10.2026**. Alle 30 Adressen anhand oeffentlicher GitHub-Metadaten auf
Erreichbarkeit, aktuelles Repository-Ziel und Archivstatus geprueft; wichtige Anwendungshinweise
zusaetzlich in Upstream-READMEs. Keine vollstaendige Code-/ Supply-Chain-Pruefung oder
Liveinstallation. Ein GitHub-Lizenzfeld `NOASSERTION` ist kein Lizenzurteil: Lizenzdateien am
ausgewaehlten Commit lesen.

**Integration bedeutet nicht Installation:** Black und mypy besitzen optionale GitHub-Installer.
Andere Eintraege sind vorhandene Bausteine, projektlokale Bibliotheken oder Quellen fuer einen
spaeteren Ausbau. Diese Ergaenzung installiert nichts und registriert keine ungetesteten Platzhalter
als einsatzbereite Tools. Kein Docker, WSL-Zugriff, Hook-/Runner-Start oder Push.

## Python und Entwicklungsumgebung

| Projekt / offizielle GitHub-Quelle                                          | Zweck im Setup                           | Einordnung / Grenze                                                                    |
| --------------------------------------------------------------------------- | ---------------------------------------- | -------------------------------------------------------------------------------------- |
| [CPython](https://github.com/python/cpython)                                | Interpreter, venv, Standardbibliothek    | Vorhandene Laufzeit bewusst waehlen; kein System-Python-Ersatz                         |
| [pip](https://github.com/pypa/pip)                                          | Python-Pakete installieren               | Privates venv; GitHub-Hauptquelle bedeutet nicht GitHub fuer alle Dependencies         |
| [Python Packaging User Guide](https://github.com/pypa/packaging.python.org) | Referenz fuer pyproject und Paketierung  | Dokumentationsprojekt, kein installierbarer Dienst                                     |
| [uv](https://github.com/astral-sh/uv)                                       | Paket-/Projektverwaltung und Lockdateien | Neu dokumentierte Alternative, noch kein Setup-Installer; Rust fuer Source-Build       |
| [Jupyter Notebook](https://github.com/jupyter/notebook)                     | Interaktive Analysen                     | Eigenes Projekt neben JupyterLab; nur Loopback mit Auth, Notebook-Code ist ausfuehrbar |

uv kann auch Python-Versionen und Tools nachladen. Eine spaetere Integration muss Downloadfreigabe,
Plattform, Pruefsummen, Cache, Disk, Pins und Deinstallation eigens regeln. `uv run`/`uv sync` sind
keine generell offline oder nebenwirkungsfreien Pruefbefehle. Kein blindes `curl | sh` oder
PowerShell- `iex` aus der README uebernehmen. Funktionsquelle:
[uv-README](https://github.com/astral-sh/uv#readme).

## Qualitaetssicherung und Tests

| Projekt / offizielle GitHub-Quelle                          | Zweck im Setup                                | Einordnung / Grenze                                                                        |
| ----------------------------------------------------------- | --------------------------------------------- | ------------------------------------------------------------------------------------------ |
| [pytest](https://github.com/pytest-dev/pytest)              | Unit-, Integrations-, Regressionstests        | Vorhandener Registry-Eintrag; bisheriger Installer nutzt PyPI/apt, keine Migration hier    |
| [Ruff](https://github.com/astral-sh/ruff)                   | Linting und alternative Formatierung          | Dokumentierte Alternative, kein neuer Menue-Installer; Source-Build braucht Rust/Cargo     |
| [Black](https://github.com/psf/black)                       | Einheitliche Formatierung                     | Optionaler gepinnter GitHub-Installer; zuerst --check --diff                               |
| [mypy](https://github.com/python/mypy)                      | Statische Typpruefung                         | Optionaler gepinnter GitHub-Installer; Konfiguration/Plugins pruefen                       |
| [pre-commit](https://github.com/pre-commit/pre-commit)      | Git-Hooks verwalten                           | Bereits Registry-Eintrag und .pre-commit-config.yaml; keine automatische Aktivierung       |
| [Coverage.py](https://github.com/coveragepy/coveragepy)     | Ausgefuehrte Codebereiche messen              | Neu dokumentierte Projektabhaengigkeit, kein neuer Installer                               |
| [Hypothesis](https://github.com/HypothesisWorks/hypothesis) | Property-based Tests mit generierten Eingaben | Neu dokumentierte Projektabhaengigkeit; Beispiele, Datenzugriff und Job-Laufzeit begrenzen |

Die alte Adresse [nedbat/coveragepy](https://github.com/nedbat/coveragepy) wird aktuell auf
`coveragepy/coveragepy` weitergeleitet. Beide Links bleiben nachvollziehbar; keinen ungeprueften
gleichnamigen Fork waehlen.

Schlanker Einstieg: vorhandene Tests plus **ein** Formatierer, optional mypy. Ruff-Linting kann
Black ergaenzen; Ruff-Formatierung und Black nicht abwechselnd als konkurrierende Formatierer
verwenden. Coverage zeigt ausgefuehrte Zeilen, nicht automatisch sinnvolle Assertions oder
Fehlerfreiheit. Hypothesis ergaenzt Beispieltests, ersetzt aber keine fachlichen Anforderungen.

Erst in einer bewusst vorbereiteten Projektumgebung ausfuehren:

```bash
python -m coverage run -m pytest tests/
python -m coverage report -m
```

Das installiert Coverage.py nicht. Keine vertraulichen Daten in generierte Tests oder oeffentliche
Reports geben. pre-commit kann beim ersten Lauf Hook-Repositories und Dependencies laden;
`pre-commit install` veraendert Git-Hooks. Beides braucht eigene Freigabe. Die bestehende
Hook-Konfiguration dieses Setup-Repositories wird hier nicht erweitert.

## Python-Webentwicklung

| Projekt / offizielle GitHub-Quelle               | Zweck im Setup                 | Einordnung / Grenze                                                                |
| ------------------------------------------------ | ------------------------------ | ---------------------------------------------------------------------------------- |
| [FastAPI](https://github.com/fastapi/fastapi)    | Typisierte API-Endpunkte       | Projektbibliothek, passender ASGI-Server erforderlich                              |
| [Flask](https://github.com/pallets/flask)        | Kompakte Webanwendungen        | Alternative, nicht parallel zu jedem Backend installieren                          |
| [Django](https://github.com/django/django)       | Webframework mit ORM/Admin     | Migrationen, Datenbank und Secrets separat freigeben                               |
| [Starlette](https://github.com/Kludex/starlette) | ASGI-Grundbausteine            | Eigenes Projekt und FastAPI-Unterbau; kein automatisch gestarteter Dienst          |
| [Pydantic](https://github.com/pydantic/pydantic) | Strukturierte Datenvalidierung | Projektbibliothek; pydantic-core/Rust-Abhaengigkeiten und passende Wheels beachten |
| [Uvicorn](https://github.com/Kludex/uvicorn)     | ASGI-Anwendungen ausfuehren    | Start nur nach Freigabe an 127.0.0.1, Port und Prozessende pruefen                 |

Die nachgereichte Adresse [encode/uvicorn](https://github.com/encode/uvicorn) fuehrt aktuell auf
`Kludex/uvicorn`. Ein gemeinsamer Maintainername macht Starlette und Uvicorn nicht zum selben Paket.
Typische Kombination: **FastAPI + Starlette + Pydantic + Uvicorn**, nicht vier globale Dienste.
Abhaengigkeiten, kompatible Versionen und Lockdatei je Zielprojekt festlegen.

## Frontend und automatisierte Vorschauen

| Projekt / offizielle GitHub-Quelle                    | Zweck im Setup                        | Einordnung / Grenze                                                                      |
| ----------------------------------------------------- | ------------------------------------- | ---------------------------------------------------------------------------------------- |
| [React](https://github.com/react/react)               | Komponenten fuer Benutzeroberflaechen | Projektbibliothek; facebook/react leitet auf dieses Ziel weiter                          |
| [TypeScript](https://github.com/microsoft/TypeScript) | Statische JavaScript-Typpruefung      | Projektwerkzeug, kein Preview-Server                                                     |
| [Vite](https://github.com/vitejs/vite)                | Dev-Server, HMR und Build             | Projektwerkzeug; explizit --host 127.0.0.1 und freier fester Port                        |
| [Node.js](https://github.com/nodejs/node)             | JavaScript-Laufzeit                   | Passende vorhandene Laufzeit verwenden, keine globale Umstellung hier                    |
| [pnpm](https://github.com/pnpm/pnpm)                  | JS-Dependencies und Projektskripte    | Version/Lockfile pruefen; Installationsskripte koennen Code ausfuehren                   |
| [Playwright](https://github.com/microsoft/playwright) | Browser-/E2E-Tests und Screenshots    | Vorhandener Baustein; Browserdownloads, Systembibliotheken und RAM/Disk eigens freigeben |

Urspruenglicher React-Link: [facebook/react](https://github.com/facebook/react). Vite-HMR
aktualisiert die Vorschau, prueft aber keine Formularlogik oder Backend-Funktion automatisch.
`localhost` ersetzt keine gepruefte Bind-Adresse; nicht mit `--host 0.0.0.0` veroeffentlichen. Die
vorhandene [WebsiteFactory](../tools/websitefactory.md) bleibt ein eigener Prototyp und wird durch
diese Quellenliste nicht zur fertigen Manus-Cloud.

## Git und kontinuierliche Integration

| Projekt / offizielle GitHub-Quelle                                              | Zweck im Setup                 | Einordnung / Grenze                                                    |
| ------------------------------------------------------------------------------- | ------------------------------ | ---------------------------------------------------------------------- |
| [Git](https://github.com/git/git)                                               | Versionierung, Branches, Diffs | Grundlage, keine automatische Commit-/Push-Freigabe                    |
| [Actions Checkout](https://github.com/actions/checkout)                         | Quellen fuer CI auschecken     | Action im Workflow, kein lokal installierbarer Agent                   |
| [Actions Runner](https://github.com/actions/runner)                             | GitHub-Actions-Jobs ausfuehren | Nicht automatisch als Self-hosted-Runner auf privater Hardware starten |
| [GitHub CLI](https://github.com/cli/cli)                                        | GitHub-Funktionen per CLI      | Vorhandener Registry-Eintrag; Anmeldung/Tokens separat freigeben       |
| [Ruff Action](https://github.com/astral-sh/ruff-action)                         | Ruff in CI aufrufen            | Optionale CI-Referenz, keine Workflow-Aktivierung hier                 |
| [Alte Playwright Action](https://github.com/microsoft/playwright-github-action) | Historische Browser-Action     | **Archiviert / deprecated: nicht fuer neue Workflows verwenden**       |

**Wichtige Korrektur:** `microsoft/playwright-github-action` ist seit 23.01.2025 archiviert.
Upstream raet davon ab und empfiehlt die **Playwright-CLI**. Quelle:
[Repository-README](https://github.com/microsoft/playwright-github-action#readme). Aktuelle
Anleitung: [Playwright in CI](https://playwright.dev/docs/ci-intro). Alte Action-Versionen aus
historischen Beispielen nicht einfach uebernehmen.

Moegliche Pipeline: Checkout, freigegebene Laufzeit, Lockfile-Installation, Lint/Format,
Tests/Coverage, Build, Browsertests. Dies ist ein **Ablaufkonzept**, kein neu eingerichteter
kompletter CI-Job. Ein CI-Dienst kann trotz GitHub- Quellcode kostenpflichtig sein; Self-hosting
kostet Ressourcen.

Fuer spaetere Workflows: Actions auf gepruefte volle Commit-SHAs pinnen, minimale `permissions`,
Timeout und Concurrency setzen. Keine Secrets an fremde Pull Requests geben und keinen fremden
PR-Code per `pull_request_target` mit privilegiertem Token ausfuehren. Self-hosted-Runner auf
privaten KI-/Wallet-/ Personalakten-Hosts sind keine Sandbox fuer unbekannten Code.
Browserinstallation mit `--with-deps` kann Systempakete installieren; diese CI-Anweisung ist keine
Freigabe fuer deine WSL oder deinen Windows-Host.

## Umsetzungsstand

Die 30 Quellen sind dokumentiert, Redirects und die archivierte Action korrigiert. Keine neuen
Runtime-Installer, globalen Frameworks, Hooks, Runner oder Cloud-Verbindungen werden hier
eingerichtet. Ein spaeterer uv-/Ruff-/ Coverage-/Hypothesis-Installer braucht eigene Pin-,
Ressourcen-, Status-, Rollback- und Deinstallationstests; kein Dummy-Status "installiert" nur wegen
dieser Quellenliste. Bestehende Aenderungen an Black/mypy bleiben unveraendert.

Weiter: [Lokaler Entwicklungsablauf](manus-development-workflow.md),
[Black und mypy](../tools/dev-quality.md),
[Beispielkonfiguration](../../examples/dev-quality/README.md),
[Queue und ihre Grenzen](../CODEX_TASK_QUEUE.md).
