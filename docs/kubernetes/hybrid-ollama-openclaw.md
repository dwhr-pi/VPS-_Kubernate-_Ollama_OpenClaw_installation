# Hybrid-K3s: Ollama und OpenClaw absichern

Der VPS ist Steuerungs- und Zugangsebene; Ollama rechnet auf dem RTX-Worker
im Heimnetz. WireGuard verbindet die Standorte; der Raspberry Pi kann den
Worker bei Bedarf wecken. Ollama bleibt privat. OpenClaw bekommt nur die
Netzwerk- und Werkzeugrechte, die der freigegebene Workflow braucht.

**Status:** Manifest- und Overlay-Beispiele, keine Laufzeit- oder
Produktionsfreigabe. Die Beispiele installieren weder Docker noch einen
Cluster, starten keine Modelle und enthalten keine Zugangsdaten.

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

Direktes Ollama ist eine optionale Ausnahme: Im OpenClaw-Pod-Template
`llmops-direct-inference: "true"` ergaenzen und das
[Policy-Paar](../../deploy/kustomize/optional/direct-openclaw-ollama/network-policy.yaml)
einbinden. Der Endpunkt lautet bei Standard-Cluster-Domain
`http://ollama.llmops.svc.cluster.local:11434`. Beide Namespaces muessen
vorhanden sein. Die Regeln erlauben den Port, unterscheiden aber keine
API-Operationen. Policies sind additiv; andere Freigaben bleiben wirksam.
Dashboard-Zugang separat ueber WireGuard und einen privaten Proxy mit TLS
und Gateway-Authentifizierung einrichten. Ollama nicht oeffentlich routen.

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
