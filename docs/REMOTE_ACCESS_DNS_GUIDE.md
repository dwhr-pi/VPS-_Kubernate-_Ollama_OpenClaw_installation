# Remote Access, DNS und Domain-Strategie

Diese Seite bündelt die drei typischen Außenanbindungs-Pfade im Setup:

- `Hurricane Electric` für DNS und Dynamic DNS
- `Tailscale` für privaten Remote-Zugriff
- `Cloudflare Tunnel` für bewusst veröffentlichte Dienste ohne offene Inbound-Ports

## Kurzentscheidung

### Wann `Hurricane Electric`?

Nutze `Hurricane Electric`, wenn du:

- deine eigene Domain selbst verwalten willst
- Dynamic DNS für eine wechselnde Heim-/MiniPC-IP brauchst
- klassische DNS-Einträge wie `A`, `AAAA`, `MX`, `TXT`, `CAA` pflegen willst

Wichtig:

- `Hurricane Electric` ist primär ein DNS-/DDNS-Pfad, kein privates Overlay-Netz wie Tailscale
- sinnvoll für `botsoft.uk`, Subdomains und DNS-seitige Kontrolle

Offizielle Quellen:

- [Hurricane Electric DNS](https://dns.he.net/)
- [Hurricane Electric DDNS Doku](https://dns.he.net/docs)

### Wann `Tailscale`?

Nutze `Tailscale`, wenn du:

- `SSH`, `Open WebUI`, `Grafana`, `Home Assistant`, `MinIO` oder ähnliche Admin-UIs nur privat erreichen willst
- keine offenen Panel-Ports im Internet möchtest
- MiniPC, VPS und weitere Hosts in ein privates Tailnet hängen willst

Wichtig:

- `Tailscale` ist kein Ersatz für öffentliche DNS-Verwaltung deiner Domain
- sehr gut für Admin-Zugriff, Debugging und private Services

Installationspfad im Repo:

```bash
bash scripts/tools/tailscale_install.sh
sudo tailscale up
```

Offizielle Quellen:

- [Tailscale Linux Install](https://tailscale.com/kb/install)
- [DNS in Tailscale](https://tailscale.com/docs/reference/dns-in-tailscale)

### Wann `Cloudflare Tunnel`?

Nutze `Cloudflare Tunnel`, wenn du:

- einzelne lokale oder interne Web-Dienste öffentlich, aber kontrolliert bereitstellen willst
- keine offenen Inbound-Ports am Host möchtest
- Cloudflare Access, Policies, WAF und DDoS-Schutz nutzen willst

Wichtig:

- gut für öffentliche Hostnamen wie `app.botsoft.uk`
- besser für veröffentlichte Webanwendungen als Tailscale
- ersetzt nicht automatisch dein DNS-Konzept, sondern ergänzt es

Installationspfad im Repo:

```bash
bash scripts/tools/cloudflared_install.sh
sudo cloudflared service install <TUNNEL_TOKEN>
```

Offizielle Quellen:

- [Cloudflare Tunnel Overview](https://developers.cloudflare.com/tunnel/)
- [Cloudflared Downloads](https://developers.cloudflare.com/tunnel/downloads/)
- [Cloudflare Tunnel Setup](https://developers.cloudflare.com/tunnel/setup/)

## Empfohlene Kombination für dieses Repo

### MiniPC / Zuhause

- `Hurricane Electric` für Domain und DDNS
- `Tailscale` für privaten Admin-Zugriff
- `Cloudflare Tunnel` nur für ausgewählte öffentliche Dienste

### VPS / produktionsnäher

- `Hurricane Electric` oder anderer DNS-Provider für öffentliche DNS-Namen
- `Tailscale` für Admin-Zugriff auf Hosts und interne UIs
- `Cloudflare Tunnel` oder Reverse Proxy für öffentliche Anwendungen

## Migration von Cloudflare DNS zu Hurricane Electric

Wenn deine Domain aktuell über Cloudflare DNS läuft und du für DNS/DDNS auf `Hurricane Electric` wechseln willst, ist der saubere Weg:

1. bestehende DNS-Zone bei Cloudflare vollständig inventarisieren
2. dieselben Records bei `dns.he.net` anlegen
3. falls genutzt: DDNS-Zielrecord bei `Hurricane Electric` als dynamisch markieren
4. Nameserver beim Registrar von Cloudflare auf `ns1.he.net`, `ns2.he.net`, usw. umstellen
5. nach Propagation prüfen, ob die Domain wirklich von HE autoritativ beantwortet wird

### Vor der Umstellung sichern

Vor dem Wechsel mindestens diese Records sichern:

- `A`
- `AAAA`
- `CNAME`
- `MX`
- `TXT`
- `CAA`
- `_acme-challenge`
- Subdomains für Apps, APIs, Mail und Tunnel

Wichtig:

- `Cloudflare Tunnel`-Hostnamen bleiben fachlich nutzbar, aber ihre DNS-Seite muss nach dem NS-Wechsel korrekt bei HE nachgebildet oder bewusst anders aufgebaut werden
- reine Cloudflare-Proxy-Funktionen des orangenen Wolkenmodus verschwinden, wenn Cloudflare nicht mehr autoritativer DNS-Anbieter ist

### Sonderfall: Cloudflare Registrar

Wenn die Domain direkt bei `Cloudflare Registrar` liegt, kannst du die Nameserver nicht einfach auf einen anderen DNS-Provider setzen. In diesem Fall musst du die Domain zuerst zu einem Registrar übertragen, der freie Nameserver-Wahl erlaubt.

Praxisfolge:

- `Cloudflare DNS` verlassen ist einfach
- `Cloudflare Registrar` verlassen braucht zusätzlich einen Registrar-Transfer

### Empfohlene Reihenfolge

1. Zone in HE vorbereiten
2. alle Records spiegeln
3. DDNS-Key in HE erzeugen
4. nur dann Nameserver beim Registrar umstellen
5. erst danach alte Cloudflare-DNS-Abhängigkeiten abbauen

### Danach sinnvoll prüfen

- antwortet `botsoft.uk` autoritativ über `he.net`?
- stimmen `A`-/`AAAA`-/`MX`-/`TXT`-Records?
- funktioniert DDNS-Update?
- funktionieren öffentliche Subdomains noch?
- wurden versehentlich Cloudflare-spezifische Schutzannahmen vergessen?

Für ein konkretes Beispiel auf dein Setup bezogen siehe auch die Beispielsektion `botsoft.uk` in [docs/DNS_DDoS_GUIDE.md](/C:/Users/danie/.codex/worktrees/50f5/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/DNS_DDoS_GUIDE.md:1).

## Praktische Zuordnung

### Privat lassen

Diese Dienste passen oft gut zu `Tailscale`:

- `SSH`
- `Open WebUI`
- `Grafana`
- `Prometheus`
- `Home Assistant`
- `MinIO Console`
- interne Entwickler- und Admin-Panels

### Öffentlich, aber abgesichert

Diese Dienste passen eher zu `Cloudflare Tunnel` oder Reverse Proxy:

- Webhooks
- OAuth-Callbacks
- öffentliche Web-Frontends
- ausgewählte Agenten- oder API-Endpunkte

### DNS-seitig mit Domain verwalten

Das passt zu `Hurricane Electric`:

- `botsoft.uk`
- `www.botsoft.uk`
- `api.botsoft.uk`
- `ha.botsoft.uk` oder andere Subdomains
- `_acme-challenge` und weitere TXT-/CAA-Einträge

## Sinnvolle Standardstrategie

1. Domain und DDNS über `Hurricane Electric`
2. private Admin-Zugriffe über `Tailscale`
3. öffentliche App-Freigaben über `Cloudflare Tunnel`

Das ist für dieses Setup meist sauberer als:

- zu viele offene Host-Ports
- Admin-Panels direkt öffentlich
- alles über nur einen einzigen Zugriffsweg lösen zu wollen

## Sicherheitsregel

- keine Tunnel-Tokens, Tailnet-Secrets oder DDNS-Keys ins Repo schreiben
- nur Vorlagen und Doku im Repo
- echte Werte in `~/.openclaw_ultimate_user_data` oder lokale Service-Dateien
