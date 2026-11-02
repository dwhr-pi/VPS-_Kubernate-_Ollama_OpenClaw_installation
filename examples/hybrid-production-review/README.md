# Hybrid-Plattform: sechs getrennte Review-Bausteine

Stand: 02.11.2026. **Nicht automatisch eingebunden und nicht produktionsabgenommen.**
Keine Installation, kein Helm-Download, kein Clusterzugriff oder Dienststart wurde ausgefuehrt.
Die vorhandenen Kustomize-, Monitoring- und GitOps-Pfade werden nicht ersetzt.
Dieses Verzeichnis hat absichtlich keine gemeinsame Kustomization und kein Apply-Skript:
Cluster-Controller, privilegierte Infrastruktur und AI-Workloads brauchen getrennte Freigaben.

Weder eine Versionsnummer noch ein Digest wird erfunden. Gepruefte lokale Chart-Archive,
vollstaendige Image-Digests, echte Domains, CA, Secrets und Hardware-Abnahmen fehlen noch.
Die Beispiele sind kopierbare Konfigurationsdateien, keine Zusage eines sofort sicheren Apply.
Source-Builds bleiben die Vorgabe; Operator-Container und NVIDIA-Treiber bedeuten keine
stillschweigende Freigabe beliebiger Registry-Binaries oder proprietaerer Abhaengigkeiten.

## 1. GPU-Resource-Management

**NVIDIA GPU Operator, nicht als fehlend vorausgesetztes GPU-Deployment:**
[Operator-Werte](gpu-values.yaml), [exklusives und geteiltes Profil](gpu-sharing.yaml).
Der vorhandene [GPU-Overlay](../../k8s/overlays/gpu/kustomization.yml) bleibt unveraendert.

Time-Slicing teilt Rechenzeit, aber nicht sicher VRAM oder Fehlerdomaenen. Fuer nicht gegenseitig
vertrauenswuerdige Jobs exklusiven Zugriff beziehungsweise getrennte Hardware vorziehen.
Nicht jeder RTX unterstuetzt MIG oder alle DCGM-Metriken. Konkrete GPU, Treiber, Kernel,
Containerd-Version und Operator-Supportmatrix pruefen. Ein Operator verwaltet keinen Windows-Treiber
innerhalb von WSL; Treiberverwaltung erfordert einen passenden nativen Linux-Worker.
Siehe [NVIDIA Sharing](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-sharing.html)
und [Supportmatrix](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/platform-support.html).

`driver.enabled: false` ist die bewusst sichere Ausgangslage. Ein automatisch verwalteter Treiber
braucht eine gesonderte Lizenz-/Hostaenderungsfreigabe und danach `driver.enabled: true` im privaten Overlay.
Toolkit-Anpassungen veraendern ebenfalls Host-Containerd; dies ist keine nebenwirkungsfreie Installation.
Nicht parallel zum bisherigen Standalone-Device-Plugin betreiben. NFD ist hier ausgeschaltet;
den echten GPU-Node vorher mit passenden NVIDIA-Feature-Labels vorbereiten und den Nvidia-RuntimeClass-Vertrag testen.
K3s kann Containerd-Konfiguration regenerieren: Persistenz des Toolkit-Pfads nach Neustart pruefen.

Exklusiv bleibt Standard. Erst nach VRAM-/OOM-Tests den Node auf das Profil `shared` setzen und im
Workload Requests/Limits auf `nvidia.com/gpu.shared: 1` umstellen, inklusive Quota. Ein normaler
OpenClaw-Client braucht keine GPU-Zuteilung, wenn ausschliesslich Ollama die Inferenz ausfuehrt.

## 2. GitOps und Continuous Deployment

**Argo CD ist teilweise vorhanden, nicht neu zu erfinden:**
[begrenztes Projekt und manuelle Anwendung](argocd.yaml).
Den vorhandenen [geprueften Bootstrap](../../docs/GITOPS_SMALL_VPS.md) wiederverwenden.
Keine bewegliche `stable/install.yaml` herunterladen und sofort ausfuehren.

Eine Anwendung zeigt auf genau einen Overlay, der die Basis bereits einbindet; zwei gleichzeitige
Anwendungen fuer dieselbe Basis erzeugen konkurrierende Eigentumsverhaeltnisse. Der echte Commit im
Beispiel ist nur die Review-Basis und enthaelt noch absichtliche Image-/Modellplatzhalter.
Vor einer Synchronisation braucht es einen freigegebenen Commit mit echten Deployment-Pins.
Projekt-Allowlist ersetzt weder Argo-RBAC, Branchschutz noch die Pruefung von Namespace-Ressourcen.
Der Argo-Controller bleibt privat; kein Auto-Sync, Prune oder automatisches Produktionsdeployment.
Siehe [deklarativer Argo-Aufbau](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/).

## 3. Secrets Management und Admission Control

**ESO plus Kyverno, jeweils separat zu installieren und abzunehmen:**
[SecretStore/ExternalSecret](external-secret.yaml), [opt-in Admission-Policy](admission.yaml).

ESO entschluesselt keine SOPS-Datei direkt aus Git. Hier lautet der explizite Datenfluss:
SOPS-verschluesseltes Git-Objekt -> vertrauenswuerdige Entschluesselungsstation -> bereits vorhandener
OpenBao/Vault-kompatibler KV-v2-Store -> ESO -> namespaced Kubernetes Secret.
Wer keinen solchen Store betreibt, sollte SOPS direkt mit einem geprueften GitOps-Integrationsweg nutzen,
statt nur fuer dieses Beispiel einen weiteren Secret-Server zu starten.
Siehe [ESO Vault-Provider](https://external-secrets.io/latest/provider/hashicorp-vault/).

Beispiel fuer eine **separat freizugebende** Provider-Befuellung, nicht Bestandteil von Argo-Sync:

```bash
set -euo pipefail
set +x
: "${SOPS_INPUT:?Absolute SOPS-Datei mit LITELLM_MASTER_KEY erforderlich}"
[[ "$SOPS_INPUT" = /* && -f "$SOPS_INPUT" ]] || exit 2
# Existing authenticated local bao session and CA-verified provider required.
# Output goes directly into the provider, never into Git, logs or an argv value.
sops --decrypt --output-type json "$SOPS_INPUT" | bao kv put -mount=secret llmops/litellm -
```

Die OpenBao-Kubernetes-Rolle muss ausschliesslich diesen ServiceAccount/Namespace, die Audience `openbao`
und Leserechte auf `secret/data/llmops/litellm` erlauben. CA-ConfigMap und Rollenbindung werden nicht erfunden.
ESO braucht eng begrenztes TokenRequest-Recht; private Keys bleiben ausserhalb Git und ausserhalb AI-Pods.
Kubernetes Secrets sind ohne zusaetzliche Konfiguration nicht automatisch verschluesselt gespeichert:
K3s-Secret-Encryption, RBAC, Backup-Schutz und Rotation getrennt abnehmen.

Kyverno greift nur bei dem Namespace-Label `llmops.example/admission=enforce`. Vorher vorhandene
Workloads inventarisieren, negative/positive Admission-Fixtures testen und PSS Restricted passend zur
Cluster-Version aktivieren. GPU-Limits gelten fuer GPU-Claims, nicht pauschal fuer jeden CPU-Sidecar.
Die vorliegende Policy kann absichtlich Debug-Container ohne Ressourcenvertrag blockieren.
GPU-/Velero-Systemnamespaces duerfen nicht versehentlich denselben Restricted-Vertrag erhalten.

## 4. Observability und GPU-Monitoring

**kube-prometheus-stack/Loki sind bereits vorbereitet; DCGM ist eine Hardware-abhaengige Ergaenzung:**
[Monitoring-Overlay](monitoring-values.yaml), [importierbares Dashboard](rtx-dashboard.json).

Die vorhandene [monitoring-lite-Chart](../../charts/monitoring-lite/Chart.yaml) hat keine solchen
Chart-Abhaengigkeiten. Ihre Values um fremde Schluessel zu erweitern wuerde nichts installieren.
Stattdessen fuer den freigegebenen Vollstack die vorhandenen
[Prometheus-Werte](../../k8s/monitoring/prometheus-values.yml) und
[Loki-Werte](../../k8s/monitoring/loki-values.yml) als zwei getrennte Releases verwenden.
Das neue Overlay wird nach den Prometheus-Werten geladen; fester Release-Name ist `monitoring`.

GPU Operator erzeugt den DCGM-Exporter-DaemonSet und ServiceMonitor. Keine zweite Exporter-Installation.
Die Prometheus-CRDs muessen vorher existieren. Labels, ServiceMonitor-Auswahl, Metrics-Port und
NetworkPolicies beider Namespaces pruefen. Unter Time-Slicing sind Hardwaremetriken keine verlaessliche
Pro-Pod-Kostenabrechnung. Nicht unterstuetzte Messwerte als unbekannt behandeln, nicht als gesund.

Dashboard manuell importieren und dabei eine echte Prometheus-Datasource auswaehlen. Automatisches
Sidecar-Provisioning braucht stattdessen eine feste lokale Datasource-UID und eine ConfigMap mit
`grafana_dashboard: '1'`; der Import-Parameter ist kein fertiger Provisioning-Datasource-Vertrag.
Loki nimmt ohne bestehenden Alloy-/Log-Collector noch keine Anwendungslogs entgegen.
Keine Prompt-/Key-Logs einschalten. Vollstack und DCGM sind kein Standard auf kleinen Gratis-VPS/Pi.

## 5. Netzwerk-Isolation und Ingress

**Cilium ist optional; funktionsfaehige Policy-Durchsetzung, Traefik und cert-manager sind Voraussetzungen:**
[Default-Deny und interne Fluesse](network-policy.yaml), [privater DNS-01-Ingress](private-ingress.yaml).

Keinen CNI-Wechsel als Beifang ausfuehren. Bestehendes K3s mit wirksamer NetworkPolicy-Durchsetzung kann
genuegen. Ein Cilium-Wechsel benoetigt einen eigenen Migrations-/Rollbackplan; Standard-NetworkPolicy
kann keine externen DNS-Namen freigeben. Externe APIs bleiben hier geschlossen, bis ein konkreter
Provider oder authentifizierter Egress-Proxy mit enger Zielregel freigegeben wurde.

Vertrag: kanonischer Namespace `llmops`, bestehende ClusterIP-Services `openclaw:18789`, `n8n:5678`,
`litellm:4000`, `ollama:11434` und passende `app`-Labels. Traefik ist der gebuendelte Controller in
`kube-system`; bei separatem Controller Namespace/Labels in **allen** vorhandenen Policies synchronisieren.
Policy-Erlaubnisse addieren sich: dieses Beispiel nimmt bestehende breite Erlaubnisse nicht zurueck.
DB-/RAG-/ESO-/Scrape-Fluesse brauchen zusaetzliche enge Regeln und echte Negativtests.
Keine oeffentliche Raw-Ollama-Route; Agenten gehen ueber das authentifizierte Gateway.

Ingress stellt keine WireGuard-Verbindung her. Vorher muessen VPS-/Worker-Adressen, AllowedIPs,
private K3s-Node-/CNI-Routen, Rueckroute und MTU funktionieren. Pi weckt, muss aber nicht Datenrouter sein.
Traefik-EntryPoint und Host-Firewall duerfen HTTPS nur im freigegebenen privaten Pfad annehmen.
Split-DNS zeigt beide UI-Domains auf diese Adresse; kein oeffentlicher LoadBalancer wird erzeugt.
Fuer private Endpunkte DNS-01 verwenden; Cloudflare-Token mit minimaler DNS-Zonenberechtigung separat
bereitstellen. Erst ACME-Staging, danach `letsencrypt-prod`.
Siehe [cert-manager DNS-01](https://cert-manager.io/docs/configuration/acme/dns01/).

Nur diese drei nicht geheimen Variablen in einer privaten Ausgabedatei ersetzen:

```bash
set -euo pipefail
set -C
umask 077
: "${OPENCLAW_HOST:?Echte private UI-Domain erforderlich}"
: "${N8N_HOST:?Echte private n8n-Domain erforderlich}"
: "${ACME_EMAIL:?Eigene ACME-Mailadresse erforderlich}"
: "${PRIVATE_INGRESS_FILE:?Neue absolute Ausgabedatei erforderlich}"
[[ "$PRIVATE_INGRESS_FILE" = /* ]] || exit 2
# Reject template injection and invalid hostname/email inputs before rendering.
host_pattern='^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$'
for host in "$OPENCLAW_HOST" "$N8N_HOST"; do
  [[ ${#host} -le 253 && "$host" =~ $host_pattern && "$host" != *.invalid ]] || exit 2
done
[[ "$OPENCLAW_HOST" != "$N8N_HOST" ]] || exit 2
[[ "$ACME_EMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]] || exit 2
# Never render every environment variable, or overwrite an existing output file.
envsubst '$OPENCLAW_HOST $N8N_HOST $ACME_EMAIL' \
  < examples/hybrid-production-review/private-ingress.yaml > "$PRIVATE_INGRESS_FILE"
```

Unersetzte Variablen sind keine gueltigen produktiven Domainwerte. UIs brauchen weiterhin ihre
eigene Authentifizierung, erlaubte Origins und Proxy-Konfiguration; vorgeschaltetes BasicAuth ersetzt dies nicht.

## 6. Backup und Disaster Recovery

**Velero ist bereits vorgesehen; fehlend ist der echte Restore-Nachweis:**
[Helm-Werte](velero-values.yaml), [zunaechst pausierter Zeitplan](backup-schedule.yaml).
Nicht parallel zur vorhandenen Schedule denselben Sicherungsumfang aktivieren.

Eine freigegebene, versionskompatible Server-/AWS-Plugin-Kombination und lokaler Chart sind Voraussetzung.
Die Variablen `VELERO_IMAGE_REPOSITORY`, `VELERO_IMAGE_DIGEST`, `VELERO_AWS_PLUGIN_IMAGE`, `S3_BUCKET`,
`S3_REGION` und `S3_ENDPOINT` nur in einer privaten Werte-Kopie ersetzen. Images brauchen echte Digests;
S3-Endpunkt muss HTTPS mit gepruefter CA sein. Keine Secrets in Helm-Werte oder Shell-Argumente schreiben.
Quelle: [offizielle Velero-Chartwerte](https://github.com/vmware-tanzu/helm-charts/blob/main/charts/velero/values.yaml).

Node-Agent nur auf explizit markierten Speicher-Nodes; Host-Mounts und Rechte separat abnehmen.
Der automatische Cluster-Admin-Binding ist ausgeschaltet. Vor Betrieb wird versionsgeprueftes
Backup-/Restore-RBAC benoetigt; ohne dieses darf die Cluster-Sicherung scheitern, statt
stillschweigend Adminrechte zu erhalten. Backup-Leserechte und Restore-Schreibrechte trennen.
FSB sichert gemountete unterstuetzte Pod-Volumes, nicht willkuerliche Hostverzeichnisse.
Fuer PVC-Volume `memory` die Annotation `backup.velero.io/backup-volumes: memory` auf das Pod-Template setzen.
Lokalen Modellcache nur bei Bedarf zusaetzlich aufnehmen; Gewichtedownloads sind nicht Agentengedaechtnis.
HostPath ist kein unterstuetzter FSB-Volumetyp; lokalen/PVC-Speicher anhand der tatsaechlichen PV und
Kubelet-Mounts pruefen. Ein Filesystem-Backup laufender Datenbanken ist nicht automatisch konsistent.
Siehe [Velero File System Backup](https://velero.io/docs/main/file-system-backup/).

S3 muss ausserhalb derselben ausfallenden Maschine liegen. Repository-Verschluesselung, unabhaengige
Repository-Zugangsdaten, S3-Verschluesselung, Retention/Object-Lock und Bucket-Rechte gesondert nachweisen.
K3s-Datastore/CA/Join-Credentials separat sichern: Velero ersetzt keine Control-Plane-Sicherung.
Erst nach Wiederherstellung in einen isolierten Zielcluster inklusive DB-Abfrage, Rechtepruefung und
Memory-/Dateivergleich darf `paused` auf `false` wechseln. Die Schedule allein beweist keinen Restore.

## Gemeinsame Offline-Abnahme vor jeder Installation

Pruefen: lokale Chart-Hashes gegen unabhaengig erhaltene Freigaben, Chart-Version/CRDs,
alle gerenderten Images mit Digests, Ressourcen, private Netze und benoetigte Namespaces.
`helm template` arbeitet mit bereits geprueften lokalen Archiven; keine automatische Dependency-Aufloesung,
kein Chart-Download oder Apply. Fuer GPU-/Velero-Systemkomponenten gelten dokumentierte Privileg-Ausnahmen,
nicht stillschweigend die Regeln der AI-Pods. Server-Dry-Run kontaktiert Cluster und Admission-Webhooks und
ist eine separat freizugebende Stufe. Erst danach expliziter Installations-/Migrationsplan und Abnahme.

Die Source-Regel bleibt bestehen. Insbesondere GPU-Treiber, Toolkit und deren Container-Artefakte koennen
nicht pauschal als vollstaendige GitHub-Source-Builds gelten. Bis zur benoetigten Ausnahmefreigabe ist
dieser Teil ein Konfigurationsentwurf, kein freigegebener neuer Installationsweg.
