# Profil: DevOps_SRE

## Zweck
Profil für Betrieb, Deployment, Logs, Monitoring, Rollback und Infrastruktur-Wartung.

## Use Cases
- K3s- und VPS-Betrieb
- GitOps- und Cluster-Wartung
- Backup, Restore und Observability

## Enthaltene Tools
- Ansible
- OpenTofu
- Helm
- Argo CD CLI
- Flux CLI
- k9s
- kubectx/kubens
- Velero
- Restic
- Uptime Kuma
- Grafana Alloy
- cAdvisor
- Node Exporter

## Installation
```bash
scripts/profiles/DevOps_SRE_install.sh
```

## Ports
- 3004 Uptime Kuma
- 8088 cAdvisor

## Modelle
- keine lokalen LLMs zwingend nötig

## Abhängigkeiten
- Docker
- optional K3s / kubectl / Helm

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: mittel
- RAM: ab 8 GB, besser 16 GB
- Storage: ab 20 GB

## Sicherheitshinweise
- Cluster- und Docker-Rechte nicht blind an Agenten geben
- Produktionssysteme nicht ohne Backup und Healthchecks ändern

## Start / Stop / Status Befehle
```bash
docker ps
kubectl get nodes 2>/dev/null || true
```

## Test-Command
```bash
bash scripts/profiles/DevOps_SRE_install.sh
```

## Deinstallation
```bash
scripts/profiles/DevOps_SRE_uninstall.sh
```
