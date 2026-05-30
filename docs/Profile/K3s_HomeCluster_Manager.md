# K3s HomeCluster Manager

## Status

- Standardstatus: planned / documentation-first
- Automatische Installation: nein
- Ressourcenklasse: heavy
- Zielhost: WSL2 / MiniPC / Oracle VPS

## Zweck

K3s Homecluster, Worker, Labels, Network Policies und GPU-Nodes.

## Tools

- k3s
- helm
- kubectl
- kustomize

## Sicherheitsgrenzen

- Keine schweren Installationen ohne explizites Opt-in.
- Keine Secrets in Repo, Logs oder Queue-Kommandos.
- Admin-Dienste nur lokal oder ueber WireGuard/Tailscale/Reverse Proxy mit Auth.

## Checks vor Aktivierung

- `bash scripts/check_resource_budget.sh`
- `bash scripts/check_secrets.sh --dry-run`
- `bash scripts/check_ports.sh`
- Falls Queue: `bash scripts/queue/queue_status.sh`

## TODO vor stable

- Installer, Uninstaller, Doctor, Portdoku, Rollback und Testmatrix ergaenzen.
