# Oracle VPS Hardening fuer Stalwart Mail

Der Oracle VPS ist der Mailserver-Standort. Er muss besonders sauber
abgesichert werden, weil Mailserver im Internet sichtbar sind.

## Ports

Oeffentlich noetig:

- `25/tcp` SMTP Server-zu-Server
- `465/tcp` SMTPS optional
- `587/tcp` Submission
- `993/tcp` IMAPS
- `995/tcp` POP3S optional
- `443/tcp` HTTPS fuer Web/Autodiscovery/API, nur abgesichert
- `4190/tcp` ManageSieve optional

Nicht oeffentlich:

- Stalwart Admin ohne Auth/VPN
- Control Panel Admin
- Datenbanken
- Docker Socket
- OpenClaw Gateway
- Ollama

## UFW Beispiel

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 25/tcp
sudo ufw allow 465/tcp
sudo ufw allow 587/tcp
sudo ufw allow 993/tcp
sudo ufw allow 995/tcp
sudo ufw allow 443/tcp
sudo ufw limit 22/tcp
sudo ufw enable
```

Optional ManageSieve:

```bash
sudo ufw allow 4190/tcp
```

## SSH

Empfohlen:

```text
PasswordAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
```

Admin-Zugriff bevorzugt ueber WireGuard, Tailscale oder feste Admin-IP.

## Fail2Ban / CrowdSec

Aktiviere mindestens SSH-Schutz. Mail-spezifische Logs koennen spaeter
angebunden werden, sobald Logformat und Pfade der Stalwart-Version geprueft
sind.

## Rate Limits

Setze Limits fuer:

- Login-Versuche
- SMTP Submission
- ausgehende Mails pro Account
- Verbindungen pro IP
- Attachment-Groessen

## DKIM Keys

- Private Keys niemals in Git.
- `*.key`, `*.pem`, `secrets/`, `data/`, `backups/` ignorieren.
- Backup verschluesseln.

## Backup und Restore

Sichern:

- Stalwart Datenverzeichnis
- Konfiguration ohne Secrets oder separat verschluesselt
- DKIM Keys
- Mailboxes
- Audit Logs

Teste Restore regelmaessig auf Testsystem.

## DDoS und Zustellbarkeit

Hurricane Electric/DNS allein ist kein DDoS-Schutz. Nutze:

- VPS Firewall
- Rate Limits
- CrowdSec/Fail2Ban
- Provider-Regeln
- bei groesseren Angriffen Scrubbing/BGP-Mitigation

Pruefe PTR/rDNS. Ohne passenden PTR auf `mail.example.tld` leidet die
Mailzustellung oft erheblich.
