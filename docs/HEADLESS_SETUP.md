# Das Setup auf einem Headless-VPS bedienen

Headless bedeutet nicht automatisch unbeaufsichtigt. Das Setup-Programm selbst
hat bereits ein Terminalmenue mit `dialog`, keine notwendige Desktop-GUI.
Dieses Menue ist ueber SSH mit zugewiesenem Terminal bedienbar. Ollama-Chat,
Messenger-Bots oder Kubernetes-Port-Forwarding sind andere Funktionen und kein
Ersatz fuer die Installationsverwaltung.

## Interaktiv ueber SSH

Auf dem eigenen Rechner, nachdem SSH-Ziel und gepruefter Setup-Checkout bereits
eingerichtet sind:

```bash
# Replace the user-defined SSH alias and verified checkout path as needed.
ssh -t vps 'cd "$HOME/openclaw_ultimate_setup" && bash setup_ultimate.sh'
```

Kein `curl | bash`, kein `chmod +x *.sh`, kein ungepruefter Clone mit sofortiger
Ausfuehrung. Fuer die Erstinstallation gilt weiterhin der
[signierte Einstieg](SIGNED_RELEASES.md). Fuer lange Arbeiten kann eine bewusst
eingerichtete tmux-Sitzung helfen; sie ist weder Rollback noch ein Beleg fuer eine
erfolgreiche Installation.

## Ohne Terminal zuerst planen

Diese neuen Befehle lesen ausschliesslich Repository-Metadaten. Keine Sprache,
kein Dialog, kein User-Workspace, keine Keys und kein Dienst werden initialisiert:

```bash
bash setup_ultimate.sh --tools-json
bash setup_ultimate.sh --tool-plan searxng
python3 -I -B scripts/tool_commands.py list
python3 -I -B scripts/tool_commands.py show ollama
python3 -I -B scripts/tool_commands.py plan markdown_docs_server

# The same command without allocating an SSH terminal:
ssh vps 'cd "$HOME/openclaw_ultimate_setup" && bash setup_ultimate.sh --tool-plan searxng'
```

Die Ausgabe ist JSON und enthaelt immer `executed:false`. Verwendet werden die
exakten IDs aus `config/tools.yml`, nicht beliebige Shellstrings oder frei
eingegebene Skriptpfade. Ein unbekanntes Tool wird abgelehnt. `list` ist keine
Abfrage installierter Programme und liest keine privaten Statusdateien.

Die [generierte Befehlstabelle fuer alle Tools](generated/HEADLESS_TOOL_COMMANDS.md)
enthaelt jede registrierte ID, Status/Bereitschaft, Plan, freigegebene Aktionen
und vorhandene Konfigurationsanleitung. `show ID` zeigt ausserdem alle tatsaechlich
vorhandenen registrierten Lifecycle-Skripte. Fehlende Doctor-/Update-/Statuspfade
oder Konfigurationsanleitungen werden als Luecken ausgewiesen, nicht erfunden.

## Bewusst unbeaufsichtigt ausfuehren

Der neue `run`-Adapter erlaubt ausschliesslich vorhandene, gepinnte native
GitHub-Buildrezepte ohne Implementierungssperre. Er startet den bereits bestehenden
nativen Helper, nicht ungepruefte Legacy-Installer. Ein vorhandener Skriptname
allein ist ausdruecklich keine Freigabe. Gepruefte Adapter sind keine pauschale
Produktions- oder Laufzeitabnahme; die Reifegradfelder bleiben sichtbar.

```bash
# Review the plan, license, resources and tool guide first.
python3 -I -B scripts/tool_commands.py run searxng \
  --action install --apply --confirm searxng:install

# Only after approving private downloads of missing build dependencies:
python3 -I -B scripts/tool_commands.py run searxng \
  --action install --apply --confirm searxng:install --install-build-deps

# Update retains the reviewed recipe/pin, not upstream main.
python3 -I -B scripts/tool_commands.py run searxng \
  --action update --apply --confirm searxng:update

python3 -I -B scripts/tool_commands.py run searxng --action status
python3 -I -B scripts/tool_commands.py run searxng --action doctor

# Review data retention and uninstall rules first.
python3 -I -B scripts/tool_commands.py run searxng \
  --action uninstall --apply --confirm searxng:uninstall
```

`--confirm` ist immer an **genau ein Tool und genau eine Aktion** gebunden.
Es gibt weder `--all` noch pauschales `--yes`, `--force`, automatische
Lizenzannahme oder beliebige Zusatzargumente. Die bestehenden Pfad-/Besitz-/
Quell-/Speicherwaechter bleiben aktiv. Fehlende Voraussetzungen fuehren zu einem
echten Fehlercode. STDIN ist geschlossen: kein verstecktes Warten auf eine
interaktive Freigabe. Der bestehende Helper verantwortet Build-/Download-Limits.

Status/Doctor lesen bei bewusster Ausfuehrung den eigenen privaten Tool-Zustand;
sie sind kein Ersatz fuer eine Inferenz-/Service-Abnahme. Install/Update starten
keine Server, Modelle oder Browser. Der Adapter verwendet keine Shell-Auswertung
und uebernimmt keine API-Keys, `PYTHONPATH`, `BASH_ENV` oder globale Auto-Yes-Flags.
Zusaetzliche spezielle Toolchain-Einstellungen sind gegebenenfalls im bestehenden
Werkzeugpfad separat freizugeben; nicht durch beliebige CLI-Flags einschleusen.
`run` ist fuer das explizit gewaehlte Linux-/WSL-Terminal vorgesehen. Unter
nativem Windows bleiben List/Plan/Dokumentation verfuegbar; es wird niemals
automatisch eine WSL-Distribution gestartet.

Nicht freigegebene Tools lassen sich weiter im interaktiven Setup nach dessen
eigenen Regeln verwalten. Der neue unbeaufsichtigte Adapter wird fuer sie nicht
auf Legacy-/Docker-/Cloud-Installationen zurueckfallen. Ein falscher oder noch
fehlender nativer Buildpfad muss zuerst implementiert und getestet werden.

## Konfiguration

Die Tabelle nennt vorhandene, separat zu startende Terminal-Wizards, zum Beispiel
OpenClaw-Konfiguration, Ollama-Modelfile-Assistent oder Markdownserver-Menue.
Diese brauchen ein SSH-Terminal und sind **nicht** unbeaufsichtigte Aktionen:

```bash
ssh -t vps 'cd "$HOME/openclaw_ultimate_setup" && bash scripts/openclaw_config_manager.sh'
ssh -t vps 'cd "$HOME/openclaw_ultimate_setup" && bash scripts/markdown_docs_server_menu.sh'
```

Bei anderen Tools die dokumentierte Konfiguration verwenden. Keine gemeinsame
`.env` mit saemtlichen Keys im Repository ablegen und keine `.env` per `source`
als Code laden. Secrets bleiben im privaten Workspace bzw. im vorhandenen
Secrets-Verfahren. Kein erfundenes `helm upgrade` auf einen nicht vorhandenen
Chart und kein pauschales `kubectl apply` auf alle Beispiele.

## Vollstaendigkeit pro Tool

Die [SSH-Abdeckungsmatrix](generated/SSH_TOOL_COVERAGE.md) listet **jede** Tool-ID
aus der Registry mit einem direkten Link zu ihrer SSH-Installationsanleitung.
Dabei zaehlen nicht die Anzahl der Markdown-Dateien oder ein allgemeiner SSH-Link,
sondern die Zuordnung, der SSH-Einstieg und der eigene `show TOOL_ID`-Plan pro Tool.

Die erste Ergaenzung von 138 vorhandenen Anleitungen war unvollstaendig:
218 von 401 Tools hatten noch keinen `doc`-Eintrag. Drei vorhandene Einzelanleitungen
wurden verknuepft, 215 kurze SSH-Einstiegsseiten ergaenzt. Bestehende Sammelanleitungen
bleiben bestehen. Die neuen Seiten benennen registrierte Skripte und offene
Lifecycle-Luecken, behaupten aber keine abgeschlossene Installations- oder Runtime-Abnahme.

Fehlende Dokumentationszuordnungen, falsche Tool-IDs, fehlende SSH-Abschnitte und
veraltete Beispiele lassen den Offline-CI-Check fehlschlagen. Neue Tools duerfen
deshalb nicht ohne verknuepfte, tool-spezifische SSH-Anleitung eingetragen werden.
Dokumentationsabdeckung ist keine Freigabe fuer unsichere Legacy-/Docker-Pfade.

## Nachweise und Pflege

Jede Markdown-Anleitung unter `docs/tools/` sowie jede in der Tool-Registry
verknuepfte Anleitung enthaelt einen sichtbaren Abschnitt **VPS ueber SSH bedienen**.
Er zeigt den SSH-Einstieg und die konkreten Offline-Plaene der zugeordneten Tools.
Install/Update/Uninstall-Beispiele erscheinen nur fuer vom nativen Adapter
freigegebene Rezepte; ein Windows-Desktopprogramm erhaelt keine erfundene
Linux-Installation. Themenanleitungen ohne eindeutige Tool-ID verweisen auf den
vollstaendigen Katalog. Bestehende Plattform- und Sicherheitsgrenzen gelten weiter.

```bash
# Check generated sections without changing files or contacting a VPS.
python3 -I -B scripts/quality/tool_ssh_docs.py
# Regenerate only these sections after changes to guides or registry metadata.
python3 -I -B scripts/quality/tool_ssh_docs.py --write
python3 -B -m unittest discover -s tests -p test_tool_ssh_docs.py -v
```

Offline-Fixtures pruefen Metadatenabdeckung, Pfad-/Argumentvalidierung,
fehlende Freigaben, die unveraenderte Weitergabe von Fehlercodes und den fruehen
dialogfreien Einstieg. Keine echte Installation oder SSH-/VPS-Abnahme dadurch.

```bash
python3 -B -m unittest discover -s tests -p test_tool_commands.py -v
python3 -I -B scripts/tool_commands.py docs
# Maintainers only: regenerate after registry changes.
python3 -I -B scripts/tool_commands.py docs --write
```

`docs` prueft nur Drift und liefert bei Abweichungen einen Fehlercode. `--write`
generiert ausschliesslich die Befehlstabelle; es installiert kein Tool. Die
bestehende Registry-Matrix bleibt ein separates, unveraendertes Artefakt.
