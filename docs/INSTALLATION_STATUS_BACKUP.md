# Programmliste sichern, exportieren und wiederherstellen

Fuer `.env` und API-Keys gibt es den getrennten
[verschluesselten Zugangsdaten-Export mit E-Mail-Option](CREDENTIALS_BACKUP.md) unter **Optionen ->
21 -> 5**. Der Inventarexport selbst enthaelt keine Keys.

Stand: 25.10.2026. Gemeint ist hier der **Installationsstatus / das Inventar**, nicht das erneute
Installieren von Programmen und nicht das komplette Textarchiv aller Installationslogs.

## Warum ein GitHub-Abgleich nicht alles loeschen sollte

Der aktuelle Status liegt ausserhalb des Git-Repositories:

```text
~/.openclaw_ultimate_user_data/installed_tools.txt
~/.openclaw_ultimate_user_data/status/installed_tools.txt
~/.openclaw_ultimate_user_data/installed_profiles.txt
~/.openclaw_ultimate_user_data/status/installed_profiles.txt
```

Der aktuelle gesicherte [Main-Abgleich](../scripts/auto_update_hard.sh) ersetzt Repository-Inhalte,
nicht diese externen Statusdateien. Damit ist **nicht** bewiesen, was bei einem aelteren Update auf
deinem Rechner passiert ist. Abweichende Workspace-Pfade, unterschiedliche Statuskopien und der
nachfolgende Abgleich mit Markern/Registry koennen ebenfalls unterschiedliche Anzeigen erklaeren.
Keine persoenlichen Statusdateien wurden fuer diese Aenderung gelesen.

`OPENCLAW_USER_DATA_DIR` wird jetzt auch von den beiden gemeinsamen Statushelfern konsistent
beruecksichtigt. Ohne Variable bleibt der Standardpfad. Der Export fuehrt beide Statuskopien lesend
zusammen und sucht zusaetzlich nach registrierten lokalen Nachweisen. Er veraendert beim Export
keine Statusdatei.

## Neu im Setup

## Optionen -> 21: Installationsstatus / Programmliste exportieren und wiederherstellen

Alternativ: **Benutzer-Workspace -> 10** oder:

```bash
bash scripts/installation_inventory_menu.sh
```

| Aktion           | Ergebnis                                                                           |
| ---------------- | ---------------------------------------------------------------------------------- |
| Anzeigen         | Erfasste Programme und lokale Hinweise, ohne Dienststart                           |
| Export           | Neue JSON-Datei plus gleichnamige lesbare Markdown-Programmliste                   |
| Vorschau         | Pruefsumme und aktuelle lokale Nachweise pruefen; nichts importieren               |
| Wiederherstellen | Nach Zustimmung qualifizierte Eintraege in beide Tool-Statuskopien zusammenfuehren |

Ein vorhandener Export wird niemals ueberschrieben. Unterschiedliche Dateinamen fuer mehrere Staende
verwenden. Kein globales Default-Verzeichnis im Workspace fuer den unabhaengigen Export: Ziel
bewusst ausserhalb waehlen.

## Was in einem normalen Backup steht

`scripts/operations/backup_run.sh` erstellt oben im neuen Backupverzeichnis:

```text
backups/ZEIT_PID/installation-inventory.json
backups/ZEIT_PID/installation-inventory.md
```

Die Markdown-Datei zeigt Programmname, erfassten Status und lokalen Hinweis. Diese Liste ist ein
Zeitpunktbestand, keine Runtime-Abnahme. Die JSON-Datei ist fuer den spaeteren Import gedacht.
Scheitert eine rsync-Kopie, bleibt der Teilbestand erhalten, aber das Backup meldet **keinen
vollstaendigen Erfolg**.

Vor dem ausdruecklich freigegebenen harten Main-Abgleich wird ebenfalls ein Inventar unter
`repo_update_backups/installation-inventory-ZEIT-PID.json` mit lesbarer Begleitdatei erzeugt. Der
reine Update-Dry-Run exportiert nichts. Die zusaetzliche Sicherung ist unabhaengig von der
Repo-Dateisicherung, aber noch **kein Offsite-Backup**. Scheitert der Inventarexport, startet der
Apply- Pfad den Repo-Abgleich nicht.

## Export muss einen kompletten Verlust ueberleben

Wenn Workspace **und** dessen Backups geloescht werden, ist eine weitere Kopie in demselben
Verzeichnis nutzlos. Auf USB/NAS, ein anderes Laufwerk oder einen geeigneten geschuetzten externen
Speicher exportieren. Bei WSL liegen Pfade unter `/home/ubuntu` meist in derselben
Distribution/VHDX: sie ueberleben kein `wsl --unregister`. Ein bewusst gewaehltes Windows-Laufwerk
ausserhalb der VHDX oder eine weitere externe Kopie ist dafuer noetig. Ein anderes Verzeichnis auf
derselben defekten Festplatte ersetzt wiederum kein unabhaengiges Backup.

```bash
# Example only: select an existing suitable external drive/share.
python3 -I -B scripts/operations/installation_inventory.py export \
  --output /mnt/d/Setup-Sicherung/programme-2026-10-25.json
```

Es entstehen `.json` und `.md`. Der Export enthaelt keine `.env`, API-Keys, Wallets,
Browser-Cookies, Modelle, Binaerdateien oder ausfuehrbaren Ready-Marker. Er uebernimmt nur bekannte
Statusnamen; unbekannte/ungueltige Statuszeilen werden gezaehlt, nicht mit moeglicherweise sensiblen
Inhalten exportiert. Programmnamen sind dennoch persoenliche Metadaten: Exportziel passend
schuetzen. Dateien werden mit 0600 angelegt, soweit das Zielfilesystem dies durchsetzt.

## Wiederherstellung nach neuer Setup-Kopie

1. Setup erneut aus vertrauenswuerdiger Quelle bereitstellen.
2. Externe JSON-Datei wieder zugaenglich machen; niemals darin enthaltene Befehle ausfuehren.
3. Alle Installer schliessen und im Menue zuerst die Vorschau lesen.
4. Erst danach die Zusammenfuehrung bestaetigen.
5. Offene Programme separat installieren beziehungsweise deren vorhandene Nachweise pruefen.

```bash
python3 -I -B scripts/operations/installation_inventory.py preview \
  --input /mnt/d/Setup-Sicherung/programme-2026-10-25.json

# Only after checking the preview and closing all installers:
python3 -I -B scripts/operations/installation_inventory.py restore \
  --input /mnt/d/Setup-Sicherung/programme-2026-10-25.json --confirm-restore
```

Der aktuelle Workspace ist das Importziel; bei Bedarf dieselbe `OPENCLAW_USER_DATA_DIR`-Variable wie
im Setup setzen. Exportierte Pfade oder Checkbefehle werden nicht als Importanweisungen verwendet.

## Was wird als vorhanden uebernommen?

**Nicht blind alle alten Haekchen wieder setzen.** Der heutige Registry-Vertrag ist massgeblich.
Fuer geeignete JSON-Nachweise werden Commit, relative Artefakt- Pfade und die gespeicherten
Artefakthashes lesend geprueft. Quellen-/Buildnachweis ist weiterhin nicht gleich laufender oder
voll funktionierender Dienst. Geprueft werden die angegebenen Artefakte, nicht pauschal saemtliche
Dateien, Git-Objekte oder die Herkunft des gesamten bestehenden Systems.

Ein registriertes konkretes Programm im PATH kann als Anwesenheitshinweis dienen; ein allgemeines
`python3`/`node` beweist dagegen keine installierte Anwendung. Ports, fremde Doctor-/Statusskripte
und Provider-APIs werden nicht aufgerufen. Verzeichnisse, einfache Textmarker oder unpassende
Nachweise bleiben offen, statt daraus einen sicheren Installed-Status zu erfinden. Die spaetere
eigene Statuspruefung des Tools bleibt massgeblich und kann Eintraege korrigieren.

Die importierte Liste bleibt vollstaendig als historische Inventardatei erhalten. Profile werden
ebenfalls historisch gespeichert, aber nicht automatisch als fertig installierte Profile gesetzt:
deren Komponenten koennen fehlen. Es gibt keinen automatischen Tool-/Profil-/Modellstart und keine
Neuinstallation.

**Sind auch die Programme und Nachweise geloescht, stellt die Liste sie nicht wieder her.** Dann ist
sie ein Neuaufbauplan. Fuer echte Programm-/Daten- Wiederherstellung braucht es ein separates
vollstaendiges, konsistentes Backup. Vollstaendige Installationslogs sind darin gesondert und ggf.
verschluesselt zu sichern; der Inventarimport bringt kein Textlogarchiv zurueck.

## Datenerhalt und Grenzen

Bestehende Tool-Statuszeilen werden zusammengefuehrt, nicht entfernt. Vor jedem Import werden die
vorherigen beiden Dateien unter `status_restore_history/ZEIT_UUID/` gesichert, zusammen mit
importiertem Inventar, offenen Eintraegen und Ergebnisjournal. Beide Zieldateien werden jeweils
atomisch ersetzt, nicht als dateiuebergreifende Transaktion. Ein Teilfehler wird als solcher
protokolliert; alte Kopien bleiben fuer die manuelle Wiederherstellung erhalten. Vorherige
Statusdateien koennen ungueltige manuelle Inhalte enthalten und bleiben deshalb privat im lokalen
Sicherungsverzeichnis, nicht im portablen Export.

Aktualisierte Installer/Reset/Inventar koordinieren sich ueber die Wartungssperre. Alte oder externe
Prozesse beachten diese nicht automatisch: vor Export/Import alle konkurrierenden Statusschreiber
stoppen. Das normale rsync-Backup ist kein Live-Datenbank-/PVC-Snapshot; konsistente
Daten-/Modell-/Restoreplaene bleiben separat. Der Inventarstand gilt fuer seinen ausgewiesenen
Exportzeitpunkt.

SHA256 erkennt Beschaedigung, ist **keine Signatur und kein Echtheitsbeweis**. Nur
vertrauenswuerdige Exporte importieren. Unbekannte Versionen, fehlerhafte Pruefsummen, zu grosse
Dateien, Symlinks und unsichere Pfade werden abgelehnt. Ein vollstaendiger Host-/WSL-Restore wurde
hier nicht durchgefuehrt.
