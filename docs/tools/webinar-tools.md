# Marp, listmonk und Mautic ohne Docker installieren

[Webinar-Stack: von Inhalt und Anmeldung bis Replay und Teilnehmerkommunikation](../tutorials/webinar-stack.md)
ordnet die drei Programme in einen vollstaendigen, schrittweisen Ablauf ein.

Stand: 22.10.2026. Eigene Installer im Tools-Menue: **Marp**, **Listmonk**, **Mautic**. Offizielle,
fest gepinnte GitHub-Release-Artefakte mit SHA256 und exakter Downloadgroesse; keine Container,
globalen npm-Pakete oder ungefragten Systemupdates.

| Tool / Version | Aufgabe                                             | Lizenz / Quelle                                                     | Was installiert wird                                                         |
| -------------- | --------------------------------------------------- | ------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| Marp CLI 4.5.1 | Markdown in HTML/PDF/PPTX-Praesentationen umwandeln | [MIT, marp-team/marp-cli](https://github.com/marp-team/marp-cli)    | Standalone-CLI, kein eigenes Node/npm erforderlich                           |
| listmonk 6.2.0 | Newsletter, Teilnehmerlisten, Kampagnen             | [AGPL-3.0, knadh/listmonk](https://github.com/knadh/listmonk)       | Native Binary; PostgreSQL und SMTP bleiben separat                           |
| Mautic 7.2.1   | Kontakte, Segmente, Marketing-Automation            | [GPL-3.0-or-later, mautic/mautic](https://github.com/mautic/mautic) | Vollpaket mit vendor, nicht das Update-ZIP; PHP/DB/Webserver bleiben separat |

Mautic ist **nicht AGPL**. Kostenlose Software bedeutet nicht kostenlosen Mailversand, Hosting oder
Wartung. listmonk und Mautic sind keine Webinar- Streamingserver. Fuer einen schlanken Einstieg
reicht haeufig listmonk; beide Programme werden nicht automatisch miteinander verbunden.

## Installation und Pruefung

In **Tools: Installieren & Deinstallieren** oeffnet die Schaltflaeche **Ubuntu / Windows** eine
Setupauswahl fuer diese drei Webinar-Werkzeuge. Erst Zielplattform, dann Werkzeug und Aktion
waehlen. Standard ist Ubuntu/WSL und anschliessend ein schreibfreier Plan; abbrechen startet nichts.
Installieren, Update und Entfernen haben eine zusaetzliche Zielbestaetigung. Die normale
Tool-Checkliste bleibt fuer Ubuntu/WSL; Windows-Installationen werden dort nicht faelschlich als
Linux-Installation angehakt.

Unter WSL kann die Windows-Auswahl den nativen PowerShell-Einstieg ueber vorhandenes Windows-Interop
ausfuehren. Sie startet keine WSL-Distro und wechselt bei fehlendem Interop nicht stillschweigend
auf ein anderes Ziel. Stattdessen wird der entsprechende manuelle Windows-Befehl angezeigt.
Windows-Status liegt im Windows-Benutzerverzeichnis, Ubuntu-Status im Linux-Benutzerverzeichnis.
Status/Doctor und Entfernen deshalb ebenfalls ueber die passende Plattformauswahl aufrufen.

Im Tools-Menue die drei Programme einzeln waehlen. Unter Ubuntu/Linux auch:

```bash
bash scripts/tools/marp_install.sh --dry-run
bash scripts/tools/marp_install.sh
bash scripts/tools/listmonk_install.sh
bash scripts/tools/mautic_install.sh
```

Native Windows-Installation derselben Programme ohne WSL mit vorhandenem Python >=3.10, vom
Setup-Verzeichnis aus:

```powershell
.\scripts\windows\webinar_tools.ps1 -Tool marp -Action plan
.\scripts\windows\webinar_tools.ps1 -Tool marp -Action install
.\scripts\windows\webinar_tools.ps1 -Tool listmonk -Action install
.\scripts\windows\webinar_tools.ps1 -Tool mautic -Action install
```

Bei Bedarf `-PythonBin C:\Pfad\python.exe` angeben. Der Plan braucht kein Python, macht keine
Netzwerkaufrufe und installiert nichts. Bei echten Aktionen wird ein vorhandenes natives
Windows-Python >=3.10 geprueft; ein Windows-Python-Bootstrap erfolgt nicht. Es wird kein
Ausfuehrungsrichtlinien- Bypass gesetzt. Eine lokale Richtliniensperre muss bewusst geprueft werden.

Kein Python-Bootstrap. Marp: Linux amd64/arm64 und Windows amd64. listmonk: Linux und Windows
amd64/arm64. Mautic: plattformneutrales PHP- Dateipaket; eine native Windows-Produktionsinstallation
ist damit nicht zugesichert. Nicht unterstuetzte Plattformen scheitern vor einem Download.

Standardziel: `~/.openclaw_ultimate_user_data/tools/<tool>/app/`. `OPENCLAW_USER_DATA_DIR` kann ein
anderes absolutes externes Ziel bestimmen. Installationsmarker: `release-ready.json` mit Version,
Artefakt-Hash und Dateihashes. Kein globaler PATH-Umbau; den Programmeinstieg im Marker benutzen.

Die Installer pruefen Marp/listmonk mit `--version`. Mautic wird auf Vollpaket- Struktur geprueft,
nicht durch Start von PHP, Webserver oder Installationswizard. **Installiert bezeichnet
Programmdateien**, nicht eine fertig konfigurierte Marketingplattform. `service_configured` bleibt
false; bei listmonk/Mautic auch `runtime_ready`. Marp ist als CLI vorbereitet; PDF-/PPTX-Export
benoetigt einen passenden vorhandenen Browser, der nicht automatisch installiert wird.

## Marp: Versionsaufruf bricht mit Exit 127 ab

Das Nutzerlog vom **22.10.2026, 21:42** zeigt einen Abbruch bei `marp --version`, nicht bei der
Speicherwache. Der bisherige Installer unterdrueckte dabei die aufgefangene stderr-Ausgabe. Aus Exit
127 allein laesst sich deshalb keine bestimmte fehlende Bibliothek auf deinem Rechner sicher
bestimmen.

Das SHA256-gepruefte Linux-amd64-Release wurde hier **ohne Ausfuehrung** im Speicher auf seine
ELF-Abhaengigkeiten untersucht: Es benoetigt unter anderem `libatomic.so.1`, `libstdc++.so.6` und
`libgcc_s.so.1`. Standalone bedeutet also kein separates Node/npm, aber nicht unabhaengig von
Systembibliotheken.
[Offizielles Release](https://github.com/marp-team/marp-cli/releases/tag/v4.5.1),
[Standalone-Buildskript](https://github.com/marp-team/marp-cli/blob/v4.5.1/scripts/standalone/build.mjs).

Der korrigierte Installer schreibt stdout, stderr und Exit-Code jetzt in das **aktuelle**
Operationslog, bevor er einen Fehler meldet. Bei einer eindeutigen Loader-Meldung kann er auf
Ubuntu/Debian gezielt anbieten:

| Fehlende Bibliothek | Freigegebenes Laufzeitpaket |
| ------------------- | --------------------------- |
| `libatomic.so.1`    | `libatomic1`                |
| `libstdc++.so.6`    | `libstdc++6`                |
| `libgcc_s.so.1`     | `libgcc-s1`                 |

Nur ein tatsaechlich genanntes Paket wird angeboten, keine pauschale Installation aller
Bibliotheken. Zustimmung mit `[(j)a/(N)ein]`; apt wartet begrenzt auf eine aktive Paketverwaltung.
Paketentfernungen sind gesperrt, passende Systemabhaengigkeiten koennen mit aktualisiert werden.
Diese gemeinsamen Bibliotheken bleiben bei Marp-Deinstallation erhalten.

Danach erfolgt **genau ein erneuter Versionsversuch**. Erst wenn dieser erfolgreich ist und die
gepinnte Version meldet, wird der Marker erstellt. Bei weiterem Fehler wird abgebrochen und nur der
neue Stage-Bestand entfernt. Ein erfolgreich installiertes System-Basispaket wird dabei nicht wieder
automatisch entfernt, da andere Programme es verwenden koennen.

Erneut im Tools-Menue installieren oder, nach bewusster Freigabe des beschriebenen Paketpfads,
nichtinteraktiv:

```bash
MARP_INSTALL_RUNTIME_LIBS=1 bash scripts/tools/marp_install.sh --repair
```

`MARP_INSTALL_RUNTIME_LIBS=0` verbietet die Reparatur; Standard `ask` fragt nur bei interaktivem
Terminal. Ohne Zustimmung bleibt der gezielte Befehl im Log zur separaten Ausfuehrung. Unbekannte
Bibliotheken, GLIBC-/GLIBCXX- Versionskonflikte, Architektur-/Loaderfehler und andere Exit-Codes
loesen **keine** automatische apt-Reparatur aus. Keine glibc-Ersetzung, geratenen Symlinks,
`LD_LIBRARY_PATH`-Umleitung oder Docker-/npm-Ausweichinstallation. Browser-/Sandbox-Fehler beim
spaeteren Export sind ein anderer Test und werden nicht durch Abschalten der Browser-Sandbox
kaschiert.

### Log endet nach dem Reparaturvorschlag

Beim gemeldeten Fehler `libatomic.so.1` fehlt **libatomic1**, nicht freier Speicher. Falls das Log
nach dem apt-Vorschlag endet, ist damit noch keine erfolgreiche Reparatur belegt. Der Installer gibt
die Bestaetigungsfrage jetzt als vollstaendige, sofort ausgegebene Logzeilen aus und zeigt an, dass
er auf eine Antwort mit Enter wartet. `j` oder `ja` bestaetigt, Enter ohne Antwort lehnt ab. Die
Entscheidung wird ebenfalls protokolliert. Ohne interaktives Eingabeterminal wird nicht gewartet
oder still zugestimmt. Nach Zustimmung kann **sudo separat nach dem Benutzerpasswort fragen**;
Passwoerter gehoeren weder ins Log noch in den Chat.

Alternativ die im konkreten Fehler genannte Bibliothek bewusst separat einrichten und danach Marp
erneut im Tools-Menue installieren:

```bash
sudo apt-get -o DPkg::Lock::Timeout=300 install --no-remove --no-install-recommends libatomic1
bash scripts/tools/marp_install.sh --repair
```

Oder den oben dokumentierten Weg mit `MARP_INSTALL_RUNTIME_LIBS=1` verwenden. Marp selbst kommt
weiterhin aus dem geprueften GitHub-Release, nicht aus Docker.

Die Reparaturlogik wurde mit synthetischen Loader-/apt-Ausgaben getestet; keine Paketinstallation
oder Live-Ausfuehrung auf deinem WSL-System hier.

## Nach der Paketinstallation

- Marp: eigenes Markdown erstellen und HTML zuerst testen. Der normale PPTX- Export ist nicht
  gleichbedeutend mit vollstaendig editierbaren Folien.
  [Exportoptionen](https://github.com/marp-team/marp-cli#usage).
- listmonk: eigene PostgreSQL-Datenbank, Zugangsdaten und SMTP bewusst bereitstellen. `--install`
  initialisiert eine DB und wird hier **nicht** ausgefuehrt. Zuerst mit Testempfaenger und ohne
  produktive Listen einrichten. [Offizielle Anleitung](https://listmonk.app/docs/installation/).
- Mautic: zum Release passende PHP-Version/-Extensions, Datenbank und Webserver pruefen. Danach
  separat einrichten, nicht pauschal den app-Ordner mit einem Entwicklungsserver ins Netz stellen.
  Keine automatischen Cronjobs, Trackingpixel, Kontaktimporte oder E-Mails durch den Installer.
  [Mautic-Dokumentation](https://docs.mautic.org/).

Konfiguration, Exporte und Nutzerdaten ausserhalb des verwalteten app-Ordners ablegen. Keine Keys im
Git oder Chat, siehe [API-Key-Uebersicht](../_API-Keys/README.md).

## Status, Update, Deinstallation und Fehler

Alle drei haben install/update/uninstall/status/check/doctor-Skripte. Direkte CLI: toolname und
Aktion austauschen:

```text
python -B scripts/tools/helpers/webinar_releases.py marp status
python -B scripts/tools/helpers/webinar_releases.py marp doctor
python -B scripts/tools/helpers/webinar_releases.py marp update
python -B scripts/tools/helpers/webinar_releases.py marp uninstall
```

Update/Repair pruefen denselben Pin, kein unbeaufsichtigtes latest-Upgrade und keine DB-Migration.
Bei lokalen Aenderungen/Zusatzdateien wird nicht geloescht oder ueberschrieben. Fuer einen neuen
Versionspin erst Backup/Migrationsplan und Releasepruefung vornehmen.

Deinstallation entfernt nur die nach Hashinventar unveraenderten verwalteten Programmdateien und
ihren Marker. Datenbanken, SMTP, Basiswerkzeuge, ausserhalb liegende Konfiguration und Logs bleiben
erhalten. Aenderungen im app-Ordner vorher bewusst sichern/umziehen; kein automatisches Verwerfen.

Reserve vor Download: Marp/listmonk jeweils 1 GiB, Mautic 2 GiB. Unter WSL wird zusaetzlich die
C:-Reserve geprueft; abweichende VHDX-Laufwerke separat pruefen. Archivpfade, Links und
Spezialdateien werden abgewehrt, Entpacklimit 1 GiB. Fehler entfernen nur Stagingdateien und
gegebenenfalls den in diesem Versuch neu veroeffentlichten Programmordner, keine vorherigen
Nutzerdateien. Aktuelle Fehler stehen in einem neuen Log unter `install_logs/`.

## Reproduzierbarkeit

Artefakt-Digests und Dateigroessen am 22.10.2026 aus den offiziellen GitHub- Release-Metadaten
abgeglichen. listmonk bleibt auf 6.2.0: Das als latest angebotene 7.0.0-beta.1 wird trotz upstream
prerelease=false nicht gewaehlt. Kein selbst erfundener Quellcode-Pin und kein GitHub-Source-ZIP als
fertiges Mautic-Installationspaket ausgegeben.

```text
python -B -m unittest discover -s tests -p test_webinar_releases.py -v
```
