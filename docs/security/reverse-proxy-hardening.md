# Reverse Proxy Hardening

Der Reverse Proxy ist der einzige Web-Eingang auf dem Oracle VPS.

## Erlaubte Dienste

Oeffentlich nur, wenn wirklich noetig:

- Statusseite
- n8n mit starker Auth
- GitHub Webhook Endpoint
- oeffentliche API nur mit Rate-Limit und Auth

Nur intern/VPN:

- Admin-Dashboards
- OpenClaw Gateway
- Ollama
- Home Assistant
- ComfyUI
- Kubernetes API

## Pflichtfunktionen

- TLS
- HSTS, X-Frame-Options, X-Content-Type-Options
- Rate Limits
- Request Size Limits
- Basic Auth oder OIDC
- IP-Allowlist fuer Admin
- Logging fuer CrowdSec/Fail2Ban

## NGINX Beispiel

```nginx
server {
    listen 443 ssl http2;
    server_name n8n.example.tld;

    client_max_body_size 20m;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    location / {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://127.0.0.1:5678;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Warnung

Leite niemals `127.0.0.1:11434` oder OpenClaw Gateway direkt ins Internet.
