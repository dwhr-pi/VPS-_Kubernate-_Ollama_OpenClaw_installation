# Security Policy

## Grundsatz

Dieses Projekt ist local-first und sicherheitsbewusst. Es akzeptiert keine echten Secrets im
Repository.

## Nicht erlaubt

- echte API-Keys
- Tokens
- Passwoerter
- private SSH-Keys
- produktive `.env`
- sensible personenbezogene Daten

## Meldung von Sicherheitsproblemen

Bitte keine sensiblen Details in oeffentlichen Issues posten. Erstelle stattdessen einen privaten
Kontaktweg ueber den Maintainer oder einen minimalen, nicht-ausnutzbaren Hinweis im Issue.

## Erwartete Defaults

- Dienste binden lokal an `127.0.0.1`.
- Remotezugriff bevorzugt via WireGuard/Tailscale oder bewusst gehaertetem Reverse Proxy.
- Cloudflare Access/Tunnel ist optional, aber nicht Pflichtbestandteil.
- Docker-/Podman-Sockets nicht oeffentlich freigeben.
- Agenten standardmaessig read-only.
- Schreibende Aktionen nur mit Human Approval.

## Kubernetes: Gateway und Tokens

- Ollama und OpenClaw nicht direkt per NodePort, LoadBalancer oder Host-Port
  exponieren. Privater Ingress ueber WireGuard mit TLS und Gateway-Authentifizierung.
- Default-Deny fuer Ingress und Egress; erlaubte Pfade in beiden Namespaces
  abnehmen. Pods und Namespace-Labels vor unbefugten Aenderungen schuetzen.
- Port-Forwarding per RBAC begrenzen: `create` auf `pods/portforward` nicht
  an Agenten oder normale Nutzer vergeben. Auch `pods/exec`, Pod-Erstellung und
  Secret-Zugriff separat einschraenken. NetworkPolicies ersetzen diese Rechtepruefung nicht.
- Tokens via `secretKeyRef` aus separat bereitgestellten Secrets beziehen.
  Bei Rotation neues Secret bereitstellen, betroffene Pods kontrolliert neu
  starten, neuen Zugriff pruefen, danach alten Token widerrufen. Keine
  Tokenwerte in Logs, Git oder Befehlsargumenten.

## Besonders sensible Bereiche

- `scripts/security/`
- `scripts/tools/`
- `scripts/wireguard/`
- `tools/mail/`
- `config/`
- `.github/`

Fuer diese Bereiche sollen PRs besonders sorgfaeltig geprueft werden.

## Security PRs

Security-PRs sind willkommen, wenn sie defensiv, autorisiert und nachvollziehbar sind.

## Source-Builds und Nachweise

- Neue Build-Freigaben brauchen GitHub-Quell-URL, vollen Commit, Lockfiles,
  Artefakt-SHA256 und SBOM mit Build-/Compiler-Version. Ein Git-Commit ersetzt
  keinen Hash fuer heruntergeladene Modelle oder Bootstrap-Artefakte.
- Bewegliche Branches und Tags sind kein unveraenderlicher Produktions-Pin.
  Neue aktive Deployments verwenden gepruefte Image-Digests; Platzhalter
  bleiben bis zur Freigabe deaktiviert. Abhaengigkeitsupdates erneut testen.
- SBOM und Scanbericht duerfen keine privaten Buildpfade oder Zugangsdaten
  enthalten. Vorhandene Trivy-Gates nicht abschwaechen; SBOM-Pflicht ist ein
  neuer Freigabevertrag, keine Behauptung vollstaendiger Altbestand-Abdeckung.
- Rotation umfasst API-, Gateway-, WireGuard-, SOPS- und Release-Schluessel
  je eigenem Runbook. Bei Verdacht zuerst Zugriff sperren, neu bereitstellen,
  Verbraucher pruefen und alten Schluessel widerrufen; private Signierschluessel
  niemals fuer einen Diagnosebericht auslesen oder ins Repository kopieren.
- Restore-Nachweise enthalten Zeit, Artefakt-/Manifest-Hash, Umfang und Ergebnis.
  Produktionsnachweis erfordert DB-konsistente Daten, getrennte Schluessel und
  Wiederherstellung auf separatem Ziel. Synthetische Fixtures und Dateialter
  sind ausdruecklich kein Offsite-/DB-/PVC-Nachweis.
- NetworkPolicy-Standard: Default-Deny in beide Richtungen, DNS und benoetigte
  Servicepfade explizit, CNI-Durchsetzung und unerlaubte Verbindungen negativ
  testen. Kein Host-Netz, privilegierter Agent oder ServiceAccount-Token als
  Abkuerzung. Egress zu Cloud/Metadatenzielen nicht pauschal freigeben.

Die Diagnose liest standardmaessig keine privaten Dateien. Host-/HTTP-Probes
erfordern explizit `--runtime`, Dateirechte nur `--secret-metadata`.
Grenzen, Exit-Codes und Restore-Fixture:
[Betriebsreview](docs/REVIEW-2026-11-11.md).
