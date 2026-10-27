# Native statt Docker: Rollback und Ubuntu-Releasewechsel

Stand: 2026-10-27. Geltungsbereich dieser Matrix sind die **49 Eintraege** in
`config/docker_to_github.json`: 45 implementierte native Buildrezepte und vier
ausdruecklich blockierte Gesamtplattformen. Andere Installer-Engines und Ansible-
Deployments brauchen ihre eigenen Nachweise; diese Matrix behauptet keine
vollstaendige Rollback-Abnahme aller Werkzeuge des Gesamtkatalogs.

## Gemeinsame Szenarien

**A: neuer Build scheitert.** Der Dispatcher entfernt nur den neu angelegten
privaten `tools/<slug>/native-github`-Buildbaum und erzeugt keinen Erfolgsmarker.
Die Quellen duerfen nicht als fertige Anwendung gelten. Logs, private
Basiswerkzeuge, bereits vorhandene Nutzdaten und alte Container/Volumes bleiben.
Bei unvollstaendiger Bereinigung steht der Restpfad im aktuellen Log. Nicht
pauschal `sudo rm -rf`, `docker system prune`, `down -v` oder ein Reset des
gesamten User-Workspaces ausfuehren. Nach hartem Prozess-/WSL-Abbruch zuerst
Installations-Reset/Diagnose benutzen, nicht einen aktiven Lock blind loeschen.

**B: alter Build vorhanden.** Ein zum Rezept passender Nachweis fuehrt zum
Ueberspringen; fremde Pins oder veraenderte Artefakte werden abgewiesen.
`update` ist damit **kein** automatischer A/B-Versionswechsel. Alten Code,
relevante ENV-/Konfigurationsdateien und anwendungskonsistente Daten vorher
verschluesselt sichern. Neue Ubuntu-Version und neuen Pin in separater
Wegwerf-VM bzw. separatem Test-Workspace bauen; alten Dienst nicht automatisch
stoppen. Rueckkehr nur zur geprueften alten Runtime samt kompatiblem Datenstand.
Ein erfolgreicher Build allein rechtfertigt keinen Datenbank-Downgrade.

**C: Implementierung blockiert.** Kein Download/Build/Marker und kein Docker-
Fallback. Der Altbestand bleibt erhalten; funktionierendes Altsystem bis zur
separaten Migration nicht deinstallieren. Eine Quellenkopie ersetzt die Plattform
nicht.

**D: Caddy-Sonderfall.** Ein unmarkierter Altordner kann nur mit ausdruecklicher
Reparaturfreigabe erhalten/umbenannt werden. Er wird nicht als lauffaehiger
Rollbackstand ausgegeben; fuer den neuen Build ist zusaetzlicher Platz noetig.

## Matrix je Tool

Die Datenhinweise sind vor einem Dienst-/Schemawechsel zusaetzlich zu A/B zu
beachten. Sie sind keine Behauptung, dass der Build-Installer diese Dienste startet.

| Slug | Buildfehler / Altstand | Zusaetzlich erhalten und vor Migration pruefen |
|---|---|---|
| `traefik` | A / B | Routes, TLS-Schluessel, Zertifikate und bisherige Unit |
| `kubeseal` | A / B | Controller-Recovery-Key separat; CLI-Downgrade entschluesselt nichts |
| `opentelemetry` | A / B | Collector-Konfiguration, Queue-/Bufferdaten und Exportervertraege |
| `autogpt` | C | Platform-DB, Worker, Volumes, Accounts; kein Classic-Ersatz |
| `supabase` | C | Postgres, Auth, Storage, Funktionen und migrationskompatible Dumps |
| `airbyte` | C | Konnektorzustand, Jobs, Credentials, DB und Plattform-Volumes |
| `apache_tika` | A / B | Serverkonfiguration, Parserprofile und externe Bibliotheken |
| `appsmith` | A / B | Datenbanken, Schluessel und Anwendungsexporte |
| `archivebox` | A / B | Archivsammlung, Indexdatenbank und Browserprofile |
| `argilla` | A / B | Suchindex, DB, Datensaetze und Benutzerkonfiguration |
| `budibase` | A / B | CouchDB/Redis-Zustand, Apps, Assets und Secret-Schluessel |
| `caddy` | A / B / D | Caddyfile, Zertifikatsdaten und alte Unit getrennt erhalten |
| `cadvisor` | A / B | Collector-Flags, Unit, Mounts und Hostrechte |
| `changedetection_io` | A / B | Watch-Daten, Historie, Browser- und Benachrichtigungskonfiguration |
| `crowdsec` | A / B | Lokale Datenbank, Collections, Bouncer-Keys und Firewallwirkung |
| `directus` | A / B | DB-Dump, Uploads, Extensions und Schema-Migrationsstand |
| `forgejo` | A / B | Repositories, Datenbank, LFS, SSH-Keys; offizielle Codeberg-Ausnahme |
| `grafana` | A / B | Datenbank, Plugins, Provisioning und Dashboards |
| `grafana_alloy` | A / B | Konfiguration, WAL/Queues, Beyla-Assets und alte Unit |
| `healthchecks` | A / B | DB, Projekt-/Check-IDs und Benachrichtigungsschluessel |
| `home_assistant` | A / B | Vollstaendiges Konfigurations-/DB-Backup und Integrationsversionen |
| `langfuse` | A / B | Postgres, ClickHouse, Redis, S3 und kompatible Migrationsstaende |
| `litellm` | A / B | Modellrouting, Budget-DB, Proxy-Keys und bestehende Runtime |
| `loki` | A / B | Index-/Chunk-Storage, Schema- und Retention-Konfiguration |
| `meilisearch` | A / B | Versionskompatibler Dump statt blindem Datenverzeichnis-Downgrade |
| `metabase` | A / B | Anwendungs-DB-Dump und gesicherte Verbindungseinstellungen |
| `minio` | A / B | Extern gesicherte Objekte, Metadaten, IAM und KMS; Wartungswarnung beachten |
| `mosquitto` | A / B | Persistenzdatei, ACLs, Passwortdateien und TLS |
| `neo4j` | A / B | Transaktionskonsistentes DB-Backup, Plugins und Store-Version |
| `netdata` | A / B | Konfiguration, lokale Historie und bestehende Privilegien |
| `nextcloud` | A / B | Wartungsmodus, DB-Dump, Daten, config.php und App-Versionen |
| `nocodb` | A / B | Externe Datenbank, Uploads, vorheriger CE-Stand; keine blinde Schema-Ruecknahme |
| `node_exporter` | A / B | Collector-Konfiguration und Textfile-Verzeichnis |
| `node_red` | A / B | Flows, Credential-Secret und gesichertes userDir |
| `open_webui` | A / B | Datenbank, Dateien, WEBUI_SECRET_KEY und passende Schema-Version |
| `penpot` | A / B | Postgres, Redis, Objektspeicher, Assets und passender WASM-/Frontendstand |
| `prometheus` | A / B | TSDB-Snapshot, Regeln, Scrape-Konfiguration und Kompatibilitaet |
| `promtail` | A / B | Positionsdateien, Loki-Ziele; EOL-Build nur nach separater Archivfreigabe |
| `qdrant` | A / B | Collection-Snapshots, Embedding-Vertrag, API-Keys und getesteter Restore |
| `rhasspy` | C | Legacy-Profile, MQTT-/Audio-Konfiguration; Ubuntu-24.04-Abnahme fehlt |
| `searxng` | A / B | settings.yml, Redis/Limiter und gepruefte Engine-Konfiguration |
| `stirling_pdf` | A / B | Benutzer-/Konfigurationsdaten und externe PDF-/OCR-Werkzeuge |
| `uptime_kuma` | A / B | SQLite-Backup, Monitor-IDs und Benachrichtigungsschluessel |
| `vault` | A / B | Getesteter Storage-/Raft-Snapshot und getrennte Unseal-/Recovery-Keys |
| `vikunja` | A / B | DB-Dump, Dateien und JWT-/Session-Konfiguration |
| `watchtower` | A / B | Alter Containerbestand; archiviertes Tool aktualisiert keine nativen Builds |
| `weaviate` | A / B | Konsistentes Backup der Collections, Module und Cluster-Konfiguration |
| `zigbee2mqtt` | A / B | data/, Coordinator-Backup, Netzwerk-Keys; kein Funkreset |
| `pyairbyte` | A / B | Lokale SDK-Projekte, Datenquellen und Konnektorzustand; kein Airbyte-Core-Ersatz |

## Abnahme auf einem neuen Ubuntu-Release

1. Aktuellen Setup-Commit, Rezept-Pin, Betriebssystem, Architektur und Toolchains erfassen.
2. Bestehende Anwendung und Daten anwendungskonsistent sichern; Restore separat testen.
3. Native Abhaengigkeiten und Build nur isoliert testen, nicht zuerst das Produktiv-OS ersetzen.
4. Buildnachweis, Versionsprobe und Wiederholungsinstallation pruefen; kein Modell-/Kontozugriff ohne Freigabe.
5. Erst dann Laufzeit-, Auth-, Netzwerk-, Datenmigrations- und Rueckkehrtest im Wartungsfenster abnehmen.

GitHub-Source-Builds sind keine Sandbox: Buildhooks fuehren Fremdcode mit den
Rechten des Buildbenutzers aus. Ein eigener Buildbenutzer/VM ohne persoenliche
Secrets ist sicherer als ein Build im angemeldeten Administratorkonto.
Lesen von Secrets auf der Platte wird nicht schon durch bereinigte ENV verhindert.
Nach OS-/ABI-Wechsel kann die alte Binaerdatei unbrauchbar sein; die bisherige
OS-/VM-Sicherung gehoert deshalb zum Rollbackplan.
