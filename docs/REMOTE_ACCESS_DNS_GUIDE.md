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
- [Subnet routers](https://tailscale.com/kb/1019/subnets)
- [Tailscale CLI](https://tailscale.com/docs/reference/tailscale-cli)
- [Install Tailscale on Android](https://tailscale.com/docs/install/android)
- [Install Tailscale on Apple TV](https://tailscale.com/kb/1280/appletv)

### Tailscale: `subnet routes` vs. `advertised routes`

Diese beiden Begriffe werden oft verwechselt, meinen aber nicht ganz dasselbe:

- `advertised routes` ist der uebergeordnete Tailscale-Begriff fuer Netze, die ein Geraet dem Tailnet anbietet
- `subnet routes` sind die konkreten LAN- oder VLAN-Netze hinter diesem Geraet, zum Beispiel `192.168.178.0/24` oder `10.10.20.0/24`

Praktisch bedeutet das:

- mit `tailscale up --advertise-routes=192.168.178.0/24` bewirbst du eine `subnet route`
- das Geraet wird damit zum `subnet router`
- andere Tailnet-Geraete koennen dann auch Ziele erreichen, auf denen selbst kein Tailscale installiert ist, etwa Drucker, Kameras, NAS, Smart-TV, AV-Receiver oder lokale IoT-Webinterfaces

Sinn und Zweck:

- `normales Tailscale`: direkter Zugriff nur auf Geraete, auf denen Tailscale selbst laeuft
- `subnet router`: Zugriff auch auf das restliche Heim- oder Standortnetz hinter einem Tailscale-Knoten

Wichtig:

- die beworbenen Routen muessen im Tailscale-Adminbereich freigegeben werden oder per `autoApprovers` erlaubt sein
- auf Linux braucht ein echter `subnet router` in der Regel aktiviertes IP-Forwarding
- `advertised routes` sind nicht dasselbe wie ein `exit node`

### Unterschied zu `exit nodes`

Ein `subnet router` leitet nur Verkehr fuer bestimmte interne Netze weiter, zum Beispiel:

```bash
sudo tailscale up --advertise-routes=192.168.178.0/24
```

Ein `exit node` leitet den gesamten Internetverkehr eines entfernten Clients ueber dieses Geraet:

```bash
sudo tailscale up --advertise-exit-node
```

Wann was sinnvoll ist:

- `subnet router`: wenn du zu Hause oder im Buero interne Systeme ohne Tailscale-App erreichen willst
- `exit node`: wenn Handy, Tablet oder Notebook unterwegs so arbeiten sollen, als waeren sie im Heimnetz oder ueber den Heimanschluss im Internet

Beides kann auf demselben Geraet kombiniert werden, wenn der Host stabil genug ist und sauber abgesichert wurde.

### Typisches Beispiel fuer dieses Repo

MiniPC zuhause mit Heimnetz `192.168.178.0/24`:

```bash
sudo tailscale up --advertise-routes=192.168.178.0/24
```

Das ist sinnvoll, wenn du von unterwegs zugreifen willst auf:

- `Home Assistant`
- Webinterfaces von NAS, Drucker, Router oder Kameras
- nicht direkt Tailscale-faehige Smart-Home-Geraete
- lokale Admin-Dienste auf weiteren Maschinen im Heimnetz

Wenn du zusaetzlich willst, dass dein Handy unterwegs den Heimanschluss als Internet-Ausgang nutzt:

```bash
sudo tailscale up --advertise-routes=192.168.178.0/24 --advertise-exit-node
```

### Handy und Tablet mit Tailscale einrichten

Fuer `iPhone`, `iPad`, `Android-Handy` und `Android-Tablet` ist der direkte Weg am saubersten:

1. Tailscale-App installieren
2. mit demselben Tailnet anmelden
3. pruefen, ob der MiniPC oder VPS in der Geraeteliste sichtbar ist
4. bei Bedarf `Use Exit Node` oder `Exit Node` aktivieren
5. interne Weboberflaechen direkt ueber Tailnet-IP, MagicDNS oder ueber die freigegebene `subnet route` aufrufen

Sinnvoll fuer mobile Geraete:

- privater Zugriff auf `Open WebUI`, `Grafana`, `Home Assistant` oder `SSH`
- Nutzung des Heimanschlusses als `exit node` in fremden WLANs
- Zugriff auf Drucker, NAS oder lokale IP-Kameras ueber einen `subnet router`

### TV und andere Geraete ohne oder mit eingeschraenktem Tailscale-Support

Hier muss man drei Faelle unterscheiden:

- `Apple TV`: Tailscale-App wird offiziell unterstuetzt
- `Android TV`: Tailscale wird offiziell auf Android 8.0+ inklusive Android TV unterstuetzt
- viele andere Smart-TVs, Streaming-Boxen oder IoT-Geraete: kein nativer Tailscale-Client

Wenn ein TV oder Geraet keinen nativen Tailscale-Client hat, gibt es zwei typische Wege:

1. `subnet router`
   Dann bleibt das TV im normalen Heimnetz, und deine anderen Tailscale-Geraete koennen dieses TV oder seine Weboberflaeche ueber das Heimnetz erreichen.

2. vorgeschalteter Router oder Gateway mit Tailscale
   Ein Router, MiniPC, Raspberry Pi oder kleines Gateway-Geraet im selben Netz kann Tailscale sprechen und als `subnet router` oder `exit node` dienen.

Wichtig dabei:

- das Geraet ohne Tailscale wird dadurch nicht selbst Teil des Tailnets
- erreichbar wird es ueber das Netz hinter dem `subnet router`
- fuer echte ausgehende Nutzung ueber Tailscale braucht das Endgeraet entweder einen eigenen Client oder einen vorgeschalteten Router, der den Verkehr entsprechend fuehrt

### Wann ein `subnet router` besonders sinnvoll ist

Ein `subnet router` passt sehr gut, wenn du:

- Smart-Home-Geraete ohne eigene Tailscale-App nutzen willst
- Kameras, Drucker oder NAS nicht oeffentlich exponieren moechtest
- Handy und Tablet privat ins Heimnetz holen willst
- einen TV, AV-Receiver oder andere lokale Mediengeraete remote indirekt erreichen moechtest

### Sicherheits- und Praxis-Hinweise

- Admin-Oberflaechen trotzdem nur gezielt freigeben, nicht pauschal das ganze LAN unnoetig gross bewerben
- moeglichst nur die wirklich benoetigten Netze per `--advertise-routes` freigeben
- bei mehreren Standorten auf ueberschneidende Netze achten, zum Beispiel nicht mehrfach dasselbe `192.168.0.0/24`
- `subnet routes` loesen keinen DNS- oder Reverse-Proxy-Bedarf fuer oeffentliche Dienste
- fuer Web-Apps mit oeffentlicher Domain bleibt `Cloudflare Tunnel` oder ein sauberer Reverse Proxy oft die bessere Ergaenzung

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
