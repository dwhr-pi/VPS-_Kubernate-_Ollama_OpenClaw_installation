# Profil: AI_Governance_Audit

## Zweck

Nachvollziehbarkeit, Auditierbarkeit, Secret- und SBOM-Checks sowie AI-Governance-nahe Dokumentation fuer lokale und serverseitige Setups.

## Installierbare Kern-Tools

- `gitleaks`
- `semgrep`
- `trivy`
- `syft`
- `grype`
- `openlit`

## Optionale / noch nicht sauber verdrahtete Tools

- spaeter sinnvoll: `SOPS`, `age`, `OpenBao`, Policy-as-Code, Modellkarten und Datenkarten

## Hardware / Plattform

- gut fuer `VPS`, `Workstation`, `Kubernetes`
- kaum GPU-Bedarf

## Risiken und Grenzen

- kein Ersatz fuer formale Rechts- oder Compliance-Beratung
- Auditdaten und Findings vertraulich behandeln

## Quickstart

```bash
bash scripts/profiles/AI_Governance_Audit_install.sh
```
