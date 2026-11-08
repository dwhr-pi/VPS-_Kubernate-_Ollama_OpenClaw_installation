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

<!-- BEGIN GENERATED VPS SSH -->

## VPS ueber SSH bedienen

Voraussetzung: ein bereits gepruefter Setup-Checkout und ein selbst eingerichteter
SSH-Alias `vps` (Benutzer, Host und Schluessel in deiner SSH-Konfiguration).
Alternativ `vps` durch `BENUTZER@VPS_HOST` ersetzen. Den Host-Fingerprint vorher
unabhaengig pruefen; keine Host-Key-Pruefung abschalten. Keine Zugangsdaten in Git.

Auf deinem Client (PowerShell, Linux oder macOS):

```bash
ssh -t vps
```

Danach **im Linux-Terminal des VPS**. Den Pfad bei einem Branch-Checkout anpassen;
ein Windows-/Desktop-Tool wird durch SSH nicht zu einer VPS-Anwendung:

```bash
cd "$HOME/openclaw_ultimate_setup" || exit 1
test -f scripts/tool_commands.py || exit 1
```

Zuerst nur den Offline-Plan lesen (keine Installation und kein Dienststart):

```bash
python3 -I -B scripts/tool_commands.py show argocd_cli
python3 -I -B scripts/tool_commands.py show cloudflared
```

### SSH-Aktionen: `argocd_cli`

Status und Diagnose lesen den privaten Tool-Zustand auf dem VPS:

```bash
python3 -I -B scripts/tool_commands.py run argocd_cli --action status
python3 -I -B scripts/tool_commands.py run argocd_cli --action doctor
```

Die folgenden Befehle **einzeln und nur nach Freigabe** ausfuehren, nicht als
gemeinsamen Ablauf: Installation, spaeter Update oder bewusst Deinstallation.
Vorher Quellen, Lizenz, Ressourcen und Daten-Erhaltungsregeln dieser Anleitung pruefen.

Installieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run argocd_cli --action install --apply --confirm argocd_cli:install
```

Aktualisieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run argocd_cli --action update --apply --confirm argocd_cli:update
```

Deinstallieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run argocd_cli --action uninstall --apply --confirm argocd_cli:uninstall
```

Fehlende Build-Abhaengigkeiten stoppen den Versuch. Nur fuer Install/Update
`--install-build-deps` nach separater Download-Freigabe ergaenzen. Kein Auto-Yes,
kein Docker-Fallback; Source-Build/Status ist keine erfolgreiche Runtime-Abnahme.

### SSH-Aktionen: `cloudflared`

Status und Diagnose lesen den privaten Tool-Zustand auf dem VPS:

```bash
python3 -I -B scripts/tool_commands.py run cloudflared --action status
python3 -I -B scripts/tool_commands.py run cloudflared --action doctor
```

Die folgenden Befehle **einzeln und nur nach Freigabe** ausfuehren, nicht als
gemeinsamen Ablauf: Installation, spaeter Update oder bewusst Deinstallation.
Vorher Quellen, Lizenz, Ressourcen und Daten-Erhaltungsregeln dieser Anleitung pruefen.

Installieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run cloudflared --action install --apply --confirm cloudflared:install
```

Aktualisieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run cloudflared --action update --apply --confirm cloudflared:update
```

Deinstallieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run cloudflared --action uninstall --apply --confirm cloudflared:uninstall
```

Fehlende Build-Abhaengigkeiten stoppen den Versuch. Nur fuer Install/Update
`--install-build-deps` nach separater Download-Freigabe ergaenzen. Kein Auto-Yes,
kein Docker-Fallback; Source-Build/Status ist keine erfolgreiche Runtime-Abnahme.

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](../HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](../generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
