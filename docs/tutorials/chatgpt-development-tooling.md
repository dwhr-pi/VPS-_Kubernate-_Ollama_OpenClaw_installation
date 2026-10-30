# ChatGPT-Interview: Entwicklungswerkzeuge und nachvollziehbare Nachweise

Stand: **22.10.2026**. Grundlage ist das vom Nutzer bereitgestellte ChatGPT-Interview. Eigener
Bereich neben [Claude](claude-development-tooling.md), [Qwen](qwen-development-tooling.md),
[Gemini](gemini-development-tooling.md), [Perplexity](perplexity-development-tooling.md),
[Grok](grok-development-tooling.md), [Meta](meta-development-tooling.md) und
[Manus](manus-interview-2026-10-22.md).

## Sinn und Zweck

Nuetzlich ist die klare Trennung aus Code schreiben, Programme tatsaechlich ausfuehren und ueber
freigegebene Integrationen arbeiten. Fuer unser Setup verbinden wir diese Unterscheidung mit
Quellen, vorhandenen Installationswegen und einer projektspezifischen Plattform-/Testmatrix. Ein
ausgegebener Programmtext ist noch kein erfolgreicher Build oder Produktionsbetrieb.

Die [vollstaendige Quellenliste](chatgpt-tooling-sources.md) erhaelt alle **90 eindeutigen
GitHub-Repository-URLs** aus dem Interview ohne Trackingparameter. Das sind keine 90 neuen
Installer. Wiederholte Inhalte wurden zusammengefuehrt, nicht als neue Dateien oder unterschiedliche
Projekte gezaehlt.

## Was der Anhang belegt und was nicht

| Aussage / Material                                                               | Einordnung                                                                                   |
| -------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Python, Jupyter, Shell, Linux-Container und GitHub-Anbindung vorhanden           | Interviewbehauptung ueber eine fremde Sitzung; kein Inventar unseres Hosts                   |
| Node, tsc, Go, Compiler und CMake angeblich gefunden; andere Tools nicht im PATH | Kein Rohprotokoll mitgeliefert. PATH-Fund ist ohnehin nur Auffindbarkeit, kein Buildnachweis |
| Python-CI                                                                        | YAML-Kurzbeispiel im Text vorhanden, aber kein nachgewiesener GitHub-Actions-Lauf            |
| Go-/Rust-Pipelines                                                               | Befehle und Prozess beschrieben, keine vollstaendigen neuen Workflow-Dateien mitgeliefert    |
| 13-Folien-PPTX und ZIP cross-platform-devops-tooling fertig                      | Nur Download-Beschriftungen, keine nutzbaren Datei-URLs oder angehaengten Originaldateien    |
| Wiederholte Beschreibung derselben Artefakte                                     | Wiederholung ist kein zusaetzlicher Nachweis und kein zweites Paket                          |
| Hardwareauswahl RTX 5060 Ti / RTX 5070 Ti                                        | Angebots-/Auswahltext, keine bestaetigte Hardwareangabe des Nutzers                          |

Die vorhandene [13-Folien-Praesentation](../presentations/technology-tooling-overview.pptx) hat zwar
dieselbe Folienzahl, wird aber ohne Provenienznachweis nicht als das behauptete ChatGPT-Artefakt
ausgegeben. Auch ein ZIP wird nicht als bereits importiert oder validiert dargestellt.

Favicon-URLs, Bildsuchergebnisse, fremde Portfolios und fragmentierte Zitatanzeigen wie "+1"/"+2"
ersetzen keine technischen Belege. Die externen Bilder werden weder heruntergeladen noch als eigene
Grafiken uebernommen. Das zerfallene Projektbaum-Layout im Interview ist eine Skizze, kein
angelegtes Projekt mit vorhandenen main.py-/Testdateien.

## ChatGPT, Codex und lokale Modelle auseinanderhalten

ChatGPT-Oberflaeche, Codex CLI, IDE-/Desktop-Client, Cloud-Ausfuehrung und ein Modellserver sind
nicht dieselbe Umgebung. Die offizielle OpenAI-Dokumentation beschreibt Codex CLI, app-server und
SDK als offene Komponenten; Modellzugang und verwaltete Dienste bleiben davon getrennt:
[OpenAI: offener Codex-Harness und Integrationswege](https://developers.openai.com/blog/codex-as-a-platform).

Ein GitHub-Checkout baut keine vollstaendige ChatGPT-Oberflaeche oder gehostete Analyseumgebung
nach. Fuer die CLI gelten deren jeweilige Konfiguration, Rechte und Laufzeit:
[offizielle Codex-CLI-Dokumentation](https://learn.chatgpt.com/docs/codex/cli). Daraus folgt keine
automatische Berechtigung fuer WSL, Cloud-Delegation, GitHub-Push oder den Zugriff auf externe
Konten.

Auch ein lokaler Client kann Cloud-Inferenz oder externe Tools verwenden. Clientlizenz,
Modelllizenz, Datenfluss und Betriebskosten getrennt pruefen. Hier werden weder ein OpenAI-Key noch
ein Konto, Login oder Modellaufruf eingerichtet.

## Quellenkorrekturen und Wartungsstand

Die nachfolgenden Einzelpunkte wurden an Primaerquellen abgeglichen; die gesamte Liste ist kein
umfassender Live-Audit aller 90 Projekte.

| Quelle aus dem Interview                                              | Befund und Konsequenz                                                                                                                                                                                           |
| --------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [rhasspy/piper](https://github.com/rhasspy/piper)                     | README verweist fuer Weiterentwicklung auf [OHF-Voice/piper1-gpl](https://github.com/OHF-Voice/piper1-gpl); dort GPL-3.0, nicht pauschal die alte MIT-Lizenz uebertragen. Stimmen/Modelle separat lizenzpruefen |
| [facebookresearch/demucs](https://github.com/facebookresearch/demucs) | Seit 01.01.2025 archiviert/read-only; nicht ungeprueft als aktiv gepflegtes Standardprojekt empfehlen                                                                                                           |
| [Prisma original](https://github.com/prisma/prisma)                   | Leitet auf [prisma/orm](https://github.com/prisma/orm) um; Originaladresse als Herkunft erhalten                                                                                                                |
| [FFmpeg-GitHub](https://github.com/FFmpeg/FFmpeg)                     | Repository bezeichnet sich als Mirror; primaeres Hosting und Build-/Lizenzoptionen gesondert beachten                                                                                                           |
| GCC, Bash, SQLite, PostgreSQL                                         | GitHub-Mirrors sind keine gleichwertigen neuen Sprachimplementierungen; Herkunft im Quellenkatalog kenntlich halten                                                                                             |
| [NVIDIA DCGM](https://github.com/NVIDIA/DCGM)                         | Nicht pauschal mit vollem Funktionsumfang fuer jede GeForce-/WSL-Konfiguration versprechen                                                                                                                      |

NVIDIA nennt eingeschraenkte Funktionalitaet auf Nicht-Datacenter-GPUs und zusatzliche
Plattform-/Treiberbedingungen:
[DCGM-Voraussetzungen](https://docs.nvidia.com/datacenter/dcgm/latest/user-guide/getting-started.html).
Daraus folgt keine bestaetigte DCGM-Funktion auf deiner RTX 5080 oder unter WSL. Kein
Treiber-/CUDA-Umbau oder Monitoring-Daemon wird gestartet.

Bei n8n, Open WebUI, LTX-Modellen und anderen Kandidaten die konkrete Code-/Modelllizenz, Edition
und Nutzungsbedingungen am Pin pruefen. Oeffentliche Quellen, lokal lauffaehig, Open Source und
uneingeschraenkte kommerzielle Nutzung sind keine austauschbaren Aussagen.

## Beispielpruefung: welche Aussage traegt welcher Test?

| Beispiel                              | Aussagekraft / fehlende Pruefung                                                                                                 |
| ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| TS modelStatus mit loaded:true        | Formatiert einen uebergebenen Wert; fragt keinen echten Modellserver ab                                                          |
| Go fmt.Println("KI-Server gestartet") | Gibt Text aus, startet keinen HTTP-/KI-Server                                                                                    |
| CMake add_test mit ki_engine          | Einfacher Prozess-Smoke-Test; Exit 0 allein bestaetigt keine fachliche Funktion                                                  |
| Rust model_status-Test                | Prueft den positiven Stringfall; negativer Fall, Fehlerpfade und echte Runtime fehlen                                            |
| Bash command -v-Schleife              | Zeigt PATH-Funde, keine Versions-/Import-/Buildpruefung. Trotz fehlender Tools kann das gezeigte Skript insgesamt Exit 0 liefern |
| SQL ai_models mit enabled=true        | Gespeicherte Konfiguration, kein Beweis eines geladenen Modells. Dialekt, Constraints und echte Migrationen getrennt testen      |

Das kleine SQL-Beispiel ist als
[inaktive SQL-Beispieldatei](../../examples/chatgpt-tooling/model-inventory.sql) erhalten. Unsere
Tests fuehren es ausschliesslich in einer SQLite-In-Memory- Datenbank aus und pruefen Tabelle,
Ausgabe und Pflichtfelder. Das ist kein Test einer installierten Datenbank oder einer
KI-Backend-Verbindung.

## Python-CI und Go-/Rust-Deployment

Das Python-Beispiel beruecksichtigt bereits contents: read und weist selbst auf fehlende
Anwendungsabhaengigkeiten und gepruefte Action-Pins hin. Diese Hinweise bleiben erhalten. Ein
Paketinstallationsschritt nur fuer pytest/Ruff installiert noch keine src/app-Anwendung und ist
keine vollstaendige Qualitaetspruefung fuer Typen, Formatierung oder Integration.

Action-Tags checkout@v6/setup-python@v7 und Python 3.13 sind Interviewwerte, keine hier neu
geprueften empfohlenen Pins. Fuer das Zielprojekt Release, Runnerkompatibilitaet, Lockfile und
Abhaengigkeiten festlegen; die Beispiele werden nicht automatisch unter .github/workflows aktiviert.

Go/Rust, manueller Image-Release und Deployment-Muster stehen bereits als
[inaktive CI-/Deployment-Beispiele](../../examples/manus-ci-cd/README.md) bereit. Ein benannter
Scan, eine Signierung oder ein geschuetztes Environment sind nicht dadurch vorhanden, dass sie als
Empfehlung im Interview stehen. Keine neue CD-Pipeline, Signierung, Cloud-Ressource oder
automatische Veroeffentlichung wird als umgesetzt behauptet.

Die bestehenden Leitfaeden zu [Gemini](gemini-development-tooling.md),
[Qwen](qwen-development-tooling.md) und [Claude](claude-development-tooling.md) erklaeren non-root
versus rootless, Image-Digests, Probes und Ressourcenlimits. Containerisierte Auslieferung eigener
Apps ist ein anderer Auftrag als die gewuenschte GitHub-basierte, Docker-freie Toolinstallation.

## Plattformmatrix statt plattformuebergreifender Pauschalzusagen

| Ziel            | Relevante Pruefung                                                   | Stand dieser Ergaenzung                                           |
| --------------- | -------------------------------------------------------------------- | ----------------------------------------------------------------- |
| Natives Windows | Pfade, Dateirechte, PowerShell, Paket-/CLI-Architektur               | Dokumentation und Offline-Tests hier; kein neues Client-Livebuild |
| Linux / WSL     | Linux-Build, Ressourcen, Rechte und gegebenenfalls Windows-Host-Disk | Nicht ausgefuehrt; keine WSL-Distro gestartet                     |
| macOS           | Zielarchitektur, native Bibliotheken, Signierung/Distribution        | Nicht getestet                                                    |
| Android / iOS   | Client-/UI- und OS-spezifische Rechte, Buildtoolchain, Geraetetest   | Nicht getestet; keine automatisch mobilen Desktop-Apps            |
| GPU / Modelle   | Treiber, Runtime, VRAM/RAM, Kontext, Quantisierung und Modellformat  | Keine Inferenz oder Treiberpruefung ausgefuehrt                   |

Bekannter Nutzerkontext bleibt RTX 5080 mit 16 GB VRAM und Letsung MiniPC, nicht die im Interview
angebotenen RTX-5060-/5070-Optionen. Unbekannter RAM oder MiniPC-Prozessor werden nicht erfunden.
Mehrere GPUs addieren ihren VRAM nicht automatisch fuer jede Anwendung.

Fuer einen Einstieg nur die benoetigte Runtime, einen Client und passende Tests waehlen. Vorhandene
[Qwen-Code-/Desktop-Wege](../tools/qwen-desktop-windows.md),
[62er-Installer](../tools/development-toolchain-check.md) und
[lokale Benchmarks](../tools/local-ai-benchmarks.md) zuerst pruefen. Keine pauschale Installation
von Compose/Kubernetes/vLLM oder eine erneute Treiberinstallation aus dieser Auswahlhilfe ableiten.

## Wiederverwendung und Grenzen

Der vorgeschlagene Name cross-platform-devops-tooling ist kein hier installierter Skill. Die
bestehenden Skills [sprach-infra-tooling](../../skills/sprach-infra-tooling/SKILL.md),
[tech-stack-architect](../../skills/tech-stack-architect/SKILL.md) und
[fullstack-project-bootstrapper](../../skills/fullstack-project-bootstrapper/SKILL.md) decken
Auswahl, Architektur und Projektgeruest ab. Quellenpruefung und Plattformmatrix wiederverwenden,
statt noch eine redundante globale Kopie anzulegen.

Keine ChatGPT-Sandbox, Compiler-Livebuilds, Browser, Cloud-API, GPU oder Deployments getestet. Keine
Toolinstallation, WSL-Aktion, aktive CI, globale Skill-Aktivierung, Commits oder Pushes ausgefuehrt.

Pruefung: acht neue ChatGPT-Tests und 62 bestehende Interview-Regressionstests bestanden.
Quellenvollstaendigkeit gegen die Interview-Fixture, lokale Verweise, Tabellen und SQL-Konfiguration
inklusive Pflichtfeldern geprueft; Diff-Pruefung ohne Fehler. Diese Tests ersetzen keine
plattformuebergreifenden Livebuilds.
