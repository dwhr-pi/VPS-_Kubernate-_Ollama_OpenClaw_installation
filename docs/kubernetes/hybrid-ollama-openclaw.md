# Hybrid-K3s: Ollama und OpenClaw absichern

Der VPS ist Steuerungs- und Zugangsebene; Ollama rechnet auf dem RTX-Worker
im Heimnetz. WireGuard verbindet die Standorte; der Raspberry Pi kann den
Worker bei Bedarf wecken. Ollama bleibt privat. OpenClaw bekommt nur die
Netzwerk- und Werkzeugrechte, die der freigegebene Workflow braucht.

**Status:** Manifest- und Overlay-Beispiele, keine Laufzeit- oder
Produktionsfreigabe. Die Beispiele installieren weder Docker noch einen
Cluster, starten keine Modelle und enthalten keine Zugangsdaten.

## Architekturbewertung

**7/10 fuer den Entwurf, keine Produktionsfreigabe.** StatefulSet, interner
Service, Modell-PVC, Ressourcenbudgets und Default-Deny sind bereits
vorhanden. Die groesste strukturelle Grenze bleibt der einzelne Heim-Worker:
Bei Schlafzustand, Tunnel- oder Plattenausfall kann der CPU-VPS die
GPU-Inferenz nicht einfach uebernehmen. Das Gateway soll mit begrenzter
Wartezeit einen klaren Fehler liefern. Kein stiller Cloud-Fallback.

Ein angeforderter GPU-Slot ist keine VRAM-Grenze. Modell, Kontext und
Parallelitaet unter Last messen. Bei OpenClaw Workspace und externe
Memory-Datenbanken getrennt und anwendungskonsistent sichern.

## Ollama: GPU und Modellcache

Das [GPU-Overlay](../../deploy/kustomize/overlays/gpu/kustomization.yaml)
erweitert den [Ollama-StatefulSet](../../k8s/base/ollama.yml), statt ein
zweites Deployment anzulegen. Sein [GPU-Patch](../../k8s/overlays/gpu/k8s-ollama-deployment.yaml)
setzt Request und Limit auf eine NVIDIA-GPU. Der bestehende 50-GiB-RWO-PVC
bleibt unter `/data` gemountet, mit `OLLAMA_MODELS=/data/models` und
Aufbewahrung beim Skalieren oder Loeschen des StatefulSets. Das ist kein
Backup und garantiert bei lokalem Storage keinen Wechsel auf einen anderen Node.

Im Checkout lokal rendern, ohne etwas anzuwenden:

```bash
kubectl kustomize deploy/kustomize/overlays/gpu
```

Vor der Freigabe den Node-Selector auf den vorgesehenen RTX-Worker begrenzen,
den Image-Digest pruefen und NVIDIA-Treiber, K3s-RuntimeClass `nvidia` und
Device-Plugin auf diesem Worker nachweisen. CPU- und RAM-Limits begrenzen
Ressourcen, verhindern aber keine OOM-Kills. Mit einem geladenen Modell und
einer parallelen Anfrage beginnen, dann Kontext und Queue unter Last messen.

### RTX-Worker explizit auswaehlen

Dieser strategische Merge-Patch erweitert das gerenderte GPU-Overlay.
Das Label `workload.openclaw.io/ollama=true` muss der Betreiber am
vorgesehenen Node setzen. Der bestehende GPU-Selector bleibt zusaetzlich
wirksam. Service, Claim-Template, Mounts und Probes bleiben unveraendert.
Die Budgets sind Startwerte, keine gemessene Kapazitaetszusage.

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata: {name: ollama, namespace: llmops}
spec:
  template:
    spec:
      nodeSelector: {workload.openclaw.io/ollama: "true"}
      containers:
        - name: ollama
          resources:
            requests: {cpu: "2", memory: 4Gi, ephemeral-storage: 256Mi, nvidia.com/gpu: 1}
            limits: {cpu: "6", memory: 12Gi, ephemeral-storage: 2Gi, nvidia.com/gpu: 1}
```

## OpenClaw: Deployment-Patch ohne Klartext-Secrets

Den folgenden strategischen Merge-Patch unter `patches` im eigenen
Kustomize-Overlay einbinden. Er setzt ein geprueftes Deployment
`ai-agents/openclaw` mit Container `openclaw` voraus. Das gepinnte Image und
der Startbefehl bleiben Teil dieses Deployments. Das Image muss mit UID
`10001` und schreibgeschuetztem Root-Dateisystem funktionieren. Der PVC
`agent-workspaces` muss in `ai-agents` bereitstehen; der gleichnamige Claim
aus dem GPU-Overlay in `llmops` kann nicht namespace-uebergreifend gemountet
werden. Der [Repo-Hardening-Patch](../../k8s/platform/openclaw-hardening-patch.yml)
ist die Vorlage fuer die Variante in `llmops`.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata: {name: openclaw, namespace: ai-agents}
spec:
  replicas: 1
  strategy: {type: Recreate, rollingUpdate: null}
  template:
    metadata:
      labels: {app.kubernetes.io/name: openclaw}
    spec:
      automountServiceAccountToken: false
      securityContext:
        runAsNonRoot: true
        runAsUser: 10001
        runAsGroup: 10001
        fsGroup: 10001
        seccompProfile: {type: RuntimeDefault}
      containers:
        - name: openclaw
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities: {drop: [ALL]}
          env:
            - {name: OPENCLAW_STATE_DIR, value: /data/state}
            - name: OPENCLAW_GATEWAY_TOKEN
              valueFrom:
                secretKeyRef: {name: openclaw-gateway, key: token}
          volumeMounts:
            - {name: workspace, mountPath: /data}
            - {name: tmp, mountPath: /tmp}
      volumes:
        - name: workspace
          persistentVolumeClaim: {claimName: agent-workspaces}
        - name: tmp
          emptyDir: {sizeLimit: 256Mi}
```

Das Secret `openclaw-gateway` mit Schluessel `token` im selben Namespace
getrennt ueber SOPS oder Sealed Secrets bereitstellen; Token-Authentifizierung
in der Gateway-Konfiguration aktivieren. Keine Secrets in Git, Logs oder
ConfigMaps schreiben. Kein Host-Mount und kein Runtime-Socket. Der
SecurityContext ist keine Shell-Sandbox: Agentenwerkzeuge separat beschraenken
oder in einer eigenen Sandbox ausfuehren.

## Netzwerk und Abnahme

Die [Agentenbasis](../../k8s/gitops/agents/kustomization.yaml) bringt
Default-Deny fuer Ingress/Egress sowie explizite DNS- und Qdrant-Freigaben mit.
Fuer normalen Betrieb authentifiziertes LiteLLM bevorzugen: Dazu auf
Agentenseite Egress und auf Gateway-Seite Ingress explizit fuer den
vorgesehenen OpenClaw-Pod und TCP 4000 freigeben.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: openclaw-to-litellm, namespace: ai-agents}
spec:
  podSelector: {matchLabels: {app.kubernetes.io/name: openclaw}}
  policyTypes: [Egress]
  egress:
    - to:
        - namespaceSelector: {matchLabels: {kubernetes.io/metadata.name: llmops}}
          podSelector: {matchLabels: {app: litellm}}
      ports: [{protocol: TCP, port: 4000}]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: litellm-from-openclaw, namespace: llmops}
spec:
  podSelector: {matchLabels: {app: litellm}}
  policyTypes: [Ingress]
  ingress:
    - from:
        - namespaceSelector: {matchLabels: {kubernetes.io/metadata.name: ai-agents}}
          podSelector: {matchLabels: {app.kubernetes.io/name: openclaw}}
      ports: [{protocol: TCP, port: 4000}]
```

Beide Policies zusammen mit den vorhandenen Default-Deny-Regeln einbinden.
Den direkten Ollama-Bypass bei diesem Pfad nicht aktivieren. Das Netzplugin
muss die Regeln durchsetzen; die Regeln ersetzen weder Authentifizierung
noch eine Modell-Allowlist. Keine pauschalen Kubernetes-Rollen vergeben.

Direktes Ollama ist eine optionale Ausnahme: Im OpenClaw-Pod-Template
`llmops-direct-inference: "true"` ergaenzen und das
[Policy-Paar](../../deploy/kustomize/optional/direct-openclaw-ollama/network-policy.yaml)
einbinden. Der Endpunkt lautet bei Standard-Cluster-Domain
`http://ollama.llmops.svc.cluster.local:11434`. Beide Namespaces muessen
vorhanden sein. Die Regeln erlauben den Port, unterscheiden aber keine
API-Operationen. Policies sind additiv; andere Freigaben bleiben wirksam.
Dashboard-Zugang separat ueber WireGuard und einen privaten Proxy mit TLS
und Gateway-Authentifizierung einrichten. Ollama nicht oeffentlich routen.

## Monitoring, Storage und Betriebsfreigabe

- **P0:** Vorhandenes Traefik und cert-manager fuer privates TLS nutzen.
  SOPS oder Sealed Secrets genuegen als erster Schritt; Vault erst bei
  konkretem Bedarf an zentraler Rotation oder dynamischen Zugangsdaten.
- **P1:** Local Path fuer wiederbeschaffbare Modelle behalten. Velero mit
  externem Backup-Ziel und passender Volume-Methode testen. Fuer Datenbanken
  zusaetzlich anwendungskonsistente Sicherungen vorsehen. Longhorn erst
  mit mehreren geeigneten Storage-Nodes und gemessener Tunnel-Latenz pruefen.
- **P1:** Prometheus/Grafana aus Monitoring-lite weiterverwenden; DCGM
  nur am GPU-Worker. Vector/Loki erst hinzunehmen, wenn lokale Logs fuer
  die Fehlersuche nicht genuegen. Prompts und Tokens nicht standardmaessig loggen.

`/api/version` und `/api/tags` pruefen Erreichbarkeit, nicht erfolgreiche
Inferenz. Einen kleinen, zeitlich begrenzten Inferenztest separat betreiben,
nicht als Liveness-Probe. Die
[Ollama-Exporter-Vorlage](../../k8s/platform/ollama-exporter.yaml) ist
deaktiviert und kein Laufzeitnachweis. Vor einem Staging-Apply die Variante
mit ihren Patches lokal rendern; hier wurde kein Cluster geaendert.

1. **P0:** Im Testcluster nachweisen, dass erlaubte Verbindungen funktionieren
   und unmarkierte Pods, unerlaubter Internet-Egress und direkte oeffentliche
   Zugriffe blockiert werden. Fehlendes Secret oder falscher Token darf
   keinen anonymen Zugriff ermoeglichen.
2. **P1:** GPU-Inferenz unter realer Last, Modellcache nach Pod-Neustart und
   einen externen Restore von Agenten-Workspace und Datenbank pruefen.
   [Velero-Beispiele](../../k8s/platform/velero/) erst nach erfolgreicher
   Wiederherstellung fuer den Regelbetrieb freigeben.
3. **P2:** [Monitoring](../../charts/monitoring-lite/) erweitern: GPU-Speicher
   und Temperatur mit DCGM, Inferenzlatenz und Fehlerquote am Gateway
   messen. Alarme fuer nicht erreichbare Worker und vollen Speicher testen.
