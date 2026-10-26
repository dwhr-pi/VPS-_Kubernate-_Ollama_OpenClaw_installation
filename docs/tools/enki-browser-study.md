# Enki Browser fuer Studienzwecke und Weiterentwicklung

Stand: 26.10.2026. **Experimenteller Entwicklungsweg, keine Produktionsfreigabe.**
Der Studienzweck ist eine Kennzeichnung im Setup, keine zusaetzliche Lizenz.
Enki nennt MIT; Chromium, Erweiterungen und sonstige Drittanbieter behalten ihre
eigenen Bedingungen. Insbesondere nicht das ganze Paket pauschal als MIT behandeln.

## Zwei getrennte Wege

| Tool unterhalb der Trennlinie, alphabetisch einsortiert | Zweck |
|---|---|
| **Enki_Browser** | Bestehender manueller Desktop-Download von offiziellen GitHub-Releases |
| **Enki_Browser_Study** | Gepinnte GitHub-Quellen fuer Studien und Weiterentwicklung; optionaler Paketbuild |

Der bisherige manuelle Installationsweg bleibt unveraendert.
**Anders als BrowserOS kompiliert Enkis offizieller Paketbuild Chromium nicht
vollstaendig aus Quellcode.** Er baut die Enki-Erweiterung und setzt das Paket
mit fertigem ungoogled-chromium und weiteren gepinnten Komponenten zusammen.
Dies ist **kein vollstaendiger Chromium-Source-Build**.
Quelle: [offizieller Beitragsleitfaden](https://github.com/danilogiles/enki-browser/blob/fd0ce82c486bbd54b4f81186fd455c0796cf536f/CONTRIBUTING.md),
[gemeinsame Buildfunktionen](https://github.com/danilogiles/enki-browser/blob/fd0ce82c486bbd54b4f81186fd455c0796cf536f/build/common.mjs).

## Nur Quellen herunterladen

Im Tools-Menue **Enki_Browser_Study** waehlen. Auswahl **1** ist Standard:
nur Quellen, kein Node-/Browser-/Paketdownload. Ohne Terminal ebenfalls Quellen.

```bash
bash scripts/tools/enki_browser_study_install.sh --dry-run
bash scripts/tools/enki_browser_study_install.sh
bash scripts/tools/enki_browser_study_status.sh
```

Pin: [fd0ce82c486bbd54b4f81186fd455c0796cf536f](https://github.com/danilogiles/enki-browser/tree/fd0ce82c486bbd54b4f81186fd455c0796cf536f).
Ziel: `~/.openclaw_ultimate_user_data/tools/enki_browser_study/runtime/`,
bei eigenem `OPENCLAW_USER_DATA_DIR` entsprechend dort. Reserve 2 GiB.
Git-HEAD, Origin und Nachweisdateien werden geprueft. Keine Profile, Cookies,
Konten oder API-Keys importiert. Update prueft denselben Pin statt `latest/main`.

Quellen koennen bewusst untersucht oder in einer eigenen Arbeitskopie/Fork
weiterentwickelt werden. Lokale Aenderungen werden nicht zurueckgesetzt;
Doctor und Deinstallation blockieren bei Abweichungen statt Arbeit zu loeschen.
Der automatische Erstbuild erwartet dagegen den unveraenderten Pin. Fuer eigene
Aenderungen die Upstream-Entwicklungsanleitung in einer gesonderten Kopie nutzen.

## Optional Erweiterung bauen und Browser paketieren

Interaktive Auswahl **2**, danach Zustimmung zu den fertigen Binaerkomponenten.
Alternativ ausdruecklich:

```bash
bash scripts/tools/enki_browser_study_install.sh --build-browser --dry-run
bash scripts/tools/enki_browser_study_install.sh \
  --build-browser --accept-pinned-binaries
```

Voraussetzungen:

- **Linux/WSL x86_64** oder **natives Windows x64**, kein Crossbuild und derzeit
  kein integrierter macOS-/ARM-Paketbuild.
- Vorhandenes Node >=22 und passendes npm. Kein automatischer Node-/npm-Umbau.
- **8 GiB Startreserve** fuer den Paketweg; unter WSL auch auf dem Windows-Host.
  Das ist eine konservative Setup-Reserve, keine gemessene Buildgroesse.
- Linux: **4 GiB verfuegbarer RAM**, `tar`, `xz`, `unzip`. `dpkg-deb` ist optional;
  Upstream kann damit zusaetzlich ein `.deb` bauen, installiert es aber nicht.
- Windows: System-`tar.exe` und der vorhandene .NET-Framework-C#-Compiler
  `csc.exe`. Mindestens 4 GiB freier RAM empfohlen; die automatische RAM-Pruefung
  ist derzeit nur unter Linux umgesetzt. Kein Windows-Build aus WSL heraus.

Unter nativem Windows das gleiche Python-Hilfsprogramm verwenden, z.B. aus dem
Setup-Repository in PowerShell mit vorhandenem Python >=3.10:

```powershell
python -B scripts/tools/helpers/enki_browser_study.py install --build-browser --accept-pinned-binaries
```

Der Paketweg arbeitet in einer **neuen Kopie** unter
`tools/enki_browser_study/development/source/`. Der urspruengliche Studien-
Checkout bleibt unveraendert. Vorhandene Entwicklungsordner werden nicht
ueberschrieben, denn die Upstream-Skripte bereinigen ihr eigenes `out/`.

Root- und Erweiterungsabhaengigkeiten werden mit `npm ci --ignore-scripts`
installiert; dann wird die Erweiterung explizit mit `npm run build` gebaut.
`ENKI_DIST` zeigt auf diese Ausgabe, damit Upstream sie ohne weitere Shell-
npm-Aufrufe uebernimmt. Abhaengigkeiten kommen auch aus npm, nicht nur GitHub;
die Lockfiles liefern deren Integritaetsdaten. Kein Offline-Versprechen.

Danach der plattformspezifische Upstream-Aufruf:

```text
Linux:   node build/build-linux.mjs
Windows: node build/build.mjs
```

Dieser laedt passende GitHub-Release-Komponenten aus der gepinnten
[upstream.json](https://github.com/danilogiles/enki-browser/blob/fd0ce82c486bbd54b4f81186fd455c0796cf536f/upstream.json).
URLs muessen HTTPS/GitHub-Releases und die Digests SHA256-Format haben; die
Buildfunktion verifiziert die heruntergeladenen Bytes gegen diese Digests.
GitHub kann auf Asset-CDNs umleiten; kein hostexklusives Netzwerkversprechen.
Die Binaer-Ausnahme erfordert bewusst `--accept-pinned-binaries` oder Zustimmung
im Menue. Ohne diese bleibt es beim reinen Quellcode-Weg.

**Kein Docker, kein Upload, kein automatisches Installieren oder Browserstart.**
Signierbefehle/Schluessel und persoenliche API-Keys werden nicht in die Build-
Umgebung uebernommen. Selbst gebaute Windows-EXEs sind deshalb nicht automatisch
wie die offiziellen Releases signiert. Signatur-/Sandbox-/Antivirenschutz nicht
abschalten, um eine Abnahme zu erzwingen. `test/verify.mjs` startet einen Browser
und wird daher ausdruecklich **nicht** als nebenwirkungsfreier Buildtest ausgefuehrt.

## Ergebnis, Status und Entfernung

Linux erzeugt `development/source/out/enki-browser-<version>-linux-x64.tar.gz`,
gegebenenfalls zusaetzlich ein `.deb`. Windows erzeugt dort
`EnkiBrowserSetup-<version>.exe`. Diese Dateien werden nur erstellt/gehasht,
nicht installiert. Paketbuild maximal vier Stunden fuer den eigentlichen
Assemblierungsschritt, npm-Schritte haben eigene Zeitlimits. Kein garantiertes
Zeit-/Platzbudget fuer den gesamten Vorgang.

`ready.json` belegt **Studienquellen**, nicht eine Browserinstallation.
`package-build.json` belegt getrennt das erzeugte Paket samt SHA256;
`package_built` und `application_tested:false` machen diese Grenze sichtbar.
GUI, Laufzeitbibliotheken, Profilisolierung und Sandbox danach separat abnehmen.

```bash
bash scripts/tools/enki_browser_study_doctor.sh
bash scripts/tools/enki_browser_study_uninstall.sh
```

Nur unveraenderte Studienquellen ohne Entwicklungs-/Paketbestand werden vom
Installer entfernt. Bei vorhandenen Entwicklungsdaten oder geaenderten Quellen
wird abgebrochen: erst privat sichern und bewusst verwalten. Fehler beim Paket-
build erhalten Entwicklungsdaten zur Diagnose; ein fehlgeschlagener Build
erstellt keinen erfolgreichen neuen Paketnachweis. Eine erneute automatische
Erstbuild-Strecke braucht wieder ein neues Entwicklungsziel. Keine Profile,
alten Desktop-Installationen oder Systempakete werden geloescht.

**Abnahmegrenze:** Offline-Fixtures pruefen Auswahl, Quellpin, sichere Pfade,
Binaer-Freigabe und Paketbefehle. Ein echter Enki-Paketbuild, native Windows-
Kompilierung und Browserstart wurden hier nicht ausgefuehrt. Details:
[Browser-Recherchetools](comet-and-browser-research.md) und
[BrowserOS-Studienweg](browseros-study.md).
