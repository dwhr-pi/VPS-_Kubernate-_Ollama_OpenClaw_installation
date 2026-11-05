# HyperFrames: HTML und Animationen zu Video

Stand: **22.10.2026**. [GitHub](https://github.com/heygen-com/hyperframes),
[Build-Anleitung](https://github.com/heygen-com/hyperframes/blob/main/CONTRIBUTING.md).

**Zweck:** HTML-basierte Videokomposition fuer eigene oder agentisch vorbereitete Inhalte. Eine
Kompositionsebene, kein Wan-/LTX-Videomodell. Vorhandene Clips koennen spaeter eingebunden werden,
ein generativer Modelltausch findet nicht statt.

## GitHub-Source-Build statt Docker

**HyperFrames** ist jetzt ein eigener Tools-Menueeintrag mit Source-Build, Status/Doctor, Update und
Deinstallation. Gepinnter Commit: `3d67fb9d10a864201db9de3214f8cd67fb6fec46`, CLI **0.8.186**. Der
Installer verwendet `bun.lock`, unterdrueckt Dependency-Lifecycle- Skripte und baut die fuer den
CLI-Pfad vorgesehenen Workspace-Pakete nacheinander. Kein Docker-Image, `npx latest` oder
Studio-/Dienststart.

Voraussetzungen: vorhandenes **Node >=22**, **Bun genau 1.4.4**, mindestens **4 GiB verfuegbarer
RAM** und **12 GiB freier Zielspeicher**. Bei erkannter WSL-Umgebung dieselbe Reserve auf C:. Die
etwa 11 GiB aus dem Nutzerlog reichen nicht. Bei anderer VHDX-Ablage deren Hostlaufwerk ebenfalls
pruefen. Reserven sind konservative Planung, kein gemessener exakter Buildbedarf.

Die Bun-Vorgabe kommt aus dem gepinnten
[Manifest](https://github.com/heygen-com/hyperframes/blob/3d67fb9d10a864201db9de3214f8cd67fb6fec46/package.json).
Kein ungefragter globaler Node-/Bun-Umbau. Installersteuerung: Python >=3.10 ohne venv/ensurepip.
Unterschiedliche Projekte koennen andere Bun-Versionen brauchen; nicht fuer Remotion global die
HyperFrames-Version erzwingen.

```bash
bash scripts/tools/hyperframes_install.sh --dry-run
bash scripts/tools/hyperframes_install.sh
bash scripts/tools/hyperframes_status.sh
bash scripts/tools/hyperframes_doctor.sh
bash scripts/tools/hyperframes_update.sh
bash scripts/tools/hyperframes_uninstall.sh
```

Privater CLI-Einstieg nach dem Build, bewusst manuell:

```bash
node "$HOME/.openclaw_ultimate_user_data/tools/hyperframes/runtime/packages/cli/bin/hyperframes.mjs" --help
```

Bei `OPENCLAW_USER_DATA_DIR` den Pfad anpassen. Kein globaler CLI-Link. Browser, Renderbibliotheken
und eigenes HTML-Projekt muessen vor dem ersten Video separat getestet werden. Projekte ausserhalb
der Runtime speichern.

## Integration in den Medien-Stack

```text
Eigenes Briefing -> HTML-Komposition + freigegebene Bilder/Clips
  -> HyperFrames nach Browser-/Render-Test
  -> Sicht-/Tonpruefung -> manueller Export
```

[OpenMontage](openmontage.md) und der
[Offline-Rezeptplaner](../media_studio/EDITABLE_VIDEO_WORKFLOWS.md) werden nicht automatisch
angebunden. Der Build ersetzt keinen Adapter. MCP, Skills, Provider, Studio-Ports und oeffentliche
Dienste bleiben aus. Cloud-bezogene Workspace-Pakete werden nur als Code gebaut, nicht
provisioniert; kein AWS-/Google-Konto wird verbunden.

Code-Lizenz:
[Apache-2.0](https://github.com/heygen-com/hyperframes/blob/3d67fb9d10a864201db9de3214f8cd67fb6fec46/LICENSE).
Fonts, Musik, Medien und Modelle haben eigene Rechte; keine pauschale Garantie fuer
kostenlose/offline Produktion oder jedes kommerzielle Template.

## Umfang, Logs und Rollback

Echte Git-/Paket-/Build-Kommandos statt Platzhalter; Marker erst nach erwarteten CLI-Artefakten und
Syntaxpruefung. Trotzdem `runtime_ready=false` bis zum funktionalen Browser-/Codec-Test. Hier kein
kompletter Zielsystem- Build ausgefuehrt, nur Offline-Installerlogik getestet.

Upstream-Buildskripte sind ausfuehrbarer Code; ausgeschaltete Dependency- Hooks ersetzen keine
Sandbox. Privates Build-Home, keine Weitergabe von Provider-Keys als Umgebungsvariablen;
Paketdownloads brauchen Netzwerk. Gemeinsamer Lock gegen parallele neue Medieninstallationen;
verwaiste Locks nur nach Prozesskontrolle behandeln.

Fehler/Speicherabbrueche stehen im aktuellen Operationslog. Neue Stages werden entfernt, bestehende
Installationen nicht ueberschrieben. Status verlangt Marker und Artefakte; Doctor/Deinstallation
pruefen das ganze Inventar und verweigern bei Aenderungen/Zusatzdateien. Update bleibt beim Pin.
Externe Projekte, Logs, Modelle und Basiswerkzeuge bleiben erhalten.

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
python3 -I -B scripts/tool_commands.py show hyperframes
```

### SSH-Aktionen: `hyperframes`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`HyperFrames` (ID `hyperframes`) waehlen und die Einzelfreigaben lesen.
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
