# Ethical HackerGPT

## Kurzbeschreibung

`Ethical HackerGPT` ist ein defensives Sicherheitsprofil fuer autorisierte Analysen auf eigenen Systemen, lokalen Laborumgebungen und freigegebenen Repositories.

Der Fokus liegt auf:

- Audit
- Hardening
- Reporting
- lokale Lern- und Testumgebungen

Nicht Ziel dieses Profils:

- Angriffe auf fremde Systeme
- Malware
- Credential-Exfiltration
- Persistenz- oder Evasion-Techniken
- automatisierte offensive Exploit-Ketten gegen reale Ziele

## Zweck des Profils

Das Profil richtet sich an Setups mit:

- VPS
- Homelab
- Docker
- Kubernetes
- Webapps
- APIs
- GitHub-Repositories
- internen oder lokalen Netzwerken

Der Agent soll helfen, Schwachstellen strukturiert zu finden, sicher zu dokumentieren und Abhaengigkeiten, Konfigurationen und Dienste auf bekannte Risiken zu pruefen.

## Guardrails und Sicherheitsregeln

- Nur autorisierte Ziele verwenden.
- Keine Scans gegen fremde IPs oder Domains ohne explizite Freigabe.
- Keine offensive Automatisierung gegen reale Ziele.
- Standardmodus ist `audit`.
- Aktive oder aggressivere Tests nur mit explizitem Schalter.
- Die Zielmenge wird ueber eine Allowlist begrenzt.
- Wenn die Allowlist leer oder ungeeignet ist, faellt das Profil auf `127.0.0.1` und `localhost` zurueck.
- Oeffentliche Ziele werden im Schutzmodus standardmaessig blockiert.

## Typische Aufgaben

- Sicherheits-Audit fuer einen eigenen VPS
- Docker- und Kubernetes-Hardening
- SSH-, Firewall-, Fail2Ban- und Tailscale-Pruefung
- TLS- und Security-Header-Checks eigener Webdienste
- Secret- und Dependency-Scans auf eigenen Repositories
- SBOM-Erstellung
- CVE-Checks und Update-Empfehlungen
- Log-Auswertung
- Incident-Response-Vorpruefung
- nachvollziehbare Report-Erstellung

## Defensiv empfohlene Tools

### Basistools

- `nmap`
- `curl`
- `jq`
- `git`
- `whois`
- `dnsutils`
- `iproute2`
- `net-tools`
- `openssl`
- `ufw`
- `fail2ban`
- `lynis`

### Code- und Repo-Security

- `gitleaks`
- `semgrep`
- `bandit`
- `pip-audit`
- `npm audit`
- `osv-scanner`
- `trivy`
- `syft`
- `grype`
- optional `trufflehog`

### Container und Kubernetes

- `trivy`
- optional `kube-bench`
- optional `kubescape`
- optional `docker bench security`

### Web-Security im defensiven Modus

- OWASP ZAP Baseline nur gegen Allowlist-Ziele
- `nuclei` nur mit sicheren Templates und Rate-Limit
- `testssl.sh`

### Lokale Trainingsumgebungen

- OWASP Juice Shop nur lokal
- DVWA nur lokal und nicht oeffentlich erreichbar
- Referenznotizen wie HackTricks nur als Lern- und Nachschlagehilfe

## ENV-Konfiguration

Die aktuelle Profilkonfiguration basiert auf folgenden Variablen:

```env
ETHICAL_HACKER_ENABLED=false
ETHICAL_HACKER_MODE=audit
ETHICAL_HACKER_ALLOWLIST=127.0.0.1,localhost
ETHICAL_HACKER_RATE_LIMIT=low
ETHICAL_HACKER_INSTALL_LABS=false
ETHICAL_HACKER_INSTALL_OPTIONAL_TOOLS=false
ETHICAL_HACKER_OUTPUT_DIR=./reports/security
ETHICAL_HACKER_NO_PUBLIC_TARGETS=true
```

Optional nutzt das Setup zusaetzlich:

```env
ETHICAL_HACKER_ENABLE_ACTIVE_TESTS=false
```

## Setup-Verhalten

Das Installationsskript arbeitet bewusst vorsichtig:

- erstellt einen dedizierten Profil-Workspace
- liest vorhandene Profil-ENV-Werte ein
- bereinigt und validiert die Allowlist
- blockiert oeffentliche Ziele standardmaessig
- erstellt `reports/security`
- erzeugt einen Beispielreport
- installiert Standardtools modular
- installiert optionale oder riskantere Bausteine nur bei expliziter Aktivierung
- bereitet lokale Labs nur vor, startet sie aber nicht automatisch

## Rollenbeschreibung

- Name: `Ethical HackerGPT`
- Zweck: `Defensive Security Assistant`
- Modus: `Audit`, `Hardening`, `Reporting`, `Learning Lab`
- Verboten: offensive Aktionen gegen fremde Ziele

Empfohlenes Ausgabeformat:

1. Findings
2. Risiko
3. Beweis / Beobachtung
4. Empfehlung
5. Fix-Kommandos
6. Prioritaet
7. Nachtest

## Beispiel-Kommandos

### Lokaler VPS-Audit

```bash
lynis audit system
sudo ufw status verbose
sudo fail2ban-client status
```

### Repo-Secret-Scan

```bash
gitleaks detect --source . --no-git
trivy fs .
```

### Docker-Image-Scan

```bash
trivy image my-local-image:latest
syft my-local-image:latest
grype my-local-image:latest
```

### Kubernetes-Hardening-Check

```bash
kubectl get pods -A
trivy k8s --report summary cluster
```

### TLS-Check einer eigenen Domain

```bash
openssl s_client -connect example.internal:443 -servername example.internal
```

### Webapp-Baseline gegen localhost

```bash
curl -I http://127.0.0.1:3000
nmap -Pn 127.0.0.1
```

## Beispielprompts

- `Pruefe meinen Ubuntu-VPS im Audit-Modus auf offensichtliche Hardening-Luecken und strukturiere das Ergebnis nach Findings, Risiko und Fix-Kommandos.`
- `Analysiere dieses Repository auf Secrets, unsichere Dependencies und typische Konfigurationsschwaechen.`
- `Erstelle eine SBOM fuer mein Docker-Image und bewerte bekannte Risiken fuer den produktiven Betrieb.`
- `Bewerte meine Webserver-Header und TLS-Konfiguration fuer meinen eigenen Dienst auf localhost.`
- `Erzeuge aus den Findings einen priorisierten Nachtest-Plan fuer mein Homelab.`

## Grenzen des Profils

- kein Ersatz fuer einen manuellen Security-Review
- keine Freigabe fuer offensives Vorgehen
- keine rechtliche Bewertung
- keine Zusicherung vollstaendiger Abdeckung aller Schwachstellen
- keine automatisierte Ausweitung des Scopes ueber die Allowlist hinaus

## Verwandte Dateien

- [Ethical_HackerGPT_RUNBOOK.md](./Ethical_HackerGPT_RUNBOOK.md)
- [scripts/profiles/Ethical_HackerGPT_install.sh](../../scripts/profiles/Ethical_HackerGPT_install.sh)
- [docs/Profil/.env.template](./.env.template)
