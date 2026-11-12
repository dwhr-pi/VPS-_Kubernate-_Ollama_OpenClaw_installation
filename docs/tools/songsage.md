# SongSage: geplanter Forschungs-Eintrag, keine Installation

Gemeint ist [SongSage: Lyric Generative Pre-training](https://arxiv.org/abs/2601.01153),
nicht ein gleichnamiger BirdNET-/MCP-Server, Hit-Song-Predictor oder Webdienst.
Gezielte Quellenpruefung: **11.11.2026**.

Das Paper beschreibt LyricBank und ein Lyrics-LLM, haelt die Trainingsdaten
aus Urheberrechtsgruenden jedoch zurueck. Eine eindeutige offizielle GitHub-
Veroeffentlichung mit nachgewiesenem Code-/Gewichtspin und Lizenz wurde in
dieser Pruefung nicht bestaetigt. Kein erfundener Repository-Link und kein
Ersatzprojekt gleichen Namens. Das ist kein Nachweis, dass es nirgendwo Code gibt.

## Menue und ehrlicher Status

`SongSage` ist als `planned` registriert, `auto_install: false`.
Der Handler ist ausschliesslich ein begrenzter Offline-Planungsguard:

```bash
bash scripts/tools/songsage_install.sh --dry-run
bash scripts/tools/songsage_status.sh
bash scripts/tools/songsage_doctor.sh
```

Status: `installed: false`, `source_prepared: false`, `runtime_tested: false`,
`performed: false`. Install/Update/Doctor/Check ohne `--dry-run` enden mit
**Exit 3: unvollstaendig**, nicht mit einem Scheinerfolg. Plan, Dry-Run und
Status sind lesend. Uninstall ist ein explizites No-op ohne Datenentfernung.
Kein Download, keine Marker, kein Benutzerverzeichnis, keine Keys, kein Docker,
keine Modelle, APIs oder Dienste. Keine systemd-Unit fuer diesen Doku-Guard.

Offen: offizielle GitHub-Zuordnung, Code-/Gewichts-/Datensatzrechte, Pins,
SHA256, nativer Build-/Dependency-Lock/SBOM und echter Runtime-Test.
Erst nach belegter Veroeffentlichung den Guard durch ein geprueftes Rezept
ersetzen; die Installationssperre nicht pauschal umgehen.

[Musik-/Lyrics-Katalog](../MUSIC_LYRICS_MODEL_CATALOG.md),
[Lyrics-Pruefer](../CREATIVE_LYRICS.md),
[Training und Datenrechte](../models/TRAINING_AND_EVALUATION.md).

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
python3 -I -B scripts/tool_commands.py show songsage
```

### SSH-Aktionen: `songsage`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`SongSage` (ID `songsage`) waehlen und die Einzelfreigaben lesen.
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
