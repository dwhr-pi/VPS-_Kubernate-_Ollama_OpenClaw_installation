# Profil: Compliance_Privacy

## Zweck
Profil für DSGVO, EU-AI-Act-nahe Governance, Auditierbarkeit und Security-Checks.

## Use Cases
- Secret-Scans
- Policy-Prüfungen
- Modell- und Datenquellen-Dokumentation
- Sicherheitsprüfungen vor Releases

## Enthaltene Tools
- Open Policy Agent
- Gitleaks
- TruffleHog
- Syft
- Grype
- Trivy
- Semgrep

## Installation
```bash
scripts/profiles/Compliance_Privacy_install.sh
```

## Ports
- keine festen Ports nötig

## Modelle
- keine lokalen Modelle erforderlich

## Abhängigkeiten
- Git
- Docker optional

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: niedrig bis mittel
- RAM: ab 6 GB
- Storage: ab 8 GB

## Sicherheitshinweise
- Findings erst prüfen, dann automatisiert handeln
- Reports können sensible Informationen enthalten

## Start / Stop / Status Befehle
```bash
trivy --version 2>/dev/null || true
gitleaks version 2>/dev/null || true
opa version 2>/dev/null || true
```

## Test-Command
```bash
bash scripts/profiles/Compliance_Privacy_install.sh
```

## Deinstallation
```bash
scripts/profiles/Compliance_Privacy_uninstall.sh
```
