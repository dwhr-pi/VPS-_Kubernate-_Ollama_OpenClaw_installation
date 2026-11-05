# Markdown Docs Server: Offline-Handbuch

Optionales Tool **Markdown_Docs_Server**, als neuer Anhang hinter dem bestehenden
A-Z-Katalog. Python >=3.11 und Git erforderlich. Keine Docker-Installation, kein
PyPI, kein Hintergrunddienst und kein Browser-Autostart.

## Lesen und Navigation

Im laufenden Setup: unten **Optionen** waehlen, dann **22 - Offline-Handbuch /
Markdownserver einrichten und lesen**. Das neue Settings-Menue bietet die
Einrichtungsanleitung, den Dokumentations-Wegweiser und die zuletzt ergaenzten
Linux-/WSL-Labor- und Messwert-Backup-Anleitungen direkt als lokale Texte.
Das Oeffnen des Menues fuehrt weder Downloads noch Dateiaenderungen aus.

Plan, Status und Doctor sind getrennte Aktionen. Installation und Update fragen
einen vollstaendigen geprueften GitHub-Commit und danach eine separate Freigabe ab.
**Server starten** fragt Port und Freigabe ab; der Server laeuft im Vordergrund,
Stop mit **Strg+C**. Die URL wird angezeigt, kein Browser automatisch geoeffnet.
Deinstallation hat ebenfalls eine eigene Sicherheitsabfrage. Alle Freigaben sind
standardmaessig **Nein**; ein leerer Commit/Port oder Abbrechen startet nichts.

Das lokale Handbuch bietet sichtbare Direktlinks fuer Einstieg/Quickstarts,
aktuellen Status, sichere Installation, Branch-Auswahl und Installationsmessungen.
Auch Setup-Skripte, Speicherbereinigung, Neustart und Update/Entfernen sind direkt
sichtbar; historische Abschnittsziele werden als solche im Quelldokument erhalten.
Weitere Dokumente stehen im aufklappbaren Themenbaum. Volltextsuche durchsucht
auch den Dokumentinhalt; `/` fokussiert die Suche, Esc schliesst sie. Auf grossen
Bildschirmen steht rechts das Seiten-Inhaltsverzeichnis. Mobil oeffnet **Menue**
die Navigation. Code kann kopiert und die Seite gedruckt werden.

HTML, JavaScript und CSS werden lokal ausgeliefert. Keine CDN-Schriftarten,
Telemetrie oder externen Bilder. Externe Textlinks oeffnen nur nach eigenem Klick
einen neuen Tab und funktionieren ohne Internet gegebenenfalls nicht.
Relative Links funktionieren nur fuer die freigegebene Momentaufnahme. Nicht
enthaltene Dokumente/Downloads bleiben deaktiviert, statt beliebige Dateien zu lesen.
Textdateien ueber 1 MiB (beispielsweise grosse Inventar-JSONs) und Bilder ueber
20 MiB sind nicht als Browserseiten freigegeben. Keine PDF-/Office-Vorschau.

## Quellen und Installation

Der Installer holt ausschliesslich GitHub-Quellen: dieses Repository an einem
**von Ihnen geprueften vollstaendigen Commit**, ausserdem
[Python-Markdown](https://github.com/Python-Markdown/markdown/tree/b41e0aaf1181f1a8cb200cf5a815aad7c0020d23)
an Commit `b41e0aaf1181f1a8cb200cf5a815aad7c0020d23` (3.11.2, BSD-3-Clause).
Die Python-Quellen werden lokal geparst und mit einem Render-Smoke-Test geprueft;
kein Wheel oder vorgebautes Programm wird installiert. Die Lizenzdateien bleiben
enthalten. Ein Git-Commit pinnt Inhalt, ersetzt aber keine Release-Signatur oder
unabhaengige Sicherheitspruefung.

Im Repository-Verzeichnis, Linux oder WSL:

```bash
# Zuerst nur Plan: kein Download und kein Dateischreibzugriff.
bash scripts/tools/markdown_docs_server_install.sh

# Den ausgegebenen Commit selbst pruefen; dieser muss bereits auf GitHub stehen
# und den Dokumentationsserver enthalten. Nicht blind fremde Commits uebernehmen.
git rev-parse HEAD
read -r -p 'Gepruefter vollstaendiger Commit: ' DOCS_COMMIT
bash scripts/tools/markdown_docs_server_install.sh --source-commit "$DOCS_COMMIT" --apply
```

Das interaktive Tool-Menue bietet zunaechst diesen Plan; fuer die bewusste
Installation ist der oben beschriebene Commit-Aufruf oder die explizite
Installationsaktion in **Optionen -> 22** erforderlich. Uncommittete
oder noch nicht hochgeladene neue Dateien werden nicht als installierte
GitHub-Quellen ausgegeben. Erstinstallation braucht Netzwerk, spaeteres Lesen nicht.
Die Bash-Install/Update/Uninstall-Adapter liefern bei reinem Plan bewusst Exitcode
2, damit der generische Installer keinen erfolgreichen Lifecycle-Vorgang bucht.
Die Python-Planansicht selbst liefert 0 und kennzeichnet `apply:false`.

Standardziel: `~/.openclaw_ultimate_user_data/tools/markdown_docs_server`.
Optional kann `OPENCLAW_USER_DATA_DIR` auf einen eigenen absoluten, privaten
Workspace ausserhalb des Repositorys zeigen. Vorhandene unsichere Rechte oder
Dateilinks werden abgelehnt, nicht automatisch umgeschrieben.

## Bewusst starten und stoppen

```bash
python3 -I -B scripts/documentation_server/lifecycle.py doctor
python3 -I -B scripts/documentation_server/lifecycle.py serve --apply
```

Dann im Browser `http://127.0.0.1:8765` aufrufen. Stoppen mit **Strg+C** im
Server-Terminal. Optional `--port 8766` verwenden, falls 8765 belegt ist. Keine
Bindung an `0.0.0.0`, keine Firewall-Freigabe, kein Tunnel. Unter WSL kann der
Windows-Browser die WSL-Localhost-Weiterleitung nutzen, sofern diese lokal
konfiguriert ist; kein Zugriff ueber LAN wird dafuer eingeschaltet.

Windows nativ: denselben Python-Aufruf mit dem bereits vorhandenen
Python-Programmpfad und PowerShell-Aufrufoperator `&` verwenden. Keine Annahme,
dass `python` oder `py` im PATH vorhanden ist. Linux und WSL nutzen `python3`.

## Update, Entfernen und Rollback

```bash
bash scripts/tools/markdown_docs_server_status.sh
bash scripts/tools/markdown_docs_server_doctor.sh
read -r -p 'Neuer gepruefter vollstaendiger Commit: ' DOCS_COMMIT
bash scripts/tools/markdown_docs_server_update.sh --source-commit "$DOCS_COMMIT" --apply
bash scripts/tools/markdown_docs_server_uninstall.sh
# Erst nach Pruefung des Plans:
bash scripts/tools/markdown_docs_server_uninstall.sh --apply
```

Updates behalten den vorherigen Quellstand samt Hashnachweis unter
`history/<ID>/`. Fehlgeschlagenes Veroeffentlichen des neuen Snapshots rollt auf
den vorherigen zurueck. Fuer einen bewussten Versions-Rollback erneut den alten
geprueften GitHub-Commit mit `update --source-commit ... --apply` installieren.
Keine manuelle Uebernahme einzelner HTML-/Python-Dateien in den Hashnachweis.

Der Server haelt eine exklusive Aktionssperre. Vor Update/Uninstall beenden.
Eine nach einem harten Abbruch verbliebene `operation.lock` wird nicht automatisch
geloescht: zuerst sicherstellen, dass kein Server/Installer dieses Tools mehr
laeuft, dann ausschliesslich diese Sperre manuell behandeln. Keine Linux-/WSL-
Neuinstallation und kein Entfernen des gesamten User-Workspace erforderlich.

Deinstallation entfernt nur die hashgepruefte App und ihren Besitznachweis.
Update-Historie, Messwerte, andere Tools, Secrets und Backups bleiben erhalten.
Veraenderte oder fremde Dateien blockieren die Entfernung statt sie zu verwerfen.

## Sicherheits- und Abnahmegrenzen

Nur versionierte README-/Dokumentations-/Konfigurations-/Skriptdateien aus dem gewaehlten
Quellstand, keine User-Workspace-, `.env`- oder `.git`-Dateien. Konfiguration wird
als escaped Quelltext angezeigt, niemals ausgefuehrt. Markdown-HTML wird gefiltert,
aktive Inhalte und fremde Bildquellen werden entfernt. Host-/Origin-Pruefung,
CSP, Pfad-Allowlist und vier begrenzte HTTP-Worker begrenzen die lokale Angriffs-
flaeche. Der Server ist fuer einen einzelnen lokalen Leser, nicht fuer WAN oder
Multi-Tenant-Hosting ausgelegt. Wer bereits Leserechte auf den privaten Workspace
hat, liegt ausserhalb dieser HTTP-Sicherheitsgrenze.

`doctor` belegt Integritaet, nicht Browser-/Produktionsreife. Die Fixture-Tests
pruefen Loopback-HTTP, Rendering-/Pfad-Sicherheit und Lifecycle-Vertraege.
Ein echter GitHub-Install/Update/Uninstall-Lauf, Linux-/WSL-Browserabnahme und
vollstaendige visuelle Abnahme muessen separat dokumentiert werden.

Lokaler Nachweis vom 05.11.2026: Offline-HTTP-/Lifecycle-Fixtures unter Windows,
zusaetzlicher Render-Smoke-Test mit den gepinnten Python-Markdown-Quellen sowie
Headless-Chrome-Fixture fuer Desktop (1440 px) und Mobil (390 px) bestanden.
Zusaetzlich wurden alle 1.084 bereits versionierten Markdown-Dokumente dieses
lokalen Quellstands gerendert; README-Details und historische Direktanker passen.
Die Browser-Fixture ersetzt API-Antworten lokal, prueft Navigation, Suche,
Seitenwechsel, Menue und horizontales Overflow; keine externen Requests.
Sie ist kein echter GitHub-Installations- oder Gesamt-Setup-Test. Der Quellstand
dieser Erweiterung muss vor einer echten GitHub-Installation veroeffentlicht sein.

```bash
python3 -B -m unittest discover -s tests -p 'test_documentation_server.py' -v
```

Optionale Browser-Fixture fuer Entwickler mit bereits vorhandenem Playwright und
Chromium: `node tests/browser/documentation_server.cjs`. Keine automatische
Abhaengigkeitsinstallation; bei Bedarf `PLAYWRIGHT_MODULE` und
`BROWSER_EXECUTABLE` auf vorhandene lokale Programme setzen. Screenshots entstehen
nur im temporaeren Testordner; es wird kein installierter Server gestartet.

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
python3 -I -B scripts/tool_commands.py show markdown_docs_server
```

### SSH-Aktionen: `markdown_docs_server`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`Markdown_Docs_Server` (ID `markdown_docs_server`) waehlen und die Einzelfreigaben lesen.
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
