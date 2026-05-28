# Kubernetes_Node_Planner

## Zweck
Kubernetes-/K3s-Knoten fuer spaetere Workloads planen, ohne sie als Default zu erzwingen.

## Typische Aufgaben
- Node-Rollen, Storage und Netzwerk skizzieren.
- Ressourcenlimits und Namespaces festlegen.
- Risiken von kind, K3s und Helm unterscheiden.

## Empfohlene Tools
K3s, kubectl, Helm, Prometheus, Grafana, Velero, Tailscale.

## Hardwarebedarf und Status
Hardware: server/cluster. Status: experimental. Installationsart: Home-Server, VPS, GPU-Node.

## Datenschutz und Sicherheit
Kubernetes-Secrets nicht ins Repo. Admin-APIs nie oeffentlich freigeben.

## Beispiel-Prompt
`Entwirf einen K3s-Node-Plan fuer Monitoring, RAG und spaeter GPU-Worker mit sicheren Namespaces.`

## Modelle
Ollama: `qwen2.5-coder:7b`, `llama3.1:8b`.

## Grenzen
Keine automatische Cluster-Erstellung ohne Backup- und Netzwerkplan.
