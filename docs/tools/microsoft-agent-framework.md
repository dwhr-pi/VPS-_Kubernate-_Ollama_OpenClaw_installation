# Microsoft Agent Framework aus GitHub

## Zuerst: Voraussetzungen und Grenzen

Optionaler, experimenteller Setup-Installer, kein Docker. Installiert wird die
Python-Bibliothek **agent-framework-core 1.22.0** aus dem offiziellen
[GitHub-Quellstand](https://github.com/microsoft/agent-framework/tree/17b1a14bd5b4c774c18d5b827b4f5b97bed3cbee/python/packages/core).
Das ist kein fertiger Coding-Assistent und kein Ersatz fuer Qwen Code.
Python und .NET sind getrennte Implementierungen; .NET wird hier nicht installiert.

Unsere konservative Installationsreserve: 2 GiB Gesamt-RAM, 2 GiB freier
Speicher auf dem Ziel-Dateisystem und unter WSL 10 GiB frei auf Windows C:.
Das sind Setup-Grenzen, keine gemessenen Microsoft-Mindestanforderungen.
Lokale Modelle brauchen zusaetzlichen RAM/VRAM und Speicher.
MiniPC, VPS und Raspberry Pi koennen das SDK ohne GPU verwenden; die spaetere
Modellleistung haengt vom getrennten Modellserver ab. ARM-Abhaengigkeiten
koennen Kompilierung erfordern; ein ARM-Ende-zu-Ende-Test steht aus.

Erforderlich: Linux, normaler Benutzer, Git, flock/util-linux und Python
3.10 bis 3.15 mit venv. Python 3.11+ bevorzugen; Ubuntu 24.04 mit Python 3.12
passt, ein isolierter Python-3.11-Build ist hier **nicht** notwendig.
Fehlende Basiswerkzeuge unter Ubuntu bewusst separat installieren:

```bash
sudo apt-get update
sudo apt-get install git util-linux python3 python3-venv
```

Nur Systemwerkzeuge kommen dabei aus apt. Das Framework selbst kommt aus
GitHub; Build- und Laufzeitabhaengigkeiten kommen aus PyPI. Vollstaendig
offline oder ausschliesslich GitHub fuer saemtliche Abhaengigkeiten ist das nicht.

## Schritt fuer Schritt

1. Im aktuellen Setup-Verzeichnis zuerst den Plan ansehen:

```bash
bash scripts/tools/agent_framework_install.sh --dry-run
```

2. Im Tools-Menue `Microsoft_Agent_Framework` bewusst auswaehlen oder:

```bash
bash scripts/tools/agent_framework_install.sh
bash scripts/tools/agent_framework_doctor.sh
bash scripts/tools/agent_framework_status.sh
```

Ohne `sudo` aufrufen. Der Installer klont den festen Commit
`17b1a14bd5b4c774c18d5b827b4f5b97bed3cbee` und installiert gezielt
`python/packages/core`, **nicht** den Monorepo-Root oder das Meta-Paket mit
allen Provider-Erweiterungen. Er verwendet eine private venv und veraendert
weder `/usr/bin/python3` noch globale Python-Pakete.

```text
~/.openclaw_ultimate_user_data/tools/agent_framework/
  source/        GitHub-Checkout
  venv/          eigene Python-Umgebung
  source-built   Erfolgsmarkierung mit Commit
  operation.lock
~/.openclaw_ultimate_user_data/install_logs/agent_framework_*.log
```

`OPENCLAW_USER_DATA_DIR` kann ein anderes absolutes, normalisiertes Verzeichnis
ausserhalb des Setup-Repos festlegen. Symlink-Ziele werden abgelehnt.
Eigenes kompatibles Python waehlt `AGENT_FRAMEWORK_PYTHON_BIN=/pfad/python3`.

3. Offline den installierten Paketstand abfragen:

```bash
"$HOME/.openclaw_ultimate_user_data/tools/agent_framework/venv/bin/python" -I -c \
  'from importlib.metadata import version; print(version("agent-framework-core"))'
```

Doctor prueft Metadaten, Git-Pin/saubere Quelle und `pip check`, ohne einen
Agenten oder Provider zu importieren. Das beweist noch keine Modellfunktion.
Dry-Run/Status/Doctor laden nichts herunter und erzeugen keinen Workspace.

## Fehler, Update und Deaktivierung

```bash
bash scripts/tools/agent_framework_install.sh --repair
bash scripts/tools/agent_framework_update.sh
bash scripts/tools/agent_framework_uninstall.sh
```

Normale Installation ist bei konsistentem Pin idempotent. Update/Repair bauen
denselben Pin erneut; ein neuer Upstream-Stand muss zuvor im Setup geprueft
werden. Keine automatische Verfolgung von `main` oder `latest`.
Die abhaengigen PyPI-Versionen sind durch Upstream-Bereiche begrenzt, aber
nicht vollstaendig mit Hashes verriegelt: reproduzierbarer Dependency-Lock
bleibt offen. Ein Build fuehrt fremden Build-Code aus, daher kein sudo verwenden.

Bei Fehlern bleibt die Erfolgsmarkierung aus; Log und Quellen bleiben erhalten.
Fremde, unvollstaendige oder veraenderte Quellordner werden nicht geloescht
oder ueberschrieben. Diese nach manueller Pruefung sichern/umbenennen und
erneut installieren. Es gibt noch keinen transaktionalen venv-Rollback.
Deinstallation bedeutet bewusst **Deaktivierung**: nur die Erfolgsmarkierung
wird entfernt. Quellen, venv, Projekte und Daten bleiben fuer Sicherung erhalten;
manuell weiterbenutzte Python-Umgebungen werden dadurch nicht technisch gesperrt.

## OpenClaw, Ollama und n8n

Die Installation startet keine Agentenschleife, Dienste, Ports, Cloud-Logins,
Downloads von Modellen oder fremde Werkzeuge. Ein eigener Python-Worker kann
spaeter freigegebene Aufgaben aus der [lokalen Queue](../JOB_QUEUE_AGENT_WORKER.md)
verarbeiten. OpenClaw/n8n sollten nur validierte Auftragsdaten liefern, keine
ungefilterten Shellbefehle. Zunaechst ein Auftrag gleichzeitig, feste Timeouts
und begrenzte Korrekturrunden; Schreibaktionen brauchen gesonderte Freigabe.

Der Kern enthaelt nicht automatisch alle Provider-Adapter. Fuer Ollama gibt es
ein [eigenes Upstream-Paket](https://github.com/microsoft/agent-framework/tree/17b1a14bd5b4c774c18d5b827b4f5b97bed3cbee/python/packages/ollama).
Dessen Einrichtung, Modellkompatibilitaet und Ende-zu-Ende-Test sind separat
offen, ebenso Cloud-Adapter, .NET, MCP und AutoGen-Migration. Keine ungeprueften
Beispiele als fertige Integration behandeln. Modell-APIs nur lokal/VPN, keine
Admin-Panels oeffentlich. Keys ausschliesslich im privaten Workspace speichern,
nicht in Git, Prompts oder Logs. Kein automatisches Einlesen des ENV-Tresors.

Diese Aenderung am Setup wurde nur mit Offline-Pruefungen getestet, nicht durch
Installation in einer WSL oder durch Aufrufe eines Modellanbieters.
