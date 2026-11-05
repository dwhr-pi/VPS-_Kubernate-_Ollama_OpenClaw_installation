# myNextCloud AI fuer Ultimate KI Setup

`myNextCloud AI` ist ein documentation-first Integrationspaket fuer die vorbereiteten Forks:

- Server: <https://github.com/dwhr-pi/myNextCloud-server>
- Android: <https://github.com/dwhr-pi/myNexcloud-for-android>

Upstreams:

- Server: <https://github.com/nextcloud/server>
- Android: <https://github.com/nextcloud/android>
- Android Library: <https://github.com/nextcloud/android-library>
- Referenz: <https://github.com/nextcloud/nextcloudpi>

## Leitplanken

- Fork based on Nextcloud.
- Not affiliated with or endorsed by Nextcloud GmbH.
- Nextcloud-Markenname, Logos, Icons, Splashscreens und offizielle Branding-Hinweise nicht als
  eigenes Branding uebernehmen.
- AGPL/GPL/MIT-Lizenztexte und Copyright-Hinweise erhalten.
- Keine Secrets ins Repo.
- Keine Docker-Pflicht; Docker nur optional.

## Empfohlene Reihenfolge

1. [Legal Branding Checklist](legal_branding_checklist.md)
2. [Branding-Strategie](branding_strategy.md)
3. [Fork-Review](fork_review.md)
4. [Upstream-Sync](upstream_sync.md)
5. [Server WSL/Ubuntu Dev](install_server_wsl_ubuntu.md)
6. [VPS Installation](install_server_vps.md)
7. [Raspberry Pi / NextcloudPi-inspiriert](install_server_raspberry_pi.md)
8. [Android Build](install_android_build.md)
9. [Cloudflare Access](cloudflare_access.md)
10. [Tailscale Access](tailscale_access.md)
11. [Ollama Datei-KI](ollama_file_ai.md)
12. [OpenClaw Agents](openclaw_agents.md)
13. [n8n Workflows](n8n_workflows.md)
14. [Home Assistant Integration](home_assistant_integration.md)
15. [Security Checklist](security_checklist.md)

## Helper-Skripte

Alle Skripte starten defensiv. Schreibende Aktionen brauchen `--apply`.

- `scripts/mynextcloud/check_upstream.sh`
- `scripts/mynextcloud/sync_upstream_server.sh`
- `scripts/mynextcloud/sync_upstream_android.sh`
- `scripts/mynextcloud/setup_env.sh`
- `scripts/mynextcloud/install_server_dev.sh`
- `scripts/mynextcloud/backup_mynextcloud.sh`
- `scripts/mynextcloud/scan_files_with_ollama.sh`
- `scripts/mynextcloud/n8n_webhook_examples.sh`

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
python3 -I -B scripts/tool_commands.py list
```

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](../../HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](../../generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
