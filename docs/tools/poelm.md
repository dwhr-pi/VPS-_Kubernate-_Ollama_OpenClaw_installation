# PoeLM

Meter-/Reim-konditionierte Poesieforschung mit annotierten Textkorpora; Versuche fuer Spanisch und Baskisch,
keine pauschale deutsche Sprachfreigabe.

Optionaler Menuepunkt **PoeLM**, Bereitschaft `planned`, keine fertige Runtime.
Primaerquelle: [aitorormazabal/poetry_generation](https://github.com/aitorormazabal/poetry_generation).
Gepruefter Pin: `26a882b2b571a834a218d539e8b76c8296e10dde`.
README und vorhandene Lizenzdateien werden gegen die SHA256 im Quellenmanifest geprueft.

## Lizenz und Risiken

Keine Root-LICENSE am geprueften Pin. Oeffentliche GitHub-Sichtbarkeit ist keine bestaetigte allgemeine
Nutzungs-/Weitergabelizenz.

Korpusaufbereitung, SentencePiece, Training und Generierung werden nicht ausgefuehrt. Keine Trainingskorpora
oder fertigen Gewichte werden mitinstalliert.

## Native Quellenverwaltung

Python 3 und Git erforderlich; 2048 MiB Reserve nur fuer Quellen, nicht fuer
Modelle oder GPU-Builds. Kein Docker-Fallback. Keine Pakete, Gewichte, GUI,
Modelle, Audio, Trainingslaeufe, APIs oder Dienste automatisch starten.

```bash
bash scripts/tools/poelm_install.sh --dry-run
bash scripts/tools/poelm_install.sh
bash scripts/tools/poelm_status.sh
bash scripts/tools/poelm_doctor.sh
bash scripts/tools/poelm_update.sh --dry-run
bash scripts/tools/poelm_uninstall.sh --dry-run
```

`source_prepared` ist kein Buildnachweis: `installed: false`, `runtime_tested: false`.
Doctor prueft Origin, Pin, Vertragsdateien und Inventar; kein Modelltest.
Update bleibt beim Pin. Uninstall ohne `--dry-run` entfernt nur unveraenderte,
inventarisierte Quellen mit Besitznachweis unter
`~/.openclaw_ultimate_user_data/tools/poelm/`. Geaenderte Dateien sperren die
Entfernung. Logs, Modelle und sonstige Benutzerdateien bleiben erhalten.
Keine systemd-Unit fuer reine Quellenverwaltung. Vollstaendiger nativer
Runtime-Build, Dependency-Lock/SBOM, Gewichtsrechte und End-to-End-Test offen.

## Verwendung im Setup

[Musik-/Lyrics-Katalog](../MUSIC_LYRICS_MODEL_CATALOG.md),
[Reim-/Lyric-Pruefung](../CREATIVE_LYRICS.md),
[Open Weights und Einrichtung](../models/README.md).
Keine automatische Uebernahme von Modellantworten als gepruefte Reime,
Musikrechte oder Fine-Tuning-Daten. Lyrics und Audio brauchen eigene Freigaben.

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
python3 -I -B scripts/tool_commands.py show poelm
```

### SSH-Aktionen: `poelm`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`PoeLM` (ID `poelm`) waehlen und die Einzelfreigaben lesen.
Fehlt der Eintrag oder ist der native Weg gesperrt, hier stoppen: keine
Legacy-/Docker-Ausweichinstallation und kein automatischer Plattformwechsel.

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](../HEADLESS_SETUP.md) | [Befehle aller registrierten
Tools](../generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
