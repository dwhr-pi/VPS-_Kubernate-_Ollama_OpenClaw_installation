# Konfigurationsvorschlaege und Runbook

Stand 23.10.2026. **Review-Vorlagen, keine neu installierten Dateien.** Bestehende Konfigurationen
nicht ueberschreiben. Nach Freigabe in einem eigenen PR extrahieren, rendern, schema-validieren und
im Wegwerfcluster testen. Echte Images/Digests, Secret-Zufuehrung, Storage-Klasse und
Gateway-Konfiguration sind verbindliche Voraussetzungen. Diese Beispiele sind kein bereits
getestetes Release.

[Bewertung und Phasen](PRODUCTION_BASELINE_2026-10-23.md).

## 1. ENV-Vertrag statt einer Datei mit allen Geheimnissen

Vorgeschlagen: `deploy/ai-core/.env.example`, nur Renderparameter:

```dotenv
OLLAMA_IMAGE=
OPENCLAW_IMAGE=
STORAGE_CLASS=
PSS_VERSION=
PRIVATE_CLIENT_CIDR=
OPENCLAW_TOKEN_SECRET=openclaw-gateway-token
OLLAMA_MODEL=
CLOUD_FALLBACK_ENABLED=false
```

| Variable                      | Anforderung                                                                                                                               |
| ----------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| OLLAMA_IMAGE / OPENCLAW_IMAGE | Verifiziertes aus GitHub-Quelle gebautes Image, vollstaendig `registry/name@sha256:<64 Hexzeichen>`; kein geratener Digest, kein `latest` |
| STORAGE_CLASS                 | Bestehende gepruefte Storage-Klasse mit passendem Restore-/Retain-Verfahren; kein implizites migrieren vorhandener PVCs                   |
| PSS_VERSION                   | Zum Testcluster passende feste PSS-Minorversion, nicht ungeprueft `latest`                                                                |
| PRIVATE_CLIENT_CIDR           | Tatsaechlich geroutetes VPN-/Adminnetz, nicht automatisch 0.0.0.0/0 oder ::/0                                                             |
| OPENCLAW_TOKEN_SECRET         | Vorab extern bereitgestellter Secretname mit nichtleerem Key `token`; kein Tokenwert in ENV/ConfigMap/Git                                 |
| OLLAMA_MODEL                  | Erst nach expliziter Modell-/Lizenz-/Speicherfreigabe konfigurieren; keine Modell-Downloads durch diese Vorlage                           |
| CLOUD_FALLBACK_ENABLED        | Vertrag fuer den spaeteren Renderer/Gateway-Adapter; nicht durch Setzen der Variable allein technisch durchgesetzt                        |

Vorlage nur mit einer **expliziten Allowlist** nichtgeheimer Variablen rendern. Kein pauschales
`envsubst` ueber Secrets, NGINX-Konfiguration oder beliebige JSON- Variablen. Kubernetes expandiert
diese Renderplatzhalter nicht automatisch. Renderer muss leere Werte, ungueltige Digests und offene
Client-CIDRs vor Apply ablehnen. Bestehende Root-/LLMOps-ENV-Dateien bleiben unveraendert.

## 2. Namespace, Budgets und ServiceAccount

Vorgeschlagen: `deploy/ai-core/base/namespace.yaml` nach Rendering. Budgets sind Beispiele fuer eine
kleine CPU-Baseline, nicht fuer beliebige Modelle.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ai-prod
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/enforce-version: "${PSS_VERSION}"
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ai-runtime
  namespace: ai-prod
automountServiceAccountToken: false
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ai-budget
  namespace: ai-prod
spec:
  hard:
    requests.cpu: "4"
    limits.cpu: "8"
    requests.memory: 8Gi
    limits.memory: 16Gi
    requests.ephemeral-storage: 2Gi
    limits.ephemeral-storage: 8Gi
    requests.storage: 80Gi
    persistentvolumeclaims: "4"
    pods: "6"
    services.nodeports: "0"
    services.loadbalancers: "0"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: ai-defaults
  namespace: ai-prod
spec:
  limits:
    - type: Container
      defaultRequest:
        cpu: 100m
        memory: 128Mi
        ephemeral-storage: 128Mi
      default:
        cpu: "1"
        memory: 1Gi
        ephemeral-storage: 1Gi
```

Kein RoleBinding und keine Admin-Kubeconfig fuer normale AI-Pods. Der Account ohne API-Token ist
kein Ersatz fuer Netz- und Tool-Policies.

## 3. Ollama: eigener Pod, Modell-PVC und Probes

Vorgeschlagen: `deploy/ai-core/base/ollama.yaml`. Image-Vertrag: Binary `ollama` ist fuer UID 10001
ausfuehrbar; Schreibpfade und PVC-Rechte vorab gegen das konkrete Image testen. Keine privilegierten
Init-Chowns.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ollama-models
  namespace: ai-prod
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: "${STORAGE_CLASS}"
  resources:
    requests:
      storage: 50Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama
  namespace: ai-prod
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: ollama
  template:
    metadata:
      labels:
        app: ollama
    spec:
      serviceAccountName: ai-runtime
      automountServiceAccountToken: false
      securityContext:
        runAsNonRoot: true
        runAsUser: 10001
        runAsGroup: 10001
        fsGroup: 10001
        fsGroupChangePolicy: OnRootMismatch
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: ollama
          image: "${OLLAMA_IMAGE}"
          command: [ollama, serve]
          ports:
            - name: api
              containerPort: 11434
          env:
            - {name: HOME, value: /tmp}
            - {name: OLLAMA_HOST, value: "0.0.0.0:11434"}
            - {name: OLLAMA_MODELS, value: /models}
            - {name: OLLAMA_CONTEXT_LENGTH, value: "4096"}
            - {name: OLLAMA_NUM_PARALLEL, value: "1"}
            - {name: OLLAMA_MAX_LOADED_MODELS, value: "1"}
            - {name: OLLAMA_KEEP_ALIVE, value: 5m}
            - {name: OLLAMA_MAX_QUEUE, value: "16"}
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop: [ALL]
          resources:
            requests:
              cpu: "1"
              memory: 2Gi
              ephemeral-storage: 512Mi
            limits:
              cpu: "4"
              memory: 8Gi
              ephemeral-storage: 4Gi
          startupProbe:
            httpGet: {path: /api/tags, port: api}
            periodSeconds: 5
            failureThreshold: 60
            timeoutSeconds: 3
          readinessProbe:
            httpGet: {path: /api/tags, port: api}
            periodSeconds: 10
            timeoutSeconds: 3
          livenessProbe:
            tcpSocket: {port: api}
            periodSeconds: 20
            timeoutSeconds: 3
          volumeMounts:
            - {name: models, mountPath: /models}
            - {name: tmp, mountPath: /tmp}
      volumes:
        - name: models
          persistentVolumeClaim:
            claimName: ollama-models
        - name: tmp
          emptyDir:
            sizeLimit: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: ollama
  namespace: ai-prod
spec:
  type: ClusterIP
  selector:
    app: ollama
  ports:
    - {name: api, port: 11434, targetPort: api}
```

In-Pod-Listener auf allen Pod-Interfaces ist nicht gleich Host-/WAN-Publishing. Die folgende Policy
begrenzt den Zugriff. `/api/tags` prueft nur API-Verfuegbarkeit, nicht Modell-/Inferenzfaehigkeit.
Kein automatischer Pull oder Probe-Prompt. `Recreate` vermeidet parallele RWO-Nutzung, bedeutet aber
Update-Downtime.

GPU-Overlay: zusaetzlich `limits.nvidia.com/gpu: 1`, passende Node-Affinity/ Toleration und
GPU-Quota setzen; NVIDIA Device Plugin und Runtime zuvor testen. Nicht blind auf einen CPU-/ARM-Node
schedulen. 8 GiB Host-RAM sind kein VRAM-Budget; Modell und KV-Cache messen, GPU nicht mit ComfyUI
ueberbuchen. PVC-Anforderung ist keine Garantie physisch freien Speichers. Bei WSL zusaetzlich den
Windows-Host begrenzen/pruefen, bevor Modell- oder Builddaten geschrieben werden.

## 4. OpenClaw: eigener Workload mit verpflichtendem Secret

Vorgeschlagen: `deploy/ai-core/base/openclaw.yaml`. Vorbedingung: ein passender Build aus
freigegebenem GitHub-Pin unter `/app`, Node im PATH und die referenzierten
Gateway-Flags/Health-Endpunkte dieser Version. Config-Schema des konkreten Pins pruefen. Kein
Docker-Socket, Host-Pfad oder privater Benutzer-Workspace wird gemountet.

Das Secret wird **nicht** mit Platzhalter-Token in Git angelegt. Secret-Manager/
Sealed-Secrets-Prozess muss `${OPENCLAW_TOKEN_SECRET}` mit Key `token` vorab bereitstellen.
Kubernetes Secrets sind ohne weitere Konfiguration nicht automatisch verschluesselt gespeichert.
RBAC/Encryption-at-rest/Rotation gesondert absichern.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: openclaw-config
  namespace: ai-prod
data:
  openclaw.json: |
    {"gateway":{"mode":"local","bind":"lan","auth":{"mode":"token"}}}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: openclaw-state
  namespace: ai-prod
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: "${STORAGE_CLASS}"
  resources:
    requests:
      storage: 5Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: openclaw-gateway
  namespace: ai-prod
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: openclaw-gateway
  template:
    metadata:
      labels:
        app: openclaw-gateway
    spec:
      serviceAccountName: ai-runtime
      automountServiceAccountToken: false
      securityContext:
        runAsNonRoot: true
        runAsUser: 10001
        runAsGroup: 10001
        fsGroup: 10001
        seccompProfile: {type: RuntimeDefault}
      containers:
        - name: gateway
          image: "${OPENCLAW_IMAGE}"
          command: [/bin/sh, -ec]
          args:
            - >-
              test -n "$OPENCLAW_GATEWAY_TOKEN";
              exec node /app/dist/index.js gateway run
              --bind lan --auth token --port 18789
          ports:
            - {name: gateway, containerPort: 18789}
          env:
            - {name: HOME, value: /state}
            - {name: OPENCLAW_CONFIG_PATH, value: /etc/openclaw/openclaw.json}
            - name: OPENCLAW_GATEWAY_TOKEN
              valueFrom:
                secretKeyRef:
                  name: "${OPENCLAW_TOKEN_SECRET}"
                  key: token
                  optional: false
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities: {drop: [ALL]}
          resources:
            requests: {cpu: 250m, memory: 256Mi, ephemeral-storage: 128Mi}
            limits: {cpu: "1", memory: 2Gi, ephemeral-storage: 1Gi}
          startupProbe:
            httpGet: {path: /startupz, port: gateway}
            periodSeconds: 5
            failureThreshold: 60
            timeoutSeconds: 3
          readinessProbe:
            httpGet: {path: /readyz, port: gateway}
            periodSeconds: 10
            timeoutSeconds: 3
          livenessProbe:
            httpGet: {path: /healthz, port: gateway}
            periodSeconds: 20
            timeoutSeconds: 3
          volumeMounts:
            - {name: state, mountPath: /state}
            - {name: config, mountPath: /etc/openclaw, readOnly: true}
            - {name: tmp, mountPath: /tmp}
      volumes:
        - name: state
          persistentVolumeClaim: {claimName: openclaw-state}
        - name: config
          configMap: {name: openclaw-config}
        - name: tmp
          emptyDir: {sizeLimit: 128Mi}
---
apiVersion: v1
kind: Service
metadata:
  name: openclaw-gateway
  namespace: ai-prod
spec:
  type: ClusterIP
  selector: {app: openclaw-gateway}
  ports:
    - {name: gateway, port: 18789, targetPort: gateway}
```

Diese Minimalconfig ist bewusst **noch keine Modell-/Skill-/Channel-Konfiguration**.
Ollama-Provider, vorhandene Modell-ID und Tool-Allowlist muessen schema-konform ergaenzt und negativ
getestet werden. Keine pauschale Shell-Freigabe fuer Agenten. Readiness ist keine Freigabe fuer
beliebige Skills oder reale Haus-/Finanzaktionen. Keine Cloud-Keys/Provider in dieser Vorlage. Token
als Secret-Env ist besser als Args/ConfigMap, aber immer noch fuer entsprechend berechtigte
Prozesse/Administratoren lesbar; SecretRef-/Credential-Mechanismen je nach Pin bevorzugen.

## 5. Default-Deny und explizite Pfade

Vorgeschlagen: `deploy/ai-core/base/network-policy.yaml`. DNS-Labels/CNI muessen am Ziel geprueft
werden; NodeLocal DNS braucht ggf. eigene Regeln. Ein CNI ohne Policy-Durchsetzung macht diese
Objekte wirkungslos.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: default-deny, namespace: ai-prod}
spec:
  podSelector: {}
  policyTypes: [Ingress, Egress]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: allow-dns, namespace: ai-prod}
spec:
  podSelector: {}
  policyTypes: [Egress]
  egress:
    - to:
        - namespaceSelector:
            matchLabels: {kubernetes.io/metadata.name: kube-system}
          podSelector:
            matchLabels: {k8s-app: kube-dns}
      ports:
        - {protocol: UDP, port: 53}
        - {protocol: TCP, port: 53}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: gateway-to-ollama, namespace: ai-prod}
spec:
  podSelector:
    matchLabels: {app: openclaw-gateway}
  policyTypes: [Egress]
  egress:
    - to:
        - podSelector:
            matchLabels: {app: ollama}
      ports:
        - {protocol: TCP, port: 11434}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: ollama-from-gateway, namespace: ai-prod}
spec:
  podSelector:
    matchLabels: {app: ollama}
  policyTypes: [Ingress]
  ingress:
    - from:
        - podSelector:
            matchLabels: {app: openclaw-gateway}
      ports:
        - {protocol: TCP, port: 11434}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: gateway-from-proxy, namespace: ai-prod}
spec:
  podSelector:
    matchLabels: {app: openclaw-gateway}
  policyTypes: [Ingress]
  ingress:
    - from:
        - namespaceSelector:
            matchLabels: {kubernetes.io/metadata.name: ingress-system}
          podSelector:
            matchLabels: {app: ai-reverse-proxy}
      ports:
        - {protocol: TCP, port: 18789}
```

Ollama bekommt absichtlich keinen Internet-Egress. Modelle ueber einen eigenen freigegebenen
Ingest-Job laden, nicht den Inferenzpod generell oeffnen. Der separate Proxy-Workload in
`ingress-system` ist Voraussetzung und braucht seinerseits Egress nur zum Gateway, eigene
Probes/Limits und eine Management- Ingressregel fuer `${PRIVATE_CLIENT_CIDR}`. Diese Regeln erzeugen
ihn nicht. Kubelet-Probes/Hostverkehr und Reverse-Proxy-SNAT am konkreten CNI testen. Keine
behauptete Ende-zu-Ende-Verbindung ohne diesen Test.

## 6. Separater Reverse Proxy mit TLS, mTLS und Rate Limit

Vorgeschlagen: ConfigMap fuer einen **eigenen** nichtprivilegierten NGINX-Workload in
`ingress-system`, kein Sidecar mit Hostzugriff. Hier nur dessen Konfiguration;
Deployment/Secret-Mounts sind Teil des spaeteren Ingress-PRs.

```nginx
pid /tmp/nginx.pid;
events { worker_connections 256; }
http {
    log_format ai_safe '$request_method $status $body_bytes_sent $request_time';
    access_log /dev/stdout ai_safe;
    error_log /dev/stderr crit;
    client_body_temp_path /tmp/client_temp;
    proxy_temp_path /tmp/proxy_temp;
    map $http_upgrade $connection_upgrade {
        default upgrade;
        '' close;
    }
    limit_req_zone $binary_remote_addr zone=ai_requests:10m rate=5r/s;
    limit_conn_zone $binary_remote_addr zone=ai_connections:10m;
    server {
        listen 8443 ssl;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_certificate /run/tls/server/tls.crt;
        ssl_certificate_key /run/tls/server/tls.key;
        ssl_client_certificate /run/tls/clients/ca.crt;
        ssl_verify_client on;
        client_max_body_size 2m;
        location / {
            limit_req zone=ai_requests burst=10 nodelay;
            limit_conn ai_connections 5;
            proxy_pass http://openclaw-gateway.ai-prod.svc.cluster.local:18789;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Forwarded-Proto https;
            proxy_buffering off;
            proxy_read_timeout 300s;
        }
    }
}
```

TLS-/Client-CA-Dateien ausschliesslich aus extern verwalteten Secrets mounten. Root-FS read-only,
`/tmp` begrenzt beschreibbar, Capabilities droppen und kein NodePort/oeffentlicher LoadBalancer als
Default. mTLS bedeutet neue Client- Zertifikate und ist ein **Breaking Change**, nicht automatisch
browserkompatibel. Alternativ bewusst OIDC/Auth-Proxy waehlen, nicht Auth entfernen. Gateway-Token
bleibt zusaetzlich erforderlich. Trusted-Proxy-/Origin-Regeln am konkreten OpenClaw-Pin setzen.
HTTP-Rate-Limits begrenzen nicht jede Nachricht eines bereits geoeffneten WebSockets; app-seitige
Session-/Kostenlimits bleiben noetig. Das Accesslog-Format enthaelt absichtlich weder URI,
Querystring noch Header. Fehler-/Anwendungslogs trotzdem separat redigieren; keine Debug-Dumps
aktivieren.

## 7. Native systemd-Alternative fuer OpenClaw

Alternative zum Gateway-Pod, **nicht gleichzeitig denselben Zustand starten**. Dedizierten
Systembenutzer `openclaw` mit nologin zuerst ueber die Hostrolle anlegen. Der Unit-Entwurf erwartet
ein gepinntes Release unter `/opt/openclaw/current`, eine kompatible private Node-Runtime sowie
validierte Konfiguration unter `/etc/openclaw`. Keinen bestehenden User-Workspace mounten oder
umziehen.

```ini
[Unit]
Description=Private OpenClaw gateway
Wants=network-online.target
After=network-online.target
StartLimitIntervalSec=300
StartLimitBurst=3

[Service]
Type=simple
User=openclaw
Group=openclaw
StateDirectory=openclaw
WorkingDirectory=/var/lib/openclaw
Environment=HOME=/var/lib/openclaw
Environment=OPENCLAW_CONFIG_PATH=/etc/openclaw/openclaw.json
LoadCredential=gateway-token:/etc/openclaw/secrets/gateway-token
ExecStart=/opt/openclaw/current/bin/run-gateway
Restart=on-failure
RestartSec=10
UMask=0077
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
PrivateDevices=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
RestrictSUIDSGID=true
RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6
CapabilityBoundingSet=
MemoryMax=2G
TasksMax=128
CPUQuota=100%
TimeoutStopSec=60
KillMode=control-group

[Install]
WantedBy=multi-user.target
```

Vorgeschlagener Release-Wrapper `bin/run-gateway`, noch nicht angelegt:

```sh
#!/bin/sh
set -eu
OPENCLAW_GATEWAY_TOKEN="$(cat "${CREDENTIALS_DIRECTORY:?}/gateway-token")"
export OPENCLAW_GATEWAY_TOKEN
test -n "$OPENCLAW_GATEWAY_TOKEN"
exec /opt/openclaw/current/runtime/bin/node \
  /opt/openclaw/current/dist/index.js gateway run \
  --bind loopback --auth token --port 18789
```

LoadCredential schuetzt den Transport zum Dienst, verschluesselt die Quelldatei aber nicht
automatisch auf Disk. Rechte, Recovery-Key und ggf. verschluesselte Credentials gesondert verwalten.
Unit ist keine vollstaendige Exec-/Egress-Sandbox; Host-Firewall und OpenClaw-Toolpolicy zusaetzlich
testen. Native Gateway->Ollama- Adresse muss zum gewaehlten Host-/VPN-/Kubernetes-Pfad passen, nicht
blind localhost.

## 8. Host-Firewall, SSH und Updates

Vorgeschlagener Regelplan fuer den VPS, **nicht unbeaufsichtigt ausfuehren**:

```sh
ufw default deny incoming
ufw default allow outgoing
ufw allow in on wg0 to any port 22 proto tcp
ufw allow in on wg0 to any port 6443 proto tcp
ufw allow 51820/udp
ufw allow 443/tcp
ufw status verbose
```

Keine implizite Freigabe fuer 11434, 18789, 6333, 8123 oder Datenbanken. 443 nur, wenn tatsaechlich
ein beabsichtigter TLS-/Auth-Proxy dort sitzt. Vor Enable/Reload: Interface/Port, IPv6,
Provider-Firewall, zweite Admin-Sitzung und Rettungskonsole pruefen. Alte Freigaben separat
inventarisieren; obige Befehle entfernen sie nicht. Kein `ufw reset`. Auf K3s-Hosts
CNI-/Forwardingregeln nicht blind sperren. Docker-Publishing kann UFW umgehen; externen
IPv4-/IPv6-Porttest gegen eigene freigegebene Hosts als Abnahme vorsehen.

Vorgeschlagener SSH-Drop-in nach erfolgreichem Key-/Sudo-Test des Adminbenutzers:

```text
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
```

`sshd -t` und effektive Konfiguration vor Reload pruefen. Lockout ist Breaking Change.
Fail2ban-SSHD-Jail mit systemd-Backend nur auf vorhandene Logs abstimmen; keine pauschalen
NGINX-Jails ohne passende Logquelle aktivieren. Security-Updates fuer Ubuntu nach geprueften
Origins/Release einrichten, aber keinen automatischen Reboot des GPU-/Control-Hosts ohne
Wartungsfenster.

```text
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
Unattended-Upgrade::Automatic-Reboot "false";
```

## 9. Monitoring-Konfiguration und Metrikvertrag

Vorgeschlagener Prometheus-Ausschnitt, Ziele erst im Monitoring-PR bereitstellen:

```yaml
global:
  scrape_interval: 30s
  evaluation_interval: 30s
rule_files: [/etc/prometheus/ai-alerts.yml]
scrape_configs:
  - job_name: host
    static_configs:
      - targets: [node-exporter.monitoring.svc.cluster.local:9100]
  - job_name: cluster-state
    static_configs:
      - targets: [kube-state-metrics.monitoring.svc.cluster.local:8080]
  - job_name: ai-instrumentation
    static_configs:
      - targets: [ai-metrics.monitoring.svc.cluster.local:9108]
```

Exporter/Namespace/DNS/Policy muessen existieren. `ai-metrics` ist ein **vorgeschlagener eigener
Adapter**, kein behaupteter Ollama-/OpenClaw-Endpunkt. CPU/RAM/Disk ueber node-exporter,
Pod-Restarts ueber kube-state-metrics, Gateway-Verfuegbarkeit ueber authentifizierungsbewusste
Healthchecks sammeln. Ollama-Latenz/TTFT im Gateway oder Adapter instrumentieren; keine automatische
Inferenz nur fuer einen als read-only beworbenen Doctor. Keine User-/Prompt-/ Tokenwerte als Labels.
Log-Retention und Collector-Speicherbudgets festlegen.

Vorgeschlagene Regeln, Adapter-Metriken sind erst zu implementieren:

```yaml
groups:
  - name: ai-baseline
    rules:
      - alert: HostMetricsUnavailable
        expr: up{job="host"} == 0
        for: 5m
        labels: {severity: warning}
      - alert: DiskSpaceLow
        expr: node_filesystem_avail_bytes{fstype!~"tmpfs|overlay"} / node_filesystem_size_bytes{fstype!~"tmpfs|overlay"} < 0.10
        for: 10m
        labels: {severity: critical}
      - alert: PodRestartBurst
        expr: increase(kube_pod_container_status_restarts_total{namespace="ai-prod"}[10m]) > 3
        labels: {severity: warning}
      - alert: GatewayUnavailable
        expr: ai_gateway_ready == 0
        for: 2m
        labels: {severity: critical}
      - alert: BackupTooOld
        expr: time() - ai_backup_last_success_timestamp_seconds > 93600
        labels: {severity: critical}
      - alert: BackupMetricMissing
        expr: absent(ai_backup_last_success_timestamp_seconds)
        for: 15m
        labels: {severity: warning}
```

Es fehlen in diesem Entwurf noch Alertmanager-Routing/Empfaengerfreigabe, regelbasierte Ausnahmen
fuer schlafende GPU-Nodes und ein Testalarm. Keine automatischen E-Mails/Pushes. Latenz-Schwellen
nach Modell/Hardware/SLO messen, nicht einen beliebigen universellen Sekundenwert als
Produktionsgarantie ausgeben.

## 10. Backup-Konfiguration und Restore

Vorgeschlagener Restic-Runner sichert **nur bereits konsistent bereitgestellte Exporte**. Er ersetzt
weder K3s-Datastore-Backup noch PVC-Snapshot/DB-Dump. Ein Export-Producer muss das Staging nach
erfolgreicher Pruefung atomar publizieren; keine parallelen Schreibzugriffe waehrend der Sicherung.
Quelle/Owner/Manifest, Frische und erwartete Pflichtartefakte vor jedem Lauf verifizieren.

```sh
#!/bin/sh
set -eu
umask 077
: "${RESTIC_REPOSITORY:?}"
: "${CREDENTIALS_DIRECTORY:?}"
RESTIC_PASSWORD_FILE="$CREDENTIALS_DIRECTORY/restic-password"
export RESTIC_PASSWORD_FILE
test -r "$RESTIC_PASSWORD_FILE"
test -s /srv/ai-backup/staging/openclaw-backup.tar.gz
test -s /srv/ai-backup/staging/manifest.json
exec 9>/run/ai-backup/backup.lock
flock -n 9 || exit 75
restic backup --tag ai-consistent-export -- /srv/ai-backup/staging
restic check
```

Der gezeigte Runner ist der Sicherungsschritt, nicht der noch fehlende Manifest-
Validator/Export-Producer. Ein vorhandenes Manifest allein beweist keine Konsistenz. Vor Aktivierung
deshalb Pflicht: nativen OpenClaw-Export mit zum Pin passender Verify-Funktion, DB-Konsistenz,
PVC-/Datastore-Exporte, RPO/RTO, Zielzugriff, Recovery-Key und Erfolg-/Fehler-Metrik implementieren.
Kein `forget --prune` als Default; kein Repo-/Workspace-rsync trotz Fehler als erfolgreich
markieren.

Vorgeschlagener Timer erst nach diesen Voraussetzungen, ohne Install/Enable:

```ini
[Unit]
Description=Daily encrypted AI export backup

[Timer]
OnCalendar=*-*-* 03:00:00
RandomizedDelaySec=15m
Persistent=true
Unit=ai-backup.service

[Install]
WantedBy=timers.target
```

Vorgeschlagene zugehoerige Service-Unit; Benutzer und gezielte Leserechte auf freigegebene Exporte
zuvor ueber Hostrolle bereitstellen. `ReadOnlyPaths` erteilt keine fehlenden Dateirechte.
`repository.env` enthaelt nur die Repository-Adresse, keine in die URL eingebetteten Zugangsdaten.
Backend-Auth, falls erforderlich, separat ueber Credentials anbinden, nicht im Beispiel erfinden.

```ini
[Unit]
Description=Encrypted backup of verified consistent AI exports
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
User=ai-backup
Group=ai-backup
RuntimeDirectory=ai-backup
CacheDirectory=ai-backup
Environment=RESTIC_CACHE_DIR=/var/cache/ai-backup
EnvironmentFile=/etc/ai-backup/repository.env
LoadCredential=restic-password:/etc/ai-backup/restic-password
ExecStart=/usr/local/libexec/ai-backup
UMask=0077
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
PrivateDevices=true
ReadOnlyPaths=/srv/ai-backup/staging
RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6
CapabilityBoundingSet=
MemoryMax=512M
CPUQuota=50%
TimeoutStartSec=2h
```

Kein automatischer Root-Zugriff auf den persoenlichen User-Workspace. Ausserhalb der Sicherung
verwahrte Recovery-Keys sind erforderlich.

Restore-Prozess: frisches isoliertes Ziel -> Archiv-/Hash-/DB-Integritaet pruefen -> Restic-Snapshot
in frisches Verzeichnis wiederherstellen -> Datenbank/State gegen kompatible Version laden -> Rechte
und Tests -> erst dann expliziter Umschaltplan. Kein In-place-Restore ueber produktive Volumes.
Monatlichen Restore-Test separat freigeben; es wurde kein Timer angelegt. Modelle standardmaessig
ueber Version/Digest/Quelle/Lizenz und Modelfiles inventarisieren; Gewichte bei Bedarf gezielt
sichern, nicht jeden Cache replizieren.

## 11. Runbook nach Freigabe und Deployment

| Aktion            | Kubernetes-Pfad                                                                                       | Native Alternative / Vorsicht                                                              |
| ----------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Start             | Gerenderte gepruefte Version anwenden, Events/Probes beobachten                                       | Vorgeschlagene Unit nach Test gezielt starten; kein Doppelbetrieb auf demselben Zustand    |
| Stop              | Erst Sessions/Jobs drainen, dann Deployment skalieren; PVC behalten                                   | Dienst stoppen, Workspaces nicht deinstallieren                                            |
| Update            | Backup/Restore pruefen, Digest aendern, neue Config schema-validieren, Rollout beobachten             | Verifiziertes Release neben altem installieren, erst nach Test umschalten; kein Hard-Sync  |
| Logs              | Nur benoetigte Pod-/Event-Metadaten, vor Weitergabe redigieren                                        | journalctl begrenzt nach Unit/Zeit; keine ENV-/Token-/Prompt-Dumps                         |
| Modellwechsel     | Gesonderter erlaubter Ingest, kompatible Modell-ID konfigurieren, Speicher und Antwort testen         | Dasselbe Verfahren; Probe ist echter Ressourcenverbrauch, kein read-only Check             |
| Disaster Recovery | Frischer Cluster/Namespace, Datastore/Token und Volumes nach dokumentierter Reihenfolge, dann Gateway | Frischer Host/Release, Geheimnisse aus geschuetzter Recovery, Restore nie ueber Live-State |

PDB absichtlich nicht als Schein-HA fuer die Einzelinstanz hinzugefuegt. Erst bei getestetem
Multi-Replik-/Storage-/Sessionkonzept z.B. `minAvailable: 1` fuer zwei wirklich unabhaengig
betriebsfaehige Gateways; das ist fuer RWO-/SQLite-State keine sichere blinde Skalierung.

## Quellen und Validierungsgrenzen

Am 23.10.2026 gelesen: [OpenClaw Gateway CLI](https://docs.openclaw.ai/cli/gateway),
[Health-Endpunkte](https://docs.openclaw.ai/gateway/health),
[Config-Schema](https://docs.openclaw.ai/gateway/configuration-reference),
[Docker-Netze](https://docs.docker.com/reference/compose-file/networks/). Live-Schema des konkreten
gebauten Pins hat Vorrang vor beweglicher Web-Doku. Keine Modell-/Auth-/Cluster-Abfragen wurden
ausgefuehrt.

Noch offen: echte Image-Pins, reproduzierbarer Build, OpenClaw-Modell-/Toolpolicy,
Proxy-Deployment/TLS-Secrets, gesamte CNI-Kommunikationsmatrix, API-Schemavalidierung, Probe- und
Rechte-Tests sowie Export-/Restore-Producer. Codebeispiele sind kein Beweis, dass diese
Integrationen bereits vorhanden oder produktionsreif sind.

Statische Dokumentpruefung dieses Vorschlagspakets: drei Dokumente, 31 lokale Dateiverweise
vorhanden, 17 geschlossene Codebloecke; drei Shell-Bloecke mit nativer Git-Bash `-n` ohne
Ausfuehrung syntaxgeprueft. Kein YAML-Parser im verwendeten Python-/Node-Pruefkontext verfuegbar,
nichts nachinstalliert. YAML/API-Schema, systemd/NGINX/Prometheus-Konfiguration und
Mermaid-Rendering sind hier nicht funktional validiert. Keine Deploy-/Probe-/Backup-Befehle aus den
Beispielen ausgefuehrt.
