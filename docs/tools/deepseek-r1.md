# DeepSeek-R1: offene Modellfamilie und GitHub-Quellen

## Lizenz und Abgrenzung

**DeepSeek ist ein Anbieter, kein einheitliches Lizenzpaket.** Fuer dieses Tool
wird konkret [DeepSeek-R1](https://github.com/deepseek-ai/DeepSeek-R1) verwendet.
Der Upstream stellt dessen Code und R1-Gewichte unter MIT bereit. Bei
Distill-Varianten sind zusaetzlich die Bedingungen des Qwen-/Llama-Basismodells
zu pruefen. Das ist keine Zusicherung vollstaendig veroeffentlichter
Trainingsdaten oder einer reproduzierbaren gesamten Trainingspipeline.

Pin: `0cf78561f1d51c84a21b2190626b21116d5c68bb`.
README und LICENSE sind mit SHA256 im Quellenmanifest verankert.
Tool **DeepSeek_R1**, Status `experimental` / `planned`.
Das Repository liefert Modelldokumentation, nicht die Gewichte oder einen
vollstaendigen Inferenzdienst. Das grosse R1 ist kein Einzel-RTX-Standard;
kleinere Distills separat nach RAM/VRAM, Kontext, Lizenz und Qualitaet bewerten.

Die [DeepSeek API](../_API-Keys/OnlineOnKeyServices/deepseek.md) ist davon
getrennte Cloud-Nutzung. Ein API-Modellname muss nicht R1 aus diesem Pin sein.

## Lifecycle und Grenzen

Sprachen: Der gepruefte Upstream belegt Coding-Evaluation, aber keine hier
abgenommene vollstaendige Sprachliste. Python, C/C++, Java, Rust, Go und
Assembler sind eigene Pruefkandidaten, keine garantierte Supportzusage.
Assembler immer mit ISA/Syntax/ABI pruefen. Die
[Sprachmatrix und Open-Weights-Einrichtung](../models/README.md) sowie
[Training und Datenmigration](../models/TRAINING_AND_EVALUATION.md) gelten
auch fuer dieses Modell; [Herkunft statt Umbenennung](../models/WEIGHTS_RAG_AND_PROVENANCE.md).

Python 3, Git und 2048 MiB Diskreserve **nur fuer GitHub-Quellen**.

```bash
bash scripts/tools/deepseek_r1_install.sh --dry-run
# Explicit source preparation; no weights, API requests or inference.
bash scripts/tools/deepseek_r1_install.sh
bash scripts/tools/deepseek_r1_status.sh
bash scripts/tools/deepseek_r1_doctor.sh
bash scripts/tools/deepseek_r1_update.sh --dry-run
bash scripts/tools/deepseek_r1_uninstall.sh --dry-run
```

Status: `source_prepared`, niemals eine fertige Modellinstallation;
`installed: false`, `runtime_tested: false`. Doctor prueft Quellenintegritaet,
keine Inferenz. Update bleibt beim Pin. Uninstall ohne `--dry-run` entfernt
nur den unveraenderten, inventarisierten Quellbestand unter
`~/.openclaw_ultimate_user_data/tools/deepseek_r1/`; eigene Aenderungen sperren
die Entfernung. Logs, Modelle und sonstige Benutzerdaten bleiben erhalten.
Keine systemd-Unit fuer Quellenverwaltung; native Engine-/Gewichtsinstallation,
SBOM und Smoke-/Runtime-Abnahme bleiben offen. Kein Docker-Fallback.

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
python3 -I -B scripts/tool_commands.py show deepseek_r1
```

### SSH-Aktionen: `deepseek_r1`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`DeepSeek_R1` (ID `deepseek_r1`) waehlen und die Einzelfreigaben lesen.
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
