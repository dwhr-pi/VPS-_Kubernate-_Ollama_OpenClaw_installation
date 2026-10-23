# Docker-Installer auf native GitHub-Builds umstellen

Stand: 23.10.2026. **Teilweise umgesetzt, nicht vollstaendig fertig.**
Der Skript-Abgleich fand 43 direkte/indirekte Image-Installationspfade: 32 waren
ueber ihren Installerpfad registriert, 11 weitere lagen als alte Einzeldateien
vor. Ein zusaetzlicher GitHub-Clone machte diese Image-Installationen nicht zu
nativen Builds. Die folgende Liste ist eine statische Pfadaufnahme, kein Scan
deiner installierten Container.

**18 native Build-/Paketrezepte sind jetzt implementiert; 25 native Umstellungen
sind noch offen.** Alle 43 Einstiegspunkte haben keinen automatischen Image-
Fallback mehr. Bei offenen Faellen liefert Installation/Update einen Fehler mit
Begruendung statt Quellen als fertige Anwendung zu zaehlen. Das ist eine bewusst
sichtbare Kompatibilitaetsaenderung, keine Behauptung von 43 fertigen Installern.
Bestehende Container, Docker, Volumes, /opt-Verzeichnisse und Secrets werden
nicht gestoppt, migriert oder geloescht. Keine live installierten Programme in
diesem Arbeitsschritt veraendert.

## Vollstaendige Liste der 43 Pfade

Nativ bedeutet **Buildrezept implementiert**, nicht auf Ubuntu gebaute und
produktiv abgenommene Anwendung. Offizielle Quelllinks bei offenen Faellen sind
Rechercheziele, keine bereits verifizierten Buildvertraege.

| Tool / Slug | Bisherige Imagequelle | Neue native Route / offener Schritt | Quelle |
|---|---|---|---|
| Airbyte (`airbyte`) | `abctl / kind / Helm-Images` | **OFFEN:** abctl startet kind/Kubernetes mit Images; native Plattform samt Konnektoren braucht einen separaten Integrationspfad. | [Upstream](https://github.com/airbytehq/airbyte) |
| Apache Tika (`apache_tika`) | `apache/tika:latest` | **OFFEN:** Native Gesamtpaketierung, Laufzeitabhaengigkeiten und Datenmigration noch nicht verifiziert; kein Docker-Fallback. | [Upstream](https://github.com/apache/tika) |
| Appsmith (`appsmith`) | `appsmith/appsmith-ce:latest` | **OFFEN:** Native Gesamtpaketierung, Laufzeitabhaengigkeiten und Datenmigration noch nicht verifiziert; kein Docker-Fallback. | [Upstream](https://github.com/appsmithorg/appsmith) |
| ArchiveBox (`archivebox`) | `archivebox/archivebox:latest` | **OFFEN:** Native Gesamtpaketierung, Laufzeitabhaengigkeiten und Datenmigration noch nicht verifiziert; kein Docker-Fallback. | [Upstream](https://github.com/ArchiveBox/ArchiveBox) |
| Argilla (`argilla`) | `argilla/argilla-quickstart:latest` | **OFFEN:** Native Gesamtpaketierung, Laufzeitabhaengigkeiten und Datenmigration noch nicht verifiziert; kein Docker-Fallback. | [Upstream](https://github.com/argilla-io/argilla) |
| Budibase (`budibase`) | `budibase/budibase:latest` | **OFFEN:** Native Gesamtpaketierung, Laufzeitabhaengigkeiten und Datenmigration noch nicht verifiziert; kein Docker-Fallback. | [Upstream](https://github.com/Budibase/budibase) |
| Caddy (`caddy`) | `caddy:2-alpine` | Rezept: go; 4096 MiB Startreserve | [Upstream](https://github.com/caddyserver/caddy) |
| cAdvisor (`cadvisor`) | `gcr.io/cadvisor/cadvisor:latest` | Rezept: go; 8192 MiB Startreserve | [Upstream](https://github.com/google/cadvisor) |
| Changedetection_IO (`changedetection_io`) | `lscr.io/linuxserver/changedetection.io:latest` | Rezept: python; 8192 MiB Startreserve | [Upstream](https://github.com/dgtlmoon/changedetection.io) |
| CrowdSec (`crowdsec`) | `crowdsecurity/crowdsec:latest` | Rezept: make; 16384 MiB Startreserve | [Upstream](https://github.com/crowdsecurity/crowdsec) |
| Directus (`directus`) | `directus/directus:latest` | **OFFEN:** Native Gesamtpaketierung, Laufzeitabhaengigkeiten und Datenmigration noch nicht verifiziert; kein Docker-Fallback. | [Upstream](https://github.com/directus/directus) |
| Forgejo (`forgejo`) | `codeberg.org/forgejo/forgejo:10` | **OFFEN:** Autoritative Quelle Codeberg; GitHub-Mirror nicht als verifizierten Ersatz behaupten. | [Upstream](https://github.com/forgejo/forgejo) |
| Grafana (`grafana`) | `grafana/grafana:latest` | **OFFEN:** Frontend, Wire-Codegenerierung und Backend gemeinsam bauen; Backend allein ist kein Grafana. | [Upstream](https://github.com/grafana/grafana) |
| Grafana Alloy (`grafana_alloy`) | `grafana/alloy:latest` | **OFFEN:** Make-Ziel laedt Beyla-Binaries; Source-only-Vertrag erfordert separaten Beyla-Build. | [Upstream](https://github.com/grafana/alloy) |
| Healthchecks (`healthchecks`) | `postgres:16, lscr.io/linuxserver/healthchecks:latest` | Rezept: requirements; 8192 MiB Startreserve | [Upstream](https://github.com/healthchecks/healthchecks) |
| Home Assistant (`home_assistant`) | `ghcr.io/home-assistant/home-assistant:stable` | **OFFEN:** Core-Paketierung, aktuelle Python-Version, Frontend und native Integrationen separat abnehmen. | [Upstream](https://github.com/home-assistant/core) |
| Langfuse (`langfuse`) | `postgres:16, ghcr.io/langfuse/langfuse:latest` | **OFFEN:** Versionskohaerente Web-/Worker-Builds, ClickHouse, PostgreSQL, Redis und S3 samt Migration fehlen. | [Upstream](https://github.com/langfuse/langfuse) |
| LiteLLM (`litellm`) | `ghcr.io/berriai/litellm:main-latest` | Rezept: python; 8192 MiB Startreserve | [Upstream](https://github.com/BerriAI/litellm) |
| Loki (`loki`) | `grafana/loki:latest` | Rezept: go; 16384 MiB Startreserve | [Upstream](https://github.com/grafana/loki) |
| Meilisearch (`meilisearch`) | `getmeili/meilisearch:latest` | Rezept: rust; 24576 MiB Startreserve | [Upstream](https://github.com/meilisearch/meilisearch) |
| Metabase (`metabase`) | `metabase/metabase:latest` | **OFFEN:** Native Gesamtpaketierung, Laufzeitabhaengigkeiten und Datenmigration noch nicht verifiziert; kein Docker-Fallback. | [Upstream](https://github.com/metabase/metabase) |
| MinIO (`minio`) | `quay.io/minio/minio:latest` | Rezept: go; 8192 MiB Startreserve | [Upstream](https://github.com/minio/minio) |
| Mosquitto (`mosquitto`) | `eclipse-mosquitto:2` | Rezept: cmake; 4096 MiB Startreserve | [Upstream](https://github.com/eclipse-mosquitto/mosquitto) |
| Neo4j (`neo4j`) | `neo4j:5` | **OFFEN:** Native Gesamtpaketierung, Laufzeitabhaengigkeiten und Datenmigration noch nicht verifiziert; kein Docker-Fallback. | [Upstream](https://github.com/neo4j/neo4j) |
| Netdata (`netdata`) | `netdata/netdata:latest` | **OFFEN:** Native Bibliotheken, Plugins und Hostberechtigungen ohne privilegierten Auto-Installer planen. | [Upstream](https://github.com/netdata/netdata) |
| Nextcloud (`nextcloud`) | `nextcloud:latest` | **OFFEN:** Native Gesamtpaketierung, Laufzeitabhaengigkeiten und Datenmigration noch nicht verifiziert; kein Docker-Fallback. | [Upstream](https://github.com/nextcloud/server) |
| NocoDB (`nocodb`) | `nocodb/nocodb:latest` | **OFFEN:** Native Gesamtpaketierung, Laufzeitabhaengigkeiten und Datenmigration noch nicht verifiziert; kein Docker-Fallback. | [Upstream](https://github.com/nocodb/nocodb) |
| Node Exporter (`node_exporter`) | `prom/node-exporter:latest` | Rezept: go; 4096 MiB Startreserve | [Upstream](https://github.com/prometheus/node_exporter) |
| Node-RED (`node_red`) | `nodered/node-red:latest` | Rezept: npm; 8192 MiB Startreserve | [Upstream](https://github.com/node-red/node-red) |
| Open WebUI (`open_webui`) | `ghcr.io/open-webui/open-webui:main` | **OFFEN:** Frontend/Backend-Paket und Datenmigration separat auf demselben Pin integrieren. | [Upstream](https://github.com/open-webui/open-webui) |
| Penpot (`penpot`) | `stacks/penpot/docker-compose.penpot.yml` | **OFFEN:** Frontend, Backend, Exporter und externe Datendienste gemeinsam nativ bauen und abnehmen. | [Upstream](https://github.com/penpot/penpot) |
| Prometheus (`prometheus`) | `prom/prometheus:latest` | Rezept: make; 16384 MiB Startreserve | [Upstream](https://github.com/prometheus/prometheus) |
| Promtail (`promtail`) | `grafana/promtail:latest` | **OFFEN:** EOL seit 2026-03-02; keine neue Installation. Alloy-Migration getrennt pruefen. | [Upstream](https://github.com/grafana/loki) |
| Qdrant (`qdrant`) | `qdrant/qdrant:latest` | Rezept: rust; 24576 MiB Startreserve | [Upstream](https://github.com/qdrant/qdrant) |
| Rhasspy (`rhasspy`) | `rhasspy/rhasspy:latest` | **OFFEN:** Native Gesamtpaketierung, Laufzeitabhaengigkeiten und Datenmigration noch nicht verifiziert; kein Docker-Fallback. | [Upstream](https://github.com/rhasspy/rhasspy) |
| SearXNG (`searxng`) | `docker.io/valkey/valkey:8-alpine, docker.io/searxng/searxng:latest` | Rezept: python; 8192 MiB Startreserve | [Upstream](https://github.com/searxng/searxng) |
| Stirling PDF (`stirling_pdf`) | `frooodle/s-pdf:latest` | **OFFEN:** Native Gesamtpaketierung, Laufzeitabhaengigkeiten und Datenmigration noch nicht verifiziert; kein Docker-Fallback. | [Upstream](https://github.com/Stirling-Tools/Stirling-PDF) |
| Uptime Kuma (`uptime_kuma`) | `louislam/uptime-kuma:latest` | Rezept: npm; 8192 MiB Startreserve | [Upstream](https://github.com/louislam/uptime-kuma) |
| Vault (`vault`) | `hashicorp/vault:1.17` | **OFFEN:** Native Gesamtpaketierung, Laufzeitabhaengigkeiten und Datenmigration noch nicht verifiziert; kein Docker-Fallback. | [Upstream](https://github.com/hashicorp/vault) |
| Vikunja (`vikunja`) | `vikunja/vikunja:latest` | **OFFEN:** Native Gesamtpaketierung, Laufzeitabhaengigkeiten und Datenmigration noch nicht verifiziert; kein Docker-Fallback. | [Upstream](https://github.com/go-vikunja/vikunja) |
| Watchtower (`watchtower`) | `containrrr/watchtower:latest` | **OFFEN:** Container-Updatewerkzeug braucht weiterhin eine Container-Runtime; kein sinnvoller Docker-freier Dienst. | [Upstream](https://github.com/containrrr/watchtower) |
| Weaviate (`weaviate`) | `semitechnologies/weaviate:latest` | Rezept: go; 16384 MiB Startreserve | [Upstream](https://github.com/weaviate/weaviate) |
| Zigbee2MQTT (`zigbee2mqtt`) | `koenkk/zigbee2mqtt:latest` | Rezept: pnpm; 8192 MiB Startreserve | [Upstream](https://github.com/Koenkk/zigbee2mqtt) |

## Installation und Status

Die bestehende Tool-Auswahl und die einzelnen Shell-Einstiege verwenden
[`native_github_tools.py`](../scripts/tools/helpers/native_github_tools.py) und
das [Migrationsmanifest](../config/docker_to_github.json). Bei geplanten Tools
bleibt die eingeschraenkte Reifegradanzeige absichtlich erhalten. Direkte CLI-
Pruefung ist fuer jeden der 43 Slugs verfuegbar:

```bash
# Read-only plan: no downloads, dependencies, host changes or service start.
bash scripts/tools/node_exporter_install.sh --dry-run
# Explicit build, only after reviewing the plan and upstream license.
bash scripts/tools/node_exporter_install.sh
bash scripts/tools/node_exporter_status.sh
bash scripts/tools/node_exporter_doctor.sh
bash scripts/tools/node_exporter_update.sh --dry-run
# Example of an honestly blocked path; install itself will fail, not pull images.
bash scripts/tools/langfuse_install.sh --dry-run
```

Ziel je Tool: `~/.openclaw_ultimate_user_data/tools/SLUG/native-github/`.
`source/` enthaelt den gepinnten Checkout; `bin/` oder `app/` die nativen
Artefakte, `venv/` gegebenenfalls Python-Pakete. Bei Node-Projekten bleiben
Frontend/Backend und Abhaengigkeiten im privaten Quellbaum. `build-ready.json`
entsteht erst nach Build, Artefaktpruefung und konfiguriertem Versions-/Pakettest.
`application_tested=false` bleibt ausdruecklich gesetzt: kein Server-, Datenbank-,
Login-, GPU-, Browser- oder Ende-zu-Ende-Nachweis. Healthchecks bereitet Code
und Django-Abhaengigkeiten vor, nicht automatisch eine Datenbank. CrowdSec
braucht separate Konfiguration/Bouncer, cAdvisor separate Hostrechte.

Update/Repair pruefen denselben Pin, kein automatisches main/latest-Upgrade.
Die Pins wurden am Stichtag ueber die offiziellen GitHub-Commit-Metadaten
aufgeloest und Builddateien gezielt gelesen. Mehrere sind Entwicklungsstaende,
kein pauschaler stabiler Release-Vertrag. Weder Signatur noch vollstaendige
Sicherheits-/Lizenzpruefung aller Quellbaeume wurde damit nachgewiesen.

## Voraussetzungen, Quellenregel und Speicher

Nur Ubuntu/WSL Linux ist als Buildziel vorgesehen. Go/Rust/CMake/Node/npm/pnpm
beziehungsweise uv und passende native Entwicklungsbibliotheken muessen bereits
vorhanden sein. Versionen ergeben sich aus gepinntem go.mod, Cargo-/Node- und
Python-Metadaten. Compilerfehler/fehlende Bibliotheken bleiben Fehler im aktuellen
Log; keine stille apt-, Docker-, globale Paketmanager- oder System-Python-Installation.
Go verwendet `GOTOOLCHAIN=local`, Rust eine vorhandene Toolchain. Ein abweichendes
vorhandenes Python ist mit `NATIVE_SOURCE_PYTHON_BIN` waehlbar.

Primaerprogramme werden aus GitHub-Quellen gebaut, nicht als fertige Images
oder Release-Binaries ersetzt. Prometheus baut auch seinen promu-Helfer aus
Go-Quellen, statt den Binary-Download aus Makefile.common zu verwenden. npm/pnpm,
Cargo, Go und Python beziehen weitere Abhaengigkeiten aus ihren offiziellen
Paketdiensten; das ist **kein ausschliesslicher GitHub-Source-Build jeder
transitiven Abhaengigkeit**. Paket-/Buildhooks fuehren Code aus. Die privaten
Buildumgebungen erben keine Provider-/AWS-Schluessel; Docker/Podman/sudo-Aufrufe
ueber PATH werden gesperrt. Das ersetzt keine Sicherheits-Sandbox gegen
boesartigen Buildcode oder absolute Programmpfade.

Speicherreserve je Rezept: 4 bis 24 GiB. Unter WSL wird auch C: geprueft; freie
Linux-Kapazitaet ersetzt die Hostreserve nicht. Bei den zuletzt gemeldeten 8 GiB
auf C: werden zahlreiche Builds weiterhin korrekt blockiert. Reserven nicht
pauschal senken. Genuegend zusaetzlichen Puffer einplanen. Bei Fehlern werden
nur neu angelegte native Buildordner entfernt; das aktuelle Log bleibt unter
`~/.openclaw_ultimate_user_data/install_logs/`. Quell-/Buildbestand, Anwendungen
und Daten nicht gleichzeitig durch andere Prozesse bearbeiten.

## Migration und Deinstallation

**Keine automatische Datenmigration.** Alte /opt-Compose-Projekte und Container
koennen nach dem Wechsel weiterhin laufen. Die neue Menue-Markierung beschreibt
nur den nativen Build, nicht deren Bestand. Alte Eintraege koennen deshalb aus
der nativen Installiert-Anzeige verschwinden, ohne dass Container entfernt wurden.
Der bisherige Startmanager ist kein Freigabenachweis fuer neue native Dienste;
keinen alten Compose-Start als nativen Start interpretieren. Ein ausdruecklich
verwendeter alter Compose-Stack bleibt ein Container-Deployment.

1. Legacy-Container, Ports und Datenpfade erfassen, verschluesselt sichern und Restore pruefen.
2. Neuen nativen Build parallel ohne Dienststart vorbereiten.
3. Konfiguration, Authentifizierung, DB-/Dateiformate und localhost/VPN-Bindung separat testen.
4. Erst nach Freigabe kontrolliert umschalten; alte Daten/Backups nicht automatisch loeschen.

```bash
bash scripts/tools/node_exporter_uninstall.sh --dry-run
bash scripts/tools/node_exporter_uninstall.sh
```

Deinstallation verwaltet ausschliesslich den neuen privaten nativen Build.
Fremde, veraenderte oder hinzugefuegte Dateien verhindern rekursive Entfernung;
vorhandene Legacy-Daten, Volumes, Logs und gemeinsame Basiswerkzeuge bleiben.
Bei blockierten Umstellungen erfolgt auch kein Legacy-Uninstall. Fuer bestehende
Container ist eine eigene datenerhaltende, projektspezifische Stilllegung noetig;
die alten potenziell datenloeschenden Uninstall-Wege werden nicht automatisch
weiterverwendet. Keine neue automatische systemd-Unit, Portfreigabe oder
Datenbankinitialisierung. Mosquitto erhaelt nur eine Beispielkonfiguration mit
localhost und verweigerten anonymen Zugriffen; Zugangsdaten/ACLs separat setzen.
Node Exporter bei manuellem Start ausdruecklich an `127.0.0.1:9100` binden.

## Gesonderte Einordnungen und verbleibende Containerdateien

- Authentik, Authelia und Stalwart-Mail erzeugen bisher Vorlagen, keine laufende
  Image-Installation. Ihre optionalen Compose-Beispiele wurden nicht heimlich
  durch einen ungetesteten nativen Dienst ersetzt.
- OpenHands ist bisher ein GitHub-Scaffold. Seine automatische Docker-/Compose-
  Paketabhaengigkeit wurde entfernt; eine Docker-freie Sandbox ist damit noch
  nicht implementiert.
- Airbyte ist mit abctl/kind keine containerfreie Plattform; CLI-Build allein
  waere keine native Airbyte-Installation. Deshalb offen statt Schein-Erfolg.
- Forgejo nutzt autoritativ Codeberg. Keine beliebige GitHub-Kopie als offizielle
  Quelle ausgeben. Eine Quellen-Ausnahme oder ein verifizierter Mirror braucht
  eine getrennte Entscheidung.
- Promtail ist EOL; neue Installation bleibt gesperrt. Alloy braucht vor seiner
  Umstellung insbesondere einen Source-Build fuer eingebettete Beyla-Komponenten.
- Vorhandene `stacks/`, Kubernetes-Images, Compose-Vorlagen und historische
  Docker-Helper bleiben als explizite Container-Alternativen im Repository.
  Die 43 umgestellten Tool-Wrapper rufen sie nicht mehr auf. Ein gesamthaft
  Docker-freies Kubernetes-/Profil-System ist **nicht** behauptet.

## Tests und verbleibende Arbeit

[Offline-Fixtures](../tests/test_native_github_tools.py) pruefen alle Rezepte mit
gemockten Compilern, 258 Lifecycle-Wrapper, Fehlerlogging, Rollback, Idempotenz,
Marker, Dateigrenzen und die 25 expliziten Blocker. Das sind keine 18 realen
Linux-Builds. Kein Tool, Container oder Dienst wurde auf dem Nutzersystem gestartet.

Noch offen: die 25 oben benannten Paket-/Runtime-Migrationen; reale Builds der
18 Rezepte auf isoliertem Ubuntu; dazu je Dienst Konfiguration, Betrieb, Restore
und Upgrade. Erst nach diesen Nachweisen als einsatzbereit einstufen.

Lokaler Nachweis: 17 neue Migrations-Fixtures, 8 bestehende native Status-/
Build-Dependency-Fixtures und 13 Repository-Audit-Fixtures bestanden (38 gesamt).
Alle 258 Lifecycle-Wrapper sowie Menue, Statushelper, OpenHands-Scaffold und
drei Shelltests wurden mit nativem Bash geparst (264 Dateien). Die drei angepassten
Shell-Vertragstests bestanden; JSON, lokale Links und `git diff --check` ebenfalls.
Kein vollstaendiger Repo-Testlauf, kein echter Ubuntu-Build oder Runtime-Start.

Weitere offizielle Einordnung:
[Airbyte/abctl und Docker](https://docs.airbyte.com/platform/using-airbyte/getting-started/oss-quickstart),
[Forgejo-Quellen und Releases](https://forgejo.org/download/),
[Promtail EOL](https://grafana.com/docs/loki/latest/send-data/promtail/).
