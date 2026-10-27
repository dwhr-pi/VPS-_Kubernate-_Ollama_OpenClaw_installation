# Docker-Installer auf native GitHub-Builds umstellen

**Rollback-Nachtrag 27.10.2026:** [Szenarien je aktuellem Tool und Ubuntu-Releasewechsel](NATIVE_BUILD_RECOVERY.md).
Die Matrix deckt alle 49 Eintraege des aktuellen Quellenmanifests ab; vorhandene
Datenbanken/Container werden nicht automatisch als Rueckfall gestartet oder entfernt.

**Nachtrag 27.10.2026:** Weitere aktive Pfade bei OpenTelemetry, AutoGPT Platform
und Supabase gefunden und bearbeitet. [Restliste mit Status und Grenzen](DOCKER_REMAINDER_2026-10-27.md).
Die folgenden Zahlen beziehen sich auf die urspruenglichen 43 Pfade.

Stand: 23.10.2026. **Teilweise umgesetzt, nicht vollstaendig fertig.**
Der Skript-Abgleich fand 43 direkte/indirekte Image-Installationspfade: 32 waren
ueber ihren Installerpfad registriert, 11 weitere lagen als alte Einzeldateien
vor. Ein zusaetzlicher GitHub-Clone machte diese Image-Installationen nicht zu
nativen Builds. Die folgende Liste ist eine statische Pfadaufnahme, kein Scan
deiner installierten Container.

**41 der 43 angefragten nativen Build-/Paketrezepte sind implementiert
(40 GitHub, eine freigegebene Codeberg-Ausnahme); 2 Umstellungen bleiben offen.**
Zusaetzlich ist PyAirbyte als eigenstaendiges GitHub-Python-SDK integriert:
insgesamt 42 Buildrezepte fuer 44 getrennte Eintraege. Alle 43 Einstiegspunkte haben keinen automatischen Image-
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
| Airbyte (`airbyte`) | `` | **OFFEN:** abctl startet kind/Kubernetes mit Images; native Plattform samt Konnektoren braucht einen separaten Integrationspfad. | [Quelle](https://github.com/airbytehq/airbyte) |
| Apache Tika (`apache_tika`) | `apache/tika:latest` | Rezept: pipeline; 16384 MiB Startreserve | [Quelle](https://github.com/apache/tika/tree/205414aec2c6a97e27cf657fbf565cb656ac8d1a) |
| Appsmith (`appsmith`) | `appsmith/appsmith-ce:latest` | Rezept: pipeline; 49152 MiB Startreserve | [Quelle](https://github.com/appsmithorg/appsmith/tree/dc5c6df034b3f402caf84661d0f22001ea277ce6) |
| ArchiveBox (`archivebox`) | `archivebox/archivebox:latest` | Rezept: python; 8192 MiB Startreserve | [Quelle](https://github.com/ArchiveBox/ArchiveBox/tree/d950dace5ef226634b86ebe43c7001aa7e076cbf) |
| Argilla (`argilla`) | `argilla/argilla-quickstart:latest` | Rezept: python; 16384 MiB Startreserve | [Quelle](https://github.com/argilla-io/argilla/tree/5338519accb13ae422f8bf9c0642651c249c49af) |
| Budibase (`budibase`) | `budibase/budibase:latest` | Rezept: pipeline; 32768 MiB Startreserve | [Quelle](https://github.com/Budibase/budibase/tree/897c4bc213fe423ce58c15c2de7574c0e4ba0112) |
| Caddy (`caddy`) | `caddy:2-alpine` | Rezept: go; 4096 MiB Startreserve | [Quelle](https://github.com/caddyserver/caddy/tree/2b47a1849f86389825623d6d36ee528da8b9e5fb) |
| cAdvisor (`cadvisor`) | `gcr.io/cadvisor/cadvisor:latest` | Rezept: go; 8192 MiB Startreserve | [Quelle](https://github.com/google/cadvisor/tree/c57813afc32715351dff34ab76a6164bcb0e5c9d) |
| Changedetection_IO (`changedetection_io`) | `lscr.io/linuxserver/changedetection.io:latest` | Rezept: python; 8192 MiB Startreserve | [Quelle](https://github.com/dgtlmoon/changedetection.io/tree/2bd1a87403b83eb6f37f9f23c04ee2555baccba0) |
| CrowdSec (`crowdsec`) | `crowdsecurity/crowdsec:latest` | Rezept: make; 16384 MiB Startreserve | [Quelle](https://github.com/crowdsecurity/crowdsec/tree/725b6659dee54dd7a5f314e587b99512531e4237) |
| Directus (`directus`) | `directus/directus:latest` | Rezept: pnpm; 24576 MiB Startreserve | [Quelle](https://github.com/directus/directus/tree/b3ce03c18673230913bdfdf14907eb13e6865178) |
| Forgejo (`forgejo`) | `codeberg.org/forgejo/forgejo:10` | Rezept: pipeline; 16384 MiB Startreserve | [Quelle](https://codeberg.org/forgejo/forgejo/src/commit/0d791421f85ca13a63b665053d81ea765fbbc571) |
| Grafana (`grafana`) | `grafana/grafana:latest` | Rezept: pipeline; 32768 MiB Startreserve | [Quelle](https://github.com/grafana/grafana/tree/9641b46829cb0172875ea6dd323bcec88fcf2cda) |
| Grafana Alloy (`grafana_alloy`) | `grafana/alloy:latest` | Rezept: pipeline; 49152 MiB Startreserve | [Quelle](https://github.com/grafana/alloy/tree/3b2a3565546bd36592dc49ca28604ad187f0fb85) |
| Healthchecks (`healthchecks`) | `postgres:16, lscr.io/linuxserver/healthchecks:latest` | Rezept: requirements; 8192 MiB Startreserve | [Quelle](https://github.com/healthchecks/healthchecks/tree/59caeef534d5f8151fd42da529c08fad6c719be2) |
| Home Assistant (`home_assistant`) | `ghcr.io/home-assistant/home-assistant:stable` | Rezept: python; 16384 MiB Startreserve | [Quelle](https://github.com/home-assistant/core/tree/3b4094800ac6c7906ded4081895fe7dce487a542) |
| Langfuse (`langfuse`) | `postgres:16, ghcr.io/langfuse/langfuse:latest` | Rezept: pipeline; 49152 MiB Startreserve | [Quelle](https://github.com/langfuse/langfuse/tree/e139e39b9ee56475c1a6df2d8ca58a3eaffc69b1) |
| LiteLLM (`litellm`) | `ghcr.io/berriai/litellm:main-latest` | Rezept: python; 8192 MiB Startreserve | [Quelle](https://github.com/BerriAI/litellm/tree/f2118fc7670ba3fa736d9b8f4deef9077a45a720) |
| Loki (`loki`) | `grafana/loki:latest` | Rezept: go; 16384 MiB Startreserve | [Quelle](https://github.com/grafana/loki/tree/518630ab23d6b0fa51135fbaa1d3f66fbb2e4cd5) |
| Meilisearch (`meilisearch`) | `getmeili/meilisearch:latest` | Rezept: rust; 24576 MiB Startreserve | [Quelle](https://github.com/meilisearch/meilisearch/tree/7b6f9f39bd91b04d4551673780cfeb31cb3f5e7b) |
| Metabase (`metabase`) | `metabase/metabase:latest` | Rezept: pipeline; 32768 MiB Startreserve | [Quelle](https://github.com/metabase/metabase/tree/0a34a97ceb26ae6bce05ebbbfc39a32d268233f5) |
| MinIO (`minio`) | `quay.io/minio/minio:latest` | Rezept: go; 8192 MiB Startreserve | [Quelle](https://github.com/minio/minio/tree/7aac2a2c5b7c882e68c1ce017d8256be2feea27f) |
| Mosquitto (`mosquitto`) | `eclipse-mosquitto:2` | Rezept: cmake; 4096 MiB Startreserve | [Quelle](https://github.com/eclipse-mosquitto/mosquitto/tree/83f2620f0b955b89aadce32cceb96a8e81950f5e) |
| Neo4j (`neo4j`) | `neo4j:5` | Rezept: pipeline; 49152 MiB Startreserve | [Quelle](https://github.com/neo4j/neo4j/tree/2994b43b44f35bf6520bd2667ab181bb76a45585) |
| Netdata (`netdata`) | `netdata/netdata:latest` | Rezept: cmake; 16384 MiB Startreserve | [Quelle](https://github.com/netdata/netdata/tree/4ca8ebf9c40a2e36b42b0255269a2a97948c752b) |
| Nextcloud (`nextcloud`) | `nextcloud:latest` | Rezept: pipeline; 24576 MiB Startreserve | [Quelle](https://github.com/nextcloud/server/tree/a6daedfcc625ccde0f712f72b1cd005a1706635c) |
| NocoDB (`nocodb`) | `nocodb/nocodb:latest` | Rezept: pipeline; 32768 MiB Startreserve | [Quelle](https://github.com/nocodb/nocodb/tree/f9731d9d7e7366328834cac29f84c94b62263009) |
| Node Exporter (`node_exporter`) | `prom/node-exporter:latest` | Rezept: go; 4096 MiB Startreserve | [Quelle](https://github.com/prometheus/node_exporter/tree/b9e296a911c8beaf89177362e75cc80bfa89eb7e) |
| Node-RED (`node_red`) | `nodered/node-red:latest` | Rezept: npm; 8192 MiB Startreserve | [Quelle](https://github.com/node-red/node-red/tree/df0a87cce1a243e21a2e0eb0fdbdbb8c4732392f) |
| Open WebUI (`open_webui`) | `ghcr.io/open-webui/open-webui:main` | Rezept: python; 24576 MiB Startreserve | [Quelle](https://github.com/open-webui/open-webui/tree/91ea4e3421d1d8069f13d4a463fcb5986d94ea60) |
| Penpot (`penpot`) | `` | Rezept: pipeline; 65536 MiB Startreserve | [Quelle](https://github.com/penpot/penpot/tree/74add0522668dffe9bb35cd18bc8a0e812372b5e) |
| Prometheus (`prometheus`) | `prom/prometheus:latest` | Rezept: make; 16384 MiB Startreserve | [Quelle](https://github.com/prometheus/prometheus/tree/a2fda0ef4638518a6a6fb27fc48be88fbd732f4b) |
| Promtail (`promtail`) | `grafana/promtail:latest` | Rezept: go; 16384 MiB Startreserve; nur freigegebener EOL-Archivbuild | [Quelle](https://github.com/grafana/loki/tree/1906dc2b29e1f1ffc37d9a6c9375d1590d7078a7) |
| Qdrant (`qdrant`) | `qdrant/qdrant:latest` | Rezept: rust; 24576 MiB Startreserve | [Quelle](https://github.com/qdrant/qdrant/tree/222b2e44ab1c3f17e8246396ead6558e45041df7) |
| Rhasspy (`rhasspy`) | `rhasspy/rhasspy:latest` | **OFFEN:** Native Gesamtpaketierung, Laufzeitabhaengigkeiten und Datenmigration noch nicht verifiziert; kein Docker-Fallback. | [Quelle](https://github.com/rhasspy/rhasspy) |
| SearXNG (`searxng`) | `docker.io/valkey/valkey:8-alpine, docker.io/searxng/searxng:latest` | Rezept: python; 8192 MiB Startreserve | [Quelle](https://github.com/searxng/searxng/tree/81371861f67226091d1c4df2e3908a11d3b54eb9) |
| Stirling PDF (`stirling_pdf`) | `frooodle/s-pdf:latest` | Rezept: pipeline; 24576 MiB Startreserve | [Quelle](https://github.com/Stirling-Tools/Stirling-PDF/tree/5c59188758c14efb9c5df1bd28e1e9ed568c6e45) |
| Uptime Kuma (`uptime_kuma`) | `louislam/uptime-kuma:latest` | Rezept: npm; 8192 MiB Startreserve | [Quelle](https://github.com/louislam/uptime-kuma/tree/0c287ac4b3a6723c56ab7d8d731017e58deff533) |
| Vault (`vault`) | `hashicorp/vault:1.17` | Rezept: go; 24576 MiB Startreserve | [Quelle](https://github.com/hashicorp/vault/tree/9f51d2357f65b0c6e842d61fb144b605a0bc78ae) |
| Vikunja (`vikunja`) | `vikunja/vikunja:latest` | Rezept: pipeline; 16384 MiB Startreserve | [Quelle](https://github.com/go-vikunja/vikunja/tree/0dc0adac052327e921ad8f136642479807bd61e3) |
| Watchtower (`watchtower`) | `containrrr/watchtower:latest` | Rezept: go; 4096 MiB Startreserve | [Quelle](https://github.com/containrrr/watchtower/tree/ca0e86e824ec05389ab972ea97d04d4bf0476e90) |
| Weaviate (`weaviate`) | `semitechnologies/weaviate:latest` | Rezept: go; 16384 MiB Startreserve | [Quelle](https://github.com/weaviate/weaviate/tree/1baf16202f883ad7410eaa9e4c01e214635d32ad) |
| Zigbee2MQTT (`zigbee2mqtt`) | `koenkk/zigbee2mqtt:latest` | Rezept: pnpm; 8192 MiB Startreserve | [Quelle](https://github.com/Koenkk/zigbee2mqtt/tree/344b6e03b43644c97154a72ca9eae17193c553a2) |

## Installation und Status

### Sichtbarkeit im Tools-Menue

Die Registry allein fuegt keine Zeile zur interaktiven Bash-Auswahlliste hinzu.
Der Abgleich vom 23.10.2026 fand 17 fehlende Menueschluessel trotz vorhandener
Installer: Appsmith, ArchiveBox, Argilla, Budibase, Caddy, Changedetection_IO,
CrowdSec, Directus, Forgejo, Nextcloud, NocoDB, Penpot, Promtail, SearXNG,
Vikunja, Watchtower und Zigbee2MQTT. Sie werden jetzt vor der Hauptschleife
ueber eine [gemeinsame Schluesselliste](../scripts/helpers/native_github_menu.sh)
registriert, ebenso fuer die Status-Normalisierung direkter Skriptaufrufe.
Bestehende Schluessel werden nicht doppelt angelegt. Die etablierte A-Z-
Sortierung, angehaengte Sondergruppe und Trennlinie nach Ruflo bleiben erhalten.

Alle 43 urspruenglichen Pfade plus PyAirbyte sind damit im Tools-Menue
adressierbar. Menueeintrag bedeutet nicht erfolgreiche Installation:
Rhasspy/Airbyte Core bleiben blockiert, Promtail verlangt die EOL-Freigabe,
Watchtower braucht im Betrieb weiterhin die Docker-API.

Nach Uebernahme der vollstaendigen aktuellen Setup-Dateien das laufende Setup
beenden und neu starten, dann Tools aufrufen und zum jeweiligen Namen scrollen.
Ein bereits laufender Bash-Prozess laedt aktualisierte Listen nicht automatisch.
Keine Tools werden durch die Menue-Ergaenzung ausgewaehlt oder installiert.

Die bestehende Tool-Auswahl und die einzelnen Shell-Einstiege verwenden
[`native_github_tools.py`](../scripts/tools/helpers/native_github_tools.py) und
das [Migrationsmanifest](../config/docker_to_github.json). Bei geplanten Tools
bleibt die eingeschraenkte Reifegradanzeige absichtlich erhalten. Direkte CLI-
Pruefung ist fuer alle 43 urspruenglichen Slugs und PyAirbyte verfuegbar:

```bash
# Read-only plan: no downloads, dependencies, host changes or service start.
bash scripts/tools/node_exporter_install.sh --dry-run
# Explicit build, only after reviewing the plan and upstream license.
bash scripts/tools/node_exporter_install.sh
bash scripts/tools/node_exporter_status.sh
bash scripts/tools/node_exporter_doctor.sh
bash scripts/tools/node_exporter_update.sh --dry-run
# Example of an honestly blocked path; install itself will fail, not pull images.
bash scripts/tools/airbyte_install.sh --dry-run
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
Mosquitto bietet unter Ubuntu 24.04 zusaetzlich einen ausdruecklich freigegebenen
apt-Schritt fuer Buildwerkzeuge/Bibliotheken an, nicht fuer den Broker selbst:
[Mosquitto-Build und cmake-Reparatur](tools/mosquitto.md).
Node Exporter verlangt Go >=1.26. Nach ausdruecklicher Freigabe kann der
vorhandene private Bootstrap ein pruefsummengesichertes offizielles Go-Archiv
bereitstellen, ohne System-Go oder globalen PATH-Wechsel:
[Node Exporter: go fehlt](tools/node-exporter.md).
Caddy nutzt dieselbe zustimmungspflichtige Go-Einrichtung mit eigener privater
Toolchain und verlangt ebenfalls Go >=1.26. Kein Webserver- oder ACME-Start:
[Caddy: go fehlt](tools/caddy.md).
Go verwendet `GOTOOLCHAIN=local`, Rust eine vorhandene Toolchain. Ein abweichendes
vorhandenes Python ist mit `NATIVE_SOURCE_PYTHON_BIN` waehlbar.

Primaerprogramme werden aus GitHub-Quellen (Forgejo: freigegebenes Codeberg)
gebaut, nicht als fertige Images
oder Release-Binaries ersetzt. Prometheus baut auch seinen promu-Helfer aus
Go-Quellen, statt den Binary-Download aus Makefile.common zu verwenden. npm/pnpm,
Cargo, Go und Python beziehen weitere Abhaengigkeiten aus ihren offiziellen
Paketdiensten; das ist **kein ausschliesslicher GitHub-Source-Build jeder
transitiven Abhaengigkeit**. Paket-/Buildhooks fuehren Code aus. Die privaten
Buildumgebungen erben keine Provider-/AWS-Schluessel; Docker/Podman/sudo-Aufrufe
ueber PATH werden gesperrt. Das ersetzt keine Sicherheits-Sandbox gegen
boesartigen Buildcode oder absolute Programmpfade.

Speicherreserve je Rezept: 4 bis 64 GiB. Unter WSL wird auch C: geprueft; freie
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
- Forgejo nutzt nach ausdruecklicher Nutzerfreigabe die offizielle Codeberg-Quelle.
  Das Rezept baut Release 17.0.0 mit Frontend, eingebetteten Assets und SQLite.
  Der Commit wurde ueber die offizielle Codeberg-API aufgeloest, nicht ueber
  einen GitHub-Mirror. Ein Git/TLS-Verbindungsfehler bleibt ein Fehler im Log;
  die Quelle wird dann nicht stillschweigend gewechselt.
- Promtail ist EOL; nur ein ausdruecklich freigegebener Archivbuild ist moeglich,
  kein automatisch gestarteter Produktivdienst. Alloy wird nativ gebaut; fuer
  eingebettete Beyla-Komponenten sind offizielle GitHub-Release-Assets mit
  Pruefsummen nach ausdruecklicher Nutzerfreigabe erlaubt.
- Vorhandene `stacks/`, Kubernetes-Images, Compose-Vorlagen und historische
  Docker-Helper bleiben als explizite Container-Alternativen im Repository.
  Die 43 umgestellten Tool-Wrapper rufen sie nicht mehr auf. Ein gesamthaft
  Docker-freies Kubernetes-/Profil-System ist **nicht** behauptet.

## Zusaetzliche Buildumfaenge und Grenzen

Die folgenden Wege wurden um echte Build-/Paketbefehle ergaenzt; ein reiner
Git-Clone reicht fuer keinen Buildmarker. Die Tabelle oben und das Manifest
unterscheiden verfuegbare Rezepte weiterhin von offenen Migrationen.

- Apache Tika baut die Server-Distribution einschliesslich Bibliotheken als ZIP.
  Die einzelne Server-JAR ohne `lib/` waere kein vollstaendiges Paket.
- Appsmith baut Client, RTS, MCP und Java-Server. Budibase baut seinen Workspace
  mit Server, Worker, Builder und Client. MongoDB/CouchDB, Redis, S3, Reverse
  Proxy und Prozessverwaltung werden nicht stillschweigend eingerichtet.
- Argilla baut das Frontend in das statische Verzeichnis seines Serverpakets,
  bevor dieses lokal installiert wird. Keine Default-Benutzer, Suchindizes oder
  Datenbankmigrationen. Redis und Elasticsearch/OpenSearch separat bereitstellen.
- ArchiveBox installiert das Python-Paket aus dem Checkout, ohne `init`/`setup`,
  Browserinstallation oder Archivierungsauftrag. Der Pin verlangt Python >=3.13.
- Directus baut API und Admin-App mit dem gepinnten pnpm. Keine DB-Migration.
  Die Upstream-Lizenz vor kommerziellem Betrieb gesondert pruefen.
- Grafana baut Wire-Code, OSS-Backend und Produktionsfrontend gemeinsam. Der
  Frontend-Build benoetigt erheblich RAM; die Vorpruefung verlangt 12 GiB.
- Home Assistant ist ein Core-Paket, kein OS/Supervisor. Der Pin verlangt
  Python >=3.14.2. Zusaetzliche Integrationen, Frontend und Hardware separat
  pruefen; kein Zugriff auf USB, Bluetooth oder das Heimnetz beim Pakettest.
- Open WebUI baut das Frontend per `npm ci` und paketiert es mit dem Backend.
  Der Upstream-Hatch-Hook mit `npm install --force` wird dabei deaktiviert.
  Python 3.11/3.12 und Node 18 bis 22 sind am Pin erforderlich. Pyodide-Assets
  sind Buildabhaengigkeiten, keine heruntergeladenen Sprachmodelle.
- Metabase baut die OSS-Uberjar inklusive Frontend; Neo4j die Community-
  Distribution. Bestehende Datenbanken werden weder gestartet noch geoeffnet.
- Nextcloud baut PHP-Abhaengigkeiten und beide Frontends. `nextcloud/3rdparty`
  wird ausschliesslich am Gitlink-Commit des Server-Checkouts geholt. Composer
  prueft die vorhandenen PHP-Erweiterungen; kein `occ install` oder `upgrade`.
- Netdata wird als nativer Agent/API mit DBEngine gebaut, **ohne Dashboard**,
  ML/eBPF oder privilegierte Zusatzplugins. So entfaellt der sonstige Dashboard-
  Download von `app.netdata.cloud`. Die Cloud-Protokollquellen kommen aus dem
  gepinnten GitHub-Submodul; keine Cloud-Registrierung oder Hostrechte-Erweiterung.
- Stirling PDF baut die Core-Variante mit Frontend. Vorhandenes JDK 25, Gradle
  9.7.1 und Go Task sind erforderlich; automatische JDK-Downloads sind gesperrt.
  OCR-/Office-Hilfsprogramme und Dienste bleiben separate Voraussetzungen.
- Vault wird als Server/CLI **ohne eingebettete Web-UI** gebaut. Die BUSL-1.1-
  Lizenz bleibt verbindlich; kein Init, Unseal oder Dev-Server.
- Vikunja baut zuerst das Frontend und bettet es in das Go-Backend ein. Ein
  vorhandener C-Compiler ist wegen CGO erforderlich; kein Platzhalter-Frontend.
- Watchtower kommt als selbst gebautes GitHub-Go-Binary. **Es benoetigt im
  Betrieb weiterhin die Docker-API.** Der Build greift nicht auf einen Socket
  zu und aktualisiert keine Container. Nicht fuer einen Docker-freien Host gedacht.

### Promtail nur als Archivbuild

Promtail hat seit dem 02.03.2026 keinen Support mehr. Der gepinnte Archivstand
`v3.5.11` ist kein Sicherheitsupdate und keine Empfehlung fuer neue Dienste.
Der Installer verweigert den Build ohne ausdrueckliche Bestaetigung:

```bash
bash scripts/tools/promtail_install.sh --dry-run
# Only for an explicitly reviewed archival/migration build, not production deployment.
NATIVE_ALLOW_EOL_PROMTAIL=1 bash scripts/tools/promtail_install.sh
```

### Herkunft und Paketmanager

Alle 43 angefragten Programme stehen jetzt auch in `config/tools.yml`, nicht
nur in einzelnen Skriptdateien. Neu ergaenzte Rezepte verwenden unveraenderliche
GitHub-Commits; mehrere davon sind Entwicklungsstaende. Vorhandene passende
Toolchains sind Voraussetzung, kein automatisches System-Upgrade. npm/pnpm/yarn,
Maven, Clojure, Gradle, Cargo und uv duerfen ihre normalen Buildabhaengigkeiten
beziehen. Das ist keine Zusicherung, dass jede transitive Bibliothek aus
GitHub-Quellcode kompiliert wird. Source-available-Lizenzen werden durch einen
GitHub-Download nicht zu freien Open-Source-Lizenzen.

Forgejo verwendet nach Nutzerfreigabe vom 23.10.2026 die offizielle Codeberg-
Quelle als ausdrueckliche Ausnahme. `source_verified: true` und
`source_exception` kennzeichnen dies in der Registry; der Installer erlaubt
keine beliebigen zusaetzlichen Quellenhosts.

## Tests und verbleibende Arbeit

[Offline-Fixtures](../tests/test_native_github_tools.py) pruefen alle Rezepte mit
gemockten Compilern, 264 Lifecycle-Wrapper, Fehlerlogging, Rollback, Idempotenz,
Marker, Dateigrenzen und die expliziten Blocker. Das sind keine realen
Linux-Builds. Kein Tool, Container oder Dienst wurde auf dem Nutzersystem gestartet.

Noch offen sind Airbyte Core und Rhasspy.
Rhasspys konkrete Archiv-/Kompatibilitaetsgruende und die verbleibende Arbeit
stehen in der [Rhasspy-2-Einordnung](tools/rhasspy.md).
Ausstehend sind auch reale Builds der verfuegbaren Rezepte auf isoliertem Ubuntu
sowie je Dienst Konfiguration, Betrieb, Restore und Upgrade. Erst nach diesen
Nachweisen als einsatzbereit einstufen.

Die aktualisierten Offline-Vertragstests pruefen zusaetzlich Mehrkomponenten-
Artefakte, Python-Vorpruefung, Promtail-Freigabe und falsche Submodul-Pins.
Die frueheren Fixture-/Shell-Nachweise ersetzen keine Abnahme dieser neuen
Compilerlaeufe. Kein vollstaendiger Repo-Testlauf, Ubuntu-Build oder Runtime-Start.

Die lokalen Offline-Tests sind kein Nachweis erfolgreicher Ubuntu-Compilerlaeufe.
Die neu hinzugekommenen Adaptertests kontrollieren insbesondere SHA256/Laenge,
Redirect-Hosts, vorhandene SDKs und die Trennung von Airbyte Core und PyAirbyte.
Lokaler Nachweis der Ergaenzung: 35 Migrations-/Adaptertests, 8 Status-/Build-
Abhaengigkeitstests und 13 Audit-Fixtures bestanden (56 Python-Tests).
Die drei Shell-Vertraege fuer Node Exporter, Mosquitto und Airbyte bestanden.
Die gemeinsame Bash-Syntaxpruefung erfasste 264 Lifecycle-Wrapper, das Setup und
den Penpot-WASM-Adapter (266 Dateien). Keine realen Ubuntu-Builds oder Dienste.

Weitere offizielle Einordnung:
[Airbyte/abctl und Docker](https://docs.airbyte.com/platform/using-airbyte/getting-started/oss-quickstart),
[Forgejo-Quellen und Releases](https://forgejo.org/download/),
[Promtail EOL](https://grafana.com/docs/loki/latest/send-data/promtail/).

## Primaerquellen fuer ergaenzte Buildvertraege

Die Quelllinks in der Tabelle zeigen bei verfuegbaren Rezepten direkt auf den
geprueften Commit. Insbesondere wurden die Paketdefinitionen und Builddateien
(Makefile, pom.xml, pyproject.toml, package.json beziehungsweise build.gradle)
gelesen, nicht nur die Startseite. Weitere relevante Originalquellen:

- [Hatch: Build-Hooks abschalten](https://hatch.pypa.io/latest/config/build/#environment-variables)
- [Forgejo 17.0.0: offizieller Release-Commit](https://codeberg.org/forgejo/forgejo/src/commit/0d791421f85ca13a63b665053d81ea765fbbc571)
- [Netdata: Dashboard-Download im Build](https://github.com/netdata/netdata/blob/4ca8ebf9c40a2e36b42b0255269a2a97948c752b/packaging/cmake/Modules/NetdataDashboard.cmake)

## Ergaenzung: Alloy, Langfuse, NocoDB, Penpot und PyAirbyte

Die vier zuvor offenen Buildrezepte und das separate SDK sind experimentell.
Buildfehler bleiben sichtbar; ein Checkout allein erzeugt keinen Buildmarker.
Die vorhandenen System-Toolchains muessen zum gepinnten Quellstand passen.

| Tool | Build und Voraussetzungen | Nicht automatisch enthalten |
|---|---|---|
| Grafana Alloy | Go/C-Compiler, Make, Node >=24.16.0 und npm >=11.13.0 laut gepinnter UI; 48 GiB Disk, 8 GiB verfuegbarer RAM | Collector-Start, privilegiertes eBPF, Konfigurationsmigration |
| Langfuse | Node 24, pnpm 12.8.2, Rust/Cargo und native Compiler; Web + Worker + Rust-Addon; 48 GiB Disk, 12 GiB RAM | ClickHouse, PostgreSQL, Redis, S3, Secrets und Schema-Migration |
| NocoDB | Vorhandenes Node exakt 24.14.0, pnpm 10.28.2; CE-API-Bibliothek, SDK und statisches Frontend; 32 GiB Disk, 8 GiB RAM | Datenbankinitialisierung, Reverse Proxy, kommerzielle Lizenzfreigabe |
| Penpot | Vorhandenes Rust 1.99.0 mit wasm32-unknown-emscripten, Emscripten, pnpm 12.15.0, Node >=24, JDK/Clojure, jq; Backend-JAR, Frontend, WASM und Exporter; 64 GiB Disk, 16 GiB RAM | PostgreSQL, Redis, Browser fuer Exporter, TLS, Auth, Dienststart |
| PyAirbyte | Python >=3.10,<3.13, uv; lokales GitHub-Paket in privater venv; 16 GiB Disk | Airbyte Core, Connectoren, Accounts, Datenquellen, Jobs oder MCP-Serverstart |

### Bewusste GitHub-Release-Abhaengigkeiten

Alloy selbst wird aus [gepinnten Quellen](https://github.com/grafana/alloy/tree/3b2a3565546bd36592dc49ca28604ad187f0fb85)
gebaut. Nach Nutzerfreigabe vom 23.10.2026 darf der Upstream-Downloader
Beyla v3.38.0 einbetten. Die [committete Versionsdatei](https://github.com/grafana/alloy/blob/3b2a3565546bd36592dc49ca28604ad187f0fb85/internal/component/beyla/ebpf/internal/config/gen/beyla/beyla_version.yaml)
und der [Downloader](https://github.com/grafana/alloy/blob/3b2a3565546bd36592dc49ca28604ad187f0fb85/internal/component/beyla/ebpf/internal/config/gen/download.go)
legen SHA256 fest und pruefen vor dem Entpacken:

- amd64: `7d760a6a7905dcfc9fd0468964b19fe1728f0a83dd54115243e7346c8faf37bc`
- arm64: `a6fc6e8402d2dd3df702711981355290175848d6bf5b4371a06c425d8bfe9586`

Penpots Rust-Abhaengigkeit Skia verwendet ebenfalls ein
[offizielles GitHub-Release-Asset](https://github.com/penpot/skia-binaries/releases/tag/0.153.3),
kein Container-Image. Der Adapter prueft exakt 28.266.131 Bytes und SHA256
`658b8c20466661fdbe8d8040377c223717cdefccbffba11b515b732e07c399d4`
und uebergibt Cargo erst danach das lokale Archiv per file-URL. Der Nachweis
bleibt in `github-build-assets.json`. Das ist kein Source-Build dieser
transitiven Skia-Bibliothek. Die Primaranwendung Penpot wird kompiliert.

### Keine globalen Toolchain-Wechsel und keine versteckten Starts

Penpot ruft nicht den global veraendernden Upstream-WASM-Setupweg auf.
`PENPOT_EMSDK_ENV=/absoluter/pfad/emsdk_env.sh` waehlt ein bereits vorhandenes
SDK. Optional waehlt `NATIVE_SOURCE_RUST_TOOLCHAIN=/absoluter/toolchainpfad`
eine vorhandene Rust-Toolchain. Kein rustup default/target add, kein emsdk install.
Der Emscripten-Cache bleibt im neuen privaten Buildordner.

Langfuses `DOCKER_BUILD=1` ist ausschliesslich ein Upstream-Buildschalter, der
beim Kompilieren fehlende Laufzeit-Secrets erlaubt; er startet kein Docker und
gehoert nicht in die spaetere Produktivkonfiguration. Prisma erzeugt nur Code,
keine Migration oder Seeds. Der Web-Build prueft seinen OTel-Worker kurz lokal
und beendet ihn wieder; kein dauerhaft laufender Agent oder Collector.

NocoDBs private .npmrc nutzt das bereits gepruefte Node statt pnpm einen
weiteren Node-Download ausfuehren zu lassen. Die Originaldatei bleibt als
`upstream.npmrc.original`; der CE-Integrationsgenerator ist eine private Kopie.
Die Development-Konfiguration mit automatischem Serverstart wird nicht genutzt.
Der Installer prueft den getrennten `run-native.cjs` nur syntaktisch.
Manueller Erststart kann Datenbanken initialisieren/migrieren und verlangt
deshalb eine ausdrueckliche Freigabe nach Backup:

```bash
# First review the generated RUN_NATIVE.md and the upstream license.
cd ~/.openclaw_ultimate_user_data/tools/nocodb/native-github
NOCODB_ACCEPT_INITIALIZATION=1 node run-native.cjs --run
```

Der Starthelfer bindet nur 127.0.0.1 oder ::1, standardmaessig Port 8080.
Daten liegen ausserhalb des Buildordners (standardmaessig im benachbarten data/).
Optional: absoluter `NOCODB_DATA_DIR`, `NOCODB_PORT`, `NOCODB_BIND_HOST`.
Authentifizierung und abgesicherten Reverse Proxy vor Zugriff konfigurieren.
Frontend-Vendorressourcen koennen beim spaeteren Browserzugriff externe
Verbindungen aufbauen; lokal installiert bedeutet nicht pauschal offline.
NocoDBs Sustainable Use License ist keine pauschale OSI-Open-Source-Freigabe.

### Zigbee2MQTT: fehlendes Node/pnpm gezielt bereitstellen

Die [Zigbee2MQTT-Anleitung](tools/zigbee2mqtt.md) beschreibt die private
Node-/pnpm-Basis nach Zustimmung, mit festen Versionen und SHA256-Pruefung.
Der neue Bootstrap braucht 9216 MiB Reserve, auch auf dem WSL-Windows-Host.
Kein Dienststart, MQTT-, USB- oder Funkzugriff; Zigbee2MQTT bleibt ein
GitHub-Quellbuild ohne Docker.

### Watchtower: fehlendes Go und Legacy-Status

Die [Watchtower-Anleitung](tools/watchtower.md) erklaert die private Go-
Einrichtung nach Zustimmung und den GitHub-Quellbuild ohne Docker.
Das archivierte Werkzeug benoetigt im spaeteren Betrieb weiterhin Docker;
es aktualisiert keine nativen Programme. Der Installer startet keinen
Updater und prueft nur `--help`, nicht das am Pin ungueltige `--version`.

### SearXNG: fehlendes uv gezielt bereitstellen

[Node-RED](tools/node-red.md) besitzt einen getrennten privaten Node-/npm-
Bootstrap mit `--install-build-deps`; kein pnpm und kein Docker-Fallback.
Neue Basis verlangt 9216 MiB Reserve; bestehende Flows bleiben unberuehrt.

[MinIO](tools/minio.md) kann bei fehlendem Go den privaten Go-Bootstrap
mit `--install-build-deps` nutzen. Konservativ Go >=1.24.8; kein Serverstart
oder Bucketzugriff. Wartungswarnung der Community-Quelle vor Nutzung lesen.

[LiteLLM](tools/litellm.md) kann den privaten uv-Bootstrap ebenfalls nach
Zustimmung nutzen. Python >=3.10,<3.15 vorab pruefen; 8448 MiB Reserve bei
neuer uv-Basis. Kein Proxy-/Datenbank-/Cloudstart durch Paketinstallation.

[Changedetection_IO](tools/changedetection_io.md) verwendet ebenfalls den
privaten GitHub-uv-Bootstrap nach Zustimmung, mit Python >=3.11 vor dem Download
und 8448 MiB Reserve bei neuer Toolchain. Keine Browser-/Watch-Aktivierung.

Fuer [cAdvisor](tools/cadvisor.md) steht bei fehlendem Go nun ebenfalls der
private Go-Bootstrap mit `--install-build-deps` zur Verfuegung. Go >=1.25.0
am Pin, kein System-Go-Umbau und kein automatischer Monitoring-Dienststart.

Auch [ArchiveBox](tools/archivebox.md) kann denselben privaten uv-Bootstrap
nach Zustimmung nutzen. Vorher ist am ArchiveBox-Pin Python >=3.13 erforderlich;
kein automatischer Python-Download. 8448 MiB Reserve bei neuer uv-Einrichtung.

Die [SearXNG-Anleitung](tools/searxng.md) beschreibt den zustimmungspflichtigen
privaten uv-Bootstrap aus einem SHA256-geprueften offiziellen GitHub-Release.
Kein System-Python-Umbau, kein Docker und kein Suchdienststart. Bei einem
neuen Bootstrap gelten 8448 MiB statt 8192 MiB Reserve; knappen Windows-
Hostspeicher zuerst freimachen.

### Airbyte Core bleibt getrennt; Rhasspy bleibt ein Altbestand

[PyAirbyte am Pin](https://github.com/airbytehq/PyAirbyte/tree/b911c5d13e1a33219dcc537d4eb8898203a9364b)
ist zusaetzlich unter **PyAirbyte** im Tools-Menue registriert. Es wird aus
GitHub ohne Docker installiert, nicht als gleichwertiger Ersatz fuer die
Airbyte-Plattform ausgegeben. Manche SDK-Connectorwege brauchen spaeter
weiterhin Container; diese werden weder eingerichtet noch gestartet.

```bash
bash scripts/tools/pyairbyte_install.sh --dry-run
bash scripts/tools/pyairbyte_install.sh
bash scripts/tools/pyairbyte_doctor.sh
```

Airbyte Core verwendet fuer Plattform/Konnektoren weiterhin Container. Ein
CLI-Build allein erfuellt keine containerfreie Plattforminstallation.
[Rhasspy v2.5.11](https://github.com/rhasspy/rhasspy/releases/tag/v2.5.11)
stammt von 2021. Seine Python-3.7/3.8-era Abhaengigkeiten und Audio-/STT-
Komponenten benoetigen einen eigenen Kompatibilitaets- und Supply-Chain-Audit
fuer Ubuntu 24.04. Ein Quellen-Clone oder Paket ohne diese Dienste wird nicht
als funktionsfaehiger Sprachassistent markiert. Beide Pfade bleiben deshalb
mit klarer Fehlermeldung blockiert, ohne Docker-Fallback.
