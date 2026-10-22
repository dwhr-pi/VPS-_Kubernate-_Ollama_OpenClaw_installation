# HyperFrames: HTML und Animationen zu Video

Stand: **22.10.2026**. [GitHub](https://github.com/heygen-com/hyperframes),
[Build-Anleitung](https://github.com/heygen-com/hyperframes/blob/main/CONTRIBUTING.md).

**Zweck:** HTML-basierte Videokomposition fuer eigene oder agentisch
vorbereitete Inhalte. Eine Kompositionsebene, kein Wan-/LTX-Videomodell.
Vorhandene Clips koennen spaeter eingebunden werden, ein generativer
Modelltausch findet nicht statt.

## GitHub-Source-Build statt Docker

**HyperFrames** ist jetzt ein eigener Tools-Menueeintrag mit Source-Build,
Status/Doctor, Update und Deinstallation. Gepinnter Commit:
`3d67fb9d10a864201db9de3214f8cd67fb6fec46`, CLI **0.8.186**.
Der Installer verwendet `bun.lock`, unterdrueckt Dependency-Lifecycle-
Skripte und baut die fuer den CLI-Pfad vorgesehenen Workspace-Pakete
nacheinander. Kein Docker-Image, `npx latest` oder Studio-/Dienststart.

Voraussetzungen: vorhandenes **Node >=22**, **Bun genau 1.4.4**, mindestens
**4 GiB verfuegbarer RAM** und **12 GiB freier Zielspeicher**. Bei erkannter
WSL-Umgebung dieselbe Reserve auf C:. Die etwa 11 GiB aus dem Nutzerlog
reichen nicht. Bei anderer VHDX-Ablage deren Hostlaufwerk ebenfalls pruefen.
Reserven sind konservative Planung, kein gemessener exakter Buildbedarf.

Die Bun-Vorgabe kommt aus dem gepinnten
[Manifest](https://github.com/heygen-com/hyperframes/blob/3d67fb9d10a864201db9de3214f8cd67fb6fec46/package.json).
Kein ungefragter globaler Node-/Bun-Umbau. Installersteuerung: Python >=3.10
ohne venv/ensurepip. Unterschiedliche Projekte koennen andere Bun-Versionen
brauchen; nicht fuer Remotion global die HyperFrames-Version erzwingen.

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

Bei `OPENCLAW_USER_DATA_DIR` den Pfad anpassen. Kein globaler CLI-Link.
Browser, Renderbibliotheken und eigenes HTML-Projekt muessen vor dem ersten
Video separat getestet werden. Projekte ausserhalb der Runtime speichern.

## Integration in den Medien-Stack

```text
Eigenes Briefing -> HTML-Komposition + freigegebene Bilder/Clips
  -> HyperFrames nach Browser-/Render-Test
  -> Sicht-/Tonpruefung -> manueller Export
```

[OpenMontage](openmontage.md) und der
[Offline-Rezeptplaner](../media_studio/EDITABLE_VIDEO_WORKFLOWS.md) werden
nicht automatisch angebunden. Der Build ersetzt keinen Adapter. MCP,
Skills, Provider, Studio-Ports und oeffentliche Dienste bleiben aus.
Cloud-bezogene Workspace-Pakete werden nur als Code gebaut, nicht
provisioniert; kein AWS-/Google-Konto wird verbunden.

Code-Lizenz: [Apache-2.0](https://github.com/heygen-com/hyperframes/blob/3d67fb9d10a864201db9de3214f8cd67fb6fec46/LICENSE).
Fonts, Musik, Medien und Modelle haben eigene Rechte; keine pauschale
Garantie fuer kostenlose/offline Produktion oder jedes kommerzielle Template.

## Umfang, Logs und Rollback

Echte Git-/Paket-/Build-Kommandos statt Platzhalter; Marker erst nach
erwarteten CLI-Artefakten und Syntaxpruefung. Trotzdem `runtime_ready=false`
bis zum funktionalen Browser-/Codec-Test. Hier kein kompletter Zielsystem-
Build ausgefuehrt, nur Offline-Installerlogik getestet.

Upstream-Buildskripte sind ausfuehrbarer Code; ausgeschaltete Dependency-
Hooks ersetzen keine Sandbox. Privates Build-Home, keine Weitergabe von
Provider-Keys als Umgebungsvariablen; Paketdownloads brauchen Netzwerk.
Gemeinsamer Lock gegen parallele neue Medieninstallationen; verwaiste Locks
nur nach Prozesskontrolle behandeln.

Fehler/Speicherabbrueche stehen im aktuellen Operationslog. Neue Stages
werden entfernt, bestehende Installationen nicht ueberschrieben. Status
verlangt Marker und Artefakte; Doctor/Deinstallation pruefen das ganze
Inventar und verweigern bei Aenderungen/Zusatzdateien. Update bleibt beim
Pin. Externe Projekte, Logs, Modelle und Basiswerkzeuge bleiben erhalten.
