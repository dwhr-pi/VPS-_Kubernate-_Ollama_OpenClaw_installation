# Vollstaendige Konfigurationen der Produktions-Baseline

Stand: 23.10.2026. Kommentierter Lesestand der angelegten Dateien, keine deployte Infrastruktur. Die
[Betriebsanleitung](PRODUCTION_BASELINE.md) beschreibt Voraussetzungen, Risiken und Tests.
Massgeblich bleiben die verlinkten Quelldateien; bei spaeteren Aenderungen kann dieser datierte
Lesestand abweichen. Platzhalter sind absichtlich nicht einsatzbereit. Keine echten Secrets
enthalten.

## 1. Infrastructure as Code

Ansible verwaltet den Sollzustand idempotent; der Dienstbenutzer erhaelt keine Root- oder
Docker-Gruppenrechte.

### ansible/vps_bootstrap.yml

[Quelldatei](../ansible/vps_bootstrap.yml)

```yaml
---
- name: Bootstrap a dedicated Ubuntu VPS
  hosts: vps
  become: true
  gather_facts: true
  serial: 1
  vars:
    llmops_ssh_public_key: ""
    # Set only after independently testing the bootstrap administrator's SSH key.
    bootstrap_key_access_confirmed: false
    # Existing hosts/firewalls need a separate migration, never an implicit reset.
    bootstrap_dedicated_host_confirmed: false
    docker_architectures:
      x86_64: amd64
      aarch64: arm64
    docker_key_sha256: 1500c1f56fa9e26b9b8f42452a553675796ade0807cdce11975eb98170b3a570
  pre_tasks:
    - name: Validate platform and explicit safety acknowledgements
      ansible.builtin.assert:
        that:
          - ansible_distribution == 'Ubuntu'
          - ansible_distribution_version in ['22.04', '24.04']
          - ansible_architecture in docker_architectures
          - bootstrap_key_access_confirmed | bool
          - bootstrap_dedicated_host_confirmed | bool
          - ansible_port | default(22) | int == 22
          - llmops_ssh_public_key is match('^(ssh-ed25519|ssh-rsa|ecdsa-sha2-nistp[0-9]+) [A-Za-z0-9+/=]+( .*)?$')
        fail_msg: "Dedicated Ubuntu host, tested administrator key and llmops public key required."
    - name: Gather installed packages
      ansible.builtin.package_facts:
        manager: auto
    - name: Reject conflicting Docker distributions without removing anything
      ansible.builtin.assert:
        that:
          - "item not in ansible_facts.packages"
        fail_msg: "Existing container runtime found. Plan a separate migration first."
      loop: [docker.io, docker-compose, docker-compose-v2, podman-docker, containerd, runc]
  tasks:
    - name: Update packages without automatic reboot or distribution upgrade
      ansible.builtin.apt:
        update_cache: true
        cache_valid_time: 3600
        upgrade: safe
        lock_timeout: 300
    - name: Install bootstrap dependencies
      ansible.builtin.apt:
        name: [ca-certificates, curl, git, make, ufw, openssh-server, python3]
        state: present
        lock_timeout: 300
    - name: Create unprivileged service account
      ansible.builtin.user:
        name: llmops
        create_home: true
        shell: /bin/bash
        password_lock: true
        groups: ""
        append: false
    - name: Protect service home
      ansible.builtin.file:
        path: /home/llmops
        state: directory
        owner: llmops
        group: llmops
        mode: '0700'
    - name: Install only the supplied public key for the service account
      ansible.posix.authorized_key:
        user: llmops
        key: "{{ llmops_ssh_public_key }}"
        exclusive: true
        manage_dir: true
    - name: Configure SSH without changing existing administrator authorized keys
      ansible.builtin.copy:
        dest: /etc/ssh/sshd_config.d/00-llmops-key-only.conf
        owner: root
        group: root
        mode: '0644'
        content: |
          PubkeyAuthentication yes
          PasswordAuthentication no
          KbdInteractiveAuthentication no
          PermitRootLogin prohibit-password
          X11Forwarding no
      notify: Validate and reload SSH
    - name: Inspect effective SSH settings before reloading
      ansible.builtin.command: /usr/sbin/sshd -T
      register: effective_sshd
      changed_when: false
    - name: Refuse conflicting SSH settings in older configuration files
      ansible.builtin.assert:
        that:
          - "'passwordauthentication no' in effective_sshd.stdout_lines"
          - "'kbdinteractiveauthentication no' in effective_sshd.stdout_lines"
          - "'pubkeyauthentication yes' in effective_sshd.stdout_lines"
          - "'port 22' in effective_sshd.stdout_lines"
        fail_msg: "Existing sshd configuration overrides the drop-in. Review manually before reload."
    - name: Create Docker keyring directory
      ansible.builtin.file:
        path: /etc/apt/keyrings
        state: directory
        mode: '0755'
    - name: Download pinned official Docker signing key
      ansible.builtin.get_url:
        url: https://download.docker.com/linux/ubuntu/gpg
        dest: /etc/apt/keyrings/docker.asc
        checksum: "sha256:{{ docker_key_sha256 }}"
        mode: '0644'
    - name: Configure signed Docker repository
      ansible.builtin.apt_repository:
        repo: "deb [arch={{ docker_architectures[ansible_architecture] }} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable"
        filename: docker
        state: present
    - name: Install Docker and Compose plugin
      ansible.builtin.apt:
        name: [docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, docker-compose-plugin]
        state: present
        lock_timeout: 300
    - name: Enable Docker without granting llmops socket access
      ansible.builtin.systemd_service:
        name: docker
        enabled: true
        state: started
    - name: Inspect existing firewall rules without changing them
      ansible.builtin.command: ufw show added
      register: existing_ufw
      changed_when: false
    - name: Refuse unexpected pre-existing firewall rules
      ansible.builtin.assert:
        that:
          - "item in ['ufw allow 22/tcp', 'ufw allow 80/tcp', 'ufw allow 443/tcp']"
        fail_msg: "Existing firewall rules need a separate migration; no reset performed."
      loop: "{{ existing_ufw.stdout_lines | select('match', '^ufw ') | list }}"
    - name: Permit bootstrap TCP ports before enabling firewall
      community.general.ufw:
        rule: allow
        port: "{{ item }}"
        proto: tcp
      loop: ['22', '80', '443']
    - name: Deny unsolicited incoming traffic
      community.general.ufw:
        direction: incoming
        policy: deny
    - name: Enable firewall without resetting existing rules
      community.general.ufw:
        state: enabled
  handlers:
    - name: Validate and reload SSH
      ansible.builtin.command: /usr/sbin/sshd -t
      changed_when: false
      notify: Reload SSH
    - name: Reload SSH
      ansible.builtin.systemd_service:
        name: ssh
        state: reloaded
```

### ansible/requirements.yml

[Quelldatei](../ansible/requirements.yml)

```yaml
---
collections:
  - name: ansible.posix
    version: 2.0.0
  - name: community.general
    version: 10.4.0
```

### ansible/inventory.example.ini

[Quelldatei](../ansible/inventory.example.ini)

```ini
[vps]
# Use a working bootstrap administrator, not the new application user.
vps.example.invalid ansible_user=ubuntu
```

## 2. Kubernetes-Baseline

Kustomize trennt CPU-Basis und GPU-Produktion. Interne Services, Ressourcenbudgets und Default-Deny
begrenzen den Zugriff. Traefik/cert-manager bleiben bewusst separat versionierte
Plattformvoraussetzungen.

### k8s/base/kustomization.yml

[Quelldatei](../k8s/base/kustomization.yml)

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: llmops
resources:
  - namespace.yml
  - ollama.yml
  - litellm.yml
  - network-policy.yml
# Replace with reviewed image digests in a private deployment overlay.
images:
  - name: ollama-runtime
    newName: registry.example.invalid/ollama
    newTag: REPLACE_WITH_REVIEWED_PIN
  - name: litellm-runtime
    newName: registry.example.invalid/litellm
    newTag: REPLACE_WITH_REVIEWED_PIN
```

### k8s/base/namespace.yml

[Quelldatei](../k8s/base/namespace.yml)

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: llmops
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: llmops-budget
spec:
  hard:
    requests.cpu: '8'
    requests.memory: 24Gi
    limits.cpu: '16'
    limits.memory: 48Gi
    requests.storage: 100Gi
    persistentvolumeclaims: '2'
    pods: '8'
---
apiVersion: v1
kind: LimitRange
metadata:
  name: container-defaults
spec:
  limits:
    - type: Container
      defaultRequest:
        cpu: 100m
        memory: 128Mi
        ephemeral-storage: 256Mi
      default:
        cpu: '1'
        memory: 1Gi
        ephemeral-storage: 2Gi
```

### k8s/base/ollama.yml

[Quelldatei](../k8s/base/ollama.yml)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ollama-headless
spec:
  clusterIP: None
  selector:
    app: ollama
  ports:
    - name: http
      port: 11434
---
apiVersion: v1
kind: Service
metadata:
  name: ollama
spec:
  selector:
    app: ollama
  ports:
    - name: http
      port: 11434
      targetPort: http
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: ollama
spec:
  serviceName: ollama-headless
  replicas: 1
  selector:
    matchLabels:
      app: ollama
  template:
    metadata:
      labels:
        app: ollama
    spec:
      automountServiceAccountToken: false
      terminationGracePeriodSeconds: 120
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
          image: ollama-runtime
          args: [serve]
          ports:
            - name: http
              containerPort: 11434
          env:
            - {name: HOME, value: /data}
            - {name: OLLAMA_MODELS, value: /data/models}
            - {name: OLLAMA_HOST, value: '0.0.0.0:11434'}
            - {name: OLLAMA_CONTEXT_LENGTH, value: '4096'}
            - {name: OLLAMA_NUM_PARALLEL, value: '1'}
            - {name: OLLAMA_MAX_LOADED_MODELS, value: '1'}
            - {name: OLLAMA_MAX_QUEUE, value: '16'}
            - {name: OLLAMA_KEEP_ALIVE, value: 5m}
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop: [ALL]
          resources:
            requests: {cpu: '1', memory: 2Gi, ephemeral-storage: 256Mi}
            limits: {cpu: '4', memory: 8Gi, ephemeral-storage: 2Gi}
          startupProbe:
            httpGet: {path: /api/version, port: http}
            periodSeconds: 10
            failureThreshold: 60
          readinessProbe:
            httpGet: {path: /api/version, port: http}
            periodSeconds: 10
          livenessProbe:
            httpGet: {path: /api/version, port: http}
            periodSeconds: 30
            failureThreshold: 5
          volumeMounts:
            - {name: models, mountPath: /data}
            - {name: tmp, mountPath: /tmp}
      volumes:
        - name: tmp
          emptyDir: {sizeLimit: 1Gi}
  volumeClaimTemplates:
    - metadata:
        name: models
      spec:
        accessModes: [ReadWriteOnce]
        resources:
          requests:
            storage: 50Gi
```

### k8s/base/litellm.yml

[Quelldatei](../k8s/base/litellm.yml)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: litellm-config
data:
  config.yaml: |
    model_list:
      - model_name: local-default
        litellm_params:
          model: os.environ/LITELLM_OLLAMA_MODEL
          api_base: os.environ/OLLAMA_API_BASE
    general_settings:
      master_key: os.environ/LITELLM_MASTER_KEY
    litellm_settings:
      callbacks: [prometheus]
      set_verbose: false
    router_settings:
      num_retries: 0
      timeout: 120
---
apiVersion: v1
kind: Service
metadata:
  name: litellm
spec:
  selector:
    app: litellm
  ports:
    - {name: http, port: 4000, targetPort: http}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: litellm
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: litellm
  template:
    metadata:
      labels:
        app: litellm
    spec:
      automountServiceAccountToken: false
      securityContext:
        runAsNonRoot: true
        runAsUser: 10001
        runAsGroup: 10001
        fsGroup: 10001
        seccompProfile: {type: RuntimeDefault}
      containers:
        - name: litellm
          image: litellm-runtime
          args: [--config, /etc/litellm/config.yaml, --port, '4000', --num_workers, '1']
          ports:
            - {name: http, containerPort: 4000}
          env:
            - {name: HOME, value: /tmp}
            - {name: OLLAMA_API_BASE, value: 'http://ollama:11434'}
            # This model must already be present; deployment never downloads models.
            - {name: LITELLM_OLLAMA_MODEL, value: 'ollama/REPLACE_WITH_INSTALLED_MODEL'}
            - name: LITELLM_MASTER_KEY
              valueFrom:
                secretKeyRef: {name: litellm-runtime, key: master-key}
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities: {drop: [ALL]}
          resources:
            requests: {cpu: 250m, memory: 512Mi, ephemeral-storage: 256Mi}
            limits: {cpu: '2', memory: 2Gi, ephemeral-storage: 1Gi}
          startupProbe:
            httpGet: {path: /health/liveliness, port: http}
            failureThreshold: 30
            periodSeconds: 10
          readinessProbe:
            httpGet: {path: /health/readiness, port: http}
            periodSeconds: 10
          livenessProbe:
            httpGet: {path: /health/liveliness, port: http}
            periodSeconds: 30
          volumeMounts:
            - {name: config, mountPath: /etc/litellm, readOnly: true}
            - {name: tmp, mountPath: /tmp}
      volumes:
        - name: config
          configMap: {name: litellm-config}
        - name: tmp
          emptyDir: {sizeLimit: 512Mi}
```

### k8s/base/network-policy.yml

[Quelldatei](../k8s/base/network-policy.yml)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes: [Ingress, Egress]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
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
metadata:
  name: litellm-to-ollama
spec:
  podSelector:
    matchLabels: {app: litellm}
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
metadata:
  name: ollama-from-litellm
spec:
  podSelector:
    matchLabels: {app: ollama}
  policyTypes: [Ingress]
  ingress:
    - from:
        - podSelector:
            matchLabels: {app: litellm}
      ports:
        - {protocol: TCP, port: 11434}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: gateway-and-monitoring-to-litellm
spec:
  podSelector:
    matchLabels: {app: litellm}
  policyTypes: [Ingress]
  ingress:
    - from:
        - namespaceSelector:
            matchLabels: {kubernetes.io/metadata.name: traefik}
          podSelector:
            matchLabels: {app.kubernetes.io/name: traefik}
        - namespaceSelector:
            matchLabels: {kubernetes.io/metadata.name: monitoring}
          podSelector:
            matchLabels: {app.kubernetes.io/name: prometheus}
      ports:
        - {protocol: TCP, port: 4000}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-acme-solver
spec:
  podSelector:
    matchLabels: {acme.cert-manager.io/http01-solver: 'true'}
  policyTypes: [Ingress]
  ingress:
    - from:
        - namespaceSelector:
            matchLabels: {kubernetes.io/metadata.name: traefik}
          podSelector:
            matchLabels: {app.kubernetes.io/name: traefik}
      ports:
        - {protocol: TCP, port: 8089}
```

### k8s/overlays/production/kustomization.yml

[Quelldatei](../k8s/overlays/production/kustomization.yml)

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
  - ingress.yml
  - issuer.yml
replicas:
  - name: ollama
    count: 1
  - name: litellm
    count: 1
patches:
  - path: resources.yml
```

### k8s/overlays/production/resources.yml

[Quelldatei](../k8s/overlays/production/resources.yml)

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: ollama
  namespace: llmops
spec:
  template:
    spec:
      nodeSelector:
        llmops.example/gpu: 'true'
      containers:
        - name: ollama
          resources:
            requests:
              cpu: '2'
              memory: 8Gi
              ephemeral-storage: 512Mi
              nvidia.com/gpu: 1
            limits:
              cpu: '8'
              memory: 16Gi
              ephemeral-storage: 4Gi
              nvidia.com/gpu: 1
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: litellm
  namespace: llmops
spec:
  template:
    spec:
      containers:
        - name: litellm
          resources:
            requests: {cpu: 500m, memory: 1Gi, ephemeral-storage: 256Mi}
            limits: {cpu: '2', memory: 4Gi, ephemeral-storage: 1Gi}
```

### k8s/overlays/production/ingress.yml

[Quelldatei](../k8s/overlays/production/ingress.yml)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: litellm
  namespace: llmops
  annotations:
    cert-manager.io/issuer: letsencrypt-production
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.tls: 'true'
    traefik.ingress.kubernetes.io/router.middlewares: llmops-api-boundary@kubernetescrd
spec:
  ingressClassName: traefik
  tls:
    - hosts: [llm.example.invalid]
      secretName: litellm-tls
  rules:
    - host: llm.example.invalid
      http:
        paths:
          - path: /v1
            pathType: Prefix
            backend:
              service:
                name: litellm
                port: {number: 4000}
---
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: api-boundary
  namespace: llmops
spec:
  ipAllowList:
    # Replace with the actual VPN client CIDR; never trust arbitrary forwarded headers.
    sourceRange: [10.44.0.0/24]
```

### k8s/overlays/production/issuer.yml

[Quelldatei](../k8s/overlays/production/issuer.yml)

```yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-production
  namespace: llmops
spec:
  acme:
    email: operator@example.invalid
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-account
    solvers:
      - http01:
          ingress:
            ingressClassName: traefik
```

### k8s/platform/traefik-values.yml

[Quelldatei](../k8s/platform/traefik-values.yml)

```yaml
# Install separately into namespace traefik; do not duplicate K3s's bundled controller.
deployment:
  replicas: 2
ingressClass:
  enabled: true
  isDefaultClass: false
providers:
  kubernetesCRD:
    enabled: true
    allowCrossNamespace: false
  kubernetesIngress:
    enabled: true
api:
  dashboard: false
ingressRoute:
  dashboard:
    enabled: false
ports:
  # HTTP is reserved for cert-manager challenges; the API ingress uses websecure.
  websecure:
    tls:
      enabled: true
service:
  spec:
    externalTrafficPolicy: Local
resources:
  requests: {cpu: 100m, memory: 128Mi}
  limits: {cpu: '1', memory: 512Mi}
securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities: {drop: [ALL], add: [NET_BIND_SERVICE]}
```

## 3. Observability

Prometheus/Grafana und Loki/Alloy sind vom Anwendungssystem getrennt. Alloy ersetzt das abgekundigte
Promtail. Tokenmetriken stammen von LiteLLM; ein nativer Ollama-Metrics-Endpunkt wird nicht
vorgetaeuscht.

### docker-compose.monitoring.yml

[Quelldatei](../docker-compose.monitoring.yml)

```yaml
name: llmops-monitoring
# Reviewed digests are mandatory. Never start this with floating latest tags.
x-restricted: &restricted
  restart: unless-stopped
  read_only: true
  cap_drop: [ALL]
  security_opt: [no-new-privileges:true]
  pids_limit: 128
  logging:
    driver: json-file
    options: {max-size: 10m, max-file: '3'}
services:
  prometheus:
    <<: *restricted
    image: ${PROMETHEUS_IMAGE:?Set reviewed image@sha256 digest}
    user: '65534:65534'
    command:
      - --config.file=/etc/prometheus/prometheus.yml
      - --storage.tsdb.path=/prometheus
      - --storage.tsdb.retention.time=7d
      - --storage.tsdb.retention.size=2GB
    ports: ['127.0.0.1:9091:9090']
    extra_hosts: ['host.docker.internal:host-gateway']
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./monitoring/alerts.yml:/etc/prometheus/alerts.yml:ro
      - ./monitoring/ollama-metrics.targets.json:/etc/prometheus/ollama-metrics.targets.json:ro
      - prometheus-data:/prometheus
    secrets: [litellm-metrics-token]
    networks: [telemetry, scrape]
    mem_limit: 1g
    cpus: 1
  grafana:
    <<: *restricted
    image: ${GRAFANA_IMAGE:?Set reviewed image@sha256 digest}
    user: '472:472'
    environment:
      GF_SECURITY_ADMIN_PASSWORD__FILE: /run/secrets/grafana-admin-password
      GF_AUTH_ANONYMOUS_ENABLED: 'false'
      GF_USERS_ALLOW_SIGN_UP: 'false'
      GF_ANALYTICS_REPORTING_ENABLED: 'false'
      GF_ANALYTICS_CHECK_FOR_UPDATES: 'false'
      GF_SECURITY_COOKIE_SAMESITE: strict
    ports: ['127.0.0.1:3030:3000']
    volumes:
      - grafana-data:/var/lib/grafana
      - ./monitoring/grafana/provisioning:/etc/grafana/provisioning:ro
      - ./monitoring/grafana/dashboards:/var/lib/grafana/dashboards:ro
    tmpfs: [/tmp:size=64m,mode=1777]
    secrets: [grafana-admin-password]
    networks: [telemetry]
    mem_limit: 512m
    cpus: 1
  loki:
    <<: *restricted
    image: ${LOKI_IMAGE:?Set reviewed image@sha256 digest}
    user: '10001:10001'
    command: [-config.file=/etc/loki/config.yml]
    volumes:
      - ./monitoring/loki.yml:/etc/loki/config.yml:ro
      - loki-data:/loki
    networks: [telemetry]
    mem_limit: 1g
    cpus: 1
  alloy:
    <<: *restricted
    image: ${ALLOY_IMAGE:?Set reviewed image@sha256 digest}
    user: '10001:10001'
    command: [run, --storage.path=/var/lib/alloy, /etc/alloy/config.alloy]
    volumes:
      - ./monitoring/config.alloy:/etc/alloy/config.alloy:ro
      - ${LLMOPS_LOG_DIR:?Set dedicated redacted log directory}:/var/log/llmops:ro
      - alloy-data:/var/lib/alloy
    networks: [telemetry]
    mem_limit: 256m
    cpus: 0.5
  node-exporter:
    <<: *restricted
    image: ${NODE_EXPORTER_IMAGE:?Set reviewed image@sha256 digest}
    profiles: [host-metrics]
    user: '65534:65534'
    command:
      - --path.procfs=/host/proc
      - --path.sysfs=/host/sys
      - --path.rootfs=/host/root
      - --collector.filesystem.mount-points-exclude=^/(dev|proc|sys|var/lib/docker)($|/)
    # No rslave propagation: it fails on some WSL root mounts.
    volumes: ['/proc:/host/proc:ro', '/sys:/host/sys:ro', '/:/host/root:ro']
    networks: [telemetry]
    mem_limit: 128m
    cpus: 0.5
networks:
  telemetry:
    internal: true
  # Only Prometheus may reach the selected external/private scrape target.
  scrape: {}
volumes:
  prometheus-data: {}
  grafana-data: {}
  loki-data: {}
  alloy-data: {}
secrets:
  grafana-admin-password:
    file: ${MONITORING_SECRET_DIR:?Set protected external secret directory}/grafana-admin-password
  litellm-metrics-token:
    file: ${MONITORING_SECRET_DIR:?Set protected external secret directory}/litellm-metrics-token
```

### monitoring/.env.example

[Quelldatei](../monitoring/.env.example)

```dotenv
# Keep the real env file outside the repository. Values below deliberately cannot deploy.
PROMETHEUS_IMAGE=prom/prometheus@sha256:REPLACE
GRAFANA_IMAGE=grafana/grafana@sha256:REPLACE
LOKI_IMAGE=grafana/loki@sha256:REPLACE
ALLOY_IMAGE=grafana/alloy@sha256:REPLACE
NODE_EXPORTER_IMAGE=prom/node-exporter@sha256:REPLACE
MONITORING_SECRET_DIR=/etc/llmops/monitoring-secrets
LLMOPS_LOG_DIR=/var/log/llmops-redacted
```

### monitoring/prometheus.yml

[Quelldatei](../monitoring/prometheus.yml)

```yaml
global:
  scrape_interval: 30s
  scrape_timeout: 10s
rule_files: [/etc/prometheus/alerts.yml]
scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']
  - job_name: litellm
    metrics_path: /metrics
    authorization:
      type: Bearer
      credentials_file: /run/secrets/litellm-metrics-token
    static_configs:
      # Must be a reachable private listener, not a host-only loopback binding.
      - targets: ['REPLACE_PRIVATE_LITELLM_ADDRESS:4000']
  - job_name: node
    static_configs:
      - targets: ['node-exporter:9100']
  - job_name: ollama-exporter
    metrics_path: /metrics
    # Empty until an independently verified exporter is installed. Ollama itself
    # is not assumed to expose Prometheus metrics on port 11434.
    file_sd_configs:
      - files: [/etc/prometheus/ollama-metrics.targets.json]
```

### monitoring/ollama-metrics.targets.json

[Quelldatei](../monitoring/ollama-metrics.targets.json)

```json
[]
```

### monitoring/alerts.yml

[Quelldatei](../monitoring/alerts.yml)

```yaml
groups:
  - name: llmops-baseline
    rules:
      - alert: ScrapeTargetUnavailable
        expr: up == 0
        for: 5m
        labels: {severity: warning}
        annotations:
          summary: 'Target {{ $labels.job }} unavailable'
      - alert: HostDiskNearlyFull
        expr: node_filesystem_avail_bytes{fstype!~"tmpfs|overlay|squashfs"} / node_filesystem_size_bytes < 0.1
        for: 10m
        labels: {severity: critical}
        annotations:
          summary: 'Less than 10 percent filesystem capacity available'
      - alert: HostMemoryPressure
        expr: node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.1
        for: 10m
        labels: {severity: warning}
        annotations:
          summary: 'Less than 10 percent RAM available'
```

### monitoring/loki.yml

[Quelldatei](../monitoring/loki.yml)

```yaml
auth_enabled: false
server:
  http_listen_port: 3100
common:
  path_prefix: /loki
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory
  storage:
    filesystem:
      chunks_directory: /loki/chunks
      rules_directory: /loki/rules
schema_config:
  configs:
    - from: '2024-01-01'
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h
compactor:
  working_directory: /loki/compactor
  retention_enabled: true
  delete_request_store: filesystem
limits_config:
  retention_period: 168h
  ingestion_rate_mb: 2
  ingestion_burst_size_mb: 4
analytics:
  reporting_enabled: false
```

### monitoring/config.alloy

[Quelldatei](../monitoring/config.alloy)

```hcl
// Read only operator-selected, already redacted logs. Never mount docker.sock.
logging {
  level = "warn"
}
local.file_match "services" {
  path_targets = [
    {"__path__" = "/var/log/llmops/openclaw/*.log", "service" = "openclaw"},
    {"__path__" = "/var/log/llmops/litellm/*.log", "service" = "litellm"},
  ]
}
loki.source.file "services" {
  targets    = local.file_match.services.targets
  forward_to = [loki.write.local.receiver]
}
loki.write "local" {
  endpoint {
    url = "http://loki:3100/loki/api/v1/push"
  }
}
```

### monitoring/grafana/provisioning/datasources/default.yml

[Quelldatei](../monitoring/grafana/provisioning/datasources/default.yml)

```yaml
apiVersion: 1
datasources:
  - name: Prometheus
    uid: prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false
  - name: Loki
    uid: loki
    type: loki
    access: proxy
    url: http://loki:3100
    editable: false
```

### monitoring/grafana/provisioning/dashboards/default.yml

[Quelldatei](../monitoring/grafana/provisioning/dashboards/default.yml)

```yaml
apiVersion: 1
providers:
  - name: llmops
    orgId: 1
    folder: LLMOps
    type: file
    disableDeletion: true
    editable: false
    options:
      path: /var/lib/grafana/dashboards
```

### monitoring/grafana/dashboards/llmops.json

[Quelldatei](../monitoring/grafana/dashboards/llmops.json)

```json
{
  "uid": "llmops-baseline",
  "title": "LLMOps: Gateway und Host",
  "schemaVersion": 39,
  "version": 1,
  "refresh": "30s",
  "time": {"from": "now-1h", "to": "now"},
  "panels": [
    {"id": 1, "title": "Tokens/s (LiteLLM, nur Gateway-Traffic)", "type": "timeseries", "datasource": {"type": "prometheus", "uid": "prometheus"}, "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}, "targets": [{"refId": "A", "expr": "sum(rate(litellm_total_tokens_metric_total[5m]))"}]},
    {"id": 2, "title": "CPU ausgelastet (%)", "type": "timeseries", "datasource": {"type": "prometheus", "uid": "prometheus"}, "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}, "targets": [{"refId": "A", "expr": "100 * (1 - avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])))"}]},
    {"id": 3, "title": "RAM verfuegbar (Bytes)", "type": "timeseries", "datasource": {"type": "prometheus", "uid": "prometheus"}, "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8}, "targets": [{"refId": "A", "expr": "node_memory_MemAvailable_bytes"}]},
    {"id": 4, "title": "Dateisystem frei (Bytes)", "type": "timeseries", "datasource": {"type": "prometheus", "uid": "prometheus"}, "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8}, "targets": [{"refId": "A", "expr": "node_filesystem_avail_bytes{fstype!~\"tmpfs|overlay|squashfs\"}"}]}
  ]
}
```

## 4. Secrets und Backups

SOPS benoetigt den echten oeffentlichen age-Empfaenger. Restic sichert validierte Daten-Mounts nur
im freigegebenen Wartungsfenster; kein Kopieren laufender Datenbanken und kein automatisches
Loeschen.

### .sops.yaml

[Quelldatei](../.sops.yaml)

```yaml
# Replace with your PUBLIC age recipient; this deliberately fails until configured.
# Keep the private age identity outside Git and outside ordinary state backups.
creation_rules:
  - path_regex: '(^|/)secrets\.enc\.ya?ml$'
    encrypted_regex: '^(data|stringData)$'
    age: age1REPLACE_WITH_YOUR_PUBLIC_RECIPIENT
```

### k8s/secrets.template.yml

[Quelldatei](../k8s/secrets.template.yml)

```yaml
# Template only. Encrypt real values outside the checkout, never commit plaintext.
apiVersion: v1
kind: Secret
metadata:
  name: litellm-runtime
  namespace: llmops
type: Opaque
stringData:
  master-key: REPLACE_WITH_RANDOM_MASTER_KEY
  # Reserved for a future shared-state deployment, not wired into the single proxy.
  database-password: REPLACE_WITH_RANDOM_DATABASE_PASSWORD
```

### scripts/backup_stateful_services.sh

[Quelldatei](../scripts/backup_stateful_services.sh)

```bash
#!/usr/bin/env bash
# Offline Compose volume backup. Explicit maintenance approval is mandatory.
set -euo pipefail
umask 077

die() { printf 'Backup abgebrochen: %s\n' "$*" >&2; exit 1; }
usage() { printf 'Nutzung: bash %s /absolut/backup.env [--dry-run|--run]\n' "$0"; }
[[ $# -ge 1 && $# -le 2 ]] || { usage; exit 2; }
env_file=$1
mode=${2:---dry-run}
[[ "$mode" == --run || "$mode" == --dry-run ]] || { usage; exit 2; }
[[ "$env_file" == /* && -f "$env_file" && ! -L "$env_file" ]] || die 'Absolute regulaere env-Datei erforderlich.'

secure_file() {
  local file=$1 owner permissions
  [[ -f "$file" && ! -L "$file" ]] || die 'Secret-Datei fehlt oder ist ein Symlink.'
  owner=$(stat -c %u -- "$file")
  permissions=$(stat -c %a -- "$file")
  [[ "$owner" == "$EUID" && "$permissions" == 600 ]] || die 'Secret-Dateien muessen dem ausfuehrenden Benutzer gehoeren und Modus 0600 haben.'
}
secure_file "$env_file"
unset RESTIC_REPOSITORY RESTIC_PASSWORD_FILE AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_DEFAULT_REGION
unset COMPOSE_FILE QDRANT_DATA_DIR POSTGRES_DATA_DIR MINIO_DATA_DIR BACKUP_LOCK_DIR BACKUP_ALLOW_DOWNTIME BACKUP_TARGET_IS_EXTERNAL

# Parse literal KEY=VALUE entries. No source, eval, substitutions or shell expansion.
while IFS= read -r line || [[ -n "$line" ]]; do
  line=${line%$'\r'}
  [[ -z "$line" || "$line" == \#* ]] && continue
  [[ "$line" == *=* ]] || die 'Ungueltige env-Zeile.'
  key=${line%%=*}
  value=${line#*=}
  case "$key" in
    RESTIC_REPOSITORY|RESTIC_PASSWORD_FILE|AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY|AWS_SESSION_TOKEN|AWS_DEFAULT_REGION|COMPOSE_FILE|QDRANT_DATA_DIR|POSTGRES_DATA_DIR|MINIO_DATA_DIR|BACKUP_LOCK_DIR|BACKUP_ALLOW_DOWNTIME|BACKUP_TARGET_IS_EXTERNAL) ;;
    *) die 'Nicht erlaubter Variablenname in env-Datei.' ;;
  esac
  if [[ "$value" == \"*\" || "$value" == \'*\' ]]; then
    value=${value:1:${#value}-2}
  fi
  printf -v "$key" '%s' "$value"
  export "$key"
done < "$env_file"

for key in RESTIC_REPOSITORY RESTIC_PASSWORD_FILE COMPOSE_FILE QDRANT_DATA_DIR POSTGRES_DATA_DIR MINIO_DATA_DIR BACKUP_LOCK_DIR; do
  [[ -n ${!key:-} ]] || die "Pflichtvariable fehlt: $key"
done
[[ "$RESTIC_REPOSITORY" == s3:https://* ]] || die 'Externes S3-Ziel mit HTTPS erforderlich.'
[[ ! "$RESTIC_REPOSITORY" =~ ^s3:https://(localhost|127\.[0-9.]+|\[::1\]|minio)(:|/) ]] || die 'Primaeres/lokales MinIO ist kein separates Backup-Ziel.'
[[ ${BACKUP_TARGET_IS_EXTERNAL:-0} == 1 ]] || die 'Separates Backup-Ziel muss bestaetigt werden; nicht das zu stoppende MinIO verwenden.'
[[ "$RESTIC_PASSWORD_FILE" == /* ]] || die 'Absoluter Passwortdateipfad erforderlich.'
secure_file "$RESTIC_PASSWORD_FILE"
[[ "$COMPOSE_FILE" == /* && -f "$COMPOSE_FILE" && ! -L "$COMPOSE_FILE" ]] || die 'Absolute Compose-Datei erforderlich.'
for key in QDRANT_DATA_DIR POSTGRES_DATA_DIR MINIO_DATA_DIR; do
  value=${!key}
  [[ "$value" == /* && "$value" != / && -d "$value" && ! -L "$value" ]] || die "Ungueltiges Datenverzeichnis: $key"
  printf -v "$key" '%s' "$(realpath -e -- "$value")"
done
[[ "$QDRANT_DATA_DIR" != "$POSTGRES_DATA_DIR" && "$QDRANT_DATA_DIR" != "$MINIO_DATA_DIR" && "$POSTGRES_DATA_DIR" != "$MINIO_DATA_DIR" ]] || die 'Datenpfade muessen verschieden sein.'
[[ ! -L "$POSTGRES_DATA_DIR/pg_wal" ]] || die 'Externes PostgreSQL-WAL erfordert einen erweiterten Backup-Plan.'
if [[ -d "$POSTGRES_DATA_DIR/pg_tblspc" ]]; then
  [[ -z $(find "$POSTGRES_DATA_DIR/pg_tblspc" -mindepth 1 -maxdepth 1 -print -quit) ]] || die 'Externe PostgreSQL-Tablespaces werden nicht implizit gesichert.'
fi
[[ "$BACKUP_LOCK_DIR" == /* && -d "$BACKUP_LOCK_DIR" && ! -L "$BACKUP_LOCK_DIR" ]] || die 'Eigenes vorab angelegtes Lock-Verzeichnis erforderlich.'
[[ $(stat -c %u -- "$BACKUP_LOCK_DIR") == "$EUID" && $(stat -c %a -- "$BACKUP_LOCK_DIR") == 700 ]] || die 'Lock-Verzeichnis muss eigen und 0700 sein.'

if [[ "$mode" == --dry-run ]]; then
  printf 'Konfiguration lokal geprueft. Keine Docker-/S3-Abfrage, kein Stop, kein Backup ausgefuehrt.\n'
  exit 0
fi
[[ ${BACKUP_ALLOW_DOWNTIME:-0} == 1 ]] || die 'Wartungsfenster mit BACKUP_ALLOW_DOWNTIME=1 freigeben.'
for tool in docker restic flock python3; do command -v "$tool" >/dev/null || die "Werkzeug fehlt: $tool"; done
# Disallow inherited Restic command hooks and alternate credentials/repositories.
unset RESTIC_PASSWORD RESTIC_PASSWORD_COMMAND RESTIC_REPOSITORY_FILE RESTIC_REST_USERNAME RESTIC_REST_PASSWORD
exec 9>"$BACKUP_LOCK_DIR/backup.lock"
flock -n 9 || die 'Ein Backup laeuft bereits.'
compose=(docker compose --file "$COMPOSE_FILE")
services=(postgres minio qdrant)
paths=("$POSTGRES_DATA_DIR" "$MINIO_DATA_DIR" "$QDRANT_DATA_DIR")
destinations=(/var/lib/postgresql/data /data /qdrant/storage)
ids=()
restart_services=()

restore_services() {
  local rc=$?
  trap - EXIT INT TERM
  if ((${#restart_services[@]})); then
    printf 'Stelle zuvor laufende Dienste wieder her.\n'
    if ! "${compose[@]}" start "${restart_services[@]}"; then
      printf 'KRITISCH: Dienststart fehlgeschlagen. Operator muss Dienste pruefen.\n' >&2
      rc=1
    fi
  fi
  exit "$rc"
}
trap restore_services EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Validate actual mounts before stopping anything; never back up arbitrary paths.
for i in "${!services[@]}"; do
  id=$("${compose[@]}" ps --all --quiet "${services[$i]}")
  [[ "$id" =~ ^[a-f0-9]{12,64}$ ]] || die 'Genau ein vorhandener Container je Dienst erforderlich.'
  ids+=("$id")
  mounts=$(docker inspect --format '{{json .Mounts}}' "$id")
  python3 -I -c '
import json, os, sys
mounts = json.loads(sys.argv[1])
matches = [m for m in mounts if m["Destination"] == sys.argv[3]]
if len(matches) != 1 or os.path.realpath(matches[0]["Source"]) != sys.argv[2]:
    raise SystemExit("Backup-Pfad stimmt nicht mit dem Container-Mount ueberein.")
if any(m.get("RW", True) and m.get("Type") in ("bind", "volume")
       and m["Destination"] != sys.argv[3] for m in mounts):
    raise SystemExit("Weitere beschreibbare Mounts erfordern einen erweiterten Backup-Plan.")
' "$mounts" "${paths[$i]}" "${destinations[$i]}"
done

# Check repository access before entering the maintenance window. No automatic init.
restic cat config >/dev/null
for i in "${!services[@]}"; do
  running=$(docker inspect --format '{{.State.Running}}' "${ids[$i]}")
  if [[ "$running" == true ]]; then
    # Register before stop, so an interrupted stop is also recovered by the trap.
    restart_services+=("${services[$i]}")
    "${compose[@]}" stop --timeout 120 "${services[$i]}"
  fi
done
for id in "${ids[@]}"; do
  state=$(docker inspect --format '{{.State.Running}} {{.State.ExitCode}}' "$id")
  [[ "$state" == 'false 0' || "$state" == 'false 143' ]] || die 'Container nicht sauber gestoppt; kein Backup inkonsistenter Dateien.'
done
printf 'Alle drei Datendienste gestoppt; starte verschluesseltes Restic-Backup.\n'
# Exit codes including incomplete reads (3) and storage failures remain failures.
restic backup --tag llmops-offline -- "${paths[@]}"
printf 'Backup erfolgreich. Restore-Probe und restic check separat durchfuehren.\n'
```

### monitoring/backup.env.example

[Quelldatei](../monitoring/backup.env.example)

```dotenv
# Real file: outside Git, owned by backup operator, chmod 0600. Literal values only.
RESTIC_REPOSITORY=s3:https://s3.example.invalid/separate-backup-bucket/llmops
RESTIC_PASSWORD_FILE=/etc/llmops/restic-password
AWS_ACCESS_KEY_ID=REPLACE
AWS_SECRET_ACCESS_KEY=REPLACE
AWS_DEFAULT_REGION=us-east-1
COMPOSE_FILE=/srv/llmops/stacks/llmops-platform/docker-compose.yml
POSTGRES_DATA_DIR=/srv/llmops/stacks/llmops-platform/data/postgres
MINIO_DATA_DIR=/srv/llmops/stacks/llmops-platform/data/minio
QDRANT_DATA_DIR=/srv/llmops/stacks/llmops-platform/data/qdrant
BACKUP_LOCK_DIR=/var/lib/llmops-backup
BACKUP_ALLOW_DOWNTIME=0
BACKUP_TARGET_IS_EXTERNAL=0
```

## 5. CI/CD und Offline-Pruefung

Bats prueft echte Skripte anhand isolierter Fixtures, Trivy scannt Dateien mit hartem Fehlerstatus.
Die Vorpruefung lehnt Platzhalter und Images ohne Digest ab.

### .github/workflows/test-install-scripts.yml

[Quelldatei](../.github/workflows/test-install-scripts.yml)

```yaml
name: Install scripts and production baseline
on:
  pull_request:
  push:
    branches: [main]
  workflow_dispatch:
permissions:
  contents: read
concurrency:
  group: install-tests-${{ github.ref }}
  cancel-in-progress: true
jobs:
  offline-tests:
    runs-on: ubuntu-24.04
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@11d5960a326750d5838078e36cf38b85af677262
        with:
          persist-credentials: false
      - uses: actions/setup-python@a26af69be951a213d495a4c3e4e4022e16d87065
        with:
          python-version: '3.12'
      - name: Get pinned Bats from its official GitHub repository
        shell: bash
        run: |
          set -euo pipefail
          git init "$RUNNER_TEMP/bats"
          git -C "$RUNNER_TEMP/bats" remote add origin https://github.com/bats-core/bats-core.git
          git -C "$RUNNER_TEMP/bats" fetch --depth=1 origin b640ec3cf2c7c9cfc9e6351479261186f76eeec8
          git -C "$RUNNER_TEMP/bats" checkout --detach FETCH_HEAD
          test "$(git -C "$RUNNER_TEMP/bats" rev-parse HEAD)" = b640ec3cf2c7c9cfc9e6351479261186f76eeec8
      - name: Parse and exercise the real scripts in isolated fixtures
        shell: bash
        run: |
          set -euo pipefail
          bash -n scripts/backup_stateful_services.sh
          "$RUNNER_TEMP/bats/bin/bats" tests/bats/install_scripts.bats
          python3 -B -m unittest discover -s tests -p test_production_baseline.py -v
      - name: Render Kubernetes objects without accessing a cluster
        shell: bash
        run: |
          set -euo pipefail
          curl --fail --location --proto '=https' --proto-redir '=https' \
            https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.8.3/kustomize_v5.8.3_linux_amd64.tar.gz \
            --output "$RUNNER_TEMP/kustomize.tar.gz"
          printf '%s  %s\n' cb9e31198d3f63b44848bd0afc4c8efc56e6cfef9c93a4a39a211940e6decd61 \
            "$RUNNER_TEMP/kustomize.tar.gz" | sha256sum --check --strict -
          tar -xzf "$RUNNER_TEMP/kustomize.tar.gz" -C "$RUNNER_TEMP" kustomize
          "$RUNNER_TEMP/kustomize" build k8s/base > "$RUNNER_TEMP/llmops-base.yml"
          "$RUNNER_TEMP/kustomize" build k8s/overlays/production > "$RUNNER_TEMP/llmops-production.yml"
  secret-scan:
    runs-on: ubuntu-24.04
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@11d5960a326750d5838078e36cf38b85af677262
        with:
          persist-credentials: false
      - name: Inspect repository files for secrets
        uses: aquasecurity/trivy-action@8f28faec26515256b6d22074d1d2a8986f4cbd87
        with:
          version: v0.76.1
          scan-type: fs
          scan-ref: .
          scanners: secret
          # Report locations and rule IDs only, never matching secret content.
          format: template
          template: '{{ range . }}{{ $target := .Target }}{{ range .Secrets }}{{ printf "%s: %s\n" $target .RuleID }}{{ end }}{{ end }}'
          exit-code: '1'
          hide-progress: 'true'
          cache: 'false'
```

### tests/bats/install_scripts.bats

[Quelldatei](../tests/bats/install_scripts.bats)

```bats
#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  FIXTURE="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$FIXTURE/scripts/quality" "$FIXTURE/config" "$FIXTURE/docs"
  cp "$REPO_ROOT/scripts/check_ports.sh" "$FIXTURE/scripts/"
  cp "$REPO_ROOT/scripts/validate_config.sh" "$FIXTURE/scripts/"
  cp "$REPO_ROOT/scripts/quality/repository_audit.py" "$FIXTURE/scripts/quality/"
  printf 'fixture\n' > "$FIXTURE/install.sh"
  printf 'fixture\n' > "$FIXTURE/uninstall.sh"
  printf 'fixture\n' > "$FIXTURE/docs/tool.md"
  printf '%s\n' '{"tools":[{"id":"example","status":"planned","auto_install":false,"install_script":"install.sh","uninstall_script":"uninstall.sh","doc":"docs/tool.md","check_type":"path","check_value":"marker"}]}' > "$FIXTURE/config/tools.yml"
  printf '%s\n' '{"profiles":[{"id":"Example","status":"planned","doc":"docs/tool.md","tools":["example"]}]}' > "$FIXTURE/config/profiles.yml"
  printf '%s\n' '{"ports":[{"port":1234,"service":"fixture"}]}' > "$FIXTURE/config/ports.yml"
}

@test "both real scripts pass bash syntax parsing" {
  run bash -n "$FIXTURE/scripts/check_ports.sh"
  [ "$status" -eq 0 ]
  run bash -n "$FIXTURE/scripts/validate_config.sh"
  [ "$status" -eq 0 ]
}

@test "port registry accepts unique integer ports without opening sockets" {
  run bash "$FIXTURE/scripts/check_ports.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"keine Doppelbelegung"* ]]
}

@test "duplicate ports fail" {
  printf '%s\n' '{"ports":[{"port":1234},{"port":1234}]}' > "$FIXTURE/config/ports.yml"
  run bash "$FIXTURE/scripts/check_ports.sh"
  [ "$status" -ne 0 ]
  [[ "$output" == *DOPPELT* ]]
}

@test "boolean ports fail instead of being accepted as integers" {
  printf '%s\n' '{"ports":[{"port":true}]}' > "$FIXTURE/config/ports.yml"
  run bash "$FIXTURE/scripts/check_ports.sh"
  [ "$status" -ne 0 ]
}

@test "configuration validation includes the real semantic repository audit" {
  run bash "$FIXTURE/scripts/validate_config.sh"
  [ "$status" -eq 0 ]
}

@test "invalid JSON stops configuration validation" {
  printf 'not-json\n' > "$FIXTURE/config/tools.yml"
  run bash "$FIXTURE/scripts/validate_config.sh"
  [ "$status" -ne 0 ]
  [[ "$output" == *FEHLER* ]]
}

@test "unknown profile tool fails semantic configuration validation" {
  printf '%s\n' '{"profiles":[{"id":"Example","status":"planned","doc":"docs/tool.md","tools":["absent"]}]}' > "$FIXTURE/config/profiles.yml"
  run bash "$FIXTURE/scripts/validate_config.sh"
  [ "$status" -ne 0 ]
}
```

### scripts/quality/production_preflight.py

[Quelldatei](../scripts/quality/production_preflight.py)

```python
#!/usr/bin/env python3
"""Reject incomplete deployment inputs without contacting infrastructure."""
import argparse
from pathlib import Path
import re
import sys

DIGEST = re.compile(r'[^\s@]+@sha256:[a-f0-9]{64}\Z')
IMAGE_KEYS = ('PROMETHEUS_IMAGE', 'GRAFANA_IMAGE', 'LOKI_IMAGE', 'ALLOY_IMAGE', 'NODE_EXPORTER_IMAGE')


def validate_manifest(text):
    if re.search(r'REPLACE|example\.invalid', text):
        raise ValueError('Manifest enthaelt noch Platzhalter.')
    images = re.findall(r'''(?m)^\s*image:\s*["']?([^\s"']+)''', text)
    if not images or any(not DIGEST.fullmatch(image) for image in images):
        raise ValueError('Alle Images muessen mit vollstaendigem sha256-Digest gepinnt sein.')


def validate_monitoring(text):
    values = {}
    for line in text.splitlines():
        if not line or line.startswith('#'):
            continue
        key, separator, value = line.partition('=')
        if not separator or key in values:
            raise ValueError('Ungueltige oder doppelte Monitoring-env-Variable.')
        values[key] = value.strip('"\'')
    if any(not DIGEST.fullmatch(values.get(key, '')) for key in IMAGE_KEYS):
        raise ValueError('Alle Monitoring-Images benoetigen einen sha256-Digest.')
    for key in ('MONITORING_SECRET_DIR', 'LLMOPS_LOG_DIR'):
        if not Path(values.get(key, '')).is_absolute():
            raise ValueError('Absolute Secret- und Log-Verzeichnisse erforderlich.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--monitoring-env', type=Path)
    args = parser.parse_args()
    try:
        if args.monitoring_env:
            validate_monitoring(args.monitoring_env.read_text(encoding='utf-8'))
        else:
            if sys.stdin.isatty():
                parser.error('Gerendertes Manifest ueber stdin uebergeben.')
            validate_manifest(sys.stdin.read())
    except (OSError, ValueError) as error:
        # Never echo manifests, env contents, image references or credentials.
        print(f'Vorpruefung fehlgeschlagen: {type(error).__name__}. Konfiguration/Pins pruefen.', file=sys.stderr)
        return 1
    print('Statische Vorpruefung erfolgreich; keine Deployment-/Cluster-Freigabe.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
```

### tests/test_production_baseline.py

[Quelldatei](../tests/test_production_baseline.py)

```python
"""Offline safety checks; never install a tool or contact a running service."""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest
import importlib.util

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('production_preflight', ROOT / 'scripts/quality/production_preflight.py')
preflight = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(preflight)


class BaselineFiles(unittest.TestCase):
    def test_manifest_preflight_rejects_examples_and_unpinned_images(self):
        for text in ('image: example.invalid/service:REPLACE', 'image: service:latest', 'kind: ConfigMap'):
            with self.assertRaises(ValueError):
                preflight.validate_manifest(text)
        preflight.validate_manifest('image: service@sha256:' + 'a' * 64)

    def test_monitoring_preflight_rejects_the_template(self):
        with self.assertRaises(ValueError):
            preflight.validate_monitoring((ROOT / 'monitoring/.env.example').read_text())

    def test_dashboard_has_real_datasource_and_unique_panel_ids(self):
        dashboard = json.loads((ROOT / 'monitoring/grafana/dashboards/llmops.json').read_text())
        panels = dashboard['panels']
        self.assertEqual(len({p['id'] for p in panels}), len(panels))
        self.assertTrue(all(p['datasource']['uid'] == 'prometheus' for p in panels))
        self.assertIn('litellm_total_tokens_metric_total', panels[0]['targets'][0]['expr'])

    def test_native_ollama_metrics_are_not_invented(self):
        self.assertEqual(json.loads((ROOT / 'monitoring/ollama-metrics.targets.json').read_text()), [])
        prometheus = (ROOT / 'monitoring/prometheus.yml').read_text()
        self.assertNotIn('11434', '\n'.join(l for l in prometheus.splitlines() if not l.lstrip().startswith('#')))
        self.assertIn('credentials_file:', prometheus)

    def test_sops_is_fail_closed_and_does_not_contain_fake_ciphertext(self):
        config = (ROOT / '.sops.yaml').read_text()
        template = (ROOT / 'k8s/secrets.template.yml').read_text()
        self.assertIn('REPLACE_WITH_YOUR_PUBLIC_RECIPIENT', config)
        self.assertNotIn('ENC[AES256_GCM', template)
        self.assertNotIn('secrets.template', (ROOT / 'k8s/base/kustomization.yml').read_text())

    def test_ci_actions_are_pinned_and_secret_scan_is_enforced(self):
        workflow = (ROOT / '.github/workflows/test-install-scripts.yml').read_text()
        actions = re.findall(r'uses: ([^\s]+)', workflow)
        self.assertGreaterEqual(len(actions), 3)
        self.assertTrue(all(re.search(r'@[a-f0-9]{40}$', action) for action in actions))
        self.assertIn('scanners: secret', workflow)
        self.assertIn("exit-code: '1'", workflow)
        self.assertNotIn('continue-on-error', workflow)
        self.assertNotIn('pull_request_target', workflow)

    def test_runtime_boundaries(self):
        for name in ('ollama', 'litellm'):
            text = (ROOT / f'k8s/base/{name}.yml').read_text()
            self.assertIn('runAsNonRoot: true', text)
            self.assertIn('allowPrivilegeEscalation: false', text)
            self.assertIn('readOnlyRootFilesystem: true', text)
            self.assertIn('automountServiceAccountToken: false', text)
            self.assertNotIn('type: LoadBalancer', text)
        compose = (ROOT / 'docker-compose.monitoring.yml').read_text()
        self.assertNotIn('docker.sock', compose)
        self.assertNotIn(':latest', compose)
        self.assertIn('127.0.0.1:3030:3000', compose)


@unittest.skipUnless(os.name == 'posix' and shutil.which('bash') and shutil.which('flock'),
                     'Linux/POSIX mock execution required; runs in Ubuntu CI')
class BackupBehavior(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.work = Path(self.temp.name)
        self.bin = self.work / 'bin'
        self.bin.mkdir()
        self.log = self.work / 'calls'
        self.lock = self.work / 'locks'
        self.lock.mkdir(mode=0o700)
        self.compose = self.work / 'compose.yml'
        self.compose.write_text('services: {}\n')
        self.password = self.work / 'password'
        self.password.write_text('fixture-only\n')
        self.password.chmod(0o600)
        self.dirs = {}
        for name in ('postgres', 'minio', 'qdrant'):
            self.dirs[name] = self.work / name
            self.dirs[name].mkdir()
        self.env_file = self.work / 'backup.env'
        self.entries = {
            'RESTIC_REPOSITORY': 's3:https://backup.example.invalid/bucket',
            'RESTIC_PASSWORD_FILE': str(self.password),
            'COMPOSE_FILE': str(self.compose),
            'BACKUP_LOCK_DIR': str(self.lock),
            'BACKUP_TARGET_IS_EXTERNAL': '1',
            'BACKUP_ALLOW_DOWNTIME': '1',
            **{f'{name.upper()}_DATA_DIR': str(directory) for name, directory in self.dirs.items()},
        }
        self.write_env()
        self.environment = dict(os.environ, PATH=f'{self.bin}:{os.environ["PATH"]}',
                                MOCK_ROOT=str(self.work), MOCK_LOG=str(self.log))
        self.write_tool('docker', '''#!/usr/bin/env python3
import json, os, pathlib, sys
root = pathlib.Path(os.environ['MOCK_ROOT'])
args = sys.argv[1:]
with open(os.environ['MOCK_LOG'], 'a') as log:
    log.write('docker ' + ' '.join(args) + '\\n')
names = ['postgres', 'minio', 'qdrant']
ids = {name: str(i + 1) * 64 for i, name in enumerate(names)}
if args[0] == 'compose':
    op = args[3]
    if op == 'ps': print(ids[args[-1]])
    elif op == 'stop': (root / ('stopped-' + args[-1])).touch()
    elif op == 'start':
        for name in args[4:]: (root / ('stopped-' + name)).unlink(missing_ok=True)
elif args[0] == 'inspect':
    name = next(name for name in names if ids[name] == args[-1])
    fmt = args[2]
    stopped = (root / ('stopped-' + name)).exists()
    if 'Mounts' in fmt:
        target = {'postgres':'/var/lib/postgresql/data', 'minio':'/data', 'qdrant':'/qdrant/storage'}[name]
        print(json.dumps([{'Source':str(root / name), 'Destination':target}]))
    elif 'ExitCode' in fmt: print('false 0' if stopped else 'true 0')
    else: print('false' if stopped else 'true')
else: raise SystemExit(88)
''')
        self.write_tool('restic', '''#!/usr/bin/env python3
import os, sys
with open(os.environ['MOCK_LOG'], 'a') as log: log.write('restic ' + sys.argv[1] + '\\n')
if sys.argv[1] == 'backup': raise SystemExit(int(os.environ.get('MOCK_BACKUP_EXIT', '0')))
''')

    def write_tool(self, name, content):
        file = self.bin / name
        file.write_text(content)
        file.chmod(0o700)

    def write_env(self):
        self.env_file.write_text(''.join(f'{key}={value}\n' for key, value in self.entries.items()))
        self.env_file.chmod(0o600)

    def run_backup(self, mode='--run'):
        return subprocess.run(['bash', str(ROOT / 'scripts/backup_stateful_services.sh'),
                               str(self.env_file), mode], env=self.environment,
                              text=True, capture_output=True, timeout=20)

    def test_dry_run_never_contacts_docker_or_restic(self):
        result = self.run_backup('--dry-run')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.log.exists())

    def test_success_restarts_previously_running_services(self):
        result = self.run_backup()
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = self.log.read_text()
        self.assertIn('restic backup', calls)
        self.assertIn('start postgres minio qdrant', calls)
        self.assertFalse(list(self.work.glob('stopped-*')))

    def test_restic_failure_still_restarts_services_and_fails(self):
        self.environment['MOCK_BACKUP_EXIT'] = '3'
        result = self.run_backup()
        self.assertEqual(result.returncode, 3, result.stderr)
        self.assertIn('start postgres minio qdrant', self.log.read_text())
        self.assertFalse(list(self.work.glob('stopped-*')))

    def test_env_is_not_executed(self):
        sentinel = self.work / 'must-not-exist'
        self.entries['AWS_ACCESS_KEY_ID'] = f'$(touch {sentinel})'
        self.write_env()
        result = self.run_backup('--dry-run')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(sentinel.exists())

    def test_unapproved_downtime_fails_before_docker(self):
        self.entries['BACKUP_ALLOW_DOWNTIME'] = '0'
        self.write_env()
        result = self.run_backup()
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.log.exists())

    def test_insecure_env_permissions_fail(self):
        self.env_file.chmod(0o644)
        result = self.run_backup('--dry-run')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.log.exists())


if __name__ == '__main__':
    unittest.main()
```
