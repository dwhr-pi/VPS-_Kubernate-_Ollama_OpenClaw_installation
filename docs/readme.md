# Dokumentation: Wegweiser

Dieses Verzeichnis beschreibt das modulare Hybrid-Setup fuer VPS, MiniPC/WSL, lokale KI-Modelle und
Agenten. Es enthaelt Anleitungen, Bestandsaufnahmen, Sicherheitskonzepte, Testplaene und historische
Entwuerfe. Eine dokumentierte Komponente ist nicht automatisch installiert, getestet oder
produktionsreif.

## Hier beginnen

[Projektformular und Prompt-Workflows](PROJECT_BRIEF_AND_PROMPT_WORKFLOWS.md):
Film, Buch oder Betriebssystem schrittweise planen, im Browser bearbeiten und
ueber Tage fortsetzen; Chat-/MCP-Uebergabe ohne automatische Ausfuehrung.

**Alle Tools im Browser oder als Windows-App sehen, einschliesslich Kubernetes/K3s:**
[Dashboard-Einstieg mit Headlamp, Grafana und optionaler Startseite](TOOL_DASHBOARD_BROWSER_DESKTOP.md).
[Boardroom](tools/boardroom.md) kann die Auswahl bewerten, ist aber kein fertiges Dashboard.
Katalogeintrag, installierte Software und betriebsbereiter Dienst sind unterschiedliche Anzeigen.
[Desktop-Apps mit Icons starten und Ressourcen-Reiter planen](DESKTOP_LAUNCHER_AND_METRICS_CONTRACT.md):
opt-in Installer-Katalog, ID-Allowlist und getrennte Prometheus-/Grafana-Anbindung; noch kein implementierter Launcher.
[Plattformen und App-Erkennung](CROSS_PLATFORM_APP_DISCOVERY.md): begrenzter Desktop-Scan implementiert,
Android-/iPhone-App sowie deren Discovery-/Startgrenzen ausdruecklich vorbereitet.

[Enterprise-Haertung schrittweise abarbeiten](architecture/ENTERPRISE_HARDENING_ROADMAP.md):
E01-E09 mit P1-P3, konkreten Checklisten, Voraussetzungen, Abnahme und Rueckbau.
Zuerst Metrics-Zugang, Restore und Sandbox; danach Streaming/Tracing, zuletzt HA und Autoscaling.
[Haertungsstand](architecture/HARDENING_IMPLEMENTATION_2026_11_12.md): Metrics-Bridge, Preflight und Sandbox
mit gesonderten Zielabnahmen und ohne automatisches Deployment.

[Natives Betriebshandbuch](NATIVE_OPERATIONS_HANDBOOK.md): zusammengefuehrte
MCP-/WebUI-/SSO-/Wartungs-Vorlagen, Make-Einstieg und sichere Backup-Grenzen.

[Modell-Routing, Export und Monitoring](MODEL_ROUTING_EXPORT_AND_MONITORING.md):
Offline-Vorschlaege statt automatischer Gewichtsinstallation oder Konfigurationsaenderung.

[Ollama-Log-Monitor](OLLAMA_LOG_MONITOR.md): begrenzte opt-in Kubernetes-Abfragen,
redigierte Kategorien, optionaler Discord-Versand und nicht-root systemd-Vorlage.

[Musikerkennung und Rechts-/Finanzmodelle](AUDIO_RECOGNITION_AND_DOMAIN_MODELS.md):
Audile, SongRec, Mousai, Dejavu und lokale Reasoning-Modelle mit SSH-Anleitungen.

[Musik-/Lyrics-Modellkatalog](MUSIC_LYRICS_MODEL_CATALOG.md): vollstaendige
Einordnung der angefragten Projekte mit Lizenz-, Installations- und Runtime-Grenzen.

[Gedichte, Songtexte und Reime](CREATIVE_LYRICS.md): Promptvorlage, Outlines,
eSpeak NG, offline pruefbare Strophen und ehrliche Phonetik-/Metrikgrenzen.

[Coding-Modelle: Qwen, DeepSeek, MiniMax, Sprachen und Einrichtung](models/README.md):
Assembler, Open Weights, Coding-Clients, RAG, Weitertraining, Datenmigration
und nachvollziehbare Modellherkunft; keine automatischen Modell-Downloads.

[Signiertes Setup neu installieren](INSTALL_SIGNED_RELEASE.md):
Windows-Public-Key uebernehmen, Bootstrap beziehen, Release pruefen und installieren.

[Audit 11.18](AUDIT-2026-11-10.md), [Tool-Auswahl](TOOL-MATRIX.md),
[offene Betriebsfaehigkeiten](MISSING-TOOLS.md) und [Betrieb](OPERATIONS.md).

[Betriebsreview 11.11.2026](REVIEW-2026-11-11.md): priorisierte Befunde,
Diagnose-/Restore-Befehle und Nachweisgrenzen.
[Vollstaendige Tool-Wahrheitstabelle](TOOL-MATRIX-NEU.md): 402 Registry-Eintraege,
keine pauschale Runtime-Freigabe.

[Erweiterter Audit 11.11.2026](AUDIT-2026-11-11.md):
Quellfundstellen fuer Pins/Netz/Privilegien, Testinventar, Referenzkandidaten,
Gitleaks-Grenzen und B1-B7-Lueckenplan.

[Infrastrukturreview vom 07.11.2026](INFRASTRUCTURE_REVIEW_2026-11-07.md):
priorisierte Befunde, drei begrenzte Monitoring-/MCP-/Retry-Patches und offene Runtime-Abnahmen.

[Hybrid-K3s: Ollama und OpenClaw absichern](kubernetes/hybrid-ollama-openclaw.md):
GPU und Modellcache, OpenClaw-Patch mit Secret-Referenz, Netzwerkisolation und Abnahmeplan.

[Hybride und fortgeschrittene KI-Infrastruktur](HYBRID_CLOUD_MCP.md):
MiniMax-M3 mit Lizenz-/Speichergrenzen, Obot als MCP-Gateway-Kandidat und
Together als separat freizugebende, bezahlte Cloud-Route.

[Boardroom](tools/boardroom.md): eigenstaendiges Entscheidungsprofil mit Beispielaufruf und Profilreferenz.

[Setup ohne Desktop ueber SSH bedienen](HEADLESS_SETUP.md): Terminalmenue,
dialogfreie JSON-Plaene und [Befehle fuer jedes Tool](generated/HEADLESS_TOOL_COMMANDS.md).
Unbeaufsichtigte Ausfuehrung nur fuer vorhandene gepruefte native Adapter und mit
getrennter Aktionsfreigabe; keine pauschalen Yes-/Force-Flags.
Die einzelnen Tool-Anleitungen enthalten ebenfalls einen sichtbaren Abschnitt
**VPS ueber SSH bedienen**, einschliesslich zugehoeriger Plan- und freigegebener
Lifecycle-Befehle. Desktop- oder nicht freigegebene Tools bleiben entsprechend gekennzeichnet.
[SSH-Abdeckung aller registrierten Tools](generated/SSH_TOOL_COVERAGE.md):
direkte Anleitungslinks pro Tool, einschliesslich der zuvor fehlenden Einstiegsseiten.
Kurze Einstiegsseiten sind keine vollstaendige Lifecycle- oder Runtime-Abnahme.

Optional: [XERJ-Code-/Dokumentsuche](tools/xerj.md), gepinnter nativer Rust-Build.
Lokaler Index und oeffentlicher Corpus Hub bleiben getrennt; kein Autostart oder Upload.
[Cargo/Rust-Build-Basis](BUILD_RUST_TOOLCHAIN.md): getrennte Erstinstallation im
Menue **62 Quellen verwalten**, ohne Docker, sudo oder globale PATH-Aenderung.
Die bestehende offizielle Compiler-Bootstrap-Ausnahme bleibt ausdruecklich dokumentiert.

[Lokale Audio-Chain](tools/local-audio-chain.md): OpenUtau, DiffSinger, RVC/Seed-VC,
UVR5 und privater FFmpeg-Build. Native Quellen als Standard, Docker gesondert
eingeordnet; lokale KI-/MCP-Schnittstelle zunaechst ausschliesslich fuer Planung.
[Concat mit lokalem Agenten](tools/concat.md#lokaler-agent-belegter-mcp-weg-statt-erfundener-http-api):
eingebautes stdio-MCP, gepruefte Versionsgrenzen und noch offene Schreib-/Sandbox-Abnahme.

Optional: [Offline-Handbuch im Browser](tools/markdown-docs-server.md) mit sichtbaren
Direktlinks, Themenbaum, Volltextsuche und Seiten-Inhaltsverzeichnis. Nur lokal,
keine Docker-Installation, keine externen Schriftarten oder Skripte.
Einrichtung und Anleitungen im Setup ueber **Optionen -> 22 - Offline-Handbuch /
Markdownserver**; kein Start oder Download allein durch Oeffnen des Settings-Menues.

[Installationsmessungen](INSTALLATION_BENCHMARKS.md): getrennte Testumgebungen fuer
[Linux](LINUX_INSTALL_LAB.md) und [WSL](WSL_INSTALL_LAB.md), Messwert-Export und Restore.

Im Setup oeffnet **Hauptmenue 10 - Dokumentation & API-Key Guide** jetzt sechs kurze Themen:
Einstieg, Architektur, Betrieb, Sicherheit, Tools/API-Keys und Historie. Erst danach ein Dokument waehlen.
Enter oeffnet die markierte Auswahl; Zurueck/Esc geht eine Ebene zurueck. Im Textfenster kehrt
Zurueck zur Dokumentauswahl zurueck. Die Anzeige liest nur lokale Dateien, ohne Browserstart,
Netzwerkzugriff, Download oder Dienstaktion. Markdown wird als lesbarer Quelltext angezeigt.
Der API-Key Guide bleibt unter **Tools, Profile und API-Keys** erreichbar.
Die kompakte [Projekt-README](../readme.md) enthaelt dieselben sechs Themen und aufklappbare historische Links.
Bestehende Abschnittsanker bleiben erhalten. Die Source-Build-Vorgabe wird nicht veraendert.

[Tool-Reihenfolge](tools/TOOL_MENU_ORDER.md): fester Bereich, bestehender Katalog
A-Z nach der Trennlinie und kuenftige Tools als Anhang hinter Z.

[P0-B: Ollama-/K3s-Quellenschutz](P0_B_CORE_SOURCES.md): gesperrte Legacy-
Direktinstallation, explizite Offline-Pruefung und noch fehlende Runtime-Abnahme.

[P1-P3-Umsetzung mit Abnahmegrenzen](P1_P3_IMPLEMENTATION.md): generierte Matrizen,
Restore-/WoL-Fixtures, optionale Gateway-Policy und weiterhin offene Produktionsnachweise.

| Anliegen                                  | Einstieg und Inhalt                                                                                                    |
| ----------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| Was ist aktuell umgesetzt?                | [Aktueller Status](CURRENT_STATUS.md) und [erste 60 Minuten](FIRST_60_MINUTES.md): Orientierung und bestehende Grenzen |
| Welcher Branch wird installiert?          | [Branch-Auswahl](INSTALL_BRANCH_SELECTION.md): main, Featurebranch, freie Eingabe, getrennte Checkout-Ordner           |
| Wie funktioniert der sichere Release-Weg? | [Signierte Releases](SIGNED_RELEASES.md): Minisign, unabhaengiger Public Key, Artefakte und Update-Vertrag             |
| Wie teste ich den Coding-Agenten-Branch?  | [Abnahmeplan](agents/CODING_AGENTS_ACCEPTANCE.md): Menue, Offline-Tests, optionale Laufzeittests und Merge-Kriterien   |
| Warum ist PR 6 noch nicht freigegeben?    | [CI-Befunde und Reparaturstand](agents/CI_REPAIR_STATUS.md): Ursachen, erster Fixsatz und weiterhin offene Blocker     |
| Wo liegt was?                             | [Verzeichnisstruktur](DIRECTORY_LAYOUT.md): Repository-Code, Nutzworkspace und Konfigurationspfade                     |

Die [Formatierungsregeln](quality/FORMATTING_POLICY.md) beschreiben die freigegebene Bereinigung und
die weiterhin verpflichtenden Sicherheitspruefungen.

## Themenbereiche

[Sechs Hybrid-Review-Bausteine](../examples/hybrid-production-review/README.md): GPU-Operator,
GitOps, ESO/Kyverno, GPU-Monitoring, privater Ingress und Velero als getrennte Konfigurationsbeispiele.
Keine automatische Installation oder Produktionsfreigabe; Pins, private Eingaben und Live-Abnahmen bleiben erforderlich.

Das alte [Kubernetes-Gesamtmanifest](legacy/K8S_DEPLOYMENTS_LEGACY.md) ist nur noch eine historische
Quellreferenz, kein ausfuehrbarer Deployment-Pfad. Bestehende Cluster und PVCs wurden durch die
Archivierung nicht veraendert.

| Bereich                      | Inhalt und wichtige Links                                                                                                                                                                                              |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Tools und Profile            | [Tool-Anleitungen](tools/), [Profil-Dokumentation](profiles/), [Tool-Registry](../config/tools.yml), [Profil-Registry](../config/profiles.yml); [Docker-zu-Source-Umstellung](DOCKER_TO_GITHUB.md) mit offenen Faellen |
| Coding-Agenten               | [Bestandsmatrix](agents/CODING_AGENT_INVENTORY.md), [lokale Workbench](agents/LOCAL_CODING_WORKBENCH.md), [native CLI-Builds](agents/NATIVE_CLI_BUILDS.md); [weitere Agenten](agents/)                                 |
| API-Keys und Onlinedienste   | [API-Key-Bereich](_API-Keys/): Anbieter, Registrierung, Kontingente, Quellenberichte und Datenschutzgrenzen; keine echten Zugangsdaten                                                                                 |
| Architektur und Kubernetes   | [Architektur](architecture/), [Kubernetes](kubernetes/), [Produktions-Baseline](PRODUCTION_BASELINE.md), [GitOps fuer kleine VPS](GITOPS_SMALL_VPS.md)                                                                 |
| Sicherer Betrieb             | [Security-Dokumentation](security/), [Core-Refactor](SECURE_CORE_REFACTOR.md), [GPU und Betriebsbausteine](LLMOPS_GPU_AND_OPERATIONS.md)                                                                               |
| Monitoring                   | [Monitoring](monitoring/): Messwerte, Exporter, Alarmierung und Betriebsgrenzen der jeweiligen Beispiele                                                                                                               |
| Backup und Wiederherstellung | [Installationsstatus](INSTALLATION_STATUS_BACKUP.md), [verschluesseltes Credential-Backup](CREDENTIALS_BACKUP.md), [Installations-Reset](INSTALLATION_RESET.md)                                                        |
| Heimnetz und Smart Home      | [Home-Watcher/WoL](home-watcher/), [Home Assistant](home_assistant/): lokale Steuerung und Integrationen                                                                                                               |
| Memory und RAG               | [Memory](memory/) und [RAG](rag/): Wissensspeicher, Datenfluesse und Evaluierung                                                                                                                                       |
| Medienproduktion             | [Film](film_studio/), [Medien](media_studio/), [Sprache](voice_studio/), [Avatare](avatar_studio/), [Broadcasting](broadcasting/), [Chor](choir_system/)                                                               |
| Workflows und Tutorials      | [Workflows](workflows/), [Tutorials](tutorials/), [n8n](n8n/): Aufgabenablaeufe und Integrationsbeispiele                                                                                                              |
| Leistung und Kapazitaet      | [Benchmarks](benchmarks/) und [Ressourcenplaner](resource-planner/README.md): Annahmen, Vergleichsmessungen und Planung                                                                                                |
| Audits und Vorschlaege       | [Gesamtaudit](audit/EXECUTIVE_SUMMARY.md), [Reviews](reviews/), [Vorschlaege](proposals/) und [Quellen](sources/): datierte Belege und offene Aufgaben                                                                 |
| Recht und Compliance         | [Legal](legal/): technische Dokumentations- und Pruefhilfen, keine individuelle Rechtsberatung                                                                                                                         |
| Praesentationen              | [Praesentationen](presentations/): begleitende Uebersichten; nicht massgeblich fuer den aktuellen Implementierungsstand                                                                                                |
| Historie                     | [Legacy](legacy/) und datierte Reviews: fruehere Konzepte und nachvollziehbare Entwicklung                                                                                                                             |

Zur technischen Abnahme: [CI-Reparaturprotokoll](agents/CI_REPAIR_STATUS.md) und
[externe Links und Quellenstatus](quality/EXTERNAL_LINK_POLICY.md). Nicht erreichbare Quellen werden
nicht durch pauschale HTTP-403-/202-Erfolgsregeln freigegeben.

## Dokumente richtig einordnen

- **Dokumentiert** bedeutet beschrieben, nicht installiert.
- **Konfiguriert** kann lediglich eine Vorlage bedeuten, noch keinen erreichbaren Dienst.
- **Installierbar** setzt die genannten Plattformen, Abhaengigkeiten und Freigaben voraus.
- **Getestet** gilt nur fuer den angegebenen Testumfang; Mocks sind keine echten Modelltests.
- **Produktionsfreigabe** benoetigt eine gesonderte Betriebs-, Sicherheits- und Restore-Abnahme.

Datierte Audits, Entwuerfe und exportierte Inventare koennen hinter dem aktuellen Branch liegen.
Immer Branch, Commit, Datum und offene Punkte mitlesen. Weder ein README noch ein Menuehaekchen
ersetzt den Laufzeitnachweis. Aehnlich benannte historische Profilverzeichnisse werden durch diesen
Wegweiser nicht umbenannt.

## Sicherheit und Rueckmeldung

Zugangsdaten und Nutzdaten gehoeren in den privaten Workspace, standardmaessig
`~/.openclaw_ultimate_user_data`, nicht ins Repository. Branch-Checkouts teilen diesen Workspace:
kein zweites isoliertes System und kein automatischer Rollback. Keine Installation, Modell-Downloads
oder Cluster-Aenderungen allein zum Lesen der Dokumentation starten. Schwere und produktive Aktionen
bleiben ausdrueckliche Opt-ins.

Bei Fehlerberichten Branch/Commit, Tool, Plattform, Exitcode und den relevanten bereinigten
Logausschnitt nennen. Keine ENV-Dateien, Tokens, Auth-Dateien, privaten Schluessel oder
vollstaendigen Credential-Backups veroeffentlichen.

Zurueck zum [Projekt-Einstieg](../readme.md).
