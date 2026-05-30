# Port Security Matrix

| Port | Dienst | Oeffentlich? | Hinweis |
|---|---|---|---|
| 22/tcp | SSH | nur Allowlist/VPN | `ufw limit`, Key-only |
| 25/tcp | SMTP | ja, Mailserver | nur Mailserver, kein Relay |
| 80/tcp | HTTP | ja | Redirect/ACME/Proxy |
| 443/tcp | HTTPS | ja | Reverse Proxy |
| 465/tcp | SMTPS | optional | Mailclient |
| 587/tcp | Submission | ja | Auth erforderlich |
| 993/tcp | IMAPS | ja | TLS |
| 995/tcp | POP3S | optional | TLS |
| 4190/tcp | ManageSieve | optional/VPN | nur wenn gebraucht |
| 11434/tcp | Ollama | nein | nur lokal/VPN |
| 18789/tcp | OpenClaw Gateway | nein | nur lokal/VPN |
| 6443/tcp | Kubernetes API | nein | nur VPN/Admin |
| 8123/tcp | Home Assistant | nein | nur VPN/Proxy mit Auth |
| 8188/tcp | ComfyUI | nein | nur lokal/VPN |
| 5678/tcp | n8n | nur Proxy/Auth | kein offenes Admin |

Grundregel: Nur Reverse Proxy, WireGuard und echte Mailports duerfen bewusst
oeffentlich sein. Alles andere bleibt intern.
