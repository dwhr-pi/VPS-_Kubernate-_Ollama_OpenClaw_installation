# MiniMax-M3: GitHub-Quellbestand

## Zweck und Umfang

Auswaehlbares optionales Tool **MiniMax_M3**, Status `experimental` / `planned`.
Der Installer bereitet ausschliesslich den festen GitHub-Quellstand vor.
Kein Modellgewicht, Inferenzserver oder fertiger Agent wird dadurch installiert.

Primaerquelle: [MiniMax-AI/MiniMax-M3](https://github.com/MiniMax-AI/MiniMax-M3).
Gepruefter Pin: `8ef4ca53e1b0e8cd3d79b617a9fd229d2b6fd5f0`.
Der gepruefte Bestand enthaelt Modelldokumentation, nicht eine vollstaendige
baubare Inferenz-Anwendung. Das README wird zusaetzlich per SHA256 gegen das
Quellenmanifest geprueft. Im Root liegt keine eigene LICENSE-Datei;
Gewichte unterliegen gesondert der MiniMax Community License.

Die [Hardware-/Lizenzbewertung](../HYBRID_CLOUD_MCP.md) bleibt verbindlich.
Kein Standard fuer eine einzelne Heim-GPU; Modelle, Quantisierung, Engine und
deren Lizenzen erfordern einen separaten geprueften Installationsplan.
Die [MiniMax API](../_API-Keys/OnlineOnKeyServices/minimax.md) ist eine andere,
externe Betriebsart und kein Ersatz fuer fehlende lokale Modellgewichte.

## Lifecycle und Grenzen

Sprachen: Allgemeine Coding-Faehigkeiten sind beschrieben, aber keine hier
abgenommene vollstaendige Sprachliste. Python, JavaScript/TypeScript, C/C++,
Java, Rust, Go und Assembler als eigene Pruefkandidaten behandeln; insbesondere
Assembler ist nicht explizit fuer einen Dialekt belegt. Details:
[Sprachmatrix und Gewichts-Einrichtung](../models/README.md),
[RAG und Herkunft](../models/WEIGHTS_RAG_AND_PROVENANCE.md),
[Training und Datenmigration](../models/TRAINING_AND_EVALUATION.md).

Python 3 und Git erforderlich. 2048 MiB Diskreserve fuer den Quellbestand,
**keine Groessenschaetzung fuer Modelle oder Inferenz**. Vorher nur planen:

```bash
bash scripts/tools/minimax_m3_install.sh --dry-run
# Explicit source preparation; no runtime or model installation.
bash scripts/tools/minimax_m3_install.sh
bash scripts/tools/minimax_m3_status.sh
bash scripts/tools/minimax_m3_doctor.sh
bash scripts/tools/minimax_m3_update.sh --dry-run
bash scripts/tools/minimax_m3_uninstall.sh --dry-run
```

Installation nur nach bewusster Auswahl; keine Installation durch diese Doku.
Status meldet `source_prepared`, immer `installed: false` und
`runtime_tested: false`. Doctor prueft Pin, Origin, Hashes und Dateiinventar,
keine Inferenz. Update bleibt beim selben Pin; neue Pins nur nach Review.
Deinstallation ohne `--dry-run` entfernt nur den unveraenderten privaten
Quellbestand mit Besitznachweis. Eigene Aenderungen fuehren zum Abbruch;
Logs, Modelle, sonstige Benutzerdaten und Basiswerkzeuge bleiben erhalten.
Der Quellbestand liegt unter `~/.openclaw_ultimate_user_data/tools/minimax_m3/`.
Eine systemd-Unit ist fuer diese reine Quellenverwaltung nicht anwendbar.
Offen: nativer Engine-Build, gewichtsspezifische Integritaet, SBOM,
Ressourcenmessung und echte Runtime-Abnahme. Kein Docker-Fallback.

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
python3 -I -B scripts/tool_commands.py show minimax_m3
```

### SSH-Aktionen: `minimax_m3`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`MiniMax_M3` (ID `minimax_m3`) waehlen und die Einzelfreigaben lesen.
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
