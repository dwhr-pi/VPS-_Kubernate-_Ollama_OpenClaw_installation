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

## Was der aktuelle Installer wirklich leistet

Der aktuelle Installer ist bewusst ein **Vorbereitungs- und Build-Pfad**. Wenn im Log Zeilen wie diese erscheinen, ist das ein gutes Zeichen:

```text
Hinweis: Clawbake ist ein Kubernetes-/OpenClaw-Operator-Projekt. Fuer produktive Nutzung werden Go, Docker/K3s und spaeter Helm-Werte/OIDC-Secrets benoetigt.
go: downloading github.com/jackc/pgservicefile ...
Hinweis: Clawbake braucht für echten Betrieb Kubernetes, PostgreSQL/OIDC-Secrets und Helm-/Values-Konfiguration. Keine Secrets ins Repo schreiben.
```

Interpretation:

- Das Repository wurde erreicht und der Go-Abhaengigkeitsaufbau ist gestartet.
- `pgservicefile` ist ein normaler Go-Download aus dem PostgreSQL-Stack, kein Fehler.
- Ein erfolgreicher Build bedeutet noch nicht, dass Clawbake produktiv erreichbar ist.
- Fuer echten Betrieb fehlen danach noch Kubernetes/K3s, PostgreSQL, OIDC/Auth, Helm-Values, Domain/TLS und eine sichere Secret-Ablage.

Kurz gesagt: `installiert/gebaut` bedeutet bei Clawbake aktuell `Quellcode vorbereitet und ggf. Binary gebaut`, nicht `Webdienst fertig deployed`.

## Datenbank: PostgreSQL statt MySQL/MariaDB

Nach Pruefung der aktuellen Upstream-Quelle ist Clawbake derzeit **PostgreSQL-only**.

Wichtige Upstream-Befunde:

- `db/sqlc.yaml` nutzt `engine: "postgresql"`.
- `db/sqlc.yaml` generiert Go-Code mit `sql_package: "pgx/v5"`.
- `go.mod` enthaelt direkt `github.com/jackc/pgx/v5`.
- `cmd/server/main.go` nutzt den `golang-migrate`-Treiber `database/pgx/v5`.
- `cmd/server/main.go` wandelt `postgresql://` und `postgres://` in `pgx5://` um.
- `charts/clawbake/values.yaml` setzt intern `postgres:18`.
- `charts/clawbake/templates/secret.yaml` erzeugt eine PostgreSQL-URL.

Damit ist MySQL/MariaDB aktuell keine sinnvolle Setup-Option fuer Clawbake. Ein MySQL-Pfad waere ein echter Upstream-Port mit neuen Migrationen, sqlc-Konfiguration, Go-Treiber, Tests und Helm-Templates. Das ist deutlich mehr als eine `.env`- oder `values.yaml`-Aenderung.

Der Installer akzeptiert deshalb nur:

```bash
CLAWBAKE_DATABASE_ENGINE=postgresql
```

Wenn `CLAWBAKE_DATABASE_ENGINE=mysql`, `mariadb` oder `mysql2` gesetzt wird, bricht der Installer bewusst mit einer erklaerenden Meldung ab. Das verhindert eine Scheinkonfiguration, die spaeter erst im Kubernetes-/Helm-Betrieb scheitert.

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

## Status erkennen

Nach dem Installer sollte zuerst zwischen drei Stufen unterschieden werden:

| Stufe | Bedeutung | Pruefung |
|---|---|---|
| Quelle vorhanden | Repo liegt unter `/opt/clawbake` | `test -d /opt/clawbake/.git` |
| Build vorbereitet | Go/Make-Abhaengigkeiten konnten aufgeloest werden | `cd /opt/clawbake && go version && make --version` |
| Produktiv bereit | Kubernetes, DB, Auth, Helm und Secrets sind konfiguriert | noch nicht automatisch im Setup umgesetzt |

Pruefbefehle:

```bash
cd /opt/clawbake
git remote -v
git log -1 --oneline
go version
make --version
find . -maxdepth 3 -type f -perm -111 | sort
```

Wenn kein laufender Dienst, kein Helm-Release oder kein Kubernetes-Namespace fuer Clawbake existiert, ist Clawbake noch nicht produktiv deployed.

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
- Statusausgabe im Setup ergaenzen: `prepared`, `built`, `deployed`.
- Keinen MySQL-Schalter fuer Clawbake einbauen, solange Upstream PostgreSQL-only ist.
- `CLAWBAKE_SKIP_BUILD=true` als Vorbereitungspfad im Setup-Menue sichtbar machen.
- Port-/Secret-/OIDC-Konfiguration in ausgelagerten User-Workspace verschieben.
- Clawbake als `experimental` oder `advanced` markieren, nicht als Default-Installation.
