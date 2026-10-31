# Codex Deep Review und Refactor-Plan 2026

Stand: **23.10.2026**. Basis-Commit: `0305ca6fcb8c349b2ea04b83a62051acdbc83e30`, plus separat
sichtbare lokale Dokumentations-/Grok-Entwuerfe. **Nur Audit und PR-Vorschlaege.** Seit dem Auftrag
"keinen neuen Code ohne OK" wurde nur dieses Review-Dokument angelegt; keine Installer, CI, Registry
oder Deployment-Manifeste dafuer geaendert. Die vorher begonnenen Dateien
`scripts/quality/lifecycle_inventory.py` und `tests/test_lifecycle_inventory.py` sind separate, noch
nicht abgenommene Entwuerfe.

## 1. Befunde zuerst

| Prio | Befund                                            | Beleg / Folge                                                                                                                                                                                                                                                                                                             |
| ---- | ------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| P0   | Hard-Sync sichert unversionierte Inhalte nicht    | [install.sh:23](../install.sh#L23) speichert nur Dateinamen; [Zeile 40](../install.sh#L40) fuehrt anschliessend reset/clean aus. Zustimmung ist vorhanden, eine vollstaendige Restore-Sicherung nicht.                                                                                                                    |
| P0   | PAT in Clone-URL                                  | [install.sh:350](../install.sh#L350), [Clone:426](../install.sh#L426): Prozessargumente und gespeicherte Git-Remote koennen Credentials enthalten. Keine echten Werte fuer das Audit gelesen oder ausgegeben.                                                                                                             |
| P0   | Gemeinsamer Uninstall kann Daten loeschen         | [Compose-Helper:91](../scripts/tools/helpers/docker_compose_tool_common.sh#L91): `down -v` und anschliessendes rekursives sudo-Loeschen mit ueberschreibbarem Zielpfad, ohne ausreichende Daten-/Besitzgrenze.                                                                                                            |
| P1   | Backup-Erfolg trotz Kopierfehler                  | [backup_run.sh:16](../scripts/operations/backup_run.sh#L16): rsync-Fehler werden ignoriert, Erfolg wird dennoch ausgegeben. Keine belegte Offsite-/Restore-Abnahme.                                                                                                                                                       |
| P1   | Netzgrenzen sind nicht einheitlich                | [Prometheus:10](../scripts/tools/prometheus_install.sh#L10), [Grafana:10](../scripts/tools/grafana_install.sh#L10): Wildcard-Publishing. [Proxy-Service:221](legacy/K8S_DEPLOYMENTS_LEGACY.md#historischer-quelltext): LoadBalancer ohne Anwendungsauthentifizierung im Beispiel. WAN-Erreichbarkeit nicht live getestet. |
| P1   | Ungeeignete GPU-/Pod-Defaults                     | [Ollama-Pod:21](legacy/K8S_DEPLOYMENTS_LEGACY.md#historischer-quelltext): keine GPU-Anforderung/Affinity, 4 GiB RAM-Limit, keine expliziten Non-root-/Seccomp-Vorgaben. NetworkPolicies liegen im falschen Namespace fuer `ai-services`.                                                                                  |
| P1   | Bewegliche Quellen und unvollstaendige Idempotenz | [OpenClaw:31](../scripts/tools/openclaw_install.sh#L31) zieht einen beweglichen Git-Stand und baut erneut; [n8n:86](../scripts/tools/n8n_install.sh#L86) aehnlich. Existierender Ordner ist kein Versions-/Artefaktnachweis.                                                                                              |
| P1   | IaC-Installer ist nicht IaC-Betrieb               | [OpenTofu:5](../scripts/tools/opentofu_install.sh#L5) gibt `make tools install` mit unterdruecktem Fehler an einen generischen Helper weiter. Daraus folgt weder funktionierendes OpenTofu noch deklarativ verwaltete Oracle-Infrastruktur.                                                                               |
| P2   | Registry und reale Pfade weichen ab               | K3s/OpenTelemetry sind in `config/tools.yml` Planned-Stubs, obwohl konkrete Skripte existieren. ArgoCD/Flux CLI ist kein installierter GitOps-Controller.                                                                                                                                                                 |
| P2   | CI vorhanden, aber kein gruener Gesamtbeleg       | [CI:64](../.github/workflows/ci.yml#L64) unterdrueckt Scan-Fehler; Gitleaks hat separate Jobs. Letzter lokaler Gesamttest unvollstaendig und mit reproduzierbarem Aegisub-Fehler.                                                                                                                                         |

Vollstaendige Einzelbelege A01-A17 und Testausgaben: [Audit vom 23.10.2026](AUDIT_2026-10-23.md).
Kein pauschales Urteil ueber alle 390 Installer aus einzelnen Beispielen ableiten.

### Inventar und Grenzen der Musterpruefung

- `setup_ultimate.sh`: **4803 Zeilen** am untersuchten Stand, nicht nur vermutete 2000.
- `scripts/tools/`: **390** direkte `*_install.sh`-Dateien, ohne rekursive Helper. 314 enthalten
  lokale `source`-Anweisungen; nur zwei eine lokale `trap`-Anweisung. Diese Textzaehlung beweist
  **nicht**, dass alle anderen ohne Fehlerbehandlung laufen: `common.sh` setzt Strict Mode, weitere
  Helper koennen Traps/Funktionen bereitstellen.
- Beispiel mit fehlendem lokalem Strict Mode:
  [ollama_install.sh](../scripts/tools/ollama_install.sh). Sein Tracking-Helper und dessen
  Apt-Helper setzen am Dateianfang ebenfalls keinen Strict Mode. Vor der Migration den
  vollstaendigen Source-/Funktionspfad pruefen.
- Neun textuelle curl/Pipe-Treffer wurden gefunden. Darunter ist die Flux-Hilfe "Kein
  curl|bash-One-Liner" ein **False Positive**. Bestaetigte ausfuehrbare Beispiele:
  [K3s:7](../scripts/tools/k3s_install.sh#L7), [Ollama:26](../scripts/tools/ollama_install.sh#L26),
  [Tailscale:24](../scripts/tools/tailscale_install.sh#L24). Keine Behauptung einer vollstaendigen
  semantischen Pruefung aller Downloads.
- Fuer Git-Clones Commit-Pin, erwarteten Origin, sauberen Checkout und ggf. Signatur/Attestation
  verifizieren. Ein Git-Commit ist nicht durch eine beliebige zusaetzliche Archiv-Checksumme zu
  ersetzen; ein Hash vom selben Server ist kein unabhaengiger Herkunftsnachweis.
- Config-Review: 366 Tool-, 245 Profil-, 44 Port-Eintraege aus dem vorhandenen Audit. Einzelne
  Profile/Installer wurden nicht auf echten Zielhosts ausgefuehrt.

## 2. Scorecard

Subjektive Engineering-Einordnung der **nachgewiesenen Repository-Reife**, keine Messskala,
Zertifizierung oder Bewertung deiner tatsaechlichen Hosts. 1 = kaum abgesichert/nachgewiesen, 10 =
reproduzierbar produktionsreif mit Abnahme.

| Bereich         | Punkte / 10 | Begruendung                                                                                    |
| --------------- | ----------- | ---------------------------------------------------------------------------------------------- |
| Security        | 3           | Gute dokumentierte Regeln, aber P0-Daten-/Tokenrisiken und uneinheitliche Netz-/Agentengrenzen |
| Maintainability | 3           | 4803-Zeilen-Menue, mehrere Status-/Registry-Pfade, grosse Lifecycle-Luecken                    |
| K8s-Readiness   | 3           | Basis-Manifeste vorhanden, GPU/Policy/Storage/Restore nicht durchgaengig integriert            |
| LLMOps          | 4           | Breiter Stack vorhanden, aber Budgets, Readiness, Routing und GPU-Lasttest nicht abgenommen    |
| Docs            | 6           | Viele nuetzliche Leitfaeden, jedoch Redundanzen und widerspruechliche Statusaussagen           |

## 3. Top 10 Quick Wins

Jeweils geschaetzter **Patch-Aufwand unter einer Stunde**, keine Zusage fuer die gesamte
Plattform-/Restore-Abnahme. Erst nach OK umsetzen; kein Live-Apply.

| Nr. | Aufwand   | Kleiner PR-Inhalt                                                             | Minimaler Nachweis                                                           |
| --- | --------- | ----------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| 1   | 15-30 min | Hard-Sync bis zur belastbaren Sicherung fail-closed sperren                   | Fixture: untracked Datei bleibt unveraendert, keine reset/clean-Ausfuehrung  |
| 2   | 20-45 min | Token-in-URL-Clone blockieren; sicheren Auth-Pfad als Folge-PR ausweisen      | Dummy-PAT erscheint nicht in Args/Remote/Log; keine echte Anmeldung          |
| 3   | 20-45 min | Backup-rsync-Fehler propagieren statt Erfolg melden                           | Simulierter Exit 23/ENOSPC -> fehlgeschlagen, kein Erfolgsstatus             |
| 4   | 10-30 min | Prometheus/Grafana-Publishing auf Loopback begrenzen                          | Gerenderte Compose-Konfiguration ohne Host-Wildcards                         |
| 5   | 10-30 min | Beispiel-Proxy standardmaessig ClusterIP statt LoadBalancer                   | Statischer Manifesttest, keine oeffentliche Service-Exposition               |
| 6   | 10-20 min | Proxy-Fallback `stream: false` bzw. expliziter NDJSON-Parser                  | Gemockte Ollama-Antwort wird vollstaendig verarbeitet                        |
| 7   | 15-40 min | CI-Tokenrechte explizit read-only, Checkout ohne gespeicherte Credentials     | Workflow-Fixture prueft Rechte und Checkout-Konfiguration                    |
| 8   | 20-45 min | Trivy-Funde mit definiertem Exitcode in einem klar begrenzten Gate blockieren | Dummy-Fund muss Job fehlschlagen lassen, keine globale Fehlerunterdrueckung  |
| 9   | 15-45 min | Zwei zentrale Action-Referenzen nach verifiziertem Commit pinnen              | Erwartete Action/Commit-Zuordnung im Review, keine geratenen SHAs            |
| 10  | 15-30 min | Source-ready/Runtime-ready in Statusanzeige und Doku explizit trennen         | Vorhandener Quellmarker ohne Runtime wird nicht als betriebsbereit angezeigt |

Die vollstaendige datenerhaltende Deinstallation, ein sicherer Release-Bootstrap und alle
Tool-Lifecycle-Adapter sind **keine** ehrlichen Unter-einer-Stunde-Zusagen.

## 4. Fuenf Architektur-Refactors und Migrationspfad

| Refactor                            | Vorgeschlagene Pfade, noch nicht angelegt                                        | Schrittweise Migration                                                                                                                                                                                  |
| ----------------------------------- | -------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Bash als UI statt Monolith          | `scripts/lib/{registry,plan,dispatch,status,preflight}.sh`                       | Erst Verhalten mit Fixtures erfassen; reine Parser/Planner extrahieren; `source` ueber aufgeloesten Repo-Root und Existenzpruefung, keine Secrets-/Netz-/Install-Seiteneffekte beim Source              |
| Hostkonfiguration mit Ansible       | `infra/ansible/roles/{host_base,ssh,wireguard,k3s_server,k3s_agent,gpu_runtime}` | Auf Wegwerf-VM beginnen, zweiter Lauf ohne Aenderung; Check-Mode separat testen, er ist kein universeller Nebenwirkungsfreiheitsnachweis; Bash-Menue ruft nur gewaehlte Rolle auf                       |
| Cloud-Ressourcen mit OpenTofu       | `infra/opentofu/oracle/{network,compute,outputs}`                                | Erst VCN/Firewall/Instanzzustand modellieren; bestehende Ressourcen kontrolliert importieren, keine automatische Neuerstellung; verschluesseltes gelocktes State-Backend, kein State mit Secrets in Git |
| Workloads deklarativ mit Helm       | `deploy/charts/ai-core/`, Values fuer `vps`, `homelab`, `gpu`                    | Bestehende Manifeste rendergleich ueberfuehren, dann Probes/GPU/Policies/Storage; CRDs und Plattform-Operatoren getrennt versionieren; helm template + kubeconform/kube-linter vor Apply                |
| Orchestrierung und Nachweis trennen | `scripts/orchestration/` und ein Schema fuer Job-/Lifecycle-Nachweise            | WOL, Readiness, Modell-Admission und Laufzeitbudgets als begrenzte Zustaende; Genehmigung fuer schreibende Aktionen; Retry mit Backoff/Maximalzahl, keine automatische Cloud-Flucht                     |

Warum nicht sofort alles ersetzen? Bash ist fuer Menue, Diagnose und kleine lokale Wrapper
brauchbar. Ansible verwaltet Hostzustand, OpenTofu Cloud-Ressourcen, Helm Kubernetes-Workloads.
Keine dieser Ebenen ersetzt die anderen. Installer fuer Ansible/Helm/OpenTofu sind bereits
vorhanden; Rollen, State und Charts sind damit noch nicht umgesetzt. Keine
Terraform-Parallelverwaltung derselben Oracle-Ressourcen einfuehren.

Heavy Builds bleiben wegen der GitHub-Quellenregel zunaechst Source-Default. Vorschlag nach
Freigabe: `--source` und optional `--binary`, sofern ein fuer die Plattform geeignetes verifiziertes
Artefakt existiert. Nicht fuer n8n pauschal eine offizielle native Einzelbinary erfinden. Cache
unter `~/.cache/openclaw_builds` nach Tool/Version/Architektur/Compiler/Lockfile-Hash isolieren,
Treffer erneut verifizieren; Cache ist kein Besitznachweis und keine Erlaubnis fuer automatische
Loeschung. Blender-/FFmpeg-Lizenzen und Releaseherkunft pro Artefakt pruefen.

## 5. Fehlende Tools versus fehlende Integration

Status = lokaler Repository-Nachweis, **keine** Installations- oder Versionszusage. GitHub-Ziele
sind Quellen fuer den spaeteren PR, noch keine freigegebenen Pins. Nicht alle Projekte wurden extern
auf Release-/Lizenz-/Buildtauglichkeit geprueft.

| Tool / Integration                          | Stand und Warum                                                                                                        | Prio  | GitHub-Source / Install-Vorschlag nach OK                                                                                                                                                                   |
| ------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | ----- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Argo CD oder Flux                           | Beide CLIs vorhanden; Controller/Reconciliation nicht dadurch belegt                                                   | P2    | [Argo CD](https://github.com/argoproj/argo-cd) oder [Flux](https://github.com/fluxcd/flux2); genau einen Controller, nicht beide Defaults                                                                   |
| External Secrets Operator + Backend         | Kein entsprechender Registry-Nachweis im geprueften Abgleich; Secret-Rotation/Workload-Zugriff fehlt                   | P1    | [ESO](https://github.com/external-secrets/external-secrets), optional [OpenBao](https://github.com/openbao/openbao) bereits planned; Vault nur nach eigener Lizenz-/Betriebsentscheidung                    |
| Sealed Secrets / SOPS                       | SOPS planned; alternative GitOps-Secretpfade, nicht alles gleichzeitig                                                 | P1    | [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets), [SOPS](https://github.com/getsops/sops); Recovery-Key/Rotation vor Live-Nutzung                                                           |
| cert-manager + ACME                         | Kein passendes Registry-Modul nachgewiesen; Zertifikatslebenszyklus fehlt                                              | P1    | [cert-manager](https://github.com/cert-manager/cert-manager); ACME-Account/Issuer bewusst konfigurieren, Let's Encrypt ist CA/Dienst, kein zusaetzlicher lokaler Server                                     |
| Kyverno oder Gatekeeper                     | OPA-Tool allein waere noch keine Cluster-Admission                                                                     | P1    | [Kyverno](https://github.com/kyverno/kyverno) oder [Gatekeeper](https://github.com/open-policy-agent/gatekeeper); zuerst Audit-, dann kontrollierter Enforce-Modus                                          |
| Falco / Tetragon                            | Falco bereits planned, Tetragon kein entsprechender Registry-Treffer; Kernel-/WSL-Tauglichkeit offen                   | P3    | [Falco](https://github.com/falcosecurity/falco), [Tetragon](https://github.com/cilium/tetragon); nur optionaler isolierter Test                                                                             |
| Cosign / SBOM-Attestation                   | Cosign planned; Vertrauen/Admission/Release-Verifikation fehlen                                                        | P1    | [Cosign](https://github.com/sigstore/cosign), [Policy Controller](https://github.com/sigstore/policy-controller); zuerst Signer-/Issuer-Vertrauensanker definieren                                          |
| Syft/Grype/Gitleaks/Trivy-Operator          | Scanner/Hook teils vorhanden; direkte Syft-/Grype-Aufrufe in acht gelesenen Workflows nicht gefunden                   | P1/P2 | [Syft](https://github.com/anchore/syft), [Grype](https://github.com/anchore/grype), [Trivy Operator](https://github.com/aquasecurity/trivy-operator); CI-Gate zuerst, Operator optional                     |
| OpenTelemetry Collector                     | Konkretes Installskript vorhanden, Registry noch Stub; nicht einfach neu erfinden                                      | P2    | [Collector](https://github.com/open-telemetry/opentelemetry-collector); gepinnte Konfiguration, Trace-Redaktion und Exportziel testen                                                                       |
| Tempo oder Jaeger                           | Kein entsprechender direkter Registry-Treffer im Abgleich                                                              | P3    | [Tempo](https://github.com/grafana/tempo), [Jaeger](https://github.com/jaegertracing/jaeger); genau einen Trace-Pfad neben bewusst gewaehltem LLM-Tracing                                                   |
| kube-prometheus-stack / Dashboards / Alerts | Prometheus/Grafana/Loki vorhanden; Alarm-/GPU-/Dashboard-as-Code-Verkabelung fehlt                                     | P2    | [Prometheus Community Charts](https://github.com/prometheus-community/helm-charts); auf kleinen Hosts erst Minimalmetriken, nicht voller Stack als Pflicht                                                  |
| NVIDIA Device Plugin / DCGM                 | GPU-Zuweisung im Core-Manifest fehlt                                                                                   | P1    | [Device Plugin](https://github.com/NVIDIA/k8s-device-plugin), [DCGM Exporter](https://github.com/NVIDIA/dcgm-exporter); GPU Operator nur bei begruendetem Bedarf                                            |
| vLLM / TGI / SGLang                         | vLLM planned, TGI-Sourcepfad vorhanden, SGLang kein passender Registry-Treffer                                         | P3    | [vLLM](https://github.com/vllm-project/vllm), [SGLang](https://github.com/sgl-project/sglang); [TGI](https://github.com/huggingface/text-generation-inference) archiviert, kein neuer Standardpfad          |
| Model Cache / Operator                      | Kein getesteter Lifecycle durch Begriff 'Model Registry' allein; LocalAI bereits planned                               | P2/P3 | Zuerst Ollama-Modell-PVC/Pruefsumme/Ladezustand; [LocalAI](https://github.com/mudler/LocalAI) ist alternative Runtime, kein allgemeiner Ollama-Cache; keinen beliebigen Ollama-Operator als Standard setzen |
| Load Test / Prompt Cache                    | Ollama-Benchmark vorhanden; Gateway-Lastprofil/Cache-Semantik damit nicht belegt                                       | P2    | [LLMPerf](https://github.com/ray-project/llmperf); keine Lasttests gegen Cloud ohne Budgetfreigabe, Cache tenant-/modell-/promptversioniert und mit Loeschkonzept                                           |
| LiteLLM Autoscaling                         | Compose `container_name`/lokaler Einzelstack ist kein HPA-Deployment                                                   | P3    | [LiteLLM](https://github.com/BerriAI/litellm); stateless Proxy-/Budgetzustand testen, HPA nach gemessenen Queues/Latenzen statt blind CPU                                                                   |
| Cilium / Gateway API / MetalLB              | Keine entsprechenden direkten Registry-Treffer; Austausch des CNI ist Migration, kein Quick Win                        | P3    | [Cilium](https://github.com/cilium/cilium), [Gateway API](https://github.com/kubernetes-sigs/gateway-api), [MetalLB](https://github.com/metallb/metallb); L2 nur im Heimnetz mit kontrolliertem Adresspool  |
| Tailscale Operator / Headscale              | Tailscale-Hostinstaller vorhanden, Headscale planned; Operatorpfad nicht nachgewiesen                                  | P3    | [Tailscale](https://github.com/tailscale/tailscale), [Headscale](https://github.com/juanfont/headscale); Zusammenwirken/Features getrennt pruefen, keine automatische Alternative versprechen               |
| Velero / Restic                             | Beide Installer vorhanden; Velero CLI verifiziert CHECKSUM, aber kein installierter Backup-Controller/Restore-Nachweis | P1/P2 | [Velero](https://github.com/vmware-tanzu/velero), [Restic](https://github.com/restic/restic); CLI-/Plugin-/Controller-/Datenbackup getrennt testen                                                          |
| Longhorn / OpenEBS                          | Kein passender Registry-Treffer; lokale PVCs bislang ohne nachgewiesenes Failover                                      | P3    | [Longhorn](https://github.com/longhorn/longhorn), [OpenEBS](https://github.com/openebs/openebs); keine Replikation ueber schlafende Nodes/WAN als Standard; local-path kann bewusst genuegen                |

TGI-Archivstatus am 23.10.2026 auf der offiziellen
[GitHub-Seite](https://github.com/huggingface/text-generation-inference) geprueft. Ein vorhandenes
Gitleaks-pre-commit-Setup erzwingt noch keine Installation auf jedem Rechner und keinen
Branchschutz. Beides gesondert nachweisen.

## 6. WIREGUARD_ONLY und Compose: korrekter PR-Entwurf

`WIREGUARD_ONLY` wurde in `setup_ultimate.sh`, `config/tools.yml`, `config/profiles.yml` und dem
LLMOps-Compose **nicht gefunden**. Ein Schalter in einer Doku oder Umgebung bewirkt ohne Consumer
keinen Schutz. Kein globaler Sicherheitsnachweis fuer alle anderen Dateien oder laufenden Hosts
daraus ableiten.

Der LLMOps-Stack publiziert seine angegebenen Hostports bereits auf `127.0.0.1`
([Compose:11](../stacks/llmops-platform/docker-compose.yml#L11)); die separaten
Prometheus-/Grafana-Installer tun das nicht. Eigene Netze, Healthchecks, Ressourcenlimits und
durchgaengige Image-Pins fehlen dort als gemeinsame Baseline. Netdata verwendet sogar `SYS_PTRACE`
und `apparmor=unconfined` ([Compose:124](../stacks/llmops-platform/docker-compose.yml#L124)); solche
Host-Monitoring-Ausnahmen bewusst begrenzen statt auf normale Agenten uebertragen.

**Kein `network_mode: internal` einfuegen.** Docker definiert `internal: true` an einem benannten
Netzwerk. Konzeptionelles Fragment, kein angewendeter Stack:

```yaml
networks:
  data_plane:
    internal: true
  approved_egress: {}
```

Die PR muss zusaetzlich pro Service Netzmitgliedschaften definieren: Datenbanken nur im internen
Datennetz; Gateway nur in benoetigten Netzen, ausgehende Provider separat opt-in mit Egress-Regeln.
Ein zweites normales Netz ist selbst keine Zielhost-Allowlist. Nur `internal: true` pauschal ueber
alles zu legen kann Ollama-/Cloud-/DNS-/Updatewege unterbrechen; Loopback-Bindings allein verhindern
keine Container-zu-Container-Bewegung.
[Docker-Netze](https://docs.docker.com/reference/compose-file/networks/),
[gueltige network_mode-Werte](https://docs.docker.com/reference/compose-file/services/#network_mode).

Policy-Vorschlag: Bei `WIREGUARD_ONLY=true` keine oeffentlichen Host-Publishings, NodePorts oder
ungeschuetzten LoadBalancer fuer Managementdienste. Native Daemons binden an Loopback oder die
festgelegte VPN-Adresse; In-Pod-/Container-Listener auf `0.0.0.0` sind nicht automatisch
WAN-Exposition und duerfen nicht blind auf Loopback umgestellt werden, wenn sonst andere
Pods/Services sie nicht erreichen. Gewuenschte Host-/Container-Semantik vor dem Code-PR bestaetigen.

## 7. Konkrete PR-Vorschlaege

| PR                           | Pfade / Umfang                                                                                                | Test / Rollback                                                                                                                                                                                           |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 01 P0-Verwaltung             | `install.sh`, Compose-Helper, Backup-Runner                                                                   | Fremde Pfade, Dummy-Secrets, volle Disk, untracked/binaere Dateien; Nutzer-Workspace tabu; kein Datenloeschen beim Rollback                                                                               |
| 02 Netz-/Cloudgrenzen        | Monitoring-Installer, LLMOps-Compose, Gateway-/Proxy-Konfiguration                                            | Statisch gerenderte Konfiguration, unauthentifizierte Anfrage blockiert, Cloud standardmaessig deaktiviert; vorherige Konfiguration atomar erhalten                                                       |
| 03 Wirksame CI               | Bestehende `.github/workflows/ci.yml` **patchen**, nicht ersetzen; koordinieren mit sieben weiteren Workflows | shellcheck, shfmt, markdownlint, Trivy mit Fehlercode, Gitleaks, kubeconform/kube-linter; gepinnte Tool-/Action-Quellen, keine `latest`-Nachinstallation. Bekannte Legacy-Lints nicht global verschlucken |
| 04 Lifecycle / UI-Extraktion | Registry-Schemas, `scripts/lib/*.sh`, ein Core-Tool nach dem anderen                                          | Doppelinstallation ohne Aenderung, Doctor ohne Seiteneffekt, datenerhaltender Uninstall, keine Shell-Ausfuehrung beim blossen Source                                                                      |
| 05 IaC / Workloads           | Ansible-Rollen, OpenTofu-Statekonzept, Helm-Chart und Values                                                  | Wegwerf-VM/Cluster, Importplan ohne Loeschung, ARM/x86 und schlafender GPU-Node; PVCs/Schluessel erhalten                                                                                                 |
| 06 WOL / Join / Telemetrie   | Begrenzter Orchestrator, Join-Credential-Transport, GPU-/Backup-Alarme                                        | Gemockte SSH/WOL/Token-Aufrufe; Timeout, abgelaufener Token, Hostkey-/CA-Fehler und fehlende GPU muessen geschlossen scheitern                                                                            |

Alle Aenderungen erst nach OK. PRs sollen Diff, Risiko, Testnachweis, Migration und datenerhaltenden
Rollback enthalten. Kein neuer Workflow nur als dupliziertes Gate. Ein CLI-Fund durch `command -v`
muss mit erwarteter Version/Provenienz ergaenzt werden; 'vorhanden' allein ist keine idempotente
Installationsentscheidung.

GitHub-Quellenregel bleibt bestehen: primaere Toolquellen GitHub, apt nur fuer
System-/Build-Abhaengigkeiten. Der vorhandene
[Ansible-Installer](../scripts/tools/ansible_install.sh) verwendet allerdings apt fuer das
Primaertool und ist damit eine zu klaerende Ausnahme. Helm nutzt ein offizielles
Nicht-GitHub-Artefaktziel. `source_verified: true` nicht blind als Ausnahmeflag setzen: dafuer
braucht es nachweisbare Quelle, Verifikationsumfang, Datum und Beleg; Ausnahmegrund getrennt
dokumentieren. Ohne OK und Quellenbeleg wurde kein Registrywert gesetzt.

## 8. Task-Plan: HE vorne, Oracle steuert, Pi weckt, RTX rechnet

1. **HE/Domain:** DNS/IPv4/IPv6-Ziel und oeffentlich benoetigte Namen festlegen. HE ist kein
   pauschaler DDoS-/Authentifizierungsdienst. Managementnamen nicht mit automatisch offenen
   Adminports verwechseln.
2. **Oracle:** DMZ und Always-on-Control trennen, SSH-Hostkeys/TLS/Firewall pruefen. Nur
   freigegebene Web-/VPN-Dienste oeffentlich; K3s-API nur im Admin-/VPN-Netz. Einzelne Control Plane
   als bewusstes SPOF dokumentieren; keine etcd-HA ueber eine ungemessene WAN-Verbindung oder
   schlafende Nodes behaupten.
3. **WireGuard:** Vorlagen existieren unter [VPS-Peer](../scripts/wireguard/create-vps-peer.sh) und
   [Home-Peer](../scripts/wireguard/create-home-peer.sh), sind aber noch keine aktive getestete
   Verbindung. Peer-Schluessel lokal/geschuetzt erzeugen, nur oeffentliche Schluessel austauschen,
   Routen/MTU/IPv6/Firewall kontrolliert testen.
4. **Pi/MiniPC:** Always-on-Waechter mit eigenem nichtprivilegiertem Dienstkonto, nur erlaubte
   GPU-MAC/Adresse und begrenzte SSH-Kommandos. Vorhandener
   [WOL-Helper](../scripts/home-watcher/wake-gpu-server.sh) ist eine Aktion, kein kompletter
   Scheduler; [Ping/Port-Check](../scripts/home-watcher/check-gpu-server.sh) ist noch keine
   Modell-/GPU-Readiness.
5. **WOL-Ablauf:** Job sperren/idempotente Job-ID -> maximal begrenzte Wake-Versuche -> bis z.B. 180
   s auf erlaubten Host/SSH warten -> NodeReady/GPU/Service pruefen. Kein Request mehrfach
   ausfuehren, keine parallelen Wake-Stuerme, keine Cloudkosten als stiller Ersatz fuer eine
   schlafende GPU. Timeout als nachvollziehbarer Status.
6. **K3s-Join getrennt vom normalen Wake:** Nur beim erstmaligen Bootstrap des bekannten Hosts bzw.
   ausdruecklicher Reparatur. Control Plane erzeugt einen kurzlebigen Agent-Bootstrap-Token, z.B.
   TTL 10 min, im sicheren Format mit CA-Hash. Kein dauerhafter Server-Admin-Token als Standard und
   kein Geheimnis in Git, Prozessargumenten, normalen Logs oder Queue-Texten.
7. **Token transportieren:** Hostkey-gepruefter verschluesselter Kanal, Ansible `no_log`, privates
   Zielverzeichnis und Modus 0600, ueber `K3S_TOKEN_FILE`/`--token-file` einbinden.
   Bereinigungs-/Ablaufkonzept **nur fuer den neu erzeugten temporaeren Join-Token**, keine
   Loeschlogik im externen Nutzer-Workspace. Bereits eingeschriebene Agents nicht bei jedem
   Aufwachen neu joinen; Ablauf-/Reconnect-Verhalten im Wegwerfcluster testen.
   [K3s Tokens](https://docs.k3s.io/cli/token), [Agent-Token-Datei](https://docs.k3s.io/cli/agent).
8. **RTX:** Pinned K3s-Agent/Runtime, Node-Labels fuer Architektur/GPU, passende Taints/Tolerations
   und Device Plugin. Genau eine GPU-lastige Pipeline zu Beginn; Ollama-KV-Cache und ComfyUI nicht
   ohne gemessene Admission gleichzeitig ueberbuchen.
9. **Nachweis:** Job-Ende, GPU-Belegung, Queue, Backup-Alter und freigegebene Inferenzlatenz
   erfassen; Prompts/Keys nicht in Logs. Idle-Shutdown nur als eigener freigegebener Schritt nach
   leeren Queues und beendetem I/O.
10. **Abnahme:** Fresh Ubuntu-VM, separater WSL-Testpfad, ARM/x86; zweiter Lauf ohne Aenderung,
    unterbrochener Join, Restore ohne Live-Datenverlust. Erst dann Ansible-/Helm-Aufrufe in das
    Bash-Menue integrieren.

## 9. Quellen, Teststand und Entscheidungspunkte

Primaerbelege sind die verlinkten lokalen Dateien. Offizielle Quellen am 23.10.2026 zusaetzlich
gelesen: Docker-Netzwerke/network_mode, K3s Netzwerk und Tokens, TGI-GitHub-Archivstatus, ESO,
cert-manager, NVIDIA Device Plugin, LLMPerf und Prometheus-Community-Charts. Es wurden keine
Releases heruntergeladen.

[K3s Custom CNI](https://docs.k3s.io/networking/basic-network-options) erfordert eine abgestimmte
Flannel-/Policy-Konfiguration.
[Cilium Gateway API](https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gateway-api/)
hat eigene Voraussetzungen; kein sicherer In-place-Wechsel durch blosses Installieren eines weiteren
Tools. Bestehendes Flannel zuerst sauber testen.

Fruehere Pruefergebnisse im [Audit](AUDIT_2026-10-23.md): struktureller Check 0 Fehler/953 Hinweise,
neun Syntax-Kernpfade bestanden, Gesamttests im Zeitlimit und Aegisub-Fixture fehlgeschlagen. Keine
neue gruene Gesamtabnahme behauptet. Dieses Dokument wird nur auf Links, Tabellen/Fences und
Leerraum geprueft.

Vor jedem weiteren Code-/CI-/Registry-/Deployment-Patch zu entscheiden: erste PR-Prioritaet,
Ziel-Testplattform und erlaubte Source-/Binary-Strategie. Keine echten Secrets, keine Live-Hosts und
keine automatischen Installationen oder PR-/Push-Aktionen wurden fuer diese Review-Phase verwendet.
