# GitOps-Deployment-Pfad fuer die Hybrid-Plattform

Stand: 03.11.2026. Bestehende Dateien werden weiterverwendet, nicht durch eine zweite Plattform ersetzt.
Git-Quellbuilds bleiben Standard, keine Docker-Installation und kein Docker-Fallback.
Diese Aenderungen sind keine Betriebsfreigabe und starten selbst keine Dienste oder Cluster.

## Struktur und Architektur

```text
HE / Oracle DMZ -> WireGuard -> Pi (WoL) -> Heim-GPU / K3s-Worker
                      |
                privater TLS-Proxy -> LiteLLM ClusterIP -> Ollama ClusterIP
                                              |               |
                                          /metrics       RWO-Modell-PVC
                                              |
                                  Prometheus / Grafana (opt-in)
```

[Kustomize-Einstiege und Zuordnung](../deploy/kustomize/README.md) referenzieren die vorhandenen
`k8s/base`-/Overlay-Verzeichnisse. Keine zweite Datenbank, kein zweites Ollama-StatefulSet,
keine geaenderten Claim-Namen. Die alten Pfade bleiben fuer Installer, ArgoCD und Links gueltig.
Namespace, ResourceQuota, LimitRange und PSS Restricted stammen weiterhin aus der Basis.
CPU- und GPU-Budgets bleiben getrennt; Quotas sind kein vollstaendiger OOM-Schutz des Hosts.

Nicht alles mit `.yaml` ist ausfuehrbar: Helm-Values, strategische Patches, noch ungepruefte
Beispiele und historische Referenzen bleiben bewusst ausserhalb des Workload-Graphs.
Die Operator-CRs sind separat, damit eine kleine Basis keine Operator-/GPU-/Storage-Dienste startet.

## Sichere Befehle und Provisionierungsgrenze

```bash
# Auch auf dem Entwicklungsclient: nur Textplan, kein Download oder Host-/Clustercheck.
bash scripts/setup-cluster.sh
# Nur lokales Rendering mit bereits vorhandenem geprueftem Kustomize:
bash scripts/setup-cluster.sh --render vps-cpu
```

Auf dem vorgesehenen Linux-Testhost mit bereits eingerichteter K3s-Source-Installation:

```bash
bash scripts/setup-cluster.sh --check --runtime-unit k3s --data-dir /var/lib/rancher/k3s
read -r -p 'Absoluter Pfad zum privat geprueften Overlay: ' OVERLAY
bash scripts/setup-cluster.sh --validate --overlay "$OVERLAY"
# Erst nach Abnahme: einzelner bewusster Install-/Update-Aufruf fuer die Workloads.
read -r -p 'Ausdruecklicher Staging-Kubernetes-Kontext: ' CONTEXT
bash scripts/setup-cluster.sh --apply --overlay "$OVERLAY" --context "$CONTEXT" --confirm-apply
```

`--validate` verwendet die bestehende lokale Host-/Runtime-Pruefung sowie Rendering und strikte
Manifestpruefung, aber keinen Kubernetes-Apply. Kubeconform-Schemas muessen verfuegbar sein;
die bestehende Standard-Schemaaufloesung kann Netzwerkzugriff benoetigen. Das ist kein
allgemeiner Offline-Nachweis. Apply verlangt zusaetzlich Server-Dry-Run, Kontext und Freigabe.
Kein Modus schaltet Swap ab oder installiert Docker, kubectl, Helm oder K3s nach.

Der vorhandene Deploy-Helfer validiert standardmaessig Kubernetes-Kernschemas. Fuer CRD-Overlays
(beispielsweise Traefik-Middleware oder ServiceMonitor) muessen die exakt passenden, geprueften
CRD-Schemas im Validator eingerichtet werden. Ohne diese bleibt die Pruefung absichtlich rot;
kein `-ignore-missing-schemas`. Der CPU-Kerneinstieg benoetigt diese Erweiterung nicht.

**Frischer Host:** `--provision` ist absichtlich kein Scheinerfolg. Der vorhandene
`bootstrap_gitops.sh`-Artefaktvertrag verlangt K3s-/cloudflared-Release-Binaries; das ist nicht
der jetzt verlangte ausschliessliche Source-Build-Pfad. Ein freigegebener nativer K3s-Gesamtbuild
ist hier noch nicht nachgewiesen. Deshalb kein stilles Delegieren an einen Release-/Docker-Installer.
`--bootstrap-plan` darf lediglich den alten Artefaktvertrag ohne Ausfuehrung pruefen.
Eine frische K3s-Source-Provisionierung bleibt ein gesonderter, mit VM-/ARM-Abnahme belegter Auftrag.

## Ollama und Persistenz

Readiness und Liveness rufen jetzt `GET /api/tags` mit fuenf Sekunden Timeout auf; Startup
bleibt ein leichter API-Versionscheck. Eine leere Modellliste kann HTTP 200 liefern: das beweist
keine Modellanwesenheit, keinen VRAM-Fit und keine erfolgreiche Inferenz. Kein automatisches Pull/Preload.
[Ollama-API-Vertrag](https://docs.ollama.com/api/tags).

`models-ollama-0` bleibt erhalten, Retention bei Loeschung/Skalierung bleibt `Retain`.
`vps-cpu-local-storage` setzt fuer **neue** Installationen die vorhandene K3s-StorageClass `local-path`.
Ein bestehendes volumeClaimTemplate oder die StorageClass eines Claims wird nicht still migriert.
Lokales RWO folgt einem anderen Node nicht automatisch. Node-Ausfall/Restore separat testen;
RWX ist nicht automatisch ein sicherer paralleler Ollama-Downloadcache.

## Netzwerk, TLS und Secrets

Standardroute: OpenClaw -> LiteLLM -> Ollama. Die Basis erlaubt direkte Ollama-Verbindungen
nur dem internen Gateway; die optionale Exporter-Policy erlaubt genau den Inventar-Exporter.
Der direkte OpenClaw-Bypass bleibt getrennt: Namespace `ai-agents`, beide expliziten Pod-Labels,
TCP 11434 und DNS. Er gewaehrt Zugang zur Ollama-API, nicht nur zu Inferenz; Pull-/Delete-Methoden
werden durch NetworkPolicy nicht eingeschraenkt. Nur vertrauenswuerdige Agenten nach extra Freigabe.
Policies sind additiv, kein Ersatz fuer RBAC oder Anwendungsauthentifizierung.

Das private Ingress-Overlay veroeffentlicht nur LiteLLM `/v1`, nicht Ollama oder die Metriken.
Domain und VPN-CIDR sind Umgebungswerte, kein fertiges Routing. Der ClusterIssuer liegt separat
unter `platform-dns01`, nutzt zunaechst die Staging-CA und ein vorhandenes, eng begrenztes DNS-API-
Secret im konfigurierten cert-manager-Cluster-Resource-Namespace (standardmaessig `cert-manager`).
Vor echtem Zertifikat E-Mail/Domain, Solver und ACME-Produktion bewusst umstellen.
DNS01 benoetigt keine oeffentliche Inbound-Freigabe des KI-Endpunkts. Private DNS-Aufloesung,
WireGuard-Routen, MTU und Firewall bleiben separat zu konfigurieren/abzunehmen.

Kein zweiter Traefik neben K3s: IngressClass, Namespace und Pod-Labels des vorhandenen Controllers
muessen zur NetworkPolicy passen. Die alte Produktionsvorlage mit HTTP01 bleibt Kompatibilitaet,
nicht die Empfehlung fuer ein vollstaendig privates Gateway.

SOPS-/Sealed-Secrets-Werkzeuge und Secret-Refs bleiben erhalten. Der vorhandene Helfer
`scripts/security/apply_vps_sops_secret.py` entschluesselt nur nach ausdruecklicher Freigabe und
akzeptiert ausschliesslich das festgelegte LiteLLM-Secret. Keine Klartext-Secrets in ConfigMaps,
Runtime-Apply oder CI-Variablen einfuegen. ESO ist kein automatischer SOPS-Git-Decryptor.
Modelleinstellungen ohne Credentials gehoeren in ConfigMap/privates Overlay, nicht pauschal in Secrets.

## Operator-Monitoring und Dashboard

`monitoring-operator` enthaelt zwei ServiceMonitors, PrometheusRule und den bisherigen Inventar-
Exporter. Er bleibt mit **null Replikaten** deaktiviert, bis ein eigenes geprueftes Image und die
Namespaces `monitoring`, `ai-monitoring`, `llmops` sowie Operator-CRDs vorhanden sind.
Keine CRDs, Namespace-Owner oder GPU-DaemonSets werden dadurch automatisch eingerichtet.

Die Basis hat jetzt auf allen Varianten das LiteLLM-Service-Label. Der optionale Vollstack waehlt
Monitors/Rules mit `release: llmops-monitoring` in genau diesen drei Namespaces; die vorhandene
Release-Konfiguration verwendet denselben Namen. Bei eigenen Releases Auswahl und RBAC anpassen.
Der Prometheus-Operator braucht Zugriff auf die referenzierten Secrets. Der derzeitige LiteLLM-
Scrape verwendet dessen Master-Key: Monitoring ist deshalb eine besonders vertrauenswuerdige
Kontrollebene, kein oeffentlicher Read-only-Account. Keine Kopie des Keys in einen zweiten Namespace.
`require_auth_for_metrics_endpoint` ist eingeschaltet; Abnahme ohne Token und mit Token erforderlich.

Neue Regeln melden fehlende/ausgefallene Gateway-Scrapes, wiederholte Restarts und hohen GPU-
Framebuffer-Verbrauch. Rules allein liefern keinen Alarm beim Betreiber; eigenen Alertmanager-
Empfaenger und kontrollierten Testalarm nachweisen. Kein No-Data wird zu einem gefaelschten Nullwert.

[Grafana-Dashboard](../monitoring/grafana/dashboards/llmops.json), Datasource-UID `prometheus`:
CPU/RAM/Disk, Gateway-p95/Tokenrate, Request-Counter mit Versions-Fallback sowie optional DCGM-VRAM/GPU.
DCGM muss separat auf kompatibler NVIDIA-Hardware laufen und privat gescrapt werden.
Der lesende Ollama-Exporter misst kein echtes VRAM und keine Inferenzlatenz. Bei mehreren Clustern
Datasource/Labels einschraenken statt fremde GPU-/Proxy-Daten unbemerkt zusammenzurechnen.
Metriknamen und Auth sind fuer die konkret eingesetzte LiteLLM-Version zu pruefen:
[offizieller Metrikvertrag](https://docs.litellm.ai/docs/proxy/prometheus).

## CI und manuelles Staging

`.github/workflows/deploy.yml` validiert bei passenden Pushes/PRs. Helm, kube-linter und Kustomize
werden aus fest gepinnten offiziellen Git-Quellen gebaut, Go-Module verifiziert; kein Docker.
Die feste offizielle Go-Buildtoolchain kommt ueber eine SHA-gepinnte Setup-Action im Wegwerf-Runner,
nicht als globaler Umbau der Benutzerinstallation. Die aktuellen Tool-Commits sind dokumentierte
Build-Eingaben, keine Runtime-/CVE-Freigabe der gesamten Plattform.
Synthetische Digests dienen ausschliesslich dem Helm-Template-Lint, nie einem Deployment.

Deployment ist standardmaessig aus und nur moeglich mit:

- manuellem `workflow_dispatch`, `deploy_staging=true` und exakt bestaetigtem Commit-SHA;
- dem Original-Repository auf `main`, nach erfolgreicher Validierung;
- dediziertem Linux-Self-hosted-Runner mit Label `llmops-staging`, niemals einem Produktionsrunner;
- eingerichtetem, geschuetztem GitHub-Environment `llmops-staging` mit erforderlichen Reviewern;
- ausserhalb des Checkouts vorbereitetem privatem Overlay und eigenem 0600-Kubeconfig des Runner-Benutzers;
- Environment-Variablen `LLMOPS_STAGING_OVERLAY`, `LLMOPS_STAGING_CONTEXT`,
  `LLMOPS_STAGING_KUBECONFIG` als Pfade/Kontext, nicht Credential-Inhalt;
- vorhandenen source-geprueften Deploy-Werkzeugen, K3s und minimalem Staging-RBAC.

Der Workflow erzeugt die Environment-Schutzregeln und Runner nicht selbst. Ohne Einrichtung bleibt
Staging aus/nicht lauffaehig. Keine Produktions- oder Pull-Request-Ausfuehrung auf dem Self-hosted-Runner.
ArgoCD und imperativen Apply nicht gleichzeitig als dauerhafte Owner derselben Workloads verwenden.

## Abnahme und Rollback

Offline-Fixtures pruefen Root/Overlay-Zuordnung, Secrets-/Probe-/Selector-Vertraege, YAML-Rendering,
Dashboard-Struktur, Workflow-Schranken und Plan-/Fehlerpfade. Das ist noch kein Helm-/kube-linter-
Buildlauf in GitHub, kein Live-Netz-/TLS-/SOPS-/GPU-Test und keine komplette Produktionsabnahme.

Lokaler Nachweis am 03.11.2026 (Windows, natives Git Bash/Kustomize, kein WSL):
kuratierte Sammlung 279 Tests, davon 255 bestanden und 24 begruendet uebersprungen;
zusaetzlich 12 neue Delivery-Fixtures und neun Hybrid-Beispieltests bestanden.
ShellCheck, shfmt, Markdownlint und `git diff --check` bestanden. Die uebersprungenen Tests
betreffen insbesondere POSIX-Rechte, Symlinks und Linux-Prozess-Fixtures; sie sind keine Erfolge.
Helm/kube-linter sind lokal nicht vorhanden und wurden nicht nachinstalliert.

Breaking Changes: `/api/tags` erzeugt Inventarzugriffe statt einfacher Versionschecks;
Metrics-Auth kann bisher unautorisierte Scrapes stoppen. Der neue lokale Storage-Einstieg ist
nicht fuer bestehende immutable Claims vorgesehen. Direkter Agenten-API-Zugriff bleibt opt-in.

Rollback: den vorigen geprueften Workload-/Policy-Stand explizit wiederverwenden; die alten Pfade
bleiben erhalten. Keine Namespace-/PVC-Loeschung, kein `prune` als Rueckweg, kein Key im Git.
Operator-Monitors/Rules nur einzeln zuruecknehmen, nicht den Monitoring-Namespace samt Daten entfernen.
Ein Manifest-Rollback ist kein Daten-Restore; dessen Nachweis bleibt separat erforderlich.
