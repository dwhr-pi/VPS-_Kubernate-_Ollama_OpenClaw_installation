# DNS-Umstellung und DDoS-Schutz für botsoft.uk

Dieses Dokument beschreibt die notwendigen Schritte zur Umstellung deiner Domain `botsoft.uk` auf Hurricane Electric DNS und Maßnahmen zum Schutz vor DDoS-Angriffen und Bot-Attacken.

## 1. DNS-Umstellung von Cloudflare auf Hurricane Electric (HE.net)

Die Umstellung deiner Domain auf Hurricane Electric (HE.net) ist sinnvoll, wenn du die dynamische IP deines Letsung MiniPCs nutzen möchtest, da HE.net hervorragende Dynamic DNS (DDNS) Services anbietet. Cloudflare ist zwar auch eine Option, aber HE.net ist oft einfacher für reine DDNS-Zwecke zu konfigurieren.

**Schritte zur Umstellung:**

1.  **Cloudflare-DNS deaktivieren:**
    *   Melde dich bei deinem Cloudflare-Konto an.
    *   Navigiere zu deiner Domain `botsoft.uk`.
    *   Gehe zum Bereich "DNS" -> "Nameservers".
    *   Notiere dir die aktuellen Nameserver von Cloudflare.
    *   Ändere die Nameserver bei deinem Domain-Registrar (z.B. GoDaddy, Namecheap) von den Cloudflare-Nameservern auf die von Hurricane Electric.

2.  **Hurricane Electric DNS konfigurieren:**
    *   Melde dich bei deinem Hurricane Electric Konto an (oder erstelle ein neues unter [https://dns.he.net/](https://dns.he.net/)).
    *   Füge deine Domain `botsoft.uk` hinzu.
    *   HE.net wird dir Nameserver zuweisen (z.B. `ns1.he.net`, `ns2.he.net`). Diese musst du bei deinem Domain-Registrar eintragen.
    *   **DNS-Einträge migrieren:** Übertrage alle wichtigen DNS-Einträge (A-Records, CNAMEs, MX-Records etc.) von Cloudflare zu HE.net. Achte besonders auf:
        *   **A-Record für `botsoft.uk`:** Dieser sollte auf die aktuelle öffentliche IP-Adresse deines Letsung MiniPCs zeigen. Da diese dynamisch ist, werden wir später DDNS konfigurieren.
        *   **A-Record für `www.botsoft.uk`:** Zeigt ebenfalls auf die IP-Adresse deines MiniPCs.
        *   **CNAME-Record für `_acme-challenge.botsoft.uk`:** Für Let's Encrypt Zertifikate, falls du diese verwendest.

3.  **Dynamic DNS (DDNS) mit Hurricane Electric einrichten:**
    *   In deinem HE.net DNS-Management für `botsoft.uk`, bearbeite den A-Record für deine Hauptdomain (`@` oder `botsoft.uk`).
    *   Aktiviere die Option "Enable Dynamic DNS".
    *   HE.net wird dir einen "Update Key" generieren. Diesen Schlüssel benötigst du für das DDNS-Update-Skript auf deinem MiniPC.
    *   Das Setup-Skript (`scripts/hybrid_setup.sh` oder `scripts/install_local_only.sh`) wird ein DDNS-Update-Skript installieren, das regelmäßig deine aktuelle IP-Adresse an HE.net übermittelt. Stelle sicher, dass du den Update Key dort einträgst.

## 2. Schutz vor DDoS-Angriffen und Bot-Attacken

Auch wenn du Cloudflare als primären DNS-Anbieter verlassen hast, gibt es weiterhin Maßnahmen, die du ergreifen kannst, um deine Dienste zu schützen.

### 2.1 Firewall-Konfiguration (UFW)

Auf deinem Letsung MiniPC und allen VPS-Instanzen solltest du eine Firewall (z.B. UFW - Uncomplicated Firewall) konfigurieren, um nur notwendige Ports zu öffnen.

```bash
sudo ufw enable
sudo ufw allow ssh             # Port 22
sudo ufw allow http            # Port 80 (für Let's Encrypt)
sudo ufw allow https           # Port 443
sudo ufw allow 3000/tcp        # Beispiel: OpenClaw Port (falls geändert, anpassen)
sudo ufw status verbose
```

### 2.2 Fail2Ban (für SSH und Webserver)

Fail2Ban überwacht Logdateien auf verdächtige Aktivitäten (z.B. zu viele fehlgeschlagene Login-Versuche) und blockiert die entsprechenden IP-Adressen temporär.

```bash
sudo apt install -y fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
# Bearbeite jail.local, um z.B. SSH und Webserver zu schützen
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### 2.3 Web Application Firewall (WAF) und Rate Limiting (z.B. Nginx mit Modulen)

Wenn du einen Reverse Proxy wie Nginx vor deinen Diensten betreibst, kannst du diesen für zusätzlichen Schutz konfigurieren.

*   **Nginx Rate Limiting:** Begrenzt die Anzahl der Anfragen pro IP-Adresse, um Brute-Force-Angriffe und einfache DDoS-Angriffe abzuwehren.
    ```nginx
    # In nginx.conf http-Block
    limit_req_zone $binary_remote_addr zone=mylimit:10m rate=5r/s;

    # In server- oder location-Block
    limit_req zone=mylimit burst=10 nodelay;
    ```
*   **Nginx mit ModSecurity (WAF):** Eine Web Application Firewall kann bekannte Angriffe auf Webanwendungen erkennen und blockieren.
    *   Die Installation von ModSecurity für Nginx ist komplexer und erfordert das Kompilieren von Nginx mit dem Modul oder die Verwendung von Paketen, die es enthalten.

### 2.4 Cloudflare als Reverse Proxy (optional, aber empfohlen)

Auch wenn du Cloudflare nicht mehr als primären DNS-Anbieter nutzt, kannst du es weiterhin als Reverse Proxy vor deinen Diensten einsetzen, um von seinen DDoS-Schutzfunktionen zu profitieren. Dazu müsstest du deine A-Records bei HE.net auf die IP-Adressen der Cloudflare-Proxys zeigen lassen (was den DDNS-Vorteil von HE.net für die Hauptdomain aufhebt) oder einen Cloudflare Tunnel verwenden, der den Traffic durch Cloudflare leitet.

**Vorteile von Cloudflare als Reverse Proxy:**
*   **Automatischer DDoS-Schutz:** Cloudflare filtert den Traffic und blockiert bekannte Angriffe.
*   **WAF:** Schützt vor gängigen Web-Exploits.
*   **Rate Limiting:** Zusätzliche Kontrolle über Anfragen.
*   **Caching:** Verbessert die Performance deiner Website.

**Empfehlung:** Für den Alexa Skill und sicheren externen Zugriff auf deinen MiniPC ist der **Cloudflare Tunnel** die beste Option, da er eine sichere Verbindung ohne Port-Forwarding ermöglicht und den Traffic durch Cloudflare leitet, was einen gewissen DDoS-Schutz bietet.

## 3. Konfiguration von OpenClaw für botsoft.uk

Die `.env`- und `config.json`-Dateien für OpenClaw (siehe `scripts/config_templates/openclaw/`) sind bereits so vorbereitet, dass sie deine Domain `botsoft.uk` verwenden. Stelle sicher, dass der `DOMAIN`-Parameter in der `.env` auf `https://botsoft.uk` gesetzt ist und die `GOOGLE_REDIRECT_URI` entsprechend angepasst ist.

```ini
# .env Beispiel
DOMAIN=https://botsoft.uk
GOOGLE_REDIRECT_URI=https://botsoft.uk/auth/google/callback
```

Stelle sicher, dass du die entsprechenden DNS-Einträge bei HE.net für `botsoft.uk` und alle Subdomains, die du verwenden möchtest, korrekt konfiguriert hast. Für den Cloudflare Tunnel (falls verwendet) musst du die Tunnel-ID und das Secret in der `.env` hinterlegen und den Tunnel so konfigurieren, dass er Traffic für `botsoft.uk` an deinen lokalen OpenClaw-Dienst weiterleitet.
