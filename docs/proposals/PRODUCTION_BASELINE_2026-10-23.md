# Produktionsnahe Baseline: Review und minimale PRs

Stand 23.10.2026, Basis `0305ca6fcb8c349b2ea04b83a62051acdbc83e30`. **Vorschlag, nicht angewendet.**
Bestehende Secrets, produktive Konfigurationen, Installer und Workspaces bleiben unveraendert. Keine
Installation oder Deployment.

## Bewertung und Prioritaeten

Das Architekturziel ist brauchbar, der aktuelle Checkout ist aber kein nachgewiesen
produktionsreifer Gesamtstack. Zuerst die Verwaltungs- und Datenverlustrisiken beseitigen, danach
reproduzierbare Workloads aufbauen. Weitere Tools allein beheben die bestehenden
Lifecycle-/Netzprobleme nicht.

| Prioritaet   | Problem                                                                                                            | Beleg                                                                                                                                                                                |
| ------------ | ------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Kritisch     | Unversionierte Update-Dateien werden nicht inhaltlich gesichert, anschliessend geloescht                           | [install.sh:23](../../install.sh#L23), [Hard-Sync:40](../../install.sh#L40)                                                                                                          |
| Kritisch     | PAT in Clone-URL kann in Args/Remote-Konfiguration landen                                                          | [install.sh:350](../../install.sh#L350), [Clone:426](../../install.sh#L426)                                                                                                          |
| Kritisch     | Compose-Uninstall entfernt Volumes und frei ueberschreibbares Verzeichnis ohne ausreichenden Besitz-/Datenschutz   | [Helper:91](../../scripts/tools/helpers/docker_compose_tool_common.sh#L91)                                                                                                           |
| Wichtig      | OpenClaw-Installer ist kein abgesicherter Dienst; Token, Dienstidentitaet und End-to-End-Inferenz nicht abgenommen | [openclaw_install.sh:23](../../scripts/tools/openclaw_install.sh#L23), [Abschluss:60](../../scripts/tools/openclaw_install.sh#L60)                                                   |
| Wichtig      | Ollama-Pod ohne GPU-Zuweisung, Probes, ephemeral-storage und explizite Pod-Security                                | [k8s_deployments.yaml:21](../legacy/K8S_DEPLOYMENTS_LEGACY.md#historischer-quelltext)                                                                                                |
| Wichtig      | Beispiel-Proxy per LoadBalancer, NetworkPolicies nicht im Namespace der AI-Services                                | [Proxy:221](../legacy/K8S_DEPLOYMENTS_LEGACY.md#historischer-quelltext), [Policy:5](../../examples/k3s/network-policies.yaml#L5)                                                     |
| Wichtig      | Monitoring-Einzelinstaller publizieren Wildcard-Ports; Prometheus scrape nur sich selbst                           | [Prometheus:10](../../scripts/tools/prometheus_install.sh#L10), [Scrape:30](../../scripts/tools/prometheus_install.sh#L30), [Grafana:10](../../scripts/tools/grafana_install.sh#L10) |
| Wichtig      | Kopierfehler im Backup werden ignoriert; kein belegter konsistenter Offsite-Restore                                | [backup_run.sh:16](../../scripts/operations/backup_run.sh#L16)                                                                                                                       |
| Wichtig      | Bewegliche Source-/Image-Versionen und Registry-/Menue-Drift                                                       | [OpenClaw:34](../../scripts/tools/openclaw_install.sh#L34), [Compose:3](../../stacks/llmops-platform/docker-compose.yml#L3)                                                          |
| Nice-to-have | GitOps, HPA, CNI-Wechsel, zweiter Trace-Stack                                                                      | Erst nach Basis-Abnahme und gemessenem Bedarf; kein schwerer Default-Rollout                                                                                                         |

Weitere Befunde und Testausgaben: [Audit A01-A17](../AUDIT_2026-10-23.md),
[Deep Review mit Scorecard und Tool-Matrix](../SETUP_REVIEW_2026_CODEX.md).

## Bestandsaufnahme

| Komponente                             | Vorhandener Weg / Version                                                                             | Netz / Zustand / manuelle Luecke                                                                                                                       |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Ollama                                 | Host: offizieller beweglicher Installer; K8s: `ollama/ollama:latest`                                  | 11434; Vorlage Loopback, Pod-interne Bindung getrennt betrachten. Modelle im Manifest auf 30-GiB-RWO-PVC; kein Modell-/GPU-Gesundheitsnachweis         |
| OpenClaw                               | Hostquellen `/opt/openclaw`, Clone/Pull und pnpm-Build, kein festgelegter Release in diesem Installer | Vorlage 18789/Loopback und Gateway-Token; kein dediziertes Dienstkonto/Service im Installer erzeugt. Tatsaechlicher Prozessbenutzer/Listener unbekannt |
| K3s                                    | Hostinstaller `get.k3s.io` ohne verpflichtenden Versionspin                                           | Cluster-API, CNI, Datastore und Join-Verfahren nicht durch einen grueneren Scriptmarker abgesichert; Oracle/ARM und GPU/x86 getrennt planen            |
| LiteLLM / Open WebUI                   | Container im LLMOps-Stack, `main-latest` / `main`                                                     | Host 4000 / konfigurierter UI-Port, bereits Loopback. Provider-Fallbacks vorhanden; Budgets/Cloud-Opt-in nicht durchgaengig nachgewiesen               |
| Qdrant / Postgres / Redis / MinIO      | Container, `latest` / `16` / `7` / `latest`                                                           | Host 6333, 5432, 6379, 9000/9001 nach Compose/ENV; Loopback. Bind-Volumes fuer Qdrant/Postgres/MinIO; Redis hat in diesem Stack kein Datenvolume       |
| Langfuse / Prometheus / Grafana / Loki | Container mit beweglichen Tags                                                                        | Hostports nach ENV, Loopback im Stack. Grafana hat Datenpfad; fuer Prometheus/Loki fehlen dort explizite Datenvolumes/Retentionsvertraege              |
| Netdata / Uptime Kuma                  | Container im Stack; Monitoring-Einstieg installiert nur Uptime Kuma                                   | Netdata mit SYS_PTRACE und AppArmor-Ausnahme bewusst begrenzen; kein Nachweis aller CPU-/GPU-/Gateway-Alarme                                           |
| WireGuard / WOL                        | Host-Hilfsskripte mit Dry-run/Apply                                                                   | Vorlagen sind keine aktive VPN-Verbindung. Wake-Helper sendet Paket, Ping/Portcheck ist keine Node-/Modell-Readiness                                   |
| Weitere Tools/Profile                  | Registry 366 Tools / 245 Profile, darunter Stubs, Source-Builds, manuelle und Containerpfade          | Nicht gleichzeitig installiert; keine konkrete Version oder Nutzbarkeit allein aus Registry-/Scriptnamen ableiten                                      |

Volume-Pfade des LLMOps-Stacks sind relativ zu dessen Arbeitsverzeichnis, u.a.
`./data/{open-webui,qdrant,postgres,minio,grafana,uptime-kuma}`. Sie sind nicht automatisch vom
Repo-/Workspace-rsync konsistent gesichert. Ein Modellcache ist anders zu behandeln als
Geschaeftsdaten/Agentenzustand.

ENV-Bedarf ist bereits aufgeteilt: Root-`.env.example`, `config/*.env.example` und
`stacks/llmops-platform/.env.example`. Relevante Namen sind `OPENCLAW_GATEWAY_TOKEN`,
`OPENCLAW_GATEWAY_URL`, `OLLAMA_BASE_URL`, `LITELLM_MASTER_KEY`, `OPENWEBUI_SECRET_KEY`,
`POSTGRES_PASSWORD`, `REDIS_PASSWORD`, `MINIO_ROOT_PASSWORD`, `LANGFUSE_NEXTAUTH_SECRET`,
`OPENAI_API_KEY`, `GEMINI_API_KEY`, `TAILSCALE_AUTHKEY` und `CLOUDFLARE_TUNNEL_TOKEN`. Fuer den
Audit wurden nur Namen, keine Werte ausgegeben. Eine ENV-Datei ist kein Secret-Manager;
Zugriffsschutz, Rotation, Log-Redaktion, Recovery und Kubernetes-Encryption-at-rest bleiben eigene
Pflichten.

## Vier Phasen und klare PR-Grenzen

| Phase                         | Kleines, konkret abgrenzbares Paket                                                                                                                                                  | Abnahme                                                                                               |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------- |
| 1 Sicherheit / Hosts          | Hard-Sync fail-closed, PAT aus URL, datenerhaltender Uninstall, Backup-Fehler; Hostkey-geprueftes SSH, Key-only, Root-Login aus, Management nur VPN, Firewall und Sicherheitsupdates | Negativ-Fixtures; Aussperrschutz mit zweiter Sitzung; kein Live-Apply ohne Freigabe                   |
| 2 Reproduzierbarkeit / K8s    | Verifizierte Source-/Image-Pins, Ansible-Rollen, OpenTofu fuer Oracle, getrennte Workloads, PVC/Quota/Policies/Probes                                                                | Helm/Kustomize-Render, Schema/Lint, Wegwerfcluster, zweimaliger Lauf ohne Aenderung, ARM-/GPU-Overlay |
| 3 Observability / Backup / CI | Host/Pod/GPU-/Inferenzmetriken, echte Alarme, verschluesselte Offsite-Backups, Restore in frisches Ziel, wirksame Lint-/Image-/Secret-Gates                                          | Alarm-Fixtures, Crash-/Disk-Failure, Datenbankintegritaet und Restore; redigierte Reports             |
| 4 GitOps / Optimierung        | Genau ein Argo-/Flux-Controller, ggf. HPA, Cache und Loadtest, Storage-/CNI-Migration nur bedarfsbelegt                                                                              | Drift-/Rollback-Test, Budget-/Last-/Ausfalltest; keine automatische Cloud-Flucht                      |

Ansible ist Hostzustand, OpenTofu ist Cloud-State, Helm/Kustomize sind Workloads; das Bash-Menue
bleibt ein duennes, bestaetigtes Frontend. Vorhandene Ressourcen nicht unkontrolliert neu erstellen.
Terraform/OpenTofu nicht parallel auf denselben State ansetzen. PDB mit einer Replik ist kein HA und
kann Drain blockieren.

## Fehlende Werkzeuge nicht mit fehlender Integration verwechseln

Ansible, OpenTofu, kubectl, Helm, Kustomize, K9s, Tailscale/WireGuard-Pfade,
Prometheus/Grafana/Loki, Scanner und Backup-CLIs sind bereits teilweise vorhanden. Die einzelne
CLI-Installation belegt weder sichere Version noch die Betriebsverkabelung. Konkrete Prioritaet:
GPU-Device-Plugin, korrekt selektierende Policies, Manifestvalidierung, Alertmanager-Regeln,
Secret-/Restore-Verfahren und Lifecycle-Adapter statt einer weiteren Sammlung von Defaults.

Vorhandene Trivy-/Gitleaks-/pre-commit-/CI-Pfade konsolidieren. Ergaenzungsvorschlag: yamllint,
kubeconform statt altem kubeval, kube-linter, redigierter Image-Scan gegen feste Digests und
ShellCheck/shfmt als wirksame Gates. Renovate/Dependabot nur nach Quellen-/Lock-Policy mit
kontrollierten Update-PRs; nicht automatisch beliebige Source-Pins oder Produktivimages hochziehen.

## Lieferbare Konfigurations- und README-Entwuerfe

- [Konfigurationen und Runbook](PRODUCTION_CONFIGURATION_DRAFTS.md): ENV-Vertrag, Workloads,
  Policies, systemd-Alternative, Firewall, Monitoring, Backup.
- [README-Entwurf](README_PRODUCTION_DRAFT.md): Architektur, Setup, Betrieb und Fehlerdiagnose.
- [PR-Roadmap](../ROADMAP_NEXT.md): Reihenfolge und Rollback-Vertraege.

Die echten `.env.example`, `readme.md`, Compose-/K8s-/CI-Dateien wurden hier nicht ersetzt. Fehlende
echte Digests, Secret-Store-Entscheidung und Storage-/GPU- Zielwerte sind bewusste
Deployment-Sperren, keine erfundenen Produktionswerte.

## Breaking Changes und offene Nachweise

- P0-Uninstall-Aenderung bewahrt Daten standardmaessig; bestehende Erwartung 'Tool weg = Daten weg'
  aendert sich absichtlich.
- Loopback-/ClusterIP-/Default-Deny-Umstellung kann bestehende Clients, DNS, Webhooks und
  Cloudanbieter unterbrechen. Routen/Ports vorher inventarisieren.
- Non-root/PVC-Umstellung kann Eigentums-/Modellpfad-Migration erfordern. Keine pauschalen
  rekursiven chown-Befehle gegen vorhandene Daten.
- Neuer OpenClaw-Pin braucht eigenes Schema-/CLI-/Probe-/Upgrade-Review. Tokenpflicht und
  Sandbox-/Egress-Beschraenkung koennen bisherige Skills blockieren.
- Ressourcenwerte sind Beispielbudgets, keine universellen VRAM-/RAM-Garantien.
- Vollstaendige Einlesung aller relevanten getrackten Dateien wurde versucht, endete aber im
  Zeitlimit. Die vorhandenen Kernpfad-Reviews und Inventare sind keine ehrliche Behauptung einer
  vollstaendigen manuellen Pruefung aller Shells.
- ShellCheck-/Scanner-Verfuegbarkeit, vollstaendige Tests und Live-Abnahme bleiben gemaess
  [Audit-Pruefprotokoll](../AUDIT_2026-10-23.md) offen. Keine neue gruene CI behauptet.
