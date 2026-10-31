# P0-Patchplan für das VPS-/Kubernetes-Setup

Stand: 2026-10-23

## Kurzentscheidung

Für dieses konkrete Setup ist Docker Compose zunächst die bessere Betriebsplattform, wenn der VPS
ein einzelner Host bleibt und primär Ollama, LiteLLM, Open WebUI, PostgreSQL und Qdrant betreibt.
K3s sollte erst eingesetzt werden, wenn mindestens zwei klar getrennte Workload-Klassen, mehrere
Nodes, GitOps oder Kubernetes-spezifische Policies benötigt werden.

Das vorhandene `scripts/k8s_deployments.yaml` ist kein produktionsreifes Komplettmanifest. Es mischt
Ollama, Zenbot, MongoDB, einen nicht reproduzierbaren OpenManus-Platzhalter und einen extern
exponierten Gemini-Proxy. Deshalb sollten nicht alle Objekte gemeinsam ausgerollt werden.

## P0-Befunde und Patchreihenfolge

### P0-1: Externe Angriffsfläche des Gemini-Proxys entfernen

**Befund:** `scripts/k8s_deployments.yaml:221-232` veröffentlicht den Proxy als
`type: LoadBalancer`. Der Proxy hat keine Authentifizierung, keine Rate-Limits und nimmt den API-Key
als URL-Parameter an (`:261`).

**Patch:**

1. `type: LoadBalancer` durch `ClusterIP` ersetzen.
2. Den Proxy standardmäßig nicht deployen. Besser: aus dem Basismanifest entfernen und als
   separates, explizit aktiviertes Overlay führen.
3. Falls extern erforderlich: nur über einen authentifizierten Ingress mit TLS, Netzwerk-Allowlist,
   Rate-Limit und Audit-Logging veröffentlichen.
4. Gemini-Key über `SecretKeyRef` injizieren, aber niemals in URL-Query-Parameter übertragen. Wenn
   der Provider Header unterstützt, den dokumentierten Auth-Header verwenden.
5. Proxy-Code aus dem ConfigMap-Platzhalter in ein versioniertes, getestetes Image verschieben.

**Akzeptanzkriterium:** `kubectl get svc -n ai-services` zeigt keinen öffentlichen LoadBalancer für
den Proxy. Ein unauthentifizierter Request auf `/generate` wird mit `401` abgewiesen.

### P0-2: Alle beweglichen Images ersetzen

**Befund:** `scripts/k8s_deployments.yaml:24,73,111,152,159,201` verwendet `latest`, `alpine/git`
und `python:3.9-slim`. Der Compose-Stack verwendet zusätzlich `main`, `main-latest` und `latest`.

**Patch:**

1. Für jedes tatsächlich unterstützte Image eine konkrete Release-Version festlegen.
2. Für produktive Deployments zusätzlich auf einen geprüften SHA256-Digest pinnen.
3. OpenManus nicht beim Pod-Start aus Git klonen. Ein reproduzierbares Image mit gelocktem Commit
   bauen und in eine kontrollierte Registry stellen.
4. Python-Version und Dependency-Lockfile im Image festschreiben.
5. CI mit Trivy/Syft/Cosign ergänzen und Deployment nur für signierte, bekannte Digests erlauben.

**Akzeptanzkriterium:** Ein Repository-Check schlägt bei `:latest`, `:main`, `:nightly` und unpinned
Git-Clones in produktiven Manifests fehl.

### P0-3: Ollama intern isolieren und absichern

**Befund:** Das Manifest besitzt für Ollama keinen Service, keine Probes, keinen `securityContext`
und keine NetworkPolicy. Dadurch ist die beabsichtigte Erreichbarkeit nicht klar kontrolliert.

**Patch:**

1. Einen internen `ClusterIP`-Service `ollama` ergänzen.
2. Zugriff nur aus dem LiteLLM-/Agent-Namespace erlauben.
3. Ollama als nicht öffentlich erreichbaren Backend-Dienst behandeln.
4. Startup-, Readiness- und Liveness-Probes ergänzen.
5. `automountServiceAccountToken: false`, `allowPrivilegeEscalation: false`,
   `capabilities.drop: [ALL]`, `seccompProfile: RuntimeDefault` setzen.
6. Für GPU-Betrieb einen separaten Overlay-Pfad mit NVIDIA Device Plugin und explizitem
   `nvidia.com/gpu`-Limit verwenden.
7. Das Modell-PVC mit Backup- und Restore-Verfahren dokumentieren.

**Akzeptanzkriterium:** Ollama ist nur innerhalb des Clusters/Tailnets erreichbar; ein Zugriff vom
öffentlichen Interface ist nicht möglich.

### P0-4: MongoDB und Zenbot aus dem Default entfernen

**Befund:** `scripts/k8s_deployments.yaml:56-120` startet Zenbot und MongoDB ohne Authentifizierung,
ohne SecurityContext, ohne Probes, ohne Resource-Limits und ohne NetworkPolicy. Trading-Automation
ist zusätzlich ein hohes fachliches Risiko.

**Patch:**

1. Zenbot/MongoDB aus dem Standardmanifest entfernen.
2. In ein separates `profiles/trading`-Overlay verschieben.
3. Das Overlay standardmäßig deaktiviert lassen.
4. Keine Live-Trading-Keys; nur Analyse-/Paper-Trading-Modus.
5. MongoDB nur mit Authentifizierung, verschlüsseltem Backup, NetworkPolicy und dokumentiertem
   Restore betreiben.
6. Jede schreibende oder externe Trading-Aktion durch ein Human-Approval-Gate sperren.

**Akzeptanzkriterium:** Ein Standard-Deploy startet weder Zenbot noch MongoDB.

### P0-5: OpenManus-Platzhalter nicht ausrollen

**Befund:** `scripts/k8s_deployments.yaml:134-181` nutzt `alpine/git`, klont beim Start den
Default-Branch und startet anschließend `python:3.9-slim` mit angenommener `main.py`. Das ist nicht
reproduzierbar und kann Supply-Chain-Code zur Laufzeit ausführen.

**Patch:**

1. Deployment aus dem Standardmanifest entfernen.
2. Ein getestetes Image aus einem fixierten Commit bauen.
3. Image signieren und Digest pinnen.
4. Read-only Root-Filesystem, nicht-root User, Ressourcenlimits und Probes ergänzen.
5. Netzwerkzugriffe standardmäßig blockieren; nur erforderliche Egress-Ziele erlauben.

**Akzeptanzkriterium:** Kein Pod führt beim Start `git clone` aus.

### P0-6: Pod-Sicherheits- und Netzwerk-Baseline ergänzen

Für jede verbleibende Workload im Namespace:

- Namespace-Labels für Pod Security Admission setzen, zunächst `warn`/`audit`, danach
  `enforce: restricted` nach Bereinigung.
- Default-Deny-NetworkPolicy für Ingress und Egress anlegen.
- Pro Anwendung nur notwendige Kommunikationspfade erlauben.
- ServiceAccounts explizit definieren und Tokens nicht automatisch mounten.
- `runAsNonRoot`, `seccompProfile: RuntimeDefault`, `allowPrivilegeEscalation: false` und
  `capabilities.drop: [ALL]` setzen.
- Requests und Limits verpflichtend machen.
- Probes, `terminationGracePeriodSeconds` und sichere Restart-Strategie ergänzen.

## Empfohlene Dateistruktur

```text
k8s/
  base/
    namespace.yaml
    ollama-deployment.yaml
    ollama-service.yaml
    ollama-pvc.yaml
    networkpolicy-default-deny.yaml
    networkpolicy-ollama.yaml
    resource-quota.yaml
    limit-range.yaml
  overlays/
    vps-cpu/
    vps-gpu/
    optional-openmanus/
    optional-trading/
```

Das bisherige `scripts/k8s_deployments.yaml` sollte nicht direkt weiter als produktives
All-in-one-Manifest verwendet werden. Es kann als historische Vorlage erhalten bleiben, sollte aber
in der README ausdrücklich als `example/legacy` markiert werden.

## Compose versus K3s für diesen VPS

### Docker Compose – Vorteile

- Weniger bewegliche Teile auf einem einzelnen VPS.
- Einfachere Fehlersuche und kleinere Betriebsoberfläche.
- Direkte und verständliche Persistenz über Volumes.
- Für Ollama, LiteLLM, Open WebUI, PostgreSQL und Qdrant ausreichend.
- Backups und Restore lassen sich mit `pg_dump`, Qdrant-Snapshots und Dateisystemarchiven einfach
  automatisieren.
- Geringerer RAM- und CPU-Overhead.
- Kein eigener Kubernetes-API-Server, kein etcd und keine zusätzliche Cluster-PKI.

### Docker Compose – Nachteile

- Keine native Self-Healing- und Scheduling-Logik über mehrere Nodes.
- Schwächere Isolation zwischen Workloads.
- Netzwerkpolicies, RBAC und Admission-Kontrollen müssen durch Host-/Proxy-Konfiguration ersetzt
  werden.
- Rolling Updates, Secrets und Rollbacks sind weniger standardisiert.
- Horizontale Skalierung und GPU-/Worker-Orchestrierung werden schnell individuell.

### K3s – Vorteile

- RBAC, Namespaces, NetworkPolicies, Probes, Quotas und deklarative Deployments.
- Bessere Grundlage für mehrere Worker, GPU-Nodes und getrennte Agenten-Workloads.
- Saubere Trennung von optionalen Profilen und sensiblen Diensten.
- GitOps, Policy-as-Code und signierte Images lassen sich systematischer integrieren.

### K3s – Nachteile

- Ein einzelner K3s-Node bleibt ein Single Point of Failure; Kubernetes macht einen VPS nicht
  automatisch hochverfügbar.
- Höhere Komplexität und zusätzlicher Wartungsaufwand.
- etcd-/SQLite-Backups, Cluster-Upgrades, CNI, Storage und Ingress müssen betrieben werden.
- Stateful Services wie PostgreSQL, Qdrant und Ollama benötigen weiterhin sorgfältige Backup-,
  Storage- und Restore-Strategien.
- Mehr Fehlermöglichkeiten für ein Setup, das aktuell viele Komponenten erst als `planned` oder
  `experimental` beschreibt.

### Entscheidung für dieses Setup

1. **Phase 1:** Docker Compose für den stabilen Kern auf einem einzelnen VPS: Ollama, LiteLLM, Open
   WebUI, PostgreSQL und Qdrant.
2. **Phase 2:** K3s erst nach erfolgreichem Backup-/Restore-Test, stabilen Healthchecks und klarer
   Trennung der Workloads.
3. **Phase 3:** K3s für mehrere Nodes, GPU-Worker, getrennte Agenten und Policy-as-Code.

Nicht sinnvoll ist ein hybrider Zustand, in dem ein einzelner VPS K3s betreibt, aber die Manifeste
weiterhin aus unversionierten Beispielcontainern und öffentlichen LoadBalancern bestehen.

## Umsetzungsreihenfolge

1. Default-Manifest auf Ollama und klar definierte interne Dienste reduzieren.
2. Trading, OpenManus und Gemini-Proxy in deaktivierte Overlays verschieben.
3. Images pinnen und CI-Policy gegen mutable Tags aktivieren.
4. Namespace-, RBAC-, Default-Deny- und Workload-NetworkPolicies hinzufügen.
5. Probes, SecurityContexts, ResourceQuota, LimitRange und PVC-Backups ergänzen.
6. Backup-Skript installieren und einen Restore auf einem separaten Testpfad durchführen.
7. Erst danach K3s als dauerhafte Betriebsplattform entscheiden.

## Tests vor Freigabe

```bash
kubeconform -strict -summary k8s/**/*.yaml
kube-linter lint k8s/
trivy config k8s/
trivy fs --scanners vuln,secret,misconfig .
kubectl apply --dry-run=server -k k8s/overlays/vps-cpu
kubectl auth can-i --list --as=system:serviceaccount:ai-services:ollama
kubectl get networkpolicy -A
kubectl get pods -n ai-services -o wide
```

Die Prüfung gilt erst als bestanden, wenn keine öffentlichen Datenbank-, Ollama- oder Admin-Ports
vorhanden sind, alle produktiven Images gepinnt sind und ein echter Restore von PostgreSQL, Qdrant
und mindestens einem Ollama-Modell erfolgreich war.
