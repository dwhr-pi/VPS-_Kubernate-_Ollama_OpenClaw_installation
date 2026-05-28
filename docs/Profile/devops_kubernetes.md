# devops_kubernetes

Status: `documentation-first`

## Zweck
DevOps-, VPS- und Kubernetes-Pfade vorbereiten, ohne Kubernetes als Pflicht zu machen.

## Modelle
- Lokal/Ollama: `llama3.2:1b` fuer Checklisten
- Optional extern: Code-/Infra-Review nur mit Freigabe

## Tools
GitHub CLI, Act, Docker/Podman optional, k3s, kubectl, Helm, Caddy/Traefik, Uptime Kuma.

## Beispielprompt
`Bewerte, ob fuer dieses Setup systemd, Docker Compose oder k3s sinnvoller ist. Begruende mit Ressourcen und Risiko.`

## Sicherheitsregeln
Keine Cluster-Installation ohne explizite Zustimmung. Keine offenen Dashboards.

## Speicher-/Kostenkontrolle
Kubernetes nur bei ausreichend RAM, Speicher und Backup-Konzept.

## Workflows
Preflight -> Portcheck -> Deployment-Plan -> Backup -> Rollback -> Monitoring.

## OpenClaw-Agent
`devops-planner`: plant, prueft und dokumentiert; keine Cluster-Aenderungen ohne Human Approval.
