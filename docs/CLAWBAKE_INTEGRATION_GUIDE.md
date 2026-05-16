# Clawbake Integration Guide

## Aktuelle Quelle

Die alte Quelle `https://github.com/openclaw/clawbake.git` ist im Setup nicht mehr die Standardquelle.

Aktuelle Standardquelle:

```txt
https://github.com/NeurometricAI/clawbake.git
```

Diese Quelle beschreibt Clawbake als Kubernetes-/OpenClaw-Verwaltung:

- Webserver/Dashboard
- Kubernetes-Operator
- `ClawInstance` Custom Resource
- PostgreSQL
- OIDC-Login
- Helm-Chart
- OpenClaw-Instanzen pro Namespace

## Wichtige Korrektur

Der alte Installer behandelte Clawbake wie ein pnpm-Projekt. Das passt nicht zur neuen Quelle.

Der Installer nutzt jetzt:

- `git clone` der NeurometricAI-Quelle
- Remote-Pruefung per `git ls-remote`
- Backup alter abweichender `/opt/clawbake`-Verzeichnisse
- Go-/Make-Pruefung
- `make build`, sofern `CLAWBAKE_SKIP_BUILD=true` nicht gesetzt ist

## Installation

```bash
bash scripts/tools/clawbake_install.sh
```

Alternative Quelle explizit setzen:

```bash
CLAWBAKE_REPO_URL=https://github.com/NeurometricAI/clawbake.git bash scripts/tools/clawbake_install.sh
```

Nur Repository vorbereiten und Build ueberspringen:

```bash
CLAWBAKE_SKIP_BUILD=true bash scripts/tools/clawbake_install.sh
```

## Voraussetzungen

Laut Upstream sind fuer lokale Entwicklung relevant:

- Go 1.25+
- Docker
- k3d oder Kubernetes/K3s
- mise als Tool-Version-Manager
- PostgreSQL fuer Serverdaten
- OIDC-Konfiguration fuer Login
- Helm fuer Deployment

Das bedeutet: Clawbake ist eher ein fortgeschrittenes Kubernetes-/OpenClaw-Managementmodul, nicht ein leichtes MiniPC-Basistool.

## Helm-Werte, OIDC und Secrets

Helm-Werte sind die Kubernetes-Konfiguration fuer ein Chart. Sie stehen meist in einer `values.yaml` und entsprechen grob einer `.env.template` fuer Kubernetes. Darin liegen zum Beispiel Hostnames, Ressourcenlimits, Datenbanknamen, Ingress-Einstellungen oder Feature-Schalter.

OIDC steht fuer OpenID Connect. Das ist kein einzelnes Tool, sondern ein Login-Standard. Clawbake kann darueber spaeter einen externen Login-Anbieter nutzen.

OIDC-Secrets sind sensible Login-Werte wie:

```env
OIDC_ISSUER_URL=https://auth.example.local/application/o/clawbake/
OIDC_CLIENT_ID=clawbake
OIDC_CLIENT_SECRET=change-me-outside-repo
OIDC_REDIRECT_URI=https://clawbake.example.local/auth/callback
```

`OIDC_CLIENT_SECRET` ist wie ein Passwort oder API-Key und gehoert nie ins Repository.

Sinnvolle OIDC-Provider fuer dieses Setup:

- Authentik: komfortabler Identity Provider mit Web-UI, OIDC/OAuth2, SAML und LDAP.
- Authelia: schlankere Auth-/MFA-Schicht vor Webdiensten, gut fuer Reverse-Proxy-Setups.
- Keycloak: sehr maechtig, aber fuer dieses Setup meist schwerer als noetig.

Mehr dazu: [Auth, OIDC, Helm-Werte und Secrets](AUTH_OIDC_HELM_SECRETS_GUIDE.md)

## Nutzung im Setup

Sinnvolle Zielumgebungen:

- zusaetzliche VPS oder Kubernetes/K3s-Umgebung
- GPU-/Server-Cluster mit mehreren OpenClaw-Instanzen
- Entwicklungsumgebung fuer OpenClaw-Operator-/Helm-Workflows

Weniger geeignet:

- Minimaler MiniPC-Standalone-Modus
- WSL2 ohne Docker/Kubernetes
- Systeme ohne OIDC-/Domain-/TLS-Konzept

## Sicherheit

- Keine OIDC-Secrets, Session-Secrets, Tokens oder Gateway-Tokens ins Repo schreiben.
- Clawbake-Webzugang nur hinter Auth, Reverse Proxy, Tailscale/Cloudflare Tunnel oder VPN freigeben.
- Kubernetes-Namespace-Isolation pruefen.
- Standardwerte nicht blind produktiv verwenden.
- Als experimentelles/fortgeschrittenes Modul behandeln, bis ein stabiler Setup-Pfad getestet wurde.

## Status und Tests

Nach Installation:

```bash
cd /opt/clawbake
git remote -v
git log -1 --oneline
make --version
go version
```

Wenn ein Build erfolgte:

```bash
find . -maxdepth 3 -type f -perm -111 | sort
```

## TODO fuer dieses Setup

- Doctor-Check fuer `/opt/clawbake`, Git-Remote, Go-Version und Makefile.
- Helm-Deployment als getrennte Advanced-Option dokumentieren.
- `CLAWBAKE_SKIP_BUILD=true` als Vorbereitungspfad im Setup-Menue sichtbar machen.
- Port-/Secret-/OIDC-Konfiguration in ausgelagerten User-Workspace verschieben.
- Clawbake als `experimental` oder `advanced` markieren, nicht als Default-Installation.
