# Verbleibende Docker-Pfade und GitHub-Umstellung

Stand: 27.10.2026. Statische Repository-Pruefung, kein Scan installierter Container. Dieser Nachtrag
erweitert die [bisherige Umstellung](DOCKER_TO_GITHUB.md). Ein GitHub-Checkout mit anschliessendem
Compose-Start ist weiterhin Containerbetrieb.

## Neu gefundene aktive Tool-Installer

| Tool             | Bisheriger Pfad                                                                                           | Bearbeitung                                                                                         | Verbleibende Abnahme                                                                                         |
| ---------------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| OpenTelemetry    | `scripts/tools/opentelemetry_install.sh`: Docker-Paketbereitstellung, Collector-Image 0.100.0, Compose up | Nativer Core-Collector aus festem GitHub-Commit; kein Docker und kein automatischer Collector-Start | Linux-Quellbuild, Komponenten-/Konfigurationsmigration und OTLP-Betrieb testen                               |
| AutoGPT Platform | `scripts/tools/autogpt_install.sh`: GitHub-Clone, Buildx/Compose, Container-Abhaengigkeiten               | Automatischer Docker-Weg entfernt; nativer Installer meldet OFFEN und Fehler statt Erfolgsmarker    | Backend, Frontend, Worker, Datenbanken und Queue nativ integrieren; Classic ist kein gleichwertiger Ersatz   |
| Supabase         | `scripts/tools/supabase_install.sh`: GitHub-Clone, Image-Pull und Compose up                              | Automatischer Docker-Weg entfernt; nativer Installer meldet OFFEN und Fehler statt Erfolgsmarker    | PostgreSQL samt Erweiterungen, Auth, Realtime, Storage, Gateway und Studio gemeinsam versionieren und testen |

**Nicht alles ist damit nativ installierbar.** Die letzten zwei Gesamtplattformen sind gesperrte
offene Arbeiten, keine implementierten nativen Builds. Ihre alten Skripte liegen nur noch als
historische `.example`-Dateien unter `docs/proposals/legacy-container-installers/`, ausserhalb
aktiver Installer. Sie sind nicht relocationsfaehig und duerfen nicht als Anleitung ausgefuehrt
werden. Auch Update und Deinstallation der beiden offenen Gesamtplattformen bleiben im nativen
Einstieg gesperrt: alte Containerdaten werden nicht automatisch entfernt. Fuer deren bewusste
Abschaltung/Entfernung ist ein eigener gepruefter Migrationsplan erforderlich. Neue Registry-IDs
`autogpt` und `supabase` bilden diese zuvor nur direkt vorhandenen Installer ab. Der bisherige
geplante `supabase_self_hosted`-Platzhalter bleibt aus Kompatibilitaetsgruenden erhalten; er ist
keine zweite installierte Supabase-Laufzeit. Bestehende Container, Volumes, `/opt`-Installationen,
Daten und Secrets bleiben unangetastet. Auch die beiden zuvor offenen Faelle Airbyte Core und
Rhasspy 2 bleiben offen; PyAirbyte ersetzt Airbyte Core nicht.

Das gemeinsame Manifest umfasst 48 Eintraege: 43 urspruengliche Pfade, PyAirbyte, diese drei
Ergaenzungen und die spaeter hinzugefuegte Kubeseal-CLI. Davon 44 Buildrezepte und vier offene
Faelle (Airbyte Core, Rhasspy 2, AutoGPT Platform, Supabase). Buildrezept bedeutet nicht erfolgreich
auf jeder Plattform gebaut oder betrieben.

## Weitere Docker-Bezuege, keine versteckten nativen Installer

| Bereich                                                         | Befund / Abgrenzung                                                                                                                      | Vorgehen                                                                                                                            |
| --------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Authelia / Authentik                                            | Tool-Installer erzeugen `docker-compose.example.yml`; das ist kein automatisch gestarteter Container und ebenso kein nativer Serverbuild | Als Vorlage kennzeichnen; kein Laufzeitnachweis aus Dateiexistenz ableiten. Native Gesamtintegration separat offen                  |
| Stalwart Mail                                                   | Compose-Beispiel bzw. Statusmeldung; kein belegter automatischer Image-Start in der gefundenen Installerzeile                            | Vor Aktivierung separate Mail-/DNS-/TLS-Abnahme                                                                                     |
| Code Sandbox                                                    | `SANDBOX_RUNTIME=docker` im Konfigurationsvorschlag                                                                                      | Kein durch diese Zeile installierter Container; Runtime explizit waehlen, keine unsichere Host-Shell als Ersatz                     |
| Watchtower                                                      | Bereits GitHub-Go-Build, benoetigt im Betrieb aber Docker                                                                                | Buildherkunft nicht mit Docker-freier Funktion verwechseln                                                                          |
| Docker / Compose Plugin                                         | Infrastrukturwerkzeuge selbst, keine ueber Images installierten Fachanwendungen                                                          | Nicht entfernen; deren Installation ist weiterhin ein eigener expliziter Setup-Pfad                                                 |
| Compose-/Kubernetes-/Monitoring-Stacks, Ansible-Docker-Aufgaben | Separate ausdrueckliche Container-Betriebspfade ausserhalb der einzelnen Tool-Installer                                                  | In dieser Umstellung nicht nativ konvertiert. Nicht als Docker-frei bewerben; keine implizite Ausfuehrung durch neue Tool-Installer |
| Alte Uninstaller / gemeinsame Helper                            | Container-Bezug kann zur expliziten Verwaltung vorhandener Altinstallationen gehoeren                                                    | Kein automatisches Cleanup oder Containerstopp aufgrund dieser Liste                                                                |

Konkret enthaelt `stacks/llmops-platform/docker-compose.yml` weiterhin Containerdefinitionen fuer
LiteLLM, Open WebUI, Qdrant, PostgreSQL, Redis, MinIO, Langfuse, Prometheus, Grafana, Loki, Uptime
Kuma und Netdata. Die bereits nativen Einzeltool-Installer ersetzen diesen optionalen Stack nicht
automatisch. Wer ihn bewusst startet, betreibt weiterhin Container. Ein Umbau der kompletten
Orchestrierung ist noch offen und keine nebenwirkungsfreie Installerkorrektur; bestehende Volumes
nicht durch native Datenpfade ersetzen.

Die statische Suche nach Docker-Aufrufen und gemeinsamen Compose-Wrappern ist kein formaler Beweis
gegen dynamisch erzeugte Befehle oder Container-Aufrufe in spaeter heruntergeladenen
Upstream-Buildhooks. K3s verwendet weiterhin OCI-Images; GitHub-Quellherkunft und containerfreie
Ausfuehrung sind getrennte Eigenschaften.

## Quellen und weitere Arbeit

- [OpenTelemetry Core: gepinnte Quelle](https://github.com/open-telemetry/opentelemetry-collector/tree/30add0562534958c3b4173fa307b5a3497d0bc9c),
  [native Anleitung](tools/opentelemetry-native.md).
- [AutoGPT Originalquelle](https://github.com/Significant-Gravitas/AutoGPT): Platform und Classic
  getrennt bewerten; Quellcode-Lizenz je Teil pruefen.
- [Supabase Originalquelle](https://github.com/supabase/supabase): Self-Hosting-Compose nicht als
  fertigen nativen Build ausgeben.
- [Zentrales Manifest](../config/docker_to_github.json): Pins, Reserven, Buildrezepte und konkrete
  Sperrgruende.

Naechste Abnahme je offener Gesamtplattform: Komponenten/Versionen/Lizenzen inventarisieren,
gepinnte Einzelbuilds ohne Docker pruefen, private Datenpfade und Dienstbenutzer definieren,
Start/Stop/Health/Update/Restore auf einer isolierten Ubuntu-24.04-VM testen. Erst danach
Erfolgsmarker und Runtime-Status freischalten. Kein Ersatz durch Cloud-Pflicht, Datenmigration oder
Container-Fallback.

Der beigefuegte P0-Plan vom 23.10.2026 bevorzugt Compose fuer einen Einzel-VPS. Das ist eine
Architektur-Empfehlung des Dokuments, keine Freigabe gegen deinen ausdruecklichen Wunsch nach
nativen GitHub-Tool-Installern. Die historischen Kubernetes-Befunde darin muessen gegen heutige
Manifeste geprueft werden.

## Offline-Pruefergebnis

41 Tests fuer den nativen Buildhelfer, Menue/Status und die neue Restliste bestanden. Zusaetzlich
bestanden die Inventar-/Dokumentationspruefungen und die Bash-Syntaxpruefung der neuen
Install-Einstiege. Der Registry-Check meldete 387 Tools, 245 Profile, keine strukturellen Fehler und
813 bestehende Hinweise. Keine Installer, Compiler, Dienste, Images oder Modelle gestartet; die
Tests des Buildhelfers verwenden lokale Fixtures und Mocks. Kein erfolgreicher
Ubuntu-/WSL-Quellbuild oder Ende-zu-Ende-Betrieb wird damit behauptet.
