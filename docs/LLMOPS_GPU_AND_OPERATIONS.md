# Kubernetes-, GPU- und Betriebsbausteine

Stand: 29.10.2026. Optionale, lokal vorbereitete Erweiterung; **keine bestaetigte
Produktionsfreigabe**. Es wurden weder Cluster noch Treiber installiert, Images
gebaut/veroeffentlicht, Secrets gelesen oder Modelle geladen. Die nativen
GitHub-Toolinstaller bleiben unveraendert; Container hier sind bewusst gewaehlte
Deployment- und CI-Artefakte, kein Docker-Fallback fuer diese Installer.

## Bestandsaufnahme und Prioritaeten

Die Basis besitzt bereits Non-root-Kontexte, Ollama-PVC/Probes, NetworkPolicies,
Budgets, Secret-Helfer, signierten Einstieg und einen abgesicherten
Installationsrunner. Diese Mechanismen werden erweitert, nicht parallel neu erfunden.

| Prioritaet | Befund | Aenderung / verbleibende Abnahme |
|---|---|---|
| P0 | Legacy-Flask-Proxy hatte LoadBalancer und Google-Key in der Request-URL; Exceptions konnten URLs enthalten | ClusterIP, Key im Header, reduzierte Fehlermeldung; keine Behauptung, dass dieser Beispielservice produktiv lief |
| P0 | Legacy-Proxy besitzt keine vollstaendige Authentifizierung und veraltete Laufzeit-/Modellbeispiele | Nicht oeffentlich betreiben; stattdessen authentifiziertes LiteLLM-Gateway verwenden |
| P1 | GPU-Runtime und Device Plugin waren nicht mit der Basis verdrahtet | GPU-Overlay und gepruefsummte Helm-Quelle, Hostvoraussetzungen separat |
| P1 | Ollama besitzt keinen hier nachgewiesenen nativen Prometheus-Endpunkt | Kein Scrape auf 11434/metrics; Gateway-Metriken und separater Exporter |
| P1 | Umfangreicher Monitoring-Stack kann einen Gratis-VPS ueberlasten | Expliziter Vollstack, kurze Retention und Limits; monitoring-lite bleibt Alternative |
| P1 | Local-Path-Volumes sind nodegebunden, keine verteilte Datensicherung | Node-/Disk-Ausfall und Restore gesondert testen; kein blindes Skalieren |

**Breaking Change:** Das alte `scripts/k8s_deployments.yaml` ist inzwischen
entfernt und nur als [historische Referenz](legacy/K8S_DEPLOYMENTS_LEGACY.md)
erhalten. Nicht erneut anwenden. Fruehere Aenderungen an diesem Beispiel
entfernten die LoadBalancer-Freigabe, waren aber keine Produktionsabnahme.
Bestehende Workloads und Zugriffspfade separat pruefen; nichts wurde automatisch
geaendert. Der alte Gemini-Modellname bleibt eine historische Angabe,
keine aktuelle Verfuegbarkeitszusage.

## Architektur

```text
Private Clients / VPN -> Traefik :443 + TLS + IP-Grenze
                                      |
                               LiteLLM :4000
                         API-Key / Limits / Metriken
                                      |
                             Ollama :11434 intern
                             GPU-Node + Modell-PVC

OpenClaw -> LiteLLM; Agent-Zustand -> eigener Workspace-PVC
Prometheus -> authentifizierte Gateway-Metriken / Node-Exporter
Alloy (separat abzunehmen) -> Loki -> Grafana intern
```

## 1. Kubernetes und GPU-Orchestrierung

Vollstaendige Dateien:

- [GPU-Kustomization](../k8s/overlays/gpu/kustomization.yml),
  [Ollama-GPU-Patch](../k8s/overlays/gpu/k8s-ollama-deployment.yaml),
  [Agent-Workspace-PVC](../k8s/overlays/gpu/agent-workspace-pvc.yml).
- Geerbte [Ollama-Basis](../k8s/base/ollama.yml): StatefulSet statt austauschbarer
  Pods ohne Zustand, Startup-/Readiness-/Liveness-Probes auf `/api/version`.
- [Device-Plugin-Werte](../k8s/platform/nvidia-device-plugin-values.yml) und
  [planbasierter Installer](../scripts/nvidia_device_plugin_install.sh).

```bash
bash scripts/nvidia_device_plugin_install.sh --plan
bash scripts/nvidia_device_plugin_install.sh --render > /tmp/nvidia-reviewed.yaml
kubectl kustomize k8s/overlays/gpu
```

Der Plan ist offline. `--render` laedt ausschliesslich den fest versionierten,
SHA256-geprueften GitHub-Chart und braucht vorhandenes Helm; kein Clusterzugriff.
Erst nach Review bewusst `--apply --context NAME --confirm` waehlen. `NAME`
bezeichnet den eigenen geprueften kubeconfig-Kontext, keinen erfundenen Standard.
Bestehende Releases brauchen zusaetzlich `--allow-upgrade`.

Voraussetzungen: NVIDIA-Linux-Treiber, Container Toolkit, K3s-containerd mit
NVIDIA-Runtime, RuntimeClass `nvidia`, bestaetigte GPU-Nodes mit Label
`nvidia.com/gpu.present=true`, Local-Path-Provisioner. Der Installer erzeugt
weder Treiber noch RuntimeClass oder Node-Labels. WSL2-GPU-Durchreichung ist eine
eigene Abnahme und folgt nicht allein aus erfolgreichem `nvidia-smi` unter Windows.
Device Plugin gehoert in `gpu-system`, nicht in den Restricted-Anwendungsnamespace;
Kubelet-Socket-/Hostzugriff ist eine ausdrueckliche Infrastruktur-Ausnahme.

Requests/Limits: 2/6 CPU, 4/12 GiB RAM, 256 MiB/2 GiB temporaerer Speicher,
jeweils eine GPU. Das ist ein Workstation-Profil, nicht fuer einen kleinen VPS.
GPU-Zuweisung ist **keine VRAM-Quote**. Kontext 4096, Parallelitaet 1 und ein
geladenes Modell begrenzen Last, garantieren aber nicht, dass jedes Modell in
16 GiB passt. Das Beispiel `llama3.2:1b` muss bereits im Cache vorhanden sein;
kein Init-Container laedt Modelle herunter.

Die Non-root-Basis nutzt `HOME=/data`, `OLLAMA_MODELS=/data/models` und mountet
den Modell-PVC dort statt unter `/root/.ollama`. Ein Mount unter `/root` passt
nicht zu UID 10001. Vorhandene Modelle nicht ohne kontrollierte Migration
verschieben. Die GPU-Images sind auf am 29.10.2026 abgefragte offizielle
Registry-Manifest-Digests festgelegt; Digest ist Herkunftsfixierung, kein
Unbedenklichkeitsnachweis. Der LiteLLM-Digest stammt aus `main-stable`; eine
Gleichheit mit der GitHub-Version 1.106.6 wurde nicht behauptet.

`local-path` ueberlebt Pod-Neustarts, folgt aber nicht automatisch einem anderen
Node. RWO und GPU=1 erlauben hier keine sinnvolle horizontale Ollama-Skalierung.
Agent-PVC ist separat und erst durch den OpenClaw-Patch tatsaechlich eingebunden.
Bei einem zweiten GPU-Node benoetigt jeder Modellserver eigene Kapazitaet und
Cache-Planung; Routing geschieht am Gateway, nicht durch Teilen desselben RWO-PVC.

## 2. Zero Trust, HTTPS und Secrets

[Netzwerkregeln](../k8s/overlays/gpu/ingress-network-policy.yml) ergaenzen die
Default-Deny-Basis fuer K3s-Traefik im Namespace `kube-system`, den ACME-Solver
und OpenClaw -> LiteLLM. Ollama akzeptiert nur LiteLLM, nicht direkt den Ingress.
Monitoring hat eine gezielte Ausnahme. Policies sind additiv: die vorhandene
Basis erlaubt auch Traefik im Namespace `traefik`. Nicht benoetigte Ausnahmen
vor Produktionsfreigabe entfernen. Controller-Labels, HostNetwork/SNAT und
tatsaechliche CNI-Durchsetzung mit positiven und negativen Requests pruefen.

Der [Offline-Ingress-Generator](../scripts/render_gpu_ingress.py) verlangt
`--domain`, `--email` und `--client-cidr` mit eigenen Werten. Er gibt einen
gueltigen Kubernetes-JSON-List mit Issuer, IP-AllowList und HTTPS-Ingress fuer
`/v1` aus. Keine Beispiel-Domain, keine API-Keys oder privaten Schluessel werden
erzeugt. Erst Ausgabe speichern, reviewen und separat anwenden.

cert-manager und die Traefik-CRDs muessen bereits installiert sein. HTTP-01
braucht oeffentlich erreichbaren Port 80 und passende DNS-Aufloesung; der
ACME-Solver wird nicht durch die private API-AllowList geleitet. Fuer rein
private Hosts stattdessen DNS-01 kontrolliert konfigurieren. Keine beliebigen
Forwarded-IP-Header vertrauen; hinter Cloudflare/VPN muss die tatsaechliche
Client-IP-Auswertung gesondert stimmen. HTTPS und IP-AllowList ersetzen weder
Gateway-Key noch mTLS, wenn mTLS im Bedrohungsmodell erforderlich ist.

[Gemini-Sealing-Helfer](../scripts/seal_gemini_secret.sh) verwendet den bestehenden
offline arbeitenden Kubeseal-Helfer. Flags: `--cert ABS`, `--cert-sha256 HASH`,
`--output ABS`. Zertifikat und SHA256 muessen unabhaengig vom Zielrepo geprueft
sein; der Key wird verdeckt am Terminal gelesen, nicht als Argument uebergeben.
Ergebnis ist ein echter `SealedSecret` fuer `llmops/gemini-runtime`, Feld
`GEMINI_API_KEY`. Keine fingierten Ciphertexte sind im Repo enthalten.
Der Controller muss samt gesichertem privaten Sealing-Key vorhanden sein.
Das GPU-Gateway referenziert dieses Secret optional, richtet jedoch **keinen
automatischen Cloud-Fallback** ein. Ohne bewusst gewaehlte Gemini-Route wird
der Key nicht benutzt. LiteLLM selbst braucht weiterhin
`llmops/litellm-runtime`, Key `master-key`, aus externem Secret-Management.

[OpenClaw-Haertungspatch](../k8s/platform/openclaw-hardening-patch.yml) ist
absichtlich **kein allein startbares Deployment**. Er braucht ein bereits
geprueftes Image, Entrypoint und Auth-Konfiguration. Containername `openclaw`,
UID/GID 10001, State-Pfad `/data/state` und Port 18789 mit dem konkreten Image
abgleichen. TCP-Probes bestaetigen nur den Listener, keine Anmeldung oder
Modellfunktion. Schreibpfade, Secret-Referenzen und Freigaben fuer Tools testen;
kein Docker-Socket, Host-Root oder ServiceAccount-Token wird bereitgestellt.

## 3. Monitoring und LLMOps

[Installer](../scripts/monitoring_install.sh),
[Prometheus/Grafana/Alertmanager-Werte](../k8s/monitoring/prometheus-values.yml),
[Loki-Werte](../k8s/monitoring/loki-values.yml) und
[Loki-Netzwerkgrenze](../k8s/monitoring/network-policy.yml).

```bash
bash scripts/monitoring_install.sh --plan
bash scripts/monitoring_install.sh --render > /tmp/monitoring-reviewed.yaml
```

Fuer Apply: vorhandener Namespace `monitoring` und Secret `grafana-admin` mit
`admin-user` sowie `admin-password`, eigener Kontext und explizite Bestaetigung.
Keine eingebauten Zugangsdaten. Das Skript prueft nur die Existenz beider Felder,
nicht ihren Inhalt. Es installiert/aktualisiert zwei getrennte Releases und
wendet vorher die Loki-Ingress-Policy an. Mindestens etwa 4 GiB RAM fuer
Monitoring zusaetzlich zur Inferenz planen, real messen; Limits aller optionalen
Chart-Helfer/Admission-Jobs vor Apply im Render kontrollieren. Node-Exporter
und Operator benoetigen Hostzugriff beziehungsweise Cluster-RBAC: keine
pauschale Restricted-Zusage fuer diesen Infrastruktur-Namespace.

Prometheus: 24h/2GB Retention, 5Gi PVC; Grafana und Alertmanager je 1Gi,
Loki 10Gi. Retention-/PVC-Groessen sind kein garantierter Schutz gegen eine volle
Disk. Alerts fuer Fuellstand, OOM, Pending/GPU, Restarts und Nichterreichbarkeit
testen. Alertmanager ist vorhanden, aber **kein Empfaenger konfiguriert**:
Paging-/E-Mail-Ziel aus eigenem Secret nachtragen und Testalarm quittieren.
Alle UIs sind ClusterIP, keine zusaetzliche oeffentliche Anmeldung freigeschaltet.

Ollama/OpenClaw erhalten `prometheus.io/scrape: false`, solange kein realer
Exporter nachgewiesen ist. LiteLLM bekommt `/metrics`-Annotations; der Operator
entdeckt diese nicht automatisch. Nach Installation seiner CRDs separat den
[authentifizierten ServiceMonitor](../k8s/monitoring/litellm-service-monitor.yml)
anwenden und `/metrics` mit und ohne Key pruefen. Monitoring-Key-RBAC eng halten;
hier referenziert der Monitor den Master-Key im selben Namespace, ein dedizierter
Metrics-Key ist bei bestaetigter Upstream-Unterstuetzung vorzuziehen.

Loki-Mandant `llmops` wird ueber `X-Scope-OrgID` verwendet. Dieser Header ist
**keine Authentifizierung**; Netzwerkgrenze und keine WAN-Freigabe sind wesentlich.
Die Grafana-Datenquelle ist vorbereitet. Loki allein sammelt keine Pod-Logs:
Alloy als separat geprueften Collector anschliessen, Prompts/Keys vor Versand
redigieren und nur eigene Container auswaehlen. Promtail wird nicht neu installiert
(EOL 02.03.2026). Kein funktionierender Logfluss wird ohne Collector-Abnahme behauptet.

Langfuse oder OpenLIT als separates, intern erreichbares Deployment bzw.
OpenTelemetry-Instrumentierung anbinden. Ein Sidecar allein erzeugt keine
automatischen LLM-Traces; die Anwendung muss instrumentiert sein. Prompt- und
Antwortinhalte standardmaessig nicht exportieren, Kosten und Retention begrenzen.

## 4. CI/CD und GitOps

[Workflow](../.github/workflows/build-and-push.yml),
[Dockerfile](../services/inference-gateway/Dockerfile) und
[Gateway-Konfiguration](../services/inference-gateway/config.yaml).
Das Custom-Image kapselt die lokale Inferenzroute auf Basis von LiteLLM, nicht
den unauthentifizierten Flask-Proxy. `LITELLM_OLLAMA_MODEL`, `OLLAMA_API_BASE`
und `LITELLM_MASTER_KEY` werden zur Laufzeit benoetigt, nie beim Build.

Ausloeser: Push auf `main` mit Aenderungen am Image/Workflow oder manueller Start
auf `main`. Reihenfolge: fest gepinnter Checkout ohne persistierte Credentials,
lokaler Docker-Build, Trivy auf HIGH/CRITICAL und Secrets, erst danach GHCR-Login
und Push **desselben Images** mit Commit-SHA-Tag. Keine `latest`-Tags, kein
automatisches Cluster-Deployment. Ein CVE stoppt die Veroeffentlichung; nicht
durch `continue-on-error` umgehen. Image-Digests erscheinen im Job-Summary.
Kuenftiger Push dieser Dateien auf main kann also ein Package veroeffentlichen;
dieser lokale Arbeitsgang hat keinen Workflow gestartet.

Fuer Argo CD/Flux: Namespace/CRDs, Sealed-Secrets-Controller und cert-manager
getrennt vor Anwendungen ausrollen; danach eine Application/Kustomization fuer
`k8s/overlays/gpu` mit **tatsaechlich vorhandenem, geprueftem Commit** anlegen.
Erst manuelle Synchronisierung, keine automatischen Prunes fuer Daten-PVCs.
Das neue GHCR-Image erst nach erfolgreichem Build, Laufzeit-/Auth-Test und mit
dem resultierenden Digest im Gateway-Patch uebernehmen. Das Overlay verweist
bis dahin auf das offizielle Digest-Image, nicht auf ein noch nicht gebautes Paket.
Siehe auch [bestehender GitOps-Bootstrap](GITOPS_SMALL_VPS.md).

## 5. Bash-Robustheit, Rollback und Betrieb

`install.sh` nutzt bereits `set -Eeuo pipefail`, Cleanup-Traps und geschuetztes
PAT-Handling. Der [Transaktionswrapper](../scripts/tools/run_install_transaction.sh)
bekommt ebenfalls `-E`, `umask 077` und prueft Python vor Ausfuehrung. Pfade,
Installer-Zuordnung, Sperren und Eigentuemer kontrolliert weiterhin
`scripts/lib/install_rollback.py`. Farbige Logs/Toolnamen bleiben in der
bestehenden interaktiven Oberflaeche; die neuen Offline-Plaene sind absichtlich
maschinenlesbares JSON statt ANSI-Code in Logdateien.

Keine globale Strict-Mode-Nachruestung in `setup_ultimate.sh` ohne Dialogtests:
Abbrechen/Nein liefert dort teilweise absichtlich einen Nichtnullstatus.
Kein pauschales `rm -rf` im ERR-Trap. Der bestehende Rollback entfernt nur
nachgewiesene neue private Installationswurzeln bei den freigegebenen
Speicherfehlern; vorhandene Daten und andere Fehlerzustande bleiben erhalten.
Ein fehlgeschlagener Build ist kein Grund, User-Daten zu loeschen.

Helm `--atomic` gilt **je Release**, nicht ueber beide Monitoring-Releases
hinweg; CRDs/PVCs und die vorher gesetzte Policy werden nicht allgemein
zurueckgerollt. Kein automatisches Helm-Uninstall oder Loeschen von Volumes.
Vor Upgrade Manifest-Diff, Helm-Historie und externes Backup pruefen.

Betriebsabnahme: Pods/Events/Logs im eigenen Kontext pruefen, Pending-Ressourcen
und PVC-Nodebindung klaeren, GPU-Zuteilung bestaetigen, zuerst unauthentifizierten
API-Zugriff ablehnen lassen, dann einen bewusst freigegebenen lokalen Modelltest
ausfuehren. Erst danach Ingress/DNS aktivieren. Restore des Agent-PVC auf
Wegwerf-Umgebung testen; Modell-Cache ist kein Ersatz fuer Agent-State-Backup.

## Quellen und Pruefgrenzen

GitHub-Release-URLs und SHA256 aus den Release-Metadaten stehen dauerhaft in
[platform_helm_releases.json](../config/platform_helm_releases.json). Chart-Hashes
werden vor Helm geprueft; Child-Images aller Charts sind dadurch noch nicht
vollstaendig per Digest fixiert. Chart-Render, Image-Scans und Freigabe der
gerenderten RBAC/Hostrechte sind weitere Gates, kein impliziter Teil des Plans.

- [NVIDIA Device Plugin v0.20.1](https://github.com/NVIDIA/k8s-device-plugin/releases/tag/v0.20.1)
- [K3s NVIDIA Runtime](https://docs.k3s.io/advanced#nvidia-container-runtime-support)
- [kube-prometheus-stack 92.14.1](https://github.com/prometheus-community/helm-charts/releases/tag/kube-prometheus-stack-92.14.1)
- [Loki-Chart 20.0.2](https://github.com/grafana-community/helm-charts/releases/tag/loki-20.0.2)
- [Loki Monolithic-Installation](https://grafana.com/docs/loki/latest/setup/install/helm/install-monolithic/)
- [Promtail-Supportende](https://grafana.com/docs/loki/latest/send-data/promtail/)
- [Migration zu Alloy](https://grafana.com/docs/alloy/latest/set-up/migrate/from-promtail/)
- [Kubernetes NetworkPolicies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

Offline-Regressionen: `tests/test_gpu_platform_blueprint.py`.
Kein erfolgreicher Offline-Test ersetzt Helm-/Kustomize-Render,
Admission-/CNI-/GPU-/TLS-/Restore- und echten Auth-/Readiness-Test.
