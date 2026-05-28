# Security

## Grundregeln

- Keine Secrets ins Repo.
- Dienste standardmaessig nur auf `127.0.0.1`.
- Remotezugriff via Tailscale oder Cloudflare Access.
- Firewall aktivieren.
- SSH mit Keys, kein Passwortlogin auf VPS.
- Security-Tools defensiv nutzen.

## Empfohlene Bausteine

- UFW
- Fail2ban oder CrowdSec
- Gitleaks/TruffleHog
- Trivy/Grype/Syft
- Pi-hole/AdGuard Home

## Human Approval

Pflicht fuer:

- Security-Aktionen
- Smart Home
- Robotik
- Trading/Web3
- Browser-Agenten
- externe APIs
