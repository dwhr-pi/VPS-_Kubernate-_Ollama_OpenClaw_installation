# n8n Workflows fuer myNextCloud

## Workflow 1: Neuer Datei-Upload

```json
{
  "name": "myNextCloud file upload summary",
  "nodes": [
    {"name": "Webhook", "type": "n8n-nodes-base.webhook", "parameters": {"path": "mynextcloud/file-upload"}},
    {"name": "Fetch file", "type": "n8n-nodes-base.httpRequest", "parameters": {"authentication": "predefinedCredentialType"}},
    {"name": "Ollama summarize", "type": "n8n-nodes-base.httpRequest", "parameters": {"url": "http://127.0.0.1:11434/api/generate"}},
    {"name": "Save summary", "type": "n8n-nodes-base.httpRequest", "parameters": {"method": "PUT"}}
  ]
}
```

## Workflow 2: Audio hochgeladen

Webhook -> Datei abrufen -> Whisper Endpoint -> Ollama Zusammenfassung -> Tags -> `.transcript.md`
speichern.

## Workflow 3: Bild hochgeladen

Webhook -> Bild abrufen -> lokale Vision-KI optional -> Beschreibung -> Album-/Ordner-Vorschlag
speichern.

## Workflow 4: Backup

Zeittrigger -> Datenbankdump -> Datenordner Snapshot -> Logdatei -> Benachrichtigung via Home
Assistant/Email.

## Sicherheit

Webhooks signieren, Zugriff begrenzen, Rate-Limits setzen, keine Tokens im Workflow-JSON committen.

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
