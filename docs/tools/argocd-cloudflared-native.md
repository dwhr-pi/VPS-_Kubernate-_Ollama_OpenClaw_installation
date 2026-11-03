# ArgoCD CLI und cloudflared: native Git-Installation

Kein Docker, kein privilegierter `latest`-Download. Die vorhandene native Build-Infrastruktur
verwendet feste Git-Commits, prueft den Checkout, Go-Module und die private Toolchain,
setzt Speicherreserven durch und erstellt erst nach Build/Probe einen privaten Buildnachweis.
Installationsziel: Tool-Verzeichnis unter `~/.openclaw_ultimate_user_data`, nicht `/usr/local/bin`.
Bestehende Systemprogramme werden weder ersetzt noch entfernt. Kein automatischer PATH-Wechsel.

```bash
bash scripts/tools/argocd_cli_install.sh --dry-run
bash scripts/tools/cloudflared_install.sh --dry-run
# Nur nach Pruefung und eigener Freigabe; keine Dienste werden gestartet:
bash scripts/tools/argocd_cli_install.sh --install-build-deps
bash scripts/tools/cloudflared_install.sh --install-build-deps
```

Status/Doctor/Uninstall sind ueber den gemeinsamen Helfer erreichbar:

```bash
python3 -B scripts/tools/helpers/native_github_tools.py argocd_cli doctor
python3 -B scripts/tools/helpers/native_github_tools.py cloudflared status
python3 -B scripts/tools/helpers/native_github_tools.py cloudflared uninstall --dry-run
```

Quellenpruefung vom 03.11.2026, keine Build- oder Produktionsabnahme:

- [ArgoCD go.mod am festen Commit](https://github.com/argoproj/argo-cd/blob/3dc411247c3b00c283581642b0d017052d91664d/go.mod),
  Go 1.27.0; `./cmd`, Probe nur `version --client --short`.
- [cloudflared go.mod am festen Commit](https://github.com/cloudflare/cloudflared/blob/872b241f94871665c1c157adefcf90c11f0ead96/go.mod),
  Go 1.27.3; `./cmd/cloudflared`, Probe nur `--version`.

Das sind nachvollziehbare Entwicklungs-Commits, keine Behauptung einer freigegebenen
Release-Version. Upstream-Abhaengigkeiten und reale Builds muessen vor Produktion abgenommen werden.
Eigene Tunnel-Token, Login, Installation einer Unit und deren Start sind getrennte Schritte.
Ein Quellbuild ohne Upstream-Linker-Version kann `dev`/`unknown` melden; der Buildnachweis
bindet deshalb den echten Commit und das Rezept statt eine erfundene Versionsnummer zu setzen.

Rollback: Keine Systemdateien veraendert. Nur den eigenen unveraenderten nativen Build
ueber den Helfer entfernen; vorhandene Tunnel-Konfigurationen und Daten bleiben erhalten.
