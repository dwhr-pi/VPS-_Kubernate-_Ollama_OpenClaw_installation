# Grok: Repository-Review und priorisierte Integration

Stand **23.10.2026**. Nutzerquelle: Grok-Text aus der Anlage `2e6499ec-3764-452f-81af-3114e4f3d943`,
Titelbeginn "Du bist ein erfahrener DevOps-/LLMOps-Architekt und Repo-Maintainer". Es liegt kein
oeffentlicher Grok-Chat-/Originalbericht-Link vor. Einordnung ausschliesslich offline anhand des
vorhandenen Checkouts; keine erneute externe Quellen-, Versions- oder Lizenzpruefung.

## A. Executive Summary

1. Staerke: getrennte Tool-/Profilpfade, private Workspaces und sichtbare Planned-Zustaende.
2. Das Architektur-Zielbild ist sinnvoll; seine Beschreibung belegt noch keinen sicheren Betrieb.
3. Risiko 1: Update-Backup erhaelt unversionierte Inhalte nicht (Audit A01).
4. Risiko 2: PAT in Clone-URL/Remote und Prozessargumenten (A02).
5. Risiko 3: Compose-Uninstall kann persistente Daten ohne ausreichenden Schutz loeschen (A03).
6. Risiko 4: Backup-Fehler und Monitoring-/Proxy-Netzgrenzen sind unzureichend abgesichert
   (A04-A07).
7. Risiko 5: Lifecycle-/Registry-Drift und kein gruener Gesamttest (A15-A17).
8. Naechste zwei Wochen, als Reihenfolge statt Zusage: zuerst P0-Verwaltung und Tests, danach
   private Netzgrenzen, Backup-Restore und ein vollstaendiger Core-Lifecycle.
9. Keine neuen schweren Default-Installationen; bestehende Komponenten zuerst konsolidieren.

## B. Priorisierte Issues und Abgleich

| Prio | Konkreter Pfad                                                                                                        | Umsetzung / Beleg                                                                                             |
| ---- | --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| P0   | [install.sh](../../install.sh)                                                                                        | Vollstaendige verifizierbare Update-Sicherung statt bloss untracked-Dateiliste; PAT nicht in URL persistieren |
| P0   | [Compose-Helper](../../scripts/tools/helpers/docker_compose_tool_common.sh)                                           | Pfad-/Besitznachweis und datenerhaltende Deinstallation, keine pauschale Volumenloeschung                     |
| P1   | [Backup](../../scripts/operations/backup_run.sh), [Monitoring](../../scripts/install_monitoring.sh)                   | Fehler muessen fehlschlagen; Restore, Offsite und echte Scrapes/Alarme implementieren                         |
| P1   | [Kubernetes-Manifeste](../legacy/K8S_DEPLOYMENTS_LEGACY.md#historischer-quelltext)                                    | Private Services, explizite GPU-/Speicheranforderungen, Namespace-Policies und Auth                           |
| P1   | [Queue-Worker](../../scripts/queue/queue_worker.sh), [User-Unit](../../scripts/systemd/openclaw-queue-worker.service) | Prozessbaum/cgroup-Grenzen, Abbruch und Neustart-Recovery mit Fixtures nachweisen                             |
| P2   | [Registry](../../config/tools.yml), [Menue](../../setup_ultimate.sh)                                                  | Eine Quelle der Wahrheit, Lifecycle-Mappings und source/runtime-getrennte Nachweise                           |
| P2   | [CI](../../.github/workflows/ci.yml), [Offline Regression](../../.github/workflows/offline-regression.yml)            | Vorhandene Gates wirksam machen, fehlende Plattform-/Manifesttests ergaenzen                                  |

Einzelbefunde, Zeilen, Aufwand und konkrete Testausgaben stehen im
[Audit A01-A17](../AUDIT_2026-10-23.md). Groks Zahlen "~340 Tools" und alte Bewertungen werden nicht
als aktuelles Inventar uebernommen: der lokale Auditlauf erfasste 366 Tools und 245 Profile, keine
Live-Installationen.

Wichtige Korrekturen: Gitleaks-CI existiert bereits, Prometheus/Grafana/Netdata sind vorhanden, und
der Automaton-Wrapper sperrt Agentenstart/Provisionierung. Fehlender Registry-Pin bedeutet nicht
zwingend fehlender Pin in einem Helper. Viele Kandidaten sind schon Planned-Stubs; sie sollen nicht
doppelt registriert werden.

## C. Konkretes Patch-Paket und Grenzen

Dieses Paket liefert einen schreibgeschuetzten
[Top-20-Inventarisierer](../../scripts/quality/lifecycle_inventory.py), den
[aktuellen Nachweisstand](../CURRENT_STATUS.md), den ergaenzten
[Lifecycle-Vertrag](../TOOL_LIFECYCLE_STANDARD.md), den
[60-Minuten-Leitfaden](../FIRST_60_MINUTES.md) und Regressionstests. Alle Inventar-Modi sind offline
und read-only, einschliesslich `--dry-run`.

**Nicht behauptet:** 20 fehlende Doctors/Updater implementiert, alle Quellen gepinnt, physisch
verkuerzte README, Profile migriert, Hosts gehaertet oder Cloud-Budgets aktiviert. Diese operativen
Arbeiten bleiben in der [PR-Roadmap](../ROADMAP_NEXT.md). Es werden keine leeren Doctor-Skripte
angelegt, die allein durch ihren Dateinamen Betriebsreife vortaeuschen.

Die README erhaelt einen kurzen neuen Einstieg, bleibt aber kompatibel bestehen. Eine spaetere
Kuerzung muss bisherige Links/Anker und Tests explizit migrieren, nicht bestehende Eintraege
kommentarlos entfernen. Alte Statusmatrizen bleiben historische Einordnungen;
[Current Status](../CURRENT_STATUS.md) ist der Einstieg zum aktuellen Nachweisstand.

## D. Aktualisierte Kandidatenliste

`already present` = konkreter Repository-Pfad, **nicht lokal installiert oder produktionsreif**.
`planned` = Registry-/Dokumentationskandidat, ggf. Stub. `recommend add` = Integrationsvorschlag
ohne Download-/Versionspruefung; `reject` betrifft den genannten Einsatz, nicht pauschal das
Projekt.

| Kandidat / Registry-ID                          | Einordnung                | Repository-Beleg und Konsequenz                                                                                                                                                      |
| ----------------------------------------------- | ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Temporal, Argo Workflows                        | planned                   | IDs `temporal`, `argo_workflows` verweisen auf Planned-Stub; nicht beide als Standard zusaetzlich zur Queue ausrollen                                                                |
| Queue-Haertung                                  | recommend add             | [Worker](../../scripts/queue/queue_worker.sh) hat Timeout/Locks/Ressourcenwache, aber kein nachgewiesenes cgroup-/Neustart-Konzept; begrenzten lokalen Pfad zuerst vervollstaendigen |
| Cosign / Policy-Controller                      | planned / recommend add   | `cosign` ist Stub; Verifikations- und Admission-Integration getrennt aufbauen, keine imaginierte Signatur                                                                            |
| SOPS / age                                      | planned                   | IDs `sops`, `age` sind Stubs; vorhandener [ENV-Tresor](../ENV_VAULT.md) ist ein anderer Integrationspfad, kein Kubernetes-SOPS-Nachweis                                              |
| Vaultwarden                                     | planned                   | Registry-ID vorhanden; Passworttresor nicht als automatischen Workload-Secret-Broker gleichsetzen                                                                                    |
| Trivy, Grype, Syft, Gitleaks, Semgrep           | already present           | Installerpfade in Registry; [DevSecOps-Profil](../../scripts/profiles/Security_DevSecOps_install.sh) vorhanden, CI-/Doctor-Vertrag noch offen                                        |
| Suricata, Wazuh                                 | planned                   | Registry-IDs vorhanden; nur optional und nach Speicher-/Netzwerk-/Datenschutzpruefung                                                                                                |
| Headscale                                       | planned                   | Registry-ID vorhanden; kein nachgewiesener fertiger Runtimepfad aus einem Stub                                                                                                       |
| Caddy / Traefik                                 | planned                   | Separate Registry-IDs sind Stubs; [K3s-Installer](../../scripts/tools/k3s_install.sh) ist ein eigener Pfad, kein Nachweis fuer gepruefte Ingress-/TLS-Policies                       |
| ddclient / HE-DDNS                              | planned                   | IDs `ddclient`, `ddclient_he`; doppelte Rollen vor Runtime-Integration klaeren                                                                                                       |
| Prometheus, Grafana, Loki                       | already present           | Installer und [LLMOps-Stack](../../stacks/llmops-platform/docker-compose.yml); keine fertige Alarm-/GPU-Metrik-Abnahme                                                               |
| OpenTelemetry Collector                         | planned                   | Registry `opentelemetry` zeigt Stub trotz vorhandenem `opentelemetry_install.sh`; Drift statt nochmals neuer Tool-ID                                                                 |
| Uptime Kuma                                     | already present           | [Monitoring-Einstieg](../../scripts/install_monitoring.sh); leichtgewichtiges Zielbild, Installation weiter bewusst auswaehlen                                                       |
| Langfuse                                        | already present           | Registry `langfuse` und LLMOps-Stack; echte Traces koennen Prompts/Secrets enthalten, Erfassung nicht automatisch aktivieren                                                         |
| Phoenix                                         | recommend add             | Keine passende Tool-ID im geprueften Registry-Abgleich; nur optionaler Evaluationskandidat, kein zweiter Default-Trace-Stack                                                         |
| LlamaIndex, Haystack, Qdrant, Chroma            | already present           | IDs `llamaindex`, `haystack`, `qdrant`, `chromadb`; zuerst eine getestete Ingest/Embed/Retrieve-Pipeline statt vier paralleler Standardinstallationen                                |
| Aider, OpenHands, Continue                      | already present           | [Agentic-Coding-Doku](../tools/agentic-coding.md); CLI-, Agent/Web- und IDE-Rollen getrennt behandeln                                                                                |
| Promptfoo                                       | already present           | Registry `promptfoo`, [Installationshinweise](../PROMPTFOO_INSTALLATION_NOTES.md); keine Modell-/Cloud-Evals ohne explizite Freigabe                                                 |
| InvokeAI                                        | planned                   | Registry `invokeai`; kein zusaetzlicher schwerer Medien-Default                                                                                                                      |
| ComfyUI                                         | already present           | [Installer](../../scripts/tools/comfyui_install.sh); Erweiterungen sind kein Ersatz fuer einen funktionierenden Core                                                                 |
| Whisper_CPP, faster-whisper, Piper              | already present           | Registry `whisper_cpp`, `faster_whisper`, `piper`; Stimmen-/Modell-Downloads und echte Audiobearbeitung bleiben getrennte Aktionen                                                   |
| Kopia                                           | planned                   | Registry `kopia`; nicht neben Restic als zweites Backup-Default einfuehren                                                                                                           |
| Restic                                          | already present           | [Installer](../../scripts/tools/restic_install.sh); Backup-/Recovery-Konfiguration fehlt im geprueften Standardlauf                                                                  |
| Syncthing, Rclone                               | already present           | Registry-Installer vorhanden; Synchronisierung ersetzt kein versioniertes Backup                                                                                                     |
| Stalwart                                        | already present / planned | `stalwart_mail` hat Installer, `stalwart` ist Planned-/Manual-Alias; Rollen pruefen, keine zweite Mail-Instanz automatisch starten                                                   |
| Rspamd, SnappyMail, Roundcube                   | planned                   | Registry-IDs vorhanden; keine neue SMTP-/Mailbox-Oeffnung in diesem Paket                                                                                                            |
| Alle Kandidaten als ein schweres Standardprofil | reject                    | Widerspricht Low-Resource-, Datenschutz- und Opt-in-Zielen; erst Lifecycle und P0-Grenzen stabilisieren                                                                              |

## E. First 60 minutes und konkrete Defaults

Der [vollstaendige Leitfaden](../FIRST_60_MINUTES.md) beginnt mit Herkunft, Read-only-Audit und
Fixtures, nicht mit Netzwerkfreigaben oder Masseninstallation. Empfohlenes spaeteres Ziel: ein
Coding-Agent, Ollama, OpenClaw, optionale einzelne RAG-Pipeline und leichtes Monitoring; WireGuard
fuer gewaehlten Remotezugriff. K3s/GPU/Medien bleiben Advanced/opt-in. Low Resource und Security
First haben getrennte Anforderungen, keine automatisch aktivierte Sammlung von Diensten.

Weiterfuehrend: [bisheriges Grok-Interview](grok-development-tooling.md) und
[Priority Install Paths](../PRIORITY_INSTALL_PATHS.md). Keine Cloud-Kosten, Wallet-Starts,
Modell-Downloads oder neuen Hintergrundaufgaben ausgefuehrt.
