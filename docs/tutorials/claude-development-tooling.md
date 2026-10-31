# Claude-AI-Interview: Werkzeugquellen und lokale Coding-Clients

Weiterer Interview-Abgleich: [ChatGPT](chatgpt-development-tooling.md).

Stand: **22.10.2026**. Grundlage ist das vom Nutzer bereitgestellte Claude- Interview. Eigener
Bereich neben [Qwen](qwen-development-tooling.md), [Gemini](gemini-development-tooling.md),
[Perplexity](perplexity-development-tooling.md), [Grok](grok-development-tooling.md),
[Meta](meta-development-tooling.md) und [Manus](manus-interview-2026-10-22.md).

## Sinn und Zweck

Das Interview beschreibt Entwicklungsarbeit mit Dateisuche, Shell, Tests, Recherche und begrenztem
Werkzeugzugriff. Fuer unser Setup ist vor allem die konkrete Frage nuetzlich: Wie lassen sich Qwen
Code Desktop, Claude Code und lokale Modelle sinnvoll auseinanderhalten und kombinieren?

Dafuer gibt es den
[Windows-Leitfaden zu Qwen Desktop, Claude Code und Ollama](qwen-desktop-claude-local.md). Er
aendert keine Installation und verspricht keine vollstaendige Claude- Funktionsgleichheit mit einem
lokalen Modell.

## Interviewaussage und Nachweis trennen

| Aussage im Anhang                                                    | Tatsaechlicher Stand                                                                                               |
| -------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Private Linux-Umgebung mit Bash, Python, Node und Dateitools         | Fremde Laufzeitbehauptung, kein Inventar unseres Rechners und keine lokale Sandbox-Garantie                        |
| Free-Plan ohne Browser-/Computersteuerung, Zugriff nur ueber Desktop | Konto-/produkt-/zeitabhaengige Aussage, hier nicht verifiziert; nicht als allgemeine Zugriffsregel uebernehmen     |
| GitHub-Push, Worktrees und Hilfsagenten moeglich                     | Keine Berechtigung fuer unseren Chat; bestehende Nutzerfreigaben gelten                                            |
| Pakete bei Bedarf installieren                                       | Kein Auftrag zur Systeminstallation oder Aenderung von WSL                                                         |
| Zehn-Folien-Praesentation und dev-tooling-overview-Karte erstellt    | Keine PPTX/HTML-Datei, kein verwendbarer Downloadlink und kein SKILL.md-Paket mitgeliefert                         |
| Go-CI und Rust-Alternative                                           | Go-YAML im Text vorhanden; Rust-Schritte nur beschrieben, kein vollstaendiger Rust-Workflow und kein Laufprotokoll |

Die [bestehende 13-Folien-Praesentation](../presentations/technology-tooling-overview.pptx) ist kein
Claude-Original. Die behauptete private Karte wird nicht als heruntergeladener oder global
installierter Skill ausgegeben. Vorhandene
[Toolauswahl](../../skills/sprach-infra-tooling/SKILL.md),
[Architekturvorbereitung](../../skills/tech-stack-architect/SKILL.md) und
[Bestandsaufnahme](../../skills/sandbox-tooling-overview/SKILL.md) decken den beschriebenen Prozess
ab; kein redundanter Skill-Installer wird angelegt.

## Python: kein break-system-packages als Setup-Standard

Der Interviewbefehl pip install --break-system-packages ist keine geeignete allgemeine Empfehlung
fuer unseren Installer. Die Option hebt den Schutz einer extern verwalteten Python-Installation auf:
[offizielle pip-Referenz](https://pip.pypa.io/en/stable/cli/pip_install/).

Stattdessen projektlokales venv beziehungsweise einen isolierten Tool-Prefix mit passendem Python
verwenden. Fehlendes ensurepip/venv ist ein gesondertes Voraussetzungsproblem, kein Grund zum
Ueberschreiben des System-Python. Auch pip/npm-Installation, Imports, Plugins und Tests koennen
fremden Code ausfuehren oder Netzwerk nutzen. Keine Nachinstallation nur zur Nachahmung einer
behaupteten Claude-Sandbox.

## GitHub-Quellen aus dem Interview

Die Liste wurde laut Interview aus dem Gedaechtnis erstellt. Die folgenden Links erhalten diese
Herkunft, sind keine frisch geprueften Build-Pins oder Installationsnachweise fuer alle Projekte.
Vor konkreten Builds Release, Lizenz, Plattform und Commit pruefen; vorhandene Rezepte stehen im
[62er-Einstieg](../tools/development-toolchain-check.md).

| Bereich    | Genannte Quellen                                                                                                                                                                                                                                                                                                            | Grenze                                                                                                    |
| ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| Python     | [Ruff](https://github.com/astral-sh/ruff), [Black](https://github.com/psf/black), [mypy](https://github.com/python/mypy), [pytest](https://github.com/pytest-dev/pytest)                                                                                                                                                    | Formatter, Linter, Typpruefung und Tests sind verschiedene Nachweise                                      |
| JS/TS      | [Node](https://github.com/nodejs/node), [TypeScript](https://github.com/microsoft/TypeScript), [ESLint](https://github.com/eslint/eslint), [Prettier](https://github.com/prettier/prettier), [Vitest](https://github.com/vitest-dev/vitest), [Jest](https://github.com/jestjs/jest), [Vite](https://github.com/vitejs/vite) | Vorlage/Preview ersetzt keinen echten Build und Browser-Test                                              |
| Compiler   | [Go](https://github.com/golang/go), [Rust](https://github.com/rust-lang/rust), [rustup](https://github.com/rust-lang/rustup), [GCC-Mirror](https://github.com/gcc-mirror/gcc)                                                                                                                                               | GitHub-Mirror nicht mit primaerem GCC-Hosting verwechseln; lokale Verfuegbarkeit gesondert pruefen        |
| Shell      | [ShellCheck](https://github.com/koalaman/shellcheck), [PowerShell](https://github.com/PowerShell/PowerShell)                                                                                                                                                                                                                | Skript schreiben, statisch pruefen und ausfuehren getrennt dokumentieren                                  |
| Container  | [Moby](https://github.com/moby/moby), [Compose](https://github.com/docker/compose), [Hadolint](https://github.com/hadolint/hadolint)                                                                                                                                                                                        | Quellcode-/Lintzugriff belegt keinen Docker-Daemon oder Containerlauf                                     |
| Cluster    | [Kubernetes](https://github.com/kubernetes/kubernetes), [Helm](https://github.com/helm/helm), [kubeconform](https://github.com/yannh/kubeconform)                                                                                                                                                                           | Schema-/Templatechecks garantieren keine Laufzeitfunktion oder Clusterrechte                              |
| IaC / YAML | [Terraform](https://github.com/hashicorp/terraform), [yamllint](https://github.com/adrienverge/yamllint)                                                                                                                                                                                                                    | Lizenz/Provider beachten; validate kann vorbereitete Plugins brauchen, kein reiner universeller Textcheck |

SQLite ist nicht aus Quellenlisten auszuschliessen, nur weil das primaere Hosting nicht GitHub ist:
Es gibt einen [offiziellen GitHub-Mirror](https://github.com/sqlite/sqlite). Der Mirror ist keine
Freigabe, eine fremde Datenbank anzusprechen. SQLite-Ergebnisse ersetzen keine
PostgreSQL-/MySQL-/SQL-Server-Tests.

## CI/CD und Deployment

Der Go-Kurzworkflow nutzt go-version-file, Linter, Race-/Coverage-Test und Build. Das ist ein
brauchbarer Ansatz, aber keine fertige Release-Pipeline: Action-Tags sind beweglich, Rechte und
Zeitlimits fehlen, ein auslieferbares Artefakt und echte Laufprotokolle ebenfalls. Ein Scan muss
tatsaechlich konfiguriert und ausgefuehrt werden, um als bestanden zu gelten.

Die beschriebenen Rust-Schritte reichen nicht als vollstaendige Datei. Toolchain/Lockfile,
benoetigte Features, Artefakt und Zielplattform festlegen. Vorhandene
[inaktive Go-/Rust-Beispiele](../../examples/manus-ci-cd/README.md) weiterverwenden; keine
automatische Aktivierung unter .github/workflows.

Ein Image-Push ist eine Veroeffentlichung. Non-root ist nicht Rootless Docker; read-only Root-FS
braucht geeignete Schreibpfade. Feste Versions-Tags bleiben technisch veraenderbar, fuer Deployments
gepruefte Digests nutzen. Zwei Replikate garantieren ohne Kapazitaet, Probes und Datenbankstrategie
keine Verfuegbarkeit. Details im [Gemini-Abgleich](gemini-development-tooling.md).

## Claude Code mit Qwen: Quellenabgleich

Die im Interview als nicht offiziell vorgesehen bezeichnete Ollama-Anbindung ist zumindest von
Ollama selbst ausdruecklich dokumentiert:
[Claude-Code-Integration](https://docs.ollama.com/integrations/claude-code). Das ist keine
allgemeine Funktionsgarantie oder Supportzusage von Anthropic.

Die [Anthropic-Kompatibilitaetsseite](https://docs.ollama.com/api/anthropic-compatibility) enthaelt
derzeit widerspruechliche Angaben: tool_choice steht sowohl unter Requestfeldern als auch unter
nicht unterstuetzten Funktionen. Deshalb weder volle Unterstuetzung noch pauschale Unmoeglichkeit
fuer jede Version behaupten. Exakte Tokenzaehlung, Caching und erzwungene Toolwahl nicht
voraussetzen; Client-/Server-/Modellkombination gesondert testen.

[LiteLLMs Anleitung](https://docs.litellm.ai/docs/tutorials/claude_non_anthropic_models) ist ohne
.md-Endung erreichbar; die im Interview verlinkte .md-URL war hier nicht abrufbar. Auch dort stehen
Hinweise zur Model Discovery und zum claude-/anthropic-Namensfilter nebeneinander. Den Modellpicker
daher nicht als universelle Regel dokumentieren. Den expliziten Modellstart und Gateway-Routing am
gewaehlten Versionsstand pruefen.

Die NYU-Einfuehrung aus dem Anhang ist eine externe Einordnung, nicht die massgebliche
Qwen-Buildanleitung. Fuer Runtime-/Node-Vorgaben gelten der
[vorhandene Qwen-Installer](../tools/qwen-code.md) und sein Pin, nicht pauschal Node 20+ oder eine
globale npm-Installation aus dem Interview. Unbenannte Community-Proxys werden nicht anhand ihres
Namens installiert.

## Pruefgrenzen

Keine Claude-Planberechtigungen, Sandbox, API-Anmeldungen, Live-Modellanfragen, MCP-Server, Hooks
oder Subagenten getestet. Keine WSL-Aktion, Installation, aktive CI, Commits oder Pushes.
Originalartefakte fehlen weiterhin; externe Links sind Belege fuer den beschriebenen
Dokumentationsstand, keine Livebuilds.

Pruefung: sieben neue Claude-Tests und 55 vorhandene Interview-Regressionstests bestanden.
PowerShell-Beispiel nur mit dem nativen Parser auf Syntax geprueft, nicht ausgefuehrt. Lokale
Verweise, Quellenzuordnung und Tabellen geprueft; Diff-Pruefung ohne Fehler. Kein Ersatz fuer einen
realen Agenten-/Modelltest.
