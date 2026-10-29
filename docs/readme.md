# Dokumentation: Wegweiser

Dieses Verzeichnis beschreibt das modulare Hybrid-Setup fuer VPS, MiniPC/WSL,
lokale KI-Modelle und Agenten. Es enthaelt Anleitungen, Bestandsaufnahmen,
Sicherheitskonzepte, Testplaene und historische Entwuerfe. Eine dokumentierte
Komponente ist nicht automatisch installiert, getestet oder produktionsreif.

## Hier beginnen

| Anliegen | Einstieg und Inhalt |
| --- | --- |
| Was ist aktuell umgesetzt? | [Aktueller Status](CURRENT_STATUS.md) und [erste 60 Minuten](FIRST_60_MINUTES.md): Orientierung und bestehende Grenzen |
| Welcher Branch wird installiert? | [Branch-Auswahl](INSTALL_BRANCH_SELECTION.md): main, Featurebranch, freie Eingabe, getrennte Checkout-Ordner |
| Wie funktioniert der sichere Release-Weg? | [Signierte Releases](SIGNED_RELEASES.md): Minisign, unabhaengiger Public Key, Artefakte und Update-Vertrag |
| Wie teste ich den Coding-Agenten-Branch? | [Abnahmeplan](agents/CODING_AGENTS_ACCEPTANCE.md): Menue, Offline-Tests, optionale Laufzeittests und Merge-Kriterien |
| Warum ist PR 6 noch nicht freigegeben? | [CI-Befunde und Reparaturstand](agents/CI_REPAIR_STATUS.md): Ursachen, erster Fixsatz und weiterhin offene Blocker |
| Wo liegt was? | [Verzeichnisstruktur](DIRECTORY_LAYOUT.md): Repository-Code, Nutzworkspace und Konfigurationspfade |

## Themenbereiche

| Bereich | Inhalt und wichtige Links |
| --- | --- |
| Tools und Profile | [Tool-Anleitungen](tools/), [Profil-Dokumentation](profiles/), [Tool-Registry](../config/tools.yml), [Profil-Registry](../config/profiles.yml); [Docker-zu-Source-Umstellung](DOCKER_TO_GITHUB.md) mit offenen Faellen |
| Coding-Agenten | [Bestandsmatrix](agents/CODING_AGENT_INVENTORY.md), [lokale Workbench](agents/LOCAL_CODING_WORKBENCH.md), [native CLI-Builds](agents/NATIVE_CLI_BUILDS.md); [weitere Agenten](agents/) |
| API-Keys und Onlinedienste | [API-Key-Bereich](_API-Keys/): Anbieter, Registrierung, Kontingente, Quellenberichte und Datenschutzgrenzen; keine echten Zugangsdaten |
| Architektur und Kubernetes | [Architektur](architecture/), [Kubernetes](kubernetes/), [Produktions-Baseline](PRODUCTION_BASELINE.md), [GitOps fuer kleine VPS](GITOPS_SMALL_VPS.md) |
| Sicherer Betrieb | [Security-Dokumentation](security/), [Core-Refactor](SECURE_CORE_REFACTOR.md), [GPU und Betriebsbausteine](LLMOPS_GPU_AND_OPERATIONS.md) |
| Monitoring | [Monitoring](monitoring/): Messwerte, Exporter, Alarmierung und Betriebsgrenzen der jeweiligen Beispiele |
| Backup und Wiederherstellung | [Installationsstatus](INSTALLATION_STATUS_BACKUP.md), [verschluesseltes Credential-Backup](CREDENTIALS_BACKUP.md), [Installations-Reset](INSTALLATION_RESET.md) |
| Heimnetz und Smart Home | [Home-Watcher/WoL](home-watcher/), [Home Assistant](home_assistant/): lokale Steuerung und Integrationen |
| Memory und RAG | [Memory](memory/) und [RAG](rag/): Wissensspeicher, Datenfluesse und Evaluierung |
| Medienproduktion | [Film](film_studio/), [Medien](media_studio/), [Sprache](voice_studio/), [Avatare](avatar_studio/), [Broadcasting](broadcasting/), [Chor](choir_system/) |
| Workflows und Tutorials | [Workflows](workflows/), [Tutorials](tutorials/), [n8n](n8n/): Aufgabenablaeufe und Integrationsbeispiele |
| Leistung und Kapazitaet | [Benchmarks](benchmarks/) und [Ressourcenplaner](resource-planner/README.md): Annahmen, Vergleichsmessungen und Planung |
| Audits und Vorschlaege | [Gesamtaudit](audit/EXECUTIVE_SUMMARY.md), [Reviews](reviews/), [Vorschlaege](proposals/) und [Quellen](sources/): datierte Belege und offene Aufgaben |
| Recht und Compliance | [Legal](legal/): technische Dokumentations- und Pruefhilfen, keine individuelle Rechtsberatung |
| Praesentationen | [Praesentationen](presentations/): begleitende Uebersichten; nicht massgeblich fuer den aktuellen Implementierungsstand |
| Historie | [Legacy](legacy/) und datierte Reviews: fruehere Konzepte und nachvollziehbare Entwicklung |

## Dokumente richtig einordnen

- **Dokumentiert** bedeutet beschrieben, nicht installiert.
- **Konfiguriert** kann lediglich eine Vorlage bedeuten, noch keinen erreichbaren Dienst.
- **Installierbar** setzt die genannten Plattformen, Abhaengigkeiten und Freigaben voraus.
- **Getestet** gilt nur fuer den angegebenen Testumfang; Mocks sind keine echten Modelltests.
- **Produktionsfreigabe** benoetigt eine gesonderte Betriebs-, Sicherheits- und Restore-Abnahme.

Datierte Audits, Entwuerfe und exportierte Inventare koennen hinter dem aktuellen
Branch liegen. Immer Branch, Commit, Datum und offene Punkte mitlesen. Weder ein
README noch ein Menuehaekchen ersetzt den Laufzeitnachweis. Aehnlich benannte
historische Profilverzeichnisse werden durch diesen Wegweiser nicht umbenannt.

## Sicherheit und Rueckmeldung

Zugangsdaten und Nutzdaten gehoeren in den privaten Workspace, standardmaessig
`~/.openclaw_ultimate_user_data`, nicht ins Repository. Branch-Checkouts teilen
diesen Workspace: kein zweites isoliertes System und kein automatischer Rollback.
Keine Installation, Modell-Downloads oder Cluster-Aenderungen allein zum Lesen
der Dokumentation starten. Schwere und produktive Aktionen bleiben ausdrueckliche Opt-ins.

Bei Fehlerberichten Branch/Commit, Tool, Plattform, Exitcode und den relevanten
bereinigten Logausschnitt nennen. Keine ENV-Dateien, Tokens, Auth-Dateien,
privaten Schluessel oder vollstaendigen Credential-Backups veroeffentlichen.

Zurueck zum [Projekt-Einstieg](../readme.md).
