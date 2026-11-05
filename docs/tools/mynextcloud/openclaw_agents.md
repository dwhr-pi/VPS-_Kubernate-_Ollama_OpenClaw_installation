# OpenClaw Agents fuer myNextCloud

## myNextCloud_File_Agent

- ueberwacht neue Dateien
- erstellt Zusammenfassungen
- verschlagwortet Inhalte
- speichert Markdown/JSON-Ergebnisse

## myNextCloud_Admin_Agent

- prueft Speicherplatz
- prueft Updates
- erstellt Backup-Berichte
- warnt bei Fehlern

## myNextCloud_Security_Agent

- prueft verdaechtige Uploads defensiv
- Hash-Vergleich
- lokale Scanner bevorzugen
- Virustotal nur optionaler externer Modus

## myNextCloud_Media_Agent

- Bilder, Musik und Videos analysieren
- Metadaten extrahieren
- Whisper fuer Audio nutzen
- Suno/ComfyUI/Video-Workflows nur spaeter und kontrolliert

## Grenzen

Keine Loeschung, Freigabe, Veroeffentlichung oder externe Analyse ohne Human Approval.

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
