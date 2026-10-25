# Schlanke VPS-Baseline: Gateway, Modellcache und kontrollierte Auslieferung

Stand: **25.10.2026**. Neue optionale Auslieferungsbausteine, keine gestarteten
Dienste oder Migration bestehender Installationen. Produktionsnahe Schutzregeln
sind implementiert; **Produktionsreife ist erst nach Staging-Abnahme belegt**.
Gepruefte Image-Digests, echte Secrets, Modellname und Storage sind bewusst nicht
erfunden. Die Platzhalter sperren einen unbeabsichtigten Standard-Deploy.

## Bestandsaufnahme und Engpaesse

Der [Architekturreview](ARCHITECTURE_REVIEW_2026-10-25.md) beschreibt die
weiterhin offenen Risiken der aelteren Host-/Compose-Pfade. Bereits vorhanden:
LiteLLM vor Ollama, Non-Root, Default-Deny, Probes, Limits, PVC, SOPS-Regel,
separates Monitoring. Neu ist ein zusammenhaengender CPU-VPS-Auslieferungsweg.
Dieser Patch saniert nicht pauschal alle alten Installer oder echten Secrets.

Auf 1-2-GiB-VPS keine lokale LLM-Inferenz plus Kubernetes und Monitoring planen.
Der CPU-Pfad verlangt mindestens 6 GiB Gesamt-RAM, aktuell 2 GiB verfuegbar und
64 GiB freien Storage; 8 GiB oder mehr sind ein vernuenftiger Teststartpunkt,
aber keine Garantie fuer ein bestimmtes Modell. Diese Werte sind konservative
Profilgrenzen, keine Benchmark-Ergebnisse. CPU-Offloading, Kontext und native
Modell-Runtime benoetigen zusaetzlichen Speicher; kleine quantisierte Modelle
zuerst messen. GPU-Workstation bleibt ein separates Profil.

## Architektur und Dateien

```text
OpenClaw / freigegebener Client
         | OpenAI-kompatibel, Bearer-Key, /v1
         v
LiteLLM ClusterIP:4000 (eine Replik, ein Worker)
         | nur lokales Routing, keine Cloud-Fallbacks
         v
Ollama ClusterIP:11434 -> StatefulSet -> models-ollama-0 PVC

Prometheus -> geschuetztes LiteLLM /metrics + erlaubter Node-Exporter
Grafana    -> CPU, RAM, Disk, Gateway-p95 und Scrape-Verfuegbarkeit
SOPS/age  -> separates Secret-Management, nicht Runtime-ConfigMap
```

| Datei | Rolle |
|---|---|
| [Basis](../k8s/base/kustomization.yml) | Namespace, Quota, LimitRange, zwei interne Services, StatefulSet/Deployment und Default-Deny |
| [VPS-Kustomization](../k8s/overlays/vps-cpu/kustomization.yml) | Bestehende Basis wiederverwenden, kein zweiter Stack |
| [deployment.yaml](../k8s/overlays/vps-cpu/deployment.yaml) | CPU-/RAM-Grenzen, kleine Queue, Kontext 2048 und eine Gateway-Replik |
| [gateway.yaml](../k8s/overlays/vps-cpu/gateway.yaml) | Modellalias local-default, Secret-Referenz, Metrics-Callback, 120s Timeout, keine Retries oder Antwortcache |
| [service.yaml](../k8s/overlays/vps-cpu/service.yaml) | Selektiver Agentenzugriff auf vorhandenen LiteLLM-Service, kein weiterer oeffentlicher Port |
| [pvc.yaml](../k8s/overlays/vps-cpu/pvc.yaml) | Retain fuer bestehende StatefulSet-Claims; der PVC wird weiterhin aus dem volumeClaimTemplate der Basis erzeugt |
| [Deploy-/Update-Skript](../scripts/operations/deploy_vps_baseline.sh) | Lokale Vorpruefung, Render/Schema-Plan, expliziter Kontext, Server-Dry-Run, SSA und begrenztes Rollout-Warten |

### Gateway und Client

Prozesspersistenz und ein Worker ermoeglichen die Wiederverwendung der
Upstream-Clients; es werden keine ungeprueften Connection-Pool-Parameter
erfunden. Pool-/Socketverhalten und maximale Parallelitaet am konkreten LiteLLM-
Image messen. Routing bleibt lokal; ueber OpenAI-kompatible Clients mit
`http://litellm.llmops.svc.cluster.local:4000/v1` und Alias `local-default`
ansprechen. Authdaten nicht in Prompts oder URLs eintragen.

Namespace des Agenten mit `llmops-client=true`, dessen Pod mit
`llmops-gateway-client=true` markieren. Beide Selector-Bedingungen muessen
passen. Bei eigener Egress-Default-Deny-Policy im Clientnamespace den Weg zu
LiteLLM plus DNS dort separat freigeben. Ein Host-OpenClaw nutzt kontrollierten
VPN-/TLS-Ingress, nicht ungeprueft die Cluster-Service-IP.

Fehlervertrag testen: kein Key => 401/403, unbekanntes Modell => dokumentierter
Clientfehler, Backendausfall => begrenzter Fehler/Timeout, kein Cloud-Retry.
Stream-Abbruch und Fehlercodes am Pin pruefen; kein automatischer Erfolg durch
Health-Probes. Eine Replik ist bewusst kein HA- oder globales Budgetsystem.
[LiteLLM-Konfiguration](https://docs.litellm.ai/docs/proxy/configs).

## Persistenter Modellcache

Ollama bleibt StatefulSet mit dem bestehenden Claim `models-ollama-0`, 50 GiB
und RWO. Kein zweiter `pvc.yaml`-PVC neben dem volumeClaimTemplate, keine
Umbenennung und kein automatisches Shrink/Migrieren. Retain behaelt Claims bei
StatefulSet-Loeschung/Skalierung; manuelles PVC-Loeschen und eine ReclaimPolicy
Delete sind dadurch nicht generell unschaedlich. Backup bleibt erforderlich.

Im privaten Overlay die passende StorageClass explizit festlegen. Beim K3s-
Local-Path-Provisioner sind Daten nodegebunden: Podneustart auf demselben Node
kann den Cache behalten, Nodeverlust/Migration erfordert Restore oder erneuten
Import. CSI/Netzstorage kann Rescheduling ermoeglichen, bringt aber Kosten,
Latenz und Ausfallpfade. Kein pauschales Longhorn fuer einen kleinen Einzelhost.
Vor Wechsel der StorageClass oder Claim-Groesse separaten Migrationsplan erstellen.
[K3s Storage](https://docs.k3s.io/storage/).

Modellgewichte bewusst vorladen/importieren, Digest und freie Disk pruefen.
Das Deployment laedt keine Modelle automatisch. Konfiguration/Modelfiles sichern;
Gewichte nur bei reproduzierbarer, erlaubter Wiederbeschaffung als Cache behandeln.
Keep-alive 5m ist endlich; mehr Kontext oder Parallelitaet erst nach RAM-/Latenz-
Messung. `/api/version` prueft keinen verfuegbaren Modellinhalt.

## Secrets: verschluesselt in Git, entschluesselt nur am Ziel

Die ConfigMap enthaelt nur `os.environ/LITELLM_MASTER_KEY`; der Pod verwendet
weiterhin `secretKeyRef` auf `llmops/litellm-runtime`, Feld `master-key`.
Das [leere Template](../k8s/secrets.template.yml) niemals mit echten Werten
im Checkout ausfuellen. [.sops.yaml](../.sops.yaml) verlangt einen echten
**oeffentlichen** age-Empfaenger statt des Platzhalters. Private age-Identitaet
nicht in Git, Runner-Artefakte oder gewoehnliche Backups schreiben.

Beispiel fuer einen separat freigegebenen Secret-Schritt; nicht automatisch
durch das Deployskript ausgefuehrt:

```bash
umask 077
# Author the plaintext only in a protected external location; never in this checkout.
sops --encrypt --config /private/config/.sops.yaml \
  --filename-override secrets.enc.yaml /private/secrets.input.yaml \
  > /private/gitops/secrets.enc.yaml
# Only after checking context, namespace, recipient and encrypted output:
python3 -I -B scripts/security/apply_vps_sops_secret.py \
  --file /private/gitops/secrets.enc.yaml --context REVIEWED_CONTEXT --confirm-apply
```

Der [Secret-Helper](../scripts/security/apply_vps_sops_secret.py) entschluesselt
nur in Prozessspeicher, akzeptiert ausschliesslich das Opaque-Secret
`llmops/litellm-runtime` mit Feld `master-key` (mindestens 32 Bytes), entfernt
fremde Metadaten und prueft vor Apply serverseitig. Auch Fehlermeldungen der
Unterprozesse werden nicht mit Payload ausgegeben. Dies ist kein geschuetzter
Speicher gegen privilegierte Hostzugriffe; System-Swap/Core-Dumps beachten.
Keine Passwoerter oder weiteren Secrets in diesem eingeschraenkten Schritt.
Kein `set -x`, kein `tee`, keine entschluesselte Datei im Repository. Erst Namespace
`llmops` aus der Basis kontrolliert vorbereiten, dann Secret separat anlegen.
Nur Ciphertext committen, SOPS-Metadaten/Empfaenger pruefen, Gitleaks/Trivy als
zusaetzliche Gates verwenden. Dies garantiert keine Abwesenheit historischer
Leaks; deren Triage/Rotation bleibt ein eigener Auftrag.

Kubernetes-Secrets sind nicht durch Base64 verschluesselt. Datastore-
Verschluesselung, restriktives RBAC und Backups des Recovery-Materials separat
abnehmen. Flux kann SOPS nach expliziter Konfiguration entschluesseln; Argo CD
braucht einen eigens geprueften Secret-/Pluginweg. Nicht blind derselbe Vertrag.
[SOPS](https://github.com/getsops/sops),
[Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/).

## Installation und Update

Voraussetzung ist ein bewusst bereits eingerichteter lokaler k3s-VPS mit
laufender Runtime, kubectl, kubeconform und Python. Das Skript installiert
keine Hostpakete, kein Docker, keinen Treiber und kein k3s. Es aendert Swap
nicht. Aktiver Swap blockiert konservativ bis zu einer getrennten kubelet-
MemorySwap-Abnahme; kein automatisches `swapoff` oder Editieren von fstab.

```bash
bash scripts/operations/deploy_vps_baseline.sh --check
bash scripts/operations/deploy_vps_baseline.sh --plan \
  --overlay /private/deployment-overlay
# Cluster contact and changes only with both explicit flags:
bash scripts/operations/deploy_vps_baseline.sh --apply \
  --overlay /private/deployment-overlay \
  --context REVIEWED_CONTEXT --confirm-apply
```

Optional `--data-dir` fuer den tatsaechlichen k3s-/Storage-Mount und
`--runtime-unit k3s-agent|containerd`. Dies ist ein **lokaler Hostcheck**,
kein Remote-Inventar aller Worker. Unter WSL wird C: zusaetzlich konservativ
geprueft; bei 14 GiB frei ist dieses 50-GiB-PVC-Profil nicht freigegeben.
Disk, Arbeitsspeicher und Storage aller echten Nodes vor Remote-Apply pruefen.

Privates Overlay importiert `k8s/overlays/vps-cpu`, ersetzt Images durch
gepruefte Digests und setzt einen bereits vorhandenen Modellnamen. `--plan`
rendert in ein privates Temp-Verzeichnis, lehnt Platzhalter/ungepinnte Images
und eingebettete Secret-Objekte ab und fuehrt kubeconform strict aus.
Schema-/Remote-Base-Aufloesung kann Netz benoetigen: nur vertrauenswuerdige
Overlays und kontrollierte Schemas verwenden. Kein garantierter Offline-Modus.
CRDs benoetigen passende lokale/erreichbare Schemas; nicht mit skip umgehen.

Apply erfordert Namespace/Secret bereits vorhanden, prueft zuerst serverseitig
und verwendet SSA ohne Force-Conflicts, Prune oder Delete. Ein Update verwendet
denselben Befehl mit neuem geprueftem Digest. Nur einen Writer einsetzen:
entweder manueller Apply oder GitOps-Controller, nicht beide parallel.
Readiness-/Rolloutfehler bleiben Fehler; keine automatische Daten-Ruecksetzung.
Konfigurations-/Secret-Aenderungen brauchen ggf. einen separat geplanten
Pod-Restart; es wird kein pauschaler Restart laufender Nutzerjobs erzwungen.

## Schlanke Observability und GitOps

Den [vorhandenen Monitoring-Stack](../docker-compose.monitoring.yml) oder eine
vorhandene private Prometheus-Instanz weiterverwenden. Kein zweiter Operator,
keine automatische cAdvisor-Daemoninstallation. Node-Exporter fuer CPU/RAM/Disk
explizit bereitstellen; sein Hostzugriff bleibt ein eigenes Opt-in. LiteLLM
exponiert `/metrics`; Ollama wird nicht als nativer Prometheus-Exporter erfunden.

Das [Dashboard](../monitoring/grafana/dashboards/llmops.json) ergaenzt nun
Gateway-p95-Gesamtlatenz und Scrape-Verfuegbarkeit. Metriknamen am Image pruefen;
fehlende Samples bedeuten keine Null-Latenz. Gemessene Latenz ist nicht reine
Decode-Geschwindigkeit. Eine freigegebene synthetische Anfrage erzeugt erst
Messwerte. Kein synthetischer Traffic wurde hier geschickt.
[LiteLLM Prometheus](https://docs.litellm.ai/docs/proxy/prometheus).

Scrape-Intervall 30s und kurze Retention der vorhandenen Konfiguration begrenzen
Overhead. Prometheus braucht einen eigenen geschuetzten Metrics-Key, Netzwerk-
Erreichbarkeit und ggf. Egress-Freigabe aus seinem Namespace. Keine Master-Keys
in Dashboards, keine unkontrollierten hochkardinalen Benutzerlabels. Der bestehende
Alertmanager-/Zustellungsbedarf aus dem Audit ist durch neue Panels nicht geloest.

GitOps-Schichten: Infrastruktur/CRDs -> Namespace/Secrets -> Runtime -> optionale
Telemetrie. Runtime-Kustomization enthaelt keine Secret-Payloads oder Controller-
CRDs. GitOps-Controller und Plattformcharts separat pinnen; kein Flux/Argo
automatisch installieren. Keine bestehenden Produktiv-Deployments ungeprueft
mit dem CPU-Profil ueberschreiben. PVC-/Modell-/Gateway-Migrationen und
Breaking Changes zuerst im Staging testen.

## Abnahmekriterien

Hostchecks, Schema/Render, zwei idempotente Deploys, Auth-Negativtest,
Client-/Fremdnamespace-Netztest, echte lokale Inferenz, Modellcache nach
Podneustart, kleiner Lasttest, Metrics-/Alarmzustellung und isolierter Restore.
Modelldigest, Architektur, Kontext, Parallelitaet und Image-Digests mitprotokollieren.
Keine echten Secrets, Prompts oder Credential-Inhalte in Abnahmeberichten.

Lokal gepruefte Fixtures sind keine echte k3s-, Image-UID-, PVC-, SOPS- oder
Inferenzabnahme. Offene Livechecks bleiben Voraussetzung fuer Produktion.

### Lokaler Pruefstand dieses Patches

Unter Windows: 21 Tests bestanden, 13 Linux-/POSIX-Ablauftests plattformbedingt
uebersprungen (VPS-Delivery, Secret-Vertrag und bestehende Baseline zusammen).
Bash-Syntax und `git diff --check` bestanden. Die CI wurde um die neuen Tests
und das Rendern des VPS-Overlays erweitert, aber hier nicht ausgefuehrt.
Kustomize-Render und kubeconform-Schemaabnahme sind lokal noch offen; ebenso
echte SOPS-Entschluesselung, Cluster-Apply, Netzwerk-, PVC- und Inferenztests.
Keine Dienste, Installationen, Modellabfragen oder produktiven Secrets wurden
fuer diese Pruefungen gestartet beziehungsweise verwendet.
