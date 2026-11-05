# Qwen Desktop: Studienzwecke und Weiterentwicklung

**Qwen_Desktop_Study** bietet wie Enki einen optionalen GitHub-Quellcheckout und einen gesondert
freizugebenden Build an. Zweck: Quellcode untersuchen, eigene Anpassungen entwickeln und lokale
Desktop-Pakete erproben. Experimentell, keine Produktionsfreigabe. Diese Zweckbeschreibung ist keine
neue Lizenz; Upstream- und Abhaengigkeitslizenzen gelten weiterhin.

Quelle: [QwenLM/qwen-code](https://github.com/QwenLM/qwen-code), Pin
`bf66a26c978dac68af31fbc093eb53044e204b24`, wie beim bisherigen Desktop-Build. Desktop-Code:
`packages/desktop`. Kein Docker und kein automatisches main-Upgrade.

## Auswahl im Setup

Im Tools-Menue unterhalb der Trennlinie alphabetisch unter **Qwen_Desktop_Study**:

1. **Nur Studienquellen** (Standard): gepinnten GitHub-Checkout laden, kein Build.
2. **Zusaetzlich Desktop bauen**: nach Zustimmung in einer separaten Kopie bauen.

Ohne interaktives Terminal werden nur Quellen geladen, sofern der Build nicht explizit per Flag
gewaehlt wurde. Die bisherigen Eintraege bleiben getrennt: `Qwen_Desktop` fuer den
[manuellen Windows-Download](qwen-desktop-windows.md), `Qwen_Desktop_Build` fuer den
[direkten Buildweg](github-gap-tools.md#qwen-code-desktop-download-oder-eigener-build).

## Aufrufe

Vom Repository-Stamm unter Linux/WSL:

```bash
# Plan ohne Downloads oder Aenderungen
bash scripts/tools/qwen_desktop_study_install.sh --dry-run
# Quellen, interaktiv mit optionaler Build-Auswahl
bash scripts/tools/qwen_desktop_study_install.sh
# Explizite Freigabe des Builds und seiner Abhaengigkeitsdownloads
bash scripts/tools/qwen_desktop_study_install.sh --build-desktop
bash scripts/tools/qwen_desktop_study_status.sh
bash scripts/tools/qwen_desktop_study_doctor.sh
```

Natives Windows: aus einer VS Developer PowerShell, nicht als WSL-Cross-Build:

```powershell
python -B scripts/tools/helpers/qwen_desktop_study.py install
python -B scripts/tools/helpers/qwen_desktop_study.py install --build-desktop
python -B scripts/tools/helpers/qwen_desktop_study.py status
```

Fuer Quellen gilt eine Reserve von 2 GiB; fuer den optionalen Build mindestens 20 GiB freier Ziel-
und unter WSL Windows-Host-Speicher. Dies ist eine Startreserve, keine Obergrenze. Der bestehende
Buildvertrag verlangt Node 22, npm/Corepack, Rust/Cargo und tar; unter Linux mindestens 6 GiB
verfuegbaren RAM sowie pkg-config mit WebKitGTK 4.1, GTK 3 und librsvg. Windows braucht die
vorhandene Visual-Studio-C++-Toolchain. Fehlende Basiswerkzeuge werden nicht automatisch systemweit
installiert.

Der Build laedt Paketabhaengigkeiten und fuehrt Buildskripte aus. Nur in einer isolierten
Entwicklungsumgebung verwenden. Linux erzeugt ein AppImage, natives Windows ein NSIS-Paket. Keine
Signierung, Installation, Anmeldung, Modellabfrage oder GUI-/Dienststarts. Das Paket ist lokal und
unsigniert; ein Build ist kein Anwendungstest.

## Status und Datenerhalt

Privater Ordner: `~/.openclaw_ultimate_user_data/tools/qwen_desktop_study/` (ueber
`OPENCLAW_USER_DATA_DIR` umstellbar).

| Pfad                  | Bedeutung                                                    |
| --------------------- | ------------------------------------------------------------ |
| `runtime/`            | Gepruefte Studienquellen                                     |
| `ready.json`          | Quellennachweis, keine fertige Anwendung                     |
| `development/source/` | Separate Build-/Entwicklungskopie mit Tauri-Artefakten       |
| `desktop-build.json`  | Buildnachweis mit Artefakt-Hashes, separat vom Quellenstatus |

Status meldet `scope: study-sources`, `desktop_built` und stets `application_tested: false`. Doctor
prueft Quellen und vorhandene Buildnachweise. Eigene Quellenaenderungen verhindern automatisches
Bauen/Deinstallieren. Bei vorhandenen Entwicklungsdaten ist die automatische Deinstallation
gesperrt: erst sichern und manuell pruefen. Fehlgeschlagene Builds behalten ihre Entwicklungskopie
zur Diagnose und erhalten keinen erfolgreichen Buildnachweis. Update bleibt beim geprueften Pin;
Entwicklungsdaten werden nicht ueberschrieben.

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
python3 -I -B scripts/tool_commands.py show qwen_desktop_study
```

### SSH-Aktionen: `qwen_desktop_study`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`Qwen_Desktop_Study` (ID `qwen_desktop_study`) waehlen und die Einzelfreigaben lesen.
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
