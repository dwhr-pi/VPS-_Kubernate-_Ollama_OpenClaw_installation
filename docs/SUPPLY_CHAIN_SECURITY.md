# Supply Chain Security

## Grundregeln

- Keine ungeprueften `curl | bash` Installer.
- GitHub-Quelle, Lizenz und Release pruefen.
- Versionen pinnen, wo moeglich.
- Keine Secrets in Git.
- SBOM optional mit Syft.
- Vulnerability Scan optional mit Grype/Trivy.
- Signaturen optional mit Cosign pruefen.

## Checks

```bash
bash scripts/security/check_supply_chain.sh
bash scripts/security/check_secrets.sh
bash scripts/security/check_containers.sh
```

## Python/npm/pnpm

- Projekt-venv bevorzugen.
- Lockfiles respektieren.
- Cloud-/API-Keys nie in Testdaten.
- Warnung bei postinstall/build scripts beachten.
