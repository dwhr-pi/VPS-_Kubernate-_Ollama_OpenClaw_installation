# Profil: DevOps_SRE_Agent

## Zweck
SRE-/Ops-Profil für CI/CD, Hardening, Containerbetrieb, IaC und Healthchecks.

## Use Cases
- Healthchecks
- Host-/Container-Härtung
- IaC
- K3s- und Docker-Betrieb

## Enthaltene Tools
- Docker
- K3s
- kubectl
- Helm
- Kustomize
- Ansible
- OpenTofu
- Renovate
- Uptime Kuma
- Healthchecks
- Watchtower
- CrowdSec
- UFW

## Installation
```bash
scripts/profiles/DevOps_SRE_Agent_install.sh
```

## Ports
- 3004
- 8004

## Modelle
- keine Pflichtmodelle

## Abhängigkeiten
- Docker
- Linux-Host

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: mittel
- RAM: 12 GB+
- Storage: 20 GB+

## Sicherheitshinweise
- Auto-Updates über Watchtower bewusst nutzen
- Firewall-Regeln dokumentieren

## Start / Stop / Status Befehle
```bash
docker ps
```

## Test-Command
```bash
bash scripts/profiles/DevOps_SRE_Agent_install.sh
```

## Deinstallation
```bash
scripts/profiles/DevOps_SRE_Agent_uninstall.sh
```
