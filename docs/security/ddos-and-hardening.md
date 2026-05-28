# DDoS- und Hardening-Konzept

Hurricane Electric ist der bevorzugte externe Einstieg fuer Domain, DNS und
IPv6. HE ersetzt aber keinen vollstaendigen DDoS-Schutz.

## Realistische Einordnung

HE kann ein guter Internet-/IPv6-/DNS-Baustein sein. Gegen groessere Angriffe
brauchst du aber mehrere Schutzschichten:

- bewusste DNS-Eintraege
- VPS-Firewall
- Reverse Proxy mit Rate-Limits
- CrowdSec
- Fail2Ban
- getrennte Admin-Zugriffe ueber WireGuard
- Provider-Regeln
- bei grossen Angriffen externes Scrubbing/BGP-Mitigation

## Ebene 1: DNS und oeffentliche Sichtbarkeit

Lege nur Hostnamen an, die wirklich gebraucht werden.

Beispiele:

```text
status.example.tld
gitops.example.tld
n8n.example.tld
api.example.tld
admin.example.tld  nur via VPN
```

Warnung:

- Keine Wildcard-DNS-Eintraege ohne Schutz.
- Keine internen Dienste direkt veroeffentlichen.
- AAAA/A Records bewusst setzen.

## Ebene 2: Oracle VPS Firewall

Grundidee:

```bash
ufw default deny incoming
ufw default allow outgoing
ufw allow 443/tcp
ufw allow 80/tcp
ufw allow 51820/udp
ufw limit 22/tcp
```

Nutze das vorbereitete Skript zuerst im Dry-Run:

```bash
bash scripts/security/setup-ufw.sh --dry-run
```

Erst danach anwenden:

```bash
sudo bash scripts/security/setup-ufw.sh --apply
```

## Ebene 3: SSH-Haertung

Empfohlen:

- SSH Key only
- `PasswordAuthentication no`
- `PermitRootLogin no`
- optional anderer SSH-Port
- Fail2Ban SSH Jail
- Admin-Zugriff bevorzugt ueber WireGuard

## Ebene 4: Reverse Proxy

Moegliche Reverse Proxies:

- Traefik
- Caddy
- NGINX Proxy Manager
- klassisches NGINX

Pflichtfunktionen:

- TLS
- Security Headers
- Rate Limiting
- Request Size Limits
- Basic Auth oder OIDC fuer Admin-Dienste
- IP-Allowlist fuer interne Dashboards
- keine direkte Veroeffentlichung sensibler APIs

## Ebene 5: CrowdSec

CrowdSec ist der bevorzugte moderne Schutzbaustein.

Empfohlen:

```bash
sudo bash scripts/security/setup-crowdsec.sh --apply
```

Collections:

- `crowdsecurity/sshd`
- `crowdsecurity/nginx`
- `crowdsecurity/traefik`
- `crowdsecurity/linux`

## Ebene 6: Fail2Ban

Fail2Ban ist Zusatzschutz oder Fallback.

Jails:

- `sshd`
- `nginx-http-auth`
- `nginx-badbots`
- optional n8n Login-Logs, wenn sauber logbar

## Ebene 7: WireGuard Pflichtpfad

WireGuard ist die Hauptverbindung zwischen Oracle VPS und Heimnetz.

Sensible Dienste duerfen nur ueber VPN erreichbar sein.

## Ebene 8: Kubernetes/K3s

- K3s bevorzugen.
- Kubernetes API nicht oeffentlich freigeben.
- Secrets nicht in Git speichern.
- SOPS oder Sealed Secrets optional vorbereiten.
- Netzwerk-Policies verwenden.

## Ebene 9: Heimnetz-Segmentierung

Empfohlene VLANs:

| VLAN | Zweck |
|---|---|
| 10 | Infrastruktur |
| 20 | KI-Systeme |
| 30 | IoT/Home Assistant/Kameras |
| 40 | Gaeste |
| 50 | Labor/Test |

Regel:

> IoT darf nicht direkt auf Ollama, OpenClaw, NAS oder Kubernetes zugreifen.

## Ebene 10: Monitoring

Ueberwachen:

- WireGuard
- Oracle VPS
- Heimnetz-Waechter
- RTX Server
- Ollama API
- OpenClaw Gateway
- n8n
- Home Assistant
