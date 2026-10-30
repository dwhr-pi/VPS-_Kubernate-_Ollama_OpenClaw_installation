# Plattform-Ergaenzungen und Sprachdialog

Stand: 2026-10-27. **Code und opt-in Vorlagen, keine Produktionsfreigabe.** Keine Installation,
Cloud-Anmeldung, Inferenz, Tunnelverbindung, Synchronisation oder Sicherung wurde ausgefuehrt. Die
Nutzerquelle wurde als Arbeitsauftrag bewertet, nicht als Tatsachenbeleg fuer den aktuellen
Repo-Zustand.

## Kurzbewertung und Architektur

Kubernetes-Requests/Limits, PSS, PVCs und Quoten existierten bereits unter `k8s/base`; Argo Core
wird durch den geprueften Bootstrap bereits installiert. Velero ist als GitHub-CLI vorhanden, aber
damit noch kein Backup-Controller. Eine leere Exporter-Zielliste ist eine Schutzvorkehrung, kein
Nachweis eines defekten Ollama-`/metrics`-Endpoints. Compose hat keine `resources.requests`: dort
heisst die entsprechende Konfiguration `reservations`.

```text
Browser -> Cloudflare Access -> ausgehender cloudflared-Tunnel
                              -> erlaubte ClusterIP-UI / Grafana
UI -> LiteLLM -> Ollama auf privatem Worker / RTX-Host
Prometheus -> read-only Inventarexporter -> nur Ollama GET /api/ps
Argo Core -> gepruefter Commit -> Kubernetes-Overlay (nicht Compose)
Velero + Node-Agent -> separates TLS-/S3-Backupziel -> isolierter Restore
```

**Kritisch verbleibend:** Mutable Images im Compose-Altstack, breit geteilte ENV, Redis-Passwort in
argv, Netdata mit SYS_PTRACE/unconfined und fehlende Laufzeit- Abnahme sind durch Ressourcenlimits
nicht behoben. Neue Ubuntu-/Architektur- Versionen, Multi-Arch-Images, CRDs, CNI, Schema-Migrationen
und Restore muessen isoliert geprueft werden. Kein pauschales Enterprise-/Zero-Trust-Versprechen.

## Dialog: zehn Sprachen und Overlay-Pakete

In `show_management_loading_notice` war `--cancel-label` gesetzt. Fuer `dialog --yesno` steuert
dieses Argument aber nicht das Nein-Feld. Jetzt werden `--yes-label` und `--no-label` mit
uebersetzbaren Schluesseln verwendet. Titel, Text, Ladeanzeige sowie Tool-/Profilbeschreibung sind
in `scripts/lang/` fuer `de en fr zh ja ru es eo ar he` enthalten. Sprachpakete werden weiterhin
**nach** dem eingebauten Sprachsatz geladen und koennen die neuen `TXT_LOADING_*`, `TXT_YES_LABEL`
und `TXT_NO_LABEL` ueberschreiben. Alte Pakete ohne diese Felder benutzen die passende eingebaute
Sprache, nicht den zuletzt geladenen Sprachsatz. Die Vorlage hat zwei `%s`-Felder fuer Ziel und
Detail; keine Shell-Auswertung.

Diese Aenderung lokalisiert diesen Dialog vollstaendig, nicht alle historisch deutschen Texte des
gesamten Setups. Hebraeische/arabische Darstellung und Zeichenbreiten brauchen weiterhin einen
UTF-8-/RTL-faehigen Terminaltest. Sprachpakete sind weiterhin ausfuehrbarer Shellcode; nur
vertrauenswuerdige Pakete laden. Diese Korrektur fuehrt keine Sandbox fuer fremde Sprachpakete ein.

## A. Ressourcen und Produktionsquota

Vollstaendiger Code: [Compose](../stacks/llmops-platform/docker-compose.yml),
[Quota-Patch](../k8s/overlays/production/resource-quota.yaml),
[Production-Overlay](../k8s/overlays/production/kustomization.yml).

LiteLLM/Open WebUI erhalten je 2 CPU / 2 GiB Limits und 512 MiB weiche Speicherreservation; Qdrant 1
CPU / 1 GiB und 256 MiB Reservation. Lokale Compose- Limits (`mem_limit`, `cpus`) stehen passend
neben `deploy.resources`; CPU- Reservationen sind ausserhalb eines geeigneten Schedulers keine
garantierten dedizierten Kerne. Dienste werden dadurch nicht gestartet. **Breaking bei
Aktivierung:** Vorhandene Workloads koennen diese Limits ueberschreiten und beim naechsten Recreate
OOM-/CPU-Drosselung erfahren. Vorher messen und anpassen. Andere Compose-Dienste wie Postgres, Redis
oder MinIO benoetigen weiterhin eigene, gemessene Budgets; die Summe aller Limits ist damit noch
keine Host-Reserve.

Ollama ist in diesem Compose-Stack nicht enthalten und wird nicht als neue Container-Installation
hinzugefuegt. Native systemd-Limits bleiben separat. Die Produktionsquota erweitert die vorhandene
`llmops-budget` per Patch um ephemeral storage, eine GPU und ein Verbot von NodePort/LoadBalancer;
keine konkurrierende zweite Quota. 48 GiB Gesamtlimit ist ein GPU-Host-Budget, kein passender
Mini-VPS-Default. Fuer CPU-VPS gibt es `k8s/overlays/vps-cpu`. Quoten reservieren keinen RAM fuer
Host/Kubelet und verhindern nicht jeden OOM.

## B. Ollama-Observability ohne erfundene Metriken

Vollstaendiger Code: [nativer Python-Exporter](../scripts/monitoring/ollama_readonly_exporter.py),
[optionales OCI-Rezept](../scripts/monitoring/Dockerfile),
[Kubernetes-Deployment/Service/Policies](../k8s/platform/ollama-exporter.yaml),
[Prometheus](../monitoring/prometheus.yml),
[inaktive Zielliste](../monitoring/ollama-metrics.targets.json),
[Kubernetes-Zielbeispiel](../monitoring/ollama-metrics.targets.example.json).

Der im Auftrag genannte `tjhop/ollama-exporter`-Link lieferte bei der Pruefung 404. Es wird kein so
benanntes ungeprueftes Paket installiert. Stattdessen liegt ein kleiner, architekturunabhaengiger
Stdlib-Exporter direkt im GitHub-Repo. Er akzeptiert nur Loopback/private IPs oder den exakt
freigegebenen Ollama-Service-Namen, ignoriert Proxy-ENV und folgt keinen Redirects. Er fragt
ausschliesslich `GET /api/ps` ab, mit Zeit-/Antwortgroessenlimit.

| Metrik                                 | Tatsaechliche Bedeutung                                                   |
| -------------------------------------- | ------------------------------------------------------------------------- |
| `ollama_monitor_up`                    | Inventarabfrage erfolgreich, keine garantierte Modell-/Inferenzgesundheit |
| `ollama_monitor_loaded_models`         | Anzahl geladener Modelle                                                  |
| `ollama_monitor_loaded_vram_bytes`     | Summierte gemeldete VRAM-Belegung, keine GPU-Auslastung in Prozent        |
| `ollama_monitor_poll_duration_seconds` | Dauer der Inventarabfrage, keine Request-/Inferenzlatenz                  |

Keine Modellnamen/Prompts als Labels, keine Tokens oder Antworttexte in Logs. `/healthz` misst nur
den Exporterprozess. Es gibt keine automatisch generierten Testprompts, Pulls oder Entladungen.
`model_load_time` und echte Request-Latenz lassen sich nicht aus `/api/ps` herleiten: separat
belegte LiteLLM-Metriken oder bewusst instrumentierten Inferenzpfad verwenden. Fuer RTX-Auslastung
braucht es zusaetzlich abgenommene NVIDIA-/DCGM-Telemetrie; kein Host-/GPU-Mount wurde ergaenzt.

```bash
# Nur bei bewusst gewuenschtem lokalem Exporterstart; kein Modellstart.
python3 -I -B scripts/monitoring/ollama_readonly_exporter.py \
  --ollama-url http://127.0.0.1:11434 --listen-address 127.0.0.1 --port 9404
```

Prometheus im Container erreicht damit NICHT automatisch den Host-Loopback. Fuer Kubernetes nach
Image-/CNI-Abnahme `replicas: 1` und einen echten Digest im eigenen Overlay setzen, danach das
Zielbeispiel bewusst uebernehmen und schreibgeschuetzt in Prometheus mounten. Standard ist weiterhin
**kein Ziel**, also kein ungefragter API-Aufruf. Der Exporter selbst hat keinen ServiceAccount-
Token und darf per NetworkPolicy nur DNS/Ollama erreichen. Verbindung zu einem Ollama-API-Port ist
keine L7-Beschraenkung: die GET-Begrenzung stammt vom Code.

## C. Cloudflare-Tunnel und private UI-Routen

Vollstaendiger Code: [Tunnel](../k8s/platform/cloudflared-tunnel.yaml),
[lokale Routen und Gegenstellen-Policies](../k8s/platform/ingress-routes.yaml).

Ein lokaler, ausgehender Tunnel benoetigt keinen zusaetzlichen oeffentlichen
Traefik-/NodePort-/LoadBalancer-Einstieg. Deshalb sind die neuen Routen direkt auf
ClusterIP-Services gerichtet. Open WebUI im Namespace `llmops` wird von diesen Dateien **nicht**
installiert; Grafana stammt aus dem vorhandenen `monitoring-lite`-Chart. Service-Namen, Labels und
Ports beim Einbau abgleichen. Die Kubernetes-Beispiele erweitern nicht automatisch den
Compose-Stack.

Standard ist `replicas: 0` und ein unbrauchbarer Image-Platzhalter. Fuer eigene lokal verwaltete
Tunnel UUID und SOPS-/Sealed-Secrets-geschuetztes Secret `llmops-edge/cloudflared-credentials` mit
`credentials.json` bereitstellen. Kein Konto-Login, cert.pem oder API-Token liegt im Repo/argv.
Beide Routen verlangen Access-JWT-Pruefung durch cloudflared mit passendem Team/Audience;
zusaetzlich Access-Anwendungen, restriktive SSO-Regeln und DNS im eigenen Konto pruefen.
UI-/Grafana-Authentifizierung bleibt erforderlich.

Metriken/Readiness binden an die explizite Pod-IP, kein Host-Port. `/ready` wird nicht als Liveness
missbraucht: Edge-Ausfall darf keinen Neustartsturm erzeugen. Die Ausgangspolicy begrenzt Ports und
private Ziele, erlaubt fuer Edge aber noch oeffentliche IPv4-Ziele auf 7844 und HTTPS/443 fuer
Access-JWKS. Vor Produktion mit aktuellen freigegebenen Edge-CIDRs beziehungsweise Egress-Gateway
verengen; das ist noch kein vollstaendig gesperrter Internet-Ausgang. CNI-/Service-NAT-Verhalten und
DNS negativ testen.

Innerhalb des Clusters benutzen die Beispielrouten HTTP. Das liefert kein mTLS zwischen Nodes: fuer
fremde Nodes/Netzsegmente Mesh, WireGuard oder TLS-Origins mit echter CA-/SNI-Pruefung vorsehen.
Niemals `noTLSVerify` aktivieren. Die bestehende Ollama-Bindung `0.0.0.0` **im isolierten Pod-Netz**
ist nicht dasselbe wie eine oeffentliche Host-Bindung. Sie blind auf Pod-Loopback zu aendern wuerde
den Servicezugriff zerstoeren. Die neuen Listener verwenden explizite Pod-IPs; Hostdienste bleiben
auf Loopback/VPN.

## D. Kyverno: ausdrueckliche Namespace-Freigabe

Vollstaendiger Code: [Requests/Limits](../k8s/base/security/require-resource-limits.yaml),
[Nicht-root/RootFS/Capabilities](../k8s/base/security/drop-root-capabilities.yaml).

Kyverno samt CRDs/Webhooks muss separat geprueft vorhanden sein. Die neuen Policies liegen
absichtlich **nicht** in `k8s/base/kustomization.yml` und werden nicht automatisch installiert. Sie
erzwingen Regeln nur in Namespaces, die ein Clusteradministrator mit
`llmops.example/security-policy=enforce` markiert hat. Erst Inventar und Audit-Modus testen, dann
bewusst Enforce. Requests/Limits gelten auch fuer Init-Container; Ephemeral-Container duerfen keine
Ressourcenfelder erhalten, muessen aber die Sicherheitsregel erfuellen.

Systemausnahmen fuer RootFS/Nicht-root benoetigen einen der benannten Namespaces `kube-system`,
`velero` oder `kyverno` **und** das administrative Namespace-Label
`llmops.example/system-exception=approved`. Kein beliebiges Pod-Label darf sich selbst ausnehmen.
Namespace-Labelrechte per RBAC begrenzen. Keine neue breite PolicyException oder ClusterRole wird
angelegt. PSS bleibt zusaetzlich aktiv; Ausnahmen in Kyverno schalten PSS nicht aus.
Policy-Engine-/Admission-Negativtests fehlen hier noch; reine Dateitests sind kein Beleg fuer
erfolgreiche Cluster-Enforcement-Abnahme.

## E. ArgoCD: bestehender Bootstrap, korrekter Quellenpfad

Vollstaendiger Code: [vorhandener Bootstrap](../scripts/bootstrap_gitops.sh),
[Artefaktvertrag](../config/gitops-bootstrap.artifacts.example.json),
[AppProject und Application](../k8s/gitops/llmops-platform-app.yaml).

Kein zweiter ungepruefter `argocd-install.yaml`-Downloadpfad wird eingefuehrt: der vorhandene
Bootstrap validiert bereits vier Downloads und Image-Digests und installiert Argo **Core**. Ablauf
siehe [GitOps-Anleitung](GITOPS_SMALL_VPS.md). Die neue Application zeigt korrekt auf
`k8s/overlays/production`, NICHT auf `stacks/llmops-platform`: Argo rendert nicht automatisch
Compose zu Kubernetes. Sie gehoert zu einem eigenen, begrenzten `llmops-core`-Projekt und wird nicht
automatisch in die existierende Root-App aufgenommen. Kein Autosync/Prune, kein
Cluster-Admin-Secret, kein Push und keine offene Argo-UI.

Commit, Image-Digests, GPU-Worker, CRDs, vorhandene Runtime-Secrets und TLS-/VPN-Ingress des
Produktions-Overlays vorher pruefen. Dessen bestehende Ingress-Datei betrifft die API, nicht die
neuen Tunnel-UI-Routen. Root-App und Cluster-Plattformrechte bleiben Admin-Review; Anwendungen
erhalten keine pauschale Berechtigung zum Installieren von Controllern.

## F. Velero: offsite, pausiert und wiederherstellbar

Vollstaendiger Code:
[StorageLocation und Schedule](../k8s/platform/velero/backup-storage-location.yaml),
[lokaler Server-/Node-Agent-Renderer](../scripts/velero_setup.sh),
[vorhandener GitHub-CLI-Installer](../scripts/tools/velero_install.sh).

Die CLI allein installiert keinen Server. Velero-Server, kompatibles AWS-/S3- Plugin und Node-Agent
zuerst aus geprueften GitHub-/OCI-Staenden samt Ressourcen, RBAC und passenden amd64/arm64-Digests
installieren. Der Node-Agent benoetigt weitreichenden Zugriff auf Pod-Volumes; diese Systemausnahme
separat pruefen, nicht als privilegienfreie Anwendung tarnen.

```bash
# Standard zeigt nur Voraussetzungen, kein Download oder Clusteraufruf.
bash scripts/velero_setup.sh

# Gepruefte Velero-1.18-CLI rendert nur; niemals direkt in kubectl pipen.
bash scripts/velero_setup.sh --render \
  --server-image DEIN_SERVER_IMAGE_MIT_SHA256_DIGEST \
  --plugin-image DEIN_KOMPATIBLES_S3_PLUGIN_MIT_SHA256_DIGEST \
  > /privat/velero.rendered.yaml
```

Der Renderer setzt Budgets fuer Server, Node-Agent und Maintenance-Jobs sowie eine parallele
Sicherung. Er liest kein Secret-File ein und fuehrt niemals `kubectl apply` aus. Gerendertes RBAC,
Host-Volumes, Restore-Helper-Image und Backup-/Restore-Jobbudgets vor einem expliziten Apply mit
eigenem Kontext pruefen. Insbesondere keine pauschale Cluster-Admin-Freigabe oder
Default-Helper-Images ungeprueft in die Produktion uebernehmen.

Danach echtes HTTPS-/S3-Ziel, Bucket und Region einsetzen. Credentials als verschluesseltes Secret
`velero/velero-cloud-credentials`, Feld `cloud`, mit AWS-Profilformat bereitstellen. Kein fake
`ENC[...]` und keine Klartextschluessel in Git. Ein MinIO auf demselben Node ist kein alleiniger
Katastrophenschutz. Serverseitige Verschluesselung, Bucketrechte und getrennte Recovery-Keys
pruefen: verschluesselte Volume-Daten bedeuten nicht automatisch verschluesselte
Kubernetes-Metadaten/Secrets im Backup-Objekt.

**Vor dem ersten FSB-Backup:** Eigenes starkes zufaelliges Repository-Passwort als verschluesselt
provisioniertes `velero/velero-repo-credentials`, Feld `repository-password`, setzen und ausserhalb
des Clusters sichern. Nicht auf den standardmaessigen gemeinsamen Repository-Schluessel vertrauen.
Eine spaetere Aenderung dieses Secrets allein macht bestehende Repositories nicht automatisch mit
dem neuen Passwort lesbar; Schluesselmigration separat planen.

Der Schedule ist **pausiert**. Nach Probe-Backup und Restore bewusst entpausieren: taeglich 02:30
UTC (03:30 MEZ bzw. 04:30 MESZ), 14 Tage TTL, `useOwnerReferencesInBackup: false`. Erst die
Entpausierung aktiviert Sicherungen. TTL kann spaeter Objekte loeschen; gesondert freigeben. Alle
Namespaces und Clusterressourcen sind eingeschlossen, FSB statt angenommener CSI-Snapshots.
K3s-local-path-Volumes sind keine automatisch unterstuetzten Cloud-Snapshots. Direkte
hostPath-Pod-Volumes werden von FSB nicht gesichert; jeden eingesetzten PVC-/PV-Typ und dessen Mount
mit einem echten Restore abnehmen. Live-DB-Konsistenz ist nicht garantiert: DB-Dumps,
Quiesce-/Hook-Konzept und separates Qdrant-/MinIO-Verfahren vor Aktivierung abstimmen.

Restore isoliert, einschliesslich Volume-Inhalt, Dateirechte, Secrets und Anwendungsstart pruefen.
Kopia-/Controller-/Sealed-Secrets-Recovery getrennt aufbewahren. Die neuen Vorlagen nicht blind
gemeinsam auf Produktion anwenden.

## Native Rollbacks und Abnahmeplan

[Toolgenaue Matrix fuer alle 49 Manifest-Eintraege](NATIVE_BUILD_RECOVERY.md). Kein neues
Buildrezept migriert oder loescht produktive Daten. Betriebssystem- Rollback, Anwendungsversion und
Datenbankschema sind getrennte Entscheidungen.

1. Offline-Dateien, Sprachschluessel, Exporter-Fixtures und gerenderte Manifeste pruefen.
2. Isolierte Ubuntu-24.04-/aarch64-Testumgebung mit echten Pins/CRDs/CNI bereitstellen.
3. Ressourcen-/Lastmessung, Nicht-Auth-/Netzwerk-Negativtests und Policy-Admission testen.
4. Getrennte SOPS-/Sealed-Secrets-/Velero-Restore-Runde abnehmen.
5. Erst dann einzelne Komponenten und Namespace-Regeln im Wartungsfenster aktivieren.

## Primaerquellen

- [Kyverno: Requests/Limits](https://kyverno.io/policies/best-practices/require-pod-requests-limits/require-pod-requests-limits/)
- [Kyverno: schreibgeschuetztes RootFS](https://kyverno.io/policies/best-practices/require-ro-rootfs/require-ro-rootfs/)
- [Cloudflare: Kubernetes und Readiness](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/deployment-guides/kubernetes/)
- [Cloudflare: Access-Pruefung am Origin](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/configure-tunnels/origin-parameters/#access)
- [Velero: Schedule-Felder](https://velero.io/docs/v1.18/api-types/schedule/)
- [Velero: S3-StorageLocation](https://velero.io/docs/v1.18/api-types/backupstoragelocation/)
- [Velero: File System Backup](https://velero.io/docs/v1.18/file-system-backup/)
- [Velero 1.18.4: Installations-/Render-Flags](https://github.com/vmware-tanzu/velero/blob/v1.18.4/pkg/cmd/cli/install/install.go)
- [Ollama: echte Zeit-/Tokenfelder aus Inferenzantworten](https://github.com/ollama/ollama/blob/main/docs/api/usage.mdx)
- [Ollama: read-only Modellinventar und size_vram](https://docs.ollama.com/api/ps)
