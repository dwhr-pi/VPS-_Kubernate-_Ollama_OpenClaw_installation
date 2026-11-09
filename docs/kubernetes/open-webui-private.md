# Open WebUI auf K3s: privater Betriebsweg

Das optionale Overlay startet mit **null Replikaten** und ohne Ingress.
Es installiert weder Docker noch K3s, zieht kein Modell und aendert keine
Node-Konfiguration. Ein privater Betreiber-Overlay bleibt Voraussetzung.

## Voraussetzungen und Reihenfolge

1. K3s, funktionierende NetworkPolicy-Durchsetzung, CoreDNS und eine RWO-StorageClass
   pruefen. Den vorhandenen [Cluster-Plan](../GITOPS_DEPLOYMENT_PATH.md) verwenden.
2. Ollama und LiteLLM zuerst im passenden CPU- oder GPU-Overlay abnehmen.
   Der vorhandene Modell-PVC liegt unter `/data`, die Modelle unter
   `/data/models`, nicht unter `/root/.ollama`. Den Claim beim Wechsel
   nicht neu anlegen. CPU-Parallelitaet und Kontext anhand von RAM und
   Last messen; NVIDIA-Treiber, RuntimeClass und Device Plugin nur am RTX-Worker
   nachweisen. Keine NPU-Kompatibilitaet voraussetzen.
3. Im privaten Overlay einen geprueften Open-WebUI-Image-Digest, StorageClass,
   Cluster-DNS-Suffix und bei Bedarf den vorgesehenen Worker festlegen.
   UID/GID 10001, schreibgeschuetztes Root-Dateisystem und die Probes
   am konkreten Image pruefen. Das Image muss ohne Startskript-Downloads auskommen.
4. In `ai-webui` das Secret `open-webui-runtime` mit `session-key` und
   `inference-key` separat bereitstellen. Nur einen beschraenkten, am
   Gateway akzeptierten Schluessel nutzen, nie den LiteLLM-Master-Key.
   Bei leerer Datenbank den ersten Admin ueber das optionale Secret
   `open-webui-bootstrap` mit `email` und `password` einrichten.
   Nach erfolgreichem Login Bootstrap-Secret entfernen und neu ausrollen.
   Registrierung bleibt aus. Die zum Image passenden Variablen pruefen.
5. Erst im Staging eine Replik freigeben. Die 10 GiB fuer Open-WebUI-Daten
   sind getrennt vom Modellcache; bei SQLite nur eine Replik betreiben.
   Die Requests (250m CPU, 512 MiB RAM) und Limits (1 CPU, 2 GiB RAM)
   sind Startwerte, kein OOM-Schutz.
6. Traefik und cert-manager separat abnehmen. Fuer die optionale Route
   den vorhandenen DNS-01-Issuer `llmops-private-dns01` bereitstellen
   oder den Namen anpassen. DNS-01 erlaubt ein Let's-Encrypt-Zertifikat
   ohne oeffentlichen Dashboard-Listener. Platzhalter-Host und VPN-CIDR
   ersetzen, tatsaechliche Quell-IP am Proxy pruefen und Zugriff an der
   Host-Firewall auf WireGuard begrenzen. App-Anmeldung bleibt erforderlich.
7. Positiv- und Negativtests ausfuehren: Zugriff ueber VPN und TLS, kein
   Zugriff von aussen, kein direkter WebUI-Zugriff auf Ollama und kein
   beliebiger Internet-Egress. NetworkPolicies sind additiv; vorhandene
   Altfreigaben sowie RBAC fuer Port-Forwarding separat pruefen.

## Lokale Vorpruefung

Aus dem Checkout mit bereits geprueftem Kustomize:

```bash
bash scripts/setup-cluster.sh --plan
bash scripts/setup-cluster.sh --render open-webui
bash scripts/setup-cluster.sh --render open-webui-ingress
```

Diese Befehle rendern nur die Vorlagen; sie beweisen keine Erreichbarkeit,
TLS-Ausstellung oder Clusterkompatibilitaet. Danach die tatsaechliche private
Variante rendern und den manuellen Staging-Weg aus dem Cluster-Plan nutzen.
Der WebUI-Service bleibt ClusterIP. Das Workload-Overlay erlaubt DNS und
den authentifizierten LiteLLM-Pfad, nicht die rohe Ollama-API.

Den bestehenden Host-Voraussetzungscheck separat auf dem vorgesehenen
Linux-VPS ausfuehren: `bash scripts/setup-cluster.sh --check`.
Er ersetzt weder den StorageClass- noch den GPU-Nachweis im Cluster.

## Monitoring, Backup und Registry

- [Monitoring-lite](../../charts/monitoring-lite/) fuer Prometheus und
  Grafana weiterverwenden. Inferenzlatenz und Anfragen am LiteLLM-Gateway,
  RAM ueber Kubelet/cAdvisor und VRAM ueber DCGM erfassen. Das vorhandene
  [RTX-Dashboard](../../examples/hybrid-production-review/rtx-dashboard.json)
  setzt einen DCGM-Exporter voraus. Metriknamen und Scrape-Authentifizierung
  am eingesetzten Pin bestaetigen. Keine Prompts oder Keys in Logs.
- [Velero-Beispiele](../../k8s/platform/velero/) fuer Clusterobjekte und
  geeignete Volumes verwenden. SQLite per konsistentem Backup oder bei
  gestoppter WebUI sichern. WebUI-PVC, OpenClaw-State und Memory-Datenbank
  getrennt auf einem anderen Ziel wiederherstellen und testen. Der
  wiederbeschaffbare Ollama-Cache kann separat behandelt werden.
- Bei Registry-Limits gepruefte Digests in eine bereits betriebene private
  OCI-Registry spiegeln. K3s-Mirror-Konfiguration pro pullendem Node
  mit TLS und separater Authentifizierung verwalten. Direkten
  Upstream-Fallback bewusst testen und nur bei geschlossener Mirror-Abdeckung
  deaktivieren. Kein neuer Registry-Dienst oder Docker erforderlich.
