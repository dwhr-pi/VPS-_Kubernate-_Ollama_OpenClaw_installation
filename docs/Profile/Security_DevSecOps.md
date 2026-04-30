# Profil: Security_DevSecOps

## Zweck
DevSecOps- und Hardening-Profil für Repo-, Dependency-, Container- und Secret-Scans.

## Use Cases
- Secret-Scanning
- CVE-Scans
- SBOM-Erzeugung
- Dependency- und SAST-Prüfung

## Enthaltene Tools
- Trivy
- Gitleaks
- Semgrep
- Grype
- Syft
- Fail2Ban

## Installation
```bash
scripts/profiles/Security_DevSecOps_install.sh
```

## Ports
- keine festen Pflichtports

## Modelle
- modellunabhängig

## Abhängigkeiten
- Docker für Container-Scans
- Python/Node für einzelne Scanner

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: niedrig bis mittel
- RAM: ab 8 GB
- Storage: gering

## Sicherheitshinweise
- Scans standardmäßig read-only fahren
- Shell-/Browser-Agenten nur mit Safe-Mode

## Start / Stop / Status Befehle
```bash
bash scripts/operations/security_scan.sh
```

## Test-Command
```bash
gitleaks detect --no-git --source .
```

## Deinstallation
```bash
scripts/profiles/Security_DevSecOps_uninstall.sh
```
