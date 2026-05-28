# Kubernetes_Operator

Status: `documentation-first`

## Zweck
k3s/Kubernetes optional fuer VPS/Homelab planen, nicht als Pflichtpfad.

## Typische Aufgaben
Cluster-Preflight, Helm-Planung, Backup, Ingress, Monitoring.

## Empfohlene Tools
k3s, kubectl, Helm, Caddy/Traefik, Prometheus, Grafana, Argo CD optional.

## Erlaubte Aktionen
Dry-run Plaene, YAML-Review, Statusabfragen.

## Verbotene/gefaehrliche Aktionen
Kein Cluster-Install/Reset ohne Freigabe.

## Umgebungsvariablen
`KUBECONFIG`, keine Secrets ins Repo.

## Beispiel-Prompts
`Bewerte, ob dieses Tool besser per systemd, Compose oder k3s laufen sollte.`

## Modellvorschlaege
Ollama lokal fuer YAML/Plan-Review.

## Speicherort
`~/.openclaw_ultimate_user_data/reports/kubernetes`
