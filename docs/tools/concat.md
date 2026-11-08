# Concat: lokaler Videoschnitt nach Wan oder LTX

Stand: **22.10.2026**. [GitHub](https://github.com/jub0t/Concat),
[README](https://github.com/jub0t/Concat/blob/main/README.md),
[Release 0.2.8](https://github.com/jub0t/Concat/releases/tag/v0.2.8).

**Zweck:** Clips in einer Timeline schneiden, Ton und Untertitel bearbeiten und Videos
zusammenstellen. Concat beschreibt lokale KI-Funktionen und JSON-RPC/MCP. Es ist kein austauschbares
Wan-/LTX-Generierungsmodell und kein bereits konfigurierter OpenClaw-MCP-Server.

## Installation aus GitHub, ohne Docker

Der eigene Tools-Menueeintrag **Concat** installiert das offizielle **0.2.8-AppImage** fuer Linux
x86_64 oder aarch64. Feste Groesse und SHA256 werden vor Freigabe geprueft. Kein Rust-Build,
apt-/Systempaket oder GUI-Start. Pruefsummen aus den offiziellen GitHub-Release-Metadaten:

| Architektur | SHA256                                                             |
| ----------- | ------------------------------------------------------------------ |
| x86_64      | `4e64a3826cdb86be43fc82beeb087ecb82141ea5c557f156d855fd21ff87ccb1` |
| aarch64     | `93058c09134bea4f274ea6c9578b7cda638ab81ebe4db2841b03a71f47d9e785` |

```bash
bash scripts/tools/concat_install.sh --dry-run
bash scripts/tools/concat_install.sh
bash scripts/tools/concat_status.sh
bash scripts/tools/concat_doctor.sh
bash scripts/tools/concat_update.sh
bash scripts/tools/concat_uninstall.sh
```

Bewusster manueller Start nach der Installation:

```bash
"$HOME/.openclaw_ultimate_user_data/tools/concat/runtime/Concat.AppImage"
```

Bei `OPENCLAW_USER_DATA_DIR` den anderen Datenpfad verwenden. Unter WSL braucht die Desktop-App eine
funktionierende GUI, etwa WSLg; AppImage/FUSE, Grafiktreiber und Codecs gesondert pruefen. Ein
Download beweist keinen GUI-/GPU-Betrieb: `installed=true`, aber `runtime_ready=false`, bis Import,
Wiedergabe und Export mit eigenen Testdaten funktionieren.

Vor Download werden **2 GiB Reserve** am Linux-Ziel und bei erkannter WSL- Umgebung auch auf C:
verlangt. Modelle/Videoarchive brauchen weiteren Platz. Bei anderer VHDX-Ablage deren echtes
Hostlaufwerk ebenfalls pruefen.

## Windows und andere Plattformen

Dieser Setup-Installer ist fuer Linux/Ubuntu/WSL. Native Windows-/macOS- Pakete und mobile Assets
bietet die [offizielle Release-Seite](https://github.com/jub0t/Concat/releases/tag/v0.2.8).
Windows-Paket bewusst manuell waehlen, nicht das AppImage. Kein automatischer EXE-/MSI-/APK-Start;
mobile Signatur-/Installationsgrenzen separat pruefen.

## Zusammenspiel mit deinem KI-Setup

```text
ComfyUI + vorhandenes Wan-/LTX-Modell -> freigegebene Clips
  -> Concat: Schnitt, eigene Tonspur, Untertitel
  -> Sicht-/Hoerpruefung -> manueller Export
```

Erster Test: eigenen kurzen Clip importieren, trimmen, eigene Tonspur hinzufuegen und exportieren.
Bildrate, Tonversatz und Schrift pruefen.
[Editierbare Rezepte](../media_studio/EDITABLE_VIDEO_WORKFLOWS.md) bleiben eine getrennte
Planungsebene ohne fertigen Concat-Adapter.

JSON-RPC/MCP erst danach mit begrenzten Dateirechten evaluieren; keine Agentenaktivierung, offenen
Ports, Mikrofon-/Modell-/Stimmendownloads durch diesen Installer. Medien-/Modellrechte und
Einwilligungen sind unabhaengig von der
[AGPL-3.0-or-later-Code-Lizenz](https://github.com/jub0t/Concat/blob/main/LICENSE).

## Lokaler Agent: belegter MCP-Weg statt erfundener HTTP-API

Nachpruefung vom **05.11.2026** am Release-Tag-Commit
`79116bd0f9a103c633d888603ad27890e929dbdc` und separat am Upstream-Head
`483c9d6afa7b272b816e44fdd5b21eba2d773be2`. Der vorhandene Installer bleibt
unveraendert bei der geprueften **GitHub-Release-AppImage-Ausnahme**, nicht bei
einem behaupteten Rust-Source-Build. Es wird weder ein zweites Concat-Tool noch
ein Docker-Fallback hinzugefuegt. Ein reiner Source-Build ist ein separater,
noch nicht in diesem Installer umgesetzter Pfad; FFmpeg-Entwicklungsbibliotheken,
Rust und GUI-Abhaengigkeiten muessen dafuer gemeinsam abgenommen werden.

Die [MCP-Anleitung am Release-Pin](https://github.com/jub0t/Concat/blob/79116bd0f9a103c633d888603ad27890e929dbdc/docs/MCP.md)
bestaetigt einen **eingebauten stdio-MCP-Server**. Ein erfundenes
`concat-mcp-wrapper.js`, eine Node-Zwischenschicht oder `requests.post` auf
`http://127.0.0.1:8080/json-rpc` ist dafuer nicht erforderlich. Die JSON-RPC-
Schnittstelle ist nicht automatisch ein HTTP-Endpunkt.

### Zuerst GUI und Automation bewusst pruefen

Erst in einer getrennten Testumgebung mit eigener Medienkopie Import, Wiedergabe,
Tonversatz und Export pruefen. Dann bei laufendem Concat-Fenster in den Einstellungen
**Automation > Scripts and apps** bewusst aktivieren. Das schreibt einen lokalen
Verbindungsnachweis mit Token in die Benutzerkonfiguration; nicht in Git kopieren
und nicht als Log/Prompt ausgeben. Diese Entwicklung liest diese Datei nicht.

Beim manuellen MCP-Client-Eintrag ein absolutes Binary verwenden und fuer den
ersten Test **window** statt **auto** waehlen. Ein neutraler Eintrag sieht so aus:

```json
{
  "mcpServers": {
    "concat-review": {
      "command": "/absoluter/gepruefter/Pfad/Concat.AppImage",
      "args": ["--mcp", "window"]
    }
  }
}
```

Der Beispielpfad ist absichtlich keine automatische Installation. Unter Windows
das bereits gepruefte `concat.exe` und korrekte JSON-Pfade benutzen; unter macOS
das Binary innerhalb des geprueften App-Bundles. Dieser Abschnitt installiert
keine dieser Plattformversionen. Kein automatischer WSL-/GUI-Start.

**Das ist ein client-neutrales MCP-Beispiel, keine bestaetigte `openclaw.json`-Schemaergaenzung.**
In OpenClaw den tatsaechlich vorhandenen MCP-Client/Bridge-Pfad und dessen Schema
zuerst pruefen; keinen beliebigen `mcpServers`-Block in eine Produktivkonfiguration
schreiben. Bestehende Einstellungen nicht ersetzen. `--mcp window` soll ohne
aktivierte Fenster-Automation fehlschlagen statt heimlich Headless zu starten.

### Lesend beginnen, schreibend nur nach Freigabe

Im gewaehlten MCP-Client erst `initialize` und `tools/list` bestaetigen. Am Pin
sind unter anderem `concat_version`, `project_get`, `timeline_read`, `clip_add`,
`media_import`, `captions_add`, `project_save`, `export_start`, `export_status`,
`export_wait` und `export_cancel` dokumentiert. **Argumente aus den tatsaechlich
gelieferten Tool-Schemas lesen**, nicht aus diesem Text erfinden.

Die Methoden aus dem eingefuegten Python-Entwurf (`project.add_clip`,
`ai.generate_subtitles`, `project.export`) sind dadurch nicht als API-Vertrag
belegt und werden nicht als ausfuehrbare Beispiele uebernommen. Captions im
Toolkatalog belegen auch keinen pauschalen automatischen Whisper-Workflow.
Ein gestarteter Export ist noch kein fertiger, gepruefter Film.

Der Ablauf fuer eigene Testkopien lautet:

```text
ComfyUI: freigegebene Wan-/LTX-Clips, kein neuer Modell-Download
  -> Benutzer prueft Dateiliste, Medienrechte, Codec/Bildrate/Ton
  -> MCP-Lesetest und Tool-Schemas pruefen
  -> Benutzer gibt Import/Schnitt/Export fuer ein eigenes Testprojekt frei
  -> Client darf nur die einzeln freigegebenen Schreib-Tools aufrufen
  -> Exportstatus abwarten, Datei pruefen, erst danach Erfolg melden
```

Wan/LTX laufen vor dem Schnitt, nicht als beliebig austauschbare interne
Concat-Modelle. Eine native OpenClaw-Bridge mit technisch erzwungener Methoden-
und Dateifreigabe ist hier **noch nicht implementiert**. Keine automatische
Agentenregistrierung, kein Render-/Mikrofon-/Modellstart durch das Setup.

### Sicherheitsgrenzen und Abbruch

Der Upstream-MCP-Server hat auch **schreibende Werkzeuge**. Ihn direkt anzubinden
macht ihn nicht read-only. Fuer Agenten einen getrennten OS-Benutzer mit nur
eigenen Projektkopien bzw. einen abgenommenen eingeschraenkten Worker nutzen;
HOME darf keine SSH-Keys, API-Keys oder fremden Medien enthalten. Rechte und
CPU/RAM/PID-/GPU-Ressourcen technisch begrenzen, nicht nur im Prompt verlangen.

`CONCAT_MCP_ROOTS` erlaubt laut Upstream zusaetzliche Verzeichnisse neben dem
Home-Bereich; es ist **keine Zusicherung, HOME auf genau einen Ordner zu sperren**.
Nicht auf den ganzen User-Workspace setzen. Im window-Modus bearbeitet der Agent
eigene Projekte, nicht ungeprueft das gerade im Fenster geoeffnete Projekt.
Projektlocks nicht loeschen, um Sperren zu umgehen.

Abbruch ueber den dokumentierten Export-Abbruch bzw. den eigenen MCP-Client;
keine fremden Prozesse beenden. Bei Fehlern Projektkopie erhalten, Status und
Logauszug ohne Tokens sichern. Ruecknahme: den selbst hinzugefuegten MCP-Eintrag
entfernen und Automation bewusst deaktivieren; keine Projekte oder Modelle loeschen.
Fuer Remote-Zugriff zuerst privaten SSH-/WireGuard-Pfad und Authentifizierung
abnehmen, keine oeffentliche Portfreigabe und kein tokenloser HTTP-Proxy.

Quellenvergleich: [aktueller gepruefter Head](https://github.com/jub0t/Concat/blob/483c9d6afa7b272b816e44fdd5b21eba2d773be2/docs/MCP.md).
Hier nur Dokumentations-/Offline-Pruefung: kein echter MCP-Handshake, AppImage-
Start, Fensterzugriff oder Wan-/LTX-/AV1-Export. Ein konkreter Agenten-Schnittauftrag
bleibt bis zu diesen Nachweisen und zur Einzelfreigabe gesperrt.

## Status, Rollback und Deinstallation

Marker erst nach geprueftem Download. Status verlangt Marker **und** unveraendertes AppImage;
Doctor/Deinstallation pruefen das ganze Inventar. Aenderungen oder Zusatzdateien fuehren zum Abbruch
statt Datenverlust. Eigene Projekte ausserhalb des verwalteten `runtime`-Ordners speichern.

Update bleibt bei 0.2.8. Fehler entfernen nur neue Stage-/Runtime-Dateien dieses Versuchs.
Deinstallation entfernt unveraenderte Runtime und Marker, nicht externe Projekte, Modelle,
Basiswerkzeuge oder Logs. Offline-Tests pruefen Installerlogik, nicht die echte GUI auf deinem
Rechner. Hier wurden kein AppImage, GUI, Modell, MCP oder Export gestartet.

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
python3 -I -B scripts/tool_commands.py show concat
```

### SSH-Aktionen: `concat`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`Concat` (ID `concat`) waehlen und die Einzelfreigaben lesen.
Fehlt der Eintrag oder ist der native Weg gesperrt, hier stoppen: keine
Legacy-/Docker-Ausweichinstallation und kein automatischer Plattformwechsel.

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
