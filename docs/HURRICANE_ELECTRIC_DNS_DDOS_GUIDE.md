# Hurricane Electric DNS/DDNS und DDoS-Hinweise

Hurricane Electric ist im neuen Standardpfad der bevorzugte externe DNS-/IPv6-
und Domain-Einstieg. Cloudflare bleibt optional, aber nicht Pflicht.

## HE DNS/DDNS

Nutze HE fuer:

- A/AAAA Records
- MX Records
- DDNS fuer dynamische Ziele
- IPv6-Kontext

## DDoS realistisch einordnen

HE DNS ist kein vollstaendiger DDoS-Schutz. Plane zusaetzlich:

- UFW/nftables auf dem Oracle VPS
- Reverse Proxy Rate-Limits
- CrowdSec/Fail2Ban
- keine Admin-Panels oeffentlich
- SSH nur ueber WireGuard/Tailscale/Allowlist
- bei grossen Angriffen Provider-Schutz oder externes Scrubbing

## DDNS mit ddclient

`ddclient_he` ist als planned Tool registriert. Konkrete Zugangsdaten muessen
lokal gespeichert werden, niemals im Repository.

## Admin-Panels

Nicht oeffentlich:

- OpenClaw Gateway
- Ollama
- Home Assistant
- Kubernetes API
- ComfyUI
- Stalwart Admin
- Datenbanken
