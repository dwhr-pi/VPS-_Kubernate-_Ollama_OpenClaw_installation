# Auth, OIDC, Helm-Werte und Secrets

## Kurzfassung

OIDC ist kein einzelnes Tool, sondern ein Login-Standard. Tools wie Authentik, Authelia oder Keycloak koennen diesen Standard bereitstellen.

Helm-Werte sind Kubernetes-Konfigurationen fuer eine Anwendung. OIDC-Secrets sind Login-Geheimnisse wie Client-Secrets, Session-Secrets oder Token-Schluessel. Sie sind vergleichbar mit `.env`-Werten, gehoeren aber im Kubernetes-Betrieb in `values.yaml`, Secret-Dateien oder Kubernetes-Secrets.

## Was sind Helm-Werte?

Helm installiert Anwendungen in Kubernetes ueber Charts. Eine `values.yaml` steuert, wie die Anwendung ausgerollt wird.

Beispiel:

```yaml
ingress:
  enabled: true
  host: clawbake.example.com

resources:
  requests:
    cpu: 250m
    memory: 512Mi

postgresql:
  host: postgres
  database: clawbake
```

Das ist im Prinzip die Kubernetes-/Helm-Variante unserer `.env.template`-Dateien.

## Was sind OIDC-Secrets?

OIDC bedeutet OpenID Connect. Es baut auf OAuth2 auf und erlaubt Single Sign-On fuer Webanwendungen.

Typische OIDC-Werte:

```env
OIDC_ISSUER_URL=https://auth.example.com/application/o/clawbake/
OIDC_CLIENT_ID=clawbake
OIDC_CLIENT_SECRET=change-me-outside-repo
OIDC_REDIRECT_URI=https://clawbake.example.com/auth/callback
```

Der wichtige Punkt: `OIDC_CLIENT_SECRET` ist wie ein Passwort oder API-Key. Es darf nicht ins Repository.

## Ablage im Setup

Empfohlene Trennung:

- Vorlagen ins Repo: `*.template`, `values.example.yaml`, Doku.
- Echte Werte in den User-Workspace: `~/.openclaw_ultimate_user_data/...`.
- Kubernetes-Secrets nur lokal erzeugen oder per SOPS/age verschluesseln.
- Keine echten Client-Secrets, Session-Secrets, Admin-Passwoerter oder SMTP-Passwoerter committen.

## Was ist Authentik?

Authentik ist ein selbst gehosteter Identity Provider und SSO-Dienst. Es kann moderne Login-Protokolle wie OIDC/OAuth2, SAML und LDAP bereitstellen.

Geeignet fuer:

- mehrere Webdienste mit einem zentralen Login
- OIDC-Login fuer Anwendungen wie Clawbake, Grafana, Open WebUI-nahe Gateways oder interne Dashboards
- Benutzerverwaltung mit Gruppen, Rollen und Policies
- komfortablere Admin-Oberflaeche

Nachteile:

- schwerer als Authelia
- braucht Datenbank/Container-Stack
- fuer MiniPC-Minimalbetrieb oft zu gross

Empfehlung: Sinnvoll fuer VPS, K3s, Homelab und produktionsnaehere Setups mit mehreren Webdiensten.

## Was ist Authelia?

Authelia ist ein schlanker Authentifizierungs- und Autorisierungsserver fuer selbst gehostete Dienste. Es wird oft mit Reverse Proxies wie Caddy, Traefik oder Nginx genutzt und bietet SSO/MFA-Schutz vor internen Web-UIs.

Geeignet fuer:

- Schutz von Webdiensten hinter Reverse Proxy
- 2FA/MFA vor internen Dashboards
- kleinere Homelab-/MiniPC-Setups
- Tailscale-/Cloudflare-/Caddy-/Traefik-Kombinationen

Nachteile:

- Konfiguration eher dateibasiert und technisch
- weniger komfortable Identity-Admin-Oberflaeche als Authentik
- bei komplexem OIDC-/Gruppenmanagement meist weniger bequem

Empfehlung: Sinnvoll als schlanke Schutzschicht fuer MiniPC, Homelab und VPS.

## Authentik oder Authelia?

| Kriterium | Authentik | Authelia |
|---|---|---|
| Ziel | Vollwertiger Identity Provider | Schlanke Auth-/SSO-Schutzschicht |
| Bedienung | Web-Admin-UI | Konfigurationsdateien |
| OIDC | Ja | Ja |
| SAML/LDAP | Ja | je nach Einsatz weniger zentral |
| Ressourcen | hoeher | niedriger |
| MiniPC | optional, eher schwer | gut geeignet |
| VPS/K3s | sehr sinnvoll | sinnvoll |
| Beste Rolle im Setup | zentrale Login-Plattform | Reverse-Proxy-Schutz fuer Dienste |

## Sinnvolle Architektur

```text
Internet / Tailscale / Cloudflare
        |
   Caddy / Traefik / Nginx
        |
   Authentik oder Authelia
        |
   Open WebUI, Grafana, Huginn, n8n, Clawbake, Dashboards
```

## Bezug zu Clawbake

Clawbake nennt OIDC, Kubernetes und Helm. Daher braucht es spaeter:

- eine Domain oder interne Hostnames
- TLS ueber Caddy/Traefik/Cloudflare/Tailscale
- OIDC-Provider wie Authentik, Authelia oder Keycloak
- Helm-Werte ohne echte Secrets im Repo
- Kubernetes-Secrets oder externe Secret-Verwaltung

## Status im Setup

Authentik und Authelia werden als optionale Auth-Bausteine aufgenommen. Die Installationsskripte bereiten bewusst nur sichere lokale Vorlagen im User-Workspace vor. Ein produktiver Start erfolgt spaeter bewusst mit Domain, TLS, Reverse Proxy, Secrets und Backup-Konzept.

Standard-Portplanung im Setup:

- Authentik HTTP wird lokal auf `9010` gemappt, damit es nicht mit MinIO auf `9000` kollidiert.
- Authentik HTTPS wird lokal auf `9444` gemappt.
- Authelia wird lokal auf `9091` vorbereitet.

## Quellen

- Authentik: <https://goauthentik.io/>
- Authentik Docs: <https://docs.goauthentik.io/>
- Authelia: <https://www.authelia.com/>
- Authelia GitHub: <https://github.com/authelia/authelia>
