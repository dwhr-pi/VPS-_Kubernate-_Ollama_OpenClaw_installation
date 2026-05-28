# Stalwart Mail im Ultimate KI Setup

Diese Integration nutzt `stalwartlabs/stalwart` als selbst gehosteten
Mailserver-Kern fuer eigene Domains auf einem Oracle VPS mit Hurricane Electric
DNS.

Upstream:

- `https://github.com/stalwartlabs/stalwart`

Wichtig: Stalwart soll nicht hart geforkt oder umgebaut werden. Das Setup baut
eine eigene Integrationsschicht davor:

- Dokumentation und sichere Betriebsprofile
- `mail-control-panel` als spaeteres eigenes Admin-/Agent-Modul
- OpenClaw/Ollama-Agent fuer Mailboxen, Aliase, Regeln und Entwuerfe
- n8n/Home-Automation optional

## Warum Stalwart?

Stalwart ist ein moderner Mailserver mit Unterstuetzung fuer:

- SMTP
- IMAP
- POP3
- JMAP
- CalDAV
- CardDAV
- WebDAV
- DKIM
- SPF
- DMARC
- ARC
- Webadmin

## Unterschied zu Mailcow/Mailu

Mailcow und Mailu sind komplette Mail-Stacks mit vielen Containern und starker
Vorkonfiguration. Stalwart ist hier als schlankerer, moderner Mailserver-Kern
gedacht, auf dem wir eine eigene KI-faehige Verwaltungsschicht aufbauen.

| Punkt | Stalwart | Mailcow/Mailu |
|---|---|---|
| Rolle im Setup | Mailserver-Kern | kompletter Mail-Stack |
| Anpassung | Integrationsschicht daneben | Stack-Konfiguration |
| KI-Agent | eigener Layer geplant | muesste separat angebunden werden |
| Updates | Upstream moeglichst unveraendert | Stack-Updates beachten |

## Zielbetrieb

```text
Hurricane Electric DNS
  -> mail.example.tld
  -> Oracle VPS
  -> Stalwart Mail Server
  -> mail-control-panel
  -> OpenClaw/Ollama Mail-Agent
```

## Was darf oeffentlich erreichbar sein?

Typische Mailports:

- `25/tcp` SMTP Server-zu-Server
- `465/tcp` SMTPS optional
- `587/tcp` Submission fuer Clients
- `993/tcp` IMAPS
- `995/tcp` POP3S optional
- `443/tcp` Webadmin/Webmail/API nur abgesichert
- `4190/tcp` ManageSieve optional

Admin-Webinterface und Control Panel sollen bevorzugt nur ueber WireGuard,
Tailscale, eingeschraenkte IPs oder starke Auth erreichbar sein.

## Was niemals automatisch passieren darf

- kein offenes Relay
- kein Catch-all als Default
- kein oeffentliches Admininterface ohne Schutz
- keine KI-Antworten automatisch senden
- keine Passwoerter im Klartext speichern
- keine DKIM Private Keys ins Git committen

## KI-Agent Grundregel

Der KI-Agent darf:

- E-Mails zusammenfassen
- Spam-/Phishing-Risiko markieren
- Antwortentwuerfe erstellen
- Regeln vorschlagen
- DNS-Konfiguration erklaeren
- Mailbox-/Alias-Aenderungen vorbereiten

Der KI-Agent darf nicht ohne Freigabe senden oder produktive Aenderungen
durchfuehren.

## Web.de/GMX Import

Web.de/GMX werden nicht nativ gehostet, sondern per IMAP abgerufen oder
importiert. Zugangsdaten liegen nur lokal oder in einem Secret Store, niemals im
Repository.

## Produktiv-Checkliste

- [ ] PTR/rDNS beim VPS-Provider korrekt gesetzt
- [ ] HE DNS: MX, A/AAAA, SPF, DKIM, DMARC gesetzt
- [ ] TLS-Zertifikate aktiv
- [ ] Port 25 beim Provider erlaubt
- [ ] Stalwart kein offenes Relay
- [ ] DKIM Private Keys ausserhalb von Git
- [ ] Admin-Web nur via VPN/IP-Allowlist/Auth
- [ ] Fail2Ban/CrowdSec/Rate-Limits aktiv
- [ ] Backups und Restore-Test vorhanden
- [ ] Logging ohne unnoetige Mailinhalte
- [ ] KI-Agent sendet nicht automatisch

## Wichtige Dateien

- [docker-compose.stalwart.yml](docker-compose.stalwart.yml)
- [DNS mit Hurricane Electric](config/dns-he-net.example.md)
- [DKIM/SPF/DMARC](config/dkim-spf-dmarc.example.md)
- [Oracle VPS Hardening](config/oracle-vps-hardening.md)
- [Mail Agent Spec](agent/mail-agent-spec.md)
- [OpenClaw Mail Profil](agent/openclaw-mail-profile.md)
- [Backend Plan](backend/README.md)
- [Frontend Plan](frontend/README.md)
