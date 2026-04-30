# Profil: Developer_CI_CD

## Zweck
Lokaler DevOps- und CI/CD-Baukasten für Repo-Hosting, lokale Actions, IaC und Build-Werkzeuge.

## Use Cases
- lokales CI
- Self-Hosted Git
- IaC
- Kubernetes- und Docker-nahe Entwicklerworkflows

## Enthaltene Tools
- Forgejo
- Act
- Docker Buildx indirekt über Docker
- Renovate
- Ansible
- OpenTofu
- k9s
- Helm
- kubectl
- Kustomize
- Pre-Commit Hooks

## Installation
```bash
scripts/profiles/Developer_CI_CD_install.sh
```

## Ports
- 3005 Forgejo
- 2222 Forgejo SSH

## Modelle
- optional lokale Coding-Modelle

## Abhängigkeiten
- Docker
- Git
- optional Kubernetes

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: mittel
- RAM: ab 12 GB
- Storage: ab 25 GB

## Sicherheitshinweise
- Forgejo/Gitea nicht ungeschützt publizieren
- Actions und Shell-lastige Runner nur bewusst freigeben

## Start / Stop / Status Befehle
```bash
docker ps
act --help || true
```

## Test-Command
```bash
bash scripts/profiles/Developer_CI_CD_install.sh
```

## Deinstallation
```bash
scripts/profiles/Developer_CI_CD_uninstall.sh
```
