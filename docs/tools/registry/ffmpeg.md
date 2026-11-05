# FFmpeg: SSH-Einstieg

[Aktuelle Audio-Chain mit Installation, Grenzen und KI-Planung](../local-audio-chain.md).

Tool-ID: `ffmpeg`; Reifegrad `experimental` / `planned`.
Kein Modell-/GUI-/Dienststart und keine automatische Inferenz.
Der Quell- bzw. Buildnachweis ist keine Runtime-Abnahme.

## Registrierte Lifecycle-Pfade

- `install`: [registriertes Skript](../../../scripts/tools/ffmpeg_install.sh).
- `update`: [registriertes Skript](../../../scripts/tools/ffmpeg_update.sh).
- `uninstall`: [registriertes Skript](../../../scripts/tools/ffmpeg_uninstall.sh).
- `doctor`: [registriertes Skript](../../../scripts/tools/ffmpeg_doctor.sh).
- `status`: [registriertes Skript](../../../scripts/tools/ffmpeg_status.sh).

Die Skripte erst nach Quellen-/Lizenz-/Ressourcenpruefung bewusst ausfuehren.
Alte /opt-Installationen, Medien, Modelle und globale Links bleiben erhalten.
Quelle und fester Pin stehen im Offline-Plan sowie in der aktuellen Audio-Anleitung.

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
python3 -I -B scripts/tool_commands.py show ffmpeg
```

### SSH-Aktionen: `ffmpeg`

Status und Diagnose lesen den privaten Tool-Zustand auf dem VPS:

```bash
python3 -I -B scripts/tool_commands.py run ffmpeg --action status
python3 -I -B scripts/tool_commands.py run ffmpeg --action doctor
```

Die folgenden Befehle **einzeln und nur nach Freigabe** ausfuehren, nicht als
gemeinsamen Ablauf: Installation, spaeter Update oder bewusst Deinstallation.
Vorher Quellen, Lizenz, Ressourcen und Daten-Erhaltungsregeln dieser Anleitung pruefen.

Installieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run ffmpeg --action install --apply --confirm ffmpeg:install
```

Aktualisieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run ffmpeg --action update --apply --confirm ffmpeg:update
```

Deinstallieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run ffmpeg --action uninstall --apply --confirm ffmpeg:uninstall
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

[SSH-Voraussetzungen und Sicherheitsgrenzen](../../HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](../../generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
