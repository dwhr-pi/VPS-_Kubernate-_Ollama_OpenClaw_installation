# Ressourcenschonende GitOps-Basis: fuenf konkrete Bausteine

Stand: 27.10.2026. **Implementierte Vorlagen und Skripte, keine Produktionsfreigabe.**
Bestehende Installationen, Secrets, K3s-Cluster und Nutzdaten werden hier nicht
migriert oder angefasst. Die bisherige [Baseline](PRODUCTION_BASELINE.md) bleibt
getrennt. Qdrant war bereits als Tool vorhanden; neu ist der kleine GitOps-Pfad.

## 1. Vektor-Datenbank fuer RAG/Memory

[Kustomize-Basis](../k8s/gitops/memory/kustomization.yaml),
[Qdrant](../k8s/gitops/memory/qdrant.yaml): eine Replik, 100m/128Mi Requests,
500m/512Mi Limits, 5Gi-RWO-PVC auf `local-path`, kein NodePort/Ingress.
Nicht-root, Read-only Root, abgeschalteter ServiceAccount-Token und Default-Deny.
`qdrant-auth` mit Feld `api-key` muss vorher per Sealed Secrets bereitstehen.
Ein fehlendes Secret blockiert den Start. API-Key wird nicht in Probes eingebaut.
TCP-Probes messen nur den Listener, nicht Auth, Datengesundheit oder RAG-Qualitaet.

```bash
# Lokal rendern, NICHT anwenden. Platzhalter-Digest verhindert versehentlichen Start.
kubectl kustomize k8s/gitops/memory
```

Eigenes Deployment-Overlay: Basis referenzieren, den dort aufgeloesten Namen
`registry.example.invalid/qdrant` durch ein aus gepruefter Quelle gebautes/
gescanntes Image mit SHA256-Digest ersetzen und echtes
`qdrant-auth`-SealedSecret aufnehmen. UID 10001, Config-Schema und Probeverhalten
gegen genau dieses Image pruefen. Native GitHub-Installation ist weiterhin ueber
den vorhandenen Qdrant-Installer moeglich; ein Kubernetes-Pod nutzt trotzdem OCI.

Payloads liegen auf Disk; Vektoren/HNSW sind **pro Collection** zusaetzlich mit
`on_disk: true` zu konfigurieren, wenn der gemessene Workload dies braucht.
512Mi ist ein bewusst kleines Testbudget, kein Versprechen fuer grosse Indizes.
Collection-/Embedding-Modell, Dimension, Distanzfunktion, Mandantenbindung,
Dokument-Loeschung und Wiederaufbau festschreiben. Das Backend fuer freigegebene
Clients ist `http://qdrant.ai-memory.svc.cluster.local:6333`.

OpenClaw wird nicht automatisch angebunden: ein verifizierter Adapter/MCP- oder
RAG-Dienst muss Collections, Auth und Zugriffsrechte korrekt umsetzen. Ein
`memory-client: 'true'`-Label in `ai-agents` erlaubt nur den vorgesehenen Netzpfad;
es ersetzt keine API-Authentifizierung. Andere API-/Internetziele bleiben gesperrt.

## 2. Limits, Quoten und Node-Reserve

[Agenten-Basis](../k8s/gitops/agents/kustomization.yaml),
[LimitRange/ResourceQuota](../k8s/gitops/agents/budgets.yaml): maximal 768Mi pro
Container und 1Gi pro Pod inklusive normaler Sidecars, Namespace-Limits insgesamt
2Gi. CPU und ephemeral storage werden ebenfalls begrenzt. Keine LoadBalancer
oder NodePorts. Groessere OpenClaw/n8n-Workloads benoetigen ein bewusst angepasstes
Overlay; dieses kleine Budget ist keine Abnahme dieser Anwendungen.

Quoten sind **nicht Node-weit** und verhindern nicht jeden OOM: andere Namespaces,
Hostprozesse und ungeeignete Modelle verbrauchen ebenfalls RAM. Der Bootstrap
reserviert je 512Mi fuer System/Kubernetes. Summe der Podbudgets, Allocatable,
RAM/Swap, Disk und WSL-Host-Limits vor Freigabe messen. Ein 2GiB-Free-VPS soll
nicht Modell, Argo, Datenbank und Monitoring gleichzeitig aufnehmen.

Empfohlenes Hybridbild: kleiner VPS fuer private Erreichbarkeit/Tunnel, MiniPC
fuer K3s/Argo/RAG und Ollama auf geeignetem CPU-/GPU-Worker. Der Bootstrap verlangt
als konservative Planungsreserve 4GiB RAM gesamt/2GiB verfuegbar und 12GiB Disk.
Dies betrifft nur Infrastruktur, nicht alle optionalen Workloads oder Modelle.

## 3. Sealed Secrets ohne Klartext in Git

[Kubeseal-CLI](../scripts/tools/kubeseal_install.sh): nativer GitHub-Go-Build,
gepinnt auf `c58a60f0bd5283d28c25ad068e7c9760634be470`; Go >=1.27.3.
Installation, Go-Freigabe und Fehlerbehebung: [Kubeseal-Anleitung](tools/kubeseal.md).
Der CLI-Installer installiert keinen Controller. Dessen
[GitOps-App-Beispiel](../k8s/gitops/platform/sealed-secrets-application.yaml.example)
braucht ein separat geprueftes Plattform-Projekt mit CRD-/Cluster-RBAC-Rechten
und einen wirklichen Controller-Image-Digest. Nie als unprivilegierte App tarnen.

Nach Controller-Abnahme Zertifikat mit **bewusstem Kontext** beziehen und den
Dateihash separat bestaetigen. Der Fetch liest nur den oeffentlichen Schluessel:

```bash
kubeseal --context DEIN_KONTEXT --controller-namespace kube-system \
  --controller-name sealed-secrets-controller --fetch-cert > /privat/controller.pem
sha256sum /privat/controller.pem
# Hash ausserhalb dieses Downloads abgleichen, nicht blind als Vertrauen uebernehmen.
bash scripts/seal_openclaw_secret.sh --cert /privat/controller.pem \
  --cert-sha256 DEIN_VERIFIZIERTER_SHA256 \
  --output /dein/deployment-repo/openclaw-api.sealed.yaml
```

Die letzte Zeile fragt den Key verdeckt ab; kein Key in Shell-History, argv oder
Klartextdateien. Das Skript verarbeitet Klartext nur im Speicher/stdio und nutzt
`kubeseal --scope strict --format yaml` offline. Das echte verschluesselte YAML
kann nach Review in Git; [Strukturbeispiel](../k8s/gitops/secrets/openclaw-api.sealed.yaml.example)
ist absichtlich kein erfundener gueltiger Ciphertext. Namespace/Name sind gebunden;
ein Umbenennen verlangt neues Sealing. `OPENCLAW_API_KEY` ist eine fiktive
Beispielvariable, kein hier bestaetigter OpenClaw-Konfigurationsvertrag.

Dasselbe Skript erzeugt mit `--namespace ai-memory --name qdrant-auth --key api-key`
oder `--namespace ai-monitoring --name grafana-auth --key admin-password` die
weiteren Secrets. Ciphertexte in eigene gepruefte GitOps-Secret-Apps/Overlays
aufnehmen, bevor die abhaengigen Workloads manuell synchronisiert werden.
Kubernetes Secrets liegen nach Entschluesselung im Cluster: RBAC, Node-Sicherheit
und Datastore-Verschluesselung separat absichern. Sealed Secrets ersetzt das nicht.

Controller-Privatschluessel verschluesselt ausserhalb des Clusters sichern;
ohne sie ist ein Ciphertext nach Clusterverlust nicht wiederherstellbar.
Private Schluessel, kubeconfig, Tunnel-Token und Recovery-Passwoerter nie in Git.
Nicht unverschluesselt per E-Mail versenden. Wiederherstellung isoliert testen.

## 4. Prometheus/Grafana ohne Operator-Zwang

[Helm-Chart](../charts/monitoring-lite/Chart.yaml) mit PVCs, ClusterIP, Probes,
Non-root, NetworkPolicies, kurzem TSDB-Fenster und Dashboard/Alertregeln.
Zusammen 256Mi RAM-Requests und 512Mi Limits fuer die beiden Container.
Das ist ein kleines Ausgangsbudget, kein Beleg fuer hohe Serienzahl/Last.

Ein eigenes `values.production.yaml` setzt beide echten Image-Digests,
`nodeExporterTargets`, `ollamaExporterTargets` und die genau dazu passenden
privaten `exporterCIDRs`/Ports. Es enthaelt keine Passwoerter.
Das Werte-Schema erlaubt fuer Exporter nur explizite private Host-CIDRs
(`/32` bzw. ULA-IPv6 `/128`), keine Internet-/Subnetz-Wildcards.
`grafana-auth`/`admin-password` muss vorher entschluesselt im Zielnamespace liegen.

```bash
helm template monitoring-lite charts/monitoring-lite --namespace ai-monitoring \
  -f /privat/values.production.yaml > /privat/monitoring.rendered.yaml
python3 -B scripts/quality/production_preflight.py < /privat/monitoring.rendered.yaml
kubeconform -strict -summary /privat/monitoring.rendered.yaml
```

Der Chart verweigert leere/ungueltige Digests. Default-Targets bleiben leer:
Ollama wird **nicht** ungeprueft unter `ollama:11434/metrics` gescrapt. Der Job
`ollama-exporter` erwartet einen separat abgenommenen Exporter. Dessen
Metriknamen/Labels und Kosten pruefen; keine versteckten Inferenz-Testprompts.
Alternativ Gateway-Metriken ueber den bereits vorhandenen geschuetzten
[LiteLLM-Scrape](../monitoring/prometheus.yml) integrieren. Exporter-Latenz ist
nicht automatisch Inferenz-Latenz. Node Exporter liefert CPU/RAM/Disk.

Ziele im Cluster brauchen passende Ingress-Policies am Exporter; Service-NAT
und CNI-Durchsetzung mit Negativtests pruefen. Grafana ist zunaechst nur per
lokalem Port-Forward/SSH erreichbar. Kein oeffentlicher Ingress wird angelegt.
Alertregeln zeigen lokale Alarme; Benachrichtigungen brauchen spaeter einen
konfigurierten Alertmanager. Volltext-/Prompt-Logging ist nicht aktiviert.

## 5. Bewusster GitOps-Bootstrap und App-of-Apps

[Skript](../scripts/bootstrap_gitops.sh),
[Artefaktvorlage](../config/gitops-bootstrap.artifacts.example.json),
[Tunnel-Unit](../systemd/openclaw-cloudflared.service).
Neue Menueeintraege **GitOps_Bootstrap und Kubeseal stehen nach dem bisherigen
Z-Ende**. Der Menue-Standard startet kein Infrastruktur-Apply ohne Parameter.

### Menueauswahl: Planung statt fehlgeschlagener Standardinstallation

Die Auswahl von `GitOps_Bootstrap` unter **Installieren** oeffnet jetzt einen
gefuehrten Offline-Plan. Sie fragt nach dem absoluten Pfad zur eigenen geprueften
Artefakt-JSON und der privaten IPv4-Adresse. Enter verschiebt den Schritt;
ohne Terminal wird ebenfalls ohne Installationsversuch verschoben. Bestehende
Artefakte, Dienste und Cluster bleiben unveraendert.

Das aktuelle Operationslog meldet `Status=planned` nach validierter Planung
oder `Status=skipped` bei Verschieben, nicht pauschal `failed`. Ungueltige
Pins, Pfade oder Adressen bleiben echte Planungsfehler. Es gibt keinen
Installationsmarker, keinen Installationsmesswert als Erfolg und keinen
Rollback-Lock fuer eine reine Planung. Das Tool bleibt ohne echten Bootstrap-
Nachweis folgerichtig **nicht installiert**. Der ausgegebene Apply-Befehl wird
nur angezeigt, niemals automatisch ausgefuehrt. Der Menuepunkt **Update** ist
keine Freigabe zur Cluster-Migration; den bewussten CLI-Weg unten verwenden.

Das gemeldete alte Log mit Exitcode 2 bedeutete: Der damalige Menue-Wrapper
hatte keine Parameter erhalten und brach bewusst vor dem Bootstrap ab.
Es war weder ein GitHub-Downloadfehler noch eine fehlgeschlagene K3s-Installation.
Mit den dort gemeldeten **9,9 GiB frei unter Windows** ist ein echter WSL-Apply
ohnehin noch unter der verlangten **12-GiB-Hostreserve**, auch wenn die allgemeine
4-GiB-Toolwache passiert wurde. Die Offline-Planung braucht diese Buildreserve
nicht; Apply prueft RAM, Linux-Disk und Windows-Host-Speicher separat.

Vorbereitung auf einer isolierten Ubuntu-24.04-VM bzw. systemd-faehigem WSL:
offizielle GitHub-Versionen/volle Commits samt SHA256 fuer K3s, dessen Installer,
cloudflared und Argo **Core** auswaehlen und ausserhalb des Repos als root-eigene,
nicht gruppen-/weltbeschreibbare JSON-Datei ablegen. `argocd_images` ordnet jedem
exakten Image-Namen des gewaehlten Vendor-Manifests einen geprueften Digest zu;
alle Container/Init-Container werden damit vor dem Apply deterministisch gepinnt.
Fehlende/ueberzaehlige Pins oder unbekannte Image-Zeilenformen blockieren den Lauf.
Die Vorlage enthaelt bewusst
keine erfundenen aktuellen Pins/Hashes und wird in diesem Zustand abgelehnt.
Der PSS-Vertrag ist auf v1.34 gepinnt; der Bootstrap akzeptiert K3s >=1.34.
Einen konkreten noch unterstuetzten Patchstand gesondert pruefen, nicht bloss
die Mindestversion verwenden. Es wird kein `latest` aufgeloest.
Fuer ARM `linux-arm64` und passende Assets eintragen. SHA256 schuetzt Integritaet,
ist aber ohne verifizierte Herkunft kein unabhaengiger Publisher-Nachweis.

Tunnel im eigenen Cloudflare-Konto bewusst anlegen, Token separat root:0600
unter `/etc/openclaw-gitops/cloudflared.token` bereitstellen; das Verzeichnis
muss root:0700 sein. Kein Login, Account-
Setup oder Token im Repo. Die Unit nutzt systemd `LoadCredential`/DynamicUser,
kein Token in argv/env. Cloudflared >=2025.4.0 ist erforderlich. Cloudflare Tunnel
ist ein optional gewaehlter externer Dienst, kein Auth-Ersatz: Access/SSO und
Routing im Dashboard separat konfigurieren, keine DB/Ollama-Ports publizieren.

```bash
# Nur Metadaten/Plan, keine Downloads oder Clusterabfrage:
bash scripts/bootstrap_gitops.sh --plan --artifacts /privat/artifacts.json \
  --private-address 10.7.0.2
# Erst auf ausdruecklich freigegebenem frischem Host nach Firewall-Pruefung:
sudo bash scripts/bootstrap_gitops.sh --apply --artifacts /root/artifacts.json \
  --private-address 10.7.0.2 --confirm-new-host --confirm-private-firewall
```

Private Adresse muss vorhanden sein; Flannel nutzt genau deren Schnittstelle.
API 6443 nur ueber private/VPN-Netze erreichbar machen, CNI/Kubelet ebenfalls
nicht aus dem WAN zugaenglich lassen. Der Bootstrap aendert keine Firewall.
Eine RFC1918-Adresse allein ist keine Firewallpruefung oder Verschluesselung.
VPS-zu-Heimnetz-Verkehr ueber WireGuard/private Transportwege absichern.
Unter WSL zusaetzlich das wirkliche VHDX-Hostlaufwerk pruefen; die vorhandene
Host-Speicherwache kann nur ihren erkannten Windows-Mount bewerten.

Alle vier Downloads werden vor Installation geprueft. Kein `curl | bash`.
Der heruntergeladene, hashgepruefte K3s-Installer wird erst beim Apply ausgefuehrt;
K3s/Cloudflared kommen aus GitHub-Artefakten, nicht aus Docker-Images. K3s-Workloads
nutzen danach trotzdem containerd/OCI. Vendor-Manifest und K3s-Paketimages sind
vor Produktion zusaetzlich auf Versions-/Digest-/CVE- und Signaturstand zu pruefen.
Traefik bleibt aktiv, nur ServiceLB wird deaktiviert; kein automatisches Argo-UI,
kein Ingress und kein Modell-, Ollama-, n8n- oder Agentenstart.

Argo Core spart Web-UI/SSO-Server. Verwaltung mit freigegebener Argo-CLI im
Core-Modus und explizitem Kontext; keine initialen Admin-Passwoerter ausgeben.
Der Vorbereitungsnachweis ist kein Ende-zu-Ende-Test des Tunnels, der Anmeldung
oder einer Anwendung. Wiederholung nutzt gleiche Hashes und verwalteten Zustand. Fremde Installationen,
andere Pins/Adressen oder eine lokal geaenderte Tunnel-Unit werden abgelehnt.
Ein Fehler kann einen teilweise eingerichteten Host hinterlassen: Logs pruefen
und denselben Stand fortsetzen; kein destruktives automatisches Rollback.
Updates fremder/bestehender Cluster und Deinstallation sind separate Vorhaben.

Danach [Projekte](../k8s/gitops/platform/projects.yaml) mit bewusstem Kontext
anwenden, [Root-App](../k8s/gitops/platform/root-application.yaml.example) konfigurieren
und manuell synchronisieren. Root-Quelle ist administrativ vertrauenswuerdig:
App-of-Apps kann andere Applications anlegen, ist keine Mandanten-Sandbox.
Geschuetzter Branch, Review und eingeschraenkte Repo-Zugangsdaten sind Pflicht.
Zuerst Controller/Namespaces/Secrets, dann Qdrant, dann Monitoring, anschliessend
bewusst gewaehlt Ollama/Agenten. Die drei
[Child-Apps](../k8s/gitops/apps/applications.yaml) enthalten Platzhalter und
synchronisieren weder automatisch noch mit Prune. Sync-Waves allein starten
keinen manuellen Child-Sync. Workload-Ref und spaeterer Config-Ref sind getrennte
volle Commits, damit keine unmoegliche Selbstreferenz auf den eigenen Commit entsteht.

## Persistenz, Backup und Abnahme

Local Path ist weder verteilter Speicher noch HA; Pods/PVs bleiben an Nodes
gebunden. `Prune=false,Delete=false` schuetzt vor normalem GitOps-Loeschen,
nicht vor explizitem PVC-/Nodeverlust. 5Gi auf Local Path sind keine garantierte
Dateisystemquota. Node-Disk und Windows-VHDX-Host separat ueberwachen.
Longhorn/OpenEBS nicht standardmaessig auf Free-VPS/Pi verteilen; erst mit
ausreichenden Disks, Nodes, Netzwerk und gemessenem Restorebedarf entscheiden.

Qdrant-Snapshots ueber die versionsgerechte Snapshot-API erstellen und auf ein
unabhaengiges Ziel exportieren; keine laufenden DB-Rohdateien blind kopieren.
Snapshots, Deployment-Pins, Controller-Recovery-Keys und private Konfiguration
mit Restic verschluesselt auf separaten Datentraeger/anderen Host sichern;
S3 ist optional, nicht das einzige Primaer-MinIO desselben Clusters.
Modellgewichte durch Hash-/Lizenz-/Quellenmanifest reproduzierbar halten oder
bewusst mit sichern. Die vorhandenen [Backup-Runbooks](BACKUP_AND_RESTORE.md)
weiterverwenden; das Compose-Wartungsbackup ist kein neuer K8s-PVC-Backupjob.
Restore isoliert testen, Count/Collection/Embedding-Suche pruefen und RPO/RTO
messen. Automatisierte Snapshots/Restore und Controller-Key-Backup sind noch
als betriebliche Jobs abzunehmen, nicht allein durch einen PVC erledigt.

Auch K3s selbst braucht ein Datastore-Backup. Beim hier vorgesehenen einzelnen
Server ohne `cluster-init` ist der SQLite-Pfad relevant; konsistente Sicherung
im geprueften Wartungsfenster planen. Der Server-Token unter
`/var/lib/rancher/k3s/server/token` muss ebenfalls verschluesselt gesichert und
passend wiederhergestellt werden. `k3s etcd-snapshot` ist nur fuer eingebettetes
etcd der passende Weg, nicht fuer SQLite.
[K3s-Backup-Vertrag](https://docs.k3s.io/datastore/backup-restore).

Vor Freigabe: Helm/Kustomize rendern, kubeconform mit passenden lokalen
CRD-Schemas, Auth-/RBAC-/CNI-Negativtests, zweite Installation/Abbruch-Fortsetzung,
Last-/OOM-/Disk-Tests und Restore auf frischem Ziel. 512Mi-Qdrant, Core-Controller
und nicht-root Images auf der konkreten Architektur pruefen. Diese Aenderung
fuehrt keinen Host-/WSL-/Cluster-/Provider-/Inferenztest aus.

Offline-Pruefstand: 27 gezielte GitOps-/Menue-/Sortier-Tests ohne Fehler,
davon ein Helm-Render-Test mangels installiertem Helm uebersprungen.
Die bestehenden nativen Build-/Status-Fixtures wurden ebenfalls ausgefuehrt;
der alte reine A-Z-Test wurde an die ausdrueckliche neue Endgruppe angepasst.
Registry-Check: 389 Tools/245 Profile, keine strukturellen Fehler, 813 Hinweise.
Statischer Python-Check ohne Fehler. Keine erfolgreiche Helm-/Kustomize-
Schemavalidierung oder Live-/Restore-Abnahme wird hier behauptet.

## Offizielle Referenzen

- [K3s Konfiguration](https://docs.k3s.io/installation/configuration)
- [Sealed Secrets und Recovery](https://github.com/bitnami/sealed-secrets)
- [Cloudflared Token-Datei](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/configure-tunnels/run-parameters/)
- [Argo deklarativ/App-of-Apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/)
- [Qdrant Konfigurationsschema](https://github.com/qdrant/qdrant/blob/master/config/config.yaml)
- [Bestehende Metrik-Konfiguration](../monitoring/prometheus.yml)
