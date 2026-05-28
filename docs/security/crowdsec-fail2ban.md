# CrowdSec und Fail2Ban

CrowdSec ist der bevorzugte moderne Schutz. Fail2Ban bleibt als Fallback oder
Zusatzschutz sinnvoll.

## CrowdSec installieren

Dry-Run:

```bash
bash scripts/security/setup-crowdsec.sh --dry-run
```

Anwenden:

```bash
sudo bash scripts/security/setup-crowdsec.sh --apply
```

Empfohlene Collections:

```bash
sudo cscli collections install crowdsecurity/sshd
sudo cscli collections install crowdsecurity/nginx
sudo cscli collections install crowdsecurity/traefik
sudo cscli collections install crowdsecurity/linux
```

## Bouncer

Je nach Proxy:

- Firewall Bouncer
- NGINX Bouncer
- Traefik Bouncer

## Fail2Ban installieren

```bash
bash scripts/security/setup-fail2ban.sh --dry-run
sudo bash scripts/security/setup-fail2ban.sh --apply
```

Empfohlene Jails:

- `sshd`
- `nginx-http-auth`
- `nginx-badbots`

## Hinweis

CrowdSec und Fail2Ban ersetzen keine saubere Firewall. Sie reagieren auf
Angriffe, aber sie sollten nicht die erste und einzige Schutzlinie sein.
