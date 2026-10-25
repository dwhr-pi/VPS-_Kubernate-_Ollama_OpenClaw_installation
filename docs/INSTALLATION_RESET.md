# Installations-Reset ohne Linux-Neuinstallation

Stand: 25.10.2026. Fuer Ubuntu/WSL. Keine Distribution zuruecksetzen oder
neu installieren, nur weil eine Installationssperre nach einem Absturz bleibt.
**Kein `wsl --unregister`, kein Loeschen der WSL-VHDX und kein pauschales `rm -rf`.**

## Im Setup

Nach Uebernahme der aktualisierten Skripte:

**Optionen -> 20: Installations-Reset / alte Sperren freigeben**

Alternativ: **Tooldiagnose -> 7: Installations-Reset** oder direkt:

```bash
bash scripts/installation_reset_menu.sh
```

1. Mit Auswahl 1 Sperren und Prozessstatus nur lesen.
2. Bei Bedarf mit Auswahl 3 die Tool-ID `node_red`, `litellm` oder `cadvisor` angeben. Leer bedeutet nur die globale Sperre.
3. Laufende Installationen/Builds in allen Terminals pruefen. Erst beenden oder abwarten.
4. Auswahl 2 und ausdrueckliche Zustimmung archivieren die freigegebenen alten Sperren.
5. Danach Tool erneut installieren beziehungsweise Doctor aufrufen.

`j/ja/y/yes` bestaetigt, Enter oder EOF lehnt ab. Ohne interaktives Terminal
fuehrt das Menueskript ausschliesslich die lesende Pruefung aus.

## Was wird zurueckgesetzt?

| Objekt | Verhalten |
|---|---|
| `install_transactions/.runner-lock` | Globales Installationsschloss; nach erfolgreicher Pruefung archivieren |
| `tools/TOOL_ID/operation.lock` | Optional genau ein bekannter Tool-Lock; nur leerer Ordner erlaubt |
| `install_transactions/.maintenance.lock` | Dauerhafte Koordinationsdatei; **niemals loeschen**. Ihr blosser Bestand bedeutet nicht aktiv gesperrt. |
| Modelle, Flows, Wallets, Secrets, Konfiguration, Tooldateien | Nicht zuruecksetzen, nicht loeschen |
| Erfolgsmarker / Installationsstatus | Nicht pauschal entfernen oder auf Erfolg setzen |
| apt/dpkg, Dienste, Docker, WSL, Linux | Nicht stoppen, reparieren oder neu installieren |

Alte Sperren werden innerhalb des Benutzer-Workspace nach
`install_transactions/reset_archives/ZEIT_UUID/` verschoben. Global ist nur
ein leerer Ordner oder eine kleine regulaere `owner.json` erlaubt. Unbekannte
Dateien, Symlinks, Mountpoints und fremde Besitzer blockieren den Reset.
Es gibt kein rekursives Loeschen und keine automatische Bereinigung unfertiger
Quell-/Buildverzeichnisse. Solche Bestaende brauchen getrennte Besitzpruefung.

## Wenn wirklich noch eine Installation laeuft

Ein Reset ist **kein Freibrief fuer zwei konkurrierende Installer**. Im
urspruenglichen Installations-Terminal kontrolliert mit **Ctrl+C** abbrechen
und warten, bis Kindprozesse beendet sind. Paketverwaltung wie apt/dpkg
moeglichst fertig arbeiten lassen, nicht mittendrin abbrechen. Danach erneut
pruefen. Bei haengenden/verwaisten Prozessen die angezeigten PIDs gezielt
administrativ untersuchen; kein `killall node`, `pkill python` oder pauschaler
SIGKILL. Diese Funktion sendet **keine Signale** an Prozesse.

Ist das alte Terminal nicht mehr vorhanden, darf ein noch laufender Compiler
nicht allein wegen eines alten Locks fuer tot erklaert werden. Die Pruefung
sucht nach Installerspuren und Compilern sowie aktiver Paketverwaltung. Sie
zeigt PID/Prozessnamen, keine vollstaendigen Argumente oder Umgebungsvariablen.
Zur Klassifikation werden Prozessargumente intern gelesen; sie werden nicht
ins Reset-Protokoll kopiert. Unlesbare Prozessdaten blockieren die Freigabe.
Unabhaengige Compiler-/Paketjobs koennen deshalb ebenfalls blockieren.

## Schutz gegen Ueberlappung und Grenzen

Aktualisierter Rollback-Runner und gemeinsame Python-Tooloperationen halten
waehrend ihrer Laufzeit eine geteilte Linux-`flock`-Sperre. Reset braucht die
exklusive Variante: er kann nicht parallel zu diesen Installern stattfinden.
Die Kernel-Sperre wird beim Prozessende freigegeben; die Datei bleibt bestehen.
Weitere Shell-/Altinstaller oder alte noch laufende Prozesse koennen diesen
Vertrag nicht nachtraeglich uebernehmen. Daher sind Prozesspruefung und die
manuelle Bestaetigung bei Legacy-Sperren weiterhin Pflicht.

Die Prozessliste ist eine Momentaufnahme, keine universelle Quieszenzgarantie.
**Vor Reset alle anderen Setup-/Buildstarts einstellen.** Unbekannte externe
Installer koennen nicht vollstaendig erkannt werden. Keine Freigabe allein
auf Basis fehlender PID oder einer willkuerlichen Wartezeit. Neue globale
Locks enthalten PID, Boot-ID und Startidentitaet; PID-Reuse wird nicht als
gleicher Besitzer behandelt. Inode/Inhalt werden vor Archivierung erneut
geprueft; eine inzwischen geaenderte Sperre blockiert.

## CLI fuer bewusste Administration

Aus dem Setup-Verzeichnis, bei Bedarf denselben `OPENCLAW_USER_DATA_DIR`
setzen, den auch die Installation verwendet:

```bash
# Read-only; no directories or logs are created.
python3 -I -B scripts/operations/reset_installation.py --check --tool node_red

# Only after reviewing and stopping all competing old installers/builds:
python3 -I -B scripts/operations/reset_installation.py --apply --tool node_red \
  --confirm-reset --acknowledge-legacy
```

Ohne `--tool` wird ausschliesslich die globale Sperre betrachtet. Tool-IDs
werden gegen `config/tools.yml` geprueft; keine freien Pfade erlaubt. Die
mutierende Funktion ist unter Windows nicht verfuegbar; in Ubuntu/WSL aufrufen.

## Logs und Wiederanlauf

Jeder bestaetigte Resetversuch bekommt eine **neue** Datei unter
`~/.openclaw_ultimate_user_data/install_logs/installation_reset_*.log`,
bei blockiertem/fehlgeschlagenem Versuch ggf. `installation_reset_failed_*.log`.
Ein schreibgeschuetztes Logziel stoppt die Archivierung. Erfolg wird erst nach
den tatsaechlichen Archivierungen gemeldet. Bei Teilfehler bleiben bereits
archivierte Sperren samt Journal erhalten; keine automatische Rueckverschiebung.

Ein kompletter VM-/Stromabbruch kann auch diesen Logger beenden. Fehlt der
Abschlussstatus, nicht Erfolg annehmen: neuen Check und aktuelles Archiv/Log
pruefen. Die reine lesende Pruefung erstellt absichtlich keine neue Logdatei.
Kein altes Tool-Installationsprotokoll wird als aktueller Resetnachweis ausgegeben.

Nach Reset kann der naechste Installer noch fehlende Voraussetzungen oder
unfertige Buildordner melden. Reset installiert kein Cargo/Node, umgeht keinen
Speicherwaechter und macht Quellen nicht zu einer fertigen Runtime.

## Pruefstand

Lokale Tests nutzen ausschliesslich temporaere Fixture-Verzeichnisse und
simulierte Prozesse. Linux-`flock`-/CNI-/WSL-Liveabnahme hier nicht ausgefuehrt.
Keine persoenlichen Installationssperren oder laufenden Prozesse wurden durch
die Entwicklung dieses Features veraendert.
