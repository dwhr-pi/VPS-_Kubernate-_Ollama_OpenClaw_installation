# Grok-Interview: Werkzeugquellen und nachweisbare lokale Faehigkeiten

Stand: **22.10.2026**. Grundlage ist das vom Nutzer bereitgestellte Grok-Interview.
Dieser Leitfaden ergaenzt die getrennten Bereiche fuer [Meta](meta-development-tooling.md),
[Manus](manus-interview-2026-10-22.md) und [Gemini](gemini-development-tooling.md).

## Sinn und Zweck

Aus dem Interview uebernehmen wir einen nuetzlichen Prozess: vorhandene
Werkzeuge feststellen, passende Tests auswaehlen und Ergebnisse mit Belegen
dokumentieren. Dazu kommt eine Quellenliste fuer Python, lokale Inferenz,
RAG und Agenten. Das ist keine Kopie der Grok-internen Laufzeit und erfordert
weder ein Grok-Konto noch eine Modellabfrage.

**Interviewaussage, Quellenpruefung und lokaler Funktionstest sind verschiedene
Nachweise.** Die Behauptung eines Chatbots, ein Paket oder eine Datei sei
vorhanden, belegt weder unseren Rechner noch seine eigene Sandbox.

## Behauptete Umgebung und fehlende Artefakte

| Interviewaussage | Einordnung fuer unser Setup |
|---|---|
| Python 3.12.3, pytest 9.0.3, Git 2.43.0 | Ungepruefte Interviewwerte, keine empfohlenen Versionspins und kein lokales Inventar |
| Node 24.15.0, npm 11.12.1, globales React 19 | Nicht als installiert uebernehmen; React gehoert normalerweise in die Projektabhaengigkeiten |
| Go 1.22.2, Rust/Cargo 1.75.0, GCC 13.3.0, Clang 18 | Projektanforderungen und gepflegte Toolchains waehlen, kein Downgrade zum Nachbau der Aussage |
| Linux-Shell, Internet, Browser und beliebige nachinstallierbare Tools | Fremde Faehigkeitsbehauptung; keine Berechtigung fuer Installationen, Netzwerk oder Host-Aenderungen |
| sandbox-tooling-overview unter /home/workdir/.grok/skills/ samt erfolgreichem validate-skill.sh | Keine Originaldateien und kein Validierungsprotokoll mitgeliefert; eigener Repository-Skill unten |
| Praesentation mit neun Folien, aber leerer Datei-/Downloadangabe | Keine Praesentationsdatei mitgeliefert. Die vorhandene 13-Folien-Praesentation ist kein Grok-Original |

Der eigene [Skill sandbox-tooling-overview](../../skills/sandbox-tooling-overview/SKILL.md)
rekonstruiert den Inventarisierungsprozess. Er ist nicht global installiert und
aktiviert nichts in einem Grok-Skillverzeichnis. Skill-Anweisungen sind keine
technische Sandbox und koennen Betriebssystemrechte nicht erzwingen.

## Python: Originalquellen und Korrekturen

Die wiederholte HTTPX-Nennung wurde zusammengefasst. Quellen sind keine Liste
vorinstallierter Pakete und kein Auftrag zur Masseninstallation.

| Aufgabe | Originalquellen |
|---|---|
| Laufzeit und Tests | [CPython](https://github.com/python/cpython), [pytest](https://github.com/pytest-dev/pytest), [Coverage.py](https://github.com/nedbat/coveragepy), [Hypothesis](https://github.com/HypothesisWorks/hypothesis) |
| HTTP und Async | [HTTPX](https://github.com/encode/httpx), [Requests](https://github.com/psf/requests), [AnyIO](https://github.com/agronholm/anyio) |
| Datenmodelle und Konfiguration | [Pydantic](https://github.com/pydantic/pydantic), [pydantic-settings](https://github.com/pydantic/pydantic-settings) |
| Web und Templates | [FastAPI](https://github.com/fastapi/fastapi), [Uvicorn](https://github.com/encode/uvicorn), [Starlette](https://github.com/Kludex/starlette), [Flask](https://github.com/pallets/flask), [Django](https://github.com/django/django), [Jinja](https://github.com/pallets/jinja) |
| Datenbank und Versionsverwaltung | [SQLAlchemy](https://github.com/sqlalchemy/sqlalchemy), [Git](https://github.com/git/git) |
| Qualitaet | [Ruff](https://github.com/astral-sh/ruff), [Black](https://github.com/psf/black), [mypy](https://github.com/python/mypy) |
| HTML-Parsing | [Beautiful Soup: offizielle Website](https://www.crummy.com/software/BeautifulSoup/) und deren [Source-Ziel auf Launchpad](https://code.launchpad.net/beautifulsoup) |

**Quellenkorrekturen:** [encode/starlette](https://github.com/encode/starlette)
leitet auf Kludex/starlette um. wention/BeautifulSoup4 aus dem Interview
nicht als offizielles Upstream-Repo verwenden: Die Beautiful-Soup-Website
verlinkt Launchpad. Dessen Quellseite war beim Abruf nicht zugaenglich; das
Linkziel ist durch die offizielle Website belegt, der Repository-Inhalt wurde
hier nicht geprueft. GitHub bevorzugen, aber keinen beliebigen Mirror als
Original ausgeben.

JS/TS, Go, Rust, C/C++, Shells und SQL sind bereits im
[Sprach-/Infrastrukturkatalog](manus-language-infrastructure-sources.md) erfasst.
Der [62er-Installationsweg](../tools/development-toolchain-check.md) zeigt die
tatsaechlichen Rezepte und Voraussetzungen. Ein SQLite-Test ersetzt keine
PostgreSQL-/MySQL-Integration; ein erzeugtes Dockerfile keinen Container-Test.

## Lokaler KI-Stack: passende Rollen statt Ranglisten

| Bereich | Quellen / Kandidaten | Bedeutung fuer unser Setup |
|---|---|---|
| Lokale Runtime und Oberflaeche | [Ollama](https://github.com/ollama/ollama), [llama.cpp](https://github.com/ggml-org/llama.cpp), [Open WebUI](https://github.com/open-webui/open-webui) | Vorhandene Integrationen zuerst pruefen; nicht alle drei parallel erforderlich |
| Server-Inferenz | [vLLM](https://github.com/vllm-project/vllm), [SGLang](https://github.com/sgl-project/sglang) | SGLang hier neue Quellenreferenz, kein neu integrierter Installer oder gemessener Geschwindigkeitsgewinn |
| Bestehendes TGI | [Text Generation Inference](https://github.com/huggingface/text-generation-inference) | Upstream meldet Wartungsmodus und verweist fuer Weiterentwicklung unter anderem auf vLLM/SGLang; kein automatischer Austausch |
| Typisierte Agenten | [Pydantic AI](https://github.com/pydantic/pydantic-ai), [Mastra](https://github.com/mastra-ai/mastra) | Python- beziehungsweise TypeScript-Kandidaten; hier Quellenreferenzen, keine neuen Installer |
| Weitere Empfehlungen im Interview | Jan, LM Studio, MLX-LM, AnythingLLM, LocalAI, Haystack, LangGraph, CrewAI, Continue, Aider, Cline, OpenCode | Bei konkreter Auswahl Quelle, Lizenz, Plattform und bestehenden Registry-Eintrag einzeln pruefen; keine pauschale Installationszusage |

Die TGI-Wartungsangabe wurde am 22.10.2026 im offiziellen README geprueft.
Der vorhandene TGI-Eintrag bleibt experimenteller Source-Weg. LocalAI steht
in unserer Registry auf geplant/manuell; Haystack besitzt bereits einen
Installer-Verweis. Ein Verweis oder Status ist kein erfolgreicher Livebuild.

Fuer deinen RTX-5080-Host oder Letsung MiniPC zuerst eine Runtime und ein
Frontend waehlen. Modellformat, Kontext, RAM/VRAM, GPU-Unterstuetzung und freien
Host-Speicher messen; nicht allein aus der Parameterzahl Geschwindigkeit
ableiten. RAG-Store oder Agentenframework nur bei einem konkreten Bedarf
ergaenzen. Empfehlungen wie "am schnellsten" oder "beliebtester Standard"
sind ohne vergleichbare Messung keine belastbare Rangliste.

Lokaler Quellcode bedeutet nicht automatisch Offline-Betrieb, offene
Modellgewichte oder eine fuer jeden Zweck geeignete Lizenz. LM Studio nicht
allein aufgrund von GitHub-Komponenten als vollstaendig Open Source bezeichnen.
Cloud-Fallbacks brauchen eine bewusste Freigabe, Kostenlimits und einen
geprueften Datenfluss.

## CI/CD: Kurzbeispiele nicht ungeprueft aktivieren

Das Interview liefert kompakte Go-/Rust-YAML-Beispiele, aber keinen Nachweis
eines erfolgreichen CI-Laufs. Unsere [bestehenden inaktiven Vorlagen](../../examples/manus-ci-cd/README.md)
bleiben die Ausgangsbasis. Keine Datei wird automatisch nach .github/workflows/
kopiert und kein Image gepusht.

- Go: Projektversion statt festem Interviewwert verwenden, Formatpruefung
  ergaenzen und ein konkretes Hauptpaket bauen. Unsere Vorlage nutzt
  ./cmd/server; ./cmd/... kann mehrere Programme bezeichnen und passt
  dann nicht zu einer einzigen Ausgabedatei bin/app.
- Rust: Toolchain festlegen, fmt/Clippy und gelockte Tests/Builds verwenden.
  --all-features ist nicht fuer jedes Projekt sinnvoll, etwa bei gegenseitig
  ausschliessenden Features. Ein Lockfile alleine garantiert keine bytegleichen Binaries.
- Floating Action-Tags, stable und ubuntu-latest nicht als vollstaendig
  reproduzierbare Pins darstellen. Minimale Rechte, Zeitlimit und Freigaben
  fuer Releases getrennt behandeln. Unsere Go-Vorlage deaktiviert Caching;
  ein setup-go-Schritt allein belegt keine bestimmte Cache-Strategie.

Multistage-Builds, non-root, Zertifikate und kleine Images sind sinnvolle
Pruefpunkte, keine Produktionsgarantie. Images nach Digest pruefen; SemVer-Tags
koennen veraendert werden. Docker-Healthchecks und Kubernetes-Probes separat
behandeln, Ressourcenwerte messen, Secrets nicht mit Base64-Verschluesselung
verwechseln und NetworkPolicies auf CNI-Unterstuetzung pruefen. Details:
[CI/CD und Deployment](manus-ci-cd-deployment.md).

## Wiederverwendbare Bestandsaufnahme

1. Auftrag, Zielordner und erlaubte Aktionen festhalten; Betriebssystem und
   angebotene Schnittstellen nicht aus einem fremden Interview ableiten.
2. Projektdateien und ausfuehrbare Pfade ermitteln. Eine gefundene
   Datei ist noch kein erfolgreicher Versions-, Import- oder Funktionstest.
3. Nur aufgabenbezogene, erlaubte Probes ausfuehren. Auch Versionsabfragen,
   Imports und Buildhooks koennen Code ausfuehren; unbekannte Programme nicht blind starten.
4. Beleg, Zeit, Exit-Code und Fehler getrennt protokollieren. Nicht ausgefuehrte
   Schritte als not-run markieren, nicht als bestanden oder nicht installiert.
5. Fehlende Voraussetzungen melden; keine Installation, fremde Prozesse,
   WSL-Distro, Cloud, Commit/Push oder Clusteraktion aus dem Interview ableiten.

Nutze dafuer den [Repository-Skill](../../skills/sandbox-tooling-overview/SKILL.md)
mit seiner [Berichtsvorlage](../../skills/sandbox-tooling-overview/assets/capability-report.md).
Fuer die anschliessende Projektumsetzung bleiben die vorhandenen
[Entwicklungsablaeufe](manus-development-workflow.md) massgeblich.

Die [vorhandene Praesentation](../presentations/technology-tooling-overview.pptx)
bleibt unveraendert. Fuer die Pruefung des behaupteten Grok-Skills oder seines
Neun-Folien-Decks muessen deren Originaldateien erst bereitgestellt werden.

## Pruefgrenzen

Diese Ergaenzung prueft Dokumentationsstruktur, Quellenzuordnung und lokale
Verweise offline. Keine Grok-Sandbox, Modelle, GPU-Builds, CI-Laeufe oder
Deployments getestet. Keine WSL-Aktion oder Toolinstallation durchgefuehrt.

Fuenf neue Grok-Tests sowie fuenf Meta- und 28 Manus-Regressionstests bestanden.
Der Standard-Skillvalidator konnte wegen fehlendem PyYAML nicht starten;
Metadaten und lokale Skill-Verweise wurden durch die Offline-Tests geprueft.
Kein Paket wurde fuer den Validator nachinstalliert.
