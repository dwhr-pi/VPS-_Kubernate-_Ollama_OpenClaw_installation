# Tailscale Access fuer myNextCloud

## Empfehlung

Admin-Zugriff nur ueber Tailscale/Tailnet. Oeffentlicher Zugriff, falls noetig, getrennt ueber Cloudflare Access.

## Nutzung

- Admin-URL nur im Tailnet erreichbar machen.
- SSH und Wartung nur via Tailscale.
- ACLs fuer Admin, Automation und Mobile trennen.

## Sicherheitsnotiz

Tailscale ersetzt keine App-2FA. myNextCloud-Admin-Konten trotzdem mit starken Passwoertern und 2FA schuetzen.
